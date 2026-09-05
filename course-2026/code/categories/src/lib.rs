//! Finite categories, functors, natural transformations, and the Yoneda bijection.
//!
//! A category here is small and concrete: a list of objects, a list of named morphisms, and a total composition table.
//! Builders construct one-object monoid categories, thin categories of posets, and free categories of graphs.
//! Functors and set-valued functors carry `check` methods that verify the defining laws, and `yoneda` verifies the bijection `Nat(Hom(a, -), F) = F(a)` by exhaustive search.
//! Kleisli composition covers the Option and List monads.
//!
//! ```
//! use categories::FiniteCategory;
//!
//! let cat = FiniteCategory::from_monoid(
//!     "Z4",
//!     &[&[0, 1, 2, 3], &[1, 2, 3, 0], &[2, 3, 0, 1], &[3, 0, 1, 2]],
//! );
//! assert!(cat.check_axioms());
//!
//! let m1 = cat.find_morphism("m1").unwrap();
//! let m2 = cat.find_morphism("m2").unwrap();
//! let sum = cat.compose(&cat.morphisms[m1], &cat.morphisms[m2]);
//! assert_eq!(sum.name, "m3"); // 1 + 2 = 3 mod 4
//! ```

pub mod category;
pub mod functor;
pub mod kleisli;
pub mod set;

pub use category::{FiniteCategory, Morphism, ObjId};
pub use functor::Functor;
pub use kleisli::{kleisli_option, kleisli_vec, unit_option, unit_vec};
pub use set::{hom_functor, natural_transformations, yoneda, NaturalTransformation, SetFunctor};
