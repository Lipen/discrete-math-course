//! CNF formulas: literals, clauses, and formula construction.
//!
//! A literal is an integer: positive `v` means "variable `v` is true", negative `-v` means "variable `v` is false".
//! Variables are numbered from 1.
//! A clause is a disjunction of literals.
//! A CNF formula is a conjunction of clauses.

/// A literal: positive means the variable is true, negative means false.
///
/// ```
/// use sat::cnf::*;
///
/// let l = pos(2);
/// let not_l = neg(2);
///
/// assert_eq!(var_of(l), 2);
/// assert!(is_pos(l));
/// assert!(!is_pos(not_l));
/// assert_eq!(lit_idx(l), 1); // 0-based index
/// ```
pub type Lit = i32;

/// A clause is a disjunction of literals (at least one must be true).
pub type Clause = Vec<Lit>;

// ── Literal helpers ──────────────────────────────────────────────────────

/// Create a positive literal for variable `v` (1-based).
pub fn pos(v: usize) -> Lit {
    v as Lit
}

/// Create a negative literal for variable `v` (1-based).
pub fn neg(v: usize) -> Lit {
    -(v as Lit)
}

/// The variable number (1-based) of a literal.
pub fn var_of(lit: Lit) -> usize {
    lit.unsigned_abs() as usize
}

/// The 0-based index of a literal, suitable for assignment vectors.
pub fn lit_idx(lit: Lit) -> usize {
    lit.unsigned_abs() as usize - 1
}

/// Whether the literal is positive (the variable should be true).
pub fn is_pos(lit: Lit) -> bool {
    lit > 0
}

// ── Clause helpers ───────────────────────────────────────────────────────

/// The truth value of a literal under a partial assignment:
/// `Some(true)` when satisfied, `Some(false)` when falsified, `None` when unassigned.
fn lit_value(lit: Lit, assign: &[Option<bool>]) -> Option<bool> {
    assign[lit_idx(lit)].map(|v| v == is_pos(lit))
}

/// Whether the clause is satisfied under the current partial assignment.
///
/// A clause is satisfied when at least one literal evaluates to true.
///
/// ```
/// use sat::cnf::*;
///
/// // x1 ∨ ¬x2  with x1 = true, x2 unassigned  -> satisfied by x1.
/// let clause = vec![pos(1), neg(2)];
/// let assign = vec![Some(true), None];
/// assert!(clause_satisfied(&clause, &assign));
/// ```
pub fn clause_satisfied(clause: &Clause, assign: &[Option<bool>]) -> bool {
    clause.iter().any(|&l| lit_value(l, assign) == Some(true))
}

/// The forced literal of a unit clause, or `None`.
///
/// A clause is unit when exactly one literal is unassigned and all the rest are false.
/// Then that literal is forced to true.
///
/// ```
/// use sat::cnf::*;
///
/// // x1 ∨ ¬x2  with x2 = true  ->  ¬x2 is false, so x1 is forced.
/// let clause = vec![pos(1), neg(2)];
/// let assign = vec![None, Some(true)];
/// assert_eq!(unit_of(&clause, &assign), Some(pos(1)));
/// ```
pub fn unit_of(clause: &Clause, assign: &[Option<bool>]) -> Option<Lit> {
    let mut forced = None;
    let mut unassigned = 0;
    for &l in clause {
        match lit_value(l, assign) {
            Some(true) => return None, // already satisfied -- not a unit
            Some(false) => {}          // falsified
            None => {
                unassigned += 1;
                forced = Some(l);
            }
        }
    }
    if unassigned == 1 {
        forced
    } else {
        None
    }
}

/// Whether the clause still has at least one unassigned literal (is "alive").
///
/// A clause without unassigned literals, where all are false, is a conflict.
///
/// ```
/// use sat::cnf::*;
///
/// // x1 ∨ ¬x2  with x1 = false, x2 unassigned -> still alive (¬x2 could save it).
/// let clause = vec![pos(1), neg(2)];
/// assert!(clause_has_unassigned(&clause, &[Some(false), None]));
///
/// // Both falsified -> dead.
/// assert!(!clause_has_unassigned(&clause, &[Some(false), Some(true)]));
/// ```
pub fn clause_has_unassigned(clause: &Clause, assign: &[Option<bool>]) -> bool {
    clause.iter().any(|&l| assign[lit_idx(l)].is_none())
}

// ── CNF formula ──────────────────────────────────────────────────────────

/// A CNF formula: a conjunction of clauses over `num_vars` variables.
///
/// Variables are numbered from 1 to `num_vars` (inclusive).
///
/// ```
/// use sat::cnf::*;
///
/// // (x1 ∨ x2) ∧ (¬x1 ∨ x2) -- two variables, two clauses.
/// let cnf = Cnf::new(2, vec![
///     vec![pos(1), pos(2)],
///     vec![neg(1), pos(2)],
/// ]).unwrap();
///
/// assert_eq!(cnf.num_vars, 2);
/// assert_eq!(cnf.clauses.len(), 2);
/// ```
#[derive(Debug, Clone)]
pub struct Cnf {
    /// Number of variables in the formula (1-indexed).
    pub num_vars: usize,
    /// Clauses of the formula.
    pub clauses: Vec<Clause>,
}

impl Cnf {
    /// Create a new CNF formula.
    ///
    /// Returns `None` when any literal is 0 or refers to a variable outside
    /// `1..=num_vars`.
    pub fn new(num_vars: usize, clauses: Vec<Clause>) -> Option<Cnf> {
        for clause in &clauses {
            for &lit in clause {
                let v = var_of(lit);
                if v == 0 || v > num_vars {
                    return None;
                }
            }
        }
        Some(Cnf { num_vars, clauses })
    }

    /// Generate a random 3-SAT formula.
    ///
    /// Each clause has exactly 3 literals over distinct variables, each with random polarity.
    ///
    /// ```
    /// use sat::cnf::Cnf;
    ///
    /// let cnf = Cnf::random_3sat(5, 10, 42);
    /// assert_eq!(cnf.num_vars, 5);
    /// assert_eq!(cnf.clauses.len(), 10);
    /// for clause in &cnf.clauses {
    ///     assert_eq!(clause.len(), 3);
    /// }
    /// ```
    pub fn random_3sat(num_vars: usize, num_clauses: usize, seed: u64) -> Cnf {
        let mut rng = XorShift64::new(seed);
        let mut clauses = Vec::with_capacity(num_clauses);
        for _ in 0..num_clauses {
            let mut clause = Vec::with_capacity(3);
            let mut vars = Vec::with_capacity(3);
            while vars.len() < 3 {
                let v = rng.below(num_vars) + 1;
                if !vars.contains(&v) {
                    vars.push(v);
                }
            }
            for v in vars {
                if rng.below(2) == 0 {
                    clause.push(pos(v));
                } else {
                    clause.push(neg(v));
                }
            }
            clauses.push(clause);
        }
        Cnf { num_vars, clauses }
    }
}

// ── Display helpers ──────────────────────────────────────────────────────

/// Format a literal as a string, e.g. `"x1"` or `"¬x2"`.
pub fn format_lit(lit: Lit) -> String {
    if is_pos(lit) {
        format!("x{}", var_of(lit))
    } else {
        format!("¬x{}", var_of(lit))
    }
}

/// Format a clause as a string, e.g. `"x1 ∨ ¬x2 ∨ x3"`.
pub fn format_clause(clause: &Clause) -> String {
    clause
        .iter()
        .map(|&l| format_lit(l))
        .collect::<Vec<_>>()
        .join(" ∨ ")
}

/// Format a CNF formula as a readable string.
pub fn format_cnf(cnf: &Cnf) -> String {
    if cnf.clauses.is_empty() {
        return "∅ (empty formula)".to_string();
    }
    cnf.clauses
        .iter()
        .map(|c| format!("({})", format_clause(c)))
        .collect::<Vec<_>>()
        .join(" ∧ ")
}

// ── Internal PRNG ────────────────────────────────────────────────────────

/// Simple xorshift64 generator -- keeps the crate dependency-free.
pub(crate) struct XorShift64(u64);

impl XorShift64 {
    /// Create a new generator. A zero seed is replaced with a non-zero default
    /// because xorshift requires a non-zero state.
    pub(crate) fn new(seed: u64) -> Self {
        if seed == 0 {
            XorShift64(0x9E37_79B9_7F4A_7C15)
        } else {
            XorShift64(seed)
        }
    }

    /// A pseudo-random `usize` in `0..n`.
    pub(crate) fn below(&mut self, n: usize) -> usize {
        let mut x = self.0;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        self.0 = x;
        (x as usize) % n
    }
}
