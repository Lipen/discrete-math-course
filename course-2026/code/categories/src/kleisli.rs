//! Kleisli composition for the Option and List monads.
//!
//! A Kleisli arrow is a function `A -> T<B>` for a monad `T`, and Kleisli composition chains two arrows through the monad.
//! For `Option` this is partial functions in sequence, for `Vec` it is every result of the first arrow fed into the second.
//!
//! ```
//! use categories::{kleisli_option, unit_option};
//!
//! let parse = |s: &str| s.parse::<u32>().ok();
//! let half = |n: u32| if n % 2 == 0 { Some(n / 2) } else { None };
//! let both = kleisli_option(parse, half);
//! assert_eq!(both("8"), Some(4));
//! assert_eq!(both("7"), None);
//! assert_eq!(both("x"), None);
//!
//! assert_eq!(unit_option(3), Some(3));
//! ```

/// Kleisli composition of two partial functions: apply `f`, then `g` to every success.
///
/// A `None` from either function makes the composite return `None`.
pub fn kleisli_option<A, B, C>(
    f: impl Fn(A) -> Option<B>,
    g: impl Fn(B) -> Option<C>,
) -> impl Fn(A) -> Option<C> {
    move |a| f(a).and_then(&g)
}

/// Kleisli composition for the List monad: every result of `f` is fed into `g`.
pub fn kleisli_vec<A, B, C>(
    f: impl Fn(A) -> Vec<B>,
    g: impl Fn(B) -> Vec<C>,
) -> impl Fn(A) -> Vec<C> {
    move |a| f(a).into_iter().flat_map(&g).collect()
}

/// The unit of the Option monad: wrap a value into `Some`.
pub fn unit_option<A>(a: A) -> Option<A> {
    Some(a)
}

/// The unit of the List monad: wrap a value into a one-element list.
pub fn unit_vec<A>(a: A) -> Vec<A> {
    vec![a]
}
