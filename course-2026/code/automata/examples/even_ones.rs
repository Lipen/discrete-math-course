//! ДКА из главы m17: слова с чётным числом единиц.
//!
//! Состояние 0 --- «пока чётно» (принимающее), состояние 1 --- «пока нечётно».
//! Единица переключает состояние, ноль --- нет.

use automata::Dfa;

fn main() {
    let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
    dfa.set_transition(0, '0', 0);
    dfa.set_transition(0, '1', 1);
    dfa.set_transition(1, '0', 1);
    dfa.set_transition(1, '1', 0);
    dfa.set_accepting(vec![true, false]);

    for w in ["", "0", "1", "11", "101", "1100", "111"] {
        let verdict = if dfa.accepts(w) { "accept" } else { "reject" };
        println!("{w:>4} -> {verdict}");
    }
}
