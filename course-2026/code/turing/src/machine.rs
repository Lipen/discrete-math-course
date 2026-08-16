//! The Turing machine: states, transitions, and execution.
//!
//! A machine is a transition table (a partial function from
//! (state, symbol) to (symbol, direction, next-state)) together with
//! designated start, accept, and reject states.
//!
//! A **run** executes the machine step by step, recording every
//! configuration until the machine accepts, rejects, gets stuck
//! (no applicable transition), or hits a step limit.

use std::collections::HashMap;
use std::fmt;
use std::hash::Hash;

use crate::tape::{Direction, Tape};

/// A single transition: write `write`, move the head, go to `next_state`.
///
/// ```
/// use turing::{Transition, Direction};
///
/// let tr = Transition { write: 'X', direction: Direction::Left, next_state: "q1" };
/// assert_eq!(tr.write, 'X');
/// assert_eq!(tr.next_state, "q1");
/// ```
#[derive(Debug, Clone)]
pub struct Transition<Sym, State> {
    pub write: Sym,
    pub direction: Direction,
    pub next_state: State,
}

/// A snapshot: the current state and the tape.
///
/// ```
/// use turing::{Configuration, Tape};
///
/// let tape: Tape<char> = Tape::new('_');
/// let cfg = Configuration { state: "q0", tape };
/// assert_eq!(cfg.state, "q0");
/// ```
#[derive(Debug, Clone)]
pub struct Configuration<Sym, State> {
    pub state: State,
    pub tape: Tape<Sym>,
}

/// The outcome of a run.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Outcome {
    /// An accepting state was reached.
    Accepted,
    /// A rejecting state was reached.
    Rejected,
    /// No transition applied; the machine neither accepts nor rejects.
    ///
    /// In the theoretical model this is the same as a rejection -- a machine
    /// that halts without accepting is said to reject the input. Here the two
    /// are told apart so that a trace shows *why* the word was not accepted.
    Stuck,
    /// The step limit was reached before the machine halted.
    Limit,
}

impl fmt::Display for Outcome {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Outcome::Accepted => write!(f, "Accepted"),
            Outcome::Rejected => write!(f, "Rejected"),
            Outcome::Stuck => write!(f, "Stuck"),
            Outcome::Limit => write!(f, "Limit"),
        }
    }
}

/// The full trace of a computation: every configuration visited, together
/// with the outcome.
#[derive(Debug, Clone)]
pub struct Run<Sym, State> {
    pub outcome: Outcome,
    pub configs: Vec<Configuration<Sym, State>>,
}

/// A Turing machine.
///
/// Holds the transition table (a partial function) and the designated start,
/// accept, and reject states. The machine is deterministic: at most one
/// transition applies to any (state, symbol) pair.
///
/// The sets Q, Σ and Γ of the formal definition are not stored separately.
/// The state set Q is the states the table mentions plus `start`, `accept`,
/// and `reject`; the tape alphabet Γ is whatever the symbol type can hold.
/// There is no separate input alphabet Σ: a word is laid on the tape before
/// the run, and the machine may read and write any symbol, including markers
/// such as the `X` used by the example machines.
///
/// ```
/// use std::collections::HashMap;
/// use turing::{Machine, Tape, Transition, Direction, Outcome};
///
/// // A machine that flips '0' to '1' and accepts.
/// let mut t = HashMap::new();
/// t.insert(("q0", '0'), Transition { write: '1', direction: Direction::Right, next_state: "accept" });
///
/// let machine = Machine::new(t, "q0", "accept", "reject");
/// let tape = Tape::with_word(&['0'], ' ');
/// let run = machine.run(tape, 100);
/// assert_eq!(run.outcome, Outcome::Accepted);
/// assert_eq!(run.configs.last().unwrap().tape.content_trimmed(), vec!['1']);
/// ```
#[derive(Debug, Clone)]
pub struct Machine<Sym, State> {
    transitions: HashMap<(State, Sym), Transition<Sym, State>>,
    start: State,
    accept: State,
    reject: State,
}

impl<Sym, State> Machine<Sym, State>
where
    Sym: Clone + Eq + Hash,
    State: Clone + Eq + Hash,
{
    /// Creates a machine from its parts.
    ///
    /// `transitions` maps (state, symbol) to a transition.
    /// `start`, `accept`, `reject` are the designated states.
    ///
    /// ```
    /// use std::collections::HashMap;
    /// use turing::{Machine, Transition, Direction};
    ///
    /// let t = HashMap::new(); // empty table: no transitions
    /// let machine: Machine<char, &str> = Machine::new(t, "q0", "ok", "no");
    /// ```
    pub fn new(
        transitions: HashMap<(State, Sym), Transition<Sym, State>>,
        start: State,
        accept: State,
        reject: State,
    ) -> Self {
        Self {
            transitions,
            start,
            accept,
            reject,
        }
    }

    /// Computes the next configuration from `config`, or `None` if no
    /// transition applies.
    ///
    /// ```
    /// use std::collections::HashMap;
    /// use turing::{Machine, Tape, Configuration, Transition, Direction};
    ///
    /// let mut t = HashMap::new();
    /// t.insert(("q0", 'a'), Transition { write: 'b', direction: Direction::Right, next_state: "q1" });
    /// let machine = Machine::new(t, "q0", "ok", "no");
    ///
    /// let tape = Tape::with_word(&['a'], '_');
    /// let next = machine.next(&Configuration { state: "q0", tape }).unwrap();
    /// assert_eq!(next.state, "q1");
    /// assert_eq!(*next.tape.read(), '_'); // moved right onto blank
    /// ```
    pub fn next(&self, config: &Configuration<Sym, State>) -> Option<Configuration<Sym, State>> {
        let sym = config.tape.read().clone();
        self.transitions
            .get(&(config.state.clone(), sym))
            .map(|tr| {
                let mut tape = config.tape.clone();
                tape.write(tr.write.clone());
                tape.move_head(tr.direction);
                Configuration {
                    state: tr.next_state.clone(),
                    tape,
                }
            })
    }

    /// Runs the machine on `tape` and returns the trace with the outcome.
    ///
    /// Takes at most `max_steps` transitions; a machine that has not halted
    /// by then ends with `Outcome::Limit` instead of running forever.
    ///
    /// `Limit` is an engineering substitute for non-termination, not a
    /// theoretical outcome: whether a machine stops at all is undecidable, so
    /// a finite trace simply gives up after `max_steps`.
    ///
    /// ```
    /// use std::collections::HashMap;
    /// use turing::{Machine, Tape, Transition, Direction, Outcome};
    ///
    /// // A machine that always moves right -- never halts.
    /// let mut t = HashMap::new();
    /// t.insert(("q0", 'a'), Transition { write: 'a', direction: Direction::Right, next_state: "q0" });
    /// t.insert(("q0", ' '), Transition { write: ' ', direction: Direction::Right, next_state: "q0" });
    /// let machine = Machine::new(t, "q0", "accept", "reject");
    ///
    /// let tape = Tape::with_word(&['a'], ' ');
    /// let run = machine.run(tape, 3);
    /// assert_eq!(run.outcome, Outcome::Limit);
    /// assert_eq!(run.configs.len(), 4); // start + 3 steps
    /// ```
    pub fn run(&self, tape: Tape<Sym>, max_steps: usize) -> Run<Sym, State> {
        let mut config = Configuration {
            state: self.start.clone(),
            tape,
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
        Run { outcome, configs }
    }
}
