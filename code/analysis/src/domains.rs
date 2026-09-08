//! Abstract domains: the constant-propagation lattice.
//!
//! A domain is a lattice: `lub` is the join ⊔ (merge two values), and
//! `Bottom`/`Top` are the least and greatest elements of the information order.

// ── Constant domain ──

/// The constant domain: a known integer, ⊥, or ⊤ (not a constant).
///
/// Used for constant propagation: tracking which variables hold a known value.
///
/// # Examples
///
/// ```
/// use analysis::Const;
///
/// assert_eq!(Const::of(42), Const::Val(42));
/// assert_eq!(Const::Val(3) + Const::Val(5), Const::Val(8));
/// // Different constants joined become ⊤.
/// assert_eq!(Const::Val(1).lub(Const::Val(2)), Const::Top);
/// ```
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Const {
    /// ⊥: unreachable.
    Bottom,
    /// A known integer.
    Val(i64),
    /// ⊤: not a constant.
    Top,
}

impl std::fmt::Display for Const {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Const::Bottom => write!(f, "⊥"),
            Const::Val(n) => write!(f, "{n}"),
            Const::Top => write!(f, "⊤"),
        }
    }
}

impl Const {
    /// The abstract value of a concrete integer.
    ///
    /// ```
    /// use analysis::Const;
    ///
    /// assert_eq!(Const::of(7), Const::Val(7));
    /// assert_eq!(Const::of(-1), Const::Val(-1));
    /// ```
    pub fn of(n: i64) -> Const {
        Const::Val(n)
    }

    /// The join ⊔: equal values stay, anything else becomes ⊤.
    ///
    /// ```
    /// use analysis::Const;
    ///
    /// assert_eq!(Const::Val(5).lub(Const::Val(5)), Const::Val(5));
    /// assert_eq!(Const::Val(1).lub(Const::Val(2)), Const::Top);
    /// assert_eq!(Const::Bottom.lub(Const::Val(3)), Const::Val(3));
    /// ```
    pub fn lub(self, other: Const) -> Const {
        if self == other {
            return self;
        }
        match (self, other) {
            (Const::Bottom, x) | (x, Const::Bottom) => x,
            _ => Const::Top,
        }
    }
}

/// Abstract addition: known when both operands are known.
///
/// ```
/// use analysis::Const;
///
/// assert_eq!(Const::Val(3) + Const::Val(5), Const::Val(8));
/// assert_eq!(Const::Val(3) + Const::Top, Const::Top);
/// assert_eq!(Const::Bottom + Const::Val(1), Const::Bottom);
/// ```
impl std::ops::Add for Const {
    type Output = Const;
    fn add(self, other: Const) -> Const {
        match (self, other) {
            (Const::Bottom, _) | (_, Const::Bottom) => Const::Bottom,
            (Const::Val(a), Const::Val(b)) => Const::Val(a + b),
            _ => Const::Top,
        }
    }
}

/// Abstract multiplication.
///
/// A key insight of constant propagation: zero times anything is zero,
/// even when the other operand is unknown.
///
/// ```
/// use analysis::Const;
///
/// assert_eq!(Const::Val(3) * Const::Val(5), Const::Val(15));
/// assert_eq!(Const::Val(0) * Const::Top, Const::Val(0)); // 0 kills uncertainty
/// assert_eq!(Const::Top * Const::Val(0), Const::Val(0));
/// assert_eq!(Const::Val(7) * Const::Top, Const::Top);
/// ```
impl std::ops::Mul for Const {
    type Output = Const;
    fn mul(self, other: Const) -> Const {
        use Const::*;
        match (self, other) {
            (Bottom, _) | (_, Bottom) => Bottom,
            (Val(0), _) | (_, Val(0)) => Val(0), // 0 * anything = 0
            (Val(a), Val(b)) => Val(a * b),
            _ => Top,
        }
    }
}

/// Abstract negation: `-Val(n) = Val(-n)`.
///
/// ```
/// use analysis::Const;
///
/// assert_eq!(-Const::Val(5), Const::Val(-5));
/// assert_eq!(-Const::Top, Const::Top);
/// assert_eq!(-Const::Bottom, Const::Bottom);
/// ```
impl std::ops::Neg for Const {
    type Output = Const;
    fn neg(self) -> Const {
        match self {
            Const::Bottom => Const::Bottom,
            Const::Val(n) => Const::Val(-n),
            Const::Top => Const::Top,
        }
    }
}
