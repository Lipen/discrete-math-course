//! Finite categories: objects, named morphisms, and a composition table.
//!
//! A category here stores its whole composition table, so composition is a lookup and every axiom becomes a loop over the table.

use std::collections::HashMap;

/// The index of an object in a category.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ObjId(pub usize);

/// A named morphism from a source object to a target object.
///
/// Names are unique inside one category, so the name identifies the morphism.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Morphism {
    /// The name, for example a monoid element `m2` or a path `b*a`.
    pub name: String,
    /// The object the morphism starts at.
    pub src: ObjId,
    /// The object the morphism ends at.
    pub dst: ObjId,
}

/// A finite category: objects, morphisms, and a total composition table.
///
/// The entry for a composable pair stores the composite `g` after `f`.
/// The builders fill the table, and `check_axioms` walks it to verify associativity and the identity laws.
pub struct FiniteCategory {
    /// Object names by index.
    pub objects: Vec<String>,
    /// All morphisms of the category.
    pub morphisms: Vec<Morphism>,
    /// Index of the identity morphism of each object.
    identities: Vec<usize>,
    /// Composition over morphism indices: `table[i][j]` is the composite of `morphisms[i]` followed by `morphisms[j]`.
    table: Vec<Vec<Option<usize>>>,
}

/// The name of the path applying the edges of `seq` in order, starting at node `src`.
fn path_name(seq: &[usize], src: usize, edges: &[(&str, usize, usize)], nodes: &[&str]) -> String {
    if seq.is_empty() {
        return format!("id_{}", nodes[src]);
    }
    seq.iter()
        .rev()
        .map(|&i| edges[i].0)
        .collect::<Vec<&str>>()
        .join("*")
}

impl FiniteCategory {
    /// The empty category: no objects and no morphisms.
    pub fn empty() -> Self {
        FiniteCategory {
            objects: Vec::new(),
            morphisms: Vec::new(),
            identities: Vec::new(),
            table: Vec::new(),
        }
    }

    /// A one-object category whose morphisms are the elements of a monoid.
    ///
    /// `table[i][j]` is the product of elements `i` and `j`.
    /// Morphisms are named `m0`, `m1` and so on after the element indices, and the identity element is detected from the table.
    /// Panics when the table is not square, has an out-of-range entry, or has no identity element.
    pub fn from_monoid(name: &str, table: &[&[usize]]) -> Self {
        let n = table.len();
        assert!(n > 0, "monoid table must not be empty");
        for row in table {
            assert!(row.len() == n, "monoid table must be square");
            for &v in row.iter() {
                assert!(v < n, "monoid table entry {v} out of range");
            }
        }
        let e = (0..n)
            .find(|&i| (0..n).all(|j| table[i][j] == j))
            .unwrap_or_else(|| panic!("monoid table has no identity element"));
        let morphisms: Vec<Morphism> = (0..n)
            .map(|i| Morphism {
                name: format!("m{i}"),
                src: ObjId(0),
                dst: ObjId(0),
            })
            .collect();
        let comp: Vec<Vec<Option<usize>>> = table
            .iter()
            .map(|row| row.iter().map(|&v| Some(v)).collect())
            .collect();
        FiniteCategory {
            objects: vec![name.to_string()],
            morphisms,
            identities: vec![e],
            table: comp,
        }
    }

    /// The cyclic monoid `Z_n` under addition mod `n`, as a one-object category.
    ///
    /// Elements are named `m0` to `m(n-1)`, the identity is `m0` (the residue 0).
    /// Panics when `n == 0`.
    /// ```
    /// use categories::FiniteCategory;
    /// let z4 = FiniteCategory::zn(4);
    /// assert!(z4.check_axioms());
    /// assert_eq!(z4.morphisms.len(), 4);
    /// ```
    pub fn zn(n: usize) -> Self {
        assert!(n > 0, "Z_n needs n >= 1");
        let table: Vec<Vec<usize>> = (0..n)
            .map(|i| (0..n).map(|j| (i + j) % n).collect())
            .collect();
        let rows: Vec<&[usize]> = table.iter().map(|r| r.as_slice()).collect();
        Self::from_monoid(&format!("Z{n}"), &rows)
    }

    /// A one-object category from a binary operation on `{0, ..., n-1}` given as a closure.
    ///
    /// The closure receives element indices; the result must be in range.
    /// Panics when the operation has no identity element or produces an out-of-range value.
    /// ```
    /// use categories::FiniteCategory;
    /// // The two-element monoid {e, s} with s * s = e.
    /// let flip = FiniteCategory::from_operation("flip", 2, &|a, b| a ^ b);
    /// assert!(flip.check_axioms());
    /// ```
    pub fn from_operation(name: &str, n: usize, op: &dyn Fn(usize, usize) -> usize) -> Self {
        assert!(n > 0, "operation needs at least one element");
        let table: Vec<Vec<usize>> = (0..n).map(|i| (0..n).map(|j| op(i, j)).collect()).collect();
        let rows: Vec<&[usize]> = table.iter().map(|r| r.as_slice()).collect();
        Self::from_monoid(name, &rows)
    }

    /// The thin category of a reflexive relation: one morphism `a -> b` exactly when `le[a][b]` holds.
    ///
    /// Objects are named `0`, `1` and so on after their indices.
    /// Transitivity is not required by the builder: a non-transitive relation builds a category whose `check_axioms` fails.
    /// Panics when `le` is not square or not reflexive.
    pub fn from_poset(le: &[&[bool]]) -> Self {
        let n = le.len();
        for (a, row) in le.iter().enumerate() {
            assert!(row.len() == n, "relation must be square");
            assert!(row[a], "relation must be reflexive: missing {a} <= {a}");
        }
        let objects: Vec<String> = (0..n).map(|i| i.to_string()).collect();
        let mut morphisms = Vec::new();
        let mut pair_index = vec![vec![None; n]; n];
        for (a, row) in le.iter().enumerate() {
            for (b, &le_ab) in row.iter().enumerate() {
                if le_ab {
                    pair_index[a][b] = Some(morphisms.len());
                    morphisms.push(Morphism {
                        name: format!("{a}->{b}"),
                        src: ObjId(a),
                        dst: ObjId(b),
                    });
                }
            }
        }
        let identities: Vec<usize> = (0..n).map(|a| pair_index[a][a].unwrap()).collect();
        let mut table: Vec<Vec<Option<usize>>> = vec![vec![None; morphisms.len()]; morphisms.len()];
        for (fi, f) in morphisms.iter().enumerate() {
            for (gi, g) in morphisms.iter().enumerate() {
                if f.dst == g.src {
                    table[fi][gi] = pair_index[f.src.0][g.dst.0];
                }
            }
        }
        FiniteCategory {
            objects,
            morphisms,
            identities,
            table,
        }
    }

    /// The free category of a directed acyclic graph: morphisms are paths, composition is concatenation.
    ///
    /// Each edge is `(name, src, dst)` by node index.
    /// The empty path at a node `A` is named `id_A`, and the path applying `e1` then `e2` is named `e2*e1`.
    /// Panics when node names or edge names repeat, when an edge endpoint is out of range, or when the graph has a cycle.
    pub fn free_from_graph(nodes: &[&str], edges: &[(&str, usize, usize)]) -> Self {
        for i in 0..nodes.len() {
            for j in i + 1..nodes.len() {
                assert!(nodes[i] != nodes[j], "duplicate node name {}", nodes[i]);
            }
        }
        for i in 0..edges.len() {
            let (name, s, t) = edges[i];
            for (other, _, _) in &edges[i + 1..] {
                assert!(name != *other, "duplicate edge name {name}");
            }
            assert!(
                s < nodes.len() && t < nodes.len(),
                "edge {name} endpoint out of range"
            );
        }
        let n = nodes.len();
        // a cycle would allow paths of every length, so the category would be infinite
        let mut indegree = vec![0usize; n];
        let mut outgoing: Vec<Vec<usize>> = vec![Vec::new(); n];
        for (i, &(_, s, t)) in edges.iter().enumerate() {
            indegree[t] += 1;
            outgoing[s].push(i);
        }
        let mut reachable = indegree.clone();
        let mut queue: Vec<usize> = (0..n).filter(|&v| reachable[v] == 0).collect();
        let mut qi = 0;
        while qi < queue.len() {
            let v = queue[qi];
            qi += 1;
            for &e in &outgoing[v] {
                let t = edges[e].2;
                reachable[t] -= 1;
                if reachable[t] == 0 {
                    queue.push(t);
                }
            }
        }
        assert!(
            queue.len() == n,
            "the graph has a cycle, so the free category would have infinitely many paths"
        );

        // grow every path of the previous level by one edge until a level adds nothing
        let mut paths: Vec<(Vec<usize>, usize, usize)> =
            (0..n).map(|v| (Vec::new(), v, v)).collect();
        let mut frontier: Vec<usize> = (0..n).collect();
        while !frontier.is_empty() {
            let mut grown: Vec<(Vec<usize>, usize, usize)> = Vec::new();
            for &p in &frontier {
                let (seq, src, dst) = &paths[p];
                let (src, dst) = (*src, *dst);
                for (ei, &(_, s, t)) in edges.iter().enumerate() {
                    if s == dst {
                        let mut whole = seq.clone();
                        whole.push(ei);
                        grown.push((whole, src, t));
                    }
                }
            }
            frontier.clear();
            for path in grown {
                frontier.push(paths.len());
                paths.push(path);
            }
        }
        let names: Vec<String> = paths
            .iter()
            .map(|(seq, s, _)| path_name(seq, *s, edges, nodes))
            .collect();
        let mut index_of_name: HashMap<String, usize> = HashMap::new();
        for (i, name) in names.iter().enumerate() {
            index_of_name.insert(name.clone(), i);
        }
        let morphisms: Vec<Morphism> = paths
            .iter()
            .zip(&names)
            .map(|((_, s, t), name)| Morphism {
                name: name.clone(),
                src: ObjId(*s),
                dst: ObjId(*t),
            })
            .collect();
        let identities: Vec<usize> = (0..n).map(|v| index_of_name[&names[v]]).collect();
        let mut table: Vec<Vec<Option<usize>>> = vec![vec![None; morphisms.len()]; morphisms.len()];
        for (fi, (seq, src, dst)) in paths.iter().enumerate() {
            for (gi, (gseq, gsrc, _)) in paths.iter().enumerate() {
                if dst == gsrc {
                    let mut whole = seq.clone();
                    whole.extend_from_slice(gseq);
                    let name = path_name(&whole, *src, edges, nodes);
                    table[fi][gi] = Some(index_of_name[&name]);
                }
            }
        }
        FiniteCategory {
            objects: nodes.iter().map(|s| s.to_string()).collect(),
            morphisms,
            identities,
            table,
        }
    }

    /// The index of the morphism with the given name, if there is one.
    pub fn find_morphism(&self, name: &str) -> Option<usize> {
        self.morphisms.iter().position(|m| m.name == name)
    }

    /// The composite `g` after `f`, or `None` when the pair is not composable.
    ///
    /// A missing table entry on a composable pair also gives `None`, which happens only for categories that fail `check_axioms`.
    pub(crate) fn composition(&self, f: &Morphism, g: &Morphism) -> Option<Morphism> {
        if f.dst != g.src {
            return None;
        }
        let i = self.find_morphism(&f.name)?;
        let j = self.find_morphism(&g.name)?;
        let k = self.table[i][j]?;
        Some(self.morphisms[k].clone())
    }

    /// The composite of `f` followed by `g`.
    ///
    /// Panics when `f` and `g` are not composable or either name is unknown to this category.
    pub fn compose(&self, f: &Morphism, g: &Morphism) -> Morphism {
        assert!(
            f.dst == g.src,
            "morphisms {} and {} are not composable",
            f.name,
            g.name
        );
        self.composition(f, g).unwrap_or_else(|| {
            panic!(
                "composition of {} then {} is missing from the table",
                f.name, g.name
            )
        })
    }

    /// The identity morphism of an object.
    ///
    /// Panics when the object index is out of range.
    pub fn identity(&self, o: ObjId) -> Morphism {
        self.morphisms[self.identities[o.0]].clone()
    }

    /// Whether the composition table satisfies the category axioms.
    ///
    /// The check verifies that the table has an entry exactly on the composable pairs, that the identities act as identities on both sides, and that composition is associative.
    pub fn check_axioms(&self) -> bool {
        if self.identities.len() != self.objects.len() {
            return false;
        }
        if self
            .morphisms
            .iter()
            .any(|m| m.src.0 >= self.objects.len() || m.dst.0 >= self.objects.len())
        {
            return false;
        }
        for (i, row) in self.table.iter().enumerate() {
            for (j, entry) in row.iter().enumerate() {
                let composable = self.morphisms[i].dst == self.morphisms[j].src;
                if composable != entry.is_some() {
                    return false;
                }
            }
        }
        for (o, &idi) in self.identities.iter().enumerate() {
            let id = &self.morphisms[idi];
            if id.src != ObjId(o) || id.dst != ObjId(o) {
                return false;
            }
            for (k, m) in self.morphisms.iter().enumerate() {
                if m.src == ObjId(o) && self.table[idi][k] != Some(k) {
                    return false;
                }
                if m.dst == ObjId(o) && self.table[k][idi] != Some(k) {
                    return false;
                }
            }
        }
        let m = self.morphisms.len();
        for i in 0..m {
            for j in 0..m {
                for k in 0..m {
                    if let (Some(p), Some(q)) = (self.table[i][j], self.table[j][k]) {
                        if self.table[p][k] != self.table[i][q] {
                            return false;
                        }
                    }
                }
            }
        }
        true
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn find_morphism_and_identity() {
        let cat = FiniteCategory::from_monoid(
            "Z4",
            &[&[0, 1, 2, 3], &[1, 2, 3, 0], &[2, 3, 0, 1], &[3, 0, 1, 2]],
        );
        let i = cat.find_morphism("m3").unwrap();
        assert_eq!(cat.morphisms[i].name, "m3");
        assert!(cat.find_morphism("nope").is_none());
        assert_eq!(cat.identity(ObjId(0)).name, "m0");
    }

    #[test]
    fn empty_category_is_vacuously_valid() {
        assert!(FiniteCategory::empty().check_axioms());
    }

    #[test]
    #[should_panic]
    fn monoid_without_identity_panics() {
        FiniteCategory::from_monoid("bad", &[&[0, 0], &[0, 0]]);
    }
}
