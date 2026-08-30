//! Structures (models) and Tarski-style truth evaluation.

use std::collections::{HashMap, HashSet};

use crate::error::Error;
use crate::formula::Formula;
use crate::term::Term;

/// A model: a non-empty domain together with an interpretation of every
/// constant, function symbol, and predicate symbol.
#[derive(Debug, Clone)]
pub struct Structure {
    /// The domain of individuals.
    pub domain: Vec<String>,
    /// The value of each constant, as a domain element.
    pub constants: HashMap<String, String>,
    /// Each function symbol maps every argument tuple to a domain element.
    pub functions: HashMap<String, HashMap<Vec<String>, String>>,
    /// Each predicate symbol maps to the set of tuples it holds of.
    pub predicates: HashMap<String, HashSet<Vec<String>>>,
}

impl Structure {
    /// A structure over the given non-empty domain, with no symbols
    /// interpreted yet.
    pub fn new(domain: Vec<String>) -> Self {
        assert!(
            !domain.is_empty(),
            "the domain of a structure must be non-empty"
        );
        Structure {
            domain,
            constants: HashMap::new(),
            functions: HashMap::new(),
            predicates: HashMap::new(),
        }
    }

    /// Interpret a constant by a domain element.
    pub fn with_constant(mut self, name: &str, value: &str) -> Self {
        self.constants.insert(name.to_string(), value.to_string());
        self
    }

    /// Interpret a function symbol by a total table from argument tuples to
    /// values.
    pub fn with_function(mut self, name: &str, table: HashMap<Vec<String>, String>) -> Self {
        self.functions.insert(name.to_string(), table);
        self
    }

    /// Interpret a predicate symbol by the set of tuples it holds of.
    pub fn with_predicate(mut self, name: &str, relation: HashSet<Vec<String>>) -> Self {
        self.predicates.insert(name.to_string(), relation);
        self
    }

    /// The value of a term under an assignment of free variables.
    pub fn eval_term(
        &self,
        t: &Term,
        assignment: &HashMap<String, String>,
    ) -> Result<String, Error> {
        match t {
            Term::Var(x) => assignment
                .get(x)
                .cloned()
                .ok_or_else(|| Error::UnboundVariable(x.clone())),
            Term::Const(c) => self
                .constants
                .get(c)
                .cloned()
                .ok_or_else(|| Error::UnknownConstant(c.clone())),
            Term::Fun(name, args) => {
                let mut values = Vec::with_capacity(args.len());
                for a in args {
                    values.push(self.eval_term(a, assignment)?);
                }
                let table = self
                    .functions
                    .get(name)
                    .ok_or_else(|| Error::UnknownFunction(name.clone()))?;
                table
                    .get(&values)
                    .cloned()
                    .ok_or_else(|| Error::UndefinedFunction(name.clone()))
            }
        }
    }

    /// The truth of a formula under an assignment of free variables, by
    /// Tarski's definition.
    pub fn eval_with(
        &self,
        f: &Formula,
        assignment: &HashMap<String, String>,
    ) -> Result<bool, Error> {
        match f {
            Formula::Pred(p, args) => {
                let mut values = Vec::with_capacity(args.len());
                for a in args {
                    values.push(self.eval_term(a, assignment)?);
                }
                let relation = self
                    .predicates
                    .get(p)
                    .ok_or_else(|| Error::UnknownPredicate(p.clone()))?;
                Ok(relation.contains(&values))
            }
            Formula::Eq(a, b) => {
                Ok(self.eval_term(a, assignment)? == self.eval_term(b, assignment)?)
            }
            Formula::Not(g) => Ok(!self.eval_with(g, assignment)?),
            Formula::And(a, b) => {
                Ok(self.eval_with(a, assignment)? && self.eval_with(b, assignment)?)
            }
            Formula::Or(a, b) => {
                Ok(self.eval_with(a, assignment)? || self.eval_with(b, assignment)?)
            }
            Formula::Implies(a, b) => {
                Ok(!self.eval_with(a, assignment)? || self.eval_with(b, assignment)?)
            }
            Formula::Forall(x, body) => {
                for d in &self.domain {
                    let mut extended = assignment.clone();
                    extended.insert(x.clone(), d.clone());
                    if !self.eval_with(body, &extended)? {
                        return Ok(false);
                    }
                }
                Ok(true)
            }
            Formula::Exists(x, body) => {
                for d in &self.domain {
                    let mut extended = assignment.clone();
                    extended.insert(x.clone(), d.clone());
                    if self.eval_with(body, &extended)? {
                        return Ok(true);
                    }
                }
                Ok(false)
            }
        }
    }

    /// The truth of a sentence (a formula with no free variables).
    pub fn eval(&self, f: &Formula) -> Result<bool, Error> {
        self.eval_with(f, &HashMap::new())
    }
}
