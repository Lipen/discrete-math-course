//! Combinational circuits as DAGs of gates: build a circuit from inputs,
//! constants, and logic gates, simulate it in one ordered pass, measure its
//! **size** (gate count) and **depth** (longest input-to-output path), and
//! check the standard adders against ordinary integer addition.
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
