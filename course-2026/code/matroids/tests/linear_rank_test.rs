//! The linear matroid over GF(2) and the rank function.

use matroids::examples::{BinaryLinearMatroid, GraphicMatroid, UniformMatroid};
use matroids::{greedy, rank, weight, Matroid};

fn sample_vectors() -> Vec<Vec<u8>> {
    // v1 = (1,0), v2 = (0,1), v3 = (1,1): any pair independent, triple dependent.
    vec![vec![1u8, 0], vec![0u8, 1], vec![1u8, 1]]
}

#[test]
fn linear_matroid_independence() {
    let vectors = sample_vectors();
    let m = BinaryLinearMatroid { vectors: &vectors };
    assert!(m.is_independent(&[0, 1]));
    assert!(m.is_independent(&[1, 2]));
    assert!(!m.is_independent(&[0, 1, 2])); // v3 = v1 + v2
}

#[test]
fn linear_matroid_greedy() {
    // Weights: v1=5, v2=4, v3=3. Greedy -> {v1, v2}, weight 9.
    let vectors = sample_vectors();
    let m = BinaryLinearMatroid { vectors: &vectors };
    let weights = [5u32, 4, 3];
    let base = greedy(&m, &weights);
    assert_eq!(weight(&base, &weights), 9);
    assert_eq!(base.len(), 2);
}

#[test]
fn rank_of_examples() {
    let edges = vec![(0u32, 1u32), (1u32, 2u32), (0u32, 2u32)];
    let graphic = GraphicMatroid::new(3, &edges);
    assert_eq!(rank(&graphic), 2); // spanning tree of a triangle

    let vectors = sample_vectors();
    let linear = BinaryLinearMatroid { vectors: &vectors };
    assert_eq!(rank(&linear), 2); // basis of the plane

    let uniform = UniformMatroid { n: 4, k: 2 };
    assert_eq!(rank(&uniform), 2);
}

#[test]
fn all_bases_have_the_same_size() {
    // On a matroid, greedy returns a base regardless of the weights:
    // the exchange property forces every base to have the same size.
    let uniform = UniformMatroid { n: 6, k: 3 };
    for weights in [
        [1u32, 1, 1, 1, 1, 1],
        [6u32, 5, 4, 3, 2, 1],
        [0u32, 9, 0, 9, 0, 9],
    ] {
        let base = greedy(&uniform, &weights);
        assert_eq!(base.len(), 3);
    }
}
