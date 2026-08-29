//! Rings and fields: zero divisors in Z_6, units of Z_5, the field GF(2).

use algebra::traits::{Field, Ring};
use algebra::{mod_inverse, Bool, Unit, Zn};

fn main() {
    // Z_6 as a ring: 2 and 3 are zero divisors, so 2 has no inverse.
    let two: Zn<6> = Zn::new(2);
    let three: Zn<6> = Zn::new(3);
    println!("2 * 3 = {:?} in Z_6: a zero divisor", two.mul(&three));
    println!("inverse of 2 mod 6 = {:?} (none)", mod_inverse(2, 6));

    // Z_5 is a field: every nonzero residue is a unit.
    println!("units of Z_5:");
    for a in 1..5u32 {
        let inv = mod_inverse(a as i64, 5).unwrap();
        println!(
            "  inverse of {a} mod 5 = {inv}  (check {} * {} = {} mod 5)",
            a,
            inv,
            a * inv as u32 % 5
        );
    }
    let all_units: Vec<u32> = (1..5).filter_map(Unit::<5>::new).map(|u| u.0).collect();
    println!("unit group Z_5^* = {:?}", all_units);

    // GF(2): booleans with XOR and AND.
    let t = Bool(true);
    let f = Bool(false);
    println!("true + true = {:?} (XOR, so 1 + 1 = 0)", t.add(&t));
    println!("true * true = {:?} (AND)", t.mul(&t));
    println!("inverse of true = {:?}", t.inv());
    println!("inverse of false = {:?} (no division by zero)", f.inv());

    assert_eq!(two.mul(&three), Zn::new(0));
    assert_eq!(t.add(&t), Bool(false));
    assert_eq!(t.inv(), Some(Bool(true)));
    assert_eq!(f.inv(), None);
}
