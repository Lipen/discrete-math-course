//! Well-known combinators.
//!
//! Combinators are closed lambda terms -- terms with no free variables -- that
//! capture common patterns of function composition and application. Together,
//! `S` and `K` form a basis: every closed term can be expressed using only
//! `S` and `K` (and applications).

use crate::term::Term;

// ===========================================================================
// SKI combinators
// ===========================================================================

/// Identity: `I = λx. x`.
///
/// ```
/// use lambda::combinators::i;
/// assert_eq!(i().to_string(), "λx. x");
/// ```
pub fn i() -> Term {
    Term::abs("x", Term::var("x"))
}

/// Constant (Kestrel): `K = λx y. x`.
///
/// Ignores its second argument and returns the first.
///
/// ```
/// use lambda::combinators::k;
/// use lambda::Term;
///
/// // K a b  ->  a
/// let term = Term::app(Term::app(k(), Term::var("a")), Term::var("b"));
/// assert_eq!(term.normalize(10), Term::var("a"));
/// ```
pub fn k() -> Term {
    Term::abs("x", Term::abs("y", Term::var("x")))
}

/// Substitution (Starling): `S = λx y z. x z (y z)`.
///
/// Distributes the third argument to both `x` and `y` before applying `x` to
/// the result.
///
/// S and K together form a **combinator basis**: any closed term can be
/// expressed using only applications of S and K.
///
/// ```
/// use lambda::combinators::{k, s};
/// use lambda::Term;
///
/// // S K K x  ->  x  (SKK is extensionally equal to I)
/// let skk = Term::app(
///     Term::app(Term::app(s(), k()), k()),
///     Term::var("x"),
/// );
/// // Normalizes to x; the trace contracts S and K one step at a time.
/// let result = skk.normalize(100);
/// assert_eq!(result, Term::var("x"));
/// ```
pub fn s() -> Term {
    Term::abs(
        "x",
        Term::abs(
            "y",
            Term::abs(
                "z",
                Term::app(
                    Term::app(Term::var("x"), Term::var("z")),
                    Term::app(Term::var("y"), Term::var("z")),
                ),
            ),
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

    #[test]
    fn i_returns_its_argument() {
        let term = Term::app(i(), Term::var("a"));
        assert_eq!(term.normalize(10), Term::var("a"));
    }

    #[test]
    fn k_drops_second_argument() {
        let term = Term::app(Term::app(k(), Term::var("a")), Term::var("b"));
        assert_eq!(term.normalize(10), Term::var("a"));
    }

    #[test]
    fn s_distributes() {
        // S K K x  ->  x  (SKK is extensionally equal to I)
        let skk = Term::app(Term::app(Term::app(s(), k()), k()), Term::var("x"));
        assert_eq!(skk.normalize(100), Term::var("x"));
    }

    #[test]
    fn i_s_k_are_closed() {
        assert!(i().free_vars().is_empty());
        assert!(k().free_vars().is_empty());
        assert!(s().free_vars().is_empty());
    }
}
