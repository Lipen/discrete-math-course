//! Number theory and cryptography.
//!
//! A teaching toolbox for the number-theory-and-cryptography chapter:
//! modular arithmetic on `u64`, textbook RSA with signing,
//! and attacks that show why the textbook versions are not secure.
//!
//! # Quick start
//!
//! ```
//! use crypto::{modular, Rsa};
//!
//! // Modular arithmetic
//! assert_eq!(modular::gcd(48, 18), 6);
//! assert_eq!(modular::mod_pow(2, 10, 1000), 24);
//!
//! // RSA roundtrip
//! let rsa = Rsa::new(61, 53, 17);
//! let c = rsa.encrypt(65);
//! assert_eq!(rsa.decrypt(c), 65);
//!
//! // RSA signing
//! let sig = rsa.sign(100);
//! assert!(rsa.verify(100, sig));
//! ```

pub mod attacks;
pub mod modular;
pub mod rsa;

pub use attacks::{common_modulus_attack, crt, factorize, malleable_product, pohlig_hellman};
pub use modular::{egcd, gcd, mod_inverse, mod_pow};
pub use rsa::Rsa;
