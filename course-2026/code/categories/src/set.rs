//! Set-valued functors, natural transformations, and the Yoneda bijection.

use crate::category::{FiniteCategory, ObjId};

/// A functor from a finite category into finite sets.
///
/// `obj_map[o]` is the set assigned to the object with index `o`, listed as element names.
/// `mor_map[i]` is the function assigned to the `i`-th morphism of the category: for every element of the source set, the index of its image in the target set.
pub struct SetFunctor<'a> {
    /// The category the functor lives over.
    pub cat: &'a FiniteCategory,
    /// The set assigned to each object.
    pub obj_map: Vec<Vec<String>>,
    /// The function assigned to each morphism of the category.
    pub mor_map: Vec<Vec<usize>>,
}

impl SetFunctor<'_> {
    /// Whether the assignment maps every set into the right target set and preserves identities and composition.
    pub fn check(&self) -> bool {
        let cat = self.cat;
        if self.obj_map.len() != cat.objects.len() || self.mor_map.len() != cat.morphisms.len() {
            return false;
        }
        for (i, m) in cat.morphisms.iter().enumerate() {
            let f = &self.mor_map[i];
            if f.len() != self.obj_map[m.src.0].len() {
                return false;
            }
            if f.iter().any(|&e| e >= self.obj_map[m.dst.0].len()) {
                return false;
            }
        }
        for o in 0..cat.objects.len() {
            let id = cat.identity(ObjId(o));
            let k = cat.find_morphism(&id.name).unwrap();
            if self.mor_map[k].iter().enumerate().any(|(e, &v)| v != e) {
                return false;
            }
        }
        for (i, f) in cat.morphisms.iter().enumerate() {
            for (j, g) in cat.morphisms.iter().enumerate() {
                if f.dst != g.src {
                    continue;
                }
                let composite = match cat.composition(f, g) {
                    Some(c) => c,
                    None => return false,
                };
                let k = cat.find_morphism(&composite.name).unwrap();
                for e in 0..self.mor_map[i].len() {
                    if self.mor_map[j][self.mor_map[i][e]] != self.mor_map[k][e] {
                        return false;
                    }
                }
            }
        }
        true
    }
}

/// The covariant hom-functor `Hom(a, -)` of a finite category.
///
/// The set assigned to an object `x` lists the morphisms from `a` to `x` by name, and a morphism `m: x -> y` acts by post-composition, sending `h` to `m` after `h`.
/// Panics when the object index is out of range.
pub fn hom_functor<'a>(cat: &'a FiniteCategory, a: ObjId) -> SetFunctor<'a> {
    assert!(a.0 < cat.objects.len(), "object index {} out of range", a.0);
    let obj_map: Vec<Vec<String>> = (0..cat.objects.len())
        .map(|x| {
            cat.morphisms
                .iter()
                .filter(|m| m.src == a && m.dst == ObjId(x))
                .map(|m| m.name.clone())
                .collect()
        })
        .collect();
    let mut mor_map = Vec::new();
    for m in &cat.morphisms {
        let mut f = Vec::new();
        for h in &cat.morphisms {
            if h.src == a && h.dst == m.src {
                let image = cat.compose(h, m);
                let pos = obj_map[m.dst.0]
                    .iter()
                    .position(|n| *n == image.name)
                    .unwrap();
                f.push(pos);
            }
        }
        mor_map.push(f);
    }
    SetFunctor {
        cat,
        obj_map,
        mor_map,
    }
}

/// A natural transformation between two set-valued functors over one category.
///
/// `components[o][e]` is the image of the `e`-th element of the source set at object `o`, inside the target set at the same object.
#[derive(Clone, Debug)]
pub struct NaturalTransformation {
    /// The component function at each object.
    pub components: Vec<Vec<usize>>,
}

/// Every function from a `dom`-element set to a `cod`-element set, as index tuples.
fn all_functions(dom: usize, cod: usize) -> Vec<Vec<usize>> {
    let total = cod.pow(dom as u32);
    (0..total)
        .map(|k| (0..dom).map(|e| k / cod.pow(e as u32) % cod).collect())
        .collect()
}

/// Whether one family of components makes every square over the morphisms of the category commute.
fn is_natural(
    cat: &FiniteCategory,
    from: &SetFunctor,
    to: &SetFunctor,
    family: &[Vec<usize>],
) -> bool {
    for (i, m) in cat.morphisms.iter().enumerate() {
        for e in 0..from.obj_map[m.src.0].len() {
            let lhs = to.mor_map[i][family[m.src.0][e]];
            let rhs = family[m.dst.0][from.mor_map[i][e]];
            if lhs != rhs {
                return false;
            }
        }
    }
    true
}

/// All natural transformations from `from` to `to`, found by exhaustive search.
///
/// Both functors must live over the same category.
/// The search enumerates every family of component functions and keeps the families whose squares commute for every morphism.
/// Panics when the functors live over different categories.
pub fn natural_transformations(from: &SetFunctor, to: &SetFunctor) -> Vec<NaturalTransformation> {
    assert!(
        std::ptr::eq(from.cat, to.cat),
        "the functors must live over the same category"
    );
    let cat = from.cat;
    let mut families: Vec<Vec<Vec<usize>>> = vec![Vec::new()];
    for o in 0..cat.objects.len() {
        let dom = from.obj_map[o].len();
        let cod = to.obj_map[o].len();
        families = families
            .into_iter()
            .flat_map(|partial| {
                all_functions(dom, cod).into_iter().map(move |component| {
                    let mut grown = partial.clone();
                    grown.push(component);
                    grown
                })
            })
            .collect();
    }
    families
        .into_iter()
        .filter(|family| is_natural(cat, from, to, family))
        .map(|components| NaturalTransformation { components })
        .collect()
}

/// The Yoneda bijection on a finite category, checked by exhaustive search.
///
/// Builds `Nat(Hom(a, -), f)` by enumeration, then checks that the canonical map sending a transformation to `τ_a(id_a)` is injective and covers every element of the set at `a`.
/// The functor `f` must live over `cat`.
/// Returns the natural transformations and whether the canonical map is a bijection onto the set at `a`.
/// Panics when the functor lives over a different category.
pub fn yoneda(
    cat: &FiniteCategory,
    a: ObjId,
    f: &SetFunctor,
) -> (Vec<NaturalTransformation>, bool) {
    assert!(
        std::ptr::eq(f.cat, cat),
        "the functor must live over the given category"
    );
    let hom = hom_functor(cat, a);
    let transformations = natural_transformations(&hom, f);
    let id_name = cat.identity(a).name;
    let id_position = hom.obj_map[a.0].iter().position(|n| *n == id_name).unwrap();
    let images: Vec<usize> = transformations
        .iter()
        .map(|t| t.components[a.0][id_position])
        .collect();
    let mut distinct = images.clone();
    distinct.sort_unstable();
    distinct.dedup();
    let bijective = distinct.len() == images.len() && images.len() == f.obj_map[a.0].len();
    (transformations, bijective)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn all_functions_counts() {
        assert_eq!(all_functions(2, 3).len(), 9);
        assert_eq!(all_functions(0, 3), vec![Vec::<usize>::new()]);
        assert!(all_functions(2, 0).is_empty());
    }
}
