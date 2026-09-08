//! Kleisli laws for Option and Vec on concrete pipelines.

use categories::{kleisli_option, kleisli_vec, unit_option, unit_vec};

fn parse(s: &str) -> Option<i64> {
    s.parse::<i64>().ok().filter(|&n| n > 0)
}

fn int_sqrt(n: i64) -> Option<i64> {
    let r = (n as f64).sqrt().round() as i64;
    if r * r == n {
        Some(r)
    } else {
        None
    }
}

fn bound(n: i64) -> Option<i64> {
    if n <= 100 {
        Some(n)
    } else {
        None
    }
}

fn divisors(n: i64) -> Vec<i64> {
    (1..=n).filter(|d| n % d == 0).collect()
}

fn proper_divisors(n: i64) -> Vec<i64> {
    (1..n).filter(|d| n % d == 0).collect()
}

fn neighbors(n: i64) -> Vec<i64> {
    vec![n - 1, n + 1]
}

#[test]
fn option_pipeline_short_circuits() {
    let p = kleisli_option(kleisli_option(parse, int_sqrt), bound);
    assert_eq!(p("16"), Some(4));
    assert_eq!(p("10201"), None); // square root 101 fails the bound
    assert_eq!(p("20"), None); // no integer square root
    assert_eq!(p("-9"), None); // parse rejects non-positive input
    assert_eq!(p("oops"), None);
}

#[test]
fn option_kleisli_associativity() {
    for s in ["4", "16", "20", "121", "-3", "oops"] {
        let left = kleisli_option(kleisli_option(parse, int_sqrt), bound);
        let right = kleisli_option(parse, kleisli_option(int_sqrt, bound));
        assert_eq!(left(s), right(s));
    }
}

#[test]
fn option_unit_laws() {
    for n in [0, 4, 9, 26] {
        assert_eq!(kleisli_option(unit_option, int_sqrt)(n), int_sqrt(n));
        assert_eq!(kleisli_option(int_sqrt, unit_option)(n), int_sqrt(n));
    }
}

#[test]
fn vec_pipeline_multivalues() {
    let p = kleisli_vec(divisors, proper_divisors);
    assert_eq!(p(12), vec![1, 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 6]);
    assert_eq!(p(7), vec![1]);
}

#[test]
fn vec_kleisli_associativity() {
    for n in [6, 9, 12, 30] {
        let left = kleisli_vec(kleisli_vec(divisors, proper_divisors), neighbors);
        let right = kleisli_vec(divisors, kleisli_vec(proper_divisors, neighbors));
        assert_eq!(left(n), right(n));
    }
}

#[test]
fn vec_unit_laws() {
    for n in [6, 9, 12] {
        assert_eq!(kleisli_vec(unit_vec, divisors)(n), divisors(n));
        assert_eq!(kleisli_vec(divisors, unit_vec)(n), divisors(n));
    }
}

#[test]
fn option_associativity_over_many_inputs() {
    for n in -50..=50 {
        let left = kleisli_option(kleisli_option(int_sqrt, bound), |x| {
            if x % 2 == 0 {
                Some(x)
            } else {
                None
            }
        })(n);
        let right = kleisli_option(
            int_sqrt,
            kleisli_option(bound, |x| if x % 2 == 0 { Some(x) } else { None }),
        )(n);
        assert_eq!(left, right, "input {n}");
    }
}

#[test]
fn option_none_head_kills_the_whole_chain() {
    let dead = kleisli_option(|_: i64| None, int_sqrt);
    for n in 0..20 {
        assert_eq!(dead(n), None);
    }
}

#[test]
fn option_string_pipeline_composes() {
    let p = kleisli_option(parse, |n| if n < 10 { Some(n) } else { None });
    assert_eq!(p("7"), Some(7));
    assert_eq!(p("70"), None);
    assert_eq!(p("x"), None);
}

#[test]
fn vec_associativity_over_several_starts() {
    for n in 1..=16i64 {
        let left = kleisli_vec(kleisli_vec(divisors, proper_divisors), neighbors)(n);
        let right = kleisli_vec(divisors, kleisli_vec(proper_divisors, neighbors))(n);
        assert_eq!(left, right, "input {n}");
    }
}

#[test]
fn vec_kleisli_matches_flat_map() {
    for n in 1..=12i64 {
        let composed = kleisli_vec(divisors, proper_divisors)(n);
        let manual: Vec<i64> = divisors(n).into_iter().flat_map(proper_divisors).collect();
        assert_eq!(composed, manual, "input {n}");
    }
}

#[test]
fn vec_unit_laws_over_lists() {
    for n in 1..=10i64 {
        let d = divisors(n);
        assert_eq!(kleisli_vec(unit_vec, divisors)(n), d);
        assert_eq!(kleisli_vec(divisors, unit_vec)(n), d);
    }
}

#[test]
fn vec_chain_of_three_stages() {
    let chain3 = kleisli_vec(
        kleisli_vec(|n: i64| vec![n, n + 1], |n: i64| vec![n / 2, n * 2]),
        |n: i64| vec![n, -n],
    );
    let got = chain3(3);
    let expect = vec![1, -1, 6, -6, 2, -2, 8, -8];
    assert_eq!(got, expect);
}
