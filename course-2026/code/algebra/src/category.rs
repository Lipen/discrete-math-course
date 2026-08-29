//! The category of sets: functions as morphisms.

/// A category whose objects are types and whose morphisms `A -> B` are
/// values of the associated type constructor `Morphism<A, B>`.
///
/// The `'static` bounds come from storing morphisms as `Box<dyn Fn>`: a
/// `'static` trait object can only mention `'static` types. A category must
/// satisfy three laws:
/// 1. `compose(f, id) == f` -- right identity.
/// 2. `compose(id, f) == f` -- left identity.
/// 3. `compose(compose(f, g), h) == compose(f, compose(g, h))` -- associativity.
pub trait Category {
    /// The type of morphisms `A -> B`.
    type Morphism<A: 'static, B: 'static>;

    /// The identity morphism on `A`.
    fn id<A: 'static>() -> Self::Morphism<A, A>;

    /// Compose `f . g`, where `g: A -> B` and `f: B -> C`.
    fn compose<A: 'static, B: 'static, C: 'static>(
        f: Self::Morphism<B, C>,
        g: Self::Morphism<A, B>,
    ) -> Self::Morphism<A, C>;
}

/// The category of Rust types and functions.
pub struct Hask;

impl Category for Hask {
    type Morphism<A: 'static, B: 'static> = Box<dyn Fn(A) -> B>;

    fn id<A: 'static>() -> Self::Morphism<A, A> {
        Box::new(|a| a)
    }

    fn compose<A: 'static, B: 'static, C: 'static>(
        f: Self::Morphism<B, C>,
        g: Self::Morphism<A, B>,
    ) -> Self::Morphism<A, C> {
        Box::new(move |a| f(g(a)))
    }
}

/// Compose two functions: `(f . g)(x) = f(g(x))`.
pub fn compose<A, B, C>(f: impl Fn(B) -> C, g: impl Fn(A) -> B) -> impl Fn(A) -> C {
    move |a| f(g(a))
}

/// The identity function on `A`.
pub fn id<A>() -> impl Fn(A) -> A {
    |a| a
}

/// The constant function: always returns `b`.
pub fn constant<A, B: Clone>(b: B) -> impl Fn(A) -> B {
    move |_| b.clone()
}

/// Curry: `(A, B) -> C` becomes `A -> (B -> C)`. The inner function is boxed
/// because nested `impl Trait` is not allowed in return position.
pub fn curry<A, B, C, F>(f: F) -> impl Fn(A) -> Box<dyn Fn(B) -> C>
where
    A: Clone + 'static,
    B: 'static,
    C: 'static,
    F: Fn(A, B) -> C + Clone + 'static,
{
    move |a| {
        let f = f.clone();
        Box::new(move |b| f(a.clone(), b))
    }
}

/// Uncurry: `A -> (B -> C)` becomes `(A, B) -> C`.
pub fn uncurry<A, B, C, F, G>(f: F) -> impl Fn(A, B) -> C
where
    F: Fn(A) -> G,
    G: Fn(B) -> C,
{
    move |a, b| f(a)(b)
}

/// Flip the arguments of a two-argument function.
pub fn flip<A, B, C, F>(f: F) -> impl Fn(B, A) -> C
where
    F: Fn(A, B) -> C,
{
    move |b, a| f(a, b)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn compose_with_identity_is_the_function_itself() {
        let double = compose(|x: i32| x * 2, id());
        assert_eq!(double(21), 42);
        let double2 = compose(id(), |x: i32| x * 2);
        assert_eq!(double2(21), 42);
    }

    #[test]
    fn curry_and_uncurry_roundtrip() {
        let add = |a: i32, b: i32| a + b;
        let curried = curry(add);
        let uncurried = uncurry(curried);
        assert_eq!(uncurried(2, 3), 5);
        assert_eq!(curry(add)(2)(3), 5);
    }

    #[test]
    fn hask_category_composes() {
        let g = Box::new(|x: i32| x + 1) as Box<dyn Fn(i32) -> i32>;
        let f = Box::new(|x: i32| x * 2) as Box<dyn Fn(i32) -> i32>;
        let fg = Hask::compose(f, g);
        assert_eq!(fg(10), 22); // (10 + 1) * 2
    }

    #[test]
    fn constant_function_ignores_input() {
        let zero = constant(0);
        assert_eq!(zero(123), 0);
    }

    #[test]
    fn flip_swaps_arguments() {
        assert_eq!(flip(|a: i32, b: i32| a - b)(3, 10), 7); // 10 - 3
    }
}
