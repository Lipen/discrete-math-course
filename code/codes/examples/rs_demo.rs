//! Reed--Solomon (7, 3, 5) over GF(8): encode, corrupt two symbols, recover.
//!
//! The demo follows the book example end to end: the message polynomial
//! 1 + a x + a^2 x^2 is evaluated at the powers of the primitive element
//! alpha, two received symbols are corrupted, and a brute-force interpolation
//! decoder votes the true polynomial back out.

/// A GF(8) element: bitmask of polynomial coefficients, low bit = constant term.
type Elem = u8;

/// The modulus x^3 + x + 1 as a bitmask.
const MOD: u16 = 0b1011;

/// Reduce a raw product modulo x^3 + x + 1.
fn reduce(mut v: u16) -> Elem {
    for i in (3..8).rev() {
        if (v >> i) & 1 == 1 {
            v ^= MOD << (i - 3);
        }
    }
    (v & 0b0111) as Elem
}

/// Multiply two field elements.
fn mul(a: Elem, b: Elem) -> Elem {
    let mut acc = 0u16;
    for i in 0..3 {
        if (b >> i) & 1 == 1 {
            acc ^= (a as u16) << i;
        }
    }
    reduce(acc)
}

/// The powers alpha^0 through alpha^6, with alpha the root of x^3 + x + 1.
fn powers() -> [Elem; 7] {
    let mut pows = [1u8; 7];
    for i in 1..7 {
        pows[i] = mul(pows[i - 1], 0b010);
    }
    pows
}

/// Multiplicative inverse by exhaustive search over the seven nonzero elements.
fn inverse(a: Elem) -> Elem {
    for b in 1..8 {
        if mul(a, b) == 1 {
            return b;
        }
    }
    unreachable!("no inverse")
}

/// Evaluate a degree-2 polynomial (coefficients of 1, x, x^2) at a field point.
fn eval(p: &[Elem; 3], x: Elem) -> Elem {
    p[0] ^ mul(p[1], x) ^ mul(p[2], mul(x, x))
}

/// Encode the message polynomial at the powers of alpha.
fn encode(m: &[Elem; 3], pows: &[Elem; 7]) -> [Elem; 7] {
    let mut c = [0u8; 7];
    for (j, cj) in c.iter_mut().enumerate() {
        *cj = eval(m, pows[j]);
    }
    c
}

/// Lagrange interpolation through three points, coefficients of 1, x, x^2.
fn interpolate(xs: [usize; 3], ys: [Elem; 3], pows: &[Elem; 7]) -> [Elem; 3] {
    let mut acc = [0u8; 3];
    for j in 0..3 {
        // The other two evaluation points for the basis polynomial.
        let v = pows[xs[(j + 1) % 3]];
        let w = pows[xs[(j + 2) % 3]];
        let x = pows[xs[j]];
        // Denominator (x - v)(x - w), subtraction is XOR in characteristic 2.
        let denom = mul(x ^ v, x ^ w);
        let scale = mul(ys[j], inverse(denom));
        // (x - v)(x - w) = x^2 + (v + w) x + v w, addition is XOR.
        acc[2] ^= scale;
        acc[1] ^= mul(scale, v ^ w);
        acc[0] ^= mul(scale, mul(v, w));
    }
    acc
}

/// Brute-force decoder: try every triple of positions, keep the best-agreeing polynomial.
fn decode(r: &[Elem; 7], pows: &[Elem; 7]) -> ([Elem; 3], usize, [usize; 3]) {
    let mut best = ([0u8; 3], 0usize, [0usize; 3]);
    for i in 0..7 {
        for j in (i + 1)..7 {
            for k in (j + 1)..7 {
                let xs = [i, j, k];
                let ys = [r[i], r[j], r[k]];
                let m = interpolate(xs, ys, pows);
                let agree = (0..7).filter(|&t| eval(&m, pows[t]) == r[t]).count();
                if agree > best.1 {
                    best = (m, agree, xs);
                }
            }
        }
    }
    best
}

/// Print name of a field element: 0, 1, a, or a^k.
fn name(e: Elem, pows: &[Elem; 7]) -> String {
    match e {
        0 => "0".to_string(),
        _ => match pows.iter().position(|&p| p == e).unwrap() {
            0 => "1".to_string(),
            1 => "a".to_string(),
            k => format!("a^{k}"),
        },
    }
}

/// Print a codeword as a comma-separated list of element names.
fn word(c: &[Elem; 7], pows: &[Elem; 7]) -> String {
    c.iter()
        .map(|&e| name(e, pows))
        .collect::<Vec<_>>()
        .join(", ")
}

fn main() {
    let pows = powers();
    assert_eq!(pows, [1, 2, 4, 3, 6, 7, 5]);
    println!("Reed--Solomon (7, 3, 5) over GF(8), alpha = root of x^3 + x + 1");

    // Message (1, alpha, alpha^2), polynomial 1 + a x + a^2 x^2.
    let m = [1u8, 0b010, 0b100];
    let mtext = m
        .iter()
        .map(|&e| name(e, &pows))
        .collect::<Vec<_>>()
        .join(", ");
    println!("message  m(x) = 1 + a x + a^2 x^2 = ({mtext})");

    let c = encode(&m, &pows);
    println!("codeword = ({})", word(&c, &pows));

    // Corrupt two symbols, exactly as in the book example.
    let mut r = c;
    r[1] = 0; // a^3 -> 0
    r[5] = 1; // a^3 -> 1
    println!("errors   at positions 1 and 5");
    println!("received = ({})", word(&r, &pows));

    let (m2, agree, xs) = decode(&r, &pows);
    println!(
        "\ndecoder: interpolation over triple ({}, {}, {}) agrees in {agree} of 7 positions",
        xs[0], xs[1], xs[2]
    );
    let m2text = m2
        .iter()
        .map(|&e| name(e, &pows))
        .collect::<Vec<_>>()
        .join(", ");
    println!("recovered message = ({m2text})");
    println!("matches the original: {}", m2 == m);
}
