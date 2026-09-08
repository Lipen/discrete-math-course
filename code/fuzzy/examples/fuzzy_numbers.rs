//! Fuzzy numbers: membership, alpha-cuts, arithmetic, and reconstruction
//! from alpha-cuts (the decomposition theorem).

use fuzzy::{FuzzySet, Triangular};

fn main() {
    println!("Triangular fuzzy numbers and alpha-cuts");
    println!("=======================================");
    let a = Triangular::new(1.0, 2.0, 3.0); // "about 2"
    let b = Triangular::new(4.0, 5.0, 6.0); // "about 5"
    println!("A = (1, 2, 3)  ~ 'about 2'");
    println!("B = (4, 5, 6)  ~ 'about 5'");
    println!();
    println!("membership of A:");
    for x in [0.0, 1.5, 2.0, 2.5, 4.0] {
        println!("  mu_A({x}) = {:.3}", a.membership(x));
    }
    println!();
    println!("alpha-cuts of A:");
    for alpha in [0.0, 0.25, 0.5, 1.0] {
        let (l, r) = a.alpha_cut(alpha);
        println!("  A_{alpha} = [{l:.2}, {r:.2}]");
    }
    println!();
    println!("arithmetic (componentwise on alpha-cuts):");
    let sum = a.add(b);
    let diff = a.sub(b);
    let prod = a.mul(b);
    println!("  A + B = ({}, {}, {})", sum.left, sum.mode, sum.right);
    println!("  A - B = ({}, {}, {})", diff.left, diff.mode, diff.right);
    println!("  A * B ~= ({}, {}, {})", prod.left, prod.mode, prod.right);
    println!();
    println!("A + B is 'about 7': mu(7) = {:.3}", sum.membership(7.0));
    println!();

    println!("Reconstructing 'young' from its alpha-cuts");
    println!("==========================================");
    let young = FuzzySet::new(vec![(0.0, 1.0), (25.0, 1.0), (40.0, 0.0), (100.0, 0.0)]);
    println!("young = 1 below 25, falls to 0 at 40 (universe [0, 100])");
    println!(
        "  support = {:?}  core = {:?}  height = {}",
        young.support(),
        young.core(),
        young.height()
    );
    println!();
    let levels: Vec<f64> = (0..=20).map(|i| i as f64 / 20.0).collect();
    println!(
        "decomposition at x = 30 (mu_young(30) = 2/3 ~= {:.3}):",
        young.membership(30.0)
    );
    let recovered = young.decompose_at(30.0, &levels);
    println!("  sup {{ alpha : 30 in A_alpha }} = {:.3}", recovered);
    println!(
        "  levels containing 30: {}",
        levels
            .iter()
            .filter(|&&a| young.membership(30.0) >= a)
            .count()
    );
}
