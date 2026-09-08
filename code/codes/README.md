# codes

Error-correcting codes over a binary channel: parity, repetition, and Hamming.

Three code families answer the same question — "how do I protect bits against noise?" — with different amounts of redundancy:

| code             | (n, k, d) | rate k/n | detects | corrects | idea                                                                                  |
| ---------------- | --------- | -------- | ------- | -------- | ------------------------------------------------------------------------------------- |
| parity           | (5, 4, 2) | 4/5      | 1       | 0        | append one bit so the word has even parity                                            |
| repetition       | (3, 1, 3) | 1/3      | 2       | 1        | send each bit three times, majority vote                                              |
| Hamming          | (7, 4, 3) | 4/7      | 2       | 1        | parity bits whose positions spell the error                                           |
| extended Hamming | (8, 4, 4) | 1/2      | 3       | 1        | Hamming(7,4) plus an overall parity bit: a double error is detected, not miscorrected |

`(n, k, d)`: n bits per codeword, k data bits, minimum distance d.
A code of distance d detects up to $d - 1$ errors and corrects up to $\lfloor (d - 1) / 2 \rfloor$.
All four detect a single error.
Repetition, Hamming, and extended Hamming also correct it, and Hamming does so at nearly twice the rate.

## Quick start

```bash
cargo test
cargo run --example hamming_demo
cargo run --example codes_compare
cargo run --example hamming_errors
cargo run --example hamming_extended
cargo run --example repetition_errors
cargo run --example parity_errors
```

| Example             | What it shows                                             |
| ------------------- | --------------------------------------------------------- |
| `hamming_demo`      | One word through the whole Hamming pipeline               |
| `codes_compare`     | The three families side by side: rate against distance    |
| `hamming_errors`    | Hamming at 0, 1, 2, 3 flipped bits                        |
| `hamming_extended`  | Extended Hamming: how one parity bit tells 1 error from 2 |
| `repetition_errors` | Repetition at 0, 1, 2, 3 flipped bits                     |
| `parity_errors`     | Parity at 0, 1, 2, 3 flipped bits                         |

The `*_errors` demos draw the flipped bits in red when the terminal supports it.

## Hamming(7,4)

### Codeword layout

Data bits sit at positions 3, 5, 6, 7.
Parity bits `p1`, `p2`, `p4` sit at positions 1, 2, 4.

![Hamming(7,4): which data bits feed each parity bit](assets/hamming-7-4.svg)

Each parity bit is the xor (sum modulo 2) of the data bits it covers:

$$ p_1 = d_1 \oplus d_2 \oplus d_4, \qquad
   p_2 = d_1 \oplus d_3 \oplus d_4, \qquad
   p_4 = d_2 \oplus d_3 \oplus d_4 $$

In terms of positions inside the 7-bit word:

| parity bit | covers positions |
| ---------- | ---------------- |
| `p1`       | 1, 3, 5, 7       |
| `p2`       | 2, 3, 6, 7       |
| `p4`       | 4, 5, 6, 7       |

### The syndrome

The decoder recomputes the three parities of the received word.
They form the 3-bit syndrome

$$ s = (s_4\, s_2\, s_1)_2 . $$

Read `s` as a binary number: it encodes **the number of the bit to flip back**, and that interpretation is correct **if at most one error occurred**.
With two flipped bits `s` stays nonzero but points at the wrong position, so the decoder "corrects" a bit that was never wrong.
With three flipped bits `s` may be zero, and the errors slip through unnoticed — the price of a code of distance 3.

The trick works because codeword position $i$ is covered by exactly the parity bits whose numbers appear in the binary expansion of $i$, so the syndrome bits spell out the position.

## Extended Hamming (8, 4, 4)

Hamming(7,4) plus one overall parity bit: the whole 8-bit word must have an even number of ones.
The minimum distance grows to 4, and the decoder now distinguishes a double error from a single one:

| syndrome | parity | what the decoder does                                  |
| -------- | ------ | ------------------------------------------------------ |
| 0        | even   | no error                                               |
| 0        | odd    | the parity bit itself was flipped: correct bit 8       |
| nonzero  | odd    | a single error: correct the bit the syndrome points at |
| nonzero  | even   | two errors: detected, left uncorrected                 |

Without the extra bit a double error was silently miscorrected: the syndrome pointed at a healthy bit, and the decoder flipped it.
The overall parity bit removes that ambiguity — `extended_decode` reports `ExtendedOutcome::Double`, and the data is not trusted.

## Repetition (3, 1, 3)

Each bit is sent three times, and the receiver takes a majority vote.
Any single error is outvoted, two errors are not.
The code is the honest naive answer to noise — it works, but spends three bits to protect one.

## Parity (n + 1, n, 2)

One parity bit is appended so the word has an even number of ones.
A single flipped bit breaks the check.
The check says nothing about *where* the error is, so parity detects without correcting.

## Distance and capability

`hamming_distance`, `min_distance`, `detects_up_to`, and `corrects_up_to` measure a code and say what it buys:

```rust
let d = min_distance(&words);
assert_eq!(detects_up_to(d), 2);   // d - 1
assert_eq!(corrects_up_to(d), 1);  // (d - 1) / 2
```

## API

### `hamming`

| Item        | Purpose                                                      |
| ----------- | ------------------------------------------------------------ |
| `encode`    | 4 data bits -> 7-bit codeword `[p1, p2, d1, p4, d2, d3, d4]` |
| `syndrome`  | 0 for a valid codeword, else the position of a single error  |
| `decode`    | Corrects a single error and returns the data bits            |
| `data_bits` | Extracts the 4 data bits from a 7-bit word                   |
| `Decoded`   | Data, the number of corrected errors (0 or 1), its position  |

### `extended`

| Item      | Purpose                                                                |
| --------- | ---------------------------------------------------------------------- |
| `encode`  | 4 data bits -> 8-bit codeword                                          |
| `decode`  | Corrects one error, detects two                                        |
| `Decoded` | Data plus an `Outcome`: `Clean`, `Corrected { position }`, or `Double` |

### `repetition`

| Item     | Purpose                             |
| -------- | ----------------------------------- |
| `encode` | One bit -> the same bit three times |
| `decode` | Majority vote over three bits       |

### `parity`

| Item     | Purpose                                                     |
| -------- | ----------------------------------------------------------- |
| `bit`    | 1 when the data has an odd number of ones                   |
| `encode` | Appends the parity bit: the (n + 1, n, 2) code              |
| `ok`     | True when the word passes the even-parity check             |
| `decode` | Strips the parity bit if the check passes, `None` otherwise |

### `distance`

| Item             | Purpose                                               |
| ---------------- | ----------------------------------------------------- |
| `hamming`        | Number of differing positions between two bit strings |
| `min_distance`   | Smallest pairwise distance over a set of codewords    |
| `detects_up_to`  | d - 1: errors detected by a code of distance d        |
| `corrects_up_to` | (d - 1) / 2: errors corrected by a code of distance d |

Everything is also re-exported flat from the crate root under familiar names (`codes::encode`, `codes::parity_bit`, `codes::extended_decode`).

## Tests

Unit tests: 29.
Doc-tests: 19 (every public function has a runnable example).
Coverage:

- Hamming(7,4): all 16 codewords verified, all 16 x 7 single-bit corruptions corrected, all 16 x 15/2 = 120 word pairs checked for d >= 3, double-error miscorrection verified, syndrome table checked, independently computed word validated.
- Extended Hamming(8,4,4): all 16 codewords have even parity, all 16 x 8 single-bit corruptions corrected, all 16 x 28 double-bit corruptions detected, parity-bit-only and data+parity bit scenarios checked, d = 4 verified.
- Repetition(3,1,3): exhaustive 8-word majority vote, two-error flip verified, d = 3 verified.
- Parity: all 16 data words checked, all 16 x 5 single-bit corruptions detected, two-error slip verified, `parity_decode` tested, edge case (empty data) covered, d = 2 verified.
- Distance: helpers verified for d = 0..4, different-length panic checked.
