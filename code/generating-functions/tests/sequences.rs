//! Prefix checks for the three sequences built from generating functions.

use generating_functions::{catalan_numbers, fibonacci_numbers, partition_numbers};

#[test]
fn catalan_numbers_match_the_table() {
    let expected = [
        1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796, 58786, 208012, 742900, 2674440, 9694845,
    ];
    assert_eq!(catalan_numbers(expected.len() - 1), expected.to_vec());
}

#[test]
fn fibonacci_numbers_agree_with_the_recurrence() {
    let n = 30;
    let got = fibonacci_numbers(n);
    let mut expected = vec![1, 1];
    for k in 2..=n {
        expected.push(expected[k - 1] + expected[k - 2]);
    }
    assert_eq!(got, expected);
}

#[test]
fn partition_numbers_match_the_table() {
    let expected = [
        1, 1, 2, 3, 5, 7, 11, 15, 22, 30, 42, 56, 77, 101, 135, 176, 231, 297, 385, 490, 627,
    ];
    assert_eq!(partition_numbers(expected.len() - 1), expected.to_vec());
}
