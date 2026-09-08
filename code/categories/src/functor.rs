//! Functors between finite categories and the functor laws.

use crate::category::{FiniteCategory, Morphism, ObjId};

/// A functor between two finite categories, given by images of objects and morphisms.
///
/// `obj_map[i]` is the image of the `i`-th object of the source category, and `mor_map[i]` is the image of the `i`-th morphism, a morphism of the target category.
pub struct Functor {
    /// Image of each source object.
    pub obj_map: Vec<ObjId>,
    /// Image of each source morphism.
    pub mor_map: Vec<Morphism>,
}

impl Functor {
    /// Whether the mapping preserves identities and composition.
    ///
    /// The check also verifies the shape: one image per object and per morphism, each image landing in the right hom-set of the target category.
    /// A broken source or target category also fails the check.
    pub fn check(&self, source: &FiniteCategory, target: &FiniteCategory) -> bool {
        if self.obj_map.len() != source.objects.len()
            || self.mor_map.len() != source.morphisms.len()
        {
            return false;
        }
        if self.obj_map.iter().any(|o| o.0 >= target.objects.len()) {
            return false;
        }
        for (m, image) in source.morphisms.iter().zip(&self.mor_map) {
            if image.src != self.obj_map[m.src.0] || image.dst != self.obj_map[m.dst.0] {
                return false;
            }
            if target.find_morphism(&image.name).is_none() {
                return false;
            }
        }
        for (k, m) in source.morphisms.iter().enumerate() {
            let is_identity = *m == source.identity(m.src);
            if is_identity && self.mor_map[k] != target.identity(self.obj_map[m.src.0]) {
                return false;
            }
        }
        for (i, f) in source.morphisms.iter().enumerate() {
            for (j, g) in source.morphisms.iter().enumerate() {
                if f.dst != g.src {
                    continue;
                }
                let composite = source.composition(f, g);
                let k = match &composite {
                    Some(c) => source.find_morphism(&c.name).unwrap(),
                    None => return false,
                };
                let composed = target.composition(&self.mor_map[i], &self.mor_map[j]);
                if composed.as_ref() != Some(&self.mor_map[k]) {
                    return false;
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
    fn identity_functor_is_a_functor() {
        let cat = FiniteCategory::from_poset(&[&[true, true], &[false, true]]);
        let f = Functor {
            obj_map: (0..cat.objects.len()).map(ObjId).collect(),
            mor_map: cat.morphisms.clone(),
        };
        assert!(f.check(&cat, &cat));
    }
}
