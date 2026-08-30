//! Combinational circuits as DAGs of gates.
//!
//! A circuit is a directed acyclic graph whose sources are the primary inputs
//! and the constants 0/1, whose internal nodes are logic gates (AND, OR, XOR,
//! NOT), and whose sinks are the outputs. Signals flow strictly from inputs to
//! outputs, so a circuit computes a boolean function with no memory. This
//! crate simulates circuits, measures their **size** (gate count) and
//! **depth** (longest input-to-output path), and builds the standard adders --
//! a half adder, a full adder, and the ripple-carry chain of `n` full adders --
//! verifying them against ordinary integer addition.
//!
//! ```
//! use circuits::adder::ripple_carry_adder;
//!
//! // 0111 + 0001 = 1000.
//! let adder = ripple_carry_adder(4);
//! let (sum, carry) = adder.add(7, 1).unwrap();
//! assert_eq!(sum, 8);
//! assert!(!carry);
//! ```

pub mod adder;
pub mod circuit;

pub use adder::{bits_of, full_adder, half_adder, ripple_carry_adder, value_of, Adder};
pub use circuit::{Circuit, CircuitError, Gate, NodeId};
