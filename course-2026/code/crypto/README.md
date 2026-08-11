# crypto

Number theory and cryptography.

A small, dependency-free toolbox of modular arithmetic on `u64`, a textbook RSA with signing, and a set of attacks that actually break it.
The point of the crate: to trust a cryptosystem you first have to attack it.

## Quick start

```bash
cargo run -p crypto --example rsa_demo
cargo run -p crypto --example pohlig_hellman
cargo test -p crypto
```

## Modules

| Module | Purpose |
| --- | --- |
| `modular` | `gcd`, `egcd`, `mod_inverse`, `mod_pow` |
| `rsa` | `Rsa` struct: key generation, encrypt/decrypt, sign/verify |
| `attacks` | Common modulus, malleability, factorization, CRT, Pohlig--Hellman |

## RSA in one picture

![RSA flow](assets/rsa-flow.svg)

Key generation picks primes $p$, $q$, computes $n = pq$ and $\phi(n) = (p-1)(q-1)$, chooses a public exponent $e$ coprime to $\phi(n)$, and derives the private key $d = e^{-1} \bmod \phi(n)$.
Encryption and decryption are the same operation with different exponents:

$$ c = m^e \bmod n \qquad m = c^d \bmod n $$

## API

| Item | Purpose |
| --- | --- |
| `gcd`, `egcd`, `mod_inverse`, `mod_pow` | Modular-arithmetic toolbox |
| `Rsa::new`, `encrypt`, `decrypt` | Textbook RSA on small numbers |
| `Rsa::sign`, `verify` | Digital signature with RSA |
| `attacks::common_modulus_attack` | Recover $m$ from two ciphertexts that share $n$ |
| `attacks::malleable_product` | $c_1 c_2 = (m_1 m_2)^e \bmod n$ |
| `attacks::factorize` | Trial division; shows why small primes fail |
| `attacks::crt` | Chinese remainder theorem |
| `attacks::pohlig_hellman` | Discrete log when $p-1$ is smooth |

## Demos

| Demo | Chapter idea | What it prints |
| --- | --- | --- |
| `brute_force_caesar` | Caesar cipher | All 33 shifts; the plaintext appears at shift 3 |
| `frequency_analysis` | Simple substitution | Letter frequencies; the top ciphertext letter maps to «о» |
| `common_modulus` | RSA common-modulus attack | $m$ recovered without any private key |
| `malleability` | RSA malleability | $c_1 c_2$ decrypts to $m_1 m_2$ |
| `pohlig_hellman` | Discrete log, smooth order | $x$ with $g^x = h \pmod p$ |
| `rsa_demo` | RSA | Encrypt/decrypt round trip and signing/verification |

## Tests

```bash
cargo test -p crypto
```
