//! Kleisli composition: chaining effectful functions through Option and Vec.
//!
//! The Option pipeline parses a positive number, takes its integer square root, and applies a bound, with every stage shown.
//! The Vec pipeline sends a number to its divisors and each divisor to its proper divisors.

use categories::{kleisli_option, kleisli_vec, unit_option, unit_vec};

fn brace(v: &[i64]) -> String {
    let items: Vec<String> = v.iter().map(|n| n.to_string()).collect();
    format!("{{{}}}", items.join(", "))
}

fn stage(v: &Option<i64>) -> String {
    match v {
        Some(n) => n.to_string(),
        None => "--".to_string(),
    }
}

fn main() {
    let width = 64;
    println!("{}", "=".repeat(width));
    println!("Option pipeline: parse, integer square root, bound by 100");
    println!("{}", "=".repeat(width));
    println!();
    println!("  input   parse   sqrt    bound     result");
    println!("  {}", "-".repeat(46));

    let parse = |s: &str| -> Option<i64> { s.parse::<i64>().ok().filter(|&n| n > 0) };
    let int_sqrt = |n: i64| -> Option<i64> {
        let r = (n as f64).sqrt().round() as i64;
        if r * r == n {
            Some(r)
        } else {
            None
        }
    };
    let at_most_hundred = |n: i64| -> Option<i64> {
        if n <= 100 {
            Some(n)
        } else {
            None
        }
    };

    let pipeline = kleisli_option(kleisli_option(parse, int_sqrt), at_most_hundred);
    for s in ["16", "10201", "20", "-9", "oops"] {
        let p = parse(s);
        let q = p.and_then(int_sqrt);
        let b = q.and_then(at_most_hundred);
        let result = match pipeline(s) {
            Some(n) => format!("Some({n})"),
            None => "None".to_string(),
        };
        println!(
            "  {:<8}{:<8}{:<8}{:<10}{}",
            s,
            stage(&p),
            stage(&q),
            stage(&b),
            result
        );
    }

    let left_unit = kleisli_option(unit_option, int_sqrt);
    let right_unit = kleisli_option(int_sqrt, unit_option);
    let units = (1..=10).all(|n| left_unit(n) == int_sqrt(n) && right_unit(n) == int_sqrt(n));
    println!();
    println!("  unit laws: {}", if units { "hold" } else { "FAIL" });

    println!();
    println!("{}", "=".repeat(width));
    println!("Vec pipeline: divisors, then proper divisors");
    println!("{}", "=".repeat(width));
    println!();

    let divisors = |n: i64| -> Vec<i64> { (1..=n).filter(|d| n % d == 0).collect() };
    let proper_divisors = |n: i64| -> Vec<i64> { (1..n).filter(|d| n % d == 0).collect() };

    for n in [12i64, 30] {
        let first = divisors(n);
        let rows: Vec<String> = first.iter().map(|d| brace(&proper_divisors(*d))).collect();
        let flat = kleisli_vec(divisors, proper_divisors)(n);
        let mut unique = flat.clone();
        unique.sort();
        unique.dedup();
        println!("  n = {n}");
        println!("    divisors      {}", brace(&first));
        println!("    proper of each");
        for (d, row) in first.iter().zip(&rows) {
            println!("      {:<6} {}", format!("of {d}"), row);
        }
        println!("    flat result   {}", brace(&flat));
        println!("    sorted unique {}", brace(&unique));
        println!();
    }

    let associativity = (1..=12).all(|n| {
        let f = |n: i64| -> Vec<i64> { divisors(n) };
        let g = |n: i64| -> Vec<i64> { proper_divisors(n) };
        let h = |n: i64| -> Vec<i64> { vec![n / 2, n + 1] };
        let left = kleisli_vec(kleisli_vec(f, g), h)(n);
        let right = kleisli_vec(f, kleisli_vec(g, h))(n);
        left == right
    });
    let vec_units = (1..=12).all(|n| {
        let d = |n: i64| -> Vec<i64> { divisors(n) };
        kleisli_vec(unit_vec, d)(n) == d(n) && kleisli_vec(d, unit_vec)(n) == d(n)
    });
    println!(
        "  laws: associativity {}, unit {}",
        if associativity { "holds" } else { "FAILS" },
        if vec_units { "holds" } else { "FAIL" }
    );

    assert!(units && associativity && vec_units);
}
