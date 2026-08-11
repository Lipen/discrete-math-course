//! Abstract domains: sign, interval, and constant.
//!
//! Every domain is a lattice: `lub` is the join ⊔ (merge two values), and
//! `Bottom`/`Top` are the least and greatest elements of the information order.

// ── Sign domain ──

/// The sign domain: ⊥, −, 0, +, ⊤.
///
/// # Examples
///
/// ```
/// use analysis::Sign;
///
/// assert_eq!(Sign::of(5), Sign::Pos);
/// assert_eq!(Sign::of(0), Sign::Zero);
/// assert_eq!(Sign::of(-3), Sign::Neg);
/// ```
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Sign {
    /// ⊥: the value is unreachable.
    Bottom,
    /// −: strictly negative.
    Neg,
    /// 0: zero.
    Zero,
    /// +: strictly positive.
    Pos,
    /// ⊤: the sign is unknown.
    Top,
}

impl std::fmt::Display for Sign {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Sign::Bottom => write!(f, "⊥"),
            Sign::Neg => write!(f, "-"),
            Sign::Zero => write!(f, "0"),
            Sign::Pos => write!(f, "+"),
            Sign::Top => write!(f, "⊤"),
        }
    }
}

impl Sign {
    /// The abstract value of a concrete integer.
    ///
    /// ```
    /// use analysis::Sign;
    ///
    /// assert_eq!(Sign::of(-10), Sign::Neg);
    /// assert_eq!(Sign::of(0), Sign::Zero);
    /// assert_eq!(Sign::of(42), Sign::Pos);
    /// ```
    pub fn of(n: i64) -> Sign {
        match n.cmp(&0) {
            std::cmp::Ordering::Less => Sign::Neg,
            std::cmp::Ordering::Equal => Sign::Zero,
            std::cmp::Ordering::Greater => Sign::Pos,
        }
    }

    /// The join ⊔ of two signs.
    ///
    /// ```
    /// use analysis::Sign;
    ///
    /// assert_eq!(Sign::Pos.lub(Sign::Pos), Sign::Pos); // same → identity
    /// assert_eq!(Sign::Pos.lub(Sign::Neg), Sign::Top); // different → ⊤
    /// assert_eq!(Sign::Bottom.lub(Sign::Zero), Sign::Zero); // ⊥ is neutral
    /// ```
    pub fn lub(self, other: Sign) -> Sign {
        use Sign::*;
        if self == other {
            return self;
        }
        match (self, other) {
            (Bottom, x) | (x, Bottom) => x,
            _ => Top,
        }
    }
}

/// Abstract addition ⊞.
///
/// ```
/// use analysis::Sign;
///
/// assert_eq!(Sign::Pos + Sign::Pos, Sign::Pos);
/// assert_eq!(Sign::Pos + Sign::Neg, Sign::Top); // a positive plus a negative: unknown
/// assert_eq!(Sign::Zero + Sign::Neg, Sign::Neg);
/// ```
impl std::ops::Add for Sign {
    type Output = Sign;
    fn add(self, other: Sign) -> Sign {
        use Sign::*;
        match (self, other) {
            (Bottom, _) | (_, Bottom) => Bottom,
            (Top, _) | (_, Top) => Top,
            (Neg, Neg) => Neg,
            (Pos, Pos) => Pos,
            (Zero, s) | (s, Zero) => s,
            (Neg, Pos) | (Pos, Neg) => Top, // a positive plus a negative: unknown
        }
    }
}

/// Abstract multiplication.
///
/// ```
/// use analysis::Sign;
///
/// assert_eq!(Sign::Neg * Sign::Neg, Sign::Pos);
/// assert_eq!(Sign::Pos * Sign::Neg, Sign::Neg);
/// assert_eq!(Sign::Zero * Sign::Pos, Sign::Zero);
/// assert_eq!(Sign::Top * Sign::Pos, Sign::Top);
/// ```
impl std::ops::Mul for Sign {
    type Output = Sign;
    fn mul(self, other: Sign) -> Sign {
        use Sign::*;
        match (self, other) {
            (Bottom, _) | (_, Bottom) => Bottom,
            (Top, _) | (_, Top) => Top,
            (Zero, _) | (_, Zero) => Zero,
            (Neg, Neg) | (Pos, Pos) => Pos,
            (Neg, Pos) | (Pos, Neg) => Neg,
        }
    }
}

/// Abstract negation.
///
/// ```
/// use analysis::Sign;
///
/// assert_eq!(-Sign::Pos, Sign::Neg);
/// assert_eq!(-Sign::Neg, Sign::Pos);
/// assert_eq!(-Sign::Zero, Sign::Zero);
/// assert_eq!(-Sign::Top, Sign::Top);
/// ```
impl std::ops::Neg for Sign {
    type Output = Sign;
    fn neg(self) -> Sign {
        use Sign::*;
        match self {
            Bottom => Bottom,
            Top => Top,
            Zero => Zero,
            Neg => Pos,
            Pos => Neg,
        }
    }
}

// ── Interval domain ──

/// The interval domain: `[lo, hi]`, with `None` standing for ±∞.
///
/// # Examples
///
/// ```
/// use analysis::Interval;
///
/// let a = Interval::point(3);
/// let b = Interval::Range { lo: Some(0), hi: Some(5) };
/// assert_eq!(a.lub(b), Interval::Range { lo: Some(0), hi: Some(5) });
/// ```
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Interval {
    /// ⊥: unreachable.
    Bottom,
    /// The range `[lo, hi]`; `None` means an open end.
    Range { lo: Option<i64>, hi: Option<i64> },
}

impl std::fmt::Display for Interval {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Interval::Bottom => write!(f, "⊥"),
            Interval::Range { lo, hi } => {
                let lo = lo.map_or_else(|| "−∞".to_string(), |x| x.to_string());
                let hi = hi.map_or_else(|| "+∞".to_string(), |x| x.to_string());
                write!(f, "[{lo}, {hi}]")
            }
        }
    }
}

impl Interval {
    /// The interval containing every integer.
    ///
    /// ```
    /// use analysis::Interval;
    ///
    /// assert_eq!(Interval::top(), Interval::Range { lo: None, hi: None });
    /// ```
    pub fn top() -> Interval {
        Interval::Range { lo: None, hi: None }
    }

    /// The interval containing a single integer.
    ///
    /// ```
    /// use analysis::Interval;
    ///
    /// assert_eq!(Interval::point(7), Interval::Range { lo: Some(7), hi: Some(7) });
    /// ```
    pub fn point(n: i64) -> Interval {
        Interval::Range {
            lo: Some(n),
            hi: Some(n),
        }
    }

    /// The join ⊔: the smallest range covering both.
    ///
    /// ```
    /// use analysis::Interval;
    ///
    /// let a = Interval::Range { lo: Some(1), hi: Some(3) };
    /// let b = Interval::Range { lo: Some(2), hi: Some(5) };
    /// assert_eq!(a.lub(b), Interval::Range { lo: Some(1), hi: Some(5) });
    /// ```
    pub fn lub(self, other: Interval) -> Interval {
        match (self, other) {
            (Interval::Bottom, r) | (r, Interval::Bottom) => r,
            (Interval::Range { lo: a, hi: b }, Interval::Range { lo: c, hi: d }) => {
                Interval::Range {
                    lo: lo_min(a, c),
                    hi: hi_max(b, d),
                }
            }
        }
    }

    /// The widening ∇: a bound that moved is dropped to ±∞.
    ///
    /// This ensures convergence for loops where bounds grow monotonically.
    ///
    /// ```
    /// use analysis::Interval;
    ///
    /// // [0,0] ∇ [0,1] = [0, +∞) -- the upper bound moved, so it is dropped.
    /// let a = Interval::point(0);
    /// let b = Interval::Range { lo: Some(0), hi: Some(1) };
    /// assert_eq!(a.widen(b), Interval::Range { lo: Some(0), hi: None });
    ///
    /// // A stable bound is kept.
    /// let c = Interval::Range { lo: Some(0), hi: Some(5) };
    /// assert_eq!(c.widen(c), c);
    /// ```
    pub fn widen(self, other: Interval) -> Interval {
        match (self, other) {
            (Interval::Bottom, r) => r,
            (r, Interval::Bottom) => r,
            (Interval::Range { lo: a, hi: b }, Interval::Range { lo: c, hi: d }) => {
                Interval::Range {
                    lo: if lo_lt(c, a) { None } else { a },
                    hi: if hi_gt(d, b) { None } else { b },
                }
            }
        }
    }
}

/// Abstract addition: `[a, b] + [c, d] = [a + c, b + d]`.
///
/// ```
/// use analysis::Interval;
///
/// let a = Interval::Range { lo: Some(1), hi: Some(3) };
/// let b = Interval::Range { lo: Some(5), hi: Some(7) };
/// assert_eq!(a + b, Interval::Range { lo: Some(6), hi: Some(10) });
/// ```
impl std::ops::Add for Interval {
    type Output = Interval;
    fn add(self, other: Interval) -> Interval {
        match (self, other) {
            (Interval::Bottom, _) | (_, Interval::Bottom) => Interval::Bottom,
            (Interval::Range { lo: a, hi: b }, Interval::Range { lo: c, hi: d }) => {
                Interval::Range {
                    lo: lo_add(a, c),
                    hi: hi_add(b, d),
                }
            }
        }
    }
}

/// Abstract negation: `-[lo, hi] = [-hi, -lo]`.
///
/// ```
/// use analysis::Interval;
///
/// let a = Interval::Range { lo: Some(1), hi: Some(5) };
/// assert_eq!(-a, Interval::Range { lo: Some(-5), hi: Some(-1) });
/// ```
impl std::ops::Neg for Interval {
    type Output = Interval;
    fn neg(self) -> Interval {
        match self {
            Interval::Bottom => Interval::Bottom,
            Interval::Range { lo, hi } => Interval::Range {
                lo: hi.map(|h| -h),
                hi: lo.map(|l| -l),
            },
        }
    }
}

/// Abstract multiplication: `[a,b] * [c,d] = [min(ac, ad, bc, bd), max(...)]`.
///
/// An unbounded operand gives `Top`: the product could be anything.
///
/// ```
/// use analysis::Interval;
///
/// let a = Interval::Range { lo: Some(-2), hi: Some(3) };
/// let b = Interval::Range { lo: Some(4), hi: Some(5) };
/// assert_eq!(a * b, Interval::Range { lo: Some(-10), hi: Some(15) });
///
/// // Unbounded operand → Top.
/// assert_eq!(Interval::top() * a, Interval::top());
/// ```
impl std::ops::Mul for Interval {
    type Output = Interval;
    fn mul(self, other: Interval) -> Interval {
        match (self, other) {
            (Interval::Bottom, _) | (_, Interval::Bottom) => Interval::Bottom,
            (
                Interval::Range {
                    lo: Some(a),
                    hi: Some(b),
                },
                Interval::Range {
                    lo: Some(c),
                    hi: Some(d),
                },
            ) => {
                let products = [
                    a.checked_mul(c),
                    a.checked_mul(d),
                    b.checked_mul(c),
                    b.checked_mul(d),
                ];
                if products.iter().any(|&p| p.is_none()) {
                    Interval::top()
                } else {
                    let vals = products.map(|p| p.unwrap());
                    Interval::Range {
                        lo: Some(vals.iter().copied().min().unwrap()),
                        hi: Some(vals.iter().copied().max().unwrap()),
                    }
                }
            }
            _ => Interval::top(),
        }
    }
}

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

    /// Widening ∇: if the value changed, go straight to ⊤.
    ///
    /// The constant lattice has infinite height (Val(0), Val(1), Val(2), ... are
    /// all incomparable), so plain iteration over a loop may never converge.
    /// Widening jumps to ⊤ on the first change, guaranteeing convergence in at most
    /// two steps.
    ///
    /// ```
    /// use analysis::Const;
    ///
    /// assert_eq!(Const::Val(0).widen(Const::Val(0)), Const::Val(0)); // stable
    /// assert_eq!(Const::Val(0).widen(Const::Val(1)), Const::Top); // changed → ⊤
    /// assert_eq!(Const::Bottom.widen(Const::Val(5)), Const::Val(5));
    /// ```
    pub fn widen(self, other: Const) -> Const {
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

// ── Interval helpers (None means ±∞) ──

fn lo_min(a: Option<i64>, b: Option<i64>) -> Option<i64> {
    match (a, b) {
        (None, _) | (_, None) => None,
        (Some(x), Some(y)) => Some(x.min(y)),
    }
}

fn hi_max(a: Option<i64>, b: Option<i64>) -> Option<i64> {
    match (a, b) {
        (None, _) | (_, None) => None,
        (Some(x), Some(y)) => Some(x.max(y)),
    }
}

fn lo_add(a: Option<i64>, b: Option<i64>) -> Option<i64> {
    match (a, b) {
        (Some(x), Some(y)) => x.checked_add(y),
        _ => None,
    }
}

fn hi_add(a: Option<i64>, b: Option<i64>) -> Option<i64> {
    match (a, b) {
        (Some(x), Some(y)) => x.checked_add(y),
        _ => None,
    }
}

/// `a < b` with `None` read as −∞.
fn lo_lt(a: Option<i64>, b: Option<i64>) -> bool {
    match (a, b) {
        (None, None) => false,
        (None, _) => true,
        (_, None) => false,
        (Some(x), Some(y)) => x < y,
    }
}

/// `a > b` with `None` read as +∞.
fn hi_gt(a: Option<i64>, b: Option<i64>) -> bool {
    match (a, b) {
        (None, None) => false,
        (None, _) => true,
        (_, None) => false,
        (Some(x), Some(y)) => x > y,
    }
}
