//! Integration tests: evaluation matches hand calculations, and enumeration
//! decides satisfiability and validity over small domains.

use std::collections::{HashMap, HashSet};

use fol::enumerate::{domain, enumerate_structures, satisfiable_over, valid_over};
use fol::formula::{and, eq, exists, forall, implies, not, or, pred};
use fol::signature::Signature;
use fol::structure::Structure;
use fol::term::{constant, func, var};

fn rel(tuples: &[&[&str]]) -> HashSet<Vec<String>> {
    tuples
        .iter()
        .map(|t| t.iter().map(|s| s.to_string()).collect())
        .collect()
}

#[test]
fn quantifier_order_changes_truth() {
    // P(x, y) = "y is the mother of x". In a chain child -> mother ->
    // grandmother, everyone has a mother, but nobody is the mother of all.
    let everyone_has_mother = forall("x", exists("y", pred("P", vec![var("x"), var("y")])));
    let someone_mothers_all = exists("y", forall("x", pred("P", vec![var("x"), var("y")])));
    // In a three-person cycle c -> m -> g -> c every person has a mother,
    // but no single person is the mother of all three.
    let model = Structure::new(vec!["c".into(), "m".into(), "g".into()])
        .with_predicate("P", rel(&[&["c", "m"], &["m", "g"], &["g", "c"]]));
    assert!(model.eval(&everyone_has_mother).unwrap());
    assert!(!model.eval(&someone_mothers_all).unwrap());
}

#[test]
fn all_humans_mortal() {
    let formula = forall(
        "x",
        implies(
            pred("Human", vec![var("x")]),
            pred("Mortal", vec![var("x")]),
        ),
    );

    // True world: every human is mortal.
    let ok = Structure::new(vec!["socrates".into(), "zeus".into()])
        .with_predicate("Human", rel(&[&["socrates"]]))
        .with_predicate("Mortal", rel(&[&["socrates"], &["zeus"]]));
    assert!(ok.eval(&formula).unwrap());

    // Counterexample world: Zeus is human but not mortal.
    let bad = Structure::new(vec!["socrates".into(), "zeus".into()])
        .with_predicate("Human", rel(&[&["socrates"], &["zeus"]]))
        .with_predicate("Mortal", rel(&[&["socrates"]]));
    assert!(!bad.eval(&formula).unwrap());
}

#[test]
fn school_arithmetic() {
    // Signature: constant 0, function succ, predicate <=.
    let sig = Signature::new()
        .constant("0")
        .function("succ", 1)
        .predicate("<=", 2);

    // A finite analogue of N: 0 <= 1 <= 2 <= 3, with succ(3) = 3.
    let naturals = Structure::new(domain(4))
        .with_constant("0", "0")
        .with_function(
            "succ",
            HashMap::from([
                (vec!["0".to_string()], "1".to_string()),
                (vec!["1".to_string()], "2".to_string()),
                (vec!["2".to_string()], "3".to_string()),
                (vec!["3".to_string()], "3".to_string()),
            ]),
        )
        .with_predicate(
            "<=",
            rel(&[
                &["0", "0"],
                &["0", "1"],
                &["0", "2"],
                &["0", "3"],
                &["1", "1"],
                &["1", "2"],
                &["1", "3"],
                &["2", "2"],
                &["2", "3"],
                &["3", "3"],
            ]),
        );

    // succ(succ(0)) evaluates to 2.
    let two = func("succ", vec![func("succ", vec![constant("0")])]);
    assert_eq!(naturals.eval_term(&two, &HashMap::new()).unwrap(), "2");

    // ∀x (0 <= x): zero is the least element.
    let zero_least = forall("x", pred("<=", vec![constant("0"), var("x")]));
    assert!(naturals.eval(&zero_least).unwrap());

    // ∃x ∀y (x <= y): a least element exists.
    let has_least = exists("x", forall("y", pred("<=", vec![var("x"), var("y")])));
    assert!(naturals.eval(&has_least).unwrap());

    // The signature accepts the formula (symbols and arities all match).
    assert!(sig.validate(&zero_least).is_ok());
}

#[test]
fn substitution_renames_to_avoid_capture() {
    // [x := f(y)] ∀y P(x, y): the binder y is renamed so the incoming y is
    // not captured.
    let f = forall("y", pred("P", vec![var("x"), var("y")]));
    let g = func("f", vec![var("y")]);
    let result = f.substitute("x", &g);
    assert_eq!(result.to_string(), "∀y_1. P(f(y), y_1)");
    // The substituted variable stays free.
    assert!(result.free_vars().contains("y"));

    // No capture when the binder does not collide: ∀z P(x, z).
    let h = forall("z", pred("P", vec![var("x"), var("z")]));
    assert_eq!(h.substitute("x", &g).to_string(), "∀z. P(f(y), z)");
}

#[test]
fn free_variables() {
    // ∃x (P(x) ∧ Q(y)): x is bound, y is free.
    let f = exists(
        "x",
        and(pred("P", vec![var("x")]), pred("Q", vec![var("y")])),
    );
    assert_eq!(f.free_vars().len(), 1);
    assert!(f.free_vars().contains("y"));
    assert!(!f.free_vars().contains("x"));
}

#[test]
fn equality_is_identity_on_the_domain() {
    let sig = Signature::new().constant("a").constant("b");
    let m = Structure::new(vec!["0".into(), "1".into()])
        .with_constant("a", "0")
        .with_constant("b", "0");
    // a = b is true: both constants denote the same domain element.
    let f = eq(constant("a"), constant("b"));
    assert!(m.eval(&f).unwrap());
    assert!(sig.validate(&f).is_ok());
}

#[test]
fn excluded_middle_is_valid_over_finite_domains() {
    let sig = Signature::new().predicate("P", 1);
    let lem = forall(
        "x",
        or(pred("P", vec![var("x")]), not(pred("P", vec![var("x")]))),
    );

    assert_eq!(enumerate_structures(&sig, &domain(1)).len(), 2);
    assert_eq!(enumerate_structures(&sig, &domain(2)).len(), 4);
    assert!(valid_over(&sig, &lem, &domain(1)));
    assert!(valid_over(&sig, &lem, &domain(2)));
}

#[test]
fn some_p_is_satisfiable_but_not_valid() {
    let sig = Signature::new().predicate("P", 1);
    let some_p = exists("x", pred("P", vec![var("x")]));
    let d = domain(2);

    assert!(satisfiable_over(&sig, &some_p, &d).is_some());
    assert!(!valid_over(&sig, &some_p, &d));
}

#[test]
fn arity_mismatch_is_rejected() {
    let sig = Signature::new().predicate("P", 2);
    let bad = pred("P", vec![var("x")]); // P declared binary, used unary.
    assert!(sig.validate(&bad).is_err());
}
