//! The three-element Heyting algebra {0, 1/2, 1}.
//!
//! The demo prints the truth tables of the connectives, then evaluates two formulas over all valuations of their atoms.
//! The axiom `p -> (q -> p)` holds everywhere.
//! Peirce's law `((p -> q) -> p) -> p` is classically valid but fails at `p = 1/2, q = 0`.
//!
//! The same algebra is available as a table algebra via `chain_three()`, which is the downset algebra of the two-element chain.

use heyting::Value;

const ELEMS: [Value; 3] = [Value::Bot, Value::Mid, Value::Top];

fn main() {
    println!("meet (and): min");
    print_table(|a, b| a.meet(b));
    println!("join (or): max");
    print_table(|a, b| a.join(b));
    println!("implies: a -> b is Top when a <= b, else b");
    print_table(|a, b| a.implies(b));
    println!("negation: !a = a -> Bot");
    for &a in &ELEMS {
        println!("  !{a:?} = {:?}", !a);
    }

    println!("\np -> (q -> p), over all nine valuations:");
    for &p in &ELEMS {
        for &q in &ELEMS {
            let v = p.implies(q.implies(p));
            println!("  p = {p:?}, q = {q:?}: {v:?}");
        }
    }

    println!("\nPeirce's law ((p -> q) -> p) -> p:");
    for &p in &ELEMS {
        for &q in &ELEMS {
            let pq = p.implies(q);
            let v = pq.implies(p).implies(p);
            let mark = if v == Value::Top {
                ""
            } else {
                "   <-- not a tautology"
            };
            println!("  p = {p:?}, q = {q:?}: {v:?}{mark}");
        }
    }

    println!("\nThe same algebra as a table algebra (chain_three):");
    let a = heyting::chain_three();
    assert_eq!(a.size(), 3);
    for (x, &ex) in ELEMS.iter().enumerate() {
        for (y, &ey) in ELEMS.iter().enumerate() {
            let expected = ex.meet(ey) as usize;
            assert_eq!(a.meet(x, y), expected);
        }
    }
    println!("  meet table agrees with Value: {a:?}");
}

fn print_table(op: fn(Value, Value) -> Value) {
    for &a in &ELEMS {
        let row: Vec<String> = ELEMS.iter().map(|&b| format!("{:?}", op(a, b))).collect();
        println!("  {a:?} | {}", row.join("  "));
    }
    println!();
}
