//! The type-level semiring: `Sum` (+) and `Prod` (×) over Rust types.
//!
//! Rust's types form a *commutative semiring* up to isomorphism: [`Zero`] is
//! `0`, [`One`] is `1`, [`Sum`] is `+`, [`Prod`] is `×`. The laws do not hold
//! by `==` (Rust cannot compare types), but by a pair of inverse functions:
//! each law below is an isomorphism together with its inverse, and the tests
//! check the round-trip on concrete finite types.
//!
//! This is the type-level cousin of the data-level [`crate::types::Type`],
//! which represents the same semiring as values. The exponential `B^A`
//! (function types) lives in [`crate::category`].

/// The empty type, `0`: it has no values, hence no constructor.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Zero {}

/// The unit type, `1`: exactly one value.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct One;

/// The sum `A + B`: a value is either a `Left` of `A` or a `Right` of `B`.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Sum<A, B> {
    /// The value of type `A`.
    Left(A),
    /// The value of type `B`.
    Right(B),
}

/// The product `A * B`: a pair.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Prod<A, B>(pub A, pub B);

/// `A + B ≅ B + A`: swap the two sides. It is its own inverse.
pub fn sum_comm<A, B>(s: Sum<A, B>) -> Sum<B, A> {
    match s {
        Sum::Left(a) => Sum::Right(a),
        Sum::Right(b) => Sum::Left(b),
    }
}

/// `(A + B) + C ≅ A + (B + C)`: re-group the sum.
pub fn sum_assoc<A, B, C>(s: Sum<Sum<A, B>, C>) -> Sum<A, Sum<B, C>> {
    match s {
        Sum::Left(Sum::Left(a)) => Sum::Left(a),
        Sum::Left(Sum::Right(b)) => Sum::Right(Sum::Left(b)),
        Sum::Right(c) => Sum::Right(Sum::Right(c)),
    }
}

/// Inverse of [`sum_assoc`].
pub fn sum_assoc_inv<A, B, C>(s: Sum<A, Sum<B, C>>) -> Sum<Sum<A, B>, C> {
    match s {
        Sum::Left(a) => Sum::Left(Sum::Left(a)),
        Sum::Right(Sum::Left(b)) => Sum::Left(Sum::Right(b)),
        Sum::Right(Sum::Right(c)) => Sum::Right(c),
    }
}

/// `A * B ≅ B * A`: swap the pair. It is its own inverse.
pub fn prod_comm<A, B>(p: Prod<A, B>) -> Prod<B, A> {
    Prod(p.1, p.0)
}

/// `(A * B) * C ≅ A * (B * C)`: re-group the pair.
pub fn prod_assoc<A, B, C>(p: Prod<Prod<A, B>, C>) -> Prod<A, Prod<B, C>> {
    Prod(p.0 .0, Prod(p.0 .1, p.1))
}

/// Inverse of [`prod_assoc`].
pub fn prod_assoc_inv<A, B, C>(p: Prod<A, Prod<B, C>>) -> Prod<Prod<A, B>, C> {
    Prod(Prod(p.0, p.1 .0), p.1 .1)
}

/// `A * (B + C) ≅ A*B + A*C`: pull `A` out of the sum.
pub fn distrib<A, B, C>(p: Prod<A, Sum<B, C>>) -> Sum<Prod<A, B>, Prod<A, C>> {
    match p.1 {
        Sum::Left(b) => Sum::Left(Prod(p.0, b)),
        Sum::Right(c) => Sum::Right(Prod(p.0, c)),
    }
}

/// Inverse of [`distrib`].
pub fn distrib_inv<A, B, C>(s: Sum<Prod<A, B>, Prod<A, C>>) -> Prod<A, Sum<B, C>> {
    match s {
        Sum::Left(Prod(a, b)) => Prod(a, Sum::Left(b)),
        Sum::Right(Prod(a, c)) => Prod(a, Sum::Right(c)),
    }
}

/// `0 + A ≅ A`: a `Sum<Zero, A>` can only be a `Right`.
pub fn sum_zero<A>(s: Sum<Zero, A>) -> A {
    match s {
        Sum::Right(a) => a,
        Sum::Left(z) => match z {}, // Zero is uninhabited: unreachable
    }
}

/// Inverse of [`sum_zero`].
pub fn sum_zero_inv<A>(a: A) -> Sum<Zero, A> {
    Sum::Right(a)
}

/// `1 * A ≅ A`: the `One` carries no information.
pub fn prod_one<A>(p: Prod<One, A>) -> A {
    p.1
}

/// Inverse of [`prod_one`].
pub fn prod_one_inv<A>(a: A) -> Prod<One, A> {
    Prod(One, a)
}

/// `0 * A ≅ 0`: a `Prod<Zero, A>` is uninhabited, so both directions are
/// defined by an empty match. The law is vacuous.
pub fn prod_zero<A>(p: Prod<Zero, A>) -> Zero {
    match p.0 {}
}

/// Inverse of [`prod_zero`]: equally vacuous.
pub fn prod_zero_inv<A>(z: Zero) -> Prod<Zero, A> {
    match z {}
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Check `back(fwd(x)) == x` over a finite domain. For our isomorphisms
    /// the domain and codomain have equal size, so this single direction is
    /// enough to pin down the inverse.
    fn check_iso<A, B, F, G>(domain: &[A], fwd: F, back: G)
    where
        A: Clone + PartialEq + std::fmt::Debug,
        B: PartialEq,
        F: Fn(A) -> B,
        G: Fn(B) -> A,
    {
        for x in domain {
            assert_eq!(back(fwd(x.clone())), *x, "iso failed at {:?}", x);
        }
    }

    #[test]
    fn sum_commutes() {
        let domain: Vec<Sum<bool, u8>> = [false, true]
            .into_iter()
            .map(Sum::Left)
            .chain((0..=255u8).map(Sum::Right))
            .collect();
        check_iso(&domain, sum_comm::<bool, u8>, sum_comm::<u8, bool>);
    }

    #[test]
    fn sum_is_associative() {
        let mut domain = Vec::new();
        for a in [false, true] {
            domain.push(Sum::Left(Sum::Left(a)));
        }
        for b in [false, true] {
            domain.push(Sum::Left(Sum::Right(b)));
        }
        for c in [false, true] {
            domain.push(Sum::Right(c));
        }
        check_iso(&domain, sum_assoc, sum_assoc_inv);
    }

    #[test]
    fn prod_commutes() {
        let mut domain = Vec::new();
        for a in [false, true] {
            for b in [false, true] {
                domain.push(Prod(a, b));
            }
        }
        check_iso(&domain, prod_comm::<bool, bool>, prod_comm::<bool, bool>);
    }

    #[test]
    fn prod_is_associative() {
        let mut domain = Vec::new();
        for a in [false, true] {
            for b in [false, true] {
                for c in [false, true] {
                    domain.push(Prod(Prod(a, b), c));
                }
            }
        }
        check_iso(&domain, prod_assoc, prod_assoc_inv);
    }

    #[test]
    fn distributes() {
        let mut domain = Vec::new();
        for a in [false, true] {
            for b in [false, true] {
                domain.push(Prod(a, Sum::Left(b)));
            }
            for c in [false, true] {
                domain.push(Prod(a, Sum::Right(c)));
            }
        }
        check_iso(&domain, distrib, distrib_inv);
    }

    #[test]
    fn zero_is_sum_identity() {
        check_iso(&[false, true], sum_zero_inv, sum_zero);
    }

    #[test]
    fn one_is_prod_identity() {
        let domain: Vec<Prod<One, bool>> =
            [false, true].into_iter().map(|a| Prod(One, a)).collect();
        check_iso(&domain, prod_one, prod_one_inv);
    }
    // `prod_zero` is vacuous: `Prod<Zero, A>` has no values to round-trip.
}
