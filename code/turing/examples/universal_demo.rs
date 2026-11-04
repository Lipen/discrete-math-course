//! A universal machine: a machine description is data, and one simulator runs any description it is given.
//!
//! The demo encodes an existing machine, prints the description, then decodes and runs it on several inputs.
//! One run is shown step by step.

use turing::{machines, Encoding, Outcome, Tape, UniversalMachine};

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

fn tape(word: &str) -> Tape<char> {
    let chars: Vec<char> = word.chars().collect();
    Tape::with_word(&chars, ' ')
}

fn main() {
    let original = machines::binary_increment();
    let encoding = Encoding::from_machine(&original);
    let universal = UniversalMachine::new();

    println!("=== machine encoded as data ===\n");
    println!("{encoding}");

    println!("=== the universal machine runs the description ===\n");
    println!("  binary increment, least significant bit first\n");
    for word in ["", "0", "11", "1011", "1111"] {
        let run = universal.run(&encoding, tape(word), 50);
        let last = run.configs.last().unwrap();
        let result: String = last.tape.content_trimmed().iter().collect();
        println!(
            "  input {word:>7?} -> {:<8} after {:>2} steps, tape = [{}]",
            run.outcome.to_string(),
            run.configs.len() - 1,
            result
        );
    }

    println!("\n=== step-by-step trace for 11 ===\n");
    let run = universal.run(&encoding, tape("11"), 20);
    for (step, config) in run.configs.iter().enumerate() {
        println!(
            "  step {step:>2}  state={:<6}  tape={}",
            config.state,
            render(&config.tape)
        );
    }
    println!("\n  result: {}", run.outcome);

    println!("\n=== decoded machine is an ordinary machine ===\n");
    let decoded = universal.decode(&encoding);
    println!(
        "  {} states, {} transitions, start = {}, accept = {}",
        encoding.states.len(),
        decoded.transitions().len(),
        decoded.start(),
        decoded.accept()
    );
    let rejected = universal.run(&encoding, tape("2"), 10).outcome;
    println!("  an unknown symbol is not accepted: {rejected}");
    assert_eq!(rejected, Outcome::Stuck);
}
