//! Concrete independence systems: four matroids.

use crate::Matroid;

/// Uniform matroid `U_{k,n}`: independent sets are subsets of size at most `k`.
pub struct UniformMatroid {
    /// Size of the ground set.
    pub n: u32,
    /// Maximum size of an independent set.
    pub k: u32,
}

impl Matroid for UniformMatroid {
    fn n(&self) -> u32 {
        self.n
    }
    fn is_independent(&self, set: &[u32]) -> bool {
        set.len() as u32 <= self.k
    }
}

/// Graphic matroid of a graph: independent sets are acyclic edge subsets (forests).
pub struct GraphicMatroid<'a> {
    /// Number of vertices of the underlying graph.
    pub vertices: u32,
    /// Edge list of the underlying graph.
    /// A ground-set element is an edge index.
    pub edges: &'a [(u32, u32)],
}

impl<'a> GraphicMatroid<'a> {
    /// A graphic matroid on `vertices` vertices with the given edge list.
    pub fn new(vertices: u32, edges: &'a [(u32, u32)]) -> Self {
        Self { vertices, edges }
    }
}

impl<'a> Matroid for GraphicMatroid<'a> {
    fn n(&self) -> u32 {
        self.edges.len() as u32
    }
    fn is_independent(&self, set: &[u32]) -> bool {
        fn find(parent: &mut Vec<u32>, x: u32) -> u32 {
            if parent[x as usize] != x {
                let root = find(parent, parent[x as usize]);
                parent[x as usize] = root;
            }
            parent[x as usize]
        }
        let mut parent: Vec<u32> = (0..self.vertices).collect();
        for &e in set {
            let (u, v) = self.edges[e as usize];
            let (ru, rv) = (find(&mut parent, u), find(&mut parent, v));
            if ru == rv {
                return false;
            }
            parent[ru as usize] = rv;
        }
        true
    }
}

/// Scheduling matroid: independent sets are sets of jobs schedulable by deadlines.
/// A set is schedulable when, for every time `t`, at most `t` jobs have deadline <= t.
pub struct SchedulingMatroid {
    /// Deadline of every job.
    /// A ground-set element is a job index.
    pub deadlines: Vec<u32>,
}

impl Matroid for SchedulingMatroid {
    fn n(&self) -> u32 {
        self.deadlines.len() as u32
    }
    fn is_independent(&self, set: &[u32]) -> bool {
        for t in 1..=self.deadlines.len() as u32 {
            let count = set
                .iter()
                .filter(|&&i| self.deadlines[i as usize] <= t)
                .count() as u32;
            if count > t {
                return false;
            }
        }
        true
    }
}

/// Linear matroid over GF(2): independent sets are linearly independent binary vectors.
/// Each ground-set element is one vector, stored as a row of bits (a `u8` per coordinate).
pub struct BinaryLinearMatroid<'a> {
    /// The vectors of the ground set.
    /// A ground-set element is a row index.
    pub vectors: &'a [Vec<u8>],
}

impl<'a> Matroid for BinaryLinearMatroid<'a> {
    fn n(&self) -> u32 {
        self.vectors.len() as u32
    }
    fn is_independent(&self, set: &[u32]) -> bool {
        let dim = self.vectors[0].len();
        // Reduced basis built so far: each row has its own pivot column.
        let mut basis: Vec<Vec<u8>> = Vec::new();
        for &i in set {
            let mut row = self.vectors[i as usize].clone();
            // Eliminate `row` against the basis over GF(2).
            for b in &basis {
                let pivot = b.iter().position(|&x| x == 1).unwrap();
                if row[pivot] == 1 {
                    for c in 0..dim {
                        row[c] ^= b[c];
                    }
                }
            }
            // A zero row means the vector is a combination of the others.
            if row.iter().all(|&x| x == 0) {
                return false;
            }
            basis.push(row);
        }
        true
    }
}
