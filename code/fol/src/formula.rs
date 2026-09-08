//! First-order formulas: atoms, connectives, and quantifiers.

use std::collections::BTreeSet;
use std::fmt;

use crate::term::Term;

/// A first-order formula.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Formula {
    /// An atomic formula `P(t1, ..., tn)`.
    Pred(String, Vec<Term>),
    /// Equality `t1 = t2`.
    Eq(Term, Term),
    /// Negation `¬f`.
    Not(Box<Formula>),
    /// Conjunction `f ∧ g`.
    And(Box<Formula>, Box<Formula>),
    /// Disjunction `f ∨ g`.
    Or(Box<Formula>, Box<Formula>),
    /// Implication `f -> g`.
    Implies(Box<Formula>, Box<Formula>),
    /// Universal quantification `∀x. f`.
    Forall(String, Box<Formula>),
    /// Existential quantification `∃x. f`.
    Exists(String, Box<Formula>),
}

/// An atomic formula.
pub fn pred(name: &str, args: Vec<Term>) -> Formula {
    Formula::Pred(name.to_string(), args)
}

/// Equality between two terms.
pub fn eq(a: Term, b: Term) -> Formula {
    Formula::Eq(a, b)
}

/// Negation `¬f`.
pub fn not(f: Formula) -> Formula {
    Formula::Not(Box::new(f))
}

/// Conjunction `f ∧ g`.
pub fn and(a: Formula, b: Formula) -> Formula {
    Formula::And(Box::new(a), Box::new(b))
}

/// Disjunction `f ∨ g`.
pub fn or(a: Formula, b: Formula) -> Formula {
    Formula::Or(Box::new(a), Box::new(b))
}

/// Implication `f -> g`.
pub fn implies(a: Formula, b: Formula) -> Formula {
    Formula::Implies(Box::new(a), Box::new(b))
}

/// Universal quantification `∀x. f`.
pub fn forall(x: &str, f: Formula) -> Formula {
    Formula::Forall(x.to_string(), Box::new(f))
}

/// Existential quantification `∃x. f`.
pub fn exists(x: &str, f: Formula) -> Formula {
    Formula::Exists(x.to_string(), Box::new(f))
}

impl Formula {
    /// The free variables of this formula.
    pub fn free_vars(&self) -> BTreeSet<String> {
        match self {
            Formula::Pred(_, args) => args.iter().flat_map(|t| t.vars()).collect(),
            Formula::Eq(a, b) => a.vars().union(&b.vars()).cloned().collect(),
            Formula::Not(g) => g.free_vars(),
            Formula::And(a, b) | Formula::Or(a, b) | Formula::Implies(a, b) => {
                a.free_vars().union(&b.free_vars()).cloned().collect()
            }
            Formula::Forall(x, body) | Formula::Exists(x, body) => {
                let mut vars = body.free_vars();
                vars.remove(x);
                vars
            }
        }
    }

    /// Capture-avoiding substitution: replace every free occurrence of `x` by the term `with`.
    /// A bound variable is renamed first when the replacement would otherwise be captured.
    pub fn substitute(&self, x: &str, with: &Term) -> Formula {
        match self {
            Formula::Pred(p, args) => Formula::Pred(
                p.clone(),
                args.iter().map(|t| t.substitute(x, with)).collect(),
            ),
            Formula::Eq(a, b) => Formula::Eq(a.substitute(x, with), b.substitute(x, with)),
            Formula::Not(g) => Formula::Not(Box::new(g.substitute(x, with))),
            Formula::And(a, b) => Formula::And(
                Box::new(a.substitute(x, with)),
                Box::new(b.substitute(x, with)),
            ),
            Formula::Or(a, b) => Formula::Or(
                Box::new(a.substitute(x, with)),
                Box::new(b.substitute(x, with)),
            ),
            Formula::Implies(a, b) => Formula::Implies(
                Box::new(a.substitute(x, with)),
                Box::new(b.substitute(x, with)),
            ),
            Formula::Forall(y, body) => substitute_quantifier(x, with, y, body, true),
            Formula::Exists(y, body) => substitute_quantifier(x, with, y, body, false),
        }
    }
}

impl fmt::Display for Formula {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Formula::Pred(p, args) => {
                write!(f, "{p}")?;
                if !args.is_empty() {
                    write!(f, "(")?;
                    for (i, a) in args.iter().enumerate() {
                        if i > 0 {
                            write!(f, ", ")?;
                        }
                        write!(f, "{a}")?;
                    }
                    write!(f, ")")?;
                }
                Ok(())
            }
            Formula::Eq(a, b) => write!(f, "({a} = {b})"),
            Formula::Not(g) => write!(f, "¬{g}"),
            Formula::And(a, b) => write!(f, "({a} ∧ {b})"),
            Formula::Or(a, b) => write!(f, "({a} ∨ {b})"),
            Formula::Implies(a, b) => write!(f, "({a} -> {b})"),
            Formula::Forall(x, body) => write!(f, "∀{x}. {body}"),
            Formula::Exists(x, body) => write!(f, "∃{x}. {body}"),
        }
    }
}

/// One quantifier case of capture-avoiding substitution.
fn substitute_quantifier(
    x: &str,
    with: &Term,
    y: &str,
    body: &Formula,
    universal: bool,
) -> Formula {
    let wrap = |z: String, new_body: Formula| {
        if universal {
            Formula::Forall(z, Box::new(new_body))
        } else {
            Formula::Exists(z, Box::new(new_body))
        }
    };

    if y == x {
        // `x` is bound here: there is no free occurrence of it inside `body`.
        wrap(y.to_string(), body.clone())
    } else if !with.vars().contains(y) {
        // The replacement does not mention `y`: no capture can occur.
        wrap(y.to_string(), body.substitute(x, with))
    } else {
        // The replacement mentions `y`: rename the binder to a fresh variable
        // before substituting, so the incoming `y` stays free.
        let mut avoid = body.free_vars();
        avoid.extend(with.vars());
        avoid.insert(x.to_string());
        let z = fresh(y, &avoid);
        let renamed = body.substitute(y, &Term::Var(z.clone()));
        wrap(z, renamed.substitute(x, with))
    }
}

/// A variable derived from `base` that does not occur in `avoid`.
fn fresh(base: &str, avoid: &BTreeSet<String>) -> String {
    if !avoid.contains(base) {
        return base.to_string();
    }
    let mut i = 1;
    loop {
        let candidate = format!("{base}_{i}");
        if !avoid.contains(&candidate) {
            return candidate;
        }
        i += 1;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::term::var;

    #[test]
    fn display() {
        let f = forall("x", exists("y", pred("L", vec![var("x"), var("y")])));
        assert_eq!(f.to_string(), "∀x. ∃y. L(x, y)");
    }

    #[test]
    fn substitution_skips_bound_occurrences() {
        // [x := z] ∀x P(x): x is bound, so nothing changes.
        let f = forall("x", pred("P", vec![var("x")]));
        assert_eq!(f.substitute("x", &var("z")), f);
    }

    #[test]
    fn fresh_skips_taken_names() {
        let avoid = BTreeSet::from(["y".to_string(), "y_1".to_string()]);
        assert_eq!(fresh("y", &avoid), "y_2");
    }
}
