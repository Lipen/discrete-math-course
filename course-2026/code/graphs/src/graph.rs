//! Модель графа: вершины, рёбра, степени.
//!
//! `Graph` -- простая структура для курса: никаких дженериков, никаких
//! трейтов. Вершины нумеруются числами `0..n` и могут иметь имена; у каждого
//! ребра есть вес (по умолчанию 1). Граф хранит данные дважды:
//!
//! - `edges` -- список всех рёбер (его читают взвешенные алгоритмы:
//!   Дейкстра, Краскал, Беллман--Форд);
//! - `adj` -- списки смежности (их читают обходы BFS/DFS).
//!
//! Поля открыты: структуру можно читать и собирать руками -- так проще
//! понять, как граф устроен изнутри.

/// Ребро графа.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Edge {
    /// Вершина, из которой ребро выходит.
    pub from: usize,
    /// Вершина, в которую ребро входит.
    pub to: usize,
    /// Вес ребра (целое число; алгоритмы, которым нужна неотрицательность,
    /// сами это документируют).
    pub weight: i64,
}

/// Граф: ориентированный или неориентированный, с именами вершин и весами рёбер.
///
/// Методы и алгоритмы, принимающие номера вершин, паникуют, если номер вне
/// отрезка `0..node_count()`; номера берутся из `add_node` и `add_edge`.
#[derive(Debug, Clone)]
pub struct Graph {
    /// `true` -- ориентированный граф (рёбра -- стрелки), `false` -- неориентированный.
    pub directed: bool,
    /// Имя вершины `i` (для вывода на экран и для рисунков).
    pub names: Vec<String>,
    /// Списки смежности: `adj[u]` содержит пары (сосед, номер ребра).
    ///
    /// Для неориентированного графа ребро попадает в списки обеих вершин,
    /// для ориентированного -- только в список начальной. Петля (ребро
    /// `u -> u`) лежит в списке один раз.
    pub adj: Vec<Vec<(usize, usize)>>,
    /// Все рёбра графа; `edges[e]` -- ребро с номером `e`.
    pub edges: Vec<Edge>,
}

impl Graph {
    /// Пустой неориентированный граф.
    pub fn undirected() -> Self {
        Self::new(false)
    }

    /// Пустой ориентированный граф.
    pub fn directed() -> Self {
        Self::new(true)
    }

    fn new(directed: bool) -> Self {
        Graph {
            directed,
            names: Vec::new(),
            adj: Vec::new(),
            edges: Vec::new(),
        }
    }

    /// Добавить вершину с именем; возвращает её номер.
    pub fn add_node(&mut self, name: impl Into<String>) -> usize {
        let id = self.names.len();
        self.names.push(name.into());
        self.adj.push(Vec::new());
        id
    }

    /// Добавить ребро с весом 1; возвращает номер ребра.
    pub fn add_edge(&mut self, from: usize, to: usize) -> usize {
        self.add_weighted_edge(from, to, 1)
    }

    /// Добавить ребро с весом; возвращает номер ребра.
    pub fn add_weighted_edge(&mut self, from: usize, to: usize, weight: i64) -> usize {
        let id = self.edges.len();
        self.edges.push(Edge { from, to, weight });
        self.adj[from].push((to, id));
        if !self.directed && from != to {
            self.adj[to].push((from, id));
        }
        id
    }

    /// Добавить несколько рёбер с весом 1: `add_edges(&[(0, 1), (1, 2)])`.
    pub fn add_edges(&mut self, pairs: &[(usize, usize)]) {
        for &(from, to) in pairs {
            self.add_edge(from, to);
        }
    }

    /// Сколько в графе вершин.
    pub fn node_count(&self) -> usize {
        self.names.len()
    }

    /// Сколько в графе рёбер.
    pub fn edge_count(&self) -> usize {
        self.edges.len()
    }

    /// Ориентированный ли граф.
    pub fn is_directed(&self) -> bool {
        self.directed
    }

    /// Имя вершины `u`.
    pub fn node_name(&self, u: usize) -> &str {
        &self.names[u]
    }

    /// Соседи вершины `u`: пары (сосед, номер ребра).
    pub fn neighbors(&self, u: usize) -> &[(usize, usize)] {
        &self.adj[u]
    }

    /// Степень вершины `u` -- число соседей.
    ///
    /// Для ориентированного графа это полустепень исхода (число рёбер,
    /// выходящих из `u`).
    pub fn degree(&self, u: usize) -> usize {
        self.adj[u].len()
    }

    /// Вес ребра с номером `e`.
    pub fn edge_weight(&self, e: usize) -> i64 {
        self.edges[e].weight
    }

    /// Есть ли ребро из `u` в `v` (для неориентированного графа -- хотя бы в одну сторону).
    pub fn adjacent(&self, u: usize, v: usize) -> bool {
        self.adj[u].iter().any(|&(w, _)| w == v)
    }

    /// Степени всех вершин (для леммы о рукопожатиях и гистограмм).
    pub fn degrees(&self) -> Vec<usize> {
        (0..self.node_count()).map(|u| self.degree(u)).collect()
    }

    /// Случайный неориентированный граф Эрдёша--Реньи $G(n, p)$.
    ///
    /// `n` вершин, каждое ребро появляется независимо с вероятностью `p`
    /// (которая должна лежать в отрезке `[0, 1]`).
    /// `seed` задаёт генератор, так что один и тот же seed даёт один и тот же
    /// граф (для воспроизводимых примеров).
    pub fn erdos_renyi(n: usize, p: f64, seed: u64) -> Graph {
        assert!((0.0..=1.0).contains(&p), "p должна быть в отрезке [0, 1]");
        let mut g = Graph::undirected();
        for i in 0..n {
            g.add_node(i.to_string());
        }
        let mut rng = XorShift64::new(seed);
        for u in 0..n {
            for v in (u + 1)..n {
                if rng.next_f64() < p {
                    g.add_edge(u, v);
                }
            }
        }
        g
    }
}

/// Крошечный генератор случайных чисел (xorshift64), чтобы не тащить
/// внешние зависимости. Хорош для учебных примеров, не для криптографии.
struct XorShift64(u64);

impl XorShift64 {
    fn new(seed: u64) -> Self {
        XorShift64(seed | 1) // ноль запрещён
    }

    fn next_u64(&mut self) -> u64 {
        let mut x = self.0;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        self.0 = x;
        x
    }

    /// Число из отрезка [0, 1).
    fn next_f64(&mut self) -> f64 {
        (self.next_u64() >> 11) as f64 / (1u64 << 53) as f64
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn undirected_edge_lands_in_both_lists() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        let b = g.add_node("b");
        let e = g.add_edge(a, b);
        assert_eq!(g.neighbors(a), &[(b, e)]);
        assert_eq!(g.neighbors(b), &[(a, e)]);
        assert_eq!(g.degree(a), 1);
        assert_eq!(g.degree(b), 1);
        assert!(g.adjacent(a, b));
        assert!(g.adjacent(b, a));
    }

    #[test]
    fn directed_edge_lands_only_in_source_list() {
        let mut g = Graph::directed();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_edge(a, b);
        assert_eq!(g.neighbors(a).len(), 1);
        assert_eq!(g.neighbors(b).len(), 0);
        assert!(g.adjacent(a, b));
        assert!(!g.adjacent(b, a));
    }

    #[test]
    fn self_loop_appears_once() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        g.add_edge(a, a);
        assert_eq!(g.neighbors(a), &[(a, 0)]);
        assert_eq!(g.degree(a), 1);
    }

    #[test]
    fn weighted_edges_keep_weights() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        let b = g.add_node("b");
        let e = g.add_weighted_edge(a, b, 7);
        assert_eq!(g.edge_weight(e), 7);
    }

    #[test]
    fn handshake_lemma_even_sum() {
        let mut g = Graph::undirected();
        for i in 0..5 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (0, 2), (1, 2), (2, 3), (3, 4)]);
        let sum: usize = g.degrees().iter().sum();
        assert_eq!(sum, 2 * g.edge_count());
    }

    #[test]
    fn erdos_renyi_deterministic() {
        let g1 = Graph::erdos_renyi(10, 0.3, 42);
        let g2 = Graph::erdos_renyi(10, 0.3, 42);
        assert_eq!(g1.edges, g2.edges);
        assert_eq!(g1.node_count(), 10);
        assert!(!g1.directed);
    }

    #[test]
    fn erdos_renyi_extremes() {
        // p = 0: рёбер нет; p = 1: полный граф.
        assert_eq!(Graph::erdos_renyi(5, 0.0, 1).edge_count(), 0);
        let complete = Graph::erdos_renyi(5, 1.0, 1);
        assert_eq!(complete.edge_count(), 5 * 4 / 2);
    }
}
