//! Машина из главы m19, распознающая язык 0^n 1^n.
//!
//! Прогон на слове "0011": машина вычёркивает пары 0--1 буквой X
//! и принимает, когда все символы вычеркнуты.

use turing::{examples, Tape};

fn main() {
    let machine = examples::zero_n_one_n();

    for word in ["", "01", "0011", "001", "10"] {
        let tape = Tape::with_word(&word.chars().collect::<Vec<_>>(), ' ');
        let outcome = machine.run(tape).outcome;
        println!("{word:>6} -> {outcome:?}");
    }

    // Полная трасса на "0011".
    let tape = Tape::with_word(&['0', '0', '1', '1'], ' ');
    let run = machine.run(tape);
    println!("\nТрасса на 0011:");
    for (i, cfg) in run.configs.iter().enumerate() {
        let content: String = cfg.tape.content().iter().collect();
        println!("{i:>2}: {:>6}  [{content}]", cfg.state);
    }
}
