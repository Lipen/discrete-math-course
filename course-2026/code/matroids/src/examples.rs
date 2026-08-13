//! Concrete independence systems: three matroids and one non-matroid.

use crate::Matroid;

/// Uniform matroid U_{k,n}: independent sets are subsets of size at most `k`.
pub struct UniformMatroid {
    pub n: u32,
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
    pub vertices: u32,
    pub edges: &'a [(u32, u32)],
}

impl<'a> GraphicMatroid<'a> {
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

/// An independence system that is NOT a matroid: used to show that greedy can fail.
/// Independent sets: size at most `max_size`, excluding the listed 2-element sets.
pub struct SimpleIndependenceSystem {
    pub n: u32,
    pub max_size: u32,
    pub forbidden: Vec<Vec<u32>>,
}

impl Matroid for SimpleIndependenceSystem {
    fn n(&self) -> u32 {
        self.n
    }
    fn is_independent(&self, set: &[u32]) -> bool {
        if set.len() as u32 > self.max_size {
            return false;
        }
        !self
            .forbidden
            .iter()
            .any(|f| f.iter().all(|&x| set.contains(&x)))
    }
}
