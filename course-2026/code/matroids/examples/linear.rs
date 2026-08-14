//! Linear matroid over GF(2): the three vectors of the book example.
//!
//! v1 = (1,0) weight 5, v2 = (0,1) weight 4, v3 = (1,1) weight 3.
//! Any two vectors are independent; all three are dependent (v3 = v1 + v2).
//! Greedy takes v1 and v2, drops v3, and reaches weight 9.

use matroids::examples::BinaryLinearMatroid;
use matroids::{greedy, rank, weight};

fn main() {
    let vectors = vec![vec![1u8, 0], vec![0u8, 1], vec![1u8, 1]];
    let weights = [5u32, 4, 3];
    let m = BinaryLinearMatroid { vectors: &vectors };

    let base = greedy(&m, &weights);
    let names: Vec<usize> = base.iter().map(|&i| i as usize + 1).collect();

    println!("vectors: v1=(1,0) w5, v2=(0,1) w4, v3=(1,1) w3");
    println!(
        "greedy picks: v{}",
        names
            .iter()
            .map(|i| i.to_string())
            .collect::<Vec<_>>()
            .join(", v")
    );
    println!("total weight: {}", weight(&base, &weights));
    println!("rank of the three vectors: {}", rank(&m));

    assert_eq!(weight(&base, &weights), 9);
    assert_eq!(rank(&m), 2);
}
