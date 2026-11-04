//! A universal machine: machine descriptions as data.
//!
//! [`Encoding`] stores a machine as plain data: the state names, the tape symbols that appear in the table, the start, accepting, and rejecting states, and one entry per transition.
//! [`UniversalMachine`] decodes such an encoding back into a running [`Machine`].
//!
//! The point is the separation between a program and its interpreter.
//! A single simulator can run any machine whose description it is given, because the description carries the whole transition table.
//!
//! ```
//! use turing::{machines, Encoding, Tape, UniversalMachine};
//!
//! let encoding = Encoding::from_machine(&machines::ends_with_zero());
//! let universal = UniversalMachine::new();
//!
//! let tape = Tape::with_word(&['1', '0'], ' ');
//! let run = universal.run(&encoding, tape, 20);
//! assert_eq!(run.outcome, turing::Outcome::Accepted);
//! ```

use std::collections::HashMap;
use std::fmt;
use std::hash::Hash;

use crate::machine::{Machine, Run, Transition};
use crate::tape::{Direction, Tape};

/// One transition of an encoded machine.
///
/// ```
/// use turing::{Direction, EncodedTransition};
///
/// let tr = EncodedTransition {
///     state: "q0".to_string(),
///     read: '0',
///     write: '1',
///     direction: Direction::Right,
///     next_state: "q1".to_string(),
/// };
/// assert_eq!(tr.read, '0');
/// assert_eq!(tr.to_string(), "q0 '0' -> '1' R q1");
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct EncodedTransition {
    /// The state the transition applies in.
    pub state: String,
    /// The symbol read from the tape.
    pub read: char,
    /// The symbol written to the tape.
    pub write: char,
    /// Where the head moves after writing.
    pub direction: Direction,
    /// The state the machine switches to.
    pub next_state: String,
}

impl fmt::Display for EncodedTransition {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{} {:?} -> {:?} {} {}",
            self.state, self.read, self.write, self.direction, self.next_state
        )
    }
}

/// A machine stored as data.
///
/// The fields are the whole description: a simulator needs nothing else to rebuild the machine.
/// `states` and `symbols` are sorted, and every state that occurs in a transition or in one of the three designated roles appears in `states`.
/// State names are strings, so two states that display the same text are the same state after decoding.
///
/// The blank symbol is not stored.
/// A tape carries its own blank, so the same description runs on tapes with different blanks, provided the transition table mentions the symbol when it needs to.
///
/// ```
/// use turing::{machines, Encoding};
///
/// let encoding = Encoding::from_machine(&machines::ends_with_zero());
/// assert!(encoding.states.contains(&"accept".to_string()));
/// assert!(encoding.symbols.contains(&'0'));
/// assert_eq!(encoding.transitions.len(), 6);
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Encoding {
    /// Every state name, sorted.
    pub states: Vec<String>,
    /// Every tape symbol mentioned by the table, sorted.
    pub symbols: Vec<char>,
    /// The start state.
    pub start: String,
    /// The accepting state.
    pub accept: String,
    /// The rejecting state.
    pub reject: String,
    /// The transition table, one entry per row.
    pub transitions: Vec<EncodedTransition>,
}

impl Encoding {
    /// Encodes a machine with character symbols and any displayable state type.
    ///
    /// State names are converted with `ToString`.
    /// The transition table is read from the machine itself, so an encoding never drifts from the machine it describes.
    ///
    /// ```
    /// use turing::{machines, Encoding, UniversalMachine, Tape, Outcome};
    ///
    /// let encoding = Encoding::from_machine(&machines::binary_increment());
    /// let universal = UniversalMachine::new();
    ///
    /// let tape = Tape::with_word(&['1', '1'], ' ');
    /// let run = universal.run(&encoding, tape, 30);
    /// assert_eq!(run.outcome, Outcome::Accepted);
    /// assert_eq!(run.configs.last().unwrap().tape.content_trimmed(), vec!['0', '0', '1']);
    /// ```
    pub fn from_machine<State>(machine: &Machine<char, State>) -> Self
    where
        State: Clone + Eq + Hash + fmt::Display,
    {
        let mut states = vec![
            machine.start().to_string(),
            machine.accept().to_string(),
            machine.reject().to_string(),
        ];
        let mut symbols = Vec::new();
        let mut transitions = Vec::new();

        for ((state, read), tr) in machine.transitions() {
            let state = state.to_string();
            let next_state = tr.next_state.to_string();
            states.push(state.clone());
            states.push(next_state.clone());
            symbols.push(*read);
            symbols.push(tr.write);
            transitions.push(EncodedTransition {
                state,
                read: *read,
                write: tr.write,
                direction: tr.direction,
                next_state,
            });
        }

        states.sort();
        states.dedup();
        symbols.sort();
        symbols.dedup();
        transitions.sort_by(|a, b| {
            (&a.state, a.read, a.write, &a.next_state).cmp(&(
                &b.state,
                b.read,
                b.write,
                &b.next_state,
            ))
        });

        Self {
            states,
            symbols,
            start: machine.start().to_string(),
            accept: machine.accept().to_string(),
            reject: machine.reject().to_string(),
            transitions,
        }
    }
}

impl fmt::Display for Encoding {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(f, "states: {}", self.states.join(" "))?;
        writeln!(f, "symbols: {:?}", self.symbols)?;
        writeln!(f, "start: {}", self.start)?;
        writeln!(f, "accept: {}", self.accept)?;
        writeln!(f, "reject: {}", self.reject)?;
        for tr in &self.transitions {
            writeln!(f, "{tr}")?;
        }
        Ok(())
    }
}

/// The simulator that runs encoded machines.
///
/// It holds no state.
/// [`UniversalMachine::decode`] turns an [`Encoding`] into a [`Machine`], and [`UniversalMachine::run`] decodes and runs in one call.
/// The decoded machine uses `String` states with `char` symbols.
///
/// ```
/// use turing::{machines, Encoding, UniversalMachine, Tape, Outcome};
///
/// let encoding = Encoding::from_machine(&machines::ends_with_zero());
/// let universal = UniversalMachine::new();
/// let machine = universal.decode(&encoding);
///
/// let tape = Tape::with_word(&['0', '1'], ' ');
/// assert_eq!(machine.run(tape, 20).outcome, Outcome::Rejected);
/// ```
#[derive(Debug, Clone, Copy, Default)]
pub struct UniversalMachine;

impl UniversalMachine {
    /// Creates the simulator.
    ///
    /// ```
    /// use turing::UniversalMachine;
    ///
    /// let universal = UniversalMachine::new();
    /// let _ = universal;
    /// ```
    pub fn new() -> Self {
        Self
    }

    /// Decodes a description into a runnable machine.
    ///
    /// Duplicate (state, read) rows keep the last one, so a description is interpreted as a deterministic table.
    /// Rows that never match any input are harmless: they simply never fire.
    ///
    /// ```
    /// use turing::{machines, Encoding, UniversalMachine};
    ///
    /// let encoding = Encoding::from_machine(&machines::zero_n_one_n());
    /// let machine = UniversalMachine::new().decode(&encoding);
    /// assert_eq!(machine.transitions().len(), encoding.transitions.len());
    /// ```
    pub fn decode(&self, encoding: &Encoding) -> Machine<char, String> {
        let mut transitions = HashMap::new();
        for tr in &encoding.transitions {
            transitions.insert(
                (tr.state.clone(), tr.read),
                Transition {
                    write: tr.write,
                    direction: tr.direction,
                    next_state: tr.next_state.clone(),
                },
            );
        }
        Machine::new(
            transitions,
            encoding.start.clone(),
            encoding.accept.clone(),
            encoding.reject.clone(),
        )
    }

    /// Decodes `encoding` and runs the resulting machine on `tape`.
    ///
    /// `max_steps` bounds the number of transitions, exactly as in [`Machine::run`].
    ///
    /// ```
    /// use turing::{machines, Encoding, Outcome, Tape, UniversalMachine};
    ///
    /// let encoding = Encoding::from_machine(&machines::ends_with_zero());
    /// let tape = Tape::with_word(&['1', '0'], ' ');
    /// let run = UniversalMachine::new().run(&encoding, tape, 20);
    /// assert_eq!(run.outcome, Outcome::Accepted);
    /// ```
    /// The call is equivalent to `self.decode(encoding).run(tape, max_steps)`.
    pub fn run(
        &self,
        encoding: &Encoding,
        tape: Tape<char>,
        max_steps: usize,
    ) -> Run<char, String> {
        self.decode(encoding).run(tape, max_steps)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::machine::Outcome;
    use crate::machines;

    fn tape(word: &str) -> Tape<char> {
        let chars: Vec<char> = word.chars().collect();
        Tape::with_word(&chars, ' ')
    }

    #[test]
    fn decoded_machine_accepts_and_rejects_like_the_original() {
        let original = machines::zero_n_one_n();
        let universal = UniversalMachine::new();
        let encoding = Encoding::from_machine(&original);

        for (word, expect) in [
            ("", Outcome::Accepted),
            ("01", Outcome::Accepted),
            ("0011", Outcome::Accepted),
            ("0", Outcome::Rejected),
            ("001", Outcome::Rejected),
            ("10", Outcome::Rejected),
        ] {
            let direct = original.run(tape(word), 100).outcome;
            let decoded = universal.run(&encoding, tape(word), 100).outcome;
            assert_eq!(direct, expect, "direct run on {word:?}");
            assert_eq!(decoded, expect, "decoded run on {word:?}");
        }
    }

    #[test]
    fn decoding_is_transparent_for_every_machine() {
        for encoding in [
            Encoding::from_machine(&machines::ends_with_zero()),
            Encoding::from_machine(&machines::binary_increment()),
            Encoding::from_machine(&machines::palindrome()),
        ] {
            let machine = UniversalMachine::new().decode(&encoding);
            assert_eq!(machine.transitions().len(), encoding.transitions.len());
            assert_eq!(machine.start(), &encoding.start);
            assert_eq!(machine.accept(), &encoding.accept);
            assert_eq!(machine.reject(), &encoding.reject);
        }
    }

    #[test]
    fn hand_written_encoding_runs_multi_step() {
        let encoding = Encoding {
            states: vec![
                "accept".to_string(),
                "q0".to_string(),
                "q1".to_string(),
                "reject".to_string(),
            ],
            symbols: vec![' ', '0', '1'],
            start: "q0".to_string(),
            accept: "accept".to_string(),
            reject: "reject".to_string(),
            transitions: vec![
                EncodedTransition {
                    state: "q0".to_string(),
                    read: '0',
                    write: '1',
                    direction: Direction::Right,
                    next_state: "q1".to_string(),
                },
                EncodedTransition {
                    state: "q1".to_string(),
                    read: '0',
                    write: '0',
                    direction: Direction::Right,
                    next_state: "accept".to_string(),
                },
            ],
        };

        let universal = UniversalMachine::new();
        let run = universal.run(&encoding, tape("00"), 10);
        assert_eq!(run.outcome, Outcome::Accepted);
        assert_eq!(run.configs.len(), 3); // start + two transitions
        assert_eq!(run.configs[0].state, "q0");
        assert_eq!(run.configs[1].state, "q1");
        assert_eq!(
            run.configs.last().unwrap().tape.content_trimmed(),
            vec!['1', '0']
        );
    }

    #[test]
    fn description_lists_every_part() {
        let encoding = Encoding::from_machine(&machines::ends_with_zero());
        let text = encoding.to_string();
        assert!(text.contains("states: accept q0 q1 reject"), "{text}");
        assert!(text.contains("start: q0"), "{text}");
        assert!(text.contains("accept: accept"), "{text}");
        assert!(text.contains("q0 '0' -> '0' R q1"), "{text}");
        assert_eq!(text.lines().count(), 5 + encoding.transitions.len());
    }

    #[test]
    fn encoding_includes_states_that_only_appear_in_transitions() {
        let encoding = Encoding::from_machine(&machines::palindrome());
        for state in ["q_0", "q_1", "ck0", "ck1", "back"] {
            assert!(
                encoding.states.contains(&state.to_string()),
                "missing state {state}"
            );
        }
    }
}
