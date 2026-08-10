//! Regular expressions via the Thompson construction.
//!
//! Book example: `(a|b)*a(a|b)` is the language of words whose second-to-last
//! letter is `a`. The expression becomes an epsilon-NFA, then a DFA via the
//! subset construction.

use automata::{parse, RegEx};

fn main() {
    let re: RegEx = parse("(a|b)*a(a|b)").unwrap();
    let nfa = re.to_nfa();
    let dfa = nfa.to_dfa();

    println!("Regular expression: (a|b)*a(a|b) --- words with second-to-last letter a");
    println!(
        "NFA states: {}, DFA states: {}",
        nfa.num_states(),
        dfa.num_states()
    );

    for w in ["a", "aa", "ba", "aab", "baba", "", "b", "bb", "abb"] {
        println!("{w:>5}: DFA={}", dfa.accepts(w));
    }
}
