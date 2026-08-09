//! Regular expressions and the Thompson construction.
//!
//! A regular expression is parsed from a string and turned into an epsilon-NFA
//! by the Thompson construction, then --- optionally --- into a DFA (see
//! `Nfa::to_dfa`). Book example: `(a|b)*a(a|b)` is the language of words whose
//! second-to-last letter is `a`.

use crate::nfa::Nfa;

/// A regular expression over an alphabet of `char`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum RegEx {
    /// The empty language `∅`.
    Empty,
    /// The empty word `ε`.
    Epsilon,
    /// A single symbol.
    Sym(char),
    /// Concatenation `AB`.
    Concat(Box<RegEx>, Box<RegEx>),
    /// Union `A|B`.
    Union(Box<RegEx>, Box<RegEx>),
    /// Kleene star `A*`.
    Star(Box<RegEx>),
}

impl RegEx {
    pub fn sym(c: char) -> RegEx {
        RegEx::Sym(c)
    }

    pub fn concat(a: RegEx, b: RegEx) -> RegEx {
        RegEx::Concat(Box::new(a), Box::new(b))
    }

    pub fn union(a: RegEx, b: RegEx) -> RegEx {
        RegEx::Union(Box::new(a), Box::new(b))
    }

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
                nfa.add_transition(s, *c, e);
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

    fn parse(mut self) -> RegEx {
        let result = self.union();
        assert_eq!(
            self.pos,
            self.chars.len(),
            "extra symbols at the end of the expression"
        );
        result
    }

    fn union(&mut self) -> RegEx {
        let mut left = self.concat();
        while self.peek() == Some('|') {
            self.pos += 1;
            let right = self.concat();
            left = RegEx::Union(Box::new(left), Box::new(right));
        }
        left
    }

    fn concat(&mut self) -> RegEx {
        let mut left = self.star();
        while matches!(self.peek(), Some(c) if c != '|' && c != ')') {
            let right = self.star();
            left = RegEx::Concat(Box::new(left), Box::new(right));
        }
        left
    }

    fn star(&mut self) -> RegEx {
        let mut atom = self.atom();
        while self.peek() == Some('*') {
            self.pos += 1;
            atom = RegEx::Star(Box::new(atom));
        }
        atom
    }

    fn atom(&mut self) -> RegEx {
        match self.peek() {
            None => panic!("unexpected end of expression"),
            Some('(') => {
                self.pos += 1;
                let inner = self.union();
                assert_eq!(self.peek(), Some(')'), "expected a closing parenthesis");
                self.pos += 1;
                inner
            }
            Some(')') | Some('|') | Some('*') => {
                panic!("unexpected symbol '{}'", self.peek().unwrap())
            }
            Some(c) => {
                self.pos += 1;
                RegEx::Sym(c)
            }
        }
    }

    fn peek(&self) -> Option<char> {
        self.chars.get(self.pos).copied()
    }
}

/// Parses a string into a regular expression.
pub fn parse(s: &str) -> RegEx {
    Parser::new(s).parse()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn matches(re: &str, word: &str) -> bool {
        parse(re).to_nfa().accepts(word)
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
        let re = parse("(a|b)*a(a|b)");
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
        let dfa = parse("a|bc").to_nfa().to_dfa();
        assert!(dfa.accepts("a"));
        assert!(dfa.accepts("bc"));
        assert!(!dfa.accepts("b"));
        assert!(!dfa.accepts("abc"));
    }
}
