//! Church encodings: numerals, booleans, and pairs.
//!
//! In untyped lambda calculus, data is encoded as functions. A Church numeral
//! `n` is a function that applies its first argument `n` times:
//!
//! ```text
//! church 0 = λf x. x
//! church 1 = λf x. f x
//! church 2 = λf x. f (f x)
//! church n = λf x. f (f (... (f x)...))
//! ```
//!
//! Arithmetic, booleans, and conditionals are all encoded as pure λ-terms
//! with no built-in types. The zero test and the predecessor (built from
//! pairs) complete the toolkit needed for recursion.

use crate::term::Term;

// ===========================================================================
// Church numerals
// ===========================================================================

/// Church numeral for `n`: `λf x. f^n x` where `f` is applied `n` times.
///
/// ```
/// use lambda::church::{church, to_nat};
/// assert_eq!(to_nat(&church(0)), Some(0));
/// assert_eq!(to_nat(&church(5)), Some(5));
/// ```
pub fn church(n: usize) -> Term {
    let f = Term::var("f");
    let x = Term::var("x");
    let mut body = x;
    for _ in 0..n {
        body = Term::app(f.clone(), body);
    }
    Term::abs("f", Term::abs("x", body))
}

/// If the term is a Church numeral in normal form, return its value.
///
/// Returns `None` for terms that are not Church numerals: wrong structure,
/// a body that is not `f` applied repeatedly to `x`, or a redex inside. The
/// two outer binder names are ignored (a numeral is α-equivalent under any
/// renaming of its binders).
///
/// ```
/// use lambda::Term;
/// use lambda::church::{church, to_nat};
/// assert_eq!(to_nat(&church(3)), Some(3));
/// assert_eq!(to_nat(&Term::var("x")), None);
/// ```
pub fn to_nat(t: &Term) -> Option<usize> {
    let Term::Abs(_, body) = t else {
        return None;
    };
    let Term::Abs(_, inner) = body.as_ref() else {
        return None;
    };
    let mut current = (**inner).clone();
    let mut n = 0;
    loop {
        match current {
            Term::App(f, a) => match *f {
                Term::Var(ref name) if name == "f" => {
                    n += 1;
                    current = *a;
                }
                _ => return None,
            },
            Term::Var(ref name) if name == "x" => return Some(n),
            _ => return None,
        }
    }
}

// ===========================================================================
// Church arithmetic
// ===========================================================================

/// Successor: `succ = λn f x. f (n f x)`.
///
/// Adds one to a Church numeral.
///
/// ```
/// use lambda::church::{church, succ, to_nat};
/// use lambda::Term;
///
/// let one = Term::app(succ(), church(0)).normalize(100);
/// assert_eq!(to_nat(&one), Some(1));
/// ```
pub fn succ() -> Term {
    Term::abs(
        "n",
        Term::abs(
            "f",
            Term::abs(
                "x",
                Term::app(
                    Term::var("f"),
                    Term::app(Term::app(Term::var("n"), Term::var("f")), Term::var("x")),
                ),
            ),
        ),
    )
}

/// Addition: `add = λm n f x. m f (n f x)`.
///
/// ```
/// use lambda::church::{add, church, to_nat};
/// use lambda::Term;
///
/// let sum = Term::app(Term::app(add(), church(2)), church(3)).normalize(1000);
/// assert_eq!(to_nat(&sum), Some(5));
/// ```
pub fn add() -> Term {
    Term::abs(
        "m",
        Term::abs(
            "n",
            Term::abs(
                "f",
                Term::abs(
                    "x",
                    Term::app(
                        Term::app(Term::var("m"), Term::var("f")),
                        Term::app(Term::app(Term::var("n"), Term::var("f")), Term::var("x")),
                    ),
                ),
            ),
        ),
    )
}

/// Multiplication: `mult = λm n f. m (n f)`.
///
/// Applies `n f` (which is `f^n`) as the function to `m`, giving `f^(m×n)`.
///
/// ```
/// use lambda::church::{church, mult, to_nat};
/// use lambda::Term;
///
/// let prod = Term::app(Term::app(mult(), church(3)), church(4)).normalize(1000);
/// assert_eq!(to_nat(&prod), Some(12));
/// ```
pub fn mult() -> Term {
    Term::abs(
        "m",
        Term::abs(
            "n",
            Term::abs(
                "f",
                Term::app(Term::var("m"), Term::app(Term::var("n"), Term::var("f"))),
            ),
        ),
    )
}

/// Exponentiation: `power = λm n f x. n m f x`.
///
/// Uses the Church numeral `n` as a multiplier: `m` is applied `n` times.
/// Because Church numerals iterate their first argument, `n m` applies
/// `m` (as a function on numerals) `n` times, which is exponentiation.
///
/// ```
/// use lambda::church::{church, power, to_nat};
/// use lambda::Term;
///
/// let exp = Term::app(Term::app(power(), church(2)), church(3)).normalize(50000);
/// assert_eq!(to_nat(&exp), Some(8)); // 2^3 = 8
/// ```
pub fn power() -> Term {
    Term::abs(
        "m",
        Term::abs(
            "n",
            Term::abs(
                "f",
                Term::abs(
                    "x",
                    Term::app(
                        Term::app(Term::app(Term::var("n"), Term::var("m")), Term::var("f")),
                        Term::var("x"),
                    ),
                ),
            ),
        ),
    )
}

/// Zero test: `isZero = λn. n (λx. false) true`.
///
/// Applies the constant `false`-function `n` times starting from `true`:
/// only `0` returns `true`, every positive numeral returns `false`.
///
/// ```
/// use lambda::church::{church, church_to_bool, is_zero};
/// use lambda::Term;
///
/// let zero = Term::app(is_zero(), church(0)).normalize(100);
/// let three = Term::app(is_zero(), church(3)).normalize(100);
/// assert_eq!(church_to_bool(&zero), Some(true));
/// assert_eq!(church_to_bool(&three), Some(false));
/// ```
pub fn is_zero() -> Term {
    Term::abs(
        "n",
        Term::app(
            Term::app(Term::var("n"), Term::abs("x", church_false())),
            church_true(),
        ),
    )
}

/// Predecessor: `pred = λn. fst (n (λp. pair (snd p) (succ (snd p))) (pair 0 0))`.
///
/// Shifts the pair `(a, b) → (b, succ b)` `n` times starting from `(0, 0)`;
/// after `n` shifts the *first* component holds `n - 1`. By convention
/// `pred 0 = 0`.
///
/// ```
/// use lambda::church::{church, pred, to_nat};
/// use lambda::Term;
///
/// let p3 = Term::app(pred(), church(3)).normalize(5000);
/// assert_eq!(to_nat(&p3), Some(2));
/// let p0 = Term::app(pred(), church(0)).normalize(5000);
/// assert_eq!(to_nat(&p0), Some(0));
/// ```
pub fn pred() -> Term {
    // λn. fst (n (λp. pair (snd p) (succ (snd p))) (pair 0 0))
    let p = Term::var("p");
    let shift = Term::abs(
        "p",
        Term::app(
            Term::app(pair(), Term::app(snd(), p.clone())),
            Term::app(succ(), Term::app(snd(), p)),
        ),
    );
    let start = Term::app(Term::app(pair(), church(0)), church(0));
    Term::abs(
        "n",
        Term::app(fst(), Term::app(Term::app(Term::var("n"), shift), start)),
    )
}

// ===========================================================================
// Church booleans
// ===========================================================================

/// Church boolean `true = λx y. x` (selects the first argument).
///
/// ```
/// use lambda::church::church_true;
/// assert_eq!(church_true().to_string(), "λx. λy. x");
/// ```
pub fn church_true() -> Term {
    Term::abs("x", Term::abs("y", Term::var("x")))
}

/// Church boolean `false = λx y. y` (selects the second argument).
///
/// ```
/// use lambda::church::church_false;
/// assert_eq!(church_false().to_string(), "λx. λy. y");
/// ```
pub fn church_false() -> Term {
    Term::abs("x", Term::abs("y", Term::var("y")))
}

/// Logical AND: `and = λp q. p q p`.
///
/// If `p` is `true`, the result is `q`; if `p` is `false`, the result is
/// `false`.
///
/// ```
/// use lambda::church::{and, church_true, church_false, church_to_bool};
/// use lambda::Term;
///
/// let result = Term::app(Term::app(and(), church_true()), church_false())
///     .normalize(100);
/// assert_eq!(church_to_bool(&result), Some(false));
/// ```
pub fn and() -> Term {
    Term::abs(
        "p",
        Term::abs(
            "q",
            Term::app(Term::app(Term::var("p"), Term::var("q")), Term::var("p")),
        ),
    )
}

/// Logical OR: `or = λp q. p p q`.
///
/// If `p` is `true`, the result is `true`; if `p` is `false`, the result
/// is `q`.
///
/// ```
/// use lambda::church::{church_true, church_false, church_to_bool, or};
/// use lambda::Term;
///
/// let result = Term::app(Term::app(or(), church_false()), church_true())
///     .normalize(100);
/// assert_eq!(church_to_bool(&result), Some(true));
/// ```
pub fn or() -> Term {
    Term::abs(
        "p",
        Term::abs(
            "q",
            Term::app(Term::app(Term::var("p"), Term::var("p")), Term::var("q")),
        ),
    )
}

/// Logical NOT: `not = λp x y. p y x` (flips the arguments).
///
/// ```
/// use lambda::church::{church_true, church_to_bool, not};
/// use lambda::Term;
///
/// let result = Term::app(not(), church_true()).normalize(100);
/// assert_eq!(church_to_bool(&result), Some(false));
/// ```
pub fn not() -> Term {
    Term::abs(
        "p",
        Term::abs(
            "x",
            Term::abs(
                "y",
                Term::app(Term::app(Term::var("p"), Term::var("y")), Term::var("x")),
            ),
        ),
    )
}

/// Conditional: `ifthenelse = λp x y. p x y`.
///
/// If `p` is `true`, returns `x`; if `p` is `false`, returns `y`.
///
/// ```
/// use lambda::church::{church_false, church_true, ifthenelse};
/// use lambda::Term;
///
/// // if true then "a" else "b"  →  "a"
/// let cond = Term::app(
///     Term::app(Term::app(ifthenelse(), church_true()), Term::var("a")),
///     Term::var("b"),
/// );
/// assert_eq!(cond.normalize(100), Term::var("a"));
/// ```
pub fn ifthenelse() -> Term {
    Term::abs(
        "p",
        Term::abs(
            "x",
            Term::abs(
                "y",
                Term::app(Term::app(Term::var("p"), Term::var("x")), Term::var("y")),
            ),
        ),
    )
}

/// Interpret a Church boolean back to Rust `bool`.
///
/// ```
/// use lambda::Term;
/// use lambda::church::{church_false, church_to_bool, church_true};
/// assert_eq!(church_to_bool(&church_true()), Some(true));
/// assert_eq!(church_to_bool(&church_false()), Some(false));
/// assert_eq!(church_to_bool(&Term::var("x")), None);
/// ```
pub fn church_to_bool(t: &Term) -> Option<bool> {
    let church_true = Term::abs("x", Term::abs("y", Term::var("x")));
    let church_false = Term::abs("x", Term::abs("y", Term::var("y")));
    if *t == church_true {
        Some(true)
    } else if *t == church_false {
        Some(false)
    } else {
        None
    }
}

// ===========================================================================
// Church pairs
// ===========================================================================

/// Church pair constructor: `pair = λx y f. f x y`.
///
/// ```
/// use lambda::church::pair;
/// assert_eq!(pair().to_string(), "λx. λy. λf. f x y");
/// ```
pub fn pair() -> Term {
    Term::abs(
        "x",
        Term::abs(
            "y",
            Term::abs(
                "f",
                Term::app(Term::app(Term::var("f"), Term::var("x")), Term::var("y")),
            ),
        ),
    )
}

/// First projection: `fst = λp. p (λx y. x)` -- extract the first element
/// of a Church pair.
///
/// ```
/// use lambda::church::{church, fst, pair, to_nat};
/// use lambda::Term;
///
/// let p = Term::app(Term::app(pair(), church(3)), church(5));
/// let first = Term::app(fst(), p).normalize(100);
/// assert_eq!(to_nat(&first), Some(3));
/// ```
pub fn fst() -> Term {
    Term::abs(
        "p",
        Term::app(
            Term::var("p"),
            Term::abs("x", Term::abs("y", Term::var("x"))),
        ),
    )
}

/// Second projection: `snd = λp. p (λx y. y)` -- extract the second element
/// of a Church pair.
///
/// ```
/// use lambda::church::{church, pair, snd, to_nat};
/// use lambda::Term;
///
/// let p = Term::app(Term::app(pair(), church(3)), church(5));
/// let second = Term::app(snd(), p).normalize(100);
/// assert_eq!(to_nat(&second), Some(5));
/// ```
pub fn snd() -> Term {
    Term::abs(
        "p",
        Term::app(
            Term::var("p"),
            Term::abs("x", Term::abs("y", Term::var("y"))),
        ),
    )
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use crate::Term;

    use super::*;

    // -- Church numerals ====================================================

    #[test]
    fn church_numerals_encode_correctly() {
        assert_eq!(to_nat(&church(0)), Some(0));
        assert_eq!(to_nat(&church(1)), Some(1));
        assert_eq!(to_nat(&church(7)), Some(7));
        assert_eq!(to_nat(&church(42)), Some(42));
    }

    #[test]
    fn to_nat_rejects_non_numerals() {
        assert_eq!(to_nat(&Term::var("x")), None);
    }

    // -- Arithmetic =========================================================

    #[test]
    fn succ_of_two_is_three() {
        let result = Term::app(succ(), church(2)).normalize(1000);
        assert_eq!(to_nat(&result), Some(3));
    }

    #[test]
    fn add_two_three_is_five() {
        let result = Term::app(Term::app(add(), church(2)), church(3)).normalize(10000);
        assert_eq!(to_nat(&result), Some(5));
    }

    #[test]
    fn add_zero_is_identity() {
        let result = Term::app(Term::app(add(), church(0)), church(7)).normalize(1000);
        assert_eq!(to_nat(&result), Some(7));
    }

    #[test]
    fn mult_three_four_is_twelve() {
        let result = Term::app(Term::app(mult(), church(3)), church(4)).normalize(5000);
        assert_eq!(to_nat(&result), Some(12));
    }

    #[test]
    fn mult_by_zero_is_zero() {
        let result = Term::app(Term::app(mult(), church(0)), church(5)).normalize(1000);
        assert_eq!(to_nat(&result), Some(0));
    }

    #[test]
    fn power_two_three_is_eight() {
        let result = Term::app(Term::app(power(), church(2)), church(3)).normalize(50000);
        assert_eq!(to_nat(&result), Some(8));
    }

    #[test]
    fn power_three_two_is_nine() {
        let result = Term::app(Term::app(power(), church(3)), church(2)).normalize(50000);
        assert_eq!(to_nat(&result), Some(9));
    }

    // -- Zero test and predecessor ===========================================

    #[test]
    fn is_zero_of_zero_is_true() {
        let result = Term::app(is_zero(), church(0)).normalize(100);
        assert_eq!(church_to_bool(&result), Some(true));
    }

    #[test]
    fn is_zero_of_positive_is_false() {
        for n in 1..=4 {
            let result = Term::app(is_zero(), church(n)).normalize(100);
            assert_eq!(church_to_bool(&result), Some(false), "isZero {n}");
        }
    }

    #[test]
    fn pred_of_three_is_two() {
        let result = Term::app(pred(), church(3)).normalize(5000);
        assert_eq!(to_nat(&result), Some(2));
    }

    #[test]
    fn pred_of_zero_is_zero() {
        let result = Term::app(pred(), church(0)).normalize(5000);
        assert_eq!(to_nat(&result), Some(0));
    }

    #[test]
    fn pred_followed_by_succ_is_identity_on_positives() {
        // succ (pred n) = n for n ≥ 1
        for n in 1..=4 {
            let result = Term::app(succ(), Term::app(pred(), church(n))).normalize(10000);
            assert_eq!(to_nat(&result), Some(n), "succ (pred {n})");
        }
    }

    // -- Booleans ===========================================================

    #[test]
    fn true_is_recognized() {
        assert_eq!(church_to_bool(&church_true()), Some(true));
    }

    #[test]
    fn false_is_recognized() {
        assert_eq!(church_to_bool(&church_false()), Some(false));
    }

    #[test]
    fn and_true_true_is_true() {
        let result = Term::app(Term::app(and(), church_true()), church_true()).normalize(100);
        assert_eq!(church_to_bool(&result), Some(true));
    }

    #[test]
    fn and_true_false_is_false() {
        let result = Term::app(Term::app(and(), church_true()), church_false()).normalize(100);
        assert_eq!(church_to_bool(&result), Some(false));
    }

    #[test]
    fn or_false_true_is_true() {
        let result = Term::app(Term::app(or(), church_false()), church_true()).normalize(100);
        assert_eq!(church_to_bool(&result), Some(true));
    }

    #[test]
    fn not_true_is_false() {
        let result = Term::app(not(), church_true()).normalize(100);
        assert_eq!(church_to_bool(&result), Some(false));
    }

    #[test]
    fn ifthenelse_with_true_returns_first_branch() {
        let cond = Term::app(
            Term::app(Term::app(ifthenelse(), church_true()), Term::var("a")),
            Term::var("b"),
        );
        assert_eq!(cond.normalize(100), Term::var("a"));
    }

    #[test]
    fn ifthenelse_with_false_returns_second_branch() {
        let cond = Term::app(
            Term::app(Term::app(ifthenelse(), church_false()), Term::var("a")),
            Term::var("b"),
        );
        assert_eq!(cond.normalize(100), Term::var("b"));
    }

    // -- Pairs ==============================================================

    #[test]
    fn fst_extracts_first_element() {
        let p = Term::app(Term::app(pair(), Term::var("a")), Term::var("b"));
        let first = Term::app(fst(), p).normalize(100);
        assert_eq!(first, Term::var("a"));
    }

    #[test]
    fn snd_extracts_second_element() {
        let p = Term::app(Term::app(pair(), Term::var("a")), Term::var("b"));
        let second = Term::app(snd(), p).normalize(100);
        assert_eq!(second, Term::var("b"));
    }

    #[test]
    fn pair_with_church_numerals_is_projectable() {
        let p = Term::app(Term::app(pair(), church(3)), church(7));
        let first = Term::app(fst(), p.clone()).normalize(100);
        let second = Term::app(snd(), p).normalize(100);
        assert_eq!(to_nat(&first), Some(3));
        assert_eq!(to_nat(&second), Some(7));
    }
}
