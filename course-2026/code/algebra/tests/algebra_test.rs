//! Axiom checks: associativity, identity, inverses, distributivity.

use algebra::traits::{Field, Group, Monoid, Ring, Semigroup};
use algebra::{is_abelian, Bool, Perm, Zn};

/// Exhaustively check associativity of `op` over a finite set of elements.
fn check_associative<T: Semigroup + std::fmt::Debug>(elems: &[T]) {
    for a in elems {
        for b in elems {
            for c in elems {
                assert_eq!(
                    a.op(b).op(c),
                    a.op(&b.op(c)),
                    "associativity failed for {:?} {:?} {:?}",
                    a,
                    b,
                    c
                );
            }
        }
    }
}

#[test]
fn z5_is_an_abelian_group() {
    let elems: Vec<Zn<5>> = (0..5).map(Zn::new).collect();
    check_associative(&elems);
    let e = Zn::<5>::identity();
    for a in &elems {
        assert_eq!(a.op(&e), *a);
        assert_eq!(a.op(&a.inverse()), e);
    }
    assert!(is_abelian(&elems));
}

#[test]
fn s3_is_a_nonabelian_group() {
    let perms = [
        Perm([0, 1, 2]),
        Perm([0, 2, 1]),
        Perm([1, 0, 2]),
        Perm([1, 2, 0]),
        Perm([2, 0, 1]),
        Perm([2, 1, 0]),
    ];
    check_associative(&perms);
    let e = Perm::<3>::identity();
    for p in &perms {
        assert_eq!(p.op(&e), *p);
        assert_eq!(p.op(&p.inverse()), e);
    }
    assert!(!is_abelian(&perms));
}

#[test]
fn zn_is_a_ring() {
    let elems: Vec<Zn<6>> = (0..6).map(Zn::new).collect();
    for a in &elems {
        assert_eq!(a.add(&a.neg()), Zn::<6>::zero());
        for b in &elems {
            assert_eq!(a.add(b), b.add(a));
            for c in &elems {
                // Distributivity: a * (b + c) == a*b + a*c.
                assert_eq!(a.mul(&b.add(c)), a.mul(b).add(&a.mul(c)));
            }
        }
    }
}

#[test]
fn bool_is_a_field() {
    let elems = [Bool(false), Bool(true)];
    let one = Bool::one();
    for a in &elems {
        assert_eq!(a.add(&a.neg()), Bool::zero());
        for b in &elems {
            assert_eq!(a.add(b), b.add(a));
            assert_eq!(a.mul(b), b.mul(a));
            assert_eq!(a.mul(&one), *a);
        }
    }
    assert_eq!(Bool(true).inv(), Some(Bool(true)));
    assert_eq!(Bool(false).inv(), None);
}

#[test]
fn units_of_z8_form_a_group() {
    let units: Vec<algebra::Unit<8>> = (1..8).filter_map(algebra::Unit::<8>::new).collect();
    assert_eq!(units.len(), 4); // {1, 3, 5, 7}
    check_associative(&units);
    let e = algebra::Unit::<8>::identity();
    for u in &units {
        assert_eq!(u.op(&e), *u);
        assert_eq!(u.op(&u.inverse()), e);
    }
}
