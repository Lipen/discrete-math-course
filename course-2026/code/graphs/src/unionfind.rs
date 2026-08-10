//! Система непересекающихся множеств (union-find / DSU).
//!
//! Хранит разбиение вершин на компоненты и умеет две операции:
//! `find(x)` --- представитель компоненты вершины `x`, `union(a, b)` ---
//! объединить компоненты `a` и `b`. Используется в алгоритме Краскала
//! (минимальное остовное дерево) и при проверке неориентированного графа
//! на циклы: ребро соединяет вершины, которые уже в одной компоненте, ---
//! значит, в графе есть цикл.

/// Разбиение множества `{0, 1, ..., n-1}` на компоненты.
pub struct UnionFind {
    /// `parent[x]` --- родитель вершины `x` в лесe представителей.
    parent: Vec<usize>,
    /// `size[x]` --- размер компоненты, если `x` --- её представитель.
    size: Vec<usize>,
}

impl UnionFind {
    /// Новое разбиение: каждая вершина --- отдельная компонента.
    pub fn new(n: usize) -> Self {
        UnionFind {
            parent: (0..n).collect(),
            size: vec![1; n],
        }
    }

    /// Представитель компоненты вершины `x` (с сжатием пути).
    pub fn find(&mut self, x: usize) -> usize {
        if self.parent[x] != x {
            self.parent[x] = self.find(self.parent[x]);
        }
        self.parent[x]
    }

    /// Объединить компоненты вершин `a` и `b`.
    ///
    /// Возвращает `false`, если вершины уже были в одной компоненте
    /// (и ничего не изменилось), и `true`, если компоненты объединились.
    pub fn union(&mut self, a: usize, b: usize) -> bool {
        let ra = self.find(a);
        let rb = self.find(b);
        if ra == rb {
            return false;
        }
        // Меньшую компоненту подвешиваем к большей --- дерево остаётся низким.
        if self.size[ra] < self.size[rb] {
            self.parent[ra] = rb;
            self.size[rb] += self.size[ra];
        } else {
            self.parent[rb] = ra;
            self.size[ra] += self.size[rb];
        }
        true
    }

    /// В одной ли компоненте вершины `a` и `b`.
    pub fn same(&mut self, a: usize, b: usize) -> bool {
        self.find(a) == self.find(b)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn initially_everything_is_separate() {
        let mut uf = UnionFind::new(5);
        for i in 0..5 {
            for j in 0..5 {
                assert_eq!(uf.same(i, j), i == j);
            }
        }
    }

    #[test]
    fn union_merges_components() {
        let mut uf = UnionFind::new(6);
        assert!(uf.union(0, 1));
        assert!(uf.union(2, 3));
        assert!(uf.union(1, 2));
        assert!(uf.same(0, 3));
        assert!(!uf.same(0, 4));
        assert!(!uf.union(0, 3)); // уже в одной компоненте
    }

    #[test]
    fn find_is_representative_after_path_compression() {
        let mut uf = UnionFind::new(4);
        uf.union(0, 1);
        uf.union(2, 3);
        uf.union(1, 3);
        let r = uf.find(0);
        assert_eq!(uf.find(1), r);
        assert_eq!(uf.find(2), r);
        assert_eq!(uf.find(3), r);
    }
}
