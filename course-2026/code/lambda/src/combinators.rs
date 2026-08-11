//! Well-known combinators.
//!
//! Combinators are closed lambda terms -- terms with no free variables -- that
//! capture common patterns of function composition and application. Together,
//! `S` and `K` form a basis: every closed term can be expressed using only
//! `S` and `K` (and applications).
//!
//! Non-terminating terms like Ω = (λx. x x)(λx. x x) demonstrate that not
//! every term has a normal form.

use crate::term::Term;

// ---------------------------------------------------------------------------
// SKI combinators
// ---------------------------------------------------------------------------

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
/// // K a b  →  a
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
/// // S K K x  →  x  (SKK is extensionally equal to I)
/// let skk = Term::app(
///     Term::app(Term::app(s(), k()), k()),
///     Term::var("x"),
/// );
/// // Normalizes to x, but may take many steps.
/// // SKK x → K x (K x) → x  (in 3 steps)
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

// ---------------------------------------------------------------------------
// Self-application and non-termination
// ---------------------------------------------------------------------------

/// Self-application: `ω = λx. x x`.
///
/// When applied to itself, it produces Ω = ω ω, a term that reduces to itself
/// indefinitely -- the simplest example of a term with no normal form.
///
/// ```
/// use lambda::combinators::self_app;
/// assert_eq!(self_app().to_string(), "λx. x x");
/// ```
pub fn self_app() -> Term {
    Term::abs("x", Term::app(Term::var("x"), Term::var("x")))
}

/// The non-terminating combinator: `Ω = (λx. x x)(λx. x x)`.
///
/// β-reduction of Ω yields Ω again -- it loops forever. This is the classic
/// demonstration that not every λ-term has a normal form.
///
/// ```
/// use lambda::combinators::omega;
/// use lambda::Term;
///
/// // Omega reduces to itself -- it stays non-normal after any number of steps.
/// let t = omega();
/// assert!(!t.is_normal_form());
/// assert_eq!(t.normalize(5), t); // unchanged after 5 reductions
/// ```
pub fn omega() -> Term {
    Term::app(self_app(), self_app())
}

// ---------------------------------------------------------------------------
// Fixed-point combinator
// ---------------------------------------------------------------------------

/// Call-by-name Y combinator: `Y = λf. (λx. f (x x)) (λx. f (x x))`.
///
/// For any term `g`, `Y g` reduces to `g (Y g)`, making `Y g` a fixed point
/// of `g`. This is how recursion is expressed in pure λ-calculus without
/// named functions.
///
/// **Note:** under normal-order reduction, `Y g` expands infinitely. This
/// combinator is included for pedagogical completeness -- use `normalize`
/// with a step limit.
///
/// ```
/// use lambda::combinators::y;
/// // Y combinator is a closed term -- no free variables.
/// assert!(y().free_vars().is_empty());
/// ```
pub fn y() -> Term {
    // λf. (λx. f (x x)) (λx. f (x x))
    let inner = Term::abs(
        "x",
        Term::app(Term::var("f"), Term::app(Term::var("x"), Term::var("x"))),
    );
    Term::abs("f", Term::app(inner.clone(), inner))
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

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
        // S K K x  →  x  (SKK is extensionally equal to I)
        let skk = Term::app(Term::app(Term::app(s(), k()), k()), Term::var("x"));
        assert_eq!(skk.normalize(100), Term::var("x"));
    }

    #[test]
    fn omega_has_no_normal_form() {
        let t = omega();
        assert!(!t.is_normal_form());
        // After one reduction, it's still omega (same shape, different memory).
        let reduced = t.beta_reduce().unwrap();
        assert!(!reduced.is_normal_form());
    }

    #[test]
    fn omega_stays_same_under_reduction() {
        // Ω → Ω (reduces to itself, structurally)
        let t = omega();
        let reduced = t.beta_reduce().unwrap();
        assert_eq!(reduced.beta_reduce(), Some(omega()));
    }

    #[test]
    fn y_combinator_g_is_closed() {
        assert!(y().free_vars().is_empty());
    }

    #[test]
    fn i_s_k_are_closed() {
        assert!(i().free_vars().is_empty());
        assert!(k().free_vars().is_empty());
        assert!(s().free_vars().is_empty());
    }
}
