//! Cayley table of the additive group Z_4, and its Latin-square property.

use algebra::traits::Semigroup;
use algebra::Zn;

fn main() {
    let elems: Vec<Zn<4>> = (0..4).map(Zn::new).collect();

    // Header row.
    print!("    ");
    for b in &elems {
        print!("{:4}", b.0);
    }
    println!();

    // One row per element: the entry is a op b = (a + b) mod 4.
    for a in &elems {
        print!("{:4}", a.0);
        for b in &elems {
            print!("{:4}", a.op(b).0);
        }
        println!();
    }

    // Latin square: every row contains each element exactly once.
    for a in &elems {
        let mut row: Vec<u32> = elems.iter().map(|b| a.op(b).0).collect();
        row.sort_unstable();
        assert_eq!(row, vec![0, 1, 2, 3]);
    }
    println!("every row is a permutation of 0..3: a Latin square");
}
