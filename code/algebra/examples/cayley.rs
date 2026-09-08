//! Cayley table of the additive group Z_4, and its Latin-square property.

use algebra::traits::Semigroup;
use algebra::Zn;

fn main() {
    let elems: Vec<Zn<4>> = (0..4).map(Zn::new).collect();

    println!("The additive group Z_4 has four elements, and its whole");
    println!("operation is one 4×4 table, where row a and column b meet at a + b:");
    println!();

    print!("{:>4}", "+");
    for b in &elems {
        print!("{:>4}", b.0);
    }
    println!();
    println!("{}", "-".repeat(4 * (elems.len() + 1)));
    for a in &elems {
        print!("{:>4}", a.0);
        for b in &elems {
            print!("{:>4}", a.op(b).0);
        }
        println!();
    }

    // Latin square: every row contains each element exactly once.
    for a in &elems {
        let mut row: Vec<u32> = elems.iter().map(|b| a.op(b).0).collect();
        row.sort_unstable();
        assert_eq!(row, vec![0, 1, 2, 3]);
    }

    println!();
    println!("Each row is 0, 1, 2, 3 in some order -- a Latin square. That is");
    println!("the table's way of saying every element has an inverse: the");
    println!("equation a + x = b has a unique solution x for every a and b.");
}
