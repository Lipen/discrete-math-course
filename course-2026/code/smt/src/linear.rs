//! A small solver for linear real arithmetic by Fourier--Motzkin elimination.
//!
//! Input: a conjunction of linear constraints over real variables,
//! `a1*x1 + ... + an*xn <= b` (or `< b`, or `= b`). Output: an exact
//! rational assignment, or `None` when the system is unsatisfiable.
//!
//! Fourier--Motzkin elimination removes one variable at a time. A variable
//! `x` appears in upper bounds `x <= u` (positive coefficient) and in lower
//! bounds `x >= l` (negative coefficient). Every pair (lower, upper) is
//! combined into a new constraint `l <= u` that no longer mentions `x`; if
//! only one kind of bound exists, `x` is unbounded on the other side and the
//! pairings are skipped. After all variables are gone, only constraints
//! `0 <= c` remain, and any `c < 0` (or strict `0 < 0`) is a contradiction.
//! The assignment is recovered by back-substitution: each eliminated variable
//! is placed inside the bounds left for it.
//!
//! All arithmetic is exact rational arithmetic ([`Rat`]); there are no
//! floating-point tolerances. Two limits are inherent to the method: the
//! elimination multiplies coefficients, so intermediate products must stay
//! within `i128` (keep the numbers small), and the constraint set can double
//! per eliminated variable, so this is meant for small systems of a handful
//! of variables.
//!
//! ```
//! use smt::linear::{solve, Constraint, Rel, Rat};
//!
//! // 2x = 1: the exact rational solution is x = 1/2.
//! let cs = vec![Constraint { coeffs: vec![2], b: 1, rel: Rel::Eq }];
//! let m = solve(&cs).unwrap();
//! assert_eq!(m[0], Rat::new(1, 2));
//! assert_eq!(m[0].to_f64(), 0.5);
//! ```

use std::cmp::Ordering;
use std::fmt;
use std::ops::{Add, Mul, Neg, Sub};

/// An exact rational number `num / den`, always reduced with `den > 0`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Rat {
    /// Numerator.
    pub num: i128,
    /// Denominator (positive, 1 for integers).
    pub den: i128,
}

impl Rat {
    /// Build `num / den`, reduced and with a positive denominator.
    pub fn new(num: i128, den: i128) -> Rat {
        assert!(den != 0, "zero denominator");
        let (num, den) = if den < 0 { (-num, -den) } else { (num, den) };
        let g = gcd(num.unsigned_abs(), den.unsigned_abs());
        Rat {
            num: num / g as i128,
            den: den / g as i128,
        }
    }

    /// The integer `v` as a rational.
    pub fn int(v: i128) -> Rat {
        Rat { num: v, den: 1 }
    }

    /// The value as an `f64` (exact for rationals with small denominators).
    pub fn to_f64(&self) -> f64 {
        self.num as f64 / self.den as f64
    }

    /// True when the value is an integer.
    pub fn is_integer(&self) -> bool {
        self.den == 1
    }

    /// The greatest integer at most `self` (rounds toward minus infinity).
    pub fn floor(&self) -> i128 {
        self.num.div_euclid(self.den)
    }

    /// The smallest integer at least `self` (rounds toward plus infinity).
    pub fn ceil(&self) -> i128 {
        -(-self.num).div_euclid(self.den)
    }

    /// Divide by an integer, used for bound `x <= b / a` with `a` nonzero.
    fn div_int(self, d: i128) -> Rat {
        Rat::new(self.num, self.den * d)
    }
}

/// Greatest common divisor of two non-negative integers.
fn gcd(mut a: u128, mut b: u128) -> u128 {
    while b != 0 {
        let r = a % b;
        a = b;
        b = r;
    }
    a
}

impl Add for Rat {
    type Output = Rat;
    fn add(self, other: Rat) -> Rat {
        Rat::new(
            self.num * other.den + other.num * self.den,
            self.den * other.den,
        )
    }
}

impl Sub for Rat {
    type Output = Rat;
    fn sub(self, other: Rat) -> Rat {
        self + (-other)
    }
}

impl Neg for Rat {
    type Output = Rat;
    fn neg(self) -> Rat {
        Rat {
            num: -self.num,
            den: self.den,
        }
    }
}

impl Mul for Rat {
    type Output = Rat;
    fn mul(self, other: Rat) -> Rat {
        Rat::new(self.num * other.num, self.den * other.den)
    }
}

impl PartialOrd for Rat {
    fn partial_cmp(&self, other: &Rat) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for Rat {
    fn cmp(&self, other: &Rat) -> Ordering {
        // Denominators are positive, so cross-multiplication preserves order.
        (self.num * other.den).cmp(&(other.num * self.den))
    }
}

impl fmt::Display for Rat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if self.den == 1 {
            write!(f, "{}", self.num)
        } else {
            write!(f, "{}/{}", self.num, self.den)
        }
    }
}

/// The comparison of a linear constraint.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Rel {
    /// `sum <= b`.
    Le,
    /// `sum < b` (strict).
    Lt,
    /// `sum == b`, stored internally as two non-strict inequalities.
    Eq,
}

/// A linear constraint `a1*x1 + ... + an*xn <rel> b`.
///
/// Variable `i` is the coefficient `coeffs[i]`; the number of variables is
/// inferred as the largest coefficient list length. Shorter lists are padded
/// with zeros.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Constraint {
    /// Coefficients `a1..an`.
    pub coeffs: Vec<i64>,
    /// The constant bound.
    pub b: i64,
    /// The comparison.
    pub rel: Rel,
}

/// An internal constraint widened to `i128` arithmetic, with a strictness flag
/// (strictness is tracked separately so that `<` survives elimination).
#[derive(Debug, Clone)]
struct ICons {
    coeffs: Vec<i128>,
    b: i128,
    strict: bool,
}

/// Solve a conjunction of linear constraints over the reals.
///
/// Returns `Some(assignment)` when satisfiable, where `assignment[i]` is the
/// (exact rational) value of variable `i`; `None` means unsatisfiable.
pub fn solve(constraints: &[Constraint]) -> Option<Vec<Rat>> {
    let n = constraints
        .iter()
        .map(|c| c.coeffs.len())
        .max()
        .unwrap_or(0);

    // Widen the input to i128 and split equalities into two inequalities.
    let mut level: Vec<ICons> = vec![];
    for c in constraints {
        let mut coeffs: Vec<i128> = c.coeffs.iter().map(|&v| v as i128).collect();
        coeffs.resize(n, 0);
        match c.rel {
            Rel::Le => level.push(ICons {
                coeffs,
                b: c.b as i128,
                strict: false,
            }),
            Rel::Lt => level.push(ICons {
                coeffs,
                b: c.b as i128,
                strict: true,
            }),
            Rel::Eq => {
                level.push(ICons {
                    coeffs: coeffs.clone(),
                    b: c.b as i128,
                    strict: false,
                });
                level.push(ICons {
                    coeffs: coeffs.iter().map(|&v| -v).collect(),
                    b: -(c.b as i128),
                    strict: false,
                });
            }
        }
    }

    // Eliminate variable by variable, keeping every intermediate system so
    // that back-substitution can later bound each variable.
    let mut levels: Vec<Vec<ICons>> = vec![level];
    for k in 0..n {
        levels.push(eliminate(&levels[k], k));
    }

    // Only constraints 0*x1 + ... + 0*xn <= b remain: any negative b (or a
    // strict 0 < 0) is a contradiction.
    for c in &levels[n] {
        if c.b < 0 || (c.b == 0 && c.strict) {
            return None;
        }
    }

    // Back-substitution: assign variables from the last to the first, each
    // inside the bounds that its elimination level leaves for it.
    let mut values: Vec<Rat> = vec![Rat::int(0); n];
    for k in (0..n).rev() {
        let mut lower: Option<(Rat, bool)> = None;
        let mut upper: Option<(Rat, bool)> = None;
        for c in &levels[k] {
            let a = c.coeffs[k];
            let mut rest = Rat::int(0);
            for (&coeff, &value) in c.coeffs.iter().zip(&values).skip(k + 1) {
                if coeff != 0 {
                    rest = rest + Rat::int(coeff) * value;
                }
            }
            if a > 0 {
                upper = tighten_upper(upper, ((Rat::int(c.b) - rest).div_int(a), c.strict));
            } else if a < 0 {
                lower = tighten_lower(lower, ((Rat::int(c.b) - rest).div_int(a), c.strict));
            } else {
                // The constraint does not mention x_k: it must already hold.
                let slack = Rat::int(c.b) - rest;
                if slack.num < 0 || (slack.num == 0 && c.strict) {
                    return None;
                }
            }
        }
        values[k] = choose_value(lower, upper)?;
    }
    Some(values)
}

/// Fourier--Motzkin step: eliminate variable `k` from a system of `n`
/// variables, where `n` is the width of every constraint's coefficient
/// vector. Each (lower, upper) pair of bounds on `x_k` becomes one new
/// constraint on the remaining variables.
fn eliminate(cons: &[ICons], k: usize) -> Vec<ICons> {
    let mut pos: Vec<&ICons> = vec![];
    let mut neg: Vec<&ICons> = vec![];
    let mut zero: Vec<ICons> = vec![];
    for c in cons {
        if c.coeffs[k] > 0 {
            pos.push(c);
        } else if c.coeffs[k] < 0 {
            neg.push(c);
        } else {
            zero.push(c.clone());
        }
    }
    if pos.is_empty() || neg.is_empty() {
        // x_k is unbounded on one side: the projection is just the rest.
        return zero;
    }
    let mut out = zero;
    for p in &pos {
        for m in &neg {
            let ap = p.coeffs[k];
            let an = m.coeffs[k];
            // Multiply the upper-bound constraint by -an and the lower-bound
            // constraint by ap (both positive) and add them: x_k cancels.
            // Result: sum_j (ap*m_j - an*p_j) x_j <= ap*m_b - an*p_b.
            let coeffs: Vec<i128> = m
                .coeffs
                .iter()
                .zip(&p.coeffs)
                .map(|(&mc, &pc)| ap * mc - an * pc)
                .collect();
            let b = ap * m.b - an * p.b;
            let strict = p.strict || m.strict;
            out.push(ICons { coeffs, b, strict });
        }
    }
    out
}

/// Keep the tighter upper bound: smaller value, and strict beats non-strict
/// when the values tie.
fn tighten_upper(cur: Option<(Rat, bool)>, cand: (Rat, bool)) -> Option<(Rat, bool)> {
    Some(match cur {
        None => cand,
        Some((cv, cs)) => {
            if cand.0 < cv || (cand.0 == cv && cand.1 && !cs) {
                cand
            } else {
                (cv, cs)
            }
        }
    })
}

/// Keep the tighter lower bound: larger value, and strict beats non-strict
/// when the values tie.
fn tighten_lower(cur: Option<(Rat, bool)>, cand: (Rat, bool)) -> Option<(Rat, bool)> {
    Some(match cur {
        None => cand,
        Some((cv, cs)) => {
            if cand.0 > cv || (cand.0 == cv && cand.1 && !cs) {
                cand
            } else {
                (cv, cs)
            }
        }
    })
}

/// Pick a value inside the tightest bounds. A bound is `(value, strict)`.
///
/// The elimination guarantees the bounds are consistent, so `None` here can
/// only be reached through a bug; it is returned rather than panicking.
fn choose_value(lower: Option<(Rat, bool)>, upper: Option<(Rat, bool)>) -> Option<Rat> {
    match (lower, upper) {
        (Some((l, ls)), Some((u, us))) => {
            if l < u {
                Some(if ls { (l + u).div_int(2) } else { l })
            } else if l == u {
                if ls || us {
                    None
                } else {
                    Some(l)
                }
            } else {
                None
            }
        }
        (Some((l, ls)), None) => Some(if ls { l + Rat::int(1) } else { l }),
        (None, Some((u, us))) => Some(if us { u - Rat::int(1) } else { u }),
        (None, None) => Some(Rat::int(0)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn le(coeffs: Vec<i64>, b: i64) -> Constraint {
        Constraint {
            coeffs,
            b,
            rel: Rel::Le,
        }
    }

    #[test]
    fn empty_system_is_satisfiable() {
        let m = solve(&[]).unwrap();
        assert!(m.is_empty());
    }

    #[test]
    fn contradictory_constant() {
        // 0 <= -1: unsatisfiable without any variable.
        assert_eq!(solve(&[le(vec![0], -1)]), None);
    }

    #[test]
    fn satisfiable_bounded() {
        // 0 <= x <= 1 and x >= 1/2: the lower bound is chosen.
        let cs = vec![le(vec![-1], 0), le(vec![1], 1), le(vec![-2], -1)];
        let m = solve(&cs).unwrap();
        assert!(m[0] >= Rat::new(1, 2) && m[0] <= Rat::int(1) && m[0] >= Rat::int(0));
    }

    #[test]
    fn unsatisfiable_pair() {
        // x >= 1/2 and x <= 1/2 with one bound strict: impossible.
        let cs = vec![
            Constraint {
                coeffs: vec![-2],
                b: -1,
                rel: Rel::Lt,
            },
            Constraint {
                coeffs: vec![2],
                b: 1,
                rel: Rel::Le,
            },
        ];
        assert_eq!(solve(&cs), None);
    }

    #[test]
    fn strict_inequality_is_used() {
        // x < 1 with x = 1 is impossible, but x <= 1 with x = 1 is fine.
        let cs = vec![
            Constraint {
                coeffs: vec![1],
                b: 1,
                rel: Rel::Lt,
            },
            Constraint {
                coeffs: vec![-1],
                b: -1,
                rel: Rel::Le,
            },
        ];
        assert_eq!(solve(&cs), None);
        let cs = vec![
            Constraint {
                coeffs: vec![1],
                b: 1,
                rel: Rel::Le,
            },
            Constraint {
                coeffs: vec![-1],
                b: -1,
                rel: Rel::Le,
            },
        ];
        let m = solve(&cs).unwrap();
        assert_eq!(m[0], Rat::int(1));
    }

    #[test]
    fn equality_gives_exact_fraction() {
        let cs = vec![Constraint {
            coeffs: vec![3],
            b: 1,
            rel: Rel::Eq,
        }];
        let m = solve(&cs).unwrap();
        assert_eq!(m[0], Rat::new(1, 3));
    }

    #[test]
    fn two_variables_recover_both() {
        // x + y <= 1, x - y <= 0, y <= 2: x = 0, y = 0 works.
        let cs = vec![le(vec![1, 1], 1), le(vec![1, -1], 0), le(vec![0, 1], 2)];
        let m = solve(&cs).unwrap();
        assert!(m[0] + m[1] <= Rat::int(1));
        assert!(m[0] - m[1] <= Rat::int(0));
        assert!(m[1] <= Rat::int(2));
    }

    #[test]
    fn mixed_strict_and_equality() {
        // x + y = 1 with x > 0 and y > 0: many solutions; must find one.
        let cs = vec![
            Constraint {
                coeffs: vec![1, 1],
                b: 1,
                rel: Rel::Eq,
            },
            Constraint {
                coeffs: vec![-1, 0],
                b: 0,
                rel: Rel::Lt,
            },
            Constraint {
                coeffs: vec![0, -1],
                b: 0,
                rel: Rel::Lt,
            },
        ];
        let m = solve(&cs).unwrap();
        assert_eq!(m[0] + m[1], Rat::int(1));
        assert!(m[0] > Rat::int(0) && m[1] > Rat::int(0));
    }

    #[test]
    fn rat_arithmetic_is_exact() {
        let a = Rat::new(1, 3);
        let b = Rat::new(1, 6);
        assert_eq!(a + b, Rat::new(1, 2));
        assert_eq!(a * b, Rat::new(1, 18));
        assert_eq!(a - a, Rat::int(0));
        assert!(Rat::new(-1, 2) < Rat::int(0));
        assert_eq!(Rat::new(-3, 2).floor(), -2);
        assert_eq!(Rat::new(-3, 2).ceil(), -1);
    }
}
