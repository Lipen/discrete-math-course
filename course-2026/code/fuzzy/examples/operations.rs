//! Zadeh operations, the three t-norm families, and the failure of the law
//! of the excluded middle.

use fuzzy::{FuzzySet, TNorm};

/// A short readable rendering of a piecewise-linear set's breakpoints.
fn fmt(set: &FuzzySet) -> String {
    set.points
        .iter()
        .map(|&(x, y)| format!("({x:.2}, {y:.2})"))
        .collect::<Vec<_>>()
        .join(" ")
}

fn main() {
    // "high" and "middle" height, on the universe [140, 210].
    let high = FuzzySet::new(vec![(140.0, 0.0), (160.0, 0.0), (190.0, 1.0), (210.0, 1.0)]);
    let middle = FuzzySet::new(vec![
        (140.0, 0.0),
        (160.0, 1.0),
        (170.0, 1.0),
        (180.0, 0.0),
        (210.0, 0.0),
    ]);

    println!("Zadeh operations on 'high' and 'middle' height");
    println!("===============================================");
    println!("high   = {}", fmt(&high));
    println!("middle = {}", fmt(&middle));
    println!();

    let x = 175.0;
    println!("at x = {x} cm:");
    println!("  mu_high   = {:.3}", high.membership(x));
    println!("  mu_middle = {:.3}", middle.membership(x));
    let inter = high.intersection(&middle);
    let union = high.union(&middle);
    println!();
    println!("intersection (min) = {}", fmt(&inter));
    println!("  mu_(high ∩ middle)({x}) = {:.3}", inter.membership(x));
    println!("union (max)        = {}", fmt(&union));
    println!("  mu_(high ∪ middle)({x}) = {:.3}", union.membership(x));
    println!();

    println!("complement of 'high': 1 - mu_high");
    for h in [150.0, 175.0, 200.0] {
        let c = high.complement();
        println!(
            "  mu_high({h}) = {:.3}, mu_not_high({h}) = {:.3}",
            high.membership(h),
            c.membership(h)
        );
    }
    println!();

    // De Morgan: not(A ∪ B) = not A ∩ not B, checked pointwise.
    let left = union.complement();
    let right = high.complement().intersection(&middle.complement());
    let mut de_morgan = true;
    for i in 0..=20 {
        let h = 140.0 + 70.0 * i as f64 / 20.0;
        if (left.membership(h) - right.membership(h)).abs() > 1e-9 {
            de_morgan = false;
        }
    }
    println!("De Morgan holds for these sets (sampled): {de_morgan}");
    println!();

    // The law of the excluded middle fails.
    let ramp = FuzzySet::new(vec![(0.0, 0.0), (1.0, 1.0)]); // mu(x) = x
    let not_ramp = ramp.complement(); // mu(x) = 1 - x
    let a = 0.6;
    let l_union = ramp.union(&not_ramp);
    let l_inter = ramp.intersection(&not_ramp);
    println!("excluded middle and contradiction on mu(x) = x at x = {a}:");
    println!(
        "  mu(A ∪ ¬A) = max(0.6, 0.4) = {:.1}  (not 1)",
        l_union.membership(a)
    );
    println!(
        "  mu(A ∩ ¬A) = min(0.6, 0.4) = {:.1}  (not 0)",
        l_inter.membership(a)
    );
    println!();

    // The three t-norm families on one pair of degrees.
    println!("three t-norms on a = 0.6, b = 0.7:");
    for t in [TNorm::Zadeh, TNorm::Product, TNorm::Lukasiewicz] {
        println!(
            "  {:>24}: I = {:.3}, U = {:.3}",
            t.name(),
            t.norm(0.6, 0.7),
            t.conorm(0.6, 0.7)
        );
    }
    println!("  A ∧ ¬A for a = 0.6 ->");
    for t in [TNorm::Zadeh, TNorm::Product, TNorm::Lukasiewicz] {
        println!("    {:>24}: {:.3}", t.name(), t.norm(0.6, 0.4));
    }
}
