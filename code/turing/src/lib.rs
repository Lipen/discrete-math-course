//! Turing machines.
//!
//! Four models share one tape implementation:
//!
//! - [`Machine`]: a deterministic machine with one tape, a transition table, accepting and rejecting states, and a trace of every configuration, - [`MultiTapeMachine`]: `k` tapes with independent heads, one step moves all of them, - [`NondeterministicMachine`]: a transition relation that offers several moves, searched breadth-first up to a step bound, - [`UniversalMachine`]: a simulator that decodes an [`Encoding`] of a machine and runs it.
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
pub mod multitape;
pub mod nondeterministic;
pub mod tape;
pub mod universal;

pub use machine::{Configuration, Machine, Outcome, Run, Transition};
pub use machines as examples;
pub use multitape::{MultiConfiguration, MultiRun, MultiTapeMachine, MultiTransition};
pub use nondeterministic::{NondeterministicMachine, NondeterministicOutcome, NondeterministicRun};
pub use tape::{Direction, Tape};
pub use universal::{EncodedTransition, Encoding, UniversalMachine};
