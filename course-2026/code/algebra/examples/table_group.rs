//! A group given only by its Cayley table, and a non-group.

use std::collections::HashMap;

use algebra::dihedral::D4;
use algebra::table_group::TableGroup;
use algebra::traits::Semigroup;

fn main() {
    // Build the Cayley table of D_4 from its group operation.
    let elems = D4::elements();
    let index: HashMap<D4, usize> = elems
        .iter()
        .copied()
        .enumerate()
        .map(|(i, g)| (g, i))
        .collect();
    let table: Vec<Vec<usize>> = elems
        .iter()
        .map(|a| elems.iter().map(|b| index[&a.op(b)]).collect())
        .collect();
    let d4 = TableGroup { n: 8, table };

    println!("D_4 as a table (pure data):");
    println!("  closed      : {}", d4.is_closed());
    println!("  associative : {}", d4.is_associative());
    println!("  identity    : {}", d4.identity().unwrap());
    println!("  inverses    : {}", d4.has_inverses());
    println!("  is a group  : {}", d4.is_group());
    println!("  abelian     : {}", d4.is_abelian());

    // A table that is closed and associative but has no identity: not a group.
    let constant = TableGroup {
        n: 2,
        table: vec![vec![0, 0], vec![0, 0]],
    };
    println!("\nconstant table on 2 elements (a·b = 0 always):");
    println!("  closed      : {}", constant.is_closed());
    println!("  associative : {}", constant.is_associative());
    println!("  identity    : none");
    println!("  is a group  : {}", constant.is_group());

    assert!(d4.is_group());
    assert!(!d4.is_abelian());
    assert!(!constant.is_group());
}
