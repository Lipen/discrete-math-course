//! Turing machines.
//!
//! A concrete model: a tape held as two stacks, a deterministic transition
//! table, accepting and rejecting states, and a trace of every configuration
//! the machine visits. The design follows the definition in the chapter --
//! simple, transparent, no generics beyond what the model naturally needs.
//!
//! ```
//! use turing::{machines, Tape, Outcome};
//!
//! // Use one of the ready-made machines.
//! let m = machines::ends_with_zero();
//! let tape = Tape::with_word(&['0', '1', '0'], ' ');
//! let run = m.run(tape, 100);
//! assert_eq!(run.outcome, Outcome::Accepted);
//! ```
//!
//! See [`machines`] for the full catalogue of example machines.

pub mod machine;
pub mod machines;
pub mod tape;

pub use machine::{Configuration, Machine, Outcome, Run, Transition};
pub use machines as examples;
pub use tape::{Direction, Tape};
