//! Greedy is optimal on matroids and can fail on a non-matroid.

use matroids::examples::{
    GraphicMatroid, SchedulingMatroid, SimpleIndependenceSystem, UniformMatroid,
};
use matroids::{greedy, weight};

#[test]
fn uniform_matroid_greedy_takes_two_heaviest() {
    let m = UniformMatroid { n: 4, k: 2 };
    let weights = [5u32, 3, 4, 2];
    let base = greedy(&m, &weights);
    assert_eq!(base.len(), 2);
    assert_eq!(weight(&base, &weights), 9); // {0, 2}
}

#[test]
fn graphic_matroid_greedy_is_max_spanning_tree() {
    // Triangle: edge 0 = (0,1) w5, edge 1 = (1,2) w4, edge 2 = (0,2) w3.
    let edges = vec![(0u32, 1u32), (1u32, 2u32), (0u32, 2u32)];
    let weights = [5u32, 4, 3];
    let m = GraphicMatroid::new(3, &edges);
    let base = greedy(&m, &weights);
    assert_eq!(base.len(), 2);
    assert_eq!(weight(&base, &weights), 9); // {0, 1}
}

#[test]
fn greedy_fails_on_non_matroid() {
    // a(5), b(4), c(4); independent: {}, {a}, {b}, {c}, {b,c}.
    let system = SimpleIndependenceSystem {
        n: 3,
        max_size: 2,
        forbidden: vec![vec![0, 1], vec![0, 2]],
    };
    let weights = [5u32, 4, 4];
    let base = greedy(&system, &weights);
    let got = weight(&base, &weights);
    assert_eq!(got, 5); // greedy takes {a}
    assert_ne!(got, 8); // optimum {b, c} = 8 is out of reach
}

#[test]
fn scheduling_matroid_greedy_is_optimal() {
    // A(d1,p50), B(d1,p40), C(d2,p30) -> optimum {A, C} = 80.
    let m = SchedulingMatroid {
        deadlines: vec![1, 1, 2],
    };
    let profits = [50u32, 40, 30];
    let base = greedy(&m, &profits);
    assert_eq!(weight(&base, &profits), 80); // {A, C}
}
