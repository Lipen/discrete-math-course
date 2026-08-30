//! First-order terms: variables, constants, and function applications.

use std::collections::BTreeSet;
use std::fmt;

/// A first-order term: a variable, a constant, or a function application.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Term {
    Var(String),
    Const(String),
    Fun(String, Vec<Term>),
}

/// A variable.
pub fn var(name: &str) -> Term {
    Term::Var(name.to_string())
}

/// A constant.
pub fn constant(name: &str) -> Term {
    Term::Const(name.to_string())
}

/// A function application `f(t1, ..., tn)`.
pub fn func(name: &str, args: Vec<Term>) -> Term {
    Term::Fun(name.to_string(), args)
}

impl Term {
    /// The variables occurring in this term.
    pub fn vars(&self) -> BTreeSet<String> {
        match self {
            Term::Var(x) => [x.clone()].into_iter().collect(),
            Term::Const(_) => BTreeSet::new(),
            Term::Fun(_, args) => args.iter().flat_map(|t| t.vars()).collect(),
        }
    }

    /// Replace every occurrence of the variable `x` by `with`. Terms have no
    /// binders, so no renaming is needed.
    pub fn substitute(&self, x: &str, with: &Term) -> Term {
        match self {
            Term::Var(y) => {
                if y == x {
                    with.clone()
                } else {
                    self.clone()
                }
            }
            Term::Const(_) => self.clone(),
            Term::Fun(name, args) => Term::Fun(
                name.clone(),
                args.iter().map(|a| a.substitute(x, with)).collect(),
            ),
        }
    }
}

impl fmt::Display for Term {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Term::Var(x) => write!(f, "{x}"),
            Term::Const(c) => write!(f, "{c}"),
            Term::Fun(name, args) => {
                write!(f, "{name}(")?;
                for (i, a) in args.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{a}")?;
                }
                write!(f, ")")
            }
        }
    }
}
