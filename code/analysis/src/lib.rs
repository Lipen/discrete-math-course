//! Abstract interpretation: the constant domain, transfer functions, and
//! fixed-point iteration.
//!
//! A tiny imperative program is analyzed on abstract values: the constant
//! domain tracks which variables hold a known integer (⊥ is unreachable, ⊤ is
//! "not a constant"). Assignments evaluate expressions abstractly, `If` merges
//! both branches with the join ⊔, and `While` loops are analyzed by Kleene
//! iteration to a fixpoint.

pub mod domains;
pub mod program;

pub use domains::Const;

#[cfg(test)]
mod tests {
    use program::{assign, exec_const, inc, Expr, State, Stmt};

    use super::*;

    #[test]
    fn const_of_concrete() {
        assert_eq!(Const::of(42), Const::Val(42));
        assert_eq!(Const::of(0), Const::Val(0));
        assert_eq!(Const::of(-7), Const::Val(-7));
    }

    #[test]
    fn const_lub_same_stays() {
        assert_eq!(Const::Val(5).lub(Const::Val(5)), Const::Val(5));
    }

    #[test]
    fn const_lub_different_goes_top() {
        assert_eq!(Const::Val(1).lub(Const::Val(2)), Const::Top);
    }

    #[test]
    fn const_lub_bottom_neutral() {
        assert_eq!(Const::Bottom.lub(Const::Val(7)), Const::Val(7));
        assert_eq!(Const::Val(7).lub(Const::Bottom), Const::Val(7));
    }

    #[test]
    fn const_addition_known() {
        assert_eq!(Const::Val(3) + Const::Val(5), Const::Val(8));
    }

    #[test]
    fn const_addition_unknown() {
        assert_eq!(Const::Val(3) + Const::Top, Const::Top);
        assert_eq!(Const::Bottom + Const::Val(1), Const::Bottom);
    }

    #[test]
    fn const_multiplication_zero_kills_uncertainty() {
        // 0 * anything = 0, even when the other operand is unknown.
        assert_eq!(Const::Val(0) * Const::Top, Const::Val(0));
        assert_eq!(Const::Top * Const::Val(0), Const::Val(0));
        assert_eq!(Const::Val(0) * Const::Val(5), Const::Val(0));
    }

    #[test]
    fn const_multiplication_nonzero_unknown() {
        assert_eq!(Const::Val(7) * Const::Top, Const::Top);
    }

    #[test]
    fn const_multiplication_known() {
        assert_eq!(Const::Val(6) * Const::Val(7), Const::Val(42));
    }

    #[test]
    fn const_negation() {
        assert_eq!(-Const::Val(5), Const::Val(-5));
        assert_eq!(-Const::Top, Const::Top);
        assert_eq!(-Const::Bottom, Const::Bottom);
    }

    #[test]
    fn const_program_basic() {
        // x := 5; y := x + 3.
        let program = vec![
            assign("x", 5),
            Stmt::Assign(
                "y".into(),
                Expr::Add(Box::new(Expr::Var("x".into())), Box::new(Expr::Const(3))),
            ),
        ];
        let mut st: State<Const> = State::new();
        exec_const(&program, &mut st);
        assert_eq!(st["x"], Const::Val(5));
        assert_eq!(st["y"], Const::Val(8));
    }

    #[test]
    fn const_program_branch_loses_precision() {
        // if ... then w := 1 else w := 2.
        let program = vec![Stmt::If {
            then: vec![assign("w", 1)],
            els: vec![assign("w", 2)],
        }];
        let mut st: State<Const> = State::new();
        exec_const(&program, &mut st);
        // 1 ⊔ 2 = ⊤.
        assert_eq!(st["w"], Const::Top);
    }

    #[test]
    fn const_program_zero_times_branch_result() {
        // x := 0; if ... then y := 1 else y := 2; z := x * y
        // After branch: y = ⊤. But x = 0, so z = 0 * ⊤ = 0.
        let program = vec![
            assign("x", 0),
            Stmt::If {
                then: vec![assign("y", 1)],
                els: vec![assign("y", 2)],
            },
            Stmt::Assign(
                "z".into(),
                Expr::Mul(
                    Box::new(Expr::Var("x".into())),
                    Box::new(Expr::Var("y".into())),
                ),
            ),
        ];
        let mut st: State<Const> = State::new();
        exec_const(&program, &mut st);
        assert_eq!(st["x"], Const::Val(0));
        assert_eq!(st["y"], Const::Top);
        // 0 * ⊤ = 0 -- the key insight.
        assert_eq!(st["z"], Const::Val(0));
    }

    #[test]
    fn const_while_kleene_converges() {
        // i := 0; while ... do i := i + 1.
        // First pass: i = 0 -> 1, joined with the loop-head value 0 gives ⊤.
        // Second pass: ⊤ stays ⊤, so the iteration stabilizes.
        let program = vec![
            assign("i", 0),
            Stmt::While {
                body: vec![inc("i")],
            },
        ];
        let mut st: State<Const> = State::new();
        exec_const(&program, &mut st);
        assert_eq!(st["i"], Const::Top);
    }
}
