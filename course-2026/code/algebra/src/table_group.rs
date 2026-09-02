//! A finite group given only by its Cayley table.
//!
//! Here a group is pure data: a set of elements labelled `0..n` plus a
//! multiplication table.
//! Nothing about the operation is known except the table, and
//! [`TableGroup::is_group`] checks the axioms against the data.

/// A finite group specified by data: elements `0..n` and a table
/// `table[i][j] = k`, where `k` is the label of the product of `i` and `j`.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TableGroup {
    /// Number of elements.
    pub n: usize,
    /// `table[i][j]` is the product of elements `i` and `j`.
    pub table: Vec<Vec<usize>>,
}

impl TableGroup {
    /// Closure: every entry is a valid label `0..n`.
    pub fn is_closed(&self) -> bool {
        self.table.iter().flatten().all(|&k| k < self.n)
    }

    /// Associativity: `(i·j)·k == i·(j·k)` for all triples.
    pub fn is_associative(&self) -> bool {
        for i in 0..self.n {
            for j in 0..self.n {
                for k in 0..self.n {
                    if self.table[self.table[i][j]][k] != self.table[i][self.table[j][k]] {
                        return false;
                    }
                }
            }
        }
        true
    }

    /// The identity element, if one exists: `e·i = i·e = i` for all `i`.
    pub fn identity(&self) -> Option<usize> {
        (0..self.n).find(|&e| (0..self.n).all(|i| self.table[e][i] == i && self.table[i][e] == i))
    }

    /// Whether every element has a two-sided inverse.
    pub fn has_inverses(&self) -> bool {
        match self.identity() {
            None => false,
            Some(e) => (0..self.n)
                .all(|i| (0..self.n).any(|j| self.table[i][j] == e && self.table[j][i] == e)),
        }
    }

    /// Whether the table defines a group: closed, associative, with an
    /// identity and inverses.
    pub fn is_group(&self) -> bool {
        self.is_closed()
            && self.is_associative()
            && self.identity().is_some()
            && self.has_inverses()
    }

    /// Whether the group is abelian: `i·j == j·i` for all pairs.
    pub fn is_abelian(&self) -> bool {
        for i in 0..self.n {
            for j in 0..self.n {
                if self.table[i][j] != self.table[j][i] {
                    return false;
                }
            }
        }
        true
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn z2_table_is_a_group() {
        // Z_2 under addition: 0+0=0, 0+1=1, 1+0=1, 1+1=0.
        let z2 = TableGroup {
            n: 2,
            table: vec![vec![0, 1], vec![1, 0]],
        };
        assert!(z2.is_group());
        assert!(z2.is_abelian());
        assert_eq!(z2.identity(), Some(0));
    }

    #[test]
    fn constant_table_is_not_a_group() {
        // a·b = 0 always: closed and associative, but no identity.
        let c = TableGroup {
            n: 2,
            table: vec![vec![0, 0], vec![0, 0]],
        };
        assert!(c.is_closed());
        assert!(c.is_associative());
        assert_eq!(c.identity(), None);
        assert!(!c.is_group());
    }
}
