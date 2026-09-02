//! Ripple-carry adder: a chain of full adders.
//!
//! The carry propagates from the least significant bit through every stage,
//! so the depth is proportional to the width. The demo traces the 4-bit sum
//! `0111 + 0001 = 1000`, then adds a wider pair and prints the resulting
//! size and depth.

use circuits::ripple_carry_adder;

fn show_bits(name: &str, bits: &[bool]) {
    let value: u64 = bits
        .iter()
        .enumerate()
        .fold(0, |acc, (i, &b)| if b { acc | (1 << i) } else { acc });
    let string: String = bits
        .iter()
        .rev()
        .map(|&b| if b { '1' } else { '0' })
        .collect();
    println!("  {name}: {string}  (= {value})");
}

fn main() {
    // -- A 4-bit trace: 0111 + 0001 = 1000 --
    let adder = ripple_carry_adder(4);
    let (sum, carry) = adder
        .add_bits(&[true, true, true, false], &[true, false, false, false])
        .unwrap();

    println!("Ripple-carry adder, 4 bits");
    show_bits("A      ", &[true, true, true, false]);
    show_bits("B      ", &[true, false, false, false]);
    show_bits("sum    ", &sum);
    println!("  carry out: {}", carry as u8);
    println!(
        "  size {} gates, depth {}",
        adder.circuit.size(),
        adder.circuit.depth()
    );

    // -- A wider pair, checked against integer addition --
    let adder = ripple_carry_adder(8);
    let x = 0b0110_1011u64; // 107
    let y = 0b0000_1101u64; // 13
    let (sum, carry) = adder.add(x, y).unwrap();
    println!("\nRipple-carry adder, 8 bits");
    println!("  {x} + {y}, an 8-bit sum");
    let exact = adder.add_exact(x, y).unwrap();
    println!("  sum (mod 2^8) = {sum}, carry out = {carry}");
    println!("  exact {x} + {y} = {exact} (u128 check)");
    println!(
        "  size {} gates, depth {}",
        adder.circuit.size(),
        adder.circuit.depth()
    );
}
