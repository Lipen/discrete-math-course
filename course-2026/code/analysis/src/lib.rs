//! Abstract interpretation: abstract domains, transfer functions, widening.
//!
//! Implements the theory from the abstract-interpretation chapter: the sign,
//! interval, and constant domains; abstract arithmetic on them; and transfer
//! functions over a tiny imperative program. Loops are analyzed by computing a
//! fixpoint; on the infinite interval domain widening makes the iteration
//! converge.

pub mod domains;
pub mod program;

pub use domains::{Interval, Sign};

#[cfg(test)]
mod tests {
    use super::*;
    use program::{assign, eval_interval, exec_interval, exec_sign, inc, State};

    #[test]
    fn sign_addition_is_imprecise_for_mixed() {
        // + ⊞ − = ⊤ from the chapter.
        assert_eq!(Sign::Pos + Sign::Neg, Sign::Top);
        assert_eq!(Sign::Pos + Sign::Pos, Sign::Pos);
        assert_eq!(Sign::Neg + Sign::Zero, Sign::Neg);
        assert_eq!(Sign::Top + Sign::Pos, Sign::Top);
    }

    #[test]
    fn sign_merge_of_branches_gives_top() {
        // if b then y := 1 else y := -1: y = + ⊔ − = ⊤.
        let program = vec![program::Stmt::If {
            then: vec![assign("y", 1)],
            els: vec![assign("y", -1)],
        }];
        let mut st: State<Sign> = State::new();
        exec_sign(&program, &mut st);
        assert_eq!(st["y"], Sign::Top);
    }

    #[test]
    fn interval_analysis_finds_bounds() {
        // x := 3; y := 5; z := x + y  →  z = [8, 8].
        let program = vec![assign("x", 3), assign("y", 5)];
        let mut st: State<Interval> = State::new();
        exec_interval(&program, &mut st);
        let z = eval_interval(
            &program::Expr::Add(
                Box::new(program::Expr::Var("x".into())),
                Box::new(program::Expr::Var("y".into())),
            ),
            &st,
        );
        assert_eq!(z, Interval::point(8));
    }

    #[test]
    fn interval_widening_converges_on_the_counter_loop() {
        // i := 0; while ... do i := i + 1  →  i ∈ [0, +∞).
        let program = vec![
            assign("i", 0),
            program::Stmt::While {
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
    fn widening_drops_moved_bound() {
        // [0, 0] ∇ [0, 1] = [0, +∞).
        let a = Interval::point(0);
        let b = Interval::Range {
            lo: Some(0),
            hi: Some(1),
        };
        assert_eq!(
            a.widen(b),
            Interval::Range {
                lo: Some(0),
                hi: None
            }
        );
    }
}
