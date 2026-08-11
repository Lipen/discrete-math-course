//! Full pipeline: regex -> NFA -> DFA -> minimize.
//!
//! Demonstrates the complete chain from a regular expression to a minimal DFA
//! and checks that each step preserves the language.

use automata::{parse, RegEx};

fn main() {
    let re_str = "(a|b)*a(a|b)";
    println!("Regex: {re_str}  (words whose second-to-last letter is 'a')");

    let re: RegEx = parse(re_str).unwrap();
    println!("AST:  {re:?}");

    let nfa = re.to_nfa();
    println!("NFA:  {} states", nfa.num_states());

    let dfa = nfa.to_dfa();
    println!("DFA:  {} states", dfa.num_states());

    let min = dfa.minimize();
    println!("Min:  {} states", min.num_states());

    // Verify that the minimal DFA accepts the same words as the original NFA.
    println!();
    println!("Word        NFA     DFA     Min");
    println!("----        ---     ---     ---");
    for w in [
        "", "a", "b", "aa", "ab", "ba", "bb", "aaa", "aab", "aba", "abb", "bab", "bba",
    ] {
        let n = nfa.accepts(w);
        let d = dfa.accepts(w);
        let m = min.accepts(w);
        let ok = if n == d && d == m { "ok" } else { "ERROR" };
        println!("{w:<12} {n:<7} {d:<7} {m:<7} {ok}");
    }

    // Confirm equivalence.
    assert!(dfa.equivalent_to(&min), "minimized DFA must be equivalent");
    println!("\nDFA and minimized DFA are equivalent.");
}
