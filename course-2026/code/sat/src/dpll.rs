//! DPLL: Davis-Putnam-Logemann-Loveland SAT solver.
//!
//! Implements unit propagation, pure literal elimination, and chronological backtracking -- exactly the DPLL algorithm.
//!
//! ```
//! use sat::cnf::{Cnf, pos, neg};
//! use sat::dpll::solve;
//!
//! // (x1 ∨ x2) ∧ (¬x1) -- x1 must be false (unit clause), then x2 must be true.
//! let cnf = Cnf::new(2, vec![
//!     vec![pos(1), pos(2)],
//!     vec![neg(1)],
//! ]).unwrap();
//!
//! let model = solve(&cnf).unwrap();
//! assert!(!model[0]); // x1 = false
//! assert!(model[1]);  // x2 = true
//! ```

use crate::cnf::*;

/// Solve the CNF formula and return a satisfying assignment, or `None` if UNSAT.
///
/// The returned vector maps each variable (0-indexed) to `true` or `false`.
///
/// ```
/// use sat::cnf::{Cnf, pos, neg};
/// use sat::dpll::solve;
///
/// // (x1 ∨ x2) ∧ (¬x2) -- x2 must be false (unit clause), x1 must be true.
/// let cnf = Cnf::new(2, vec![
///     vec![pos(1), pos(2)],
///     vec![neg(2)],
/// ]).unwrap();
///
/// let model = solve(&cnf).unwrap();
/// assert!(model[0]);  // x1 = true
/// assert!(!model[1]); // x2 = false
/// ```
pub fn solve(cnf: &Cnf) -> Option<Vec<bool>> {
    let mut assign = vec![None; cnf.num_vars];
    dpll(cnf, &mut assign)
}

/// Solve with step-by-step trace printed to stdout. Useful for demos.
///
/// ```no_run
/// use sat::cnf::{Cnf, pos, neg};
/// use sat::dpll::solve_traced;
///
/// let cnf = Cnf::new(2, vec![
///     vec![pos(1), pos(2)],
///     vec![neg(1)],
/// ]).unwrap();
///
/// let model = solve_traced(&cnf);
/// assert!(model.is_some());
/// ```
pub fn solve_traced(cnf: &Cnf) -> Option<Vec<bool>> {
    println!(
        "DPLL: {} variables, {} clauses",
        cnf.num_vars,
        cnf.clauses.len()
    );
    println!("F = {}\n", format_cnf(cnf));

    let mut assign = vec![None; cnf.num_vars];
    let result = dpll_traced(cnf, &mut assign, 0);

    match &result {
        Some(model) => {
            println!("\nSAT: model found");
            for (i, &val) in model.iter().enumerate() {
                println!("  x{} = {}", i + 1, val);
            }
        }
        None => println!("\nUNSAT: no satisfying assignment exists"),
    }
    result
}

// ── Core DPLL (clean) ────────────────────────────────────────────────────

fn dpll(cnf: &Cnf, assign: &mut Vec<Option<bool>>) -> Option<Vec<bool>> {
    // Unit propagation + pure literal elimination to fixed point.
    propagate_all(cnf, assign)?;

    // All clauses satisfied?
    if cnf.clauses.iter().all(|c| clause_satisfied(c, assign)) {
        return Some(assign.iter().map(|x| x.unwrap_or(false)).collect());
    }

    // Decide: pick the first unassigned variable.
    let v = (0..cnf.num_vars).find(|&i| assign[i].is_none())?;

    let saved = assign.clone();
    for val in [true, false] {
        *assign = saved.clone();
        assign[v] = Some(val);
        if let Some(m) = dpll(cnf, assign) {
            return Some(m);
        }
    }
    None
}

// ── Core DPLL (traced) ───────────────────────────────────────────────────

fn dpll_traced(cnf: &Cnf, assign: &mut Vec<Option<bool>>, depth: usize) -> Option<Vec<bool>> {
    let indent = "  ".repeat(depth);

    // Unit propagation + pure literal elimination to fixed point.
    propagate_all_traced(cnf, assign, depth)?;

    // All clauses satisfied?
    if cnf.clauses.iter().all(|c| clause_satisfied(c, assign)) {
        return Some(assign.iter().map(|x| x.unwrap_or(false)).collect());
    }

    // Decide: pick the first unassigned variable.
    let v = (0..cnf.num_vars).find(|&i| assign[i].is_none())?;
    println!("{}decide: x{}", indent, v + 1);

    let saved = assign.clone();
    for val in [true, false] {
        *assign = saved.clone();
        assign[v] = Some(val);
        println!("{}  try x{} = {}", indent, v + 1, val);

        if let Some(m) = dpll_traced(cnf, assign, depth + 1) {
            return Some(m);
        }
        println!("{}  backtrack on x{} = {}", indent, v + 1, val);
    }
    None
}

// ── Propagation ──────────────────────────────────────────────────────────

/// Run unit propagation and pure literal elimination to a fixed point.
/// Returns `None` on conflict.
fn propagate_all(cnf: &Cnf, assign: &mut [Option<bool>]) -> Option<()> {
    loop {
        let mut changed = false;

        // Unit propagation pass.
        for clause in &cnf.clauses {
            if clause_satisfied(clause, assign) {
                continue;
            }
            if let Some(l) = unit_of(clause, assign) {
                assign[lit_idx(l)] = Some(is_pos(l));
                changed = true;
            } else if !clause_has_unassigned(clause, assign) {
                return None; // conflict: every literal is false
            }
        }

        // Pure literal elimination pass.
        if pure_literal_eliminate(cnf, assign) {
            changed = true;
        }

        if !changed {
            break;
        }
    }
    Some(())
}

/// Traced version of [propagate_all].
fn propagate_all_traced(cnf: &Cnf, assign: &mut [Option<bool>], depth: usize) -> Option<()> {
    let indent = "  ".repeat(depth);
    loop {
        let mut changed = false;

        // Unit propagation pass.
        for clause in &cnf.clauses {
            if clause_satisfied(clause, assign) {
                continue;
            }
            if let Some(l) = unit_of(clause, assign) {
                let idx = lit_idx(l);
                if assign[idx].is_none() {
                    assign[idx] = Some(is_pos(l));
                    println!(
                        "{}unit: {} forced by clause ({})",
                        indent,
                        format_lit(l),
                        format_clause(clause)
                    );
                    changed = true;
                }
            } else if !clause_has_unassigned(clause, assign) {
                println!(
                    "{}conflict: clause ({}) is false under current assignment",
                    indent,
                    format_clause(clause)
                );
                return None;
            }
        }

        // Pure literal elimination pass.
        if pure_literal_eliminate_traced(cnf, assign, depth) {
            changed = true;
        }

        if !changed {
            break;
        }
    }
    Some(())
}

// ── Pure literal elimination ─────────────────────────────────────────────

/// Eliminate pure literals: if a variable appears only in one polarity across all unsatisfied clauses, set it to the satisfying value.
///
/// Returns `true` if any variable was assigned.
fn pure_literal_eliminate(cnf: &Cnf, assign: &mut [Option<bool>]) -> bool {
    let mut pos_seen = vec![false; cnf.num_vars];
    let mut neg_seen = vec![false; cnf.num_vars];

    for clause in &cnf.clauses {
        if clause_satisfied(clause, assign) {
            continue;
        }
        for &l in clause {
            if assign[lit_idx(l)].is_none() {
                if is_pos(l) {
                    pos_seen[lit_idx(l)] = true;
                } else {
                    neg_seen[lit_idx(l)] = true;
                }
            }
        }
    }

    let mut changed = false;
    for i in 0..cnf.num_vars {
        if assign[i].is_none() {
            if pos_seen[i] && !neg_seen[i] {
                assign[i] = Some(true);
                changed = true;
            } else if !pos_seen[i] && neg_seen[i] {
                assign[i] = Some(false);
                changed = true;
            }
        }
    }
    changed
}

/// Traced version of [pure_literal_eliminate].
fn pure_literal_eliminate_traced(cnf: &Cnf, assign: &mut [Option<bool>], depth: usize) -> bool {
    let indent = "  ".repeat(depth);
    let mut pos_seen = vec![false; cnf.num_vars];
    let mut neg_seen = vec![false; cnf.num_vars];

    for clause in &cnf.clauses {
        if clause_satisfied(clause, assign) {
            continue;
        }
        for &l in clause {
            if assign[lit_idx(l)].is_none() {
                if is_pos(l) {
                    pos_seen[lit_idx(l)] = true;
                } else {
                    neg_seen[lit_idx(l)] = true;
                }
            }
        }
    }

    let mut changed = false;
    for i in 0..cnf.num_vars {
        if assign[i].is_none() {
            if pos_seen[i] && !neg_seen[i] {
                assign[i] = Some(true);
                println!(
                    "{}pure: x{} appears only positively, set to true",
                    indent,
                    i + 1
                );
                changed = true;
            } else if !pos_seen[i] && neg_seen[i] {
                assign[i] = Some(false);
                println!(
                    "{}pure: x{} appears only negatively, set to false",
                    indent,
                    i + 1
                );
                changed = true;
            }
        }
    }
    changed
}
