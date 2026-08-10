//! Subset construction: NFA -> DFA.
//!
//! An NFA for the language "contains 00 or 11" is determinized into a DFA;
//! the languages agree on all test words.

use automata::Nfa;

fn contains_double() -> Nfa {
    let mut nfa = Nfa::new(vec!['0', '1']);
    let q0 = nfa.add_state(false);
    let q1 = nfa.add_state(false);
    let qa = nfa.add_state(true);
    let q2 = nfa.add_state(false);
    let qb = nfa.add_state(true);
    nfa.set_start(q0);

    nfa.add_transition(q0, '0', q1).unwrap();
    nfa.add_transition(q1, '0', qa).unwrap();
    nfa.add_transition(q1, '1', q2).unwrap();
    nfa.add_transition(q0, '1', q2).unwrap();
    nfa.add_transition(q2, '1', qb).unwrap();
    nfa.add_transition(q2, '0', q1).unwrap();
    nfa.add_transition(qa, '0', qa).unwrap();
    nfa.add_transition(qa, '1', qa).unwrap();
    nfa.add_transition(qb, '0', qb).unwrap();
    nfa.add_transition(qb, '1', qb).unwrap();
    nfa
}

fn main() {
    let nfa = contains_double();
    let dfa = nfa.to_dfa();

    println!(
        "NFA with {} states -> DFA with {} states",
        nfa.num_states(),
        dfa.num_states()
    );

    for w in [
        "", "0", "1", "00", "11", "010", "1010", "01011", "1000", "010010",
    ] {
        let a = nfa.accepts(w);
        let b = dfa.accepts(w);
        let mark = if a == b { "ok" } else { "ERROR" };
        println!("{w:>7}: NFA={a:<5} DFA={b:<5} {mark}");
    }
}
