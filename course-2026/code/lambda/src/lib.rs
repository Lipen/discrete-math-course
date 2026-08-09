//! Untyped lambda calculus.
//!
//! Terms, capture-avoiding substitution, beta reduction,
//! and Church arithmetic. Worked examples from the chapter are in `examples/`.

use std::collections::HashSet;

/// A lambda term.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Term {
    /// A variable.
    Var(String),
    /// Abstraction `lambda x. body`.
    Abs(String, Box<Term>),
    /// Application `f a`.
    App(Box<Term>, Box<Term>),
}

impl Term {
    pub fn var(x: &str) -> Term {
        Term::Var(x.to_string())
    }

    pub fn abs(x: &str, body: Term) -> Term {
        Term::Abs(x.to_string(), Box::new(body))
    }

    pub fn app(f: Term, a: Term) -> Term {
        Term::App(Box::new(f), Box::new(a))
    }

    /// Free variables of the term.
    pub fn free_vars(&self) -> HashSet<String> {
        match self {
            Term::Var(x) => HashSet::from([x.clone()]),
            Term::Abs(x, body) => {
                let mut fv = body.free_vars();
                fv.remove(x);
                fv
            }
            Term::App(f, a) => {
                let mut fv = f.free_vars();
                fv.extend(a.free_vars());
                fv
            }
        }
    }

    /// Substitute `self[x := replacement]` without capturing variables.
    pub fn substitute(&self, x: &str, replacement: &Term) -> Term {
        match self {
            Term::Var(y) if y == x => replacement.clone(),
            Term::Var(_) => self.clone(),
            Term::Abs(y, _) if y == x => self.clone(),
            Term::Abs(y, body) => {
                // If `replacement` contains a free `y`, first
                // rename the bound variable (alpha-conversion).
                if replacement.free_vars().contains(y) {
                    let fresh = format!("{y}'");
                    let renamed = body.rename(y, &fresh);
                    Term::Abs(fresh, Box::new(renamed.substitute(x, replacement)))
                } else {
                    Term::Abs(y.clone(), Box::new(body.substitute(x, replacement)))
                }
            }
            Term::App(f, a) => Term::App(
                Box::new(f.substitute(x, replacement)),
                Box::new(a.substitute(x, replacement)),
            ),
        }
    }

    /// Rename the bound variable `from` to `to`.
    fn rename(&self, from: &str, to: &str) -> Term {
        match self {
            Term::Var(y) if y == from => Term::Var(to.to_string()),
            Term::Var(_) => self.clone(),
            Term::Abs(y, body) if y == from => Term::Abs(to.to_string(), body.clone()),
            Term::Abs(y, body) => Term::Abs(y.clone(), Box::new(body.rename(from, to))),
            Term::App(f, a) => {
                Term::App(Box::new(f.rename(from, to)), Box::new(a.rename(from, to)))
            }
        }
    }

    /// One beta-reduction step (leftmost outermost); `None` if the term is a normal form.
    pub fn beta_reduce(&self) -> Option<Term> {
        match self {
            Term::App(f, a) => match f.as_ref() {
                Term::Abs(x, body) => Some(body.substitute(x, a)),
                _ => {
                    if let Some(f_reduced) = f.beta_reduce() {
                        Some(Term::App(Box::new(f_reduced), a.clone()))
                    } else {
                        a.beta_reduce()
                            .map(|a_reduced| Term::App(f.clone(), Box::new(a_reduced)))
                    }
                }
            },
            Term::Abs(x, body) => body
                .beta_reduce()
                .map(|b| Term::Abs(x.clone(), Box::new(b))),
            Term::Var(_) => None,
        }
    }

    /// Full normalization; `max_steps` guards against non-termination.
    pub fn normalize(&self, max_steps: usize) -> Term {
        let mut t = self.clone();
        for _ in 0..max_steps {
            match t.beta_reduce() {
                Some(t_next) => t = t_next,
                None => break,
            }
        }
        t
    }
}

/// Church numeral `n`: `lambda f x. f^n x`.
pub fn church(n: usize) -> Term {
    let f = Term::var("f");
    let x = Term::var("x");
    let mut body = x.clone();
    for _ in 0..n {
        body = Term::app(f.clone(), body);
    }
    Term::abs("f", Term::abs("x", body))
}

/// If the term is a Church numeral in normal form, return its value.
pub fn to_nat(t: &Term) -> Option<usize> {
    let Term::Abs(_, body) = t else { return None };
    let Term::Abs(_, inner) = body.as_ref() else {
        return None;
    };
    let mut current = (**inner).clone();
    let mut n = 0;
    loop {
        match current {
            Term::App(f, a) => match *f {
                Term::Var(name) if name == "f" => {
                    n += 1;
                    current = *a;
                }
                _ => return None,
            },
            Term::Var(name) if name == "x" => return Some(n),
            _ => return None,
        }
    }
}

/// `succ = lambda n f x. f (n f x)`.
pub fn succ() -> Term {
    Term::abs(
        "n",
        Term::abs(
            "f",
            Term::abs(
                "x",
                Term::app(
                    Term::var("f"),
                    Term::app(Term::app(Term::var("n"), Term::var("f")), Term::var("x")),
                ),
            ),
        ),
    )
}

/// `add = lambda m n f x. m f (n f x)`.
pub fn add() -> Term {
    Term::abs(
        "m",
        Term::abs(
            "n",
            Term::abs(
                "f",
                Term::abs(
                    "x",
                    Term::app(
                        Term::app(Term::var("m"), Term::var("f")),
                        Term::app(Term::app(Term::var("n"), Term::var("f")), Term::var("x")),
                    ),
                ),
            ),
        ),
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn church_two_and_three_normalize_to_their_values() {
        assert_eq!(to_nat(&church(2).normalize(100)), Some(2));
        assert_eq!(to_nat(&church(3).normalize(100)), Some(3));
    }

    #[test]
    fn succ_increments() {
        let result = Term::app(succ(), church(2)).normalize(1000);
        assert_eq!(to_nat(&result), Some(3));
    }

    #[test]
    fn add_two_three_is_five() {
        let result = Term::app(Term::app(add(), church(2)), church(3)).normalize(10000);
        assert_eq!(to_nat(&result), Some(5));
    }
}
