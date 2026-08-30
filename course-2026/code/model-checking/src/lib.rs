//! A model-checking toolkit: CTL state labeling over Kripke structures.
//!
//! ```
//! use model_checking::{check, Formula, Kripke};
//!
//! // Traffic light: green -> yellow -> red -> green.
//! let m = Kripke::new(
//!     vec![vec![1], vec![2], vec![0]],
//!     vec![vec![0], vec![1], vec![2]], // atoms: 0 = green, 1 = yellow, 2 = red
//! );
//!
//! // AX green: every successor is green. On the 3-cycle the only state
//! // whose single successor is green is red (it goes back to green).
//! let next_green = Formula::Ax(Box::new(Formula::Atom(0)));
//! assert_eq!(check(&m, &next_green), vec![false, false, true]);
//!
//! // EX red: some successor is red -- true from yellow.
//! let next_red = Formula::Ex(Box::new(Formula::Atom(2)));
//! assert_eq!(check(&m, &next_red), vec![false, true, false]);
//! ```

pub mod ctl;
pub mod kripke;

pub use ctl::{check, Formula};
pub use kripke::Kripke;
