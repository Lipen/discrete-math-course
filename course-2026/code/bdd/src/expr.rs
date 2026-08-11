use crate::bdd::{Bdd, Edge, TRUE};

/// A boolean expression over named variables `x_0, x_1, ...`.
///
/// Convert any expression to a BDD via [`Expr::to_bdd`] and then use the
/// BDD operations -- evaluation, satisfiability, counting -- on the result.
///
/// ```
/// use bdd::{Bdd, Expr};
///
/// let mut bdd = Bdd::new();
/// let x = Expr::var(0);
/// let y = Expr::var(1);
///
/// // x XOR y
/// let xor = Expr::xor(x.clone(), y.clone());
/// let f = xor.to_bdd(&mut bdd);
/// assert!(!bdd.eval(f, &[false, false]));
/// assert!(bdd.eval(f, &[false, true]));
/// ```
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum Expr {
    /// A single variable `x_i`.
    Var(u32),
    /// `¬e`
    Not(Box<Expr>),
    /// `a ∧ b`
    And(Box<Expr>, Box<Expr>),
    /// `a ∨ b`
    Or(Box<Expr>, Box<Expr>),
    /// `a ⊕ b`
    Xor(Box<Expr>, Box<Expr>),
    /// `a → b`
    Implies(Box<Expr>, Box<Expr>),
}

impl Expr {
    /// A single variable `x_i`.
    ///
    /// ```
    /// use bdd::Expr;
    ///
    /// let x0 = Expr::var(0);
    /// assert_eq!(x0, Expr::Var(0));
    /// ```
    pub fn var(i: u32) -> Expr {
        Expr::Var(i)
    }

    /// `¬self`
    ///
    /// ```
    /// use bdd::Expr;
    ///
    /// let x = Expr::var(0);
    /// let nx = x.clone().not_();
    /// assert_eq!(nx, Expr::Not(Box::new(Expr::Var(0))));
    /// ```
    pub fn not_(self) -> Expr {
        Expr::Not(Box::new(self))
    }

    /// `self ∧ other`
    ///
    /// ```
    /// use bdd::Expr;
    ///
    /// let e = Expr::var(0).and(Expr::var(1));
    /// assert_eq!(e, Expr::And(Box::new(Expr::Var(0)), Box::new(Expr::Var(1))));
    /// ```
    pub fn and(self, other: Expr) -> Expr {
        Expr::And(Box::new(self), Box::new(other))
    }

    /// `self ∨ other`
    ///
    /// ```
    /// use bdd::Expr;
    ///
    /// let e = Expr::var(0).or(Expr::var(1));
    /// assert_eq!(e, Expr::Or(Box::new(Expr::Var(0)), Box::new(Expr::Var(1))));
    /// ```
    pub fn or(self, other: Expr) -> Expr {
        Expr::Or(Box::new(self), Box::new(other))
    }

    /// `self ⊕ other`
    ///
    /// ```
    /// use bdd::Expr;
    ///
    /// let e = Expr::var(0).xor(Expr::var(1));
    /// assert_eq!(e, Expr::Xor(Box::new(Expr::Var(0)), Box::new(Expr::Var(1))));
    /// ```
    pub fn xor(self, other: Expr) -> Expr {
        Expr::Xor(Box::new(self), Box::new(other))
    }

    /// `self → other`
    ///
    /// ```
    /// use bdd::Expr;
    ///
    /// let e = Expr::var(0).implies(Expr::var(1));
    /// assert_eq!(e, Expr::Implies(Box::new(Expr::Var(0)), Box::new(Expr::Var(1))));
    /// ```
    pub fn implies(self, other: Expr) -> Expr {
        Expr::Implies(Box::new(self), Box::new(other))
    }

    /// Build the BDD for this expression using the given manager.
    ///
    /// ```
    /// use bdd::{Bdd, Expr};
    ///
    /// let mut bdd = Bdd::new();
    /// let x = Expr::var(0);
    /// let y = Expr::var(1);
    ///
    /// // x -> y  =  ¬x ∨ y
    /// let imp = x.clone().implies(y.clone());
    /// let f = imp.to_bdd(&mut bdd);
    /// assert!(!bdd.eval(f, &[true, false])); // T -> F
    /// assert!(bdd.eval(f, &[false, false])); // F -> F
    /// ```
    pub fn to_bdd(&self, bdd: &mut Bdd) -> Edge {
        match self {
            Expr::Var(i) => bdd.var(*i),
            Expr::Not(e) => {
                let child = e.to_bdd(bdd);
                bdd.not(child)
            }
            Expr::And(a, b) => {
                let fa = a.to_bdd(bdd);
                let fb = b.to_bdd(bdd);
                bdd.and(fa, fb)
            }
            Expr::Or(a, b) => {
                let fa = a.to_bdd(bdd);
                let fb = b.to_bdd(bdd);
                bdd.or(fa, fb)
            }
            Expr::Xor(a, b) => {
                let fa = a.to_bdd(bdd);
                let fb = b.to_bdd(bdd);
                bdd.xor(fa, fb)
            }
            Expr::Implies(a, b) => {
                // a -> b  =  ¬a ∨ b  =  ite(a, b, TRUE)
                let fa = a.to_bdd(bdd);
                let fb = b.to_bdd(bdd);
                bdd.ite(fa, fb, TRUE)
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn expr_var_to_bdd() {
        let mut bdd = Bdd::new();
        let e = Expr::var(0);
        let f = e.to_bdd(&mut bdd);
        assert!(!bdd.eval(f, &[false]));
        assert!(bdd.eval(f, &[true]));
    }

    #[test]
    fn expr_xor_matches_manual() {
        let mut bdd = Bdd::new();
        let e = Expr::var(0).xor(Expr::var(1));
        let f = e.to_bdd(&mut bdd);

        let mut bdd2 = Bdd::new();
        let x = bdd2.var(0);
        let y = bdd2.var(1);
        let g = bdd2.xor(x, y);

        // Same function, potentially different managers -- the edges
        // won't be equal, but the truth tables must match.
        for a in [false, true] {
            for b in [false, true] {
                assert_eq!(bdd.eval(f, &[a, b]), bdd2.eval(g, &[a, b]));
            }
        }
    }

    #[test]
    fn expr_implies_is_implication() {
        let mut bdd = Bdd::new();
        let e = Expr::var(0).implies(Expr::var(1));
        let f = e.to_bdd(&mut bdd);
        // x->y is false only when x=true, y=false.
        assert!(!bdd.eval(f, &[true, false]));
        assert!(bdd.eval(f, &[true, true]));
        assert!(bdd.eval(f, &[false, false]));
        assert!(bdd.eval(f, &[false, true]));
    }

    #[test]
    fn equivalent_expressions_produce_same_edge() {
        let mut bdd = Bdd::new();
        // x -> y
        let imp = Expr::var(0).implies(Expr::var(1));
        // ¬x ∨ y
        let alt = Expr::var(0).not_().or(Expr::var(1));

        let f1 = imp.to_bdd(&mut bdd);
        let f2 = alt.to_bdd(&mut bdd);
        // Same BDD manager, same function => same edge.
        assert_eq!(f1, f2);
    }

    #[test]
    fn double_negation_is_original() {
        let mut bdd = Bdd::new();
        let e = Expr::var(0).not_().not_();
        let f = e.to_bdd(&mut bdd);
        assert!(!bdd.eval(f, &[false]));
        assert!(bdd.eval(f, &[true]));
    }

    #[test]
    fn complex_expr_tautology() {
        let mut bdd = Bdd::new();
        // (x -> y) ∧ (y -> z) -> (x -> z)  -- transitivity of implication
        let x = Expr::var(0);
        let y = Expr::var(1);
        let z = Expr::var(2);
        let premise = x
            .clone()
            .implies(y.clone())
            .and(y.clone().implies(z.clone()));
        let conclusion = x.implies(z);
        let formula = premise.implies(conclusion);
        let f = formula.to_bdd(&mut bdd);
        assert!(Bdd::is_tautology(f));
    }
}
