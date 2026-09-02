//! Fuzz the ripple-carry adder against ordinary integer addition.
//!
//! For a range of bit widths, build the ripple-carry adder and check a batch
//! of random operand pairs. Every result must agree with plain integer
//! arithmetic (done in `u128` so the carry never overflows). The demo prints
//! how many cases were checked and whether any failed.

use circuits::ripple_carry_adder;

/// A tiny deterministic xorshift64 generator (no external dependencies).
struct Rng(u64);

impl Rng {
    fn next(&mut self) -> u64 {
        let mut x = self.0;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        self.0 = x;
        x
    }
}

fn main() {
    println!("fuzzing the ripple-carry adder against integer addition");
    println!();
    println!("width | samples | ripple ok | mismatches");

    let mut total = 0u64;
    let mut bad = 0u64;

    for n in [1usize, 2, 3, 4, 5, 8, 12, 16, 20, 24, 32] {
        let ripple = ripple_carry_adder(n);
        let mask = (1u64 << n) - 1;
        let samples = 400u64;

        let mut rng = Rng(0x9E37_79B9_7F4A_7C15 ^ (n as u64).wrapping_mul(0xDEAD_BEEF));
        let mut ok = true;

        for _ in 0..samples {
            let x = rng.next() & mask;
            let y = rng.next() & mask;
            let expected = x as u128 + y as u128;

            if ripple.add_exact(x, y).unwrap() != expected {
                ok = false;
                bad += 1;
                if bad == 1 {
                    println!("  first mismatch: n={n}, x={x}, y={y}, expected {expected}");
                }
            }
            total += 1;
        }

        println!(
            "{n:>4}  | {:>7} | {:>10} | {:>10}",
            samples,
            ok,
            if bad == 0 { "none" } else { "FOUND" }
        );
    }

    println!();
    println!("checked {total} ripple cases, mismatches: {bad}");
}
