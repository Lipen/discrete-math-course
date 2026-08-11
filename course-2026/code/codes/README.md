# codes

Error-correcting codes over a binary channel: parity, repetition, and Hamming.

Three code families answer the same question -- "how do I protect bits against
noise?" -- with different amounts of redundancy:

| code | (n, k, d) | rate k/n | detects | corrects | idea |
| --- | --- | --- | --- | --- | --- |
| parity | (7, 6, 2) | 6/7 | 1 | 0 | append one bit so the word has even parity |
| repetition | (3, 1, 3) | 1/3 | 2 | 1 | send each bit three times, majority vote |
| Hamming | (7, 4, 3) | 4/7 | 2 | 1 | parity bits whose positions spell the error |
| extended Hamming | (8, 4, 4) | 1/2 | 3 | 1 | Hamming(7,4) plus an overall parity bit: a double error is detected, not miscorrected |

`(n, k, d)`: n bits per codeword, k data bits, minimum distance d. A code of
distance d detects up to d - 1 errors and corrects up to (d - 1) / 2. All four
detect a single error; repetition, Hamming, and extended Hamming also correct
it, and Hamming does so at nearly twice the rate.

## Quick start

```bash
cargo run -p codes --example hamming_demo
cargo run -p codes --example codes_compare
cargo run -p codes --example hamming_errors
cargo run -p codes --example hamming_extended
cargo run -p codes --example repetition_errors
cargo run -p codes --example parity_errors
cargo test -p codes
```

The demos:

| Example | What it shows |
| --- | --- |
| `hamming_demo` | One word through the whole Hamming pipeline |
| `codes_compare` | The three families side by side (rate vs distance) |
| `hamming_errors` | Hamming at 0, 1, 2, 3 flipped bits |
| `hamming_extended` | Extended Hamming: how one parity bit tells 1 error from 2 |
| `repetition_errors` | Repetition at 0, 1, 2, 3 flipped bits |
| `parity_errors` | Parity at 0, 1, 2, 3 flipped bits |

The `*_errors` demos draw the flipped bits in red when the terminal supports it.

## Hamming(7,4)

Data bits sit at positions 3, 5, 6, 7; parity bits `p1`, `p2`, `p4` at positions 1, 2, 4.
Each parity bit is the xor (sum modulo 2) of the data bits it covers:

![Hamming(7,4): which data bits feed each parity bit](assets/hamming-7-4.svg)

$$ p_1 = d_1 \oplus d_2 \oplus d_4, \qquad
   p_2 = d_1 \oplus d_3 \oplus d_4, \qquad
   p_4 = d_2 \oplus d_3 \oplus d_4 $$

Equivalently, in terms of positions inside the 7-bit word:

| parity bit | covers positions |
| --- | --- |
| `p1` | 1, 3, 5, 7 |
| `p2` | 2, 3, 6, 7 |
| `p4` | 4, 5, 6, 7 |

The decoder recomputes the three parities of the received word; they form the
3-bit syndrome

$$ s = (s_4\, s_2\, s_1)_2 . $$

Read `s` as a binary number: it encodes the **number of the bit to flip
back**, and that interpretation is correct **if at most one error occurred**.
With two or more flipped bits `s` stays nonzero but points at the wrong
position, so the decoder "corrects" a bit that was never wrong -- the price of
a code of distance 3.

## Extended Hamming (8, 4, 4)

Hamming(7,4) plus one overall parity bit: the whole 8-bit word must have an
even number of ones. The minimum distance grows to 4, and the decoder now
distinguishes a double error from a single one:

| syndrome | parity | what the decoder does |
| --- | --- | --- |
| 0 | even | no error |
| 0 | odd | the parity bit itself was flipped: correct bit 8 |
| nonzero | odd | a single error: correct the bit the syndrome points at |
| nonzero | even | two errors: detected, left uncorrected |

Without the extra bit a double error was silently miscorrected: the syndrome
pointed at a healthy bit, and the decoder flipped it. The overall parity bit
removes that ambiguity -- `extended_decode` reports `ExtendedOutcome::Double`
and the data is not trusted.

## Repetition (3, 1, 3)

Each bit is sent three times; the receiver takes a majority vote. Any single
error is outvoted, two errors are not. The code is the honest naive answer to
noise -- it works, but spends three bits to protect one.

## Parity (n + 1, n, 2)

One parity bit is appended so the word has an even number of ones. A single
flipped bit breaks the check, but the check says nothing about *where* the
error is, so parity detects without correcting.

## Distance and capability

`hamming_distance`, `min_distance`, `detects_up_to`, and `corrects_up_to`
measure a code and say what it buys:

```rust
let d = min_distance(&words);
assert_eq!(detects_up_to(d), 2);   // d - 1
assert_eq!(corrects_up_to(d), 1);  // (d - 1) / 2
```

## Modules

| Module | What is inside |
| --- | --- |
| `hamming` | `encode`, `syndrome`, `data_bits`, `decode`, `Decoded` |
| `extended` | `encode`, `decode`, `Outcome`, `Decoded` |
| `repetition` | `encode`, `decode` |
| `parity` | `bit`, `encode`, `ok`, `decode` |
| `distance` | `hamming`, `min_distance`, `detects_up_to`, `corrects_up_to` |

All public items are also re-exported from the crate root under their familiar
names (`codes::encode`, `codes::parity_bit`, `codes::extended_decode`, etc.),
so existing code continues to work.

## API

| Function | Module | Purpose |
| --- | --- | --- |
| `encode` | `hamming` | 4 data bits -> 7-bit Hamming codeword |
| `syndrome` | `hamming` | 0 for a valid codeword, else the position of a single error |
| `decode` | `hamming` | Corrects a single error and returns the data bits |
| `data_bits` | `hamming` | Extracts the 4 data bits from a 7-bit word |
| `extended::encode` | `extended` | 4 data bits -> 8-bit extended Hamming codeword |
| `extended::decode` | `extended` | Corrects one error, detects two; returns `ExtendedDecoded` |
| `repeat_encode` | `repetition` | One bit -> the same bit three times |
| `repeat_decode` | `repetition` | Majority vote over three bits |
| `parity_bit` | `parity` | 1 when the data has an odd number of ones |
| `parity_encode` | `parity` | Appends the parity bit: (n + 1, n, 2) code |
| `parity_ok` | `parity` | True when the word passes the even-parity check |
| `parity_decode` | `parity` | Strips the parity bit if the check passes; `None` otherwise |
| `hamming_distance` | `distance` | Number of differing positions between two bit strings |
| `min_distance` | `distance` | Smallest pairwise distance over a set of codewords |
| `detects_up_to` | `distance` | d - 1: errors detected by a code of distance d |
| `corrects_up_to` | `distance` | d - 1 / 2: errors corrected by a code of distance d |

`hamming::Decoded` reports the recovered data plus how many errors were
corrected (0 or 1) and where.
`extended::Decoded` reports data and an `Outcome` (`Clean`, `Corrected`,
or `Double`).

## Tests

```bash
cargo test -p codes
```

Unit tests: 29. Doc-tests: 19 (every public function has a runnable example).
Test coverage:

- Hamming(7,4): all 16 codewords verified, all 16 x 7 single-bit corruptions
  corrected, all 16 x 15/2 = 120 word pairs checked for d >= 3, double-error
  miscorrection verified, syndrome table checked, hand-computed word validated.
- Extended Hamming(8,4,4): all 16 codewords have even parity, all 16 x 8
  single-bit corruptions corrected, all 16 x 28 double-bit corruptions
  detected, parity-bit-only and data+parity bit scenarios checked, d = 4
  verified.
- Repetition(3,1,3): exhaustive 8-word majority vote, two-error flip verified,
  d = 3 verified.
- Parity: all 16 data words checked, all 16 x 5 single-bit corruptions
  detected, two-error slip verified, `parity_decode` tested, edge case
  (empty data) covered, d = 2 verified.
- Distance: helpers verified for d = 0..4, different-length panic checked.
