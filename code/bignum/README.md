# bignum

Schoolbook arbitrary-precision integers: a sign plus a magnitude of base $2^{32}$ limbs.

The crate shows long arithmetic in its plainest form.
A number is an array of limbs, least significant first, with no leading zeros, plus a sign flag.
Addition, subtraction, multiplication, division and comparison work as on paper, one column at a time.
Values grow past any fixed width: the demos print $100!$ with 158 digits and the thousandth Fibonacci number with 209 digits in full.

## Quick start

```bash
cargo run --example big-arithmetic
cargo run --example overflow-u64
cargo run --example factorial-fibonacci
cargo test
```

## The model

### Limbs and the sign

A `Magnitude` stores a nonnegative integer in base $B = 2^{32}$, least significant limb first:

$$v = d_0 + d_1 B + \dots + d_{n-1} B^{n-1}, \qquad 0 \le d_k < B$$

Two invariants hold at every observable moment: the limb array is never empty, and its most significant limb is nonzero unless the value is zero, stored as the single limb $[0]$.
A `BigInt` pairs the magnitude with a sign, and a zero magnitude always lands on the positive sign, so every value has exactly one representation.

![Layout of a BigInt](assets/bignum-layout.svg)

### Addition, comparison, subtraction

Addition aligns the operands at the low end and ripples the carry upward: limb plus limb plus carry fits a `u64`, the low 32 bits stay in place, the rest moves one limb up.
Comparison reads from the most significant limb: different widths already order the values, and equal widths compare from the top limb down.
A derived `Ord` on the limb array would compare the least significant limbs first and call $1 > 2$ on $[1]$ versus $[0, 1]$.
Magnitude subtraction borrows limb by limb and is defined only for $a \ge b$.
The signed layer builds the general case on it: opposite signs subtract the smaller magnitude from the larger and keep the sign of the larger.

### Multiplication

Multiplication is the schoolbook $O(n \cdot m)$ scheme: every limb pair contributes one double-width product, and the carry of each row normalizes the array in the same pass.
The bounds keep a plain `u64` cell safe: a cell below $B$, a limb product below $B^2$ and a carry below $B$ sum to at most $2^{64} - 1$.

### Division and decimal printing

Division works by shift-subtract from the most significant bit: the running remainder doubles, the next dividend bit drops in, and the divisor is subtracted whenever it fits.
The same `divmod` powers the decimal conversion, which divides by $10^9$ and peels nine digits per pass.

## Demos

| Demo                  | Shows                                                                                              |
| --------------------- | -------------------------------------------------------------------------------------------------- |
| `big-arithmetic`      | addition, subtraction, multiplication and division of two 39-digit numbers, printed in full        |
| `overflow-u64`        | the first overflow of `u64` factorials and Fibonacci numbers, and the same values computed exactly |
| `factorial-fibonacci` | the records $100!$ and $F_{1000}$, digit counts along the way, and the divisibility checks         |

A sample of the `overflow-u64` output:

```text
factorial: 20! still fits, 21! does not
  20! = 2432902008176640000 still fits u64
  21! = 51090942171709440000 no longer fits
  the crate computes 30! = 265252859812191058636308480000000 (33 decimal digits)
```

## API

| Item             | Purpose                                                                                  |
| ---------------- | ---------------------------------------------------------------------------------------- |
| `Magnitude`      | nonnegative integers as base $2^{32}$ limbs, with `+`, `-`, `*`, `divmod`, and `Display` |
| `BigInt`, `Sign` | sign plus magnitude: signed arithmetic, ordering, and `Display`                          |
| `factorial(n)`   | $n!$ by repeated multiplication                                                          |
| `fibonacci(n)`   | $F_n$ with $F_1 = F_2 = 1$, by iteration on pairs                                        |
| `SplitMix64`     | a seeded generator for the randomized property checks                                    |

## Tests

- representation invariants: no leading zeros, zero as $[0]$ with a positive sign
- carry, borrow and comparison cross-checked against `u128` on seeded random operands
- signed arithmetic and ordering cross-checked against `i128` on hundreds of random pairs
- ring properties on random triples: commutativity, associativity, distributivity, order consistency
- division inverting multiplication, and the neighbor law $F_{n+1} = F_n + F_{n-1}$ far beyond 64 bits
- the records pinned to exact decimal strings, including the 24 trailing zeros of $100!$
