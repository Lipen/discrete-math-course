//! Fuzzy relations and max-min composition: four towns on one road, with
//! "x is close to y" as the relation.

use fuzzy::FuzzyRelation;

fn main() {
    println!("Fuzzy relation 'x is close to y'");
    println!("================================");
    // Towns {1, 2, 3, 4} on a road; closeness = max(0, 1 - |x - y| / 3).
    let close = FuzzyRelation::from_fn(4, 4, |i, j| {
        (1.0 - (i as f64 - j as f64).abs() / 3.0).max(0.0)
    });
    println!("mu(x, y) = max(0, 1 - |x - y| / 3), towns 1..=4");
    println!();
    println!("relation matrix:");
    for i in 0..4 {
        let row: Vec<String> = (0..4).map(|j| format!("{:5.2}", close.get(i, j))).collect();
        println!("  {}", row.join(" "));
    }
    println!();
    println!(
        "  mu(1,1) = {:.2}, mu(1,2) = {:.2}, mu(1,3) = {:.2}, mu(1,4) = {:.2}",
        close.get(0, 0),
        close.get(0, 1),
        close.get(0, 2),
        close.get(0, 3)
    );
    println!();

    println!("max-min composition R ∘ R (closeness through one middle town)");
    println!("-------------------------------------------------------------");
    let rr = close.max_min_compose(&close).unwrap();
    for i in 0..4 {
        let row: Vec<String> = (0..4).map(|j| format!("{:5.2}", rr.get(i, j))).collect();
        println!("  {}", row.join(" "));
    }
    println!();
    println!("towns 1 and 4 are not directly close (0), but through a");
    println!("middleman they are {:.2} close.", rr.get(0, 3));
    println!();

    println!("max-product composition R · R (Larsen)");
    println!("--------------------------------------");
    let rp = close.max_product_compose(&close).unwrap();
    for i in 0..4 {
        let row: Vec<String> = (0..4).map(|j| format!("{:5.2}", rp.get(i, j))).collect();
        println!("  {}", row.join(" "));
    }
    println!();
    println!("max-product is never above max-min (min >= product on [0,1]).");
}
