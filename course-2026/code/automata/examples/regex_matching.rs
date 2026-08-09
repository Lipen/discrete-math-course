//! Регулярные выражения через конструкцию Томпсона (глава m17).
//!
//! Пример главы: `(a|b)*a(a|b)` --- язык слов с предпоследней буквой `a`.
//! Выражение превращается в ε-НКА, затем --- в ДКА конструкцией подмножеств.

use automata::{parse, RegEx};

fn main() {
    let re: RegEx = parse("(a|b)*a(a|b)");
    let nfa = re.to_nfa();
    let dfa = nfa.to_dfa();

    println!("Регулярное выражение: (a|b)*a(a|b) --- слова с предпоследней буквой a");
    println!(
        "НКА состояний: {}, ДКА состояний: {}",
        nfa.num_states(),
        dfa.num_states()
    );

    for w in ["a", "aa", "ba", "aab", "baba", "", "b", "bb", "abb"] {
        println!("{w:>5}: ДКА={}", dfa.accepts(w));
    }
}
