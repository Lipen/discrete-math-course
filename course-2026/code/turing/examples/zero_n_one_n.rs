//! A machine from the chapter recognizing the language 0^n 1^n.
//!
//! A run on the word "0011": the machine crosses out pairs 0--1 with X
//! and accepts when all symbols are crossed out.

use turing::{examples, Tape};

fn main() {
    let machine = examples::zero_n_one_n();

    for word in ["", "01", "0011", "001", "10"] {
        let tape = Tape::with_word(&word.chars().collect::<Vec<_>>(), ' ');
        let outcome = machine.run(tape).outcome;
        println!("{word:>6} -> {outcome:?}");
    }

    // The full trace for "0011".
    let tape = Tape::with_word(&['0', '0', '1', '1'], ' ');
    let run = machine.run(tape);
    println!("\nTrace for 0011:");
    for (i, cfg) in run.configs.iter().enumerate() {
        let content: String = cfg.tape.content().iter().collect();
        println!("{i:>2}: {:>6}  [{content}]", cfg.state);
    }
}
