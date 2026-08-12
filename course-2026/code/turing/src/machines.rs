//! Example Turing machines from the chapter and beyond.
//!
//! Each function builds a [`Machine`] that recognises a
//! specific language or computes a simple function. The machines use
//! `&'static str` for states (readable in traces) and `char` for tape
//! symbols (with `' '` as the blank).

use std::collections::HashMap;

use crate::machine::{Machine, Transition};
use crate::tape::Direction;

/// Shorthand for building a transition.
fn tr<Sym: Clone, State>(
    write: Sym,
    direction: Direction,
    next_state: State,
) -> Transition<Sym, State> {
    Transition {
        write,
        direction,
        next_state,
    }
}

/// A machine that accepts words over `{0, 1}` ending in `0`.
///
/// State `q0` means "the last symbol seen was 1" (or we are at the start);
/// `q1` means "the last symbol seen was 0".
///
/// ```
/// use turing::{machines, Tape, Outcome};
///
/// let m = machines::ends_with_zero();
/// let tape = Tape::with_word(&['0', '1', '0'], ' ');
/// assert_eq!(m.run(tape, 20).outcome, Outcome::Accepted);
///
/// let tape = Tape::with_word(&['0', '1'], ' ');
/// assert_eq!(m.run(tape, 20).outcome, Outcome::Rejected);
/// ```
pub fn ends_with_zero() -> Machine<char, &'static str> {
    let mut t = HashMap::new();
    t.insert(("q0", '0'), tr('0', Direction::Right, "q1"));
    t.insert(("q0", '1'), tr('1', Direction::Right, "q0"));
    t.insert(("q0", ' '), tr(' ', Direction::Right, "reject"));
    t.insert(("q1", '0'), tr('0', Direction::Right, "q1"));
    t.insert(("q1", '1'), tr('1', Direction::Right, "q0"));
    t.insert(("q1", ' '), tr(' ', Direction::Right, "accept"));
    Machine::new(t, "q0", "accept", "reject")
}

/// A machine that recognises the language `0^n 1^n` (n >= 0).
///
/// The algorithm repeatedly crosses out the leftmost `0` and the rightmost
/// `1` with `X`. When all symbols are crossed out the machine accepts;
/// a mismatch leads to rejection.
///
/// ```
/// use turing::{machines, Tape, Outcome};
///
/// let m = machines::zero_n_one_n();
///
/// // Accepted words.
/// for w in ["", "01", "0011", "000111"] {
///     let tape = Tape::with_word(&w.chars().collect::<Vec<_>>(), ' ');
///     assert_eq!(m.run(tape, 100).outcome, Outcome::Accepted, "word {w}");
/// }
///
/// // Rejected words.
/// for w in ["0", "10", "011", "00110"] {
///     let tape = Tape::with_word(&w.chars().collect::<Vec<_>>(), ' ');
///     assert_eq!(m.run(tape, 100).outcome, Outcome::Rejected, "word {w}");
/// }
/// ```
pub fn zero_n_one_n() -> Machine<char, &'static str> {
    let mut t = HashMap::new();
    // q0: find the first 0 not yet crossed out.
    t.insert(("q0", '0'), tr('X', Direction::Right, "q1"));
    t.insert(("q0", 'X'), tr('X', Direction::Right, "accept"));
    t.insert(("q0", '1'), tr('1', Direction::Right, "reject"));
    t.insert(("q0", ' '), tr(' ', Direction::Right, "accept")); // empty word
                                                                // q1: move right to the end of the string.
    t.insert(("q1", '0'), tr('0', Direction::Right, "q1"));
    t.insert(("q1", '1'), tr('1', Direction::Right, "q1"));
    t.insert(("q1", 'X'), tr('X', Direction::Right, "q1"));
    t.insert(("q1", ' '), tr(' ', Direction::Left, "q2"));
    // q2: find the first 1 not yet crossed out on the right.
    t.insert(("q2", '1'), tr('X', Direction::Left, "q3"));
    t.insert(("q2", 'X'), tr('X', Direction::Left, "q2"));
    t.insert(("q2", '0'), tr('0', Direction::Left, "reject"));
    t.insert(("q2", ' '), tr(' ', Direction::Left, "reject"));
    // q3: return left to the start.
    t.insert(("q3", '1'), tr('1', Direction::Left, "q3"));
    t.insert(("q3", '0'), tr('0', Direction::Left, "q3"));
    t.insert(("q3", 'X'), tr('X', Direction::Right, "q0"));
    Machine::new(t, "q0", "accept", "reject")
}

/// A machine that increments a binary number.
///
/// The input is a word over `{0, 1}` with the least significant bit on the
/// left (as in the book's exercise). The machine adds 1: it flips leading
/// `1`s to `0` (carry propagation) and flips the first `0` to `1`. An all-`1`
/// input grows one digit on the right (e.g. `111` becomes `0001`).
///
/// ```
/// use turing::{machines, Tape, Outcome};
///
/// let m = machines::binary_increment();
///
/// // 0 + 1 = 1
/// let t = Tape::with_word(&['0'], ' ');
/// let run = m.run(t, 20);
/// assert_eq!(run.outcome, Outcome::Accepted);
/// assert_eq!(run.configs.last().unwrap().tape.content_trimmed(), vec!['1']);
///
/// // 1011 (13) + 1 = 0111 (14) -- LSB on the left
/// let t = Tape::with_word(&['1', '0', '1', '1'], ' ');
/// let run = m.run(t, 20);
/// assert_eq!(run.outcome, Outcome::Accepted);
/// assert_eq!(run.configs.last().unwrap().tape.content_trimmed(), vec!['0', '1', '1', '1']);
///
/// // 111 (7) + 1 = 0001 (8) -- overflow
/// let t = Tape::with_word(&['1', '1', '1'], ' ');
/// let run = m.run(t, 20);
/// assert_eq!(run.outcome, Outcome::Accepted);
/// assert_eq!(run.configs.last().unwrap().tape.content_trimmed(), vec!['0', '0', '0', '1']);
/// ```
pub fn binary_increment() -> Machine<char, &'static str> {
    let mut t = HashMap::new();
    // q0: start, the head is on the least significant bit.
    t.insert(("q0", '0'), tr('1', Direction::Right, "accept")); // 0+1=1, done
    t.insert(("q0", '1'), tr('0', Direction::Right, "q1")); // 1+1=0, carry
    t.insert(("q0", ' '), tr('1', Direction::Right, "accept")); // empty word -> 1
                                                                // q1: carry propagation to the right.
    t.insert(("q1", '0'), tr('1', Direction::Right, "accept")); // 0+1=1, done
    t.insert(("q1", '1'), tr('0', Direction::Right, "q1")); // 1+1=0, carry
    t.insert(("q1", ' '), tr('1', Direction::Right, "accept")); // overflow: 111... -> 0001...
    Machine::new(t, "q0", "accept", "reject")
}

/// A machine that checks whether a word over `{0, 1}` is a palindrome.
///
/// The algorithm crosses out matching symbols from both ends: it remembers
/// the leftmost uncrossed symbol (crossing it out with `X`), moves to the
/// right end, checks that the rightmost uncrossed symbol matches, crosses
/// it out, and returns to the left. The process repeats until all symbols
/// are matched (accept) or a mismatch is found (reject).
///
/// ```
/// use turing::{machines, Tape, Outcome};
///
/// let m = machines::palindrome();
///
/// for w in ["", "0", "1", "00", "11", "010", "101", "0110", "1001"] {
///     let tape = Tape::with_word(&w.chars().collect::<Vec<_>>(), ' ');
///     assert_eq!(m.run(tape, 200).outcome, Outcome::Accepted, "word {w}");
/// }
///
/// for w in ["01", "10", "001", "110", "0100"] {
///     let tape = Tape::with_word(&w.chars().collect::<Vec<_>>(), ' ');
///     assert_eq!(m.run(tape, 200).outcome, Outcome::Rejected, "word {w}");
/// }
/// ```
pub fn palindrome() -> Machine<char, &'static str> {
    let mut t = HashMap::new();
    // q0: find the first uncrossed symbol. If blank -- accept (all matched).
    t.insert(("q0", '0'), tr('X', Direction::Right, "q_0"));
    t.insert(("q0", '1'), tr('X', Direction::Right, "q_1"));
    t.insert(("q0", 'X'), tr('X', Direction::Right, "q0"));
    t.insert(("q0", ' '), tr(' ', Direction::Right, "accept"));
    // q_0: remembered 0 -- move right to the end.
    t.insert(("q_0", '0'), tr('0', Direction::Right, "q_0"));
    t.insert(("q_0", '1'), tr('1', Direction::Right, "q_0"));
    t.insert(("q_0", 'X'), tr('X', Direction::Right, "q_0"));
    t.insert(("q_0", ' '), tr(' ', Direction::Left, "ck0"));
    // q_1: remembered 1 -- move right to the end.
    t.insert(("q_1", '0'), tr('0', Direction::Right, "q_1"));
    t.insert(("q_1", '1'), tr('1', Direction::Right, "q_1"));
    t.insert(("q_1", 'X'), tr('X', Direction::Right, "q_1"));
    t.insert(("q_1", ' '), tr(' ', Direction::Left, "ck1"));
    // ck0: check that the rightmost uncrossed symbol is 0.
    t.insert(("ck0", 'X'), tr('X', Direction::Left, "ck0"));
    t.insert(("ck0", '0'), tr('X', Direction::Left, "back"));
    t.insert(("ck0", '1'), tr('1', Direction::Left, "reject"));
    t.insert(("ck0", ' '), tr(' ', Direction::Right, "q0"));
    // ck1: check that the rightmost uncrossed symbol is 1.
    t.insert(("ck1", 'X'), tr('X', Direction::Left, "ck1"));
    t.insert(("ck1", '1'), tr('X', Direction::Left, "back"));
    t.insert(("ck1", '0'), tr('0', Direction::Left, "reject"));
    t.insert(("ck1", ' '), tr(' ', Direction::Right, "q0"));
    // back: return to the leftmost position.
    t.insert(("back", '0'), tr('0', Direction::Left, "back"));
    t.insert(("back", '1'), tr('1', Direction::Left, "back"));
    t.insert(("back", 'X'), tr('X', Direction::Left, "back"));
    t.insert(("back", ' '), tr(' ', Direction::Right, "q0"));
    Machine::new(t, "q0", "accept", "reject")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::machine::Outcome;
    use crate::tape::{Direction, Tape};

    // -- ends_with_zero ===================================================

    #[test]
    fn ends_with_zero_accepts_correct_words() {
        let machine = ends_with_zero();
        for (word, expect) in [
            ("0", true),
            ("10", true),
            ("010", true),
            ("00", true),
            ("110", true),
            ("", false),
            ("1", false),
            ("11", false),
            ("01", false),
            ("101", false),
        ] {
            let tape = Tape::with_word(&word.chars().collect::<Vec<_>>(), ' ');
            let outcome = machine.run(tape, 50).outcome;
            assert_eq!(
                outcome == Outcome::Accepted,
                expect,
                "word {word:?}: expected accept={expect}, got {outcome}"
            );
        }
    }

    // -- zero_n_one_n =====================================================

    #[test]
    fn zero_n_one_n_accepts_correct_words() {
        let machine = zero_n_one_n();
        for (word, expect) in [
            ("", true),
            ("01", true),
            ("0011", true),
            ("000111", true),
            ("00001111", true),
            ("0", false),
            ("1", false),
            ("10", false),
            ("001", false),
            ("011", false),
            ("00111", false),
            ("0101", false),
        ] {
            let tape = Tape::with_word(&word.chars().collect::<Vec<_>>(), ' ');
            let outcome = machine.run(tape, 100).outcome;
            assert_eq!(
                outcome == Outcome::Accepted,
                expect,
                "word {word:?}: expected accept={expect}, got {outcome}"
            );
        }
    }

    #[test]
    fn zero_n_one_n_trace_has_correct_configurations() {
        let machine = zero_n_one_n();
        let tape = Tape::with_word(&['0', '1'], ' ');
        let run = machine.run(tape, 100);
        assert_eq!(run.outcome, Outcome::Accepted);
        // The trace should include the starting configuration and all steps.
        assert!(
            run.configs.len() > 2,
            "expected several steps, got {}",
            run.configs.len()
        );
        // First config: state q0, tape [0, 1].
        assert_eq!(run.configs[0].state, "q0");
        assert_eq!(run.configs[0].tape.content_trimmed(), vec!['0', '1']);
        // Last config: state accept.
        assert_eq!(run.configs.last().unwrap().state, "accept");
    }

    // -- binary_increment =================================================

    #[test]
    fn binary_increment_accepts_various_inputs() {
        let m = binary_increment();
        // LSB on the left, as in the book's exercise.
        let cases = [
            ("0", "1"),
            ("1", "01"),
            ("10", "01"),
            ("11", "001"),
            ("100", "010"),
            ("111", "0001"),
            ("1011", "0111"),
            ("1111", "00001"),
        ];
        for (input, expected) in cases {
            let tape = Tape::with_word(&input.chars().collect::<Vec<_>>(), ' ');
            let run = m.run(tape, 50);
            assert_eq!(run.outcome, Outcome::Accepted, "input {input}");
            let result: String = run
                .configs
                .last()
                .unwrap()
                .tape
                .content_trimmed()
                .iter()
                .collect();
            assert_eq!(
                result, expected,
                "input {input}: expected {expected}, got {result}"
            );
        }
    }

    // -- palindrome =======================================================

    #[test]
    fn palindrome_accepts_palindromes() {
        let m = palindrome();
        for w in [
            "", "0", "1", "00", "11", "010", "101", "0110", "1001", "00100", "11011",
        ] {
            let tape = Tape::with_word(&w.chars().collect::<Vec<_>>(), ' ');
            let outcome = m.run(tape, 200).outcome;
            assert_eq!(outcome, Outcome::Accepted, "word {w} should be accepted");
        }
    }

    #[test]
    fn palindrome_rejects_non_palindromes() {
        let m = palindrome();
        for w in [
            "01", "10", "001", "100", "110", "0100", "1011", "0011", "1100",
        ] {
            let tape = Tape::with_word(&w.chars().collect::<Vec<_>>(), ' ');
            let outcome = m.run(tape, 200).outcome;
            assert_eq!(outcome, Outcome::Rejected, "word {w} should be rejected");
        }
    }

    #[test]
    fn palindrome_single_symbol_is_trivial() {
        let m = palindrome();
        for w in ["0", "1"] {
            let tape = Tape::with_word(&w.chars().collect::<Vec<_>>(), ' ');
            let run = m.run(tape, 20);
            assert_eq!(run.outcome, Outcome::Accepted);
            // Should be quick: mark left, go right, mark right, back, accept.
            assert!(run.configs.len() <= 10, "too many steps for single symbol");
        }
    }

    // -- non-halting ======================================================

    #[test]
    fn non_halting_machine_hits_the_step_limit() {
        // A machine that moves right forever never halts.
        let mut transitions = HashMap::new();
        let move_right = |sym: char| Transition {
            write: sym,
            direction: Direction::Right,
            next_state: "q0",
        };
        transitions.insert(("q0", 'a'), move_right('a'));
        transitions.insert(("q0", ' '), move_right(' '));
        let machine = Machine::new(transitions, "q0", "accept", "reject");
        let tape = Tape::with_word(&['a', 'a', 'a'], ' ');
        let run = machine.run(tape, 5);
        assert_eq!(run.outcome, Outcome::Limit);
        assert_eq!(run.configs.len(), 6); // start + 5 steps
    }
}
