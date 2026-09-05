//! Kleisli composition: chaining effectful functions through Option and Vec.
//!
//! The Option pipeline parses a positive number, takes its integer square root, and applies a bound.
//! The Vec pipeline sends a number to its divisors and each divisor to its proper divisors.

use categories::{kleisli_option, kleisli_vec, unit_option, unit_vec};

fn main() {
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
    println!("pipeline: parse a positive number, take its integer square root, keep it <= 100");
    for s in ["16", "10201", "20", "-9", "oops"] {
        println!("  {s:>5} -> {:?}", pipeline(s));
    }
    println!();

    let left_unit = kleisli_option(unit_option, int_sqrt);
    let right_unit = kleisli_option(int_sqrt, unit_option);
    println!(
        "unit laws hold: {}",
        (1..=10).all(|n| left_unit(n) == int_sqrt(n) && right_unit(n) == int_sqrt(n))
    );
    println!();

    let divisors = |n: i64| -> Vec<i64> { (1..=n).filter(|d| n % d == 0).collect() };
    let proper_divisors = |n: i64| -> Vec<i64> { (1..n).filter(|d| n % d == 0).collect() };
    let neighbors = |n: i64| -> Vec<i64> { vec![n - 1, n + 1] };

    let composed = kleisli_vec(divisors, proper_divisors);
    println!(
        "divisors of 12, then proper divisors of each: {:?}",
        composed(12)
    );

    let assoc_left = kleisli_vec(kleisli_vec(divisors, proper_divisors), neighbors);
    let assoc_right = kleisli_vec(divisors, kleisli_vec(proper_divisors, neighbors));
    println!(
        "Kleisli associativity holds for the list monad: {}",
        [6, 9, 12].iter().all(|&n| assoc_left(n) == assoc_right(n))
    );

    let vec_left_unit = kleisli_vec(unit_vec, divisors);
    let vec_right_unit = kleisli_vec(divisors, unit_vec);
    println!(
        "list unit laws hold: {}",
        [6, 9]
            .iter()
            .all(|&n| vec_left_unit(n) == divisors(n) && vec_right_unit(n) == divisors(n))
    );

    assert_eq!(pipeline("16"), Some(4));
    assert_eq!(pipeline("10201"), None);
    assert_eq!(pipeline("20"), None);
    assert_eq!(pipeline("-9"), None);
    assert_eq!(composed(12), vec![1, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 6]);
    assert_eq!(assoc_left(12), assoc_right(12));
}
