//! A tiny imperative program and abstract transfer functions.
//!
//! The analyzer runs the program on abstract values: assignments evaluate an
//! expression abstractly, `If` merges both branches with the join ⊔, and
//! `While` computes a fixpoint (with widening on the interval domain).

use std::collections::HashMap;

use crate::domains::{Interval, Sign};

/// An integer expression.
#[derive(Debug, Clone)]
pub enum Expr {
    Const(i64),
    Var(String),
    Add(Box<Expr>, Box<Expr>),
    Mul(Box<Expr>, Box<Expr>),
    Neg(Box<Expr>),
}

/// A statement. Conditions are deliberately absent: the analyzer over-approximates
/// by running every branch and merging, and by iterating a loop body to a fixpoint.
#[derive(Debug, Clone)]
pub enum Stmt {
    Assign(String, Expr),
    If { then: Vec<Stmt>, els: Vec<Stmt> },
    While { body: Vec<Stmt> },
}

/// An abstract state: a value per variable.
pub type State<D> = HashMap<String, D>;

/// Evaluates an expression in the sign domain.
pub fn eval_sign(e: &Expr, st: &State<Sign>) -> Sign {
    match e {
        Expr::Const(n) => Sign::of(*n),
        Expr::Var(v) => st.get(v).copied().unwrap_or(Sign::Top),
        Expr::Add(a, b) => eval_sign(a, st) + eval_sign(b, st),
        Expr::Mul(a, b) => eval_sign(a, st) * eval_sign(b, st),
        Expr::Neg(a) => -eval_sign(a, st),
    }
}

/// Runs a list of statements in the sign domain, updating `st` in place.
pub fn exec_sign(stmts: &[Stmt], st: &mut State<Sign>) {
    for s in stmts {
        match s {
            Stmt::Assign(v, e) => {
                st.insert(v.clone(), eval_sign(e, st));
            }
            Stmt::If { then, els } => {
                let mut then_state = st.clone();
                let mut else_state = st.clone();
                exec_sign(then, &mut then_state);
                exec_sign(els, &mut else_state);
                *st = merge(then_state, else_state, Sign::Bottom, Sign::lub);
            }
            Stmt::While { body } => {
                // Plain iteration from a non-⊥ state on a finite non-chain lattice can
                // oscillate between incomparable states (e.g. `i := -i`); bound the
                // passes and over-approximate to ⊤ on timeout.
                let mut converged = false;
                for _ in 0..64 {
                    let before = st.clone();
                    exec_sign(body, st);
                    if *st == before {
                        converged = true;
                        break;
                    }
                }
                if !converged {
                    for v in st.values_mut() {
                        *v = Sign::Top;
                    }
                }
            }
        }
    }
}

/// Evaluates an expression in the interval domain.
pub fn eval_interval(e: &Expr, st: &State<Interval>) -> Interval {
    match e {
        Expr::Const(n) => Interval::point(*n),
        Expr::Var(v) => st.get(v).copied().unwrap_or(Interval::top()),
        Expr::Add(a, b) => eval_interval(a, st) + eval_interval(b, st),
        Expr::Mul(a, b) => eval_interval(a, st) * eval_interval(b, st),
        Expr::Neg(a) => -eval_interval(a, st),
    }
}

/// Runs a list of statements in the interval domain, updating `st` in place.
///
/// Loop bodies are iterated with widening: after each pass every variable is
/// widened against its loop-head value, forcing the iteration to converge.
pub fn exec_interval(stmts: &[Stmt], st: &mut State<Interval>) {
    for s in stmts {
        match s {
            Stmt::Assign(v, e) => {
                st.insert(v.clone(), eval_interval(e, st));
            }
            Stmt::If { then, els } => {
                let mut then_state = st.clone();
                let mut else_state = st.clone();
                exec_interval(then, &mut then_state);
                exec_interval(els, &mut else_state);
                *st = merge(then_state, else_state, Interval::Bottom, Interval::lub);
            }
            Stmt::While { body } => loop {
                let before = st.clone();
                exec_interval(body, st);
                let updates: Vec<(String, Interval)> =
                    st.iter().map(|(v, a)| (v.clone(), *a)).collect();
                for (var, after) in updates {
                    let old = before.get(&var).copied().unwrap_or(Interval::top());
                    st.insert(var, old.widen(after));
                }
                if *st == before {
                    break;
                }
            },
        }
    }
}

/// Merges two branch states with the join of the domain.
fn merge<D: Copy>(
    then_state: State<D>,
    else_state: State<D>,
    bottom: D,
    lub: fn(D, D) -> D,
) -> State<D> {
    let mut out = State::new();
    for key in union_keys(&then_state, &else_state) {
        let t = then_state.get(&key).copied().unwrap_or(bottom);
        let f = else_state.get(&key).copied().unwrap_or(bottom);
        out.insert(key, lub(t, f));
    }
    out
}

fn union_keys<D>(a: &State<D>, b: &State<D>) -> Vec<String> {
    let mut keys: Vec<String> = a.keys().cloned().collect();
    for k in b.keys() {
        if !keys.contains(k) {
            keys.push(k.clone());
        }
    }
    keys
}

/// A convenient builder for `x := n`.
pub fn assign(var: &str, n: i64) -> Stmt {
    Stmt::Assign(var.to_string(), Expr::Const(n))
}

/// A convenient builder for `x := y + 1`.
pub fn inc(var: &str) -> Stmt {
    Stmt::Assign(
        var.to_string(),
        Expr::Add(
            Box::new(Expr::Var(var.to_string())),
            Box::new(Expr::Const(1)),
        ),
    )
}
