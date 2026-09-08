//! A tiny imperative program and abstract transfer functions.
//!
//! The analyzer runs the program on abstract values: assignments evaluate an
//! expression abstractly, `If` merges both branches with the join ⊔, and
//! `While` computes a fixpoint by Kleene iteration.

use std::collections::HashMap;

use crate::domains::Const;

/// An integer expression.
#[derive(Debug, Clone)]
pub enum Expr {
    /// An integer literal.
    Const(i64),
    /// A read of the variable with this name.
    Var(String),
    /// `a + b`.
    Add(Box<Expr>, Box<Expr>),
    /// `a * b`.
    Mul(Box<Expr>, Box<Expr>),
    /// `-a`.
    Neg(Box<Expr>),
}

/// A statement. Conditions are deliberately absent: the analyzer
/// over-approximates by running every branch and merging, and by iterating a
/// loop body to a fixpoint.
#[derive(Debug, Clone)]
pub enum Stmt {
    /// `x := e`.
    Assign(String, Expr),
    /// Runs `then` and `else` on copies of the state and merges the results.
    If { then: Vec<Stmt>, els: Vec<Stmt> },
    /// Iterates the body to a fixpoint.
    While { body: Vec<Stmt> },
}

/// An abstract state: a value per variable.
pub type State<D> = HashMap<String, D>;

/// Evaluates an expression in the constant domain.
///
/// ```
/// use analysis::program::{eval_const, Expr, State};
/// use analysis::Const;
///
/// let mut st: State<Const> = State::new();
/// st.insert("x".into(), Const::Val(10));
/// let e = Expr::Mul(
///     Box::new(Expr::Var("x".into())),
///     Box::new(Expr::Const(3)),
/// );
/// assert_eq!(eval_const(&e, &st), Const::Val(30));
/// ```
pub fn eval_const(e: &Expr, st: &State<Const>) -> Const {
    match e {
        Expr::Const(n) => Const::of(*n),
        Expr::Var(v) => st.get(v).copied().unwrap_or(Const::Top),
        Expr::Add(a, b) => eval_const(a, st) + eval_const(b, st),
        Expr::Mul(a, b) => eval_const(a, st) * eval_const(b, st),
        Expr::Neg(a) => -eval_const(a, st),
    }
}

/// Runs a list of statements in the constant domain, updating `st` in place.
///
/// A `While` loop is analyzed by Kleene iteration from the loop-head state:
/// after each pass the state is joined with the loop-head entry state
/// (`F(d) = E ⊔ transfer(B)(d)`), and the iteration stops once it stabilizes.
/// Because the join of two different constants is ⊤ (which every operation
/// preserves), the iteration always converges quickly.
///
/// ```
/// use analysis::program::{assign, exec_const, State};
/// use analysis::Const;
///
/// let program = vec![
///     assign("x", 5),
///     assign("y", 3),
/// ];
/// let mut st: State<Const> = State::new();
/// exec_const(&program, &mut st);
/// assert_eq!(st["x"], Const::Val(5));
/// assert_eq!(st["y"], Const::Val(3));
/// ```
pub fn exec_const(stmts: &[Stmt], st: &mut State<Const>) {
    for s in stmts {
        match s {
            Stmt::Assign(v, e) => {
                st.insert(v.clone(), eval_const(e, st));
            }
            Stmt::If { then, els } => {
                let mut then_state = st.clone();
                let mut else_state = st.clone();
                exec_const(then, &mut then_state);
                exec_const(els, &mut else_state);
                *st = merge(then_state, else_state, Const::Bottom, Const::lub);
            }
            Stmt::While { body } => {
                // Kleene iteration from the loop-head state E: after each pass the
                // next state is joined with E (F(d) = E ⊔ transfer(B)(d)). The
                // join of different constants is ⊤, so the iteration stabilizes.
                let entry = st.clone();
                loop {
                    let mut after = st.clone();
                    exec_const(body, &mut after);
                    let next = merge(entry.clone(), after, Const::Bottom, Const::lub);
                    if next == *st {
                        break;
                    }
                    *st = next;
                }
            }
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

/// A convenient builder for `x := x + 1`.
pub fn inc(var: &str) -> Stmt {
    Stmt::Assign(
        var.to_string(),
        Expr::Add(
            Box::new(Expr::Var(var.to_string())),
            Box::new(Expr::Const(1)),
        ),
    )
}
