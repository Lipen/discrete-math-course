//! CTL model checking via state labeling.
//!
//! Computes the set of states of a Kripke structure in which a CTL formula
//! holds, bottom-up over subformulas, using the fixed-point characterizations
//! of the temporal operators.

pub mod ctl;
pub mod kripke;

pub use ctl::{check, Formula};
pub use kripke::Kripke;
