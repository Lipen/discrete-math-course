//! Regular expressions and the Thompson construction.
//!
//! A regular expression is parsed from a string by recursive descent and
//! turned into an epsilon-NFA via the Thompson construction.
//! The result can be determinized with [`Nfa::to_dfa`](crate::Nfa::to_dfa).
//!
//! The grammar is: `union := concat ('|' concat)*`, `concat := star+`,
//! `star := atom '*'*`, `atom := symbol | '(' union ')'`.
//! Juxtaposition is implicit concatenation.
//!
//! ```
//! use automata::{parse, RegEx};
//!
//! let re = parse("(a|b)*a(a|b)").unwrap();
//! // Words whose second-to-last letter is 'a'.
//! let nfa = re.to_nfa();
//! assert!(nfa.accepts("aa"));
//! assert!(nfa.accepts("ab"));
//! assert!(!nfa.accepts("ba"));
//! assert!(!nfa.accepts(""));
//! ```

use crate::nfa::Nfa;

/// A regular expression over an alphabet of `char`.
///
/// Construct via the [`parse`] function or the convenience methods
/// [`sym`](RegEx::sym), [`concat`](RegEx::concat), [`union`](RegEx::union),
/// [`star`](RegEx::star).
///
/// ```
/// use automata::RegEx;
///
/// // (a|b)*  --  zero or more repetitions of 'a' or 'b'.
/// let re = RegEx::star(RegEx::union(RegEx::sym('a'), RegEx::sym('b')));
/// let nfa = re.to_nfa();
/// assert!(nfa.accepts(""));
/// assert!(nfa.accepts("a"));
/// assert!(nfa.accepts("abba"));
/// assert!(!nfa.accepts("c"));
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum RegEx {
    /// The empty language `∅` -- accepts nothing.
    Empty,
    /// The empty word `ε` -- accepts only the empty string.
    Epsilon,
    /// A single symbol.
    Sym(char),
    /// Concatenation `AB` -- words that are a word of A followed by a word of B.
    Concat(Box<RegEx>, Box<RegEx>),
    /// Union `A|B` -- words that belong to A or to B (or both).
    Union(Box<RegEx>, Box<RegEx>),
    /// Kleene star `A*` -- zero or more repetitions of a word from A.
    Star(Box<RegEx>),
}

impl RegEx {
    /// A single symbol.
    ///
    /// ```
    /// use automata::RegEx;
    ///
    /// let re = RegEx::sym('x');
    /// let nfa = re.to_nfa();
    /// assert!(nfa.accepts("x"));
    /// assert!(!nfa.accepts(""));
    /// assert!(!nfa.accepts("xx"));
    /// ```
    pub fn sym(c: char) -> RegEx {
        RegEx::Sym(c)
    }

    /// The empty language.
    ///
    /// ```
    /// use automata::RegEx;
    ///
    /// let re = RegEx::empty();
    /// let nfa = re.to_nfa();
    /// assert!(!nfa.accepts(""));
    /// assert!(!nfa.accepts("a"));
    /// ```
    pub fn empty() -> RegEx {
        RegEx::Empty
    }

    /// The empty word (epsilon).
    ///
    /// ```
    /// use automata::RegEx;
    ///
    /// let re = RegEx::epsilon();
    /// let nfa = re.to_nfa();
    /// assert!(nfa.accepts(""));
    /// assert!(!nfa.accepts("a"));
    /// ```
    pub fn epsilon() -> RegEx {
        RegEx::Epsilon
    }

    /// Concatenation of two expressions: `AB`.
    ///
    /// ```
    /// use automata::RegEx;
    ///
    /// let re = RegEx::concat(RegEx::sym('a'), RegEx::sym('b'));
    /// let nfa = re.to_nfa();
    /// assert!(nfa.accepts("ab"));
    /// assert!(!nfa.accepts("a"));
    /// assert!(!nfa.accepts("ba"));
    /// ```
    pub fn concat(a: RegEx, b: RegEx) -> RegEx {
        RegEx::Concat(Box::new(a), Box::new(b))
    }

    /// Union of two expressions: `A|B`.
    ///
    /// ```
    /// use automata::RegEx;
    ///
    /// let re = RegEx::union(RegEx::sym('a'), RegEx::sym('b'));
    /// let nfa = re.to_nfa();
    /// assert!(nfa.accepts("a"));
    /// assert!(nfa.accepts("b"));
    /// assert!(!nfa.accepts(""));
    /// assert!(!nfa.accepts("ab"));
    /// ```
    pub fn union(a: RegEx, b: RegEx) -> RegEx {
        RegEx::Union(Box::new(a), Box::new(b))
    }

    /// Kleene star of an expression: `A*`.
    ///
    /// ```
    /// use automata::RegEx;
    ///
    /// let re = RegEx::star(RegEx::sym('a'));
    /// let nfa = re.to_nfa();
    /// assert!(nfa.accepts(""));
    /// assert!(nfa.accepts("a"));
    /// assert!(nfa.accepts("aaaa"));
    /// assert!(!nfa.accepts("b"));
    /// ```
    pub fn star(a: RegEx) -> RegEx {
        RegEx::Star(Box::new(a))
    }

    /// Symbols occurring in the expression (the alphabet of the built automaton).
    fn symbols(&self, out: &mut Vec<char>) {
        match self {
            RegEx::Sym(c) => {
                if !out.contains(c) {
                    out.push(*c);
                }
            }
            RegEx::Concat(a, b) | RegEx::Union(a, b) => {
                a.symbols(out);
                b.symbols(out);
            }
            RegEx::Star(a) => a.symbols(out),
            RegEx::Empty | RegEx::Epsilon => {}
        }
    }

    /// Thompson construction: regular expression -> epsilon-NFA.
    ///
    /// Each constructor (`Empty`, `Epsilon`, `Sym`, `Concat`, `Union`,
    /// `Star`) adds a small sub-automaton with exactly one start state
    /// and one accepting state.
    ///
    /// ```
    /// use automata::RegEx;
    ///
    /// // (a|b)*a  --  words ending in 'a'.
    /// let re = RegEx::concat(
    ///     RegEx::star(RegEx::union(RegEx::sym('a'), RegEx::sym('b'))),
    ///     RegEx::sym('a'),
    /// );
    /// let nfa = re.to_nfa();
    /// assert!(nfa.accepts("a"));
    /// assert!(nfa.accepts("ba"));
    /// assert!(nfa.accepts("abba"));
    /// assert!(!nfa.accepts(""));
    /// assert!(!nfa.accepts("b"));
    /// ```
    pub fn to_nfa(&self) -> Nfa {
        let mut alphabet = Vec::new();
        self.symbols(&mut alphabet);
        let mut nfa = Nfa::new(alphabet);
        let (start, end) = self.build(&mut nfa);
        nfa.set_start(start);
        nfa.set_accepting(end, true);
        nfa
    }

    /// Builds an automaton fragment for the expression, returning the pair
    /// `(start, end)`. `end` is the accepting state of the fragment.
    fn build(&self, nfa: &mut Nfa) -> (usize, usize) {
        match self {
            RegEx::Empty => {
                let s = nfa.add_state(false);
                let e = nfa.add_state(false);
                (s, e)
            }
            RegEx::Epsilon => {
                let s = nfa.add_state(false);
                let e = nfa.add_state(false);
                nfa.add_epsilon(s, e);
                (s, e)
            }
            RegEx::Sym(c) => {
                let s = nfa.add_state(false);
                let e = nfa.add_state(false);
                nfa.add_transition(s, *c, e)
                    .expect("symbol from the regex's own alphabet");
                (s, e)
            }
            RegEx::Concat(a, b) => {
                let (s1, e1) = a.build(nfa);
                let (s2, e2) = b.build(nfa);
                nfa.add_epsilon(e1, s2);
                (s1, e2)
            }
            RegEx::Union(a, b) => {
                let s = nfa.add_state(false);
                let e = nfa.add_state(false);
                let (s1, e1) = a.build(nfa);
                let (s2, e2) = b.build(nfa);
                nfa.add_epsilon(s, s1);
                nfa.add_epsilon(s, s2);
                nfa.add_epsilon(e1, e);
                nfa.add_epsilon(e2, e);
                (s, e)
            }
            RegEx::Star(r) => {
                let s = nfa.add_state(false);
                let e = nfa.add_state(false);
                let (s1, e1) = r.build(nfa);
                nfa.add_epsilon(s, s1);
                nfa.add_epsilon(s, e);
                nfa.add_epsilon(e1, s1);
                nfa.add_epsilon(e1, e);
                (s, e)
            }
        }
    }
}

/// Recursive descent over the grammar:
/// `union := concat ('|' concat)*`, `concat := star+`,
/// `star := atom '*'*`, `atom := symbol | '(' union ')'`.
struct Parser {
    chars: Vec<char>,
    pos: usize,
}

impl Parser {
    fn new(s: &str) -> Self {
        Parser {
            chars: s.chars().collect(),
            pos: 0,
        }
    }

    fn parse(mut self) -> Result<RegEx, String> {
        let result = self.union()?;
        if self.pos != self.chars.len() {
            return Err("extra symbols at the end of the expression".to_string());
        }
        Ok(result)
    }

    fn union(&mut self) -> Result<RegEx, String> {
        let mut left = self.concat()?;
        while self.peek() == Some('|') {
            self.pos += 1;
            let right = self.concat()?;
            left = RegEx::Union(Box::new(left), Box::new(right));
        }
        Ok(left)
    }

    fn concat(&mut self) -> Result<RegEx, String> {
        let mut left = self.star()?;
        while matches!(self.peek(), Some(c) if c != '|' && c != ')') {
            let right = self.star()?;
            left = RegEx::Concat(Box::new(left), Box::new(right));
        }
        Ok(left)
    }

    fn star(&mut self) -> Result<RegEx, String> {
        let mut atom = self.atom()?;
        while self.peek() == Some('*') {
            self.pos += 1;
            atom = RegEx::Star(Box::new(atom));
        }
        Ok(atom)
    }

    fn atom(&mut self) -> Result<RegEx, String> {
        match self.peek() {
            None => Err("unexpected end of expression".to_string()),
            Some('(') => {
                self.pos += 1;
                let inner = self.union()?;
                if self.peek() != Some(')') {
                    return Err("expected a closing parenthesis".to_string());
                }
                self.pos += 1;
                Ok(inner)
            }
            Some(')') | Some('|') | Some('*') => {
                Err(format!("unexpected symbol '{}'", self.peek().unwrap()))
            }
            Some(c) => {
                self.pos += 1;
                Ok(RegEx::Sym(c))
            }
        }
    }

    fn peek(&self) -> Option<char> {
        self.chars.get(self.pos).copied()
    }
}

/// Parses a string into a regular expression.
///
/// The syntax supports symbols (any char except `(`, `)`, `|`, `*`),
/// concatenation by juxtaposition, union `|`, Kleene star `*`, and
/// grouping with parentheses.
///
/// ```
/// use automata::parse;
///
/// // Words whose second-to-last letter is 'a'.
/// let re = parse("(a|b)*a(a|b)").unwrap();
/// let nfa = re.to_nfa();
/// assert!(nfa.accepts("aa"));
/// assert!(nfa.accepts("ab"));
/// assert!(!nfa.accepts("ba"));
///
/// // Parse errors.
/// assert!(parse("a|").is_err());
/// assert!(parse("(a").is_err());
/// assert!(parse("*a").is_err());
/// ```
pub fn parse(s: &str) -> Result<RegEx, String> {
    Parser::new(s).parse()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn matches(re: &str, word: &str) -> bool {
        parse(re).unwrap().to_nfa().accepts(word)
    }

    #[test]
    fn literal_matches_exactly() {
        assert!(matches("a", "a"));
        assert!(!matches("a", ""));
        assert!(!matches("a", "aa"));
        assert!(!matches("a", "b"));
    }

    #[test]
    fn union_matches_either() {
        assert!(matches("a|b", "a"));
        assert!(matches("a|b", "b"));
        assert!(!matches("a|b", "c"));
        assert!(!matches("a|b", "ab"));
    }

    #[test]
    fn concat_matches_sequence() {
        assert!(matches("ab", "ab"));
        assert!(!matches("ab", "a"));
        assert!(!matches("ab", "ba"));
    }

    #[test]
    fn star_repeats_zero_or_more() {
        assert!(matches("a*", ""));
        assert!(matches("a*", "a"));
        assert!(matches("a*", "aaaa"));
        assert!(!matches("a*", "b"));
    }

    #[test]
    fn chapter_example_second_to_last_a() {
        // (a|b)*a(a|b): words whose second-to-last letter is a (need >= 2 symbols).
        let re = parse("(a|b)*a(a|b)").unwrap();
        for (w, expect) in [
            ("", false),
            ("a", false),
            ("b", false),
            ("aa", true),
            ("ab", true),
            ("ba", false),
            ("bb", false),
            ("aab", true),
            ("bab", true),
            ("baba", false),
            ("abb", false),
        ] {
            assert_eq!(re.to_nfa().accepts(w), expect, "word {w:?}");
        }
    }

    #[test]
    fn to_dfa_after_thompson() {
        let dfa = parse("a|bc").unwrap().to_nfa().to_dfa();
        assert!(dfa.accepts("a"));
        assert!(dfa.accepts("bc"));
        assert!(!dfa.accepts("b"));
        assert!(!dfa.accepts("abc"));
    }

    #[test]
    fn parse_errors() {
        assert!(parse("").is_err());
        assert!(parse("a|").is_err());
        assert!(parse("(a").is_err());
        assert!(parse("*a").is_err());
        assert!(parse("a|*").is_err());
        assert!(parse(")a").is_err());
    }

    #[test]
    fn empty_language_accepts_nothing() {
        let re = RegEx::empty();
        let nfa = re.to_nfa();
        assert!(!nfa.accepts(""));
        assert!(!nfa.accepts("a"));
    }

    #[test]
    fn epsilon_accepts_only_empty_word() {
        let re = RegEx::epsilon();
        let nfa = re.to_nfa();
        assert!(nfa.accepts(""));
        assert!(!nfa.accepts("a"));
        assert!(!nfa.accepts("aa"));
    }

    #[test]
    fn concat_empty_with_anything_is_empty() {
        let re = RegEx::concat(RegEx::empty(), RegEx::sym('a'));
        let nfa = re.to_nfa();
        assert!(!nfa.accepts("a"));
        assert!(!nfa.accepts(""));
    }

    #[test]
    fn union_empty_with_re_is_re() {
        let re = RegEx::union(RegEx::empty(), RegEx::sym('a'));
        let nfa = re.to_nfa();
        assert!(nfa.accepts("a"));
        assert!(!nfa.accepts(""));
        assert!(!nfa.accepts("b"));
    }

    #[test]
    fn nesting_and_precedence() {
        // a|bc*  =  a | (b(c*))  -- not (a|b)c*
        let dfa = parse("a|bc*").unwrap().to_nfa().to_dfa();
        assert!(dfa.accepts("a"));
        assert!(dfa.accepts("b"));
        assert!(dfa.accepts("bc"));
        assert!(dfa.accepts("bcc"));
        assert!(!dfa.accepts("ac"));
        assert!(!dfa.accepts(""));
    }

    #[test]
    fn complex_regex_with_star_union_concat() {
        // a(b|c)*d  --  words starting with a, ending with d, middle any mix of b,c.
        let dfa = parse("a(b|c)*d").unwrap().to_nfa().to_dfa();
        assert!(dfa.accepts("ad"));
        assert!(dfa.accepts("abd"));
        assert!(dfa.accepts("acd"));
        assert!(dfa.accepts("abcbcd"));
        assert!(!dfa.accepts(""));
        assert!(!dfa.accepts("a"));
        assert!(!dfa.accepts("d"));
        assert!(!dfa.accepts("abc")); // no trailing d
        assert!(dfa.accepts("abcd")); // a + (b,c)* + d
    }

    /// All words over `alphabet` of exactly length `len`.
    fn all_words(alphabet: &[char], len: usize) -> Vec<String> {
        if len == 0 {
            return vec![String::new()];
        }
        let mut words = Vec::new();
        for &c in alphabet {
            for w in all_words(alphabet, len - 1) {
                words.push(format!("{c}{w}"));
            }
        }
        words
    }

    /// The Thompson NFA and its determinized DFA must agree on every word.
    #[test]
    fn nfa_and_dfa_agree_on_all_short_words() {
        for re_str in [
            "a",
            "ab",
            "a|b",
            "a*",
            "(a|b)*",
            "(a|b)*a(a|b)",
            "ab|ba",
            "(ab)*",
            "a(b|c)*",
            "a*b*c*",
            "(a|b|c)*",
        ] {
            let nfa = parse(re_str).unwrap().to_nfa();
            let dfa = nfa.to_dfa();
            for len in 0..=5 {
                for word in all_words(&['a', 'b', 'c'], len) {
                    assert_eq!(
                        dfa.accepts(&word),
                        nfa.accepts(&word),
                        "regex {re_str:?} word {word:?}"
                    );
                }
            }
        }
    }

    #[test]
    fn to_nfa_then_to_dfa_then_minimize_preserves_language() {
        // End-to-end check: parse -> NFA -> DFA -> minimize must preserve language.
        let re = parse("(a|b)*a(a|b)").unwrap();
        let nfa = re.to_nfa();
        let dfa = nfa.to_dfa();
        let min = dfa.minimize();
        for len in 0..=5 {
            for word in all_words(&['a', 'b'], len) {
                assert_eq!(min.accepts(&word), nfa.accepts(&word), "word {word:?}");
            }
        }
    }
}
