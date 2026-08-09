//! Атака с общим модулем на RSA (глава m13, раздел «Взлом»).
//!
//! Два пользователя делят модуль $n$, показатели $e_1$, $e_2$ взаимно просты.
//! Расширенный алгоритм Евклида даёт $u, v$ с $e_1 u + e_2 v = 1$, и
//! $c_1^u c_2^v = m$ --- закрытые ключи не нужны.

use crypto::attacks::common_modulus_attack;
use crypto::{mod_inverse, mod_pow};

fn main() {
    let p = 61;
    let q = 53;
    let n = p * q;
    let phi = (p - 1) * (q - 1);
    let e1 = 17;
    let e2 = 7; // gcd(17, 7) = 1

    let m = 42;
    let c1 = mod_pow(m, e1, n);
    let c2 = mod_pow(m, e2, n);

    println!("n = {n}, e1 = {e1}, e2 = {e2}, m = {m}");
    println!("c1 = m^e1 = {c1}");
    println!("c2 = m^e2 = {c2}");

    let recovered = common_modulus_attack(n, e1, c1, e2, c2).expect("атака должна удаться");
    println!("Атака восстановила: {recovered}");

    // Закрытые показатели существовали, но не понадобились.
    let _d1 = mod_inverse(e1, phi).unwrap();
    let _d2 = mod_inverse(e2, phi).unwrap();
    println!("Модуль обязан быть индивидуальным у каждого пользователя.");
}
