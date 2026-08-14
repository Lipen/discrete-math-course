//! Rank of a matroid: size of a maximum independent set.
//!
//! All bases of a matroid have the same size, so the rank is well-defined.
//! A triangle (graphic matroid) has rank 2, three binary vectors have rank 2,
//! and the uniform matroid U(2,4) has rank 2.

use matroids::examples::{BinaryLinearMatroid, GraphicMatroid, UniformMatroid};
use matroids::rank;

fn main() {
    // Triangle: three edges, any two form a spanning tree, all three a cycle.
    let edges = vec![(0u32, 1u32), (1u32, 2u32), (0u32, 2u32)];
    let graphic = GraphicMatroid::new(3, &edges);

    // The three vectors of the book example: (1,0), (0,1), (1,1).
    let vectors = vec![vec![1u8, 0], vec![0u8, 1], vec![1u8, 1]];
    let linear = BinaryLinearMatroid { vectors: &vectors };

    let uniform = UniformMatroid { n: 4, k: 2 };

    println!("graphic matroid of a triangle:   rank {}", rank(&graphic));
    println!("linear matroid of three vectors: rank {}", rank(&linear));
    println!("uniform matroid U(2,4):          rank {}", rank(&uniform));

    assert_eq!(rank(&graphic), 2);
    assert_eq!(rank(&linear), 2);
    assert_eq!(rank(&uniform), 2);
}
