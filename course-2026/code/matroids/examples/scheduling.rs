//! Scheduling with deadlines as a matroid: A(d1,p50), B(d1,p40), C(d2,p30).
//!
//! Independent sets are schedulable sets of jobs: at every time t, at most t jobs have deadline <= t.
//! Greedy by profit picks {A, C} with total 80.

use matroids::examples::SchedulingMatroid;
use matroids::{greedy, weight};

fn main() {
    let m = SchedulingMatroid {
        deadlines: vec![1, 1, 2],
    };
    let profits = [50u32, 40, 30];

    let base = greedy(&m, &profits);
    let total = weight(&base, &profits);
    let names: Vec<char> = base.iter().map(|&i| (b'A' + i as u8) as char).collect();

    println!("jobs: A(d=1,p=50), B(d=1,p=40), C(d=2,p=30)");
    println!("greedy picks: {:?}", names);
    println!("total profit: {}", total);

    assert_eq!(total, 80);
}
