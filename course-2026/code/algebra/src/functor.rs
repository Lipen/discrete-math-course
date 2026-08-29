//! Functors and their fixed points.
//!
//! A *functor* is a type constructor `F` together with a `map` operation that
//! lifts a function `A -> B` to a function `F<A> -> F<B>`, respecting
//! identity and composition.
//!
//! The *least fixed point* of `F` is the recursive type `Fix<F> = F<Fix<F>>`,
//! whose values are finite trees of `F` layers. Unfolding the functor
//! `X -> 1 + X` (i.e. `Option`) yields the naturals: `Nat = 1 + Nat =
//! Option<Nat>`, with `None` as zero and `Some` as the successor.

/// A functor: a type constructor with a `map` that lifts functions.
///
/// Rust has no higher-kinded types, so `F` cannot be written `F<T>`; a marker
/// type such as [`OptionF`] stands for the constructor, and its associated
/// type constructor [`Functor::Target`] is what gets applied to an argument:
/// `OptionF::Target<A> = Option<A>`.
///
/// A lawful functor satisfies two equations:
/// 1. `map(id) = id` -- mapping the identity leaves the structure untouched.
/// 2. `map(f ∘ g) = map(f) ∘ map(g)` -- mapping a composition is the
///    composition of the maps.
pub trait Functor {
    /// The type produced by applying the functor to `A`, written `F<A>`.
    type Target<A>;
    /// Lift `f: A -> B` into a function `F<A> -> F<B>`: apply `f` to every
    /// element, keeping the outer shape of the structure.
    fn map<A, B>(fa: &Self::Target<A>, f: impl FnMut(&A) -> B) -> Self::Target<B>;
}

/// The functor `X -> 1 + X`, also known as `Option`.
///
/// `Target<A> = Option<A>`: the `None` case is the constant `1`, the
/// `Some(a)` case is the `X`.
pub struct OptionF;

impl Functor for OptionF {
    type Target<A> = Option<A>;

    fn map<A, B>(fa: &Option<A>, f: impl FnMut(&A) -> B) -> Option<B> {
        fa.as_ref().map(f)
    }
}

/// The least fixed point of a functor: `Fix<F> = F<Fix<F>>`.
///
/// A value of `Fix<F>` is a finite tree of `F` layers; "least" means only
/// the finite unfoldings exist (no infinite chains). The `Box` gives the
/// recursion a pointer so the type has finite size.
///
/// `Fix<OptionF>` is the Peano naturals: `zero = Fix(None)` and
/// `succ(n) = Fix(Some(n))`.
pub struct Fix<F: Functor>(Box<F::Target<Fix<F>>>);

impl Fix<OptionF> {
    /// Zero, the `None` layer.
    pub fn zero() -> Self {
        Fix(Box::new(None))
    }

    /// The successor of `n`, the `Some` layer.
    pub fn succ(n: Self) -> Self {
        Fix(Box::new(Some(n)))
    }

    /// The natural number denoted by this fixed point.
    pub fn to_u32(&self) -> u32 {
        match self.0.as_ref() {
            None => 0,
            Some(n) => 1 + n.to_u32(),
        }
    }

    /// Build the fixed point for a `u32`.
    pub fn from_u32(n: u32) -> Self {
        (0..n).fold(Self::zero(), |acc, _| Self::succ(acc))
    }
}

/// A catamorphism: fold `Fix<F>` using an `F`-algebra `alg: F<A> -> A`.
///
/// An `F`-algebra says how to collapse one layer `F<A>` into a value `A`.
/// `cata` walks the tree bottom-up, replacing every `F` layer by an `A`
/// value, so the whole `Fix<F>` collapses to a single `A`. It is the unique
/// "fold" associated with the data type.
///
/// For `Fix<OptionF>` the algebra `None -> 0, Some(n) -> n + 1` computes
/// `to_u32`; a different algebra folds the same naturals into a different
/// function (e.g. `None -> 1, Some(n) -> n * 2` counts powers of two).
pub fn cata<F: Functor, A>(fix: &Fix<F>, alg: &dyn Fn(F::Target<A>) -> A) -> A {
    let mapped = F::map(fix.0.as_ref(), |sub: &Fix<F>| cata(sub, alg));
    alg(mapped)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fix_of_option_is_the_naturals() {
        assert_eq!(Fix::<OptionF>::zero().to_u32(), 0);
        let three = Fix::<OptionF>::from_u32(3);
        assert_eq!(three.to_u32(), 3);
        assert_eq!(Fix::<OptionF>::succ(three).to_u32(), 4);
    }

    #[test]
    fn cata_folds_an_option_algebra() {
        let three = Fix::<OptionF>::from_u32(3);
        // The Option algebra: None -> 0, Some(n) -> n + 1.
        let alg = |x: Option<u32>| match x {
            None => 0,
            Some(n) => n + 1,
        };
        assert_eq!(cata(&three, &alg), 3);
    }
}
