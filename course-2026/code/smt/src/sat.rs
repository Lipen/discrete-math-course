//! A small self-contained SAT solver (DPLL).
//!
//! The solver takes a set of clauses -- disjunctions of boolean literals --
//! and decides satisfiability by the DPLL procedure: decide an unassigned
//! variable, assign everything forced by the clauses (unit propagation),
//! and on a conflict flip the last decision (backtracking). No clause
//! learning is used: this is the plain Davis--Putnam--Logemann--Loveland
//! skeleton that the DPLL(T) driver of this crate builds on, and the engine
//! that the bitvector solver calls after bit-blasting.
//!
//! Variables are numbered from 1; a literal is a signed variable index:
//! `v > 0` means "variable `v` is true", `v < 0` means "variable `-v` is
//! false". A clause is a list of literals joined by OR, and a set of clauses
//! is joined by AND. The model returned by [`solve`] is indexed from 0:
//! `model[i]` is the value of variable `i + 1`.
//!
//! ```
//! use smt::sat::{solve, Clause};
//!
//! // (x1 OR x2) AND (NOT x1 OR x3) AND (NOT x3) forces x2 to be true.
//! let clauses: Vec<Clause> = vec![
//!     vec![1, 2],
//!     vec![-1, 3],
//!     vec![-3],
//! ];
//! let model = solve(3, &clauses).unwrap();
//! assert_eq!(model[0], false); // x1
//! assert_eq!(model[1], true);  // x2
//! assert_eq!(model[2], false); // x3
//! ```

/// A literal: a signed variable index (`v > 0` true, `v < 0` false).
pub type Literal = i32;

/// A clause: a list of literals joined by OR.
pub type Clause = Vec<Literal>;

/// One entry of the assignment trail: a variable, its value, and whether the
/// value was chosen by a decision (as opposed to forced by propagation).
#[derive(Debug, Clone, Copy)]
struct TrailEntry {
    var: usize,
    val: bool,
    decision: bool,
    /// True once this decision was already flipped: both values failed.
    flipped: bool,
}

/// An incremental SAT solver: add clauses, then ask for a model.
///
/// A [`Solver`] may be solved repeatedly; each call to [`Solver::solve`]
/// restarts the search from scratch over the accumulated clauses, which is
/// exactly what the DPLL(T) driver needs after learning a conflict clause.
pub struct Solver {
    num_vars: usize,
    clauses: Vec<Clause>,
    assign: Vec<Option<bool>>,
    trail: Vec<TrailEntry>,
}

impl Solver {
    /// Create a solver for `num_vars` variables (numbered 1..=num_vars).
    pub fn new(num_vars: usize) -> Solver {
        Solver {
            num_vars,
            clauses: vec![],
            assign: vec![None; num_vars],
            trail: vec![],
        }
    }

    /// Add a clause to the formula.
    pub fn add_clause(&mut self, clause: &[Literal]) {
        self.clauses.push(clause.to_vec());
    }

    /// Decide satisfiability and return a model, or `None` if unsatisfiable.
    ///
    /// The model is a vector over variables indexed from 0; every variable
    /// gets a value (unassigned variables default to `false`).
    pub fn solve(&mut self) -> Option<Vec<bool>> {
        self.assign = vec![None; self.num_vars];
        self.trail = vec![];
        loop {
            if self.propagate().is_err() {
                if !self.backtrack() {
                    return None;
                }
                continue;
            }
            if self.trail.len() == self.num_vars {
                break; // every variable is assigned and no clause is violated
            }
            let v = (0..self.num_vars)
                .find(|&v| self.assign[v].is_none())
                .expect("fewer trail entries than assigned variables");
            self.assign[v] = Some(true);
            self.trail.push(TrailEntry {
                var: v,
                val: true,
                decision: true,
                flipped: false,
            });
        }
        Some(
            (0..self.num_vars)
                .map(|v| self.assign[v].unwrap_or(false))
                .collect(),
        )
    }

    /// Unit propagation: repeatedly assign every variable forced by a clause
    /// that has one unassigned literal left. Returns `Err` on a conflict
    /// (a clause whose literals are all false).
    fn propagate(&mut self) -> Result<(), ()> {
        loop {
            let mut changed = false;
            'clauses: for clause in &self.clauses {
                let mut unassigned = 0;
                let mut last: Option<(usize, bool)> = None;
                for &lit in clause {
                    let v = lit.unsigned_abs() as usize - 1;
                    let want = lit > 0;
                    match self.assign[v] {
                        Some(actual) if actual == want => continue 'clauses, // satisfied
                        Some(_) => {}
                        None => {
                            unassigned += 1;
                            last = Some((v, want));
                        }
                    }
                }
                if unassigned == 0 {
                    return Err(()); // every literal is false: conflict
                }
                if unassigned == 1 {
                    let (v, want) = last.expect("one unassigned literal");
                    self.assign[v] = Some(want);
                    self.trail.push(TrailEntry {
                        var: v,
                        val: want,
                        decision: false,
                        flipped: false,
                    });
                    changed = true;
                }
            }
            if !changed {
                return Ok(());
            }
        }
    }

    /// Undo the last decision: pop the trail past it and flip it. A decision
    /// that has already been flipped is popped past as well (both values
    /// failed under the assignments that led here). Returns `false` when no
    /// decision is left to flip, meaning the formula is unsatisfiable.
    fn backtrack(&mut self) -> bool {
        while let Some(entry) = self.trail.pop() {
            self.assign[entry.var] = None;
            if entry.decision {
                if entry.flipped {
                    continue;
                }
                self.assign[entry.var] = Some(!entry.val);
                self.trail.push(TrailEntry {
                    var: entry.var,
                    val: !entry.val,
                    decision: true,
                    flipped: true,
                });
                return true;
            }
        }
        false
    }
}

/// Decide a set of clauses in one call: `None` means unsatisfiable.
pub fn solve(num_vars: usize, clauses: &[Clause]) -> Option<Vec<bool>> {
    let mut solver = Solver::new(num_vars);
    for clause in clauses {
        solver.add_clause(clause);
    }
    solver.solve()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn trivially_satisfiable() {
        // (x1 OR x2) AND (NOT x2): x1 must be true.
        let model = solve(2, &[vec![1, 2], vec![-2]]).unwrap();
        assert_eq!(model, vec![true, false]);
    }

    #[test]
    fn trivially_unsatisfiable() {
        // x1 AND NOT x1.
        assert_eq!(solve(1, &[vec![1], vec![-1]]), None);
    }

    #[test]
    fn empty_clause_is_a_conflict() {
        assert_eq!(solve(2, &[vec![1], vec![]]), None);
    }

    #[test]
    fn backtracking_required() {
        // The 2-SAT formula (x1 OR x2) AND (NOT x1 OR x2) AND (x1 OR NOT x2)
        // AND (NOT x1 OR NOT x2) is unsatisfiable, but unit propagation alone
        // cannot see it: a decision is needed, and both values fail.
        let clauses = vec![vec![1, 2], vec![-1, 2], vec![1, -2], vec![-1, -2]];
        assert_eq!(solve(2, &clauses), None);
    }

    #[test]
    fn decision_is_flipped() {
        // (x1 OR x2) AND (NOT x1 OR x3) AND (x2 OR NOT x3) AND (NOT x1 OR
        // NOT x2) AND (x1 OR NOT x3). Deciding x1 = true propagates x3 = true
        // and x2 = true, which conflicts with (NOT x1 OR NOT x2); the
        // decision must be flipped to x1 = false, and x = (false, true,
        // false) is the model.
        let clauses = vec![
            vec![1, 2],
            vec![-1, 3],
            vec![2, -3],
            vec![-1, -2],
            vec![1, -3],
        ];
        let model = solve(3, &clauses).unwrap();
        assert_eq!(model, vec![false, true, false]);
    }

    #[test]
    fn brute_force_against_exhaustive_search() {
        // Every 2-var and 3-var formula from a fixed clause pool must agree
        // with exhaustive truth-table search.
        let pools: &[&[Vec<i32>]] = &[
            &[vec![1, 2], vec![-1, 2], vec![1, -2], vec![-1, -2]],
            &[
                vec![1, 2, 3],
                vec![-1, 2, 3],
                vec![1, -2, 3],
                vec![1, 2, -3],
                vec![-1, -2, 3],
                vec![-1, 2, -3],
                vec![1, -2, -3],
                vec![-1, -2, -3],
                vec![1, 2],
                vec![-1, 3],
                vec![-2, 3],
            ],
        ];
        for (n, pool) in pools.iter().enumerate() {
            let n = n + 2;
            for mask in 0u64..(1u64 << pool.len()) {
                let clauses: Vec<Vec<i32>> = pool
                    .iter()
                    .enumerate()
                    .filter(|&(i, _)| (mask >> i) & 1 == 1)
                    .map(|(_, c)| c.clone())
                    .collect();
                let got = solve(n, &clauses);
                let expected = (0u64..(1u64 << n)).find(|&m| {
                    clauses.iter().all(|c| {
                        c.iter().any(|&l| {
                            let v = l.unsigned_abs() as usize - 1;
                            ((m >> v) & 1 == 1) == (l > 0)
                        })
                    })
                });
                let got_ok = got.as_ref().map(|g| {
                    clauses.iter().all(|c| {
                        c.iter().any(|&l| {
                            let v = l.unsigned_abs() as usize - 1;
                            g[v] == (l > 0)
                        })
                    })
                });
                assert!(
                    got_ok.unwrap_or(true),
                    "invalid model for clauses {clauses:?}"
                );
                assert_eq!(
                    got.is_some(),
                    expected.is_some(),
                    "mismatch for clauses {clauses:?}"
                );
            }
        }
    }

    #[test]
    fn incremental_solver_reuses_clauses() {
        let mut solver = Solver::new(2);
        solver.add_clause(&[1, 2]);
        // The solver decides x1 = true, so x = (true, true) satisfies
        // (x1 OR x2); the point is that a model is returned.
        assert_eq!(solver.solve().unwrap(), vec![true, true]);
        solver.add_clause(&[-1]);
        solver.add_clause(&[-2]);
        assert_eq!(solver.solve(), None);
    }
}
