//! A machine that increments a binary number.
//!
//! The input is a word over {0, 1} with the least significant bit on the
//! left. The machine adds 1: leading 1s become
//! 0s (carry), the first 0 becomes 1, and an all-1 input grows a new digit
//! on the right.
//!
//! This example prints a step-by-step trace for several inputs.

use turing::{machines, Tape};

fn main() {
    let machine = machines::binary_increment();

    for input in ["0", "1", "10", "11", "1011", "111"] {
        println!("=== Binary increment: {input} ===");
        let chars: Vec<char> = input.chars().collect();
        let tape = Tape::with_word(&chars, ' ');
        let run = machine.run(tape, 30);

        for (i, cfg) in run.configs.iter().enumerate() {
            let tape_str: String = cfg.tape.content_trimmed().iter().collect();
            println!("  step {i:>2}:  state={:>6}  tape=[{tape_str}]", cfg.state);
        }
        println!("  outcome: {}\n", run.outcome);
    }
}
