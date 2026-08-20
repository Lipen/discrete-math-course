//! A small DPLL(T) stack for quantifier-free SMT problems.
//!
//! The crate builds a satisfiability solver in layers, from the Boolean core
//! up to a mixed-signature driver:
//!
//! - [`sat`] -- a self-contained DPLL SAT solver (unit propagation and
//!   backtracking), the engine every other module uses;
//! - [`difference`] -- difference logic, solved as a negative-cycle test;
//! - [`linear`] -- linear real arithmetic by Fourier--Motzkin elimination
//!   with exact rational arithmetic;
//! - [`integers`] -- linear integer arithmetic by branch and bound on the
//!   rational relaxation;
//! - [`bitvec`] -- fixed-width bitvectors by bit-blasting into the SAT core;
//! - [`driver`] -- the DPLL(T) loop: abstract a mixed formula to Booleans,
//!   hand each SAT model to the theory solvers, and learn conflicts.
//!
//! The classic example, difference logic, is still solved directly:
//!
//! ```
//! use smt::difference::{Constraint, solve};
//!
//! // 4 <= x - y <= 5  (i.e. x - y <= 5 and y - x <= -4)
//! let cs = vec![
//!     Constraint { x: 0, y: 1, c: 5 },
//!     Constraint { x: 1, y: 0, c: -4 },
//! ];
//!
//! let a = solve(&cs).unwrap();
//! assert!(a[0] - a[1] <= 5);
//! assert!(a[1] - a[0] <= -4);
//! ```

pub mod bitvec;
pub mod difference;
pub mod driver;
pub mod integers;
pub mod linear;
pub mod sat;

pub use difference::{solve, Constraint};
pub use driver::{check, Atom, Error, Formula, Verdict};
pub use linear::Rat;
