//! Kruskal as greedy on the graphic matroid: a triangle with edge weights 5, 4, 3.
//!
//! The greedy algorithm takes edges in decreasing weight order while keeping the chosen set acyclic (a forest).
//! It builds the maximum spanning tree of weight 9.

use matroids::examples::GraphicMatroid;
use matroids::{greedy, weight};

fn main() {
    // Triangle: edge 0 = (0,1) w5, edge 1 = (1,2) w4, edge 2 = (0,2) w3.
    let edges = vec![(0u32, 1u32), (1u32, 2u32), (0u32, 2u32)];
    let weights = [5u32, 4, 3];
    let m = GraphicMatroid::new(3, &edges);

    let base = greedy(&m, &weights);
    let total = weight(&base, &weights);

    println!("triangle edges: (0-1) w5, (1-2) w4, (0-2) w3");
    println!("greedy (Kruskal) picks edges: {:?}", base);
    println!("maximum spanning tree weight: {}", total);

    assert_eq!(total, 9);
}
