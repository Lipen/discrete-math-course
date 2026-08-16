//! Abstract interpretation: abstract domains, transfer functions, widening.
//!
//! Implements the theory from the abstract-interpretation chapter: the sign,
//! interval, and constant domains; abstract arithmetic on them; and transfer
//! functions over a tiny imperative program. Loops are analyzed by computing a
//! fixpoint; on the infinite interval and constant domains widening makes the
//! iteration converge.

pub mod domains;
pub mod program;

pub use domains::{Const, Interval, Sign};

#[cfg(test)]
mod tests {
    use program::{
        assign, eval_interval, exec_const, exec_interval, exec_sign, inc, Expr, State, Stmt,
    };

    use super::*;

    // ── Sign domain tests ──

    #[test]
    fn sign_of_concrete() {
        assert_eq!(Sign::of(-5), Sign::Neg);
        assert_eq!(Sign::of(0), Sign::Zero);
        assert_eq!(Sign::of(42), Sign::Pos);
    }

    #[test]
    fn sign_lub_table() {
        use Sign::*;
        // Same → identity.
        assert_eq!(Pos.lub(Pos), Pos);
        assert_eq!(Neg.lub(Neg), Neg);
        assert_eq!(Zero.lub(Zero), Zero);
        assert_eq!(Top.lub(Top), Top);
        assert_eq!(Bottom.lub(Bottom), Bottom);
        // Bottom is unit.
        assert_eq!(Bottom.lub(Pos), Pos);
        assert_eq!(Neg.lub(Bottom), Neg);
        // Different → Top.
        assert_eq!(Pos.lub(Neg), Top);
        assert_eq!(Pos.lub(Zero), Top);
        assert_eq!(Neg.lub(Zero), Top);
    }

    #[test]
    fn sign_addition_table() {
        use Sign::*;
        // Basic rules.
        assert_eq!(Pos + Pos, Pos);
        assert_eq!(Neg + Neg, Neg);
        assert_eq!(Zero + Pos, Pos);
        assert_eq!(Neg + Zero, Neg);
        // Mixed → Top.
        assert_eq!(Pos + Neg, Top);
        assert_eq!(Neg + Pos, Top);
        // Top and Bottom.
        assert_eq!(Top + Pos, Top);
        assert_eq!(Bottom + Pos, Bottom);
        assert_eq!(Pos + Bottom, Bottom);
    }

    #[test]
    fn sign_multiplication_table() {
        use Sign::*;
        assert_eq!(Pos * Pos, Pos);
        assert_eq!(Neg * Neg, Pos);
        assert_eq!(Pos * Neg, Neg);
        assert_eq!(Neg * Pos, Neg);
        assert_eq!(Zero * Pos, Zero);
        assert_eq!(Zero * Top, Zero);
        assert_eq!(Top * Zero, Zero);
        assert_eq!(Top * Pos, Top);
        assert_eq!(Bottom * Neg, Bottom);
    }

    #[test]
    fn sign_negation() {
        assert_eq!(-Sign::Pos, Sign::Neg);
        assert_eq!(-Sign::Neg, Sign::Pos);
        assert_eq!(-Sign::Zero, Sign::Zero);
        assert_eq!(-Sign::Top, Sign::Top);
        assert_eq!(-Sign::Bottom, Sign::Bottom);
    }

    #[test]
    fn sign_merge_of_branches_gives_top() {
        // if b then y := 1 else y := -1: y = + ⊔ − = ⊤.
        let program = vec![Stmt::If {
            then: vec![assign("y", 1)],
            els: vec![assign("y", -1)],
        }];
        let mut st: State<Sign> = State::new();
        exec_sign(&program, &mut st);
        assert_eq!(st["y"], Sign::Top);
    }

    #[test]
    fn sign_nested_if_different_signs_go_top() {
        // if ... then (if ... then x := 1 else x := -1) else x := 0
        // Inner if: x = + ⊔ − = ⊤
        // Outer if: x = ⊤ ⊔ 0 = ⊤
        let program = vec![Stmt::If {
            then: vec![Stmt::If {
                then: vec![assign("x", 1)],
                els: vec![assign("x", -1)],
            }],
            els: vec![assign("x", 0)],
        }];
        let mut st: State<Sign> = State::new();
        exec_sign(&program, &mut st);
        assert_eq!(st["x"], Sign::Top);
    }

    #[test]
    fn sign_while_oscillating_body_converges_to_top() {
        // i := 1; while ... do i := -i: the sign alternates +, −, +, ... Plain
        // iteration would oscillate; Kleene iteration joins with the loop-head
        // state and reaches ⊤ in two passes.
        let program = vec![
            assign("i", 1),
            Stmt::While {
                body: vec![Stmt::Assign(
                    "i".into(),
                    Expr::Neg(Box::new(Expr::Var("i".into()))),
                )],
            },
        ];
        let mut st: State<Sign> = State::new();
        exec_sign(&program, &mut st);
        assert_eq!(st["i"], Sign::Top);
    }

    #[test]
    fn sign_while_counter_stays_positive() {
        // i := 1; while ... do i := i + 1  →  i stays +.
        let program = vec![
            assign("i", 1),
            Stmt::While {
                body: vec![inc("i")],
            },
        ];
        let mut st: State<Sign> = State::new();
        exec_sign(&program, &mut st);
        assert_eq!(st["i"], Sign::Pos);
    }

    #[test]
    fn interval_narrow_refines_only_unbounded_ends() {
        // [0, +∞) ▲ [1, 4] = [0, 4] -- the upper bound becomes finite.
        let wide = Interval::Range {
            lo: Some(0),
            hi: None,
        };
        let finite = Interval::Range {
            lo: Some(1),
            hi: Some(4),
        };
        assert_eq!(
            wide.narrow(finite),
            Interval::Range {
                lo: Some(0),
                hi: Some(4)
            }
        );
        // Finite bounds survive narrowing.
        let point = Interval::point(3);
        assert_eq!(point.narrow(Interval::top()), point);
    }

    // ── Interval domain tests ──

    #[test]
    fn interval_lub_covers_both() {
        let a = Interval::Range {
            lo: Some(1),
            hi: Some(3),
        };
        let b = Interval::Range {
            lo: Some(2),
            hi: Some(5),
        };
        assert_eq!(
            a.lub(b),
            Interval::Range {
                lo: Some(1),
                hi: Some(5)
            }
        );
        // Bottom is neutral.
        assert_eq!(Interval::Bottom.lub(b), b);
    }

    #[test]
    fn interval_addition() {
        let a = Interval::Range {
            lo: Some(1),
            hi: Some(3),
        };
        let b = Interval::Range {
            lo: Some(5),
            hi: Some(7),
        };
        assert_eq!(
            a + b,
            Interval::Range {
                lo: Some(6),
                hi: Some(10)
            }
        );
    }

    #[test]
    fn interval_negation_flips_ends() {
        let a = Interval::Range {
            lo: Some(1),
            hi: Some(5),
        };
        assert_eq!(
            -a,
            Interval::Range {
                lo: Some(-5),
                hi: Some(-1)
            }
        );
        // Negating an unbounded interval.
        let top = Interval::top();
        assert_eq!(-top, Interval::top());
        // Negating Bottom.
        assert_eq!(-Interval::Bottom, Interval::Bottom);
    }

    #[test]
    fn interval_multiplication_bounded() {
        let a = Interval::Range {
            lo: Some(-2),
            hi: Some(3),
        };
        let b = Interval::Range {
            lo: Some(4),
            hi: Some(5),
        };
        // Products: -8, -10, 12, 15 → min = -10, max = 15.
        assert_eq!(
            a * b,
            Interval::Range {
                lo: Some(-10),
                hi: Some(15)
            }
        );
    }

    #[test]
    fn interval_multiplication_unbounded_gives_top() {
        let a = Interval::Range {
            lo: Some(1),
            hi: Some(3),
        };
        assert_eq!(Interval::top() * a, Interval::top());
        assert_eq!(a * Interval::top(), Interval::top());
    }

    #[test]
    fn interval_multiplication_bottom_is_zero() {
        let a = Interval::Range {
            lo: Some(1),
            hi: Some(2),
        };
        assert_eq!(Interval::Bottom * a, Interval::Bottom);
        assert_eq!(a * Interval::Bottom, Interval::Bottom);
    }

    #[test]
    fn interval_analysis_finds_bounds() {
        // x := 3; y := 5; z := x + y  →  z = [8, 8].
        let program = vec![assign("x", 3), assign("y", 5)];
        let mut st: State<Interval> = State::new();
        exec_interval(&program, &mut st);
        let z = eval_interval(
            &Expr::Add(
                Box::new(Expr::Var("x".into())),
                Box::new(Expr::Var("y".into())),
            ),
            &st,
        );
        assert_eq!(z, Interval::point(8));
    }

    #[test]
    fn interval_if_merge_joins_branches() {
        // if ... then x := 1 else x := 5; y := x + 2
        // x = [1,1] ⊔ [5,5] = [1,5]; y = [1,5] + [2,2] = [3,7]
        let program = vec![
            Stmt::If {
                then: vec![assign("x", 1)],
                els: vec![assign("x", 5)],
            },
            Stmt::Assign(
                "y".into(),
                Expr::Add(Box::new(Expr::Var("x".into())), Box::new(Expr::Const(2))),
            ),
        ];
        let mut st: State<Interval> = State::new();
        exec_interval(&program, &mut st);
        assert_eq!(
            st["x"],
            Interval::Range {
                lo: Some(1),
                hi: Some(5)
            }
        );
        assert_eq!(
            st["y"],
            Interval::Range {
                lo: Some(3),
                hi: Some(7)
            }
        );
    }

    #[test]
    fn interval_widening_converges_on_counter_loop() {
        // i := 0; while ... do i := i + 1  →  i ∈ [0, +∞).
        let program = vec![
            assign("i", 0),
            Stmt::While {
                body: vec![inc("i")],
            },
        ];
        let mut st: State<Interval> = State::new();
        exec_interval(&program, &mut st);
        assert_eq!(
            st["i"],
            Interval::Range {
                lo: Some(0),
                hi: None
            }
        );
    }

    #[test]
    fn interval_widening_stable_bound_kept() {
        // A bound that did not move is kept.
        let a = Interval::Range {
            lo: Some(0),
            hi: Some(5),
        };
        let b = Interval::Range {
            lo: Some(0),
            hi: Some(5),
        };
        assert_eq!(a.widen(b), a);
    }

    #[test]
    fn interval_widening_from_bottom() {
        assert_eq!(
            Interval::Bottom.widen(Interval::point(3)),
            Interval::point(3)
        );
    }

    // ── Const domain tests ──

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
    fn const_widen_stable() {
        assert_eq!(Const::Val(0).widen(Const::Val(0)), Const::Val(0));
    }

    #[test]
    fn const_widen_changed_goes_top() {
        // The value changed, so widening jumps to ⊤.
        assert_eq!(Const::Val(0).widen(Const::Val(1)), Const::Top);
        assert_eq!(Const::Val(5).widen(Const::Val(-3)), Const::Top);
    }

    #[test]
    fn const_widen_from_bottom() {
        assert_eq!(Const::Bottom.widen(Const::Val(5)), Const::Val(5));
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
    fn const_while_widening_converges() {
        // i := 0; while ... do i := i + 1.
        // After first pass: i = 0 → 1. Widen: 0 ∇ 1 = ⊤. Second pass: ⊤ stays ⊤.
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
