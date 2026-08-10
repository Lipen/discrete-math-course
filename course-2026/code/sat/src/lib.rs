//! A small DPLL SAT solver.
//!
//! Literals are integers: a positive `v` means "variable `v` is true", a
//! negative `-v` means "variable `v` is false". Variables are numbered from 1.
//! A formula is a list of clauses, each clause a disjunction of literals.
//! `solve` returns a satisfying assignment, or `None` when the formula is
//! unsatisfiable. The solver uses unit propagation and chronological
//! backtracking --- exactly the DPLL from the book chapter.

/// A literal: positive means the variable is true, negative means false.
pub type Lit = i32;

/// A clause is a disjunction of literals.
pub type Clause = Vec<Lit>;

/// Whether the clause is satisfied by the current assignment.
fn satisfied(clause: &Clause, assign: &[Option<bool>]) -> bool {
    clause.iter().any(|&l| {
        let v = l.unsigned_abs() as usize - 1;
        assign[v] == Some(l > 0)
    })
}

/// The single literal that would satisfy a unit clause, if any.
///
/// A clause is unit when exactly one of its literals is still unassigned and
/// the rest are false; then that literal is forced to true.
fn unit(clause: &Clause, assign: &[Option<bool>]) -> Option<Lit> {
    let mut forced = None;
    let mut unassigned = 0;
    for &l in clause {
        let v = l.unsigned_abs() as usize - 1;
        match assign[v] {
            Some(val) if val == (l > 0) => return None, // satisfied already
            Some(_) => {}                               // a false literal
            None => {
                unassigned += 1;
                forced = Some(l);
            }
        }
    }
    if unassigned == 1 {
        forced
    } else {
        None
    }
}

/// Whether the clause has at least one unassigned literal (not yet decided).
fn has_way_out(clause: &Clause, assign: &[Option<bool>]) -> bool {
    clause.iter().any(|&l| {
        let v = l.unsigned_abs() as usize - 1;
        assign[v].is_none()
    })
}

/// A satisfying assignment, or `None` when the formula is unsatisfiable.
///
/// The result maps each variable to `true` or `false`.
pub fn solve(nvars: usize, clauses: &[Clause]) -> Option<Vec<bool>> {
    // Reject out-of-range literals (0 or > nvars) up front instead of panicking.
    for clause in clauses {
        for &l in clause {
            let v = l.unsigned_abs() as usize;
            if v == 0 || v > nvars {
                return None;
            }
        }
    }
    let mut assign = vec![None; nvars];
    dpll(nvars, clauses, &mut assign).map(|a| a.into_iter().map(|x| x.unwrap_or(false)).collect())
}

/// Recursive DPLL with unit propagation and chronological backtracking.
fn dpll(
    nvars: usize,
    clauses: &[Clause],
    assign: &mut Vec<Option<bool>>,
) -> Option<Vec<Option<bool>>> {
    // Unit propagation: apply forced literals until a fixed point.
    loop {
        let mut changed = false;
        for clause in clauses {
            if satisfied(clause, assign) {
                continue;
            }
            if let Some(l) = unit(clause, assign) {
                let v = l.unsigned_abs() as usize - 1;
                assign[v] = Some(l > 0);
                changed = true;
            } else if !has_way_out(clause, assign) {
                return None; // every literal is false: conflict
            }
        }
        if !changed {
            break;
        }
    }

    // All clauses satisfied: found a model.
    if clauses.iter().all(|c| satisfied(c, assign)) {
        return Some(assign.clone());
    }

    // Decide an unassigned variable and try both values.
    let v = (0..nvars).find(|&i| assign[i].is_none())?;
    // Unit propagation from a failed branch must not leak into the next one,
    // so each branch starts from the same saved assignment.
    let saved = assign.clone();
    for val in [true, false] {
        *assign = saved.clone();
        assign[v] = Some(val);
        if let Some(m) = dpll(nvars, clauses, assign) {
            return Some(m);
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn simple_formula_is_sat() {
        // (x1 ∨ x2) ∧ (¬x1 ∨ x2) ∧ (x2 ∨ ¬x3) --- x2 must be true.
        let clauses = vec![vec![1, 2], vec![-1, 2], vec![2, -3]];
        let model = solve(3, &clauses).expect("satisfiable");
        assert!(model[1]); // x2 is forced true
    }

    #[test]
    fn formula_from_book_chapter_is_unsat() {
        // F = (x1∨x2∨x3) ∧ (¬x1∨x2) ∧ (x2∨¬x3) ∧ (¬x2∨x3) ∧ (¬x2∨¬x3).
        let clauses = vec![
            vec![1, 2, 3],
            vec![-1, 2],
            vec![2, -3],
            vec![-2, 3],
            vec![-2, -3],
        ];
        assert_eq!(solve(3, &clauses), None);
    }

    #[test]
    fn model_satisfies_every_clause() {
        // (x1 ∨ x2) ∧ (¬x1 ∨ x2) ∧ (x2 ∨ ¬x3): x2 is forced true.
        let clauses = vec![vec![1, 2], vec![-1, 2], vec![2, -3]];
        let model = solve(3, &clauses).expect("satisfiable");
        assert!(model[1]); // x2 is forced by C1 and C2 whatever x1 is
        for clause in &clauses {
            assert!(clause.iter().any(|&l| {
                let v = l.unsigned_abs() as usize - 1;
                model[v] == (l > 0)
            }));
        }
    }

    #[test]
    fn empty_formula_is_trivially_sat() {
        assert!(solve(0, &[]).is_some());
    }
}
