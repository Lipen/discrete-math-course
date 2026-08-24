//! A declarative, SPIN/SMV-inspired model builder.
//!
//! A `ModelBuilder` describes a *synchronous transition system*: a set of
//! finite-domain variables and a set of guarded transitions. Each
//! transition has a guard (an expression over the current values) and a
//! list of per-variable updates. From a state, every enabled transition
//! produces one successor; variables that a transition does not update
//! keep their value (the frame rule). A state with no enabled transition
//! is a dead end. Compiling the builder produces a `Kripke` structure
//! whose states are the valuations (state `s` encodes the variables in
//! mixed-radix order: the first declared variable is the most
//! significant) and whose atoms are `(variable, value)` pairs.
//!
//! ```
//! use model_checking::{check, Expr, Formula, ModelBuilder};
//!
//! // Traffic light: green -> yellow -> red -> green.
//! let mut b = ModelBuilder::new();
//! let light = b.var("light", 0); // 0 = green, 1 = yellow, 2 = red
//! b.next(
//!     "light",
//!     Expr::mod_(
//!         Expr::add(Expr::var(light), Expr::val(1)),
//!         Expr::val(3),
//!     ),
//! );
//! b.transition(Expr::val(1)); // always enabled: one deterministic step
//!
//! let m = b.build();
//! let green = b.atom("light", 0);
//! let red = b.atom("light", 2);
//!
//! // AG (green -> AF red): after green, every path eventually sees red.
//! let prop = Formula::Ag(Box::new(Formula::Or(
//!     Box::new(Formula::Not(Box::new(Formula::Atom(green)))),
//!     Box::new(Formula::Af(Box::new(Formula::Atom(red)))),
//! )));
//! assert!(check(&m, &prop).iter().all(|&x| x));
//! ```
//!
//! # The expression language
//!
//! Expressions evaluate over the current variable values. Conditions are
//! expressions that are 0 (false) or nonzero (true): comparisons, `not`,
//! `and`, `or`. Arithmetic (`add`, `sub`, `mul`, `mod_`) and a ternary
//! `if_` complete the language.
//!
//! # Domains
//!
//! The domain of a variable is inferred: it starts at `0..=init` and
//! grows to cover every constant that appears in any expression
//! mentioning the variable. `mod` arithmetic is the idiomatic way to keep
//! a value inside a small domain (see the traffic light above). If an
//! update ever computes a value outside the domain, the value is clamped
//! to the nearest domain element. States that only the clamping can reach
//! are simply unreachable from the initial valuations.

use crate::kripke::Kripke;

/// An expression over the current variable values.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Expr {
    /// A constant.
    Const(i64),
    /// The current value of a variable (by index, as returned by `var`).
    Var(usize),
    /// `a == b` (0 or 1).
    Eq(Box<Expr>, Box<Expr>),
    /// `a != b` (0 or 1).
    Ne(Box<Expr>, Box<Expr>),
    /// `a < b` (0 or 1).
    Lt(Box<Expr>, Box<Expr>),
    /// `a <= b` (0 or 1).
    Le(Box<Expr>, Box<Expr>),
    /// `a > b` (0 or 1).
    Gt(Box<Expr>, Box<Expr>),
    /// `a >= b` (0 or 1).
    Ge(Box<Expr>, Box<Expr>),
    /// Logical negation (0 if the argument is nonzero, else 1).
    Not(Box<Expr>),
    /// Logical conjunction.
    And(Box<Expr>, Box<Expr>),
    /// Logical disjunction.
    Or(Box<Expr>, Box<Expr>),
    /// Addition.
    Add(Box<Expr>, Box<Expr>),
    /// Subtraction.
    Sub(Box<Expr>, Box<Expr>),
    /// Multiplication.
    Mul(Box<Expr>, Box<Expr>),
    /// Euclidean remainder (0 when the modulus is 0).
    Mod(Box<Expr>, Box<Expr>),
    /// `if cond { then } else { else }`.
    If(Box<Expr>, Box<Expr>, Box<Expr>),
}

impl Expr {
    /// The value of a variable.
    pub fn var(i: usize) -> Expr {
        Expr::Var(i)
    }

    /// A constant.
    pub fn val(k: i64) -> Expr {
        Expr::Const(k)
    }

    /// `a == b`.
    pub fn eq(a: Expr, b: Expr) -> Expr {
        Expr::Eq(Box::new(a), Box::new(b))
    }

    /// `a != b`.
    pub fn ne(a: Expr, b: Expr) -> Expr {
        Expr::Ne(Box::new(a), Box::new(b))
    }

    /// `a < b`.
    pub fn lt(a: Expr, b: Expr) -> Expr {
        Expr::Lt(Box::new(a), Box::new(b))
    }

    /// `a <= b`.
    pub fn le(a: Expr, b: Expr) -> Expr {
        Expr::Le(Box::new(a), Box::new(b))
    }

    /// `a > b`.
    pub fn gt(a: Expr, b: Expr) -> Expr {
        Expr::Gt(Box::new(a), Box::new(b))
    }

    /// `a >= b`.
    pub fn ge(a: Expr, b: Expr) -> Expr {
        Expr::Ge(Box::new(a), Box::new(b))
    }

    /// Logical negation.
    pub fn not(a: Expr) -> Expr {
        Expr::Not(Box::new(a))
    }

    /// Logical conjunction.
    pub fn and(a: Expr, b: Expr) -> Expr {
        Expr::And(Box::new(a), Box::new(b))
    }

    /// Logical disjunction.
    pub fn or(a: Expr, b: Expr) -> Expr {
        Expr::Or(Box::new(a), Box::new(b))
    }

    /// Addition.
    pub fn add(a: Expr, b: Expr) -> Expr {
        Expr::Add(Box::new(a), Box::new(b))
    }

    /// Subtraction.
    pub fn sub(a: Expr, b: Expr) -> Expr {
        Expr::Sub(Box::new(a), Box::new(b))
    }

    /// Multiplication.
    pub fn mul(a: Expr, b: Expr) -> Expr {
        Expr::Mul(Box::new(a), Box::new(b))
    }

    /// Euclidean remainder.
    pub fn mod_(a: Expr, b: Expr) -> Expr {
        Expr::Mod(Box::new(a), Box::new(b))
    }

    /// `if cond { then } else { else }`.
    pub fn if_(cond: Expr, then: Expr, else_: Expr) -> Expr {
        Expr::If(Box::new(cond), Box::new(then), Box::new(else_))
    }

    fn eval(&self, v: &[i64]) -> i64 {
        match self {
            Expr::Const(k) => *k,
            Expr::Var(i) => v[*i],
            Expr::Eq(a, b) => (a.eval(v) == b.eval(v)) as i64,
            Expr::Ne(a, b) => (a.eval(v) != b.eval(v)) as i64,
            Expr::Lt(a, b) => (a.eval(v) < b.eval(v)) as i64,
            Expr::Le(a, b) => (a.eval(v) <= b.eval(v)) as i64,
            Expr::Gt(a, b) => (a.eval(v) > b.eval(v)) as i64,
            Expr::Ge(a, b) => (a.eval(v) >= b.eval(v)) as i64,
            Expr::Not(a) => (a.eval(v) == 0) as i64,
            Expr::And(a, b) => (a.eval(v) != 0 && b.eval(v) != 0) as i64,
            Expr::Or(a, b) => (a.eval(v) != 0 || b.eval(v) != 0) as i64,
            Expr::Add(a, b) => a.eval(v) + b.eval(v),
            Expr::Sub(a, b) => a.eval(v) - b.eval(v),
            Expr::Mul(a, b) => a.eval(v) * b.eval(v),
            Expr::Mod(a, b) => {
                let d = b.eval(v);
                if d == 0 {
                    0
                } else {
                    a.eval(v).rem_euclid(d)
                }
            }
            Expr::If(c, t, e) => {
                if c.eval(v) != 0 {
                    t.eval(v)
                } else {
                    e.eval(v)
                }
            }
        }
    }

    /// Collect the variables mentioned and the largest constant.
    fn walk(&self, vars: &mut Vec<usize>, max_const: &mut i64) {
        match self {
            Expr::Const(k) => *max_const = (*max_const).max(*k),
            Expr::Var(i) => vars.push(*i),
            Expr::Eq(a, b)
            | Expr::Ne(a, b)
            | Expr::Lt(a, b)
            | Expr::Le(a, b)
            | Expr::Gt(a, b)
            | Expr::Ge(a, b)
            | Expr::And(a, b)
            | Expr::Or(a, b)
            | Expr::Add(a, b)
            | Expr::Sub(a, b)
            | Expr::Mul(a, b)
            | Expr::Mod(a, b) => {
                a.walk(vars, max_const);
                b.walk(vars, max_const);
            }
            Expr::Not(a) => a.walk(vars, max_const),
            Expr::If(c, t, e) => {
                c.walk(vars, max_const);
                t.walk(vars, max_const);
                e.walk(vars, max_const);
            }
        }
    }
}

#[derive(Debug, Clone)]
struct Transition {
    guard: Expr,
    effects: Vec<(usize, Expr)>,
}

/// A synchronous transition system that compiles to a `Kripke` structure.
#[derive(Debug, Clone)]
pub struct ModelBuilder {
    names: Vec<String>,
    inits: Vec<i64>,
    domains: Vec<usize>,
    transitions: Vec<Transition>,
    current: Option<Transition>,
}

impl ModelBuilder {
    /// An empty builder.
    pub fn new() -> Self {
        ModelBuilder {
            names: Vec::new(),
            inits: Vec::new(),
            domains: Vec::new(),
            transitions: Vec::new(),
            current: None,
        }
    }

    /// Declare a variable with an initial value; returns its index.
    ///
    /// The domain starts at `0..=init` and grows with every constant that
    /// appears in an expression mentioning the variable.
    pub fn var(&mut self, name: &str, init: i64) -> usize {
        let i = self.names.len();
        self.names.push(name.to_string());
        self.inits.push(init);
        self.domains.push(init.max(0) as usize + 1);
        i
    }

    /// The index of a declared variable.
    pub fn var_index(&self, name: &str) -> usize {
        self.names
            .iter()
            .position(|n| n == name)
            .unwrap_or_else(|| panic!("no variable named `{}`", name))
    }

    /// Give `name` the update rule `expr` in the transition under
    /// construction. Repeated updates for the same variable replace each
    /// other (the last one wins). A transition is closed by
    /// `transition(guard)`; the first `next` call opens one implicitly.
    pub fn next(&mut self, name: &str, expr: Expr) {
        let i = self.var_index(name);
        self.grow_domains(&expr, Some(i));
        if self.current.is_none() {
            self.current = Some(Transition {
                guard: Expr::Const(1),
                effects: Vec::new(),
            });
        }
        let t = self.current.as_mut().expect("transition opened above");
        if let Some(slot) = t.effects.iter_mut().find(|(v, _)| *v == i) {
            slot.1 = expr;
        } else {
            t.effects.push((i, expr));
        }
    }

    /// Close the transition under construction with `guard` and start a
    /// fresh one. A transition with no updates is a no-op step: when its
    /// guard holds, the system stays in place.
    pub fn transition(&mut self, guard: Expr) {
        self.grow_domains(&guard, None);
        let t = self.current.take();
        let effects = t.map_or_else(Vec::new, |t| t.effects);
        self.transitions.push(Transition { guard, effects });
    }

    /// The atom index for "variable `name` has value `value`".
    ///
    /// Call this after all variables and expressions are declared, so the
    /// inferred domains (and therefore the atom numbering) are final.
    pub fn atom(&self, name: &str, value: i64) -> usize {
        let i = self.var_index(name);
        let offset: usize = self.domains[..i].iter().sum();
        offset + value as usize
    }

    /// The current values of all variables in state `s`.
    pub fn state_values(&self, s: usize) -> Vec<i64> {
        decode(s, &self.domains)
    }

    /// A readable description of state `s`, e.g. `(light=1, turn=0)`.
    pub fn state_label(&self, s: usize) -> String {
        let vals = decode(s, &self.domains);
        let parts: Vec<String> = self
            .names
            .iter()
            .zip(&vals)
            .map(|(n, &v)| format!("{}={}", n, v))
            .collect();
        format!("({})", parts.join(", "))
    }

    /// Compile the transition system into a `Kripke` structure.
    ///
    /// States are all valuations of the variables (exponentially many in
    /// the number of variables -- keep models small). State `s` encodes
    /// the valuation in mixed radix, the first declared variable being
    /// the most significant. A pending unclosed transition is given the
    /// guard `true`; with no transitions at all, every state stutters.
    pub fn build(&self) -> Kripke {
        let mut transitions = self.transitions.clone();
        if let Some(t) = &self.current {
            transitions.push(Transition {
                guard: Expr::Const(1),
                effects: t.effects.clone(),
            });
        }
        if transitions.is_empty() {
            transitions.push(Transition {
                guard: Expr::Const(1),
                effects: Vec::new(),
            });
        }

        let n: usize = self.domains.iter().product();
        let mut successors: Vec<Vec<usize>> = vec![Vec::new(); n];
        let mut atoms: Vec<Vec<usize>> = vec![Vec::new(); n];

        for s in 0..n {
            let vals = decode(s, &self.domains);

            // Atoms: one per (variable, value) pair that holds here.
            let mut atom_list = Vec::new();
            for (i, &val) in vals.iter().enumerate() {
                let offset: usize = self.domains[..i].iter().sum();
                atom_list.push(offset + val as usize);
            }
            atoms[s] = atom_list;

            // Successors: apply every enabled transition, deduplicated.
            let mut seen: Vec<usize> = Vec::new();
            for t in &transitions {
                if t.guard.eval(&vals) != 0 {
                    let mut next_vals = vals.clone();
                    for (vi, e) in &t.effects {
                        let lo = 0i64;
                        let hi = self.domains[*vi] as i64 - 1;
                        next_vals[*vi] = e.eval(&vals).clamp(lo, hi);
                    }
                    let ns = encode(&next_vals, &self.domains);
                    if !seen.contains(&ns) {
                        seen.push(ns);
                    }
                }
            }
            successors[s] = seen;
        }

        Kripke::new(successors, atoms)
    }

    fn grow_domains(&mut self, expr: &Expr, target: Option<usize>) {
        let mut vars: Vec<usize> = Vec::new();
        let mut max_const: i64 = 0;
        expr.walk(&mut vars, &mut max_const);
        let cap = max_const.max(0) as usize + 1;
        if let Some(t) = target {
            if cap > self.domains[t] {
                self.domains[t] = cap;
            }
        }
        for v in vars {
            if cap > self.domains[v] {
                self.domains[v] = cap;
            }
        }
    }
}

/// Decode a mixed-radix state index into per-variable values.
fn decode(s: usize, domains: &[usize]) -> Vec<i64> {
    let mut vals = vec![0i64; domains.len()];
    let mut rest = s;
    for i in (0..domains.len()).rev() {
        vals[i] = (rest % domains[i]) as i64;
        rest /= domains[i];
    }
    vals
}

/// Encode per-variable values into a mixed-radix state index.
fn encode(vals: &[i64], domains: &[usize]) -> usize {
    let mut s = 0;
    for i in 0..vals.len() {
        s = s * domains[i] + vals[i] as usize;
    }
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ctl::{check, Formula};

    #[test]
    fn traffic_light_cycles() {
        let mut b = ModelBuilder::new();
        let light = b.var("light", 0);
        b.next(
            "light",
            Expr::mod_(
                Expr::add(Expr::var(light), Expr::val(1)),
                Expr::val(3),
            ),
        );
        b.transition(Expr::val(1));

        let m = b.build();
        // Domain 0..=3 (the constant 3 grows it): state 3 is unreachable.
        assert_eq!(m.n, 4);
        assert_eq!(m.successors, vec![vec![1], vec![2], vec![0], vec![1]]);

        // Atoms follow the valuations.
        let red = b.atom("light", 2);
        assert_eq!(
            m.atoms.iter().map(|a| a.contains(&red)).collect::<Vec<_>>(),
            vec![false, false, true, false]
        );

        // AG (green -> AF red) holds in every state.
        let green = b.atom("light", 0);
        let prop = Formula::Ag(Box::new(Formula::Or(
            Box::new(Formula::Not(Box::new(Formula::Atom(green)))),
            Box::new(Formula::Af(Box::new(Formula::Atom(red)))),
        )));
        assert!(check(&m, &prop).iter().all(|&x| x));
    }

    #[test]
    fn guarded_transitions_branch() {
        // Two boolean variables; two guarded transitions, one per
        // variable. From (0, 0) both are enabled: the system branches.
        let mut b = ModelBuilder::new();
        let x = b.var("x", 0);
        let y = b.var("y", 0);

        b.next("x", Expr::val(1));
        b.transition(Expr::eq(Expr::var(x), Expr::val(0)));
        b.next("y", Expr::val(1));
        b.transition(Expr::eq(Expr::var(y), Expr::val(0)));

        let m = b.build();
        assert_eq!(m.n, 4);
        // State 0 = (x=0, y=0): both guards fire -> (1,0) and (0,1).
        assert_eq!(m.successors[0], vec![2, 1]);
        // (1,0) = state 2: only y's guard fires -> (1,1) = 3.
        assert_eq!(m.successors[2], vec![3]);
        // (0,1) = state 1: only x's guard fires -> (1,1) = 3.
        assert_eq!(m.successors[1], vec![3]);
        // (1,1) = state 3: no guard fires: a dead end.
        assert_eq!(m.successors[3], Vec::<usize>::new());
    }

    #[test]
    fn unmentioned_variables_keep_their_value() {
        let mut b = ModelBuilder::new();
        let x = b.var("x", 0);
        let y = b.var("y", 1); // y starts at 1 and is never updated
        b.next("x", Expr::val(1));
        b.transition(Expr::eq(Expr::var(x), Expr::val(0)));

        let m = b.build();
        // (x=0, y=1) = 1 -> (x=1, y=1) = 3: y keeps its value.
        assert_eq!(m.successors[1], vec![3]);
        // (x=1, y=1) = 3: the guard is false: a dead end.
        assert_eq!(m.successors[3], Vec::<usize>::new());
        let _ = (x, y);
    }

    #[test]
    fn out_of_domain_values_are_clamped() {
        // Domain of x is {0, 1}; x + 1 overflows at 1 and clamps back.
        let mut b = ModelBuilder::new();
        let x = b.var("x", 0);
        b.next("x", Expr::add(Expr::var(x), Expr::val(1)));
        b.transition(Expr::val(1));

        let m = b.build();
        assert_eq!(m.n, 2);
        assert_eq!(m.successors[0], vec![1]);
        assert_eq!(m.successors[1], vec![1]);
    }

    #[test]
    fn labels_and_values() {
        let mut b = ModelBuilder::new();
        let x = b.var("x", 0);
        let y = b.var("y", 0);
        b.next("x", Expr::val(1));
        b.transition(Expr::val(1));
        b.next("y", Expr::val(1));
        b.transition(Expr::val(1));

        assert_eq!(b.state_label(0), "(x=0, y=0)");
        assert_eq!(b.state_label(1), "(x=0, y=1)");
        assert_eq!(b.state_label(2), "(x=1, y=0)");
        assert_eq!(b.state_values(3), vec![1, 1]);
        let _ = (x, y);
    }
}
