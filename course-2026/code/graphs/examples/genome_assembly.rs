//! Genome assembly from reads: reads -> de Bruijn graph -> Eulerian path -> genome.
//!
//! Two runs: a linear genome (the trail is a path), and a circular genome (the trail is a cycle, so the assembled string is a rotation of the genome).

use graphs::DeBruijnGraph;

fn main() {
    linear_genome();
    circular_genome();
}

/// The reads "ACG", "CGT", "GTA" spell the linear genome "ACGTA".
fn linear_genome() {
    let k = 3;
    let reads = ["ACG", "CGT", "GTA"];

    println!("== Linear genome, k = {k} ==");
    println!("reads: {reads:?}\n");

    let g = DeBruijnGraph::build(&reads, k);
    print_graph(&g);

    let path = g.eulerian_path().expect("an Eulerian path exists");
    print_path(&g, &path);

    let genome = g.genome_from_path(&path);
    println!("assembled genome: {genome}");

    assert_eq!(genome, "ACGTA");
    assert!(reads.iter().all(|r| genome.contains(r)));
    println!("the assembled string contains every read\n");
}

/// The same four reads form a cycle: the genome is circular, and any rotation of the assembled string is a valid assembly.
fn circular_genome() {
    let k = 3;
    let reads = ["TAC", "ACG", "CGT", "GTA"];
    let original = "TACGTA"; // the circular genome the reads came from

    println!("== Circular genome, k = {k} ==");
    println!("reads: {reads:?}");
    println!("the reads come from the circular genome {original:?}\n");

    let g = DeBruijnGraph::build(&reads, k);
    print_graph(&g);

    let cycle = g.eulerian_path().expect("an Eulerian cycle exists");
    print_path(&g, &cycle);

    let assembled = g.genome_from_path(&cycle);
    println!("assembled genome: {assembled}");

    // Reading circularly, every read must appear in the assembled string
    // (the doubled string covers the wrap-around).
    let doubled = format!("{assembled}{assembled}");
    for r in reads {
        assert!(doubled.contains(r), "read {r} missing from {assembled}");
    }
    assert_eq!(assembled, original);
    println!("every read appears in the circular genome\n");
}

fn print_graph(g: &DeBruijnGraph) {
    println!(
        "de Bruijn graph: {} vertices, {} edges",
        g.node_count(),
        g.edge_count()
    );
    for u in 0..g.node_count() {
        for &(v, c) in &g.adj[u] {
            let label = g.edge_label(u, v);
            if c > 1 {
                println!(
                    "  {} -> {}   (edge {label}, {c} reads)",
                    g.names[u], g.names[v]
                );
            } else {
                println!("  {} -> {}   (edge {label})", g.names[u], g.names[v]);
            }
        }
    }
    println!();
}

fn print_path(g: &DeBruijnGraph, path: &[usize]) {
    let names: Vec<&str> = path.iter().map(|&u| g.names[u].as_str()).collect();
    println!("Eulerian path: {}", names.join(" -> "));
}
