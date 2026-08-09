//! Операции над языками автоматов (глава m17, «Свойства замкнутости»).
//!
//! Объединение, пересечение и дополнение строятся через произведение
//! автоматов: состояние результата --- пара состояний исходных машин.

use automata::Dfa;

/// ДКА: слова с чётным числом единиц.
fn even_ones() -> Dfa {
    let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
    dfa.set_transition(0, '0', 0);
    dfa.set_transition(0, '1', 1);
    dfa.set_transition(1, '0', 1);
    dfa.set_transition(1, '1', 0);
    dfa.set_accepting(vec![true, false]);
    dfa
}

/// ДКА: слова, заканчивающиеся на "0".
fn ends_with_zero() -> Dfa {
    let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
    dfa.set_transition(0, '0', 1);
    dfa.set_transition(0, '1', 0);
    dfa.set_transition(1, '0', 1);
    dfa.set_transition(1, '1', 0);
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
            "{w:>3}: чёт.1={:<5} кон.0={:<5} ∪={:<5} ∩={:<5} ∖={:<5} ¬чёт.1={}",
            even.accepts(w),
            end0.accepts(w),
            union.accepts(w),
            inter.accepts(w),
            diff.accepts(w),
            comp.accepts(w),
        );
    }

    println!(
        "Размеры: чёт.1={}, кон.0={}, произведение (∪)={}",
        even.num_states(),
        end0.num_states(),
        union.num_states(),
    );
}
