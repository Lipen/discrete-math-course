//! Finite-domain semantics: enumerating structures and deciding
//! satisfiability and validity by exhaustion.

use std::collections::{HashMap, HashSet};

use crate::formula::Formula;
use crate::signature::Signature;
use crate::structure::Structure;

/// A canonical domain of `n` individuals named `"0"`, `"1"`, ..., `"n-1"`.
pub fn domain(n: usize) -> Vec<String> {
    (0..n).map(|i| i.to_string()).collect()
}

/// Every structure over `domain` that interprets the symbols of `sig`.
pub fn enumerate_structures(sig: &Signature, domain: &[String]) -> Vec<Structure> {
    assert!(!domain.is_empty(), "the domain must be non-empty");
    let mut acc = vec![Structure::new(domain.to_vec())];

    for c in &sig.constants {
        acc = extend(acc, domain, |s, value| s.with_constant(c, &value));
    }

    for (name, arity) in &sig.functions {
        let tables = function_tables(domain, &tuples(domain, *arity));
        acc = extend(acc, &tables, |s, table| s.with_function(name, table));
    }

    for (name, arity) in &sig.predicates {
        let relations: Vec<HashSet<Vec<String>>> = all_subsets(&tuples(domain, *arity))
            .into_iter()
            .map(|v| v.into_iter().collect())
            .collect();
        acc = extend(acc, &relations, |s, rel| s.with_predicate(name, rel));
    }

    acc
}

/// A model of `f` over the given domain, if one exists.
///
/// The formula must be a sentence over `sig`.
pub fn satisfiable_over(sig: &Signature, f: &Formula, domain: &[String]) -> Option<Structure> {
    assert!(
        sig.validate(f).is_ok(),
        "the formula is not over the signature"
    );
    enumerate_structures(sig, domain).into_iter().find(|s| {
        s.eval(f)
            .expect("a complete structure evaluates every symbol")
    })
}

/// Whether `f` is true in every structure over the given domain.
///
/// The formula must be a sentence over `sig`.
pub fn valid_over(sig: &Signature, f: &Formula, domain: &[String]) -> bool {
    assert!(
        sig.validate(f).is_ok(),
        "the formula is not over the signature"
    );
    enumerate_structures(sig, domain).into_iter().all(|s| {
        s.eval(f)
            .expect("a complete structure evaluates every symbol")
    })
}

/// The product `domain^arity`, as a list of argument tuples.
fn tuples(domain: &[String], arity: usize) -> Vec<Vec<String>> {
    let mut acc: Vec<Vec<String>> = vec![vec![]];
    for _ in 0..arity {
        let mut next = Vec::new();
        for prefix in &acc {
            for d in domain {
                let mut p = prefix.clone();
                p.push(d.clone());
                next.push(p);
            }
        }
        acc = next;
    }
    acc
}

/// All total tables `tuples -> domain`.
fn function_tables(domain: &[String], tuples: &[Vec<String>]) -> Vec<HashMap<Vec<String>, String>> {
    let mut result = vec![HashMap::new()];
    for t in tuples {
        let mut next = Vec::new();
        for table in &result {
            for d in domain {
                let mut extended = table.clone();
                extended.insert(t.clone(), d.clone());
                next.push(extended);
            }
        }
        result = next;
    }
    result
}

/// All subsets of `items`.
fn all_subsets<T: Clone>(items: &[T]) -> Vec<Vec<T>> {
    let mut result: Vec<Vec<T>> = vec![vec![]];
    for item in items {
        let mut with_item: Vec<Vec<T>> = result
            .iter()
            .map(|s| {
                let mut c = s.clone();
                c.push(item.clone());
                c
            })
            .collect();
        result.append(&mut with_item);
    }
    result
}

/// A structure with one more symbol interpretation chosen from `choices`.
fn extend<T: Clone, F>(acc: Vec<Structure>, choices: &[T], apply: F) -> Vec<Structure>
where
    F: Fn(Structure, T) -> Structure,
{
    let mut out = Vec::new();
    for s in acc {
        for choice in choices {
            out.push(apply(s.clone(), choice.clone()));
        }
    }
    out
}
