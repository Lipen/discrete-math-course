//! Print the distributions and a covariance example.
//!
//! The Poisson example uses three calls per minute.
//! The covariance example shows two dependent variables whose covariance is still zero.

use probability::{correlation, covariance, Distribution};

fn main() {
    let distributions = [
        ("Bernoulli(0.25)", Distribution::Bernoulli { p: 0.25 }),
        (
            "Binomial(10, 0.3)",
            Distribution::Binomial { n: 10, p: 0.3 },
        ),
        ("Geometric(0.2)", Distribution::Geometric { p: 0.2 }),
        ("Poisson(3)", Distribution::Poisson { lambda: 3.0 }),
    ];

    println!("distribution        P(X=0)   P(X=1)   mean    variance");
    for (name, d) in distributions {
        println!(
            "{name:18} {:8.4} {:8.4} {:7.3} {:9.3}",
            d.pmf(0),
            d.pmf(1),
            d.mean(),
            d.variance()
        );
    }

    let calls = Distribution::Poisson { lambda: 3.0 };
    println!();
    println!("Poisson(3): P(X=5) = {:.4}", calls.pmf(5));
    println!(
        "Poisson(3): P(X<=2) = {:.4}",
        (0..=2).map(|k| calls.pmf(k)).sum::<f64>()
    );

    let xs = [-1.0, 0.0, 1.0];
    let ys = [1.0, 0.0, 1.0];
    println!();
    println!("covariance = {:?}", covariance(&xs, &ys));
    println!("correlation = {:?}", correlation(&xs, &ys));
}
