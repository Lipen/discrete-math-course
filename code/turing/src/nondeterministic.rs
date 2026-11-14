//! Nondeterministic Turing machines and bounded breadth-first search.
//!
//! A nondeterministic machine may offer several transitions for the same (state, symbol) pair.
//! A step therefore returns every configuration the machine can move to, and a run explores them breadth-first up to a step bound.
//!
//! Breadth-first search is what makes the answer meaningful.
//! Exploring one branch at a time could descend into a non-halting branch and never try the accepting one.
//! Level by level, an accepting configuration is found in the fewest steps, and its path is a witness of acceptance.
//!
//! ```
//! use std::collections::HashMap;
//! use turing::{Direction, NondeterministicMachine, NondeterministicOutcome, Tape, Transition};
//!
//! // Guess whether the next symbol is 'x'.
//! let mut t = HashMap::new();
//! t.insert(
//!     ("q0", 'a'),
//!     vec![
//!         Transition { write: 'a', direction: Direction::Right, next_state: "q0" },
//!         Transition { write: 'a', direction: Direction::Right, next_state: "q1" },
//!     ],
//! );
//! t.insert(
//!     ("q1", 'x'),
//!     vec![Transition { write: 'x', direction: Direction::Right, next_state: "accept" }],
//! );
//!
//! let m = NondeterministicMachine::new(t, "q0", "accept", "reject");
//! let tape = Tape::with_word(&['a', 'x'], ' ');
//! assert_eq!(m.run(tape, 10).outcome, NondeterministicOutcome::Accepted);
//! ```

use std::collections::{HashMap, HashSet};
use std::fmt;
use std::hash::Hash;

use crate::machine::{Configuration, Transition};
use crate::tape::Tape;

/// How a nondeterministic search ended.
///
/// ```
/// use turing::NondeterministicOutcome;
///
/// assert_eq!(NondeterministicOutcome::Accepted.to_string(), "Accepted");
/// ```
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NondeterministicOutcome {
    /// Some branch reached the accepting state.
    Accepted,
    /// The search exhausted every reachable configuration without accepting.
    Rejected,
    /// Branches were still alive when the step bound was reached.
    Limit,
}

impl fmt::Display for NondeterministicOutcome {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            NondeterministicOutcome::Accepted => write!(f, "Accepted"),
            NondeterministicOutcome::Rejected => write!(f, "Rejected"),
            NondeterministicOutcome::Limit => write!(f, "Limit"),
        }
    }
}

/// The result of a bounded breadth-first search.
///
/// `path` is a witness of acceptance: the configurations from the start to the accepting one, inclusive.
/// It is empty unless the outcome is [`NondeterministicOutcome::Accepted`].
///
/// ```
/// use turing::{machines, NondeterministicOutcome, Tape};
///
/// let m = machines::contains_01();
/// let tape = Tape::with_word(&['0', '1'], ' ');
/// let run = m.run(tape, 10);
/// assert_eq!(run.outcome, NondeterministicOutcome::Accepted);
/// assert_eq!(run.steps, 2);
/// assert_eq!(run.path.len(), 3); // start, guessed state, accepting state
/// ```
#[derive(Debug, Clone)]
pub struct NondeterministicRun<Sym, State> {
    /// How the search ended.
    pub outcome: NondeterministicOutcome,
    /// The number of steps in the witness path, or the depth explored when no witness was found.
    pub steps: usize,
    /// The accepting computation, from the start configuration to the accepting one.
    /// Empty when the word was not accepted.
    pub path: Vec<Configuration<Sym, State>>,
    /// How many distinct configurations the search reached, including the initial one.
    pub visited: usize,
}

/// A configuration discovered by the search, with a link to its predecessor.
struct Node<Sym, State> {
    config: Configuration<Sym, State>,
    parent: Option<usize>,
}

/// Rebuilds the path from the start to `nodes[index]`.
fn witness<Sym, State>(
    nodes: &[Node<Sym, State>],
    mut index: usize,
) -> Vec<Configuration<Sym, State>>
where
    Sym: Clone,
    State: Clone,
{
    let mut path = Vec::new();
    loop {
        path.push(nodes[index].config.clone());
        match nodes[index].parent {
            Some(parent) => index = parent,
            None => break,
        }
    }
    path.reverse();
    path
}

/// A nondeterministic Turing machine.
///
/// The transition relation maps each (state, symbol) pair to a list of possible steps.
/// An empty or missing list means the branch halts.
///
/// A run is a bounded breadth-first search.
/// A configuration is visited at most once per state-and-tape snapshot, so cycles cannot make the search diverge on their own.
/// `max_steps` bounds the depth of the search, and the number of distinct configurations bounds the width in practice.
///
/// ```
/// use std::collections::HashMap;
/// use turing::{Direction, NondeterministicMachine, NondeterministicOutcome, Tape, Transition};
///
/// let mut t = HashMap::new();
/// t.insert(
///     ("q0", 'a'),
///     vec![
///         Transition { write: 'a', direction: Direction::Right, next_state: "q0" },
///         Transition { write: 'a', direction: Direction::Right, next_state: "accept" },
///     ],
/// );
/// let m = NondeterministicMachine::new(t, "q0", "accept", "reject");
///
/// let tape = Tape::with_word(&['a'], ' ');
/// assert_eq!(m.run(tape, 5).outcome, NondeterministicOutcome::Accepted);
/// ```
#[derive(Debug, Clone)]
pub struct NondeterministicMachine<Sym, State> {
    transitions: HashMap<(State, Sym), Vec<Transition<Sym, State>>>,
    start: State,
    accept: State,
    reject: State,
}

impl<Sym, State> NondeterministicMachine<Sym, State>
where
    Sym: Clone + Eq + Hash,
    State: Clone + Eq + Hash,
{
    /// Creates a machine from its transition relation and designated states.
    ///
    /// ```
    /// use std::collections::HashMap;
    /// use turing::NondeterministicMachine;
    ///
    /// let m: NondeterministicMachine<char, &str> =
    ///     NondeterministicMachine::new(HashMap::new(), "q0", "ok", "no");
    /// let tape = turing::Tape::new(' ');
    /// assert_eq!(m.run(tape, 3).outcome, turing::NondeterministicOutcome::Rejected);
    /// ```
    pub fn new(
        transitions: HashMap<(State, Sym), Vec<Transition<Sym, State>>>,
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

    /// Returns every configuration reachable in one step.
    ///
    /// The vector is empty when the branch halts.
    /// Its length is the local branching factor.
    ///
    /// ```
    /// use turing::machines;
    /// use turing::{Configuration, Tape};
    ///
    /// let m = machines::contains_01();
    /// let cfg = Configuration { state: "q0", tape: Tape::with_word(&['0', '1'], ' ') };
    /// assert_eq!(m.next(&cfg).len(), 2); // stay in q0 or guess the '01' pair
    /// ```
    pub fn next(&self, config: &Configuration<Sym, State>) -> Vec<Configuration<Sym, State>> {
        let sym = config.tape.read().clone();
        match self.transitions.get(&(config.state.clone(), sym)) {
            Some(steps) => steps
                .iter()
                .map(|tr| {
                    let mut tape = config.tape.clone();
                    tape.write(tr.write.clone());
                    tape.move_head(tr.direction);
                    Configuration {
                        state: tr.next_state.clone(),
                        tape,
                    }
                })
                .collect(),
            None => Vec::new(),
        }
    }

    /// Searches for an accepting computation of at most `max_steps` steps.
    ///
    /// Configurations are expanded level by level.
    /// A configuration that has already been reached is not expanded again, so cyclic branches do not loop.
    /// The search stops with:
    ///
    /// - `Accepted` when a level contains an accepting configuration, with the shortest witness path in `path`, - `Rejected` when the reachable configurations are exhausted without an accepting one, - `Limit` when `max_steps` levels were expanded and branches remain.
    ///
    /// ```
    /// use turing::{machines, NondeterministicOutcome, Tape};
    ///
    /// let m = machines::contains_01();
    ///
    /// let tape = Tape::with_word(&['1', '1', '0', '1'], ' ');
    /// assert_eq!(m.run(tape, 20).outcome, NondeterministicOutcome::Accepted);
    ///
    /// let tape = Tape::with_word(&['1', '0', '0'], ' ');
    /// assert_eq!(m.run(tape, 20).outcome, NondeterministicOutcome::Rejected);
    /// ```
    pub fn run(&self, tape: Tape<Sym>, max_steps: usize) -> NondeterministicRun<Sym, State> {
        let start = Configuration {
            state: self.start.clone(),
            tape,
        };
        let mut visited: HashSet<Configuration<Sym, State>> = HashSet::new();
        visited.insert(start.clone());

        if start.state == self.accept {
            return NondeterministicRun {
                outcome: NondeterministicOutcome::Accepted,
                steps: 0,
                path: vec![start],
                visited: 1,
            };
        }

        let mut nodes = vec![Node {
            config: start,
            parent: None,
        }];
        let mut frontier = vec![0usize];
        let mut depth = 0;

        while !frontier.is_empty() {
            if depth == max_steps {
                return NondeterministicRun {
                    outcome: NondeterministicOutcome::Limit,
                    steps: depth,
                    path: Vec::new(),
                    visited: visited.len(),
                };
            }

            let mut next_frontier = Vec::new();
            for index in &frontier {
                let config = nodes[*index].config.clone();
                for next in self.next(&config) {
                    if !visited.insert(next.clone()) {
                        continue;
                    }
                    if next.state == self.accept {
                        let mut path = witness(&nodes, *index);
                        path.push(next);
                        return NondeterministicRun {
                            outcome: NondeterministicOutcome::Accepted,
                            steps: depth + 1,
                            path,
                            visited: visited.len(),
                        };
                    }
                    if next.state == self.reject {
                        continue;
                    }
                    let node = nodes.len();
                    nodes.push(Node {
                        config: next,
                        parent: Some(*index),
                    });
                    next_frontier.push(node);
                }
            }

            frontier = next_frontier;
            depth += 1;
        }

        NondeterministicRun {
            outcome: NondeterministicOutcome::Rejected,
            steps: depth.saturating_sub(1),
            path: Vec::new(),
            visited: visited.len(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::machines;
    use crate::tape::{Direction, Tape};

    fn tape(word: &str) -> Tape<char> {
        let chars: Vec<char> = word.chars().collect();
        Tape::with_word(&chars, ' ')
    }

    #[test]
    fn contains_01_accepts_words_with_the_pair() {
        let m = machines::contains_01();
        for word in ["01", "001", "010", "1101", "101", "0110"] {
            let run = m.run(tape(word), 30);
            assert_eq!(
                run.outcome,
                NondeterministicOutcome::Accepted,
                "word {word:?}"
            );
        }
    }

    #[test]
    fn contains_01_rejects_words_without_the_pair() {
        let m = machines::contains_01();
        for word in ["", "0", "1", "10", "00", "111", "100", "1100"] {
            let run = m.run(tape(word), 30);
            assert_eq!(
                run.outcome,
                NondeterministicOutcome::Rejected,
                "word {word:?}"
            );
        }
    }

    #[test]
    fn witness_path_is_a_multi_step_trace() {
        let m = machines::contains_01();
        let run = m.run(tape("001"), 30);

        assert_eq!(run.outcome, NondeterministicOutcome::Accepted);
        assert_eq!(run.steps, 3);
        assert_eq!(run.path.len(), run.steps + 1);
        assert_eq!(run.path[0].state, "q0");
        assert_eq!(run.path.last().unwrap().state, "accept");
        // The guessed branch switches to q1 before reading the final '1'.
        assert!(run.path.iter().any(|cfg| cfg.state == "q1"));
        assert!(run.visited >= run.path.len());
    }

    #[test]
    fn search_reports_the_step_limit_with_live_branches() {
        // Every branch keeps producing fresh configurations and no accepting state is reachable.
        let mut t: HashMap<(&str, char), Vec<Transition<char, &str>>> = HashMap::new();
        t.insert(
            ("q0", 'a'),
            vec![Transition {
                write: 'a',
                direction: Direction::Right,
                next_state: "q0",
            }],
        );
        t.insert(
            ("q0", ' '),
            vec![Transition {
                write: ' ',
                direction: Direction::Right,
                next_state: "q0",
            }],
        );
        let m = NondeterministicMachine::new(t, "q0", "accept", "reject");
        let run = m.run(tape("a"), 5);
        assert_eq!(run.outcome, NondeterministicOutcome::Limit);
        assert_eq!(run.steps, 5);
    }

    #[test]
    fn reject_states_kill_a_branch() {
        let mut t: HashMap<(&str, char), Vec<Transition<char, &str>>> = HashMap::new();
        t.insert(
            ("q0", 'a'),
            vec![Transition {
                write: 'a',
                direction: Direction::Right,
                next_state: "reject",
            }],
        );
        let m = NondeterministicMachine::new(t, "q0", "accept", "reject");
        let run = m.run(tape("a"), 5);
        assert_eq!(run.outcome, NondeterministicOutcome::Rejected);
        assert!(run.path.is_empty());
    }

    #[test]
    fn start_state_can_be_accepting() {
        let m: NondeterministicMachine<char, &str> =
            NondeterministicMachine::new(HashMap::new(), "accept", "accept", "reject");
        let run = m.run(tape(""), 0);
        assert_eq!(run.outcome, NondeterministicOutcome::Accepted);
        assert_eq!(run.steps, 0);
        assert_eq!(run.path.len(), 1);
    }
}
