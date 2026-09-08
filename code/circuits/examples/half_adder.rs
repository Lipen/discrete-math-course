//! Half adder and full adder from gates.
//!
//! The half adder is two gates (XOR for the sum, AND for the carry). The full
//! adder takes a carry in as well, and is five gates: two XOR, two AND, one
//! OR. The demo prints the truth table of each and shows the size and depth
//! the circuit costs.

use circuits::{full_adder, half_adder, Circuit};

fn main() {
    // -- Half adder --
    let mut c = Circuit::new();
    let a = c.input(0);
    let b = c.input(1);
    let (sum, carry) = half_adder(&mut c, a, b);

    println!("Half adder: S = A XOR B, C = A AND B");
    println!("  size {} gates, depth {}", c.size(), c.depth());
    println!("  A  B  | S  C");
    for (x, y) in [(false, false), (false, true), (true, false), (true, true)] {
        let s = c.eval(sum, &[x, y]).unwrap();
        let k = c.eval(carry, &[x, y]).unwrap();
        println!("  {}  {}  | {}  {}", x as u8, y as u8, s as u8, k as u8);
    }

    // -- Full adder --
    let mut d = Circuit::new();
    let a = d.input(0);
    let b = d.input(1);
    let cin = d.input(2);
    let (sum, carry) = full_adder(&mut d, a, b, cin);

    println!("\nFull adder: S = A XOR B XOR Cin");
    println!("            C_out = (A AND B) OR (Cin AND (A XOR B))");
    println!("  size {} gates, depth {}", d.size(), d.depth());
    println!("  A  B Cin | S  C_out");
    for (x, y, z) in [
        (false, false, false),
        (false, false, true),
        (false, true, false),
        (false, true, true),
        (true, false, false),
        (true, false, true),
        (true, true, false),
        (true, true, true),
    ] {
        let s = d.eval(sum, &[x, y, z]).unwrap();
        let k = d.eval(carry, &[x, y, z]).unwrap();
        let total = (x as u8) + (y as u8) + (z as u8);
        println!(
            "  {}  {}   {} | {}  {}   (sum of bits = {})",
            x as u8, y as u8, z as u8, s as u8, k as u8, total
        );
    }
}
