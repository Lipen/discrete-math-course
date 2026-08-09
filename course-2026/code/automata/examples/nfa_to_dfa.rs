//! Конструкция подмножеств: НКА -> ДКА (глава m17).
//!
//! НКА языка «содержит "00" или "11"» детерминизируется в ДКА;
//! языки совпадают на всех пробных словах.

use automata::Nfa;

fn contains_double() -> Nfa {
    let mut nfa = Nfa::new(vec!['0', '1']);
    let q0 = nfa.add_state(false);
    let q1 = nfa.add_state(false);
    let qa = nfa.add_state(true);
    let q2 = nfa.add_state(false);
    let qb = nfa.add_state(true);
    nfa.set_start(q0);

    nfa.add_transition(q0, '0', q1);
    nfa.add_transition(q1, '0', qa);
    nfa.add_transition(q1, '1', q2);
    nfa.add_transition(q0, '1', q2);
    nfa.add_transition(q2, '1', qb);
    nfa.add_transition(q2, '0', q1);
    nfa.add_transition(qa, '0', qa);
    nfa.add_transition(qa, '1', qa);
    nfa.add_transition(qb, '0', qb);
    nfa.add_transition(qb, '1', qb);
    nfa
}

fn main() {
    let nfa = contains_double();
    let dfa = nfa.to_dfa();

    println!(
        "НКА с {} состояниями -> ДКА с {} состояниями",
        nfa.num_states(),
        dfa.num_states()
    );

    for w in [
        "", "0", "1", "00", "11", "010", "1010", "01011", "1000", "010010",
    ] {
        let a = nfa.accepts(w);
        let b = dfa.accepts(w);
        let mark = if a == b { "ok" } else { "ОШИБКА" };
        println!("{w:>7}: НКА={a:<5} ДКА={b:<5} {mark}");
    }
}
