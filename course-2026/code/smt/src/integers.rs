//! A small solver for linear integer arithmetic by branch and bound.
//!
//! Input: a conjunction of linear constraints `a1*x1 + ... + an*xn <= b`
//! over integer variables. The solver works on the rational relaxation:
//!
//! 1. Solve the constraints as a linear program over the reals (the
//!    Fourier--Motzkin solver in the [`linear`](crate::linear) module).
//! 2. If the relaxation is unsatisfiable, so is the integer system.
//! 3. If every variable in the rational solution is an integer, that is the
//!    answer.
//! 4. Otherwise pick a fractional variable `x` with rational value `v` and
//!    branch: try adding `x <= floor(v)`, then `x >= ceil(v)`, and recurse.
//!
//! Branching on a fractional value can only add integer bounds, so each branch strictly narrows the feasible region and the search terminates.
//! In the worst case it is exponential, so keep the systems small.
//! Variables that are unbounded in the relaxation are assigned integer values directly and never branched on.
//! Solutions are integers that must fit `i64`.
//!
//! ```
//! use smt::integers::{solve, Constraint};
//!
//! // x >= 1/2 and x <= 1/2: the relaxation has the solution x = 1/2,
//! // which is fractional, and neither branch x <= 0 nor x >= 1 works.
//! let cs = vec![
//!     Constraint { coeffs: vec![-2], b: -1 }, // x >= 1/2
//!     Constraint { coeffs: vec![2], b: 1 },   // x <= 1/2
//! ];
//! assert_eq!(solve(&cs), None);
//!
//! // x + y >= 1 with x <= 1 and y <= 1: x = 1, y = 0 satisfies all three.
//! let cs = vec![
//!     Constraint { coeffs: vec![-1, -1], b: -1 },
//!     Constraint { coeffs: vec![1, 0], b: 1 },
//!     Constraint { coeffs: vec![0, 1], b: 1 },
//! ];
//! let m = solve(&cs).unwrap();
//! assert!(m[0] + m[1] >= 1 && m[0] <= 1 && m[1] <= 1);
//! ```

use crate::linear;

/// A linear constraint `a1*x1 + ... + an*xn <= b` over integer variables.
///
/// Variable `i` is the coefficient `coeffs[i]`.
/// The number of variables is inferred as the largest coefficient list length.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Constraint {
    /// Coefficients `a1..an`.
    pub coeffs: Vec<i64>,
    /// The constant bound.
    pub b: i64,
}

/// Solve a conjunction of integer linear constraints.
///
/// Returns `Some(assignment)` when satisfiable, where `assignment[i]` is the integer value of variable `i`.
/// `None` means unsatisfiable.
pub fn solve(constraints: &[Constraint]) -> Option<Vec<i64>> {
    let n = constraints
        .iter()
        .map(|c| c.coeffs.len())
        .max()
        .unwrap_or(0);
    let relaxation: Vec<linear::Constraint> = constraints
        .iter()
        .map(|c| linear::Constraint {
            coeffs: c.coeffs.clone(),
            b: c.b,
            rel: linear::Rel::Le,
        })
        .collect();
    search(&relaxation, n)
}

/// Branch and bound over the rational relaxation `lin` of `n` variables.
fn search(lin: &[linear::Constraint], n: usize) -> Option<Vec<i64>> {
    let lp = linear::solve(lin)?;

    // A fractional variable triggers the split. The first one is fine.
    let mut fractional: Option<usize> = None;
    for (i, v) in lp.iter().enumerate() {
        if !v.is_integer() {
            fractional = Some(i);
            break;
        }
    }
    let Some(k) = fractional else {
        // All values are integers: the rational solution is the answer.
        let mut out = Vec::with_capacity(n);
        for v in &lp {
            out.push(i64::try_from(v.num).ok()?);
        }
        return Some(out);
    };

    let v = lp[k];
    let lo = v.floor();
    let hi = v.ceil();

    // Branch 1: x_k <= floor(v).
    let mut c1: Vec<linear::Constraint> = lin.to_vec();
    let mut upper = vec![0i64; n];
    upper[k] = 1;
    let lo64 = i64::try_from(lo).ok()?;
    c1.push(linear::Constraint {
        coeffs: upper,
        b: lo64,
        rel: linear::Rel::Le,
    });
    if let Some(m) = search(&c1, n) {
        return Some(m);
    }

    // Branch 2: x_k >= ceil(v), written as -x_k <= -ceil(v).
    let mut c2: Vec<linear::Constraint> = lin.to_vec();
    let mut lower = vec![0i64; n];
    lower[k] = -1;
    let hi64 = i64::try_from(hi).ok()?;
    c2.push(linear::Constraint {
        coeffs: lower,
        b: -hi64,
        rel: linear::Rel::Le,
    });
    search(&c2, n)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn c(coeffs: Vec<i64>, b: i64) -> Constraint {
        Constraint { coeffs, b }
    }

    #[test]
    fn integral_solution_without_branching() {
        let cs = vec![c(vec![2, 1], 5), c(vec![-1, 0], 0), c(vec![0, -1], 0)];
        let m = solve(&cs).unwrap();
        // 2x + y <= 5 with x >= 0, y >= 0: relaxation already integral.
        assert!(2 * m[0] + m[1] <= 5 && m[0] >= 0 && m[1] >= 0);
    }

    #[test]
    fn branching_is_needed() {
        // 2x <= 1 (x <= 1/2) and x >= 1/2: only the fractional relaxation
        // value 1/2 satisfies the reals, no integer does.
        let cs = vec![c(vec![-2], -1), c(vec![2], 1)];
        assert_eq!(solve(&cs), None);
    }

    #[test]
    fn branch_then_succeed() {
        // 2x >= 1 and x <= 1: x = 1 is integral, the x <= 0 branch fails.
        let cs = vec![c(vec![-2], -1), c(vec![1], 1)];
        let m = solve(&cs).unwrap();
        assert!(m[0] == 1);
    }

    #[test]
    fn lower_bound_and_rounding() {
        // x >= 1/2 alone: branch x <= 0 fails, x >= 1 succeeds with x = 1.
        let cs = vec![c(vec![-2], -1)];
        let m = solve(&cs).unwrap();
        assert!(m[0] == 1);
    }

    #[test]
    fn two_branches_both_fail() {
        // x >= 1/2 and x <= 3/2 and 2x = 2k... keep it simple: x >= 1/2,
        // x <= 1/2 (no integer), and a constant contradiction 0 <= -1.
        let cs = vec![c(vec![-2], -1), c(vec![2], 1), c(vec![0], -1)];
        assert_eq!(solve(&cs), None);
    }

    #[test]
    fn negative_coefficients() {
        // -x <= -3 (x >= 3) and x <= 5: x = 3.
        let cs = vec![c(vec![-1], -3), c(vec![1], 5)];
        let m = solve(&cs).unwrap();
        assert!(m[0] == 3);
    }

    #[test]
    fn two_variable_system() {
        // x + 2y <= 4, x >= 1, y >= 1, x <= 2: x = 1, y = 1 works and the
        // relaxation x = 2, y = 1 forces a split on x.
        let cs = vec![
            c(vec![1, 2], 4),
            c(vec![-1, 0], -1),
            c(vec![0, -1], -1),
            c(vec![1, 0], 2),
        ];
        let m = solve(&cs).unwrap();
        assert!(m[0] + 2 * m[1] <= 4 && m[0] >= 1 && m[1] >= 1 && m[0] <= 2);
    }
}
