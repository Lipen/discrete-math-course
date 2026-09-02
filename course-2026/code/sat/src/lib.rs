//! A small DPLL SAT solver.
//!
//! Implements the Davis-Putnam-Logemann-Loveland algorithm with unit propagation, pure literal elimination, and chronological backtracking.
//!
//! ```
//! use sat::cnf::{Cnf, pos, neg};
//! use sat::solve;
//!
//! // (x1 ∨ x2) ∧ (¬x1) -- x1 must be false, then x2 must be true.
//! let cnf = Cnf::new(2, vec![
//!     vec![pos(1), pos(2)],
//!     vec![neg(1)],
//! ]).unwrap();
//!
//! let model = solve(&cnf).unwrap();
//! assert!(!model[0]); // x1 = false
//! assert!(model[1]);  // x2 = true
//! ```

pub mod cnf;
pub mod dpll;

pub use cnf::{Clause, Cnf, Lit};
pub use dpll::{solve, solve_traced};

#[cfg(test)]
mod tests {
    use crate::cnf::*;
    use crate::dpll::*;

    // ── Literal helpers ──────────────────────────────────────────────

    #[test]
    fn literal_helpers() {
        assert_eq!(pos(3), 3);
        assert_eq!(neg(3), -3);
        assert_eq!(var_of(5), 5);
        assert_eq!(var_of(-5), 5);
        assert!(is_pos(pos(1)));
        assert!(!is_pos(neg(1)));
        assert_eq!(lit_idx(pos(1)), 0);
        assert_eq!(lit_idx(pos(3)), 2);
        assert_eq!(lit_idx(neg(3)), 2);
    }

    // ── Clause helpers ───────────────────────────────────────────────

    #[test]
    fn clause_satisfied_basic() {
        let c = vec![pos(1), neg(2)];
        // x1 = true -> satisfied regardless of x2.
        assert!(clause_satisfied(&c, &[Some(true), None]));
        // x1 = false, x2 = false -> ¬x2 = true -> satisfied.
        assert!(clause_satisfied(&c, &[Some(false), Some(false)]));
        // Both false -> not satisfied.
        assert!(!clause_satisfied(&c, &[Some(false), Some(true)]));
    }

    #[test]
    fn unit_of_detects_unit() {
        // x1 ∨ ¬x2 with x2 = true -> ¬x2 false -> x1 forced.
        let c = vec![pos(1), neg(2)];
        assert_eq!(unit_of(&c, &[None, Some(true)]), Some(pos(1)));
        // x1 = false, x2 unassigned -> ¬x2 forced.
        assert_eq!(unit_of(&c, &[Some(false), None]), Some(neg(2)));
        // Already satisfied -> not a unit.
        assert_eq!(unit_of(&c, &[Some(true), None]), None);
        // Both false -> no unassigned literal to force.
        assert_eq!(unit_of(&c, &[Some(false), Some(true)]), None);
    }

    #[test]
    fn clause_has_unassigned_basic() {
        let c = vec![pos(1), neg(2)];
        assert!(clause_has_unassigned(&c, &[None, Some(true)]));
        assert!(clause_has_unassigned(&c, &[Some(false), None]));
        assert!(!clause_has_unassigned(&c, &[Some(false), Some(true)]));
    }

    // ── Cnf construction ─────────────────────────────────────────────

    #[test]
    fn cnf_new_rejects_zero_literal() {
        assert!(Cnf::new(3, vec![vec![0, 1]]).is_none());
    }

    #[test]
    fn cnf_new_rejects_out_of_range() {
        assert!(Cnf::new(2, vec![vec![1, 3]]).is_none());
        assert!(Cnf::new(2, vec![vec![-3]]).is_none());
    }

    #[test]
    fn cnf_new_accepts_valid_formula() {
        let cnf = Cnf::new(3, vec![vec![1, -2], vec![3]]).unwrap();
        assert_eq!(cnf.num_vars, 3);
        assert_eq!(cnf.clauses.len(), 2);
    }

    #[test]
    fn random_3sat_properties() {
        let cnf = Cnf::random_3sat(5, 7, 12345);
        assert_eq!(cnf.num_vars, 5);
        assert_eq!(cnf.clauses.len(), 7);
        for clause in &cnf.clauses {
            assert_eq!(clause.len(), 3, "every clause must have exactly 3 literals");
            for &l in clause {
                assert!(var_of(l) >= 1 && var_of(l) <= 5, "literal out of range");
            }
        }
    }

    // ── DPLL: satisfiable cases ──────────────────────────────────────

    #[test]
    fn solve_empty_formula() {
        let cnf = Cnf::new(0, vec![]).unwrap();
        assert!(solve(&cnf).is_some());
    }

    #[test]
    fn solve_empty_clauses_trivially_sat() {
        let cnf = Cnf::new(3, vec![]).unwrap();
        let model = solve(&cnf).unwrap();
        assert_eq!(model.len(), 3);
    }

    #[test]
    fn solve_single_unit_clause() {
        // (x1) -- x1 must be true.
        let cnf = Cnf::new(1, vec![vec![pos(1)]]).unwrap();
        let model = solve(&cnf).unwrap();
        assert!(model[0]);
    }

    #[test]
    fn solve_unit_propagation_chain() {
        // (¬x1) ∧ (x1 ∨ x2) -- x1 must be false, then x2 must be true.
        let cnf = Cnf::new(2, vec![vec![neg(1)], vec![pos(1), pos(2)]]).unwrap();
        let model = solve(&cnf).unwrap();
        assert!(!model[0]);
        assert!(model[1]);
    }

    #[test]
    fn solve_tautological_clause_ignored() {
        // (x1 ∨ ¬x1) -- always satisfiable, tautology does not confuse.
        let cnf = Cnf::new(1, vec![vec![pos(1), neg(1)]]).unwrap();
        assert!(solve(&cnf).is_some());
    }

    #[test]
    fn solve_pure_literal_positive() {
        // (x1 ∨ x2) ∧ (x1 ∨ ¬x3) -- x1 appears only positively -> set to true.
        let cnf = Cnf::new(3, vec![vec![pos(1), pos(2)], vec![pos(1), neg(3)]]).unwrap();
        let model = solve(&cnf).unwrap();
        assert!(model[0]); // x1 = true (pure positive)
    }

    #[test]
    fn solve_model_satisfies_every_clause() {
        let cnf = Cnf::new(
            3,
            vec![
                vec![pos(1), pos(2)],
                vec![neg(1), pos(2)],
                vec![pos(2), neg(3)],
            ],
        )
        .unwrap();
        let model = solve(&cnf).unwrap();
        for clause in &cnf.clauses {
            assert!(
                clause.iter().any(|&l| {
                    let idx = lit_idx(l);
                    model[idx] == is_pos(l)
                }),
                "model {model:?} does not satisfy clause {clause:?}"
            );
        }
    }

    // ── DPLL: unsatisfiable cases ────────────────────────────────────

    #[test]
    fn solve_immediate_conflict() {
        // (x1) ∧ (¬x1) -- immediate conflict.
        let cnf = Cnf::new(1, vec![vec![pos(1)], vec![neg(1)]]).unwrap();
        assert_eq!(solve(&cnf), None);
    }

    #[test]
    fn solve_unsat_formula() {
        // F = (x1∨x2∨x3) ∧ (¬x1∨x2) ∧ (x2∨¬x3) ∧ (¬x2∨x3) ∧ (¬x2∨¬x3).
        let cnf = Cnf::new(
            3,
            vec![
                vec![pos(1), pos(2), pos(3)],
                vec![neg(1), pos(2)],
                vec![pos(2), neg(3)],
                vec![neg(2), pos(3)],
                vec![neg(2), neg(3)],
            ],
        )
        .unwrap();
        assert_eq!(solve(&cnf), None);
    }

    #[test]
    fn solve_pigeonhole_2_1_is_unsat() {
        // PHP(2,1): 2 pigeons, 1 hole -- UNSAT.
        // Variables: p11, p21 (x1, x2).
        // Clauses: (x1), (x2), (¬x1 ∨ ¬x2).
        let cnf = Cnf::new(2, vec![vec![pos(1)], vec![pos(2)], vec![neg(1), neg(2)]]).unwrap();
        assert_eq!(solve(&cnf), None);
    }

    #[test]
    fn solve_php_3_2_is_unsat() {
        // PHP(3,2): 3 pigeons, 2 holes.
        // Variables: p11, p12, p21, p22, p31, p32 (x1..x6).
        let cnf = php_cnf(3, 2);
        assert_eq!(solve(&cnf), None);
    }

    // ── Randomised comparison with brute force ───────────────────────

    /// `solve` must agree with exhaustive search on random small formulas.
    #[test]
    fn solve_matches_brute_force_on_random_formulas() {
        fn brute_force(nvars: usize, clauses: &[Clause]) -> bool {
            (0..(1u32 << nvars)).any(|mask| {
                clauses.iter().all(|clause| {
                    clause.iter().any(|&l| {
                        let v = lit_idx(l);
                        ((mask >> v) & 1) == is_pos(l) as u32
                    })
                })
            })
        }

        let mut rng = XorShift64::new(0x9E37_79B9_7F4A_7C15);
        for nvars in 1..=4usize {
            for _ in 0..200 {
                let mut clauses = Vec::new();
                for _ in 0..rng.below(3 * nvars + 1) {
                    let clause: Clause = (0..rng.below(4))
                        .map(|_| {
                            let v = (rng.below(nvars) + 1) as i32;
                            if rng.below(2) == 0 {
                                pos(v as usize)
                            } else {
                                neg(v as usize)
                            }
                        })
                        .collect();
                    clauses.push(clause);
                }
                let cnf = Cnf::new(nvars, clauses.clone()).unwrap();
                let model = solve(&cnf);
                match model {
                    Some(m) => {
                        assert!(
                            brute_force(nvars, &clauses),
                            "solve found a model for an unsat formula: {clauses:?}"
                        );
                        for clause in &clauses {
                            assert!(
                                clause.iter().any(|&l| {
                                    let idx = lit_idx(l);
                                    m[idx] == is_pos(l)
                                }),
                                "model {m:?} does not satisfy {clause:?} in {clauses:?}"
                            );
                        }
                    }
                    None => assert!(
                        !brute_force(nvars, &clauses),
                        "solve says unsat but {clauses:?} is satisfiable (nvars {nvars})"
                    ),
                }
            }
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────

    /// Build the pigeonhole principle PHP(n, n-1): n pigeons, n-1 holes.
    ///
    /// Variable index: pigeon i in hole j -> variable (i-1)*(n-1) + j.
    fn php_cnf(n: usize, holes: usize) -> Cnf {
        let nvars = n * holes;
        let mut clauses = Vec::new();

        // Each pigeon occupies at least one hole.
        for i in 0..n {
            let mut clause = Vec::new();
            for j in 0..holes {
                clause.push(pos(i * holes + j + 1));
            }
            clauses.push(clause);
        }

        // No two pigeons share the same hole.
        for i1 in 0..n {
            for i2 in (i1 + 1)..n {
                for j in 0..holes {
                    let v1 = i1 * holes + j + 1;
                    let v2 = i2 * holes + j + 1;
                    clauses.push(vec![neg(v1), neg(v2)]);
                }
            }
        }

        Cnf::new(nvars, clauses).unwrap()
    }
}
