//! Теория чисел и криптография (глава m13).
//!
//! Модулярная арифметика на `u64` для учебных примеров.
//! Для полноценных ключей RSA нужна произвольная точность
//! (например, `num-bigint`) --- добавим, когда дойдём до неё.

pub mod attacks;

/// Алгоритм Евклида: наибольший общий делитель.
pub fn gcd(a: u64, b: u64) -> u64 {
    let (mut a, mut b) = (a, b);
    while b != 0 {
        let r = a % b;
        a = b;
        b = r;
    }
    a
}

/// Расширенный алгоритм Евклида: тройка `(g, x, y)` с `a*x + b*y = g`.
pub fn egcd(a: i64, b: i64) -> (i64, i64, i64) {
    if b == 0 {
        (a, 1, 0)
    } else {
        let (g, x, y) = egcd(b, a % b);
        (g, y, x - (a / b) * y)
    }
}

/// Обратный элемент `a` по модулю `m`, если он существует.
pub fn mod_inverse(a: u64, m: u64) -> Option<u64> {
    let (g, x, _) = egcd(a as i64, m as i64);
    if g != 1 {
        return None;
    }
    Some(((x % m as i64 + m as i64) % m as i64) as u64)
}

/// Быстрое возведение в степень по модулю: `base^exp mod m`.
pub fn mod_pow(mut base: u64, mut exp: u64, m: u64) -> u64 {
    if m == 1 {
        return 0;
    }
    let mut result = 1;
    base %= m;
    while exp > 0 {
        if exp % 2 == 1 {
            result = result * base % m;
        }
        exp /= 2;
        base = base * base % m;
    }
    result
}

/// Учебный RSA на малых числах (без произвольной точности).
pub struct Rsa {
    /// Модуль `p * q`.
    pub n: u64,
    /// Открытый показатель.
    pub e: u64,
    d: u64,
}

impl Rsa {
    /// Собирает ключи из простых `p`, `q` и открытого показателя `e`.
    pub fn new(p: u64, q: u64, e: u64) -> Rsa {
        let n = p * q;
        let phi = (p - 1) * (q - 1);
        let d = mod_inverse(e, phi).expect("e должно быть взаимно простым с phi(n)");
        Rsa { n, e, d }
    }

    pub fn encrypt(&self, msg: u64) -> u64 {
        mod_pow(msg, self.e, self.n)
    }

    pub fn decrypt(&self, cipher: u64) -> u64 {
        mod_pow(cipher, self.d, self.n)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn euclid_finds_gcd() {
        assert_eq!(gcd(48, 18), 6);
        assert_eq!(gcd(17, 5), 1);
        assert_eq!(gcd(0, 7), 7);
    }

    #[test]
    fn inverse_of_three_mod_seven_is_five() {
        assert_eq!(mod_inverse(3, 7), Some(5)); // 3 * 5 = 15 = 1 (mod 7)
        assert_eq!(mod_inverse(2, 4), None);
    }

    #[test]
    fn fermat_little_theorem_small_case() {
        // p = 7, a = 3: 3^6 = 1 (mod 7).
        assert_eq!(mod_pow(3, 6, 7), 1);
    }

    #[test]
    fn rsa_roundtrip() {
        // Классический учебный пример из главы m13: p = 61, q = 53, e = 17.
        let rsa = Rsa::new(61, 53, 17);
        for msg in [0, 1, 42, 65, 123] {
            assert_eq!(rsa.decrypt(rsa.encrypt(msg)), msg);
        }
    }
}
