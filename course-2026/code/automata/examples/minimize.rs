//! Минимизация ДКА методом Мура (глава m17, «Минимизация ДКА»).
//!
//! Автомат с избыточным (неразличимым) состоянием сжимается до минимального
//! числа состояний; язык сохраняется.

use automata::Dfa;

fn main() {
    // Язык слов, заканчивающихся на 0; состояния 1 и 2 неразличимы.
    let mut dfa = Dfa::new(3, 0, vec!['0', '1']);
    dfa.set_transition(0, '0', 1);
    dfa.set_transition(0, '1', 0);
    dfa.set_transition(1, '0', 2);
    dfa.set_transition(1, '1', 1);
    dfa.set_transition(2, '0', 1);
    dfa.set_transition(2, '1', 2);
    dfa.set_accepting(vec![false, true, true]); // 1 и 2 неразличимы

    let min = dfa.minimize();
    println!(
        "Исходный ДКА: {} состояния, минимальный: {} состояния",
        dfa.num_states(),
        min.num_states()
    );

    for w in ["", "0", "1", "00", "010", "1010", "00100"] {
        let a = dfa.accepts(w);
        let b = min.accepts(w);
        let mark = if a == b { "ok" } else { "ОШИБКА" };
        println!("{w:>6}: до={a:<5} после={b:<5} {mark}");
    }
}
