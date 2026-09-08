//! Textbook RSA on small numbers.
//!
//! A teaching implementation: key generation from two primes,
//! encryption/decryption, and digital signatures.
//! Real RSA needs arbitrary-precision integers and padding
//! (OAEP for encryption, PSS for signatures).

use super::modular::{mod_inverse, mod_pow};

/// Teaching RSA on small numbers (without arbitrary precision).
///
/// # Examples
///
/// ```
/// use crypto::rsa::Rsa;
///
/// let rsa = Rsa::new(61, 53, 17);
/// let c = rsa.encrypt(65);
/// assert_eq!(rsa.decrypt(c), 65);
/// ```
pub struct Rsa {
    /// The modulus `p * q`.
    pub n: u64,
    /// The public exponent.
    pub e: u64,
    d: u64,
}

impl Rsa {
    /// Builds keys from primes `p`, `q` and the public exponent `e`.
    ///
    /// Computes `n = p * q`, `φ = (p-1)(q-1)`, and the private key
    /// `d = e^(-1) mod φ`.
    ///
    /// # Panics
    ///
    /// Panics if `e` is not coprime with `φ(n)`.
    ///
    /// # Examples
    ///
    /// ```
    /// use crypto::rsa::Rsa;
    ///
    /// let rsa = Rsa::new(61, 53, 17);
    /// assert_eq!(rsa.n, 3233);
    /// assert_eq!(rsa.e, 17);
    /// ```
    pub fn new(p: u64, q: u64, e: u64) -> Rsa {
        let n = p * q;
        let phi = (p - 1) * (q - 1);
        let d = mod_inverse(e, phi).expect("e must be coprime with phi(n)");
        Rsa { n, e, d }
    }

    /// Encrypts `msg` with the public key: `c = msg^e mod n`.
    ///
    /// # Examples
    ///
    /// ```
    /// use crypto::rsa::Rsa;
    ///
    /// let rsa = Rsa::new(61, 53, 17);
    /// let c = rsa.encrypt(42);
    /// assert_eq!(rsa.decrypt(c), 42); // roundtrip works
    /// ```
    pub fn encrypt(&self, msg: u64) -> u64 {
        mod_pow(msg, self.e, self.n)
    }

    /// Decrypts `cipher` with the private key: `m = cipher^d mod n`.
    ///
    /// # Examples
    ///
    /// ```
    /// use crypto::rsa::Rsa;
    ///
    /// let rsa = Rsa::new(61, 53, 17);
    /// let c = rsa.encrypt(42);
    /// assert_eq!(rsa.decrypt(c), 42);
    /// ```
    pub fn decrypt(&self, cipher: u64) -> u64 {
        mod_pow(cipher, self.d, self.n)
    }

    /// Signs `msg` with the private key: `s = msg^d mod n`.
    ///
    /// In textbook RSA, signing is the same mathematical operation
    /// as decryption: the signer applies the private exponent.
    ///
    /// # Examples
    ///
    /// ```
    /// use crypto::rsa::Rsa;
    ///
    /// let rsa = Rsa::new(61, 53, 17);
    /// let sig = rsa.sign(100);
    /// assert!(rsa.verify(100, sig));
    /// ```
    pub fn sign(&self, msg: u64) -> u64 {
        self.decrypt(msg)
    }

    /// Verifies a signature: returns `true` if `sig^e mod n == msg`.
    ///
    /// # Examples
    ///
    /// ```
    /// use crypto::rsa::Rsa;
    ///
    /// let rsa = Rsa::new(61, 53, 17);
    /// let sig = rsa.sign(100);
    /// assert!(rsa.verify(100, sig));
    /// assert!(!rsa.verify(100, sig + 1)); // tampered signature
    /// ```
    pub fn verify(&self, msg: u64, sig: u64) -> bool {
        self.encrypt(sig) == msg
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rsa_roundtrip_small_messages() {
        let rsa = Rsa::new(61, 53, 17);
        for msg in [0, 1, 42, 65, 123] {
            assert_eq!(rsa.decrypt(rsa.encrypt(msg)), msg);
        }
    }

    #[test]
    fn rsa_roundtrip_edge_cases() {
        let rsa = Rsa::new(61, 53, 17);
        assert_eq!(rsa.decrypt(rsa.encrypt(0)), 0);
        assert_eq!(rsa.decrypt(rsa.encrypt(1)), 1);
        assert_eq!(rsa.decrypt(rsa.encrypt(rsa.n - 1)), rsa.n - 1);
    }

    #[test]
    fn sign_and_verify_works() {
        let rsa = Rsa::new(61, 53, 17);
        let msg = 100;
        let sig = rsa.sign(msg);
        assert!(rsa.verify(msg, sig));
    }

    #[test]
    fn tampered_signature_fails_verification() {
        let rsa = Rsa::new(61, 53, 17);
        let sig = rsa.sign(42);
        assert!(!rsa.verify(42, sig + 1)); // modified signature
        assert!(!rsa.verify(43, sig)); // wrong message
    }

    #[test]
    #[should_panic(expected = "e must be coprime")]
    fn new_panics_on_non_coprime_e() {
        // p=7, q=13, phi=72, e=2: gcd(2, 72) = 2
        Rsa::new(7, 13, 2);
    }

    #[test]
    fn encrypt_is_deterministic() {
        let rsa = Rsa::new(61, 53, 17);
        assert_eq!(rsa.encrypt(42), rsa.encrypt(42));
    }

    #[test]
    fn different_keys_produce_different_ciphertexts() {
        let a = Rsa::new(61, 53, 17);
        let b = Rsa::new(67, 71, 13);
        assert_ne!(a.encrypt(42), b.encrypt(42));
    }
}
