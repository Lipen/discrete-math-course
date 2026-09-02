//! Unification-based type inference for λ→.
//!
//! This is algorithm W applied to the untyped [`Term`]: fresh metavariables
//! are assigned to each binder and unify, producing the most general type.
//! Self-application `λx. x x` forces the equation `σ = σ -> τ`, which the
//! occurs check rejects.
//!
//! The type system is monomorphic (λ→ has no type quantifiers).
//! A metavariable left unbound at the end becomes a schematic variable `a`, `b`, ... -- so an open result like the identity reads `a -> a` (the scheme σ → σ).
//!
//! ```
//! use type_theory::{infer, Term};
//! // λx. x : a -> a
//! assert_eq!(infer(&Term::abs("x", Term::var("x"))).unwrap().to_string(), "a -> a");
//! // λx. x x is rejected: σ = σ -> τ has no solution.
//! let omega = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
//! assert!(infer(&omega).is_err());
//! ```

use std::collections::HashMap;

use crate::term::Term;
use crate::ty::{Context, Type};

/// A metavariable is a unification variable named `?0`, `?1`, ..., and its name is its identity.
/// A variable without the `?` prefix is a schematic (rigid) variable and must match itself exactly.
fn is_meta(name: &str) -> bool {
    name.starts_with('?')
}

/// Infer the type of `term` in the empty context.
///
/// ```
/// use type_theory::{infer, Term};
/// // The K combinator infers to a -> b -> a.
/// let k = Term::abs("x", Term::abs("y", Term::var("x")));
/// assert_eq!(infer(&k).unwrap().to_string(), "a -> b -> a");
/// ```
pub fn infer(term: &Term) -> Result<Type, InferError> {
    infer_in(term, &Context::new())
}

/// Infer the type of `term` in the context `ctx`.
///
/// `ctx` gives the types of the free variables.
/// Any variable in the context must be a concrete type (a base or arrow type), not an open schematic one.
pub fn infer_in(term: &Term, ctx: &Context) -> Result<Type, InferError> {
    let mut inf = Infer::new();
    let entries: Vec<(String, Type)> = ctx.iter().cloned().collect();
    let ty = inf.infer(term, &entries)?;
    Ok(inf.generalize(&ty))
}

/// A unification substitution over metavariables.
struct Infer {
    /// metavariable name -> resolved type
    subst: HashMap<String, Type>,
    /// next fresh metavariable id
    next: usize,
}

impl Infer {
    fn new() -> Infer {
        Infer {
            subst: HashMap::new(),
            next: 0,
        }
    }

    /// A fresh metavariable `?n`.
    fn fresh(&mut self) -> Type {
        let name = format!("?{}", self.next);
        self.next += 1;
        Type::Var(name)
    }

    /// Follow any chained substitution bindings to the head of `ty`.
    fn resolve(&self, ty: &Type) -> Type {
        match ty {
            Type::Var(name) if is_meta(name) => match self.subst.get(name) {
                Some(bound) => self.resolve(bound),
                None => Type::Var(name.clone()),
            },
            _ => ty.clone(),
        }
    }

    /// Does the metavariable `name` occur anywhere inside `ty`?
    ///
    /// An occurrence would make `name = ... name ...` a cyclic (infinite) type, e.g. `σ = σ -> τ`, so it has no finite solution.
    fn occurs(&self, name: &str, ty: &Type) -> bool {
        match self.resolve(ty) {
            Type::Var(n) => n == name,
            Type::Arrow(dom, cod) => self.occurs(name, &dom) || self.occurs(name, &cod),
            Type::Base(_) => false,
        }
    }

    /// Unify `a` and `b`, binding metavariables as needed.
    fn unify(&mut self, a: &Type, b: &Type) -> Result<(), InferError> {
        let a = self.resolve(a);
        let b = self.resolve(b);
        match (&a, &b) {
            (Type::Var(x), Type::Var(y)) if x == y => Ok(()),
            (Type::Var(x), _) if is_meta(x) => self.bind(x, &b),
            (_, Type::Var(y)) if is_meta(y) => self.bind(y, &a),
            (Type::Base(x), Type::Base(y)) if x == y => Ok(()),
            (Type::Arrow(d1, c1), Type::Arrow(d2, c2)) => {
                self.unify(d1, d2)?;
                self.unify(c1, c2)
            }
            _ => Err(InferError::Mismatch {
                expected: a,
                found: b,
            }),
        }
    }

    /// Bind the metavariable `var` to `ty` (with occurs check).
    fn bind(&mut self, var: &str, ty: &Type) -> Result<(), InferError> {
        if self.occurs(var, ty) {
            return Err(InferError::OccursCheck {
                var: var.to_string(),
                ty: ty.clone(),
            });
        }
        self.subst.insert(var.to_string(), ty.clone());
        Ok(())
    }

    /// The rule-based inference algorithm W, thread the context as a list.
    fn infer(&mut self, term: &Term, ctx: &[(String, Type)]) -> Result<Type, InferError> {
        match term {
            Term::Var(x) => ctx
                .iter()
                .rev()
                .find(|(name, _)| name == x)
                .map(|(_, ty)| ty.clone())
                .ok_or_else(|| InferError::UnboundVariable(x.clone())),
            Term::Abs(x, body) => {
                let dom = self.fresh();
                let mut extended = ctx.to_vec();
                extended.push((x.clone(), dom.clone()));
                let cod = self.infer(body, &extended)?;
                Ok(Type::arrow(dom, cod))
            }
            Term::App(fun, arg) => {
                let fun_ty = self.infer(fun, ctx)?;
                let arg_ty = self.infer(arg, ctx)?;
                let result = self.fresh();
                self.unify(&fun_ty, &Type::arrow(arg_ty, result.clone()))?;
                Ok(result)
            }
        }
    }

    /// Replace every yet-unbound metavariable with a schematic variable `a`, `b`, ... in order of first appearance, left-to-right.
    fn generalize(&self, ty: &Type) -> Type {
        let mut names: HashMap<String, String> = HashMap::new();
        let mut next = 0usize;
        self.gen(ty, &mut names, &mut next)
    }

    fn gen(&self, ty: &Type, names: &mut HashMap<String, String>, next: &mut usize) -> Type {
        match self.resolve(ty) {
            Type::Base(name) => Type::Base(name),
            Type::Arrow(dom, cod) => {
                let d = self.gen(&dom, names, next);
                let c = self.gen(&cod, names, next);
                Type::arrow(d, c)
            }
            Type::Var(name) if is_meta(&name) => {
                let schematic = names.entry(name.clone()).or_insert_with(|| {
                    let n = schematic_name(*next);
                    *next += 1;
                    n
                });
                Type::Var(schematic.clone())
            }
            Type::Var(name) => Type::Var(name),
        }
    }
}

/// The nth schematic variable name: a, b, ..., z, a', b', ...
fn schematic_name(mut i: usize) -> String {
    let letters = b"abcdefghijklmnopqrstuvwxyz";
    let mut s = String::new();
    loop {
        s.insert(0, letters[i % 26] as char);
        if i < 26 {
            break;
        }
        s.insert(0, '\'');
        i = i / 26 - 1;
    }
    s
}

/// Why a term failed to type check during inference.
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum InferError {
    /// A free variable that is not in the typing context.
    UnboundVariable(String),
    /// Unification would produce a cyclic type, e.g. `σ = σ -> τ` for self-application `λx. x x`.
    OccursCheck { var: String, ty: Type },
    /// Two types that must be equal are not.
    Mismatch { expected: Type, found: Type },
}

impl std::fmt::Display for InferError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            InferError::UnboundVariable(x) => write!(f, "unbound variable `{x}`"),
            InferError::OccursCheck { var, ty } => write!(
                f,
                "no finite type: occurs check failed -- `{var}` would equal `{ty}`, a type containing `{var}`"
            ),
            InferError::Mismatch { expected, found } => {
                write!(f, "type mismatch: expected `{expected}`, found `{found}`")
            }
        }
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    fn infer_string(term: &Term) -> String {
        infer(term).unwrap().to_string()
    }

    // -- Well-typed terms =====================================================

    #[test]
    fn identity_infers_to_sigma_sigma() {
        // λx. x : a -> a  -- the scheme σ -> σ.
        let id = Term::abs("x", Term::var("x"));
        let ty = infer(&id).unwrap();
        assert_eq!(ty.to_string(), "a -> a");
        // Both sides of the arrow are the same schematic variable.
        assert_eq!(ty.dom(), Some(&Type::var("a")));
        assert_eq!(ty.cod(), Some(&Type::var("a")));
    }

    #[test]
    fn k_infers_to_sigma_tau_sigma() {
        // λx. λy. x : a -> b -> a  -- the scheme σ -> τ -> σ.
        let k = Term::abs("x", Term::abs("y", Term::var("x")));
        let ty = infer(&k).unwrap();
        assert_eq!(ty.to_string(), "a -> b -> a");
        // The whole result is an arrow whose codomain projects back to `a`.
        let dom = ty.dom().unwrap();
        let cod = ty.cod().unwrap();
        assert_eq!(dom, &Type::var("a"));
        assert_eq!(cod.dom().unwrap(), &Type::var("b"));
        assert_eq!(cod.cod().unwrap(), &Type::var("a"));
    }

    #[test]
    fn s_infers_to_combinator_type() {
        // λx. λy. λz. x z (y z) : (a->b->c) -> (a->b) -> a -> c
        let x = Term::var("x");
        let y = Term::var("y");
        let z = Term::var("z");
        let s = Term::abs(
            "x",
            Term::abs(
                "y",
                Term::abs("z", Term::app(Term::app(x, z.clone()), Term::app(y, z))),
            ),
        );
        assert_eq!(infer_string(&s), "(a -> b -> c) -> (a -> b) -> a -> c");
    }

    #[test]
    fn church_two_infers_to_f_nat_arrow_type() {
        // 2 = λf. λx. f (f x) : (a -> a) -> a -> a
        let f = Term::var("f");
        let x = Term::var("x");
        let two = Term::abs("f", Term::abs("x", Term::app(f.clone(), Term::app(f, x))));
        let ty = infer(&two).unwrap();
        assert_eq!(ty.to_string(), "(a -> a) -> a -> a");
    }

    #[test]
    fn application_infers_against_context() {
        // (λx. x) a with a : Nat -> Nat
        let id = Term::abs("x", Term::var("x"));
        let app = Term::app(id, Term::var("a"));
        let ctx = Context::new().extend("a", Type::nat());
        let ty = infer_in(&app, &ctx).unwrap();
        assert_eq!(ty, Type::nat());
    }

    // -- Ill-typed terms ======================================================

    #[test]
    fn self_application_is_rejected() {
        // λx. x x  -- needs σ = σ -> τ, so the occurs check fails.
        let omega = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
        match infer(&omega) {
            Err(InferError::OccursCheck { var, ty }) => {
                // `var` is the metavariable for `x`: it would have to equal a function type containing itself, σ = σ -> τ.
                assert!(var.starts_with('?'));
                assert!(ty.is_arrow());
                assert_eq!(ty.dom(), Some(&Type::Var(var.clone())));
            }
            other => panic!("expected occurs check, got {other:?}"),
        }
    }

    #[test]
    fn omega_combinator_is_rejected() {
        // Ω = (λx. x x)(λx. x x) is not typable either.
        let self_app = Term::abs("x", Term::app(Term::var("x"), Term::var("x")));
        let omega = Term::app(self_app.clone(), self_app);
        assert!(infer(&omega).is_err());
    }

    #[test]
    fn unbound_variable_is_rejected() {
        let app = Term::app(Term::abs("x", Term::var("x")), Term::var("a"));
        assert_eq!(infer(&app), Err(InferError::UnboundVariable("a".into())));
    }

    #[test]
    fn mismatched_application_is_rejected() {
        // Applying a non-function is rejected: `a : Nat`, so `a a` cannot type.
        let app = Term::app(Term::var("a"), Term::var("a"));
        let ctx = Context::new().extend("a", Type::nat());
        assert!(infer_in(&app, &ctx).is_err());
    }

    // -- Generalization =======================================================

    #[test]
    fn generalize_renames_metavars_deterministically() {
        // Re-running inference gives the same schematic names.
        let id = Term::abs("x", Term::var("x"));
        assert_eq!(infer_string(&id), "a -> a");
        assert_eq!(infer_string(&id), "a -> a");
        let k = Term::abs("x", Term::abs("y", Term::var("x")));
        assert_eq!(infer_string(&k), "a -> b -> a");
    }

    #[test]
    fn erased_application_agree_between_checking_and_inference() {
        // Checking and inference agree on well-typed annotated applications.
        // Erasing (λx:Nat. x) a gives (λx. x) a, and inferring it in the context a : Nat gives Nat, exactly what checking says.
        use crate::checker::STerm;
        use crate::ty::{Context, Type};
        let id = STerm::abs("x", Type::nat(), STerm::var("x"));
        let app = STerm::app(id, STerm::var("a"));
        let ctx = Context::new().extend("a", Type::nat());
        assert_eq!(app.check(&ctx).unwrap(), Type::nat());
        assert_eq!(infer_in(&app.erase(), &ctx).unwrap(), Type::nat());
    }
}
