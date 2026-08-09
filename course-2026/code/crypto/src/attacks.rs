//! Атаки на криптосистемы.
//!
//! Каждая атака показывает грань, за которой система перестаёт быть
//! безопасной: общий модуль и маллобильность ломают неумелый RSA,
//! Полиг--Хеллман --- DLOG в группе с гладким порядком.

use super::{egcd, mod_inverse, mod_pow};

/// Возведение в степень по модулю с отрицательным показателем
/// (через обратный элемент).
fn mod_pow_signed(base: u64, exp: i64, m: u64) -> Option<u64> {
    if exp >= 0 {
        Some(mod_pow(base, exp as u64, m))
    } else {
        let inv = mod_inverse(base, m)?;
        Some(mod_pow(inv, exp.unsigned_abs(), m))
    }
}

/// Атака с общим модулем.
///
/// Два пользователя используют один модуль $n$ с разными показателями
/// $e_1$, $e_2$ ($"gcd"(e_1, e_2) = 1$). Увидев $c_1 = m^(e_1)$ и
/// $c_2 = m^(e_2)$, злоумышленник находит $u, v$ с $e_1 u + e_2 v = 1$
/// расширенным алгоритмом Евклида и вычисляет $c_1^u c_2^v = m$.
pub fn common_modulus_attack(n: u64, e1: u64, c1: u64, e2: u64, c2: u64) -> Option<u64> {
    let (g, u, v) = egcd(e1 as i64, e2 as i64);
    if g != 1 {
        return None;
    }
    let a = mod_pow_signed(c1, u, n)?;
    let b = mod_pow_signed(c2, v, n)?;
    Some(a * b % n)
}

/// Маллобильность RSA: произведение шифротекстов --- шифротекст
/// произведения сообщений: $c_1 c_2 = (m_1 m_2)^e mod n$.
pub fn malleable_product(c1: u64, c2: u64, n: u64) -> u64 {
    c1 % n * c2 % n
}

/// Разложение на простые множители пробным делением: `[(простое, степень)]`.
pub fn factorize(mut n: u64) -> Vec<(u64, u64)> {
    let mut factors = Vec::new();
    let mut d = 2;
    while d * d <= n {
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

/// Китайская теорема об остатках для попарно взаимно простых модулей.
fn crt(residues: &[u64], moduli: &[u64]) -> Option<u64> {
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

/// Упрощённая атака Полига--Хеллмана: дискретный логарифм
/// $x = log_g h (mod p)$, когда порядок группы $p - 1$ гладкий.
///
/// Для каждой простой степени $q^a$ порядок логарифма сводится к подгруппе
/// порядка $q^a$, где ответ находится перебором; результаты собираются по CRT.
pub fn pohlig_hellman(p: u64, g: u64, h: u64) -> Option<u64> {
    let n = p - 1;
    let mut residues = Vec::new();
    let mut moduli = Vec::new();
    for (q, a) in factorize(n) {
        let qa = q.pow(a as u32);
        let g_a = mod_pow(g, n / qa, p);
        let h_a = mod_pow(h, n / qa, p);
        // h_a = g_a^(x mod qa): перебираем показатель в подгруппе порядка qa.
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
            return None; // h не лежит в подгруппе (не должно случаться для образующего g)
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
        // Учебные ключи с общим модулем n = 61 * 53.
        let n = 61 * 53;
        let e1 = 17;
        let e2 = 7; // gcd(17, 7) = 1
        let m = 42;
        let c1 = mod_pow(m, e1, n);
        let c2 = mod_pow(m, e2, n);
        assert_eq!(common_modulus_attack(n, e1, c1, e2, c2), Some(m));
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
    fn pohlig_hellman_solves_smooth_dlog() {
        // p = 29, порядок группы 28 = 2^2 * 7 --- гладкий.
        let p = 29;
        let g = 2; // образующий ZZ_29^*
        let x = 13;
        let h = mod_pow(g, x, p);
        assert_eq!(pohlig_hellman(p, g, h), Some(x));
    }

    #[test]
    fn factorize_splits_smooth_order() {
        assert_eq!(factorize(28), vec![(2, 2), (7, 1)]);
        assert_eq!(factorize(12), vec![(2, 2), (3, 1)]);
        assert_eq!(factorize(13), vec![(13, 1)]);
    }
}
