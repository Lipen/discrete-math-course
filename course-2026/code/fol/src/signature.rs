//! A first-order signature: the symbols of the language.

use crate::error::Error;
use crate::formula::Formula;
use crate::term::Term;

/// A first-order signature: the constants, function symbols, and predicate
/// symbols of the language, each function and predicate with its arity.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Signature {
    /// Constant symbols.
    pub constants: Vec<String>,
    /// Function symbols, as `(name, arity)`.
    pub functions: Vec<(String, usize)>,
    /// Predicate symbols, as `(name, arity)`.
    pub predicates: Vec<(String, usize)>,
}

impl Signature {
    /// An empty signature.
    pub fn new() -> Self {
        Signature::default()
    }

    /// Add a constant symbol.
    pub fn constant(mut self, name: &str) -> Self {
        self.constants.push(name.to_string());
        self
    }

    /// Add a function symbol of the given arity.
    pub fn function(mut self, name: &str, arity: usize) -> Self {
        self.functions.push((name.to_string(), arity));
        self
    }

    /// Add a predicate symbol of the given arity.
    pub fn predicate(mut self, name: &str, arity: usize) -> Self {
        self.predicates.push((name.to_string(), arity));
        self
    }

    /// Check that every symbol occurring in `f` is declared here with the right arity.
    pub fn validate(&self, f: &Formula) -> Result<(), Error> {
        match f {
            Formula::Pred(p, args) => {
                self.check_predicate(p, args.len())?;
                for t in args {
                    self.validate_term(t)?;
                }
                Ok(())
            }
            Formula::Eq(a, b) => {
                self.validate_term(a)?;
                self.validate_term(b)?;
                Ok(())
            }
            Formula::Not(g) => self.validate(g),
            Formula::And(a, b) | Formula::Or(a, b) | Formula::Implies(a, b) => {
                self.validate(a)?;
                self.validate(b)?;
                Ok(())
            }
            Formula::Forall(_, body) | Formula::Exists(_, body) => self.validate(body),
        }
    }

    fn validate_term(&self, t: &Term) -> Result<(), Error> {
        match t {
            Term::Var(_) => Ok(()),
            Term::Const(c) => {
                if self.constants.iter().any(|n| n == c) {
                    Ok(())
                } else {
                    Err(Error::UnknownConstant(c.clone()))
                }
            }
            Term::Fun(name, args) => {
                match self.functions.iter().find(|(n, _)| n == name) {
                    Some((_, a)) if *a == args.len() => {}
                    Some((_, a)) => {
                        return Err(Error::ArityMismatch {
                            symbol: name.clone(),
                            expected: *a,
                            found: args.len(),
                        })
                    }
                    None => return Err(Error::UnknownFunction(name.clone())),
                }
                for t in args {
                    self.validate_term(t)?;
                }
                Ok(())
            }
        }
    }

    fn check_predicate(&self, p: &str, arity: usize) -> Result<(), Error> {
        match self.predicates.iter().find(|(n, _)| n == p) {
            Some((_, a)) if *a == arity => Ok(()),
            Some((_, a)) => Err(Error::ArityMismatch {
                symbol: p.to_string(),
                expected: *a,
                found: arity,
            }),
            None => Err(Error::UnknownPredicate(p.to_string())),
        }
    }
}
