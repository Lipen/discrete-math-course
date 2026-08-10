//! Operations on automaton languages (the chapter "Closure Properties").
//!
//! Union, intersection and complement are built via the product of automata:
//! the state of the result is a pair of states of the source machines.

use automata::Dfa;

/// A DFA for words with an even number of ones.
fn even_ones() -> Dfa {
    let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
    dfa.set_transition(0, '0', 0).unwrap();
    dfa.set_transition(0, '1', 1).unwrap();
    dfa.set_transition(1, '0', 1).unwrap();
    dfa.set_transition(1, '1', 0).unwrap();
    dfa.set_accepting(vec![true, false]);
    dfa
}

/// A DFA for words ending in "0".
fn ends_with_zero() -> Dfa {
    let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
    dfa.set_transition(0, '0', 1).unwrap();
    dfa.set_transition(0, '1', 0).unwrap();
    dfa.set_transition(1, '0', 1).unwrap();
    dfa.set_transition(1, '1', 0).unwrap();
    dfa.set_accepting(vec![false, true]);
    dfa
}

fn main() {
    let even = even_ones();
    let end0 = ends_with_zero();
    let union = even.union(&end0);
    let inter = even.intersection(&end0);
    let diff = even.difference(&end0);
    let comp = even.complement();

    for w in ["", "0", "1", "10", "110", "010"] {
        println!(
            "{w:>3}: even1={:<5} end0={:<5} ∪={:<5} ∩={:<5} ∖={:<5} ¬even1={}",
            even.accepts(w),
            end0.accepts(w),
            union.accepts(w),
            inter.accepts(w),
            diff.accepts(w),
            comp.accepts(w),
        );
    }

    println!(
        "Sizes: even1={}, end0={}, product (∪)={}",
        even.num_states(),
        end0.num_states(),
        union.num_states(),
    );
}
