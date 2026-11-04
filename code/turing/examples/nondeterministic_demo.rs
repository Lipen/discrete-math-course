//! A nondeterministic machine that guesses where `01` occurs.
//!
//! A summary shows which words are accepted.
//! A witness path for one accepted word shows the branch the breadth-first search chose, and a rejected word shows how all branches die.

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

fn tape(word: &str) -> Tape<char> {
    let chars: Vec<char> = word.chars().collect();
    Tape::with_word(&chars, ' ')
}

fn main() {
    let machine = machines::contains_01();

    println!("=== nondeterministic search for the pair 01 ===\n");
    for word in ["", "0", "1", "10", "01", "001", "010", "1101", "100"] {
        let run = machine.run(tape(word), 30);
        println!(
            "  input {word:>5?} -> {:<8} steps={:<2} visited={}",
            run.outcome.to_string(),
            run.steps,
            run.visited
        );
    }

    println!("\n=== witness path for 1101 ===\n");
    let run = machine.run(tape("1101"), 30);
    for (step, config) in run.path.iter().enumerate() {
        println!(
            "  step {step:>2}  state={:<6}  tape={}",
            config.state,
            render(&config.tape)
        );
    }
    println!(
        "\n  result: {} after {} steps, {} configurations visited",
        run.outcome, run.steps, run.visited
    );

    println!("\n=== no branch survives for 100 ===\n");
    let run = machine.run(tape("100"), 30);
    println!(
        "  result: {} after exploring depth {}, {} configurations visited",
        run.outcome, run.steps, run.visited
    );
    println!("  witness path is empty: {}", run.path.is_empty());
}
