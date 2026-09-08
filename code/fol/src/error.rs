//! Evaluation and validation errors.

use std::fmt;

/// A reason an evaluation or validation failed.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Error {
    /// A variable is free in the formula but has no value in the assignment.
    UnboundVariable(String),
    /// The structure does not interpret this constant symbol.
    UnknownConstant(String),
    /// The structure does not interpret this function symbol.
    UnknownFunction(String),
    /// A function symbol is interpreted but has no value on the given arguments.
    UndefinedFunction(String),
    /// The structure does not interpret this predicate symbol.
    UnknownPredicate(String),
    /// A symbol is applied to a wrong number of arguments.
    ArityMismatch {
        symbol: String,
        expected: usize,
        found: usize,
    },
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Error::UnboundVariable(v) => write!(f, "variable `{v}` has no value in the assignment"),
            Error::UnknownConstant(c) => {
                write!(f, "the structure does not interpret constant `{c}`")
            }
            Error::UnknownFunction(sym) => {
                write!(
                    f,
                    "the structure does not interpret function symbol `{sym}`"
                )
            }
            Error::UndefinedFunction(sym) => {
                write!(f, "function `{sym}` has no value for the given arguments")
            }
            Error::UnknownPredicate(p) => {
                write!(f, "the structure does not interpret predicate symbol `{p}`")
            }
            Error::ArityMismatch {
                symbol,
                expected,
                found,
            } => {
                write!(
                    f,
                    "symbol `{symbol}` has arity {expected}, but is applied to {found} arguments"
                )
            }
        }
    }
}

impl std::error::Error for Error {}
