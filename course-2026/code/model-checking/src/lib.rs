//! A model-checking toolkit: CTL state labeling, LTL via Büchi automata,
//! a declarative model builder, and a pedagogical symbolic engine.
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
//! // AG (green -> AF red): after green, every path eventually sees red.
//! let prop = Formula::Ag(Box::new(Formula::Or(
//!     Box::new(Formula::Not(Box::new(Formula::Atom(0)))),
//!     Box::new(Formula::Af(Box::new(Formula::Atom(2)))),
//! )));
//! assert_eq!(check(&m, &prop), vec![true, true, true]);
//!
//! // AG green alone fails: the light is not always green.
//! let always_green = Formula::Ag(Box::new(Formula::Atom(0)));
//! assert_eq!(check(&m, &always_green), vec![false, false, false]);
//! ```

pub mod builder;
pub mod ctl;
pub mod kripke;
pub mod ltl;
pub mod property;
pub mod symbolic;

pub use builder::{Expr, ModelBuilder};
pub use ctl::{check, Formula};
pub use kripke::Kripke;
pub use ltl::Counterexample;
pub use property::{holds, Prop};
