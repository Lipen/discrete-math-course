# codes

Hamming codes and single-error correction.

Implements the canonical Hamming(7,4) code: 4 data bits protected by 3 parity bits into a 7-bit codeword.
The code has minimum distance 3, so it corrects any single bit error and detects any double error.

## Quick start

```bash
cargo run -p codes --example hamming_demo
cargo test -p codes
```

## How the code works

Data bits sit at positions 3, 5, 6, 7; parity bits `p1`, `p2`, `p4` at positions 1, 2, 4.
Parity `p_i` covers every position whose number has bit `i` set:

![Hamming(7,4): parity groups](assets/hamming-7-4.svg)

The decoder recomputes the three parities of the received word.
They form a 3-bit syndrome; zero means "no error", any other value is exactly the position of the flipped bit:

$$ s = (s_4\, s_2\, s_1)_2 \;\Rightarrow\; \text{flip bit } s $$

## API

| Function | Purpose |
| --- | --- |
| `encode` | 4 data bits → 7-bit codeword |
| `syndrome` | 0 for a valid codeword, else the position of a single error |
| `decode` | Corrects a single error and returns the data bits |
| `data_bits` | Extracts the 4 data bits from a 7-bit word |
| `hamming_distance` | Number of differing positions between two bit strings |

`Decoded` reports the recovered data plus how many errors were corrected (0 or 1) and where.

## Tests

```bash
cargo test -p codes
```

Every one of the 16 data words is checked against all 7 single-bit corruptions, and every pair of distinct codewords is checked to differ in at least 3 positions.
