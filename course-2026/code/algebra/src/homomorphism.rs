//! Group homomorphisms: maps that preserve the operation, their kernels and
//! images, cosets, and the quotient group behind the first isomorphism
//! theorem.

use crate::traits::Group;

/// Whether `f: G -> H` preserves the operation on every pair of `elems`.
///
/// `elems` is the complete element list of a finite group `G`, and the check
/// is `f(a op b) == f(a) op f(b)` for all `a`, `b`.
pub fn is_homomorphism<G: Group, H: Group>(elems: &[G], f: &dyn Fn(&G) -> H) -> bool {
    for a in elems {
        for b in elems {
            if f(&a.op(b)) != f(a).op(&f(b)) {
                return false;
            }
        }
    }
    true
}

/// The kernel of `f`: the elements of `G` sent to the identity of `H`.
pub fn kernel<G: Group, H: Group>(elems: &[G], f: &dyn Fn(&G) -> H) -> Vec<G> {
    let e = H::identity();
    elems.iter().filter(|g| f(g) == e).cloned().collect()
}

/// The image of `f`, with duplicates removed (in first-appearance order).
pub fn image<G: Group, H: Group>(elems: &[G], f: &dyn Fn(&G) -> H) -> Vec<H> {
    let mut out: Vec<H> = Vec::new();
    for g in elems {
        let h = f(g);
        if !out.contains(&h) {
            out.push(h);
        }
    }
    out
}

/// The left cosets `gK` of a subgroup `K` in a finite group, one per coset.
///
/// `group` is the complete element list, and `subgroup` is a subgroup of it
/// (its own complete element list).
/// Returns each distinct coset `{ g*k : k in K }` as a list of group elements.
pub fn left_cosets<G: Group>(group: &[G], subgroup: &[G]) -> Vec<Vec<G>> {
    let mut seen: Vec<G> = Vec::new();
    let mut out: Vec<Vec<G>> = Vec::new();
    for g in group {
        let coset: Vec<G> = subgroup.iter().map(|k| g.op(k)).collect();
        if coset.iter().any(|x| seen.contains(x)) {
            continue;
        }
        seen.extend(coset.iter().cloned());
        out.push(coset);
    }
    out
}

/// Whether `subgroup` is normal in `group`: `g k g^{-1}` stays in `subgroup`
/// for every `g` and `k`.
pub fn is_normal<G: Group>(group: &[G], subgroup: &[G]) -> bool {
    for g in group {
        for k in subgroup {
            let c = g.op(k).op(&g.inverse());
            if !subgroup.contains(&c) {
                return false;
            }
        }
    }
    true
}

/// The coset containing `g.op(h)`, where `g` and `h` are representatives of
/// two cosets of `cosets` (the quotient's coset list from [`left_cosets`]).
///
/// For a normal subgroup this coset does not depend on the choice of
/// representatives -- that independence is exactly what makes the quotient a
/// group.
pub fn coset_product<G: Group>(cosets: &[Vec<G>], g: &G, h: &G) -> Vec<G> {
    let gh = g.op(h);
    cosets
        .iter()
        .find(|c| c.contains(&gh))
        .cloned()
        .expect("product coset must be present in the quotient")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::Zn;

    #[test]
    fn reduction_mod_3_is_a_homomorphism() {
        let z6: Vec<Zn<6>> = (0..6).map(Zn::new).collect();
        let phi = |z: &Zn<6>| Zn::<3>::new(z.0 % 3);
        assert!(is_homomorphism(&z6, &phi));
        assert_eq!(kernel(&z6, &phi), vec![Zn::new(0), Zn::new(3)]);
        assert_eq!(image(&z6, &phi).len(), 3);
    }

    #[test]
    fn kernel_cosets_partition_the_group() {
        let z6: Vec<Zn<6>> = (0..6).map(Zn::new).collect();
        let phi = |z: &Zn<6>| Zn::<3>::new(z.0 % 3);
        let k = kernel(&z6, &phi);
        let cosets = left_cosets(&z6, &k);
        assert_eq!(cosets.len(), 3);
        assert!(is_normal(&z6, &k));
        // Representatives g = 1, h = 2: (1+K)(2+K) = 3+K = 0+K = {0, 3}.
        let product = coset_product(&cosets, &Zn::new(1), &Zn::new(2));
        assert_eq!(product, cosets[0]);
    }

    #[test]
    fn a_non_homomorphic_map_is_rejected() {
        let z6: Vec<Zn<6>> = (0..6).map(Zn::new).collect();
        // The constant map to 1 is not a homomorphism: f(0+0) = 1 != 1+1 = 2.
        let f = |_: &Zn<6>| Zn::<3>::new(1);
        assert!(!is_homomorphism(&z6, &f));
    }
}
