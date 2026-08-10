//! Abstract domains: sign, interval, and constant.
//!
//! Every domain is a lattice: `lub` is the join ⊔ (merge two values), and
//! `Bottom`/`Top` are the least and greatest elements of the information order.

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

/// The sign domain: ⊥, −, 0, +, ⊤.
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

impl Sign {
    /// The abstract value of a concrete integer.
    pub fn of(n: i64) -> Sign {
        match n.cmp(&0) {
            std::cmp::Ordering::Less => Sign::Neg,
            std::cmp::Ordering::Equal => Sign::Zero,
            std::cmp::Ordering::Greater => Sign::Pos,
        }
    }

    /// The join ⊔ of two signs.
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

/// The interval domain: `[lo, hi]`, with `None` standing for ±∞.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Interval {
    /// ⊥: unreachable.
    Bottom,
    /// The range `[lo, hi]`; `None` means an open end.
    Range { lo: Option<i64>, hi: Option<i64> },
}

impl Interval {
    /// The interval containing every integer.
    pub fn top() -> Interval {
        Interval::Range { lo: None, hi: None }
    }

    /// The interval containing a single integer.
    pub fn point(n: i64) -> Interval {
        Interval::Range {
            lo: Some(n),
            hi: Some(n),
        }
    }

    /// The join ⊔: the smallest range covering both.
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

    /// The widening ∇ from the chapter: a bound that moved is dropped to ±∞.
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
impl std::ops::Neg for Interval {
    type Output = Interval;
    fn neg(self) -> Interval {
        match self {
            Interval::Bottom => Interval::Bottom,
            Interval::Range { lo, hi } => Interval::Range { lo: hi, hi: lo },
        }
    }
}

/// Abstract multiplication, from the chapter:
/// `[a,b] * [c,d] = [min(ac, ad, bc, bd), max(ac, ad, bc, bd)]`.
///
/// An unbounded operand gives `Top`: the product could be anything.
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

/// The constant domain: a known integer, ⊥, or ⊤ (not a constant).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Const {
    /// ⊥: unreachable.
    Bottom,
    /// A known integer.
    Val(i64),
    /// ⊤: not a constant.
    Top,
}

impl Const {
    /// The abstract value of a concrete integer.
    pub fn of(n: i64) -> Const {
        Const::Val(n)
    }

    /// The join ⊔: equal values stay, anything else becomes ⊤.
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
