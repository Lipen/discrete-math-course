//! Multi-tape Turing machines: `k` tapes, each with its own head.
//!
//! One step reads the symbols under all `k` heads at once, writes one symbol per tape, moves each head independently, and switches state.
//! The transition table is indexed by the current state together with the tuple of symbols read from the tapes.
//!
//! Multi-tape machines do not recognise more languages than single-tape ones, but they can be much faster: work that needs a back-and-forth scan on one tape becomes a single sweep when the intermediate result has its own tape.
//!
//! ```
//! use std::collections::HashMap;
//! use turing::{Direction, MultiTapeMachine, MultiTransition, MultiConfiguration, Outcome, Tape};
//!
//! // Two tapes: copy the symbol under the first head onto the second tape.
//! let mut t = HashMap::new();
//! t.insert(
//!     ("q0", vec!['a', ' ']),
//!     MultiTransition {
//!         writes: vec!['a', 'a'],
//!         directions: vec![Direction::Right, Direction::Right],
//!         next_state: "q0",
//!     },
//! );
//! t.insert(
//!     ("q0", vec![' ', ' ']),
//!     MultiTransition {
//!         writes: vec![' ', ' '],
//!         directions: vec![Direction::Stay, Direction::Stay],
//!         next_state: "accept",
//!     },
//! );
//!
//! let m = MultiTapeMachine::new(t, 2, "q0", "accept", "reject");
//! let tapes = vec![Tape::with_word(&['a', 'a'], ' '), Tape::new(' ')];
//! let run = m.run(tapes, 20);
//! assert_eq!(run.outcome, Outcome::Accepted);
//! assert_eq!(run.configs.last().unwrap().tapes[1].content_trimmed(), vec!['a', 'a']);
//! ```

use std::collections::HashMap;
use std::hash::Hash;

use crate::machine::Outcome;
use crate::tape::{Direction, Tape};

/// One step of a multi-tape machine.
///
/// `writes[i]` is written on tape `i`, then `directions[i]` moves the head of tape `i`, and the machine enters `next_state`.
/// Both vectors hold one entry per tape.
///
/// ```
/// use turing::{Direction, MultiTransition};
///
/// let tr = MultiTransition {
///     writes: vec!['0', '1'],
///     directions: vec![Direction::Left, Direction::Right],
///     next_state: "q1",
/// };
/// assert_eq!(tr.writes.len(), 2);
/// assert_eq!(tr.next_state, "q1");
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MultiTransition<Sym, State> {
    /// The symbols written on the tapes, one per tape.
    pub writes: Vec<Sym>,
    /// Where each head moves after writing, one per tape.
    pub directions: Vec<Direction>,
    /// The state the machine switches to.
    pub next_state: State,
}

/// A snapshot of a multi-tape machine: the state and every tape.
///
/// ```
/// use turing::{MultiConfiguration, Tape};
///
/// let cfg = MultiConfiguration {
///     state: "q0",
///     tapes: vec![Tape::with_word(&['0'], ' '), Tape::new(' ')],
/// };
/// assert_eq!(cfg.tapes.len(), 2);
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MultiConfiguration<Sym, State> {
    /// The state the machine is in.
    pub state: State,
    /// One tape per tape index, each with its own head.
    pub tapes: Vec<Tape<Sym>>,
}

/// The full trace of a multi-tape computation.
///
/// ```
/// use turing::{machines, Outcome, Tape};
///
/// let m = machines::copy_reversed();
/// let tapes = vec![Tape::with_word(&['0', '1'], ' '), Tape::new(' ')];
/// let run = m.run(tapes, 100);
/// assert_eq!(run.outcome, Outcome::Accepted);
/// assert!(run.configs.len() > 3);
/// ```
#[derive(Debug, Clone)]
pub struct MultiRun<Sym, State> {
    /// How the run ended.
    pub outcome: Outcome,
    /// Every configuration from the start to the halt, in order.
    pub configs: Vec<MultiConfiguration<Sym, State>>,
}

/// A deterministic Turing machine with `k` independent tapes.
///
/// Each tape has its own head.
/// A transition reads all heads, so the table is keyed by `(state, symbols under the heads)`.
/// The machine halts on the accepting state, on the rejecting state, when no transition matches the current tuple of symbols, or when the step limit is reached.
///
/// ```
/// use std::collections::HashMap;
/// use turing::{Direction, MultiTapeMachine, MultiTransition, Outcome, Tape};
///
/// let mut t = HashMap::new();
/// t.insert(
///     ("q0", vec!['x', ' ']),
///     MultiTransition {
///         writes: vec!['x', 'x'],
///         directions: vec![Direction::Right, Direction::Right],
///         next_state: "q0",
///     },
/// );
/// t.insert(
///     ("q0", vec![' ', ' ']),
///     MultiTransition {
///         writes: vec![' ', ' '],
///         directions: vec![Direction::Stay, Direction::Stay],
///         next_state: "accept",
///     },
/// );
///
/// let m = MultiTapeMachine::new(t, 2, "q0", "accept", "reject");
/// let tapes = vec![Tape::with_word(&['x'], ' '), Tape::new(' ')];
/// assert_eq!(m.run(tapes, 10).outcome, Outcome::Accepted);
/// ```
#[derive(Debug, Clone)]
pub struct MultiTapeMachine<Sym, State> {
    transitions: HashMap<(State, Vec<Sym>), MultiTransition<Sym, State>>,
    tapes: usize,
    start: State,
    accept: State,
    reject: State,
}

impl<Sym, State> MultiTapeMachine<Sym, State>
where
    Sym: Clone + Eq + Hash,
    State: Clone + Eq + Hash,
{
    /// Creates a machine with `tapes` tapes from its parts.
    ///
    /// `transitions` maps a state and the tuple of read symbols to a step.
    /// `start`, `accept`, `reject` are the designated states.
    ///
    /// # Panics
    ///
    /// Panics if `tapes` is zero, or if any transition does not have exactly one write and one direction per tape.
    /// Both are programmer errors that would otherwise make [`MultiTapeMachine::next`] silently skip steps.
    ///
    /// ```
    /// use std::collections::HashMap;
    /// use turing::MultiTapeMachine;
    ///
    /// let m: MultiTapeMachine<char, &str> =
    ///     MultiTapeMachine::new(HashMap::new(), 1, "q0", "ok", "no");
    /// assert_eq!(m.tapes(), 1);
    /// ```
    pub fn new(
        transitions: HashMap<(State, Vec<Sym>), MultiTransition<Sym, State>>,
        tapes: usize,
        start: State,
        accept: State,
        reject: State,
    ) -> Self {
        assert!(tapes > 0, "a machine needs at least one tape");
        for tr in transitions.values() {
            assert_eq!(
                tr.writes.len(),
                tapes,
                "a transition must write one symbol per tape"
            );
            assert_eq!(
                tr.directions.len(),
                tapes,
                "a transition must move one head per tape"
            );
        }
        Self {
            transitions,
            tapes,
            start,
            accept,
            reject,
        }
    }

    /// Returns the number of tapes.
    ///
    /// ```
    /// use turing::machines;
    ///
    /// assert_eq!(machines::copy_reversed().tapes(), 2);
    /// ```
    pub fn tapes(&self) -> usize {
        self.tapes
    }

    /// Computes the next configuration, or `None` if no transition matches the tuple of symbols under the heads.
    ///
    /// Heads move independently: one may move left while another moves right, and a `Direction::Stay` leaves a head in place.
    ///
    /// ```
    /// use turing::{machines, MultiConfiguration, Tape};
    ///
    /// let m = machines::copy_reversed();
    /// let cfg = MultiConfiguration {
    ///     state: "scan",
    ///     tapes: vec![Tape::with_word(&['0', '1'], ' '), Tape::new(' ')],
    /// };
    /// let next = m.next(&cfg).unwrap();
    /// assert_eq!(next.state, "scan");
    /// assert_eq!(next.tapes[0].head_index(), 1); // first tape advanced
    /// assert_eq!(next.tapes[1].head_index(), 0); // second tape stayed
    /// ```
    pub fn next(
        &self,
        config: &MultiConfiguration<Sym, State>,
    ) -> Option<MultiConfiguration<Sym, State>> {
        let read: Vec<Sym> = config.tapes.iter().map(|t| t.read().clone()).collect();
        self.transitions
            .get(&(config.state.clone(), read))
            .map(|tr| {
                let mut tapes = config.tapes.clone();
                for (tape, (write, direction)) in
                    tapes.iter_mut().zip(tr.writes.iter().zip(&tr.directions))
                {
                    tape.write(write.clone());
                    tape.move_head(*direction);
                }
                MultiConfiguration {
                    state: tr.next_state.clone(),
                    tapes,
                }
            })
    }

    /// Runs the machine on `tapes` and returns the trace with the outcome.
    ///
    /// Takes at most `max_steps` transitions.
    /// A machine that has not halted by then ends with `Outcome::Limit` instead of running forever.
    ///
    /// # Panics
    ///
    /// Panics if `tapes.len()` differs from the number of tapes the machine was built with.
    ///
    /// ```
    /// use turing::{machines, Outcome, Tape};
    ///
    /// let m = machines::copy_reversed();
    /// let tapes = vec![Tape::with_word(&['0', '1', '0'], ' '), Tape::new(' ')];
    /// let run = m.run(tapes, 100);
    /// assert_eq!(run.outcome, Outcome::Accepted);
    /// assert_eq!(run.configs.last().unwrap().state, "accept");
    /// ```
    pub fn run(&self, tapes: Vec<Tape<Sym>>, max_steps: usize) -> MultiRun<Sym, State> {
        assert_eq!(
            tapes.len(),
            self.tapes,
            "expected {} tapes, got {}",
            self.tapes,
            tapes.len()
        );
        let mut config = MultiConfiguration {
            state: self.start.clone(),
            tapes,
        };
        let mut configs = Vec::new();
        let outcome = loop {
            configs.push(config.clone());
            if config.state == self.accept {
                break Outcome::Accepted;
            }
            if config.state == self.reject {
                break Outcome::Rejected;
            }
            if configs.len() - 1 == max_steps {
                break Outcome::Limit;
            }
            match self.next(&config) {
                Some(next) => config = next,
                None => break Outcome::Stuck,
            }
        };
        MultiRun { outcome, configs }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::machines;
    use crate::tape::Tape;

    fn tapes_from(word: &str) -> Vec<Tape<char>> {
        let chars: Vec<char> = word.chars().collect();
        vec![Tape::with_word(&chars, ' '), Tape::new(' ')]
    }

    fn tape_string(tape: &Tape<char>) -> String {
        tape.content_trimmed().iter().collect()
    }

    #[test]
    fn copy_reversed_accepts_words_and_writes_the_reverse() {
        let m = machines::copy_reversed();
        for (input, reversed) in [
            ("", ""),
            ("0", "0"),
            ("01", "10"),
            ("011", "110"),
            ("1010", "0101"),
        ] {
            let run = m.run(tapes_from(input), 100);
            assert_eq!(run.outcome, Outcome::Accepted, "input {input:?}");
            let out = tape_string(&run.configs.last().unwrap().tapes[1]);
            assert_eq!(out, reversed, "input {input:?}");
        }
    }

    #[test]
    fn copy_reversed_rejects_non_binary_symbols() {
        let m = machines::copy_reversed();
        let run = m.run(tapes_from("10X1"), 100);
        assert_eq!(run.outcome, Outcome::Rejected);
    }

    #[test]
    fn copy_reversed_trace_moves_the_heads_independently() {
        let m = machines::copy_reversed();
        let run = m.run(tapes_from("01"), 100);

        assert_eq!(run.outcome, Outcome::Accepted);
        assert!(run.configs.len() > 4, "expected a multi-step trace");

        // While the first head scans right, the second head stays put.
        assert_eq!(run.configs[0].state, "scan");
        assert_eq!(run.configs[1].tapes[0].head_index(), 1);
        assert_eq!(run.configs[1].tapes[1].head_index(), 0);

        // The accepting configuration has the reversed word on tape 1.
        assert_eq!(run.configs.last().unwrap().state, "accept");
        assert_eq!(tape_string(&run.configs.last().unwrap().tapes[1]), "10");
        assert_eq!(tape_string(&run.configs.last().unwrap().tapes[0]), "01");
    }

    #[test]
    fn step_limit_is_reported() {
        let m = machines::copy_reversed();
        let run = m.run(tapes_from("0101"), 2);
        assert_eq!(run.outcome, Outcome::Limit);
        assert_eq!(run.configs.len(), 3);
    }

    #[test]
    fn next_returns_none_when_no_transition_matches() {
        let m = machines::copy_reversed();
        let cfg = MultiConfiguration {
            state: "back",
            tapes: vec![Tape::with_word(&['7'], ' '), Tape::new(' ')],
        };
        assert!(m.next(&cfg).is_none());
    }
}
