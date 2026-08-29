//! Types as data: a small language of type expressions.
//!
//! A compiler or analyzer does not reason with Rust's own types; it holds
//! types as values. `Type` is such a representation, and the "semiring of
//! types" becomes ordinary functions over it: sum is a variant, product is a
//! pair, `Void` is `0` and `Unit` is `1`. The semiring laws hold up to
//! isomorphism and are shown as rewrite rules in [`Type::simplify`].

/// A type expression over a tiny universe.
#[derive(Clone, PartialEq, Eq, Debug)]
pub enum Type {
    /// The empty type, `0` in the semiring: no values.
    Void,
    /// The unit type, `1`: exactly one value.
    Unit,
    /// Booleans: two values.
    Bool,
    /// Natural numbers: infinitely many values.
    Nat,
    /// Sum type `A + B` (a variant).
    Sum(Box<Type>, Box<Type>),
    /// Product type `A * B` (a pair).
    Product(Box<Type>, Box<Type>),
    /// Function type `A -> B`, the exponential `B^A`.
    Func(Box<Type>, Box<Type>),
}

impl Type {
    /// Sum `A + B`.
    pub fn sum(a: Type, b: Type) -> Type {
        Type::Sum(Box::new(a), Box::new(b))
    }
    /// Product `A * B`.
    pub fn product(a: Type, b: Type) -> Type {
        Type::Product(Box::new(a), Box::new(b))
    }
    /// Function `A -> B`.
    pub fn func(a: Type, b: Type) -> Type {
        Type::Func(Box::new(a), Box::new(b))
    }

    /// Number of values, for finite types; `None` for infinite types.
    pub fn cardinality(&self) -> Option<u128> {
        match self {
            Type::Void => Some(0),
            Type::Unit => Some(1),
            Type::Bool => Some(2),
            Type::Nat => None,
            Type::Sum(a, b) => Some(a.cardinality()?.checked_add(b.cardinality()?)?),
            Type::Product(a, b) => Some(a.cardinality()?.checked_mul(b.cardinality()?)?),
            // |B^A| = |B|^|A| (the exponent is truncated to u32; fine for the demo).
            Type::Func(a, b) => b.cardinality()?.checked_pow(a.cardinality()? as u32),
        }
    }

    /// Normalize using the semiring laws:
    /// - `0 + A = A` -- the empty sum;
    /// - `1 * A = A` -- the unit product;
    /// - `0 * A = 0` -- the empty product;
    /// - `1^A = 1`, `B^0 = 1`, `B^1 = B` -- the exponential laws.
    pub fn simplify(&self) -> Type {
        match self {
            Type::Sum(a, b) => {
                let a = a.simplify();
                let b = b.simplify();
                if a == Type::Void {
                    b
                } else if b == Type::Void {
                    a
                } else {
                    Type::sum(a, b)
                }
            }
            Type::Product(a, b) => {
                let a = a.simplify();
                let b = b.simplify();
                if a == Type::Void || b == Type::Void {
                    Type::Void
                } else if a == Type::Unit {
                    b
                } else if b == Type::Unit {
                    a
                } else {
                    Type::product(a, b)
                }
            }
            Type::Func(a, b) => {
                let a = a.simplify();
                let b = b.simplify();
                if b == Type::Unit || a == Type::Void {
                    Type::Unit
                } else if a == Type::Unit {
                    b
                } else {
                    Type::func(a, b)
                }
            }
            other => other.clone(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cardinalities_of_finite_types() {
        assert_eq!(Type::Void.cardinality(), Some(0));
        assert_eq!(Type::Unit.cardinality(), Some(1));
        assert_eq!(Type::Bool.cardinality(), Some(2));
        assert_eq!(Type::sum(Type::Bool, Type::Unit).cardinality(), Some(3));
        assert_eq!(Type::product(Type::Bool, Type::Bool).cardinality(), Some(4));
        // Bool -> Bool has 2^2 = 4 functions.
        assert_eq!(Type::func(Type::Bool, Type::Bool).cardinality(), Some(4));
    }

    #[test]
    fn infinite_types_have_no_cardinality() {
        assert_eq!(Type::Nat.cardinality(), None);
        assert_eq!(Type::sum(Type::Nat, Type::Bool).cardinality(), None);
    }

    #[test]
    fn simplify_applies_semiring_laws() {
        let a = Type::Bool;
        assert_eq!(Type::sum(Type::Void, a.clone()).simplify(), a);
        assert_eq!(Type::product(Type::Unit, a.clone()).simplify(), a);
        assert_eq!(Type::product(Type::Void, a.clone()).simplify(), Type::Void);
        assert_eq!(Type::func(a.clone(), Type::Unit).simplify(), Type::Unit);
        assert_eq!(Type::func(Type::Void, a.clone()).simplify(), Type::Unit);
        assert_eq!(Type::func(Type::Unit, a.clone()).simplify(), a);
    }
}
