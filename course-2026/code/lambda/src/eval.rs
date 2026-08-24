//! Reduction strategies: how to pick the next redex.
//!
//! β-reduction itself is fixed; strategies differ in *which* redex is
//! contracted next:
//!
//! - **Normal order** (leftmost outermost) -- the strategy of the book.
//!   If a term has a normal form, normal order finds it.
//! - **Applicative order** (leftmost innermost) -- arguments are evaluated
//!   before functions are applied. It can loop where normal order
//!   terminates, e.g. on `(λx. y) Ω`.
//! - **Weak head normal form** (WHNF) -- stops as soon as the *head* (the
//!   leftmost spine of the term) is a variable or a binder. Redexes inside
//!   arguments are left untouched, which is how lazy languages evaluate.
//!
//! Every multi-step driver takes a fuel limit (`max_steps`) so that
//! diverging terms such as `Ω` cannot hang the process, and reports the
//! outcome as a [`Reduction`] with a step counter.

use crate::term::Term;

/// Outcome of a fuel-limited reduction run.
///
/// The driver performs `steps` single-step reductions, then either reached a
/// normal form (`converged == true`) or ran out of fuel (`converged ==
/// false` -- the term may still contain redexes).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Reduction {
    /// The term reached after `steps` reductions.
    pub term: Term,
    /// Number of reduction steps actually performed (at most the fuel).
    pub steps: usize,
    /// `true` if the run stopped at a normal form, `false` if fuel ran out.
    pub converged: bool,
}

// ===========================================================================
// Single steps
// ===========================================================================

impl Term {
    /// One step of **normal-order** β-reduction (leftmost outermost redex).
    ///
    /// Returns `None` if the term is already in β-normal form -- i.e., no
    /// subterm has the shape `(λx.M) N`.
    ///
    /// ```
    /// use lambda::Term;
    /// // (λx. x) y  ->  y
    /// let id = Term::abs("x", Term::var("x"));
    /// let term = Term::app(id, Term::var("y"));
    /// assert_eq!(term.beta_reduce(), Some(Term::var("y")));
    /// ```
    pub fn beta_reduce(&self) -> Option<Term> {
        match self {
            Term::App(fun, arg) => match fun.as_ref() {
                // (λx. body) arg  ->  body[x := arg]
                Term::Abs(x, body) => Some(body.substitute(x, arg)),
                // Reduce the function part first (leftmost outermost).
                _ => {
                    if let Some(fun_reduced) = fun.beta_reduce() {
                        Some(Term::App(Box::new(fun_reduced), arg.clone()))
                    } else {
                        arg.beta_reduce()
                            .map(|arg_reduced| Term::App(fun.clone(), Box::new(arg_reduced)))
                    }
                }
            },
            // Reduce inside the body of an abstraction.
            Term::Abs(x, body) => body
                .beta_reduce()
                .map(|b| Term::Abs(x.clone(), Box::new(b))),
            Term::Var(_) => None,
        }
    }

    /// One step of **applicative-order** β-reduction (leftmost innermost
    /// redex).
    ///
    /// Arguments are reduced before functions are applied: inside a redex
    /// `(λx. body) arg`, the body and the argument are searched for inner
    /// redexes first, and only when both are inert is the redex itself
    /// contracted.
    ///
    /// ```
    /// use lambda::Term;
    /// // (λx. (λy. y) x) z -- the inner redex goes first:
    /// // applicative order gives (λx. x) z, normal order gives (λy. y) z.
    /// let inner = Term::app(Term::abs("y", Term::var("y")), Term::var("x"));
    /// let t = Term::app(Term::abs("x", inner), Term::var("z"));
    /// assert_eq!(t.beta_reduce_applicative().unwrap().to_string(), "(λx. x) z");
    /// ```
    pub fn beta_reduce_applicative(&self) -> Option<Term> {
        match self {
            Term::App(fun, arg) => match fun.as_ref() {
                Term::Abs(x, body) => {
                    // This is a redex, but inner redexes come first: search
                    // the body (left), then the argument. A step inside the
                    // body keeps the application: (λx. body) arg -> (λx. body') arg.
                    if let Some(b) = body.beta_reduce_applicative() {
                        let fun_reduced = Term::Abs(x.clone(), Box::new(b));
                        return Some(Term::App(Box::new(fun_reduced), arg.clone()));
                    }
                    if let Some(a) = arg.beta_reduce_applicative() {
                        return Some(Term::App(fun.clone(), Box::new(a)));
                    }
                    // Both are inert -- contract the redex itself.
                    Some(body.substitute(x, arg))
                }
                _ => {
                    if let Some(f) = fun.beta_reduce_applicative() {
                        Some(Term::App(Box::new(f), arg.clone()))
                    } else {
                        arg.beta_reduce_applicative()
                            .map(|a| Term::App(fun.clone(), Box::new(a)))
                    }
                }
            },
            Term::Abs(x, body) => body
                .beta_reduce_applicative()
                .map(|b| Term::Abs(x.clone(), Box::new(b))),
            Term::Var(_) => None,
        }
    }

    /// One step toward **weak head normal form**.
    ///
    /// Contracts the first redex on the head spine -- the leftmost chain of
    /// applications -- and nothing else. Returns `None` when the head is a
    /// variable or a binder.
    ///
    /// ```
    /// use lambda::Term;
    /// // ((λx. x) f) a  ->whnf  f a
    /// let t = Term::app(
    ///     Term::app(Term::abs("x", Term::var("x")), Term::var("f")),
    ///     Term::var("a"),
    /// );
    /// assert_eq!(t.whnf_step(), Some(Term::app(Term::var("f"), Term::var("a"))));
    /// ```
    pub fn whnf_step(&self) -> Option<Term> {
        match self {
            Term::App(fun, arg) => match fun.as_ref() {
                Term::Abs(x, body) => Some(body.substitute(x, arg)),
                _ => fun.whnf_step().map(|f| Term::App(Box::new(f), arg.clone())),
            },
            Term::Abs(..) | Term::Var(_) => None,
        }
    }
}

// ===========================================================================
// Normal-form predicates
// ===========================================================================

impl Term {
    /// Check whether the term is in β-normal form -- no redex exists.
    ///
    /// ```
    /// use lambda::Term;
    /// assert!(Term::var("x").is_normal_form());
    /// assert!(Term::abs("x", Term::var("x")).is_normal_form());
    /// // (λx. x) y  is NOT in normal form
    /// let redex = Term::app(Term::abs("x", Term::var("x")), Term::var("y"));
    /// assert!(!redex.is_normal_form());
    /// ```
    pub fn is_normal_form(&self) -> bool {
        match self {
            Term::Var(_) => true,
            Term::Abs(_, body) => body.is_normal_form(),
            Term::App(fun, arg) => {
                // If the left part is an abstraction, it's a redex.
                if matches!(fun.as_ref(), Term::Abs(..)) {
                    return false;
                }
                fun.is_normal_form() && arg.is_normal_form()
            }
        }
    }

    /// Check whether the term is in **weak head normal form**: the head is a
    /// variable or a binder. Redexes inside arguments do not matter.
    ///
    /// ```
    /// use lambda::Term;
    /// // λx. ((λy. y) x) is WHNF (the redex sits in the body)...
    /// let t = Term::abs("x", Term::app(Term::abs("y", Term::var("y")), Term::var("x")));
    /// assert!(t.is_whnf());
    /// // ...but not a normal form.
    /// assert!(!t.is_normal_form());
    /// // An application whose head is a variable is WHNF.
    /// assert!(Term::app(Term::var("f"), Term::var("a")).is_whnf());
    /// ```
    pub fn is_whnf(&self) -> bool {
        match self {
            Term::Var(_) => true,
            Term::Abs(..) => true,
            Term::App(fun, _) => !matches!(fun.as_ref(), Term::Abs(..)) && fun.is_whnf(),
        }
    }
}

// ===========================================================================
// Multi-step drivers
// ===========================================================================

impl Term {
    /// Reduce to normal form with **normal-order** reduction, stopping after
    /// `max_steps` iterations.
    ///
    /// The step guard prevents infinite loops on non-terminating terms such
    /// as `Ω = (λx. x x)(λx. x x)`.
    ///
    /// ```
    /// use lambda::Term;
    /// // (λx. x) a  ->  a  in one step
    /// let term = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
    /// assert_eq!(term.normalize(10), Term::var("a"));
    /// ```
    pub fn normalize(&self, max_steps: usize) -> Term {
        self.reduce_normal(max_steps).term
    }

    /// Reduce to normal form with **applicative-order** reduction, stopping
    /// after `max_steps` iterations.
    ///
    /// When both strategies terminate they reach the same normal form
    /// (Church--Rosser), but applicative order may burn its fuel on
    /// diverging arguments first.
    ///
    /// ```
    /// use lambda::Term;
    /// let id = Term::abs("x", Term::var("x"));
    /// let term = Term::app(Term::app(id, Term::abs("y", Term::var("y"))), Term::var("a"));
    /// assert_eq!(term.normalize_applicative(10), Term::var("a"));
    /// ```
    pub fn normalize_applicative(&self, max_steps: usize) -> Term {
        self.reduce_applicative(max_steps).term
    }

    /// Reduce to **weak head normal form**, stopping after `max_steps`
    /// iterations.
    ///
    /// ```
    /// use lambda::Term;
    /// // Only the head redex is contracted; the redex in the argument stays.
    /// let term = Term::app(
    ///     Term::abs("x", Term::var("x")),
    ///     Term::app(Term::var("f"), Term::app(Term::abs("y", Term::var("y")), Term::var("a"))),
    /// );
    /// assert_eq!(term.whnf(10).to_string(), "f ((λy. y) a)");
    /// ```
    pub fn whnf(&self, max_steps: usize) -> Term {
        self.reduce_whnf(max_steps).term
    }

    /// Normal-order reduction with a step counter: returns the term reached
    /// and how many steps it took.
    ///
    /// ```
    /// use lambda::Term;
    /// let term = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
    /// let r = term.reduce_normal(10);
    /// assert_eq!(r.term, Term::var("a"));
    /// assert_eq!(r.steps, 1);
    /// assert!(r.converged);
    /// ```
    pub fn reduce_normal(&self, max_steps: usize) -> Reduction {
        reduce_loop(self, max_steps, Term::beta_reduce)
    }

    /// Applicative-order reduction with a step counter.
    ///
    /// ```
    /// use lambda::Term;
    /// // (λx. y) Ω: normal order finds y at once; applicative order spends
    /// // its fuel inside Ω and does not converge.
    /// let omega = Term::app(
    ///     Term::abs("x", Term::app(Term::var("x"), Term::var("x"))),
    ///     Term::abs("x", Term::app(Term::var("x"), Term::var("x"))),
    /// );
    /// let t = Term::app(Term::abs("x", Term::var("y")), omega);
    /// assert_eq!(t.reduce_normal(100).term, Term::var("y"));
    /// assert!(!t.reduce_applicative(100).converged);
    /// ```
    pub fn reduce_applicative(&self, max_steps: usize) -> Reduction {
        reduce_loop(self, max_steps, Term::beta_reduce_applicative)
    }

    /// Weak-head reduction with a step counter.
    ///
    /// ```
    /// use lambda::Term;
    /// // ((λx. x) f) a  ->whnf  f a  in one head-spine step.
    /// let t = Term::app(
    ///     Term::app(Term::abs("x", Term::var("x")), Term::var("f")),
    ///     Term::var("a"),
    /// );
    /// let r = t.reduce_whnf(10);
    /// assert_eq!(r.term.to_string(), "f a");
    /// assert_eq!(r.steps, 1);
    /// assert!(r.converged);
    /// ```
    pub fn reduce_whnf(&self, max_steps: usize) -> Reduction {
        reduce_loop(self, max_steps, Term::whnf_step)
    }

    /// Full **normal-order** reduction trace: records each intermediate term
    /// from start to normal form (or until `max_steps` is exhausted).
    ///
    /// ```
    /// use lambda::Term;
    /// // (λx. x) (λy. y) a  ->  two steps
    /// let id = Term::abs("x", Term::var("x"));
    /// let term = Term::app(Term::app(id, Term::abs("y", Term::var("y"))), Term::var("a"));
    /// let trace = term.trace(10);
    /// assert_eq!(trace.len(), 3); // initial + two reductions
    /// assert_eq!(trace[2], Term::var("a"));
    /// ```
    pub fn trace(&self, max_steps: usize) -> Vec<Term> {
        trace_loop(self, max_steps, Term::beta_reduce)
    }

    /// Full **applicative-order** reduction trace.
    ///
    /// ```
    /// use lambda::Term;
    /// // The argument (λy. y) a is reduced before the outer redex.
    /// let term = Term::app(
    ///     Term::abs("x", Term::var("x")),
    ///     Term::app(Term::abs("y", Term::var("y")), Term::var("a")),
    /// );
    /// let trace = term.trace_applicative(10);
    /// assert_eq!(trace[1].to_string(), "(λx. x) a");
    /// assert_eq!(trace[2], Term::var("a"));
    /// ```
    pub fn trace_applicative(&self, max_steps: usize) -> Vec<Term> {
        trace_loop(self, max_steps, Term::beta_reduce_applicative)
    }
}

/// Shared loop: apply a one-step reducer until it returns `None` or the fuel
/// runs out, counting the steps.
fn reduce_loop(start: &Term, max_steps: usize, step: fn(&Term) -> Option<Term>) -> Reduction {
    let mut t = start.clone();
    let mut steps = 0;
    while steps < max_steps {
        match step(&t) {
            Some(next) => {
                t = next;
                steps += 1;
            }
            None => {
                return Reduction {
                    term: t,
                    steps,
                    converged: true,
                }
            }
        }
    }
    Reduction {
        term: t,
        steps,
        converged: false,
    }
}

/// Shared loop: collect every intermediate term like `reduce_loop`, but
/// return the whole trace instead of the final outcome.
fn trace_loop(start: &Term, max_steps: usize, step: fn(&Term) -> Option<Term>) -> Vec<Term> {
    let mut steps = vec![start.clone()];
    let mut t = start.clone();
    for _ in 0..max_steps {
        match step(&t) {
            Some(next) => {
                steps.push(next.clone());
                t = next;
            }
            None => break,
        }
    }
    steps
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use crate::combinators::omega;

    // -- beta_reduce (normal order) ==========================================

    #[test]
    fn beta_reduce_simple_redex() {
        // (λx. x) a  ->  a
        let redex = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
        assert_eq!(redex.beta_reduce(), Some(Term::var("a")));
    }

    #[test]
    fn beta_reduce_nested_redex_leftmost_outermost() {
        // (λx. (λy. y) x) z  ->  (λy. y) z  (not λx. x z)
        let inner = Term::app(Term::abs("y", Term::var("y")), Term::var("x"));
        let outer = Term::abs("x", inner);
        let redex = Term::app(outer, Term::var("z"));
        // Leftmost outermost redex is the whole term.
        let result = redex.beta_reduce().unwrap();
        // After one step: ((λy. y) z)
        assert_eq!(result.to_string(), "(λy. y) z");
    }

    #[test]
    fn beta_reduce_variable_is_normal_form() {
        assert!(Term::var("x").beta_reduce().is_none());
    }

    #[test]
    fn beta_reduce_abstraction_reduces_body() {
        // λx. ((λy. y) x)  ->  λx. x
        let body = Term::app(Term::abs("y", Term::var("y")), Term::var("x"));
        let t = Term::abs("x", body);
        assert_eq!(t.beta_reduce(), Some(Term::abs("x", Term::var("x"))));
    }

    // -- beta_reduce_applicative =============================================

    #[test]
    fn applicative_reduces_innermost_first() {
        // (λx. (λy. y) x) z -- two redexes; applicative order takes the
        // inner one, normal order the outer one.
        let inner = Term::app(Term::abs("y", Term::var("y")), Term::var("x"));
        let t = Term::app(Term::abs("x", inner), Term::var("z"));
        assert_eq!(
            t.beta_reduce_applicative().unwrap().to_string(),
            "(λx. x) z"
        );
        assert_eq!(t.beta_reduce().unwrap().to_string(), "(λy. y) z");
    }

    #[test]
    fn applicative_reduces_argument_of_omega() {
        // (λx. y) Ω: applicative order dives into the argument first.
        let t = Term::app(Term::abs("x", Term::var("y")), omega());
        let step = t.beta_reduce_applicative().unwrap();
        assert_eq!(step.to_string(), "(λx. y) ((λx. x x) (λx. x x))");
        // Normal order contracts the outer redex instead, in one step.
        assert_eq!(t.beta_reduce(), Some(Term::var("y")));
    }

    // -- Normalization =======================================================

    #[test]
    fn normalize_stops_at_normal_form() {
        // (λx. x) a  ->  a  (one step, then stops)
        let redex = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
        assert_eq!(redex.normalize(10), Term::var("a"));
    }

    #[test]
    fn normalize_respects_step_limit_on_non_terminating_term() {
        // Ω = (λx. x x)(λx. x x) stays the same shape; the step limit
        // prevents an infinite loop.
        let t = omega();
        let result = t.normalize(3);
        // After 3 reductions of Ω, it's still not in normal form.
        assert!(!result.is_normal_form());
    }

    #[test]
    fn applicative_reaches_the_same_normal_form() {
        // Both strategies agree when a normal form exists (Church--Rosser).
        let id = Term::abs("x", Term::var("x"));
        let term = Term::app(
            Term::app(id, Term::abs("y", Term::var("y"))),
            Term::var("a"),
        );
        assert_eq!(term.normalize(10), term.normalize_applicative(10));
        assert_eq!(term.normalize_applicative(10), Term::var("a"));
    }

    #[test]
    fn applicative_diverges_where_normal_terminates() {
        // The book's example: (λx. y) Ω.
        let t = Term::app(Term::abs("x", Term::var("y")), omega());
        let normal = t.reduce_normal(100);
        assert!(normal.converged);
        assert_eq!(normal.term, Term::var("y"));
        assert_eq!(normal.steps, 1);
        let applicative = t.reduce_applicative(100);
        assert!(!applicative.converged);
        assert_eq!(applicative.steps, 100); // all fuel spent inside Ω
    }

    // -- Weak head normal form ===============================================

    #[test]
    fn whnf_stops_at_head() {
        // (λx. x) (f ((λy. y) a)) -- WHNF is f ((λy. y) a): the redex inside
        // the argument is not touched.
        let t = Term::app(
            Term::abs("x", Term::var("x")),
            Term::app(
                Term::var("f"),
                Term::app(Term::abs("y", Term::var("y")), Term::var("a")),
            ),
        );
        assert!(!t.is_whnf());
        let r = t.reduce_whnf(10);
        assert_eq!(r.term.to_string(), "f ((λy. y) a)");
        assert_eq!(r.steps, 1);
        assert!(r.converged);
        assert!(r.term.is_whnf());
        assert!(!r.term.is_normal_form());
    }

    #[test]
    fn whnf_abstraction_is_whnf() {
        // λx. (λy. y) x is in WHNF (the redex is inside the body).
        let t = Term::abs(
            "x",
            Term::app(Term::abs("y", Term::var("y")), Term::var("x")),
        );
        assert!(t.is_whnf());
        assert!(!t.is_normal_form());
        // A full normal-order run does reach the normal form.
        assert_eq!(t.normalize(10).to_string(), "λx. x");
    }

    #[test]
    fn whnf_reduces_head_spine() {
        // ((λx. x) f) a  ->whnf  f a
        let t = Term::app(
            Term::app(Term::abs("x", Term::var("x")), Term::var("f")),
            Term::var("a"),
        );
        let r = t.reduce_whnf(10);
        assert_eq!(r.term.to_string(), "f a");
        assert_eq!(r.steps, 1);
    }

    // -- Reduction counters ==================================================

    #[test]
    fn reduction_counts_steps_and_convergence() {
        // Already a normal form: zero steps, converged.
        let r = Term::var("x").reduce_normal(10);
        assert_eq!(r.steps, 0);
        assert!(r.converged);
        assert_eq!(r.term, Term::var("x"));

        // Fuel exhausted on a diverging term.
        let r2 = omega().reduce_normal(5);
        assert_eq!(r2.steps, 5);
        assert!(!r2.converged);
    }

    // -- Traces ==============================================================

    #[test]
    fn trace_records_all_intermediate_steps() {
        // (λx. x) ((λy. y) a)  ->  two steps
        let id = Term::abs("x", Term::var("x"));
        let inner = Term::app(Term::abs("y", Term::var("y")), Term::var("a"));
        let redex = Term::app(id, inner);
        let trace = redex.trace(10);
        assert_eq!(trace.len(), 3); // initial + inner redex + final
    }

    #[test]
    fn trace_applicative_records_steps() {
        let t = Term::app(
            Term::abs("x", Term::var("x")),
            Term::app(Term::abs("y", Term::var("y")), Term::var("a")),
        );
        let trace = t.trace_applicative(10);
        assert_eq!(trace.len(), 3);
        assert_eq!(trace[1].to_string(), "(λx. x) a");
        assert_eq!(trace[2], Term::var("a"));
    }

    // -- is_normal_form ======================================================

    #[test]
    fn variable_is_normal_form() {
        assert!(Term::var("x").is_normal_form());
    }

    #[test]
    fn abstraction_of_normal_form_is_normal_form() {
        assert!(Term::abs("x", Term::var("x")).is_normal_form());
    }

    #[test]
    fn application_with_abs_on_left_is_not_normal_form() {
        let redex = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
        assert!(!redex.is_normal_form());
    }

    #[test]
    fn application_of_normal_forms_is_normal_form() {
        let t = Term::app(Term::var("f"), Term::var("a"));
        assert!(t.is_normal_form());
    }
}
