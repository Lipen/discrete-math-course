//! A machine that checks whether a word over {0, 1} is a palindrome.
//!
//! The algorithm crosses out matching symbols from both ends. It remembers
//! the leftmost uncrossed symbol, moves to the right end, checks that the
//! rightmost uncrossed symbol matches, crosses it out, and returns left.
//! The process repeats until all symbols are matched or a mismatch appears.
//!
//! This example runs the machine on several words and prints a trace for
//! one palindrome and one non-palindrome.

use turing::{machines, Tape};

fn main() {
    let machine = machines::palindrome();

    println!("=== Palindrome check -- outcomes ===\n");
    for word in [
        "", "0", "1", "00", "11", "010", "0110", "1001", "01", "10", "001", "011",
    ] {
        let chars: Vec<char> = word.chars().collect();
        let tape = Tape::with_word(&chars, ' ');
        let outcome = machine.run(tape, 200).outcome;
        println!("  {word:>6}  ->  {outcome}");
    }

    // Trace for a palindrome.
    println!("\n=== Trace for palindrome 0110 ===\n");
    let tape = Tape::with_word(&['0', '1', '1', '0'], ' ');
    let run = machine.run(tape, 100);
    for (i, cfg) in run.configs.iter().enumerate() {
        let tape_str: String = cfg.tape.content_trimmed().iter().collect();
        println!("  step {i:>2}:  state={:>6}  tape=[{tape_str}]", cfg.state);
    }
    println!("  outcome: {}", run.outcome);

    // Trace for a non-palindrome.
    println!("\n=== Trace for non-palindrome 011 ===\n");
    let tape = Tape::with_word(&['0', '1', '1'], ' ');
    let run = machine.run(tape, 100);
    for (i, cfg) in run.configs.iter().enumerate() {
        let tape_str: String = cfg.tape.content_trimmed().iter().collect();
        println!("  step {i:>2}:  state={:>6}  tape=[{tape_str}]", cfg.state);
    }
    println!("  outcome: {}", run.outcome);
}
