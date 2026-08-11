//! A machine from the chapter recognising the language 0^n 1^n.
//!
//! The algorithm crosses out matching 0--1 pairs with X and accepts when
//! all symbols are crossed out. This example prints the outcome for several
//! words and shows a full step-by-step trace for "0011".

use turing::{machines, Tape};

fn main() {
    let machine = machines::zero_n_one_n();

    println!("=== 0^n 1^n -- outcome for several inputs ===\n");
    for word in ["", "01", "0011", "000111", "0", "001", "10", "011"] {
        let chars: Vec<char> = word.chars().collect();
        let tape = Tape::with_word(&chars, ' ');
        let outcome = machine.run(tape, 100).outcome;
        println!("  {word:>8}  ->  {outcome}");
    }

    // Full step-by-step trace for "0011".
    println!("\n=== Step-by-step trace for 0011 ===\n");
    let tape = Tape::with_word(&['0', '0', '1', '1'], ' ');
    let run = machine.run(tape, 100);
    for (i, cfg) in run.configs.iter().enumerate() {
        let tape_str: String = cfg.tape.content_trimmed().iter().collect();
        println!("  step {i:>2}:  state={:>6}  tape=[{tape_str}]", cfg.state);
    }
    println!("\n  outcome: {}", run.outcome);
}
