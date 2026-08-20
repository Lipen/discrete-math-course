//! Exhaustive intuitionistic validity checking over finite Heyting algebras.
//!
//! A formula is **valid** when it evaluates to `⊤` in every finite Heyting
//! algebra under every valuation; the formulas valid in *all* Heyting
//! algebras are exactly the theorems of intuitionistic logic.  Finite
//! Heyting algebras cannot decide full intuitionistic logic, but the
//! collection of all finite Heyting algebras up to a size bound gives a
//! sound and, up to that bound, complete check.
//!
//! # The enumeration
//!
//! [`all_finite_heyting_algebras`] returns the finite Heyting algebras used
//! by [`valid`].  It is built in three steps, all cached after the first
//! call:
//!
//! 1. **Posets**: every partial order on `0..n` for `n <= 4` (there are
//!    1 + 1 + 3 + 19 + 219 = 243 of them).
//! 2. **Downset algebras**: for each poset, its downset algebra
//!    ([`crate::Poset::downset_algebra`]), of at most `2^4 = 16` elements.
//! 3. **Subalgebras**: every subalgebra of every downset algebra, i.e. every
//!    subset of elements closed under `∧`, `∨` and `->` (and hence containing
//!    `0` and `1`), generated from subsets of the join-irreducibles (in a
//!    downset algebra these are the principal downsets, at most 4 of them).
//!    Duplicate algebras are identified up to isomorphism by a canonical
//!    form.
//!
//! Every finite Heyting algebra is a finite distributive lattice, and by
//! Birkhoff duality a finite distributive lattice is the downset algebra of
//! the poset of its join-irreducibles.  A Heyting algebra of at most 5
//! elements has at most 4 join-irreducibles, so the enumeration contains
//! **every finite Heyting algebra with up to 5 elements** (the counts per
//! size are 1, 1, 1, 2, 3), and it goes on with 4 algebras of size 6 and
//! larger ones up to the 16-element Boolean algebra.  [`valid`] therefore
//! checks a formula against all finite Heyting algebras up to size 5 and a
//! further, documented selection of larger ones.
//!
//! ```
//! use heyting::{Formula, valid};
//!
//! let p = Formula::atom(0);
//! let q = Formula::atom(1);
//!
//! // Intuitionistic tautologies hold...
//! assert!(valid(&p.clone().implies(q.clone().implies(p.clone())))); // p -> q -> p
//! assert!(valid(&p.clone().implies(!(!p.clone()))));                // p -> ¬¬p
//!
//! // ...classical laws fail.
//! assert!(!valid(&p.clone().or(!p.clone())));                       // p ∨ ¬p
//! assert!(!valid(&(!(!p.clone())).implies(p.clone())));             // ¬¬p -> p
//! assert!(!valid(&((p.clone().implies(q.clone())).implies(p.clone())).implies(p.clone())));
//! ```

use crate::algebra::Algebra;
use crate::formula::all_valuations;
use crate::poset::Poset;
use crate::Formula;
use std::collections::HashMap;
use std::sync::OnceLock;

/// The size bound of the enumeration: posets on up to 4 elements, whose
/// downset algebras have at most `2^4 = 16` elements.
const MAX_POSET_SIZE: usize = 4;

/// All finite Heyting algebras up to 5 elements (plus larger subalgebras of
/// the downset algebras), cached after first use.
///
/// The enumeration is described in the module documentation; this is the
/// exact collection [`valid`] quantifies over.  The algebras are deduplicated
/// up to isomorphism (same meet/join/implies structure, different element
/// names), so each appears once.
///
/// ```
/// use heyting::all_finite_heyting_algebras;
///
/// let algebras = all_finite_heyting_algebras();
/// let mut by_size = std::collections::BTreeMap::new();
/// for a in algebras {
///     *by_size.entry(a.size()).or_insert(0usize) += 1;
/// }
/// // Complete up to size 5: 1 + 1 + 1 + 2 + 3 algebras of sizes 1..5.
/// assert_eq!(by_size[&1], 1);
/// assert_eq!(by_size[&2], 1);
/// assert_eq!(by_size[&3], 1);
/// assert_eq!(by_size[&4], 2);
/// assert_eq!(by_size[&5], 3);
/// // Size 6 is covered beyond the five distributive lattices: the
/// // enumeration contains 4 of the 5 six-element Heyting algebras (the
/// // 6-element chain needs a 5-element poset of join-irreducibles,
/// // beyond the ≤4-element enumeration bound).
/// assert_eq!(by_size[&6], 4);
/// ```
pub fn all_finite_heyting_algebras() -> &'static [Algebra] {
    static ALGEBRAS: OnceLock<Vec<Algebra>> = OnceLock::new();
    ALGEBRAS.get_or_init(build_enumeration)
}

/// Build the enumeration: subalgebras of downset algebras of posets on
/// `<= MAX_POSET_SIZE` elements, deduplicated up to isomorphism.
fn build_enumeration() -> Vec<Algebra> {
    // Group candidates by (size, fingerprint); isomorphic algebras share the
    // fingerprint, so exact isomorphism checks only run within a group.
    let mut groups: HashMap<(usize, Vec<usize>), Vec<Algebra>> = HashMap::new();

    for size in 0..=MAX_POSET_SIZE {
        for poset in all_posets(size) {
            let base = poset.downset_algebra();
            for sub in subalgebras(&base) {
                let key = (sub.size(), fingerprint(&sub));
                groups.entry(key).or_default().push(sub);
            }
        }
    }

    // Deduplicate each group up to isomorphism.
    let mut out: Vec<Algebra> = Vec::new();
    let mut keys: Vec<(usize, Vec<usize>)> = groups.keys().cloned().collect();
    keys.sort();
    for key in keys {
        let Some(candidates) = groups.get_mut(&key) else {
            continue;
        };
        let mut kept: Vec<Algebra> = Vec::new();
        for cand in candidates.drain(..) {
            if !kept.iter().any(|a| is_isomorphic(a, &cand)) {
                kept.push(cand);
            }
        }
        out.extend(kept);
    }
    out
}

/// A cheap isomorphism invariant: the sorted lists of meet- and join-degrees
/// of the elements (how many elements are below/above each element).  Two
/// isomorphic algebras always have the same fingerprint; different ones
/// usually do not, which keeps the exact checks in [`build_enumeration`]
/// small.
fn fingerprint(a: &Algebra) -> Vec<usize> {
    let n = a.size;
    let mut meet_deg = Vec::with_capacity(n);
    let mut join_deg = Vec::with_capacity(n);
    for x in 0..n {
        let mut mc = 0;
        let mut jc = 0;
        for y in 0..n {
            if a.meet[x][y] == x {
                mc += 1;
            }
            if a.join[x][y] == x {
                jc += 1;
            }
        }
        meet_deg.push(mc);
        join_deg.push(jc);
    }
    meet_deg.sort_unstable();
    join_deg.sort_unstable();
    let mut f = meet_deg;
    f.extend(join_deg);
    f
}

/// Every partial order on `0..size` (labelled posets), enumerated by trying
/// all relations and keeping the reflexive, antisymmetric, transitive ones.
fn all_posets(size: usize) -> Vec<Poset> {
    let mut out = Vec::new();
    let cells = size * size;
    for code in 0..(1usize << cells) {
        // Relation matrix: bit (x * size + y) means x <= y.
        let less = |x: usize, y: usize| code & (1 << (x * size + y)) != 0;
        if is_partial_order(size, less) {
            out.push(Poset { size, mask: code });
        }
    }
    out
}

/// Is `less` a partial order (reflexive, antisymmetric, transitive)?
fn is_partial_order(size: usize, less: impl Fn(usize, usize) -> bool) -> bool {
    for x in 0..size {
        if !less(x, x) {
            return false;
        }
    }
    for x in 0..size {
        for y in 0..size {
            if x != y && less(x, y) && less(y, x) {
                return false;
            }
        }
    }
    for x in 0..size {
        for y in 0..size {
            for z in 0..size {
                if less(x, y) && less(y, z) && !less(x, z) {
                    return false;
                }
            }
        }
    }
    true
}

/// All subalgebras of `a`: closures of subsets under `∧`, `∨` and `->`.
///
/// Any subalgebra is generated by its join-irreducible elements (every
/// element is a join of join-irreducibles below it), so it is enough to
/// enumerate the closures of all subsets of the join-irreducibles.  In the
/// downset algebra of a poset with `m` elements the join-irreducibles are
/// exactly the principal downsets, so there are at most `m <= 5` of them and
/// at most `2^5 = 32` subsets to try.  Every closure contains `bottom` and
/// `top` (the empty meet and join are reached in the closure process).
fn subalgebras(a: &Algebra) -> Vec<Algebra> {
    let n = a.size;
    let mut seen: std::collections::HashSet<Vec<usize>> = std::collections::HashSet::new();
    let mut out = Vec::new();

    // Join-irreducibles: elements x != bottom that cannot be written as the
    // join of two strictly smaller elements.
    let mut join_irreducible = Vec::new();
    for x in 0..n {
        if x == a.bottom {
            continue;
        }
        let mut irre = true;
        for u in 0..n {
            for v in 0..n {
                if a.leq(u, x) && a.leq(v, x) && u != x && v != x && a.join(u, v) == x {
                    irre = false;
                }
            }
        }
        if irre {
            join_irreducible.push(x);
        }
    }

    // The subalgebra generated by the elements in `gens`.
    let closure = |mut gens: Vec<usize>| -> Vec<usize> {
        gens.push(a.bottom);
        gens.push(a.top);
        gens.sort_unstable();
        gens.dedup();
        let mut set = gens;
        let mut present = vec![false; n];
        for &x in &set {
            present[x] = true;
        }
        loop {
            let snapshot = set.clone();
            let mut added = false;
            for &x in &snapshot {
                for &y in &snapshot {
                    for z in [a.meet(x, y), a.join(x, y), a.implies(x, y)] {
                        if !present[z] {
                            present[z] = true;
                            set.push(z);
                            added = true;
                        }
                    }
                }
            }
            if !added {
                break;
            }
        }
        set.sort_unstable();
        set
    };

    // Every subset of the join-irreducibles generates a subalgebra, and
    // every subalgebra is generated by its own join-irreducibles.
    for gens in 0..(1usize << join_irreducible.len()) {
        let mut g = Vec::new();
        for (i, &e) in join_irreducible.iter().enumerate() {
            if gens & (1 << i) != 0 {
                g.push(e);
            }
        }
        let closed = closure(g);
        if seen.insert(closed.clone()) {
            out.push(subalgebra_algebra(a, &closed));
        }
    }
    out
}

/// Restrict an algebra to the subalgebra on the sorted element set `elems`.
fn subalgebra_algebra(a: &Algebra, elems: &[usize]) -> Algebra {
    let m = elems.len();
    let pos: HashMap<usize, usize> = elems.iter().enumerate().map(|(i, &e)| (e, i)).collect();
    let mut meet = vec![vec![0; m]; m];
    let mut join = vec![vec![0; m]; m];
    let mut implies = vec![vec![0; m]; m];
    for i in 0..m {
        for j in 0..m {
            meet[i][j] = pos[&a.meet(elems[i], elems[j])];
            join[i][j] = pos[&a.join(elems[i], elems[j])];
            implies[i][j] = pos[&a.implies(elems[i], elems[j])];
        }
    }
    let labels: Vec<String> = elems.iter().map(|&e| a.labels[e].clone()).collect();
    Algebra {
        size: m,
        meet,
        join,
        implies,
        bottom: pos[&a.bottom],
        top: pos[&a.top],
        labels,
    }
}

/// The canonical form of an algebra: relabel the elements so that `bottom`
/// becomes 0, `top` becomes `size - 1`, and the remaining elements are
/// ordered to make the flattened tables lexicographically smallest.  Two
/// algebras are isomorphic iff they have the same canonical form.
///
/// The search is an *individualization-refinement* canonicalization:
/// elements are partitioned by isomorphism invariants (meet/join degree,
/// then the class of every meet/join/implication partner), cells of size
/// greater than one are split by individualizing one element, and the
/// minimal flattened table over all terminal partitions is the canonical
/// form.  Unlike a naive degree-pruned relabeling search, every isomorphism
/// is reached by some branch, so isomorphic algebras always receive the
/// same canonical form.
fn canonical_form(a: &Algebra) -> Vec<usize> {
    let n = a.size;
    if n == 0 {
        return Vec::new();
    }
    // Normalize: relabel the elements so that bottom is at 0 and top at
    // n - 1 (the standard form used by all algebras in this crate).  This
    // makes the canonical form independent of the given element order.
    let norm = normalized(a);

    // The current partition of elements into cells, plus the order in which
    // elements were individualized (a tie-breaker for terminal partitions).
    let mut best: Option<Vec<usize>> = None;

    // Refine a partition by the degree pair and by the classes of all
    // meet/join/implication results.  Returns the refined partition.
    fn refine(norm: &Algebra, cells: &mut Vec<Vec<usize>>) {
        loop {
            let mut class_of = vec![0usize; norm.size];
            for (ci, cell) in cells.iter().enumerate() {
                for &x in cell {
                    class_of[x] = ci;
                }
            }
            // Signature of x: (own class, sorted pairs (partner class,
            // class of meet/join/implies result)) — an isomorphism invariant.
            let sig = |x: usize| {
                let mut pairs: Vec<(usize, usize, usize, usize)> = (0..norm.size)
                    .map(|y| {
                        (
                            class_of[y],
                            class_of[norm.meet[x][y]],
                            class_of[norm.join[x][y]],
                            class_of[norm.implies[x][y]],
                        )
                    })
                    .collect();
                pairs.sort_unstable();
                (class_of[x], pairs)
            };
            // Group elements by (old cell, signature); order the new cells
            // canonically: by old cell, then by signature (so isomorphic
            // algebras always lay out their cells in the same order), then
            // by first element as a deterministic tie-breaker.
            let mut groups: Vec<Vec<usize>> = Vec::new();
            let mut placed = vec![false; norm.size];
            for old in 0..cells.len() {
                // All signatures inside one old cell, with their elements.
                let mut entries: Vec<(Vec<(usize, usize, usize, usize)>, usize)> = Vec::new();
                for &x in &cells[old] {
                    if placed[x] {
                        continue;
                    }
                    let (_, pairs) = sig(x);
                    entries.push((pairs, x));
                }
                entries.sort_unstable();
                // Split by signature.
                let mut i = 0;
                while i < entries.len() {
                    let mut j = i + 1;
                    while j < entries.len() && entries[j].0 == entries[i].0 {
                        j += 1;
                    }
                    let mut cell: Vec<usize> = entries[i..j].iter().map(|&(_, x)| x).collect();
                    cell.sort_unstable();
                    for &x in &cell {
                        placed[x] = true;
                    }
                    groups.push(cell);
                    i = j;
                }
            }
            if groups.len() == cells.len()
                && groups.iter().zip(cells.iter()).all(|(g, c)| g == c)
            {
                *cells = groups;
                return;
            }
            *cells = groups;
        }
    }

    // Flatten the tables under the given element order (perm[x] = the new
    // name of element x).
    fn key_of(norm: &Algebra, perm: &[usize]) -> Vec<usize> {
        let n = norm.size;
        let mut nm = vec![vec![0; n]; n];
        let mut nj = vec![vec![0; n]; n];
        let mut ni = vec![vec![0; n]; n];
        for x in 0..n {
            for y in 0..n {
                nm[perm[x]][perm[y]] = perm[norm.meet[x][y]];
                nj[perm[x]][perm[y]] = perm[norm.join[x][y]];
                ni[perm[x]][perm[y]] = perm[norm.implies[x][y]];
            }
        }
        let mut key = Vec::with_capacity(n * n * 3);
        key.extend(nm.iter().flatten());
        key.extend(nj.iter().flatten());
        key.extend(ni.iter().flatten());
        key
    }

    // Search over individualizations.  At a terminal partition every cell
    // is a singleton, and the cell order (as laid out by refine() and the
    // individualization splits) is the canonical element order: the
    // relabeling assigns names 1..n-2 to it (bottom and top keep 0 and
    // n-1).  The minimal flattened table over all terminal partitions is
    // the canonical form.
    fn search(
        norm: &Algebra,
        cells: &mut Vec<Vec<usize>>,
        best: &mut Option<Vec<usize>>,
    ) {
        refine(norm, cells);
        // Find the first non-singleton cell.
        let target = cells.iter().position(|c| c.len() > 1);
        let Some(ti) = target else {
            // Terminal: every cell is a singleton, so `cells` already
            // determines a total element order (the order refine() laid
            // the cells out).  Assign names 1..n-2 to that order; bottom
            // and top keep 0 and n-1.
            let mut perm = vec![0usize; norm.size];
            perm[norm.bottom] = 0;
            perm[norm.top] = norm.size - 1;
            let mut next = 1usize;
            for cell in cells.iter() {
                let &x = &cell[0];
                if x == norm.bottom || x == norm.top {
                    continue;
                }
                perm[x] = next;
                next += 1;
            }
            let key = key_of(norm, &perm);
            if best.as_ref().is_none_or(|b| &key < b) {
                *best = Some(key);
            }
            return;
        };
        // Individualize: try each element of the first non-singleton cell.
        let cell = cells[ti].clone();
        for &x in &cell {
            let mut cells2 = cells.clone();
            cells2[ti].retain(|&y| y != x);
            cells2.insert(ti + 1, vec![x]);
            search(norm, &mut cells2, best);
        }
    }

    let mut cells: Vec<Vec<usize>> = vec![(0..n).collect()];
    search(&norm, &mut cells, &mut best);
    best.expect("every algebra has at least one terminal partition")
}

/// A copy of the algebra whose elements are relabeled so that `bottom` is 0
/// and `top` is `size - 1`, preserving the tables.
fn normalized(a: &Algebra) -> Algebra {
    let n = a.size;
    // Map each element to a new name: bottom -> 0, top -> n-1, the rest in
    // the order they appear.
    let mut new_name = vec![usize::MAX; n];
    new_name[a.bottom] = 0;
    new_name[a.top] = n - 1;
    let mut next = 1usize;
    for slot in new_name.iter_mut() {
        if *slot == usize::MAX {
            *slot = next;
            next += 1;
        }
    }
    let relabel = |t: &Vec<Vec<usize>>| {
        let mut out = vec![vec![0; n]; n];
        for x in 0..n {
            for y in 0..n {
                out[new_name[x]][new_name[y]] = new_name[t[x][y]];
            }
        }
        out
    };
    Algebra {
        size: n,
        meet: relabel(&a.meet),
        join: relabel(&a.join),
        implies: relabel(&a.implies),
        bottom: 0,
        top: n - 1,
        labels: (0..n).map(|i| i.to_string()).collect(),
    }
}

/// Are two algebras isomorphic (same structure, up to renaming elements)?
///
/// Two finite algebras are isomorphic iff their canonical forms coincide.
pub fn is_isomorphic(a: &Algebra, b: &Algebra) -> bool {
    if a.size != b.size {
        return false;
    }
    canonical_form(a) == canonical_form(b)
}

/// Is the formula valid in the algebra, i.e. `⊤` under every valuation?
///
/// ```
/// use heyting::{Formula, chain_three, valid_in};
///
/// let a = chain_three();
/// let p = Formula::atom(0);
/// // Peirce's law fails in the three-element chain...
/// let peirce = ((p.clone().implies(Formula::atom(1))).implies(p.clone())).implies(p);
/// assert!(!valid_in(&a, &peirce));
/// // ...but the axiom p -> p holds.
/// assert!(valid_in(&a, &Formula::atom(0).implies(Formula::atom(0))));
/// ```
pub fn valid_in(a: &Algebra, f: &Formula) -> bool {
    let atoms = f.atom_count();
    all_valuations(atoms, a.size()).all(|v| f.eval(a, &v) == a.top)
}

/// Is the formula valid in every finite Heyting algebra with up to 5
/// elements (and in the larger subalgebras of the small downset algebras)?
///
/// This is the small-scale intuitionistic validity check: the formulas that
/// pass are intuitionistically provable, and every formula with a
/// counterexample in a finite Heyting algebra of at most 5 elements is
/// rejected.  (A formula could still fail in a larger or infinite algebra
/// and pass here -- the bound is documented and intentional.)
///
/// ```
/// use heyting::{Formula, valid};
///
/// let p = Formula::atom(0);
/// let q = Formula::atom(1);
///
/// // Intuitionistic tautologies hold: p -> ¬¬p, and the double negation
/// // of excluded middle ¬¬(p ∨ ¬p).
/// assert!(valid(&p.clone().implies(!(!p.clone()))));
/// let lem = p.clone().or(!p.clone());
/// assert!(valid(&(!(!lem.clone()))));
/// // ...while excluded middle itself is not.
/// assert!(!valid(&lem));
/// let _ = q;
/// ```
pub fn valid(f: &Formula) -> bool {
    all_finite_heyting_algebras().iter().all(|a| valid_in(a, f))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::bool_algebra;

    #[test]
    fn enumeration_sizes_are_complete_up_to_five() {
        let algebras = all_finite_heyting_algebras();
        let mut by_size: HashMap<usize, usize> = HashMap::new();
        for a in algebras {
            *by_size.entry(a.size()).or_insert(0) += 1;
        }
        // Complete up to size 5: a Heyting algebra of size <= 5 has at
        // most 4 join-irreducibles, so by Birkhoff duality it is a subalgebra
        // of the downset algebra of a poset on <= 4 elements, which the
        // enumeration covers.  The counts match the known numbers of finite
        // distributive lattices (OEIS A006982: 1, 1, 1, 2, 3 for sizes 1..5;
        // size 6 has five distributive lattices, and the enumeration covers
        // four of them -- the 6-element chain needs 5 join-irreducibles,
        // hence a 5-element poset, beyond the <= 4-element bound).
        assert_eq!(by_size.get(&1), Some(&1));
        assert_eq!(by_size.get(&2), Some(&1));
        assert_eq!(by_size.get(&3), Some(&1));
        assert_eq!(by_size.get(&4), Some(&2));
        assert_eq!(by_size.get(&5), Some(&3));
        assert_eq!(by_size.get(&6), Some(&4));
        // Every algebra in the enumeration satisfies the Heyting adjunction.
        for a in algebras {
            for x in 0..a.size {
                for y in 0..a.size {
                    let ab = a.implies(x, y);
                    assert!(a.leq(a.meet(x, ab), y));
                    for c in 0..a.size {
                        if a.leq(a.meet(x, c), y) {
                            assert!(a.leq(c, ab));
                        }
                    }
                }
            }
        }
    }

    #[test]
    fn subalgebras_are_closed() {
        // Every returned subalgebra of the downset algebra of a 4-element
        // antichain (the 16-element Boolean algebra) must itself be closed
        // under the operations.
        let poset = Poset::from_less(4, |x, y| x == y);
        let base = poset.downset_algebra();
        for sub in subalgebras(&base) {
            for x in 0..sub.size {
                for y in 0..sub.size {
                    assert!(sub.meet[x][y] < sub.size);
                    assert!(sub.join[x][y] < sub.size);
                    assert!(sub.implies[x][y] < sub.size);
                }
            }
        }
    }

    /// Relabel the elements of an algebra by the permutation `perm`
    /// (`perm[x]` is the new name of element `x`).
    fn relabel(a: &Algebra, perm: &[usize]) -> Algebra {
        let n = a.size;
        let map = |x: usize| perm[x];
        let relabel_table = |t: &Vec<Vec<usize>>| {
            let mut out = vec![vec![0; n]; n];
            for x in 0..n {
                for y in 0..n {
                    out[map(x)][map(y)] = map(t[x][y]);
                }
            }
            out
        };
        let mut b = a.clone();
        b.meet = relabel_table(&a.meet);
        b.join = relabel_table(&a.join);
        b.implies = relabel_table(&a.implies);
        b.bottom = map(a.bottom);
        b.top = map(a.top);
        b.labels = (0..n).map(|x| a.labels[map(x)].clone()).collect();
        b
    }

    #[test]
    fn is_isomorphic_detects_renaming() {
        // The 4-element Boolean algebra and a copy with permuted names.
        let a = bool_algebra(2);
        let b = bool_algebra(2);
        assert!(is_isomorphic(&a, &b));
        // A 3-element chain is not isomorphic to a 4-element Boolean algebra.
        assert!(!is_isomorphic(&bool_algebra(2), &crate::chain_three()));
        // Permuting the element order of one copy still gives an isomorphism.
        let permuted = relabel(&b, &[0, 2, 3, 1]);
        assert!(is_isomorphic(&a, &permuted));
        // The 4-chain and the 4-element Boolean algebra are not isomorphic.
        let chain4 = crate::Poset::from_relations(4, &[(0, 1), (1, 2), (2, 3)]).downset_algebra();
        assert!(!is_isomorphic(&chain4, &a));
    }

    #[test]
    fn validity_agrees_with_known_logic() {
        let p = Formula::atom(0);
        let q = Formula::atom(1);

        // Intuitionistic tautologies.
        assert!(valid(&p.clone().implies(q.clone().implies(p.clone()))));
        assert!(valid(&p.clone().implies(p.clone().or(q.clone()))));
        assert!(valid(&p.clone().implies(!(!p.clone())))); // p -> ¬¬p

        // Classical non-tautologies: LEM, DNE, Peirce.
        assert!(!valid(&p.clone().or(!p.clone())));
        assert!(!valid(&(!(!p.clone())).implies(p.clone())));
        assert!(!valid(&p.clone().or(!p.clone()).implies(p.clone())));
        let peirce = ((p.clone().implies(q.clone())).implies(p.clone())).implies(p.clone());
        assert!(!valid(&peirce));
    }

    #[test]
    fn valid_in_boolean_accepts_classical_laws() {
        let bool2 = bool_algebra(1);
        let p = Formula::atom(0);
        assert!(valid_in(&bool2, &p.clone().or(!p.clone())));
        assert!(valid_in(&bool2, &(!(!p.clone())).implies(p.clone())));
    }

    #[test]
    fn canonical_form_is_an_isomorphism_invariant() {
        // Re-label the same algebra by permuting element names; canonical
        // forms must agree.
        let a = bool_algebra(2);
        let b = relabel(&a, &[0, 2, 3, 1]);
        assert_eq!(canonical_form(&a), canonical_form(&b));
        // Different algebras have different canonical forms.
        let chain4 = crate::Poset::from_relations(4, &[(0, 1), (1, 2), (2, 3)]).downset_algebra();
        assert_ne!(canonical_form(&chain4), canonical_form(&a));
    }
}
