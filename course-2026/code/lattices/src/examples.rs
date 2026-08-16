//! Concrete lattices used as running examples.

use crate::Lattice;

/// The diamond M3: bottom, top, and three pairwise incomparable middles.
pub fn m3() -> Lattice {
    // Elements 0..=4: 0 = bottom, 4 = top, 1, 2, 3 incomparable middles.
    let mut leq = Vec::new();
    for x in 0..=4 {
        leq.push((x, x));
    }
    for &x in &[1, 2, 3] {
        leq.push((0, x));
        leq.push((x, 4));
    }
    leq.push((0, 4));
    Lattice {
        elements: vec![0, 1, 2, 3, 4],
        leq,
    }
}

/// The pentagon N5: `0 < a < b < 1` and `0 < c < 1`, `c` incomparable with
/// `a` and `b`.
pub fn n5() -> Lattice {
    // 0 = 0, a = 1, b = 2, c = 3, 1 = 4.
    let leq = vec![
        (0, 0),
        (1, 1),
        (2, 2),
        (3, 3),
        (4, 4),
        (0, 1),
        (1, 2),
        (2, 4),
        (0, 3),
        (3, 4),
        (0, 2),
        (0, 4),
        (1, 4),
    ];
    Lattice {
        elements: vec![0, 1, 2, 3, 4],
        leq,
    }
}

/// Divisors of 12 ordered by divisibility.
pub fn divisors_12() -> Lattice {
    let elements = vec![1u32, 2, 3, 4, 6, 12];
    let mut leq = Vec::new();
    for &a in &elements {
        for &b in &elements {
            if b % a == 0 {
                leq.push((a, b));
            }
        }
    }
    Lattice { elements, leq }
}

/// Boolean lattice of subsets of {1, 2, 3} ordered by inclusion.
///
/// Each element is a bitmask over the three elements; `a <= b` means `a` is
/// a subset of `b`.
pub fn boolean_3() -> Lattice {
    let elements: Vec<u32> = (0..8).collect();
    let mut leq = Vec::new();
    for &a in &elements {
        for &b in &elements {
            if a & b == a {
                leq.push((a, b));
            }
        }
    }
    Lattice { elements, leq }
}
