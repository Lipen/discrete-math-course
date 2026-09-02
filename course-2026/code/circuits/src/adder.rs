//! Adders built from gates.
//!
//! A half adder is two gates, a full adder is five.
//! Chaining `n` full adders gives a ripple-carry adder: the carry travels
//! through every bit, so size and depth both grow linearly with the width.

use crate::circuit::{Circuit, CircuitError, NodeId};

/// A half adder: `S = A XOR B`, `C = A AND B`. Returns `(sum, carry)`.
pub fn half_adder(c: &mut Circuit, a: NodeId, b: NodeId) -> (NodeId, NodeId) {
    let sum = c.xor(a, b);
    let carry = c.and(a, b);
    (sum, carry)
}

/// A full adder: `S = A XOR B XOR C_in`, and `C_out` is the majority of the
/// three inputs. Returns `(sum, carry_out)`.
///
/// `A XOR B` is computed once and reused by both the sum and the carry, so
/// the circuit is two XORs, two ANDs, and one OR -- five gates in total.
pub fn full_adder(c: &mut Circuit, a: NodeId, b: NodeId, c_in: NodeId) -> (NodeId, NodeId) {
    let a_xor_b = c.xor(a, b);
    let sum = c.xor(a_xor_b, c_in);
    // C_out = (A AND B) OR (C_in AND (A XOR B)).
    let and_ab = c.and(a, b);
    let and_cin = c.and(c_in, a_xor_b);
    let carry = c.or(and_ab, and_cin);
    (sum, carry)
}

/// A bitwise adder: a circuit that adds two `n`-bit operands.
///
/// The primary inputs are laid out as `A_0..A_{n-1}` at indices `0..n` and
/// `B_0..B_{n-1}` at indices `n..2n`, least significant bit first.
/// [`Adder::add`] and [`Adder::add_bits`] build the assignment for you.
pub struct Adder {
    /// The underlying circuit.
    pub circuit: Circuit,
    /// Primary input nodes for the `A` operand, least significant first.
    pub a: Vec<NodeId>,
    /// Primary input nodes for the `B` operand, least significant first.
    pub b: Vec<NodeId>,
    /// Sum output nodes, least significant first.
    pub sum: Vec<NodeId>,
    /// The final carry-out node (the `(n+1)`-th bit).
    pub carry_out: NodeId,
}

impl Adder {
    /// Number of bits per operand.
    pub fn bits(&self) -> usize {
        self.a.len()
    }

    /// Add two integers. Returns `(sum, carry_out)` where `sum` is the low
    /// `n` bits (as an integer) and `carry_out` is the `(n+1)`-th bit.
    pub fn add(&self, x: u64, y: u64) -> Result<(u64, bool), CircuitError> {
        let n = self.bits();
        let (sum_bits, carry) = self.add_bits(&bits_of(x, n), &bits_of(y, n))?;
        Ok((value_of(&sum_bits), carry))
    }

    /// Add two integers and combine `sum` and the final carry into one exact
    /// result: `x + y` (which may need `n + 1` bits).
    pub fn add_exact(&self, x: u64, y: u64) -> Result<u128, CircuitError> {
        let n = self.bits();
        let (sum, carry) = self.add(x, y)?;
        Ok(sum as u128 + ((carry as u128) << n))
    }

    /// Add two LSB-first bit slices and return the `n` sum bits plus the final
    /// carry. Every slice must have `bits()` entries.
    pub fn add_bits(&self, x: &[bool], y: &[bool]) -> Result<(Vec<bool>, bool), CircuitError> {
        let n = self.bits();
        if x.len() != n || y.len() != n {
            return Err(CircuitError::WidthMismatch {
                expected: n,
                got_x: x.len(),
                got_y: y.len(),
            });
        }
        let mut inputs = Vec::with_capacity(2 * n);
        inputs.extend_from_slice(x);
        inputs.extend_from_slice(y);
        let values = self.circuit.simulate(&inputs)?;
        let sum = self.sum.iter().map(|&id| values[id]).collect();
        let carry = values[self.carry_out];
        Ok((sum, carry))
    }
}

/// An `n`-bit ripple-carry adder: a chain of `n` full adders.
///
/// The carry travels through every bit, so size and depth are both `O(n)`.
pub fn ripple_carry_adder(n: usize) -> Adder {
    let mut c = Circuit::new();
    let mut a = Vec::with_capacity(n);
    let mut b = Vec::with_capacity(n);
    for i in 0..n {
        a.push(c.input(i));
        b.push(c.input(i + n));
    }

    let mut sum = Vec::with_capacity(n);
    let mut carry = c.zero(); // C_0
    for i in 0..n {
        let (s, next) = full_adder(&mut c, a[i], b[i], carry);
        sum.push(s);
        carry = next;
    }
    Adder {
        circuit: c,
        a,
        b,
        sum,
        carry_out: carry,
    }
}

/// The low `n` bits of `x`, least significant bit first.
pub fn bits_of(x: u64, n: usize) -> Vec<bool> {
    (0..n).map(|i| (x >> i) & 1 != 0).collect()
}

/// Reconstruct an integer from LSB-first bits.
pub fn value_of(bits: &[bool]) -> u64 {
    bits.iter()
        .enumerate()
        .fold(0, |acc, (i, &b)| if b { acc | (1 << i) } else { acc })
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A tiny xorshift64 pseudo-random generator (deterministic, no deps).
    fn next(state: &mut u64) -> u64 {
        let mut x = *state;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        *state = x;
        x
    }

    #[test]
    fn half_adder_truth_table() {
        let mut c = Circuit::new();
        let a = c.input(0);
        let b = c.input(1);
        let (sum, carry) = half_adder(&mut c, a, b);

        assert_eq!(c.size(), 2);
        assert_eq!(c.depth(), 1);

        for (a, b) in [(false, false), (false, true), (true, false), (true, true)] {
            let s = c.eval(sum, &[a, b]).unwrap();
            let co = c.eval(carry, &[a, b]).unwrap();
            assert_eq!((s, co), (a ^ b, a && b), "A={a}, B={b}");
        }
    }

    #[test]
    fn full_adder_truth_table() {
        let mut c = Circuit::new();
        let a = c.input(0);
        let b = c.input(1);
        let cin = c.input(2);
        let (sum, carry) = full_adder(&mut c, a, b, cin);

        assert_eq!(c.size(), 5);
        assert_eq!(c.depth(), 3);

        for (a, b, cin) in [
            (false, false, false),
            (false, false, true),
            (false, true, false),
            (false, true, true),
            (true, false, false),
            (true, false, true),
            (true, true, false),
            (true, true, true),
        ] {
            let s = c.eval(sum, &[a, b, cin]).unwrap();
            let co = c.eval(carry, &[a, b, cin]).unwrap();
            let total = (a as u8) + (b as u8) + (cin as u8);
            assert_eq!(
                (s, co),
                (total & 1 == 1, total >= 2),
                "A={a}, B={b}, Cin={cin}"
            );
        }
    }

    #[test]
    fn ripple_carry_4_bit_trace() {
        let adder = ripple_carry_adder(4);
        // 0111 + 0001 = 1000, carry out 0.
        let (sum_bits, carry) = adder
            .add_bits(&[true, true, true, false], &[true, false, false, false])
            .unwrap();
        assert_eq!(sum_bits, vec![false, false, false, true]);
        assert!(!carry);
        assert_eq!(value_of(&sum_bits), 8);
    }

    #[test]
    fn ripple_matches_integer_addition() {
        for n in [1usize, 2, 3, 4, 8, 12, 20, 32, 40] {
            let ripple = ripple_carry_adder(n);
            let mask = (1u64 << n) - 1;

            // Exhaustive small widths, random samples for larger ones.
            let samples = if n <= 4 { 1 << n } else { 200 };
            let mut state = 0x9E3779B97F4A7C15u64;
            let mut x;
            let mut y;
            for s in 0..samples {
                if n <= 4 {
                    x = s;
                    y = (s * 7 + 3) & mask;
                } else {
                    x = next(&mut state) & mask;
                    y = next(&mut state) & mask;
                }

                let r = ripple.add_exact(x, y).unwrap();
                let expected = x as u128 + y as u128;
                assert_eq!(r, expected, "n={n}, x={x}, y={y}");
            }
        }
    }

    #[test]
    fn ripple_size_and_depth_are_linear() {
        let n = 32;
        let ripple = ripple_carry_adder(n);

        assert_eq!(ripple.circuit.size(), 5 * n); // n full adders, 5 gates each
        assert_eq!(ripple.circuit.depth(), 2 * n + 1);
    }

    #[test]
    fn wrong_width_is_rejected() {
        let adder = ripple_carry_adder(3);
        let err = adder
            .add_bits(&[true, false], &[true, false, true])
            .unwrap_err();
        assert!(matches!(err, CircuitError::WidthMismatch { .. }));
    }

    #[test]
    fn bits_and_value_of_are_inverse() {
        for &n in &[1usize, 4, 8, 16] {
            let mask = (1u64 << n) - 1;
            for &x in &[0, 1, 7, mask / 3, mask] {
                let bits = bits_of(x, n);
                assert_eq!(value_of(&bits), x & mask, "n={n}, x={x}");
            }
        }
    }
}
