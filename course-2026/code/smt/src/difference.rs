//! Difference logic: satisfiability via negative-cycle detection.

/// A difference constraint `x - y <= c`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Constraint {
    /// Left variable: `x - y <= c`.
    pub x: usize,
    /// Right variable.
    pub y: usize,
    /// Constant bound.
    pub c: i64,
}

/// Solve a conjunction of difference constraints.
///
/// Returns `Some(assignment)` if satisfiable, where `assignment[i]` is a value
/// for variable `i` (variables are indexed from `0`, and the count is inferred
/// as one more than the largest index occurring in any constraint).
///
/// Returns `None` if unsatisfiable: then the constraint graph contains a
/// negative cycle, an arithmetic contradiction.
///
/// Each constraint `x - y <= c` becomes an edge `y -> x` of weight `c`, since
/// `x <= y + c`. A super-source with zero-weight edges to every variable
/// initialises Bellman--Ford; a negative cycle makes the relaxation fail to
/// converge, which is reported as unsatisfiability.
pub fn solve(constraints: &[Constraint]) -> Option<Vec<i64>> {
    let n = constraints
        .iter()
        .map(|c| c.x.max(c.y))
        .max()
        .map(|m| m + 1)
        .unwrap_or(0);

    // Edges y -> x of weight c, plus a super-source n -> i of weight 0.
    let mut edges: Vec<(usize, usize, i64)> =
        constraints.iter().map(|c| (c.y, c.x, c.c)).collect();
    for i in 0..n {
        edges.push((n, i, 0));
    }

    const INF: i64 = i64::MAX / 4;
    let mut dist = vec![INF; n + 1];
    dist[n] = 0;

    // Relax |V| - 1 = n times.
    for _ in 0..n {
        let mut changed = false;
        for &(u, v, w) in &edges {
            if dist[u] != INF && dist[u] + w < dist[v] {
                dist[v] = dist[u] + w;
                changed = true;
            }
        }
        if !changed {
            break;
        }
    }

    // A further relaxation detects a negative cycle.
    for &(u, v, w) in &edges {
        if dist[u] != INF && dist[u] + w < dist[v] {
            return None;
        }
    }

    Some(dist[..n].to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn satisfiable_bounded_difference() {
        // 4 <= x - y <= 5
        let cs = vec![
            Constraint { x: 0, y: 1, c: 5 },
            Constraint { x: 1, y: 0, c: -4 },
        ];
        let a = solve(&cs).unwrap();
        assert!(a[0] - a[1] <= 5);
        assert!(a[1] - a[0] <= -4);
    }

    #[test]
    fn satisfiable_chain() {
        // x - y <= 2, y - z <= 3  =>  x - z <= 5
        let cs = vec![
            Constraint { x: 0, y: 1, c: 2 },
            Constraint { x: 1, y: 2, c: 3 },
        ];
        let a = solve(&cs).unwrap();
        assert!(a[0] - a[1] <= 2);
        assert!(a[1] - a[2] <= 3);
    }

    #[test]
    fn unsatisfiable_negative_cycle() {
        // x - y <= 1, y - z <= -1, z - x <= -1  =>  cycle weight -1 < 0
        let cs = vec![
            Constraint { x: 0, y: 1, c: 1 },
            Constraint { x: 1, y: 2, c: -1 },
            Constraint { x: 2, y: 0, c: -1 },
        ];
        assert!(solve(&cs).is_none());
    }

    #[test]
    fn equality_pair() {
        // x - y <= 3 and y - x <= -3  =>  x - y == 3
        let cs = vec![
            Constraint { x: 0, y: 1, c: 3 },
            Constraint { x: 1, y: 0, c: -3 },
        ];
        let a = solve(&cs).unwrap();
        assert_eq!(a[0] - a[1], 3);
    }
}
