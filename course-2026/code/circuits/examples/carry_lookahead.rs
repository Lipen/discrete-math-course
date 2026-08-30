//! Carry-lookahead adder vs ripple-carry adder.
//!
//! The ripple-carry adder chains the carry through every bit, so its depth is
//! `O(n)`. The carry-lookahead adder precomputes generate/propagate signals
//! and combines them in a tree, so its carry path is `O(log n)`. Both add
//! correctly; the demo compares their size and depth across widths and checks
//! the sums against integer addition.

use circuits::{carry_lookahead_adder, ripple_carry_adder};

fn main() {
    println!("width | ripple size / depth |  cla size / depth");
    println!("------+---------------------+----------------");
    for n in [4usize, 8, 16, 32, 48, 64] {
        let ripple = ripple_carry_adder(n);
        let cla = carry_lookahead_adder(n);
        println!(
            "{n:>4}  | {rs:>8}  /  {rd:>4}    | {cs:>8}  /  {cd:>4}",
            rs = ripple.circuit.size(),
            rd = ripple.circuit.depth(),
            cs = cla.circuit.size(),
            cd = cla.circuit.depth(),
        );
    }
    println!();
    println!("CLA pays with gates for a much shorter carry path:");
    println!("  depth O(n)  ->  O(log n);   size O(n)  ->  O(n log n).");

    // --- Correctness spot-check against integer addition ----------------
    let cla = carry_lookahead_adder(8);
    let x = 0b1001_1100u64; // 156
    let y = 0b0110_1010u64; // 106
    let (sum, carry) = cla.add(x, y).unwrap();
    println!("\nCarry-lookahead adder, 8 bits");
    println!("  {x} + {y}");
    println!("  sum (mod 2^8) = {sum}, carry out = {carry}");
    println!(
        "  exact result  = {}  (= {})",
        cla.add_exact(x, y).unwrap(),
        x + y
    );
    println!(
        "  size {} gates, depth {}",
        cla.circuit.size(),
        cla.circuit.depth()
    );
}
