//! Turing machines.
//!
//! The core is modeled after the design of the experimental repository
//! `~/dev/nexus/turing`: a tape with a head on two stacks, a transition table,
//! a trace of configurations. Adapted to the definition in the chapter ---
//! accepting and rejecting states.

use std::collections::HashMap;
use std::hash::Hash;

/// The direction the head moves.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Direction {
    Left,
    Right,
    Stay,
}

/// Transition: write `write`, move, go to `next_state`.
#[derive(Debug, Clone)]
pub struct Transition<Sym, State> {
    pub write: Sym,
    pub direction: Direction,
    pub next_state: State,
}

/// Tape with a head.
///
/// Symbols to the left and right of the head are stored in two stacks, so
/// a move transfers a symbol between `left`, `head` and `right`.
#[derive(Debug, Clone)]
pub struct Tape<Sym> {
    head: Sym,
    left: Vec<Sym>,
    right: Vec<Sym>,
    blank: Sym,
}

impl<Sym: Clone + Eq> Tape<Sym> {
    /// An empty tape; the head is on the blank symbol.
    pub fn new(blank: Sym) -> Self {
        Self {
            head: blank.clone(),
            left: Vec::new(),
            right: Vec::new(),
            blank,
        }
    }

    /// A tape with the word `word`; the head is on the first symbol.
    pub fn with_word(word: &[Sym], blank: Sym) -> Self {
        let mut tape = Tape::new(blank.clone());
        for (i, sym) in word.iter().enumerate() {
            tape.write(sym.clone());
            if i + 1 < word.len() {
                tape.move_right();
            }
        }
        // Return to the first symbol.
        for _ in 1..word.len() {
            tape.move_left();
        }
        tape
    }

    pub fn read(&self) -> &Sym {
        &self.head
    }

    pub fn write(&mut self, sym: Sym) {
        self.head = sym;
    }

    pub fn move_left(&mut self) {
        self.right.push(self.head.clone());
        self.head = self.left.pop().unwrap_or_else(|| self.blank.clone());
    }

    pub fn move_right(&mut self) {
        self.left.push(self.head.clone());
        self.head = self.right.pop().unwrap_or_else(|| self.blank.clone());
    }

    pub fn move_head(&mut self, direction: Direction) {
        match direction {
            Direction::Left => self.move_left(),
            Direction::Right => self.move_right(),
            Direction::Stay => {}
        }
    }

    /// The tape content: `left` + `head` + `right`.
    pub fn content(&self) -> Vec<Sym> {
        let mut content = Vec::new();
        content.extend(self.left.iter().cloned());
        content.push(self.head.clone());
        content.extend(self.right.iter().rev().cloned());
        content
    }
}

/// Configuration: the current state and the tape.
#[derive(Debug, Clone)]
pub struct Configuration<Sym, State> {
    pub state: State,
    pub tape: Tape<Sym>,
}

/// The outcome of the machine's run on an input.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Outcome {
    /// An accepting state was reached.
    Accepted,
    /// A rejecting state was reached.
    Rejected,
    /// No applicable transition: the machine neither accepts nor rejects.
    Stuck,
    /// The step limit was reached before the machine halted.
    Limit,
}

/// A trace of the computation together with the outcome.
#[derive(Debug, Clone)]
pub struct Run<Sym, State> {
    pub outcome: Outcome,
    pub configs: Vec<Configuration<Sym, State>>,
}

/// Turing machine: the transition table, and the start, accepting
/// and rejecting states.
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

    /// The next configuration according to the rule for the current state and symbol.
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

/// Example machines from the chapter.
pub mod examples {
    use super::*;

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

    /// A machine from the chapter that accepts strings over `{0, 1}`
    /// ending in `0`. The blank tape symbol is a space.
    ///
    /// State `q0` means "the last symbol was 1", `q1` means "it was 0".
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

    /// A machine from the chapter recognizing the language `0^n 1^n` (n >= 0).
    ///
    /// Repeatedly crosses out one `0` on the left and one `1` on the right with `X`;
    /// accepts when all symbols are crossed out.
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
        // q2: find the first 1 not yet crossed out on the right (skip crossed-out X's).
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
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ends_with_zero_accepts_correct_words() {
        let machine = examples::ends_with_zero();
        for (word, expect) in [
            ("0", true),
            ("10", true),
            ("010", true),
            ("00", true),
            ("", false),
            ("1", false),
            ("11", false),
            ("01", false),
        ] {
            let tape = Tape::with_word(&word.chars().collect::<Vec<_>>(), ' ');
            let outcome = machine.run(tape, 100).outcome;
            assert_eq!(outcome == Outcome::Accepted, expect, "word {word:?}");
        }
    }

    #[test]
    fn zero_n_one_n_accepts_correct_words() {
        let machine = examples::zero_n_one_n();
        for (word, expect) in [
            ("", true),
            ("01", true),
            ("0011", true),
            ("000111", true),
            ("001", false),
            ("011", false),
            ("10", false),
            ("00111", false),
        ] {
            let tape = Tape::with_word(&word.chars().collect::<Vec<_>>(), ' ');
            let outcome = machine.run(tape, 100).outcome;
            assert_eq!(outcome == Outcome::Accepted, expect, "word {word:?}");
        }
    }

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
        assert_eq!(run.configs.len(), 6); // the start configuration + 5 steps
    }
}
