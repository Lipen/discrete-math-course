//! A Mamdani fuzzy inference engine.
//!
//! A linguistic variable takes fuzzy sets as values ("temperature is warm").
//! A rule base says "if temperature is hot then cooling is strong". The
//! Mamdani pipeline turns crisp inputs into a crisp output in four steps:
//!
//! 1. *fuzzification*: the degree of membership of each input in its terms,
//! 2. *rule firing*: each rule's antecedent strength (a t-norm over the
//!    antecedent degrees),
//! 3. *aggregation*: each consequent is clipped at its firing strength and
//!    the clipped sets are united with `max`,
//! 4. *defuzzification*: the aggregated set is reduced to one number by
//!    centroid, mean-of-max, or bisector.

use crate::set::FuzzySet;
use crate::tnorm::TNorm;

/// A named fuzzy set: one term of a linguistic variable.
pub struct Term {
    pub name: &'static str,
    pub set: FuzzySet,
}

/// A linguistic variable: a name and its terms, all on one numeric domain.
pub struct Variable {
    pub name: &'static str,
    pub terms: Vec<Term>,
}

impl Variable {
    /// The term with the given name, if any.
    pub fn term(&self, name: &str) -> Option<&Term> {
        self.terms.iter().find(|t| t.name == name)
    }

    /// Degree to which the crisp value `x` belongs to the named term.
    pub fn degree(&self, term: &str, x: f64) -> f64 {
        self.term(term).map(|t| t.set.membership(x)).unwrap_or(0.0)
    }
}

/// A Mamdani rule: "if `v1` is `t1` and `v2` is `t2` ... then `out` is `t`".
#[derive(Clone, Debug)]
pub struct Rule {
    pub antecedents: Vec<(&'static str, &'static str)>,
    pub consequent: (&'static str, &'static str),
}

/// Defuzzification methods for turning the aggregated set into one number.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Defuzzifier {
    /// The center of gravity: `∫ x mu dx / ∫ mu dx`. Smooth, averages the curve.
    Centroid,
    /// The mean of the points where `mu` is maximal. "Take the surest value".
    MeanOfMax,
    /// The vertical line that splits the area under `mu` in half.
    Bisector,
}

/// A complete Mamdani system: linguistic variables (inputs and outputs) plus
/// a rule base and the t-norm used to combine antecedent degrees.
pub struct Mamdani {
    pub variables: Vec<Variable>,
    pub rules: Vec<Rule>,
    pub tnorm: TNorm,
}

impl Mamdani {
    /// The variable with the given name, if any.
    pub fn variable(&self, name: &str) -> Option<&Variable> {
        self.variables.iter().find(|v| v.name == name)
    }

    /// Degree of membership of the crisp value `x` in term `term` of `var`.
    pub fn fuzzify(&self, var: &str, term: &str, x: f64) -> f64 {
        self.variable(var).map(|v| v.degree(term, x)).unwrap_or(0.0)
    }

    /// Firing strength of a rule: the t-norm over its antecedent degrees.
    pub fn firing_strength(&self, rule: &Rule, inputs: &[(&str, f64)]) -> f64 {
        let mut f = 1.0;
        for &(var, term) in &rule.antecedents {
            let x = match inputs.iter().find(|&&(v, _)| v == var) {
                Some(&(_, value)) => value,
                None => return 0.0,
            };
            f = self.tnorm.norm(f, self.fuzzify(var, term, x));
        }
        f
    }

    /// The aggregated output set: each consequent clipped at its rule's
    /// firing strength, then all united with `max`.
    pub fn aggregate(&self, inputs: &[(&str, f64)], out_var: &str) -> FuzzySet {
        let mut acc: Option<FuzzySet> = None;
        for rule in &self.rules {
            if rule.consequent.0 != out_var {
                continue;
            }
            let f = self.firing_strength(rule, inputs);
            if f <= 0.0 {
                continue;
            }
            if let Some(out) = self.variable(out_var) {
                if let Some(term) = out.term(rule.consequent.1) {
                    let clipped = term.set.clip(f);
                    acc = Some(match acc {
                        None => clipped,
                        Some(a) => a.union(&clipped),
                    });
                }
            }
        }
        acc.unwrap_or_else(|| match self.variable(out_var) {
            Some(out) => FuzzySet::new(
                out.terms
                    .iter()
                    .flat_map(|t| t.set.points.clone())
                    .collect(),
            ),
            None => FuzzySet::new(vec![]),
        })
    }

    /// The full inference: aggregate then defuzzify.
    pub fn infer(&self, inputs: &[(&str, f64)], out_var: &str, defuzz: Defuzzifier) -> f64 {
        defuzzify(&self.aggregate(inputs, out_var), defuzz)
    }
}

/// Defuzzify a piecewise-linear fuzzy set into a single crisp number.
pub fn defuzzify(set: &FuzzySet, method: Defuzzifier) -> f64 {
    match method {
        Defuzzifier::Centroid => centroid(set),
        Defuzzifier::MeanOfMax => mean_of_max(set),
        Defuzzifier::Bisector => bisector(set),
    }
}

/// The center of gravity: `∫ x mu dx / ∫ mu dx` over the set's span.
pub fn centroid(set: &FuzzySet) -> f64 {
    let pts = &set.points;
    if pts.len() < 2 {
        return if pts.is_empty() { 0.0 } else { pts[0].0 };
    }
    let mut area = 0.0;
    let mut moment = 0.0;
    for w in pts.windows(2) {
        let (x0, y0) = w[0];
        let (x1, y1) = w[1];
        let dx = x1 - x0;
        if dx == 0.0 {
            continue;
        }
        let m = (y1 - y0) / dx;
        let b = y0 - m * x0;
        area += m * (x1 * x1 - x0 * x0) / 2.0 + b * dx;
        moment += m * (x1 * x1 * x1 - x0 * x0 * x0) / 3.0 + b * (x1 * x1 - x0 * x0) / 2.0;
    }
    if area == 0.0 {
        return 0.0;
    }
    moment / area
}

/// The mean of the points where the membership is maximal.
pub fn mean_of_max(set: &FuzzySet) -> f64 {
    let regions = set.alpha_cut(set.height());
    if regions.is_empty() {
        return 0.0;
    }
    let mut total_w = 0.0;
    let mut acc = 0.0;
    for &(a, b) in &regions {
        let w = b - a;
        total_w += w;
        acc += (a + b) / 2.0 * w;
    }
    if total_w > 0.0 {
        acc / total_w
    } else {
        // Zero-width regions (isolated peaks): average the peaks.
        regions.iter().map(|&(a, _)| a).sum::<f64>() / regions.len() as f64
    }
}

/// The vertical line that splits the area under `mu` in half.
pub fn bisector(set: &FuzzySet) -> f64 {
    let pts = &set.points;
    if pts.len() < 2 {
        return if pts.is_empty() { 0.0 } else { pts[0].0 };
    }
    let mut total = 0.0;
    for w in pts.windows(2) {
        let (x0, y0) = w[0];
        let (x1, y1) = w[1];
        total += (y0 + y1) / 2.0 * (x1 - x0);
    }
    if total == 0.0 {
        return 0.0;
    }
    let target = total / 2.0;
    let mut acc = 0.0;
    for w in pts.windows(2) {
        let (x0, y0) = w[0];
        let (x1, y1) = w[1];
        let dx = x1 - x0;
        let piece = (y0 + y1) / 2.0 * dx;
        if acc + piece >= target {
            let need = target - acc;
            let m = (y1 - y0) / dx;
            let c = y0;
            let d = m / 2.0;
            if d.abs() < 1e-12 {
                return if c.abs() < 1e-12 { x0 } else { x0 + need / c };
            }
            let disc = c * c + 4.0 * d * need;
            let t = (-c + disc.sqrt()) / (2.0 * d);
            return x0 + t;
        }
        acc += piece;
    }
    pts[pts.len() - 1].0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn trapezoid_defuzzification_matches_the_chapter() {
        // The trapezoid with vertices (2,0), (2.5,1), (3,1), (4.5,0).
        let t = FuzzySet::new(vec![(2.0, 0.0), (2.5, 1.0), (3.0, 1.0), (4.5, 0.0)]);
        assert!((centroid(&t) - 3.0555).abs() < 1e-3);
        assert!((mean_of_max(&t) - 2.75).abs() < 1e-9);
        assert!((bisector(&t) - 3.0).abs() < 1e-9);
    }

    #[test]
    fn triangular_centroid_is_the_mode() {
        let t = FuzzySet::new(vec![(1.0, 0.0), (4.0, 1.0), (7.0, 0.0)]);
        assert!((centroid(&t) - 4.0).abs() < 1e-9);
        assert!((mean_of_max(&t) - 4.0).abs() < 1e-9);
        assert!((bisector(&t) - 4.0).abs() < 1e-9);
    }

    fn ac() -> Mamdani {
        // The air conditioner from the chapter: temperature -> cooling.
        let hot = FuzzySet::new(vec![(0.0, 0.0), (25.0, 0.0), (30.0, 1.0), (40.0, 1.0)]);
        let warm = FuzzySet::new(vec![
            (0.0, 0.0),
            (18.0, 0.0),
            (24.0, 1.0),
            (34.0, 0.0),
            (40.0, 0.0),
        ]);
        let temperature = Variable {
            name: "temperature",
            terms: vec![
                Term {
                    name: "hot",
                    set: hot,
                },
                Term {
                    name: "warm",
                    set: warm,
                },
            ],
        };
        let strong = FuzzySet::new(vec![(0.0, 0.0), (60.0, 0.0), (80.0, 1.0), (100.0, 1.0)]);
        let weak = FuzzySet::new(vec![
            (0.0, 0.0),
            (10.0, 0.0),
            (35.0, 1.0),
            (60.0, 0.0),
            (100.0, 0.0),
        ]);
        let cooling = Variable {
            name: "cooling",
            terms: vec![
                Term {
                    name: "strong",
                    set: strong,
                },
                Term {
                    name: "weak",
                    set: weak,
                },
            ],
        };
        Mamdani {
            variables: vec![temperature, cooling],
            rules: vec![
                Rule {
                    antecedents: vec![("temperature", "hot")],
                    consequent: ("cooling", "strong"),
                },
                Rule {
                    antecedents: vec![("temperature", "warm")],
                    consequent: ("cooling", "weak"),
                },
            ],
            tnorm: TNorm::Zadeh,
        }
    }

    #[test]
    fn firing_strengths_match_the_chapter() {
        let c = ac();
        let hot_rule = &c.rules[0];
        let warm_rule = &c.rules[1];
        let inputs = &[("temperature", 27.0)];
        // mu_hot(27) = (27 - 25) / 5 = 0.4.
        assert!((c.firing_strength(hot_rule, inputs) - 0.4).abs() < 1e-12);
        // mu_warm(27) = (34 - 27) / 10 = 0.7.
        assert!((c.firing_strength(warm_rule, inputs) - 0.7).abs() < 1e-12);
    }

    #[test]
    fn inference_is_monotone_in_temperature() {
        let c = ac();
        let out = |t: f64| c.infer(&[("temperature", t)], "cooling", Defuzzifier::Centroid);
        // Higher temperature means strictly more cooling.
        assert!(out(20.0) < out(27.0));
        assert!(out(27.0) < out(33.0));
        // Outputs stay on the cooling scale [0, 100].
        for t in [18.0, 22.0, 27.0, 33.0, 38.0] {
            let v = out(t);
            assert!((0.0..=100.0).contains(&v), "out({t}) = {v}");
        }
    }
}
