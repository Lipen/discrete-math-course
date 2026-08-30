//! A Mamdani air-conditioner controller.
//!
//! Four temperature terms (cold, comfortable, warm, hot) drive three cooling
//! terms (off, low, strong) through a small rule base. The demo fuzzifies a
//! crisp temperature, fires every rule proportionally, aggregates the clipped
//! consequents, defuzzifies with three methods, and then sweeps the input to
//! show that the response surface is smooth -- no threshold jumps.

use fuzzy::{Defuzzifier, FuzzySet, Mamdani, Rule, TNorm, Term, Variable};

/// The air-conditioner system: `temperature` -> `cooling`.
fn ac() -> Mamdani {
    let temperature = Variable {
        name: "temperature",
        terms: vec![
            Term {
                name: "cold",
                set: FuzzySet::new(vec![(0.0, 1.0), (15.0, 1.0), (20.0, 0.0), (40.0, 0.0)]),
            },
            Term {
                name: "comfortable",
                set: FuzzySet::new(vec![
                    (0.0, 0.0),
                    (15.0, 0.0),
                    (20.0, 1.0),
                    (24.0, 1.0),
                    (28.0, 0.0),
                    (40.0, 0.0),
                ]),
            },
            Term {
                name: "warm",
                set: FuzzySet::new(vec![
                    (0.0, 0.0),
                    (18.0, 0.0),
                    (24.0, 1.0),
                    (34.0, 0.0),
                    (40.0, 0.0),
                ]),
            },
            Term {
                name: "hot",
                set: FuzzySet::new(vec![(0.0, 0.0), (25.0, 0.0), (30.0, 1.0), (40.0, 1.0)]),
            },
        ],
    };
    let cooling = Variable {
        name: "cooling",
        terms: vec![
            Term {
                name: "off",
                set: FuzzySet::new(vec![(0.0, 1.0), (20.0, 0.0), (100.0, 0.0)]),
            },
            Term {
                name: "low",
                set: FuzzySet::new(vec![
                    (0.0, 0.0),
                    (10.0, 0.0),
                    (35.0, 1.0),
                    (60.0, 0.0),
                    (100.0, 0.0),
                ]),
            },
            Term {
                name: "strong",
                set: FuzzySet::new(vec![(0.0, 0.0), (60.0, 0.0), (80.0, 1.0), (100.0, 1.0)]),
            },
        ],
    };
    Mamdani {
        variables: vec![temperature, cooling],
        rules: vec![
            Rule {
                antecedents: vec![("temperature", "cold")],
                consequent: ("cooling", "off"),
            },
            Rule {
                antecedents: vec![("temperature", "comfortable")],
                consequent: ("cooling", "low"),
            },
            Rule {
                antecedents: vec![("temperature", "warm")],
                consequent: ("cooling", "low"),
            },
            Rule {
                antecedents: vec![("temperature", "hot")],
                consequent: ("cooling", "strong"),
            },
        ],
        tnorm: TNorm::Zadeh,
    }
}

fn main() {
    let controller = ac();

    println!("Mamdani air-conditioner controller");
    println!("==================================");
    println!("rules:");
    println!("  if cold        then cooling off");
    println!("  if comfortable then cooling low");
    println!("  if warm        then cooling low");
    println!("  if hot         then cooling strong");
    println!();

    let temp = 27.0;
    println!("input temperature: {temp} C");
    println!();
    println!("fuzzification (membership in each temperature term):");
    let temperature = controller.variable("temperature").unwrap();
    for term in &temperature.terms {
        println!("  {:>11}: {:.3}", term.name, term.set.membership(temp));
    }
    println!();
    println!("rule firing strengths:");
    for rule in &controller.rules {
        let f = controller.firing_strength(rule, &[("temperature", temp)]);
        let (var, term) = rule.consequent;
        println!(
            "  if temperature is {} -> cooling {} : {:.3}",
            rule.antecedents[0].1, term, f
        );
        let _ = var;
    }
    println!();

    let aggregate = controller.aggregate(&[("temperature", temp)], "cooling");
    println!("aggregated output set (breakpoints (x, mu)):");
    println!(
        "  {}",
        aggregate
            .points
            .iter()
            .map(|&(x, y)| format!("({x:.2}, {y:.2})"))
            .collect::<Vec<_>>()
            .join(" ")
    );
    println!();
    println!("defuzzification:");
    for (name, method) in [
        ("centroid", Defuzzifier::Centroid),
        ("mean of max", Defuzzifier::MeanOfMax),
        ("bisector", Defuzzifier::Bisector),
    ] {
        println!(
            "  {:>11}: {:.2}% cooling",
            name,
            controller.infer(&[("temperature", temp)], "cooling", method)
        );
    }
    println!();

    println!("sweep: centroid cooling power vs temperature (no jumps):");
    for t in (15..=35).step_by(2) {
        let out = controller.infer(
            &[("temperature", t as f64)],
            "cooling",
            Defuzzifier::Centroid,
        );
        let bar = "#".repeat((out / 4.0).round() as usize);
        println!("  {:>3} C: {:5.1}% {bar}", t, out);
    }
}
