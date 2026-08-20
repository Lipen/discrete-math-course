//! Fixed-point combinators: recursion without names.
//!
//! In λ-calculus functions have no names, so a function cannot call itself
//! directly. Instead, recursion is expressed through a *fixed point*: a term
//! `X` with `X = F X`. The call-by-name combinator [`y`] unfolds as
//! `Y F → F (Y F)`; the call-by-value combinator [`z`] adds a `λv` wrapper
//! so that the recursive expansion is delayed until an argument arrives --
//! which is what call-by-value evaluation needs. [`fact`] shows the pattern
//! in action: the factorial is built as the fixed point of a one-step term.

use crate::church::{church, is_zero, mult, pred};
use crate::term::Term;

// ===========================================================================
// Call-by-name fixed point
// ===========================================================================

/// Call-by-name Y combinator: `Y = λf. (λx. f (x x)) (λx. f (x x))`.
///
/// For any term `g`, `Y g` reduces to `g (Y g)`, making `Y g` a fixed point
/// of `g`. This is how recursion is expressed in pure λ-calculus without
/// named functions.
///
/// **Note:** under normal-order reduction, `Y g` expands infinitely unless
/// `g` discards its argument. Use `normalize` with a step limit.
///
/// The unfold `Y g → g (Y g)` is visible in the first steps of the trace:
///
/// ```
/// use lambda::fixpoint::y;
/// use lambda::Term;
///
/// // K = λf. λx. x ignores its argument, so Y K → K (Y K) → λx. x:
/// // the fixed point of K is the identity.
/// let k = Term::abs("f", Term::abs("x", Term::var("x")));
/// let steps = Term::app(y(), k).trace(10);
/// // Step 2 is K (Y K) -- the fixed-point equation made visible.
/// assert_eq!(
///     steps[2].to_string(),
///     "(λf. λx. x) ((λx. (λf. λx. x) (x x)) (λx. (λf. λx. x) (x x)))"
/// );
/// // Step 3 is the normal form: λx. x.
/// assert_eq!(steps[3], Term::abs("x", Term::var("x")));
/// ```
pub fn y() -> Term {
    // λf. (λx. f (x x)) (λx. f (x x))
    let inner = Term::abs(
        "x",
        Term::app(Term::var("f"), Term::app(Term::var("x"), Term::var("x"))),
    );
    Term::abs("f", Term::app(inner.clone(), inner))
}

// ===========================================================================
// Call-by-value fixed point
// ===========================================================================

/// Call-by-value Z combinator: `Z = λf. (λx. f (λv. x x v)) (λx. f (λv. x x v))`.
///
/// The `λv` wrapper delays the self-application: `Z g` expands to
/// `g (λv. Z g v)` rather than `g (Z g)`, so the recursive call fires only
/// when the result is applied to an argument. This is what **call-by-value**
/// evaluation needs: the plain Y combinator would expand `Y g` to `g (Y g)`
/// and then keep expanding the recursive argument forever, before `g`'s body
/// (say, a zero test) ever runs. Note that full applicative-order reduction
/// (which reduces inside abstractions) can still loop on `Z g` when the
/// fixed point itself is infinite -- the wrapper protects call-by-value,
/// not every strategy.
///
/// The unfold is visible in the first steps of the trace:
///
/// ```
/// use lambda::fixpoint::z;
/// use lambda::Term;
///
/// // Z g  →  (λx. g (λv. x x v)) (λx. g (λv. x x v))  →  g (λv. Z g v)
/// let steps = Term::app(z(), Term::var("g")).trace(10);
/// assert_eq!(steps[1].to_string(), "(λx. g (λv. x x v)) (λx. g (λv. x x v))");
/// assert_eq!(
///     steps[2].to_string(),
///     "g (λv. (λx. g (λv. x x v)) (λx. g (λv. x x v)) v)"
/// );
/// ```
pub fn z() -> Term {
    // λf. (λx. f (λv. x x v)) (λx. f (λv. x x v))
    let inner = Term::abs(
        "x",
        Term::app(
            Term::var("f"),
            Term::abs(
                "v",
                Term::app(Term::app(Term::var("x"), Term::var("x")), Term::var("v")),
            ),
        ),
    );
    Term::abs("f", Term::app(inner.clone(), inner))
}

// ===========================================================================
// Factorial as a fixed point
// ===========================================================================

/// The factorial recursive body: `Fact = λf. λn. isZero n 1 (mult n (f (pred n)))`.
///
/// `Fact` is not recursive by itself -- the recursive call is the parameter
/// `f`. The fixed-point combinator supplies `f`, so `fact = Z Fact` really
/// is the factorial function.
///
/// ```
/// use lambda::fixpoint::fact;
/// assert!(fact().free_vars().is_empty());
/// ```
pub fn fact_step() -> Term {
    let f = Term::var("f");
    let n = Term::var("n");
    let recursive = Term::app(f, Term::app(pred(), n.clone()));
    let body = Term::app(
        Term::app(Term::app(is_zero(), n.clone()), church(1)),
        Term::app(Term::app(mult(), n), recursive),
    );
    Term::abs("f", Term::abs("n", body))
}

/// The factorial function as a fixed point: `fact = Z Fact`.
///
/// Applying it to a Church numeral and normalizing gives the factorial:
///
/// ```
/// use lambda::church::{church, to_nat};
/// use lambda::fixpoint::fact;
/// use lambda::Term;
///
/// // fact 3 → 6, all through pure β-reduction.
/// let three = Term::app(fact(), church(3));
/// assert_eq!(to_nat(&three.normalize(200_000)), Some(6));
/// ```
///
/// **Note:** naive call-by-name substitution duplicates the recursive call at
/// every level (`mult n (f (pred n))` iterates `n` times over the recursion),
/// so the step count grows exponentially in `n` -- `3!` takes about 1500
/// steps. Real implementations share subterms instead of copying them.
pub fn fact() -> Term {
    Term::app(z(), fact_step())
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use crate::church::to_nat;

    #[test]
    fn y_is_closed() {
        assert!(y().free_vars().is_empty());
    }

    #[test]
    fn z_is_closed() {
        assert!(z().free_vars().is_empty());
    }

    #[test]
    fn y_unfolds_to_fixed_point_equation() {
        // Y g  →  g (Y g)  -- check the unfold on a symbolic g.
        let g = Term::var("g");
        let yg = Term::app(y(), g.clone());
        let t1 = yg.beta_reduce().unwrap();
        assert_eq!(t1.to_string(), "(λx. g (x x)) (λx. g (x x))");
        let t2 = t1.beta_reduce().unwrap();
        // g ((λx. g (x x)) (λx. g (x x)))  =  g (Y g), up to the inner redex.
        assert_eq!(t2.to_string(), "g ((λx. g (x x)) (λx. g (x x)))");
    }

    #[test]
    fn y_fixed_point_of_k_is_identity() {
        // Y K  →  λx. x
        let k = Term::abs("f", Term::abs("x", Term::var("x")));
        let result = Term::app(y(), k).normalize(100);
        assert_eq!(result, Term::abs("x", Term::var("x")));
    }

    #[test]
    fn fact_zero_is_one() {
        let result = Term::app(fact(), church(0)).normalize(100_000);
        assert_eq!(to_nat(&result), Some(1));
    }

    #[test]
    fn fact_three_is_six() {
        let result = Term::app(fact(), church(3)).normalize(200_000);
        assert_eq!(to_nat(&result), Some(6));
    }

    #[test]
    fn z_unfolds_with_delayed_recursion() {
        // Z g  →  g (λv. Z g v): the recursive call is wrapped in λv, so it
        // only fires when an argument arrives.
        let g = Term::var("g");
        let zg = Term::app(z(), g);
        let t1 = zg.beta_reduce().unwrap();
        assert_eq!(t1.to_string(), "(λx. g (λv. x x v)) (λx. g (λv. x x v))");
        let t2 = t1.beta_reduce().unwrap();
        assert_eq!(
            t2.to_string(),
            "g (λv. (λx. g (λv. x x v)) (λx. g (λv. x x v)) v)"
        );
    }

    #[test]
    fn y_does_not_converge_under_applicative_order() {
        // Under applicative order the plain Y combinator expands the
        // recursive argument forever, so the guarded factorial never gets
        // to its zero test.
        let fact_y = Term::app(y(), fact_step());
        let result = Term::app(fact_y, church(3)).reduce_applicative(100);
        assert!(!result.converged);
    }
}
