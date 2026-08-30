//! Capture-avoiding substitution: bound variables are renamed when needed.

use fol::formula::{forall, pred};
use fol::term::{func, var};

fn main() {
    // The replacement f(y) mentions y, so the bound y is renamed before the
    // incoming term slides in -- otherwise the free y would be captured.
    let f = forall("y", pred("P", vec![var("x"), var("y")]));
    let g = func("f", vec![var("y")]);
    println!("formula:          {f}");
    println!("substitute [x := {g}]:  {}", f.substitute("x", &g));
    println!();

    // No capture here: the binder is z, so f(y) slides in unchanged.
    let h = forall("z", pred("P", vec![var("x"), var("z")]));
    println!("formula:          {h}");
    println!("substitute [x := {g}]:  {}", h.substitute("x", &g));
    println!();

    // Terms have no binders, so substitution is plain replacement.
    let t = func("g", vec![var("x"), func("h", vec![var("x")])]);
    println!("term:             {t}");
    println!("substitute [x := {g}]:  {}", t.substitute("x", &g));
}
