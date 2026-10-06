//! A deterministic generator for the randomized property checks.
//!
//! The tests cross-check the crate against the built-in types on seeded
//! operands: the same seed replays the same run, so a failure is always
//! reproducible.

/// SplitMix64: the state advances by the golden-ratio constant, then three
/// mixing rounds spread the bits.
pub struct SplitMix64 {
    state: u64,
}

impl SplitMix64 {
    /// Seeds the generator.
    pub fn new(seed: u64) -> Self {
        SplitMix64 { state: seed }
    }

    /// The next pseudorandom 64-bit value.
    pub fn next_u64(&mut self) -> u64 {
        self.state = self.state.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut z = self.state;
        z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        z ^ (z >> 31)
    }

    /// A value in `0..bound`; `bound` must be positive.
    ///
    /// # Panics
    ///
    /// Panics when `bound` is zero.
    pub fn below(&mut self, bound: u64) -> u64 {
        assert!(bound > 0, "bound must be positive");
        self.next_u64() % bound
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sequence_is_reproducible() {
        let mut first = SplitMix64::new(42);
        let mut second = SplitMix64::new(42);
        for _ in 0..10 {
            assert_eq!(first.next_u64(), second.next_u64());
        }
    }

    #[test]
    fn below_stays_in_range() {
        let mut rng = SplitMix64::new(9);
        for _ in 0..1000 {
            assert!(rng.below(7) < 7);
        }
    }

    #[test]
    #[should_panic(expected = "bound must be positive")]
    fn below_rejects_zero_bound() {
        let mut rng = SplitMix64::new(1);
        let _ = rng.below(0);
    }
}
