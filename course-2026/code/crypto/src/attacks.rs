//! Attacks on cryptosystems.
//!
//! Each attack shows the boundary beyond which a system stops being
//! secure: the common modulus and malleability break careless RSA,
//! Pohlig--Hellman breaks DLOG in a group of smooth order.

use super::modular::{egcd, mod_inverse, mod_pow};

/// Modular exponentiation with a negative exponent
/// (through the modular inverse).
fn mod_pow_signed(base: u64, exp: i128, m: u64) -> Option<u64> {
    if exp >= 0 {
        Some(mod_pow(base, exp as u64, m))
    } else {
        let inv = mod_inverse(base, m)?;
        Some(mod_pow(inv, exp.unsigned_abs() as u64, m))
    }
}

/// Common modulus attack.
///
/// Two users share one modulus `n` with different exponents `e1`, `e2`
/// (`gcd(e1, e2) = 1`).
/// Seeing `c1 = m^e1 mod n` and `c2 = m^e2 mod n`, the attacker finds `u`, `v`
/// with `e1*u + e2*v = 1` by the extended Euclidean algorithm and computes
/// `c1^u * c2^v mod n = m`.
///
/// Returns `None` if `gcd(e1, e2) != 1`.
///
/// # Examples
///
/// ```
/// use crypto::attacks::common_modulus_attack;
/// use crypto::modular::mod_pow;
///
/// let n = 61 * 53; // 3233
/// let (e1, e2) = (17, 7);
/// let m = 42;
/// let c1 = mod_pow(m, e1, n);
/// let c2 = mod_pow(m, e2, n);
/// assert_eq!(common_modulus_attack(n, e1, c1, e2, c2), Some(m));
/// ```
pub fn common_modulus_attack(n: u64, e1: u64, c1: u64, e2: u64, c2: u64) -> Option<u64> {
    let (g, u, v) = egcd(e1 as i128, e2 as i128);
    if g != 1 {
        return None;
    }
    let a = mod_pow_signed(c1, u, n)?;
    let b = mod_pow_signed(c2, v, n)?;
    Some(((a as u128 * b as u128) % n as u128) as u64)
}

/// RSA malleability: the product of ciphertexts is the ciphertext
/// of the product of the messages: `c1 * c2 = (m1 * m2)^e mod n`.
///
/// # Examples
///
/// ```
/// use crypto::attacks::malleable_product;
/// use crypto::modular::mod_pow;
///
/// let n = 61 * 53;
/// let e = 17;
/// let m1 = 7;
/// let m2 = 11;
/// let forged = malleable_product(mod_pow(m1, e, n), mod_pow(m2, e, n), n);
/// assert_eq!(forged, mod_pow(m1 * m2 % n, e, n));
/// ```
pub fn malleable_product(c1: u64, c2: u64, n: u64) -> u64 {
    ((c1 as u128 % n as u128) * (c2 as u128 % n as u128) % n as u128) as u64
}

/// Factorization by trial division: returns `[(prime, exponent)]`.
///
/// # Examples
///
/// ```
/// use crypto::attacks::factorize;
///
/// assert_eq!(factorize(28), vec![(2, 2), (7, 1)]);
/// assert_eq!(factorize(13), vec![(13, 1)]);
/// assert_eq!(factorize(1), vec![]);
/// ```
pub fn factorize(mut n: u64) -> Vec<(u64, u64)> {
    let mut factors = Vec::new();
    let mut d = 2;
    while d <= n / d {
        if n.is_multiple_of(d) {
            let mut a = 0;
            while n.is_multiple_of(d) {
                n /= d;
                a += 1;
            }
            factors.push((d, a));
        }
        d += 1;
    }
    if n > 1 {
        factors.push((n, 1));
    }
    factors
}

/// Chinese remainder theorem for pairwise coprime moduli.
/// Given residues `r_i` and pairwise coprime moduli `m_i`,
/// finds `x` such that `x ≡ r_i (mod m_i)` for all `i`.
/// Returns `None` if any pair of moduli is not coprime
/// (the required modular inverse does not exist).
///
/// # Examples
///
/// ```
/// use crypto::attacks::crt;
///
/// // x ≡ 2 (mod 3), x ≡ 3 (mod 5), x ≡ 2 (mod 7) => x = 23
/// assert_eq!(crt(&[2, 3, 2], &[3, 5, 7]), Some(23));
/// ```
pub fn crt(residues: &[u64], moduli: &[u64]) -> Option<u64> {
    let mut x = 0u64;
    let mut m = 1u64;
    for (&r, &mi) in residues.iter().zip(moduli) {
        let minv = mod_inverse(m % mi, mi)?;
        let diff = (r as i128 - x as i128).rem_euclid(mi as i128) as u64;
        let t = diff * minv % mi;
        x += t * m;
        m *= mi;
    }
    Some(x % m)
}

/// Simplified Pohlig--Hellman attack: the discrete logarithm
/// `x = log_g h (mod p)`, when the group order `p - 1` is smooth.
///
/// For each prime power `q^a` the logarithm reduces to the subgroup
/// of order `q^a`, where the answer is found by brute force, and the
/// results are combined via CRT.
///
/// # Examples
///
/// ```
/// use crypto::attacks::pohlig_hellman;
/// use crypto::modular::mod_pow;
///
/// let p = 29;
/// let g = 2; // generator of Z_29^*
/// let x = 13;
/// let h = mod_pow(g, x, p);
/// assert_eq!(pohlig_hellman(p, g, h), Some(x));
/// ```
pub fn pohlig_hellman(p: u64, g: u64, h: u64) -> Option<u64> {
    let n = p - 1;
    let mut residues = Vec::new();
    let mut moduli = Vec::new();
    for (q, a) in factorize(n) {
        let qa = q.pow(a as u32);
        let g_a = mod_pow(g, n / qa, p);
        let h_a = mod_pow(h, n / qa, p);
        // h_a = g_a^(x mod qa): brute-force the exponent in the subgroup of order qa.
        let mut x = 0u64;
        let mut cur = 1u64;
        while x < qa {
            if cur == h_a {
                break;
            }
            cur = cur * g_a % p;
            x += 1;
        }
        if x >= qa {
            return None; // h is not in the subgroup (should not happen for a generator g)
        }
        residues.push(x);
        moduli.push(qa);
    }
    crt(&residues, &moduli)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn common_modulus_recovers_message() {
        let n = 61 * 53;
        let e1 = 17;
        let e2 = 7; // gcd(17, 7) = 1
        let m = 42;
        let c1 = mod_pow(m, e1, n);
        let c2 = mod_pow(m, e2, n);
        assert_eq!(common_modulus_attack(n, e1, c1, e2, c2), Some(m));
    }

    #[test]
    fn common_modulus_fails_with_non_coprime_exponents() {
        let n = 61 * 53;
        let e1 = 6;
        let e2 = 9; // gcd(6, 9) = 3
        let m = 42;
        let c1 = mod_pow(m, e1, n);
        let c2 = mod_pow(m, e2, n);
        assert_eq!(common_modulus_attack(n, e1, c1, e2, c2), None);
    }

    #[test]
    fn malleability_forges_product() {
        let n = 61 * 53;
        let e = 17;
        let m1 = 7;
        let m2 = 11;
        let forged = malleable_product(mod_pow(m1, e, n), mod_pow(m2, e, n), n);
        assert_eq!(forged, mod_pow(m1 * m2 % n, e, n));
    }

    #[test]
    fn malleability_with_larger_messages() {
        let n = 61 * 53;
        let e = 17;
        let m1 = 100;
        let m2 = 200;
        let forged = malleable_product(mod_pow(m1, e, n), mod_pow(m2, e, n), n);
        assert_eq!(forged, mod_pow(m1 * m2 % n, e, n));
    }

    #[test]
    fn pohlig_hellman_solves_smooth_dlog() {
        // p = 29, the group order 28 = 2^2 * 7 is smooth.
        let p = 29;
        let g = 2; // generator of Z_29^*
        let x = 13;
        let h = mod_pow(g, x, p);
        assert_eq!(pohlig_hellman(p, g, h), Some(x));
    }

    #[test]
    fn pohlig_hellman_with_other_generator() {
        // p = 29, g = 3 is also a generator, x = 5.
        let p = 29;
        let g = 3;
        let x = 5;
        let h = mod_pow(g, x, p);
        assert_eq!(pohlig_hellman(p, g, h), Some(x));
    }

    #[test]
    fn factorize_splits_smooth_order() {
        assert_eq!(factorize(28), vec![(2, 2), (7, 1)]);
        assert_eq!(factorize(12), vec![(2, 2), (3, 1)]);
    }

    #[test]
    fn factorize_prime_returns_single_factor() {
        assert_eq!(factorize(13), vec![(13, 1)]);
        assert_eq!(factorize(97), vec![(97, 1)]);
    }

    #[test]
    fn factorize_one_is_empty() {
        assert_eq!(factorize(1), vec![]);
    }

    #[test]
    fn factorize_powers_of_two() {
        assert_eq!(factorize(8), vec![(2, 3)]);
        assert_eq!(factorize(16), vec![(2, 4)]);
    }

    #[test]
    fn crt_reconstructs_known_number() {
        // x = 23: 23 ≡ 2 (mod 3), 23 ≡ 3 (mod 5), 23 ≡ 2 (mod 7)
        assert_eq!(crt(&[2, 3, 2], &[3, 5, 7]), Some(23));
    }

    #[test]
    fn crt_returns_none_with_non_coprime_moduli() {
        // moduli 4 and 6 are not coprime
        assert_eq!(crt(&[1, 2], &[4, 6]), None);
    }

    #[test]
    fn crt_with_single_modulus() {
        assert_eq!(crt(&[5], &[7]), Some(5));
    }
}
