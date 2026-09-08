//! Distributive flow functions, the idea behind IFDS.
//!
//! In dataflow analysis a program point holds a set of facts, and the join
//! ⊔ of two sets merges what two branches contribute. A monotone flow
//! function `f` only guarantees `f(x ⊔ y) ⊒ f(x) ⊔ f(y)`: merging the
//! inputs before applying `f` can add facts that no branch alone justified.
//! When `f` is *distributive* -- `f(x ⊔ y) = f(x) ⊔ f(y)` -- each fact can
//! be run through `f` on its own and the results merged with no loss. That
//! is exactly what the IFDS class of analyses relies on.

/// A set of facts, one bit per fact. The universe is {x, y, z}.
type Facts = u8;

const X: Facts = 0b001;
const Y: Facts = 0b010;
const Z: Facts = 0b100;

fn join(a: Facts, b: Facts) -> Facts {
    a | b
}

/// Monotone but NOT distributive: if both `x` and `y` are present, `z`
/// becomes known as well. Merging two branches before applying `f` can add
/// `z` even though neither branch alone knew it.
fn lossy(s: Facts) -> Facts {
    if s & X != 0 && s & Y != 0 {
        s | Z
    } else {
        s
    }
}

/// A distributive flow function: adds `x` to every set. Here
/// `f(s) = union over singletons {e in s} of f({e})`, so running each fact
/// separately and merging loses nothing.
fn distributive(s: Facts) -> Facts {
    s | X
}

fn bits(s: Facts) -> String {
    let mut out = String::from("{");
    let mut first = true;
    for (bit, name) in [(X, "x"), (Y, "y"), (Z, "z")] {
        if s & bit != 0 {
            if !first {
                out.push_str(", ");
            }
            out.push_str(name);
            first = false;
        }
    }
    out.push('}');
    out
}

fn main() {
    let merged = join(X, Y);

    // Lossy: applying f after the merge can be coarser than merging after f.
    let after_merge = lossy(merged);
    let after_apply = join(lossy(X), lossy(Y));
    println!("lossy:");
    println!("  f(x join y)  = {}", bits(after_merge));
    println!("  f(x) join f(y) = {}", bits(after_apply));
    println!("  precision lost: {}\n", after_merge != after_apply);

    // Distributive: both orders agree, so branches can be analysed separately.
    let d_merged = distributive(merged);
    let d_apply = join(distributive(X), distributive(Y));
    println!("distributive:");
    println!("  f(x join y)  = {}", bits(d_merged));
    println!("  f(x) join f(y) = {}", bits(d_apply));
    println!("  exact merge: {}", d_merged == d_apply);
}
