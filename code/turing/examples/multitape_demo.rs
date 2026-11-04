//! A two-tape machine that copies a word onto its second tape in reverse.
//!
//! The demo prints both tapes after every step of one run, so the two heads can be seen moving independently: the first tape is scanned to the right, then walked back to the left, while the second tape only advances during the walk back.

use turing::{machines, Tape};

/// Renders a tape with the head in brackets.
///
/// Blank cells print as `_`.
fn render(tape: &Tape<char>) -> String {
    let content = tape.content();
    let head = tape.head_index();
    let mut out = String::new();
    for (index, symbol) in content.iter().enumerate() {
        if index == head {
            out.push('[');
        }
        out.push(if *symbol == ' ' { '_' } else { *symbol });
        if index == head {
            out.push(']');
        }
    }
    out
}

fn tapes(word: &str) -> Vec<Tape<char>> {
    let chars: Vec<char> = word.chars().collect();
    vec![Tape::with_word(&chars, ' '), Tape::new(' ')]
}

fn main() {
    let machine = machines::copy_reversed();

    println!("=== two-tape copy in reverse ===\n");
    println!("blank cells print as _, the head is in [].\n");

    for word in ["", "0", "01", "011", "1010", "10X1"] {
        let run = machine.run(tapes(word), 100);
        let last = run.configs.last().unwrap();
        let copy: String = last.tapes[1].content_trimmed().iter().collect();
        println!(
            "  input {word:>7?} -> {:<8} after {:>2} steps, tape 1 = [{}]",
            run.outcome.to_string(),
            run.configs.len() - 1,
            copy
        );
    }

    println!("\n=== step-by-step trace for 011 ===\n");
    let run = machine.run(tapes("011"), 100);
    for (step, config) in run.configs.iter().enumerate() {
        println!(
            "  step {step:>2}  state={:<6}  tape 0={:<9}  tape 1={}",
            config.state,
            render(&config.tapes[0]),
            render(&config.tapes[1])
        );
    }
    println!("\n  result: {}", run.outcome);
}
