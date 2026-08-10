//! Алгоритмы на графах из главы про графы.
//!
//! Каждый алгоритм -- свободная функция, принимающая `&Graph`.
//! Модель отделена от алгоритмов: один и тот же граф можно скормить
//! любому числу функций.
//!
//! Сложность и идея каждого алгоритма описаны в его документации;
//! рабочие демонстрации -- в `examples/`.

use std::cmp::Reverse;
use std::collections::{BinaryHeap, VecDeque};

use crate::graph::Graph;
use crate::unionfind::UnionFind;

/// Результат обхода в ширину.
#[derive(Debug)]
pub struct BfsResult {
    /// Вершины в порядке посещения.
    pub order: Vec<usize>,
    /// Расстояние от стартовой вершины; `usize::MAX` -- вершина недостижима
    /// (сентинел, как в примере главы; во взвешенных алгоритмах Дейкстры и
    /// Беллмана--Форда недостижимость обозначается `None`).
    pub dist: Vec<usize>,
    /// Предок в BFS-дереве; `None` для стартовой вершины и недостижимых.
    pub parent: Vec<Option<usize>>,
}

/// Обход в ширину (BFS) от вершины `start`.
///
/// Обходит граф по слоям: сначала вершины на расстоянии 1, затем 2, и так
/// далее. Работает за $O(V + E)$ и находит кратчайшие пути в невзвешенном
/// графе (веса игнорируются).
pub fn bfs(g: &Graph, start: usize) -> BfsResult {
    let n = g.node_count();
    let mut order = Vec::with_capacity(n);
    let mut dist = vec![usize::MAX; n];
    let mut parent = vec![None; n];

    let mut q = VecDeque::new();
    dist[start] = 0;
    q.push_back(start);

    while let Some(u) = q.pop_front() {
        order.push(u);
        for &(v, _) in &g.adj[u] {
            if dist[v] == usize::MAX {
                dist[v] = dist[u] + 1;
                parent[v] = Some(u);
                q.push_back(v);
            }
        }
    }
    BfsResult {
        order,
        dist,
        parent,
    }
}

/// Результат обхода в глубину.
#[derive(Debug)]
pub struct DfsResult {
    /// Время входа в вершину (1-based; 0 -- вершина не посещалась в этом обходе).
    pub pre: Vec<usize>,
    /// Время выхода из вершины.
    pub post: Vec<usize>,
    /// Предок в DFS-лесе; `None` для корней.
    pub parent: Vec<Option<usize>>,
    /// Вершины в порядке первого посещения.
    pub order: Vec<usize>,
    /// Вершины в порядке завершения обработки.
    ///
    /// Обратный порядок -- топологический порядок вершин DAG, и именно он
    /// нужен алгоритму Косарайю для поиска компонент сильной связности.
    pub finish: Vec<usize>,
}

/// Обход в глубину (DFS) по всем вершинам графа.
///
/// Идёт «вглубь»: рекурсивно исследует первого непосещённого соседа, затем
/// его соседа, и так далее; времена входа `pre` и выхода `post` дают
/// структурную информацию о рёбрах (прямые, обратные, перекрёстные).
/// Работает за $O(V + E)$. Рекурсивный: для очень больших графов может
/// переполнить стек вызовов.
pub fn dfs(g: &Graph) -> DfsResult {
    let n = g.node_count();
    let mut res = DfsResult {
        pre: vec![0; n],
        post: vec![0; n],
        parent: vec![None; n],
        order: Vec::with_capacity(n),
        finish: Vec::with_capacity(n),
    };
    let mut time = 0usize;

    fn visit(u: usize, g: &Graph, res: &mut DfsResult, time: &mut usize) {
        *time += 1;
        res.pre[u] = *time;
        res.order.push(u);
        for &(v, _) in &g.adj[u] {
            if res.pre[v] == 0 {
                res.parent[v] = Some(u);
                visit(v, g, res, time);
            }
        }
        *time += 1;
        res.post[u] = *time;
        res.finish.push(u);
    }

    for start in 0..n {
        if res.pre[start] == 0 {
            visit(start, g, &mut res, &mut time);
        }
    }
    res
}

/// Число компонент связности и номер компоненты каждой вершины.
///
/// Для ориентированного графа считаются *слабые* компоненты: направление
/// рёбер игнорируется.
pub fn connected_components(g: &Graph) -> (usize, Vec<usize>) {
    let n = g.node_count();
    let mut uf = UnionFind::new(n);
    for e in &g.edges {
        uf.union(e.from, e.to);
    }

    // Представитель -> номер компоненты (0, 1, 2, ...).
    let mut label_of_root: Vec<Option<usize>> = vec![None; n];
    let mut comp = Vec::with_capacity(n);
    let mut count = 0;
    for u in 0..n {
        let root = uf.find(u);
        if label_of_root[root].is_none() {
            label_of_root[root] = Some(count);
            count += 1;
        }
        comp.push(label_of_root[root].unwrap());
    }
    (count, comp)
}

/// Компоненты сильной связности (алгоритм Косарайю), только для ориентированных графов.
///
/// Два прохода: DFS на исходном графе даёт порядок завершения, DFS на
/// обратном графе в обратном порядке -- сами компоненты.
/// Для неориентированного графа используйте [`connected_components`]:
/// передача такого графа сюда -- ошибка, и функция на неё паникует.
pub fn strongly_connected_components(g: &Graph) -> Vec<Vec<usize>> {
    assert!(
        g.directed,
        "strongly_connected_components предназначен для ориентированных графов"
    );
    let n = g.node_count();

    // 1. Обратный граф: rev[v] -- вершины, из которых идут рёбра в v.
    let mut rev = vec![Vec::new(); n];
    for e in &g.edges {
        rev[e.to].push(e.from);
    }

    // 2. DFS на обратном графе в порядке убывания времени выхода.
    let finish = dfs(g).finish;
    let mut visited = vec![false; n];
    let mut sccs = Vec::new();
    for &u in finish.iter().rev() {
        if !visited[u] {
            let mut comp = Vec::new();
            collect(u, &rev, &mut visited, &mut comp);
            sccs.push(comp);
        }
    }
    sccs
}

/// Собрать всю достижимую из `u` область обратного графа (одну компоненту).
fn collect(u: usize, rev: &[Vec<usize>], visited: &mut [bool], comp: &mut Vec<usize>) {
    visited[u] = true;
    comp.push(u);
    for &v in &rev[u] {
        if !visited[v] {
            collect(v, rev, visited, comp);
        }
    }
}

/// Есть ли в графе цикл.
///
/// Неориентированный граф проверяется системой непересекающихся множеств
/// (ребро, соединяющее вершины одной компоненты, замыкает цикл);
/// ориентированный -- DFS с цветами (серый цвет означает ребро в текущий
/// стек рекурсии).
pub fn is_cyclic(g: &Graph) -> bool {
    if !g.directed {
        let mut uf = UnionFind::new(g.node_count());
        for e in &g.edges {
            if !uf.union(e.from, e.to) {
                return true;
            }
        }
        return false;
    }

    // Цвета: 0 = белая (не посещена), 1 = серая (в стеке), 2 = чёрная (готова).
    let n = g.node_count();
    let mut color = vec![0u8; n];

    fn has_cycle_from(u: usize, g: &Graph, color: &mut [u8]) -> bool {
        color[u] = 1;
        for &(v, _) in &g.adj[u] {
            if color[v] == 1 {
                return true; // ребро в предка из текущего стека
            }
            if color[v] == 0 && has_cycle_from(v, g, color) {
                return true;
            }
        }
        color[u] = 2;
        false
    }

    for u in 0..n {
        if color[u] == 0 && has_cycle_from(u, g, &mut color) {
            return true;
        }
    }
    false
}

/// Топологическая сортировка (алгоритм Кана), для ориентированных ациклических графов.
///
/// Возвращает `None`, если в графе есть цикл (топологического порядка нет).
/// Порядок таков: каждое ребро идёт из вершины, стоящей раньше, в вершину,
/// стоящую позже. Для неориентированного графа сортировка не определена,
/// и функция на него паникует.
pub fn topological_sort(g: &Graph) -> Option<Vec<usize>> {
    assert!(
        g.directed,
        "topological_sort предназначен для ориентированных графов"
    );
    let n = g.node_count();

    // Полустепень захода: сколько рёбер входит в каждую вершину.
    let mut indegree = vec![0usize; n];
    for e in &g.edges {
        indegree[e.to] += 1;
    }

    let mut q: VecDeque<usize> = (0..n).filter(|&u| indegree[u] == 0).collect();
    let mut order = Vec::with_capacity(n);
    while let Some(u) = q.pop_front() {
        order.push(u);
        for &(v, _) in &g.adj[u] {
            indegree[v] -= 1;
            if indegree[v] == 0 {
                q.push_back(v);
            }
        }
    }

    if order.len() == n {
        Some(order)
    } else {
        None // остались вершины с ненулевой полустепенью -- цикл
    }
}

/// Расстояния от источника и предшественники на кратчайших путях.
///
/// Пара `(dist, prev)`: `dist[v]` -- длина кратчайшего пути до `v`
/// (`None` -- недостижима), `prev[v]` -- предыдущая вершина на этом пути.
pub type ShortestPaths = (Vec<Option<i64>>, Vec<Option<usize>>);

/// Кратчайшие пути от `start` (алгоритм Дейкстры).
///
/// Веса рёбер должны быть неотрицательными (в отладочной сборке это
/// проверяется). Возвращает [`ShortestPaths`]: расстояние до каждой вершины
/// и предшественника на кратчайшем пути (для восстановления самого пути).
/// Работает за $O((V + E) log V)$.
pub fn dijkstra(g: &Graph, start: usize) -> ShortestPaths {
    debug_assert!(
        g.edges.iter().all(|e| e.weight >= 0),
        "Дейкстра требует неотрицательных весов рёбер"
    );
    let n = g.node_count();
    let mut dist: Vec<Option<i64>> = vec![None; n];
    let mut prev = vec![None; n];

    // Куча в Rust -- максимальная, поэтому храним (расстояние, вершину)
    // внутри Reverse: так первым извлекается минимум. Вершина попадает в
    // кучу заново при каждом улучшении её расстояния, поэтому старых
    // записей в куче больше, чем вершин; устаревшие отбрасываются ниже.
    let mut heap = BinaryHeap::new();
    dist[start] = Some(0);
    heap.push(Reverse((0, start)));

    while let Some(Reverse((d, u))) = heap.pop() {
        if dist[u] != Some(d) {
            continue; // устаревшая запись: до u уже нашли путь короче
        }
        for &(v, e) in &g.adj[u] {
            // Переполнение i64 трактуем как «путь бесконечной длины».
            let Some(nd) = d.checked_add(g.edge_weight(e)) else {
                continue;
            };
            // dist[v] ещё не найден или новый путь короче.
            let shorter = match dist[v] {
                None => true,
                Some(old) => nd < old,
            };
            if shorter {
                dist[v] = Some(nd);
                prev[v] = Some(u);
                heap.push(Reverse((nd, v)));
            }
        }
    }
    (dist, prev)
}

/// Кратчайшие пути от `start` (алгоритм Беллмана--Форда).
///
/// Работает и с отрицательными весами: путь не становится короче при
/// добавлении ребра только в Дейкстре, а Беллман--Форд за $V - 1$ раундов
/// релаксации всех рёбер перебирает пути любой длины. Не переживает только
/// отрицательные циклы: если из `start` достижим такой цикл, возвращает
/// `None` (недостижимый цикл на результат не влияет). За $k$ раундов
/// корректны пути из не более чем $k$ рёбер. Сложность $O(V E)$.
pub fn bellman_ford(g: &Graph, start: usize) -> Option<ShortestPaths> {
    let n = g.node_count();
    let mut dist: Vec<Option<i64>> = vec![None; n];
    let mut prev = vec![None; n];
    dist[start] = Some(0);

    for _ in 0..n.saturating_sub(1) {
        let mut changed = false;
        for e in &g.edges {
            if let Some(du) = dist[e.from] {
                let Some(nd) = du.checked_add(e.weight) else {
                    continue;
                };
                let shorter = match dist[e.to] {
                    None => true,
                    Some(old) => nd < old,
                };
                if shorter {
                    dist[e.to] = Some(nd);
                    prev[e.to] = Some(e.from);
                    changed = true;
                }
            }
        }
        if !changed {
            break;
        }
    }

    // Ещё один раунд: если что-то улучшилось -- есть отрицательный цикл.
    for e in &g.edges {
        if let Some(du) = dist[e.from] {
            if let Some(nd) = du.checked_add(e.weight) {
                let shorter = match dist[e.to] {
                    None => true,
                    Some(old) => nd < old,
                };
                if shorter {
                    return None;
                }
            }
        }
    }
    Some((dist, prev))
}

/// Минимальное остовное дерево (алгоритм Краскала), для неориентированных графов.
///
/// Сортируем рёбра по весу и добавляем каждое, которое соединяет две разные
/// компоненты (проверка системой непересекающихся множеств). Возвращает
/// номера рёбер остовного дерева; для несвязного графа -- остовный лес
/// (дерево каждой компоненты).
pub fn min_spanning_tree(g: &Graph) -> Vec<usize> {
    assert!(
        !g.directed,
        "min_spanning_tree предназначен для неориентированных графов"
    );

    let mut order: Vec<usize> = (0..g.edge_count()).collect();
    order.sort_by_key(|&e| g.edges[e].weight);

    let mut uf = UnionFind::new(g.node_count());
    let mut tree = Vec::new();
    for e in order {
        let edge = &g.edges[e];
        if uf.union(edge.from, edge.to) {
            tree.push(e);
        }
    }
    tree
}

/// Эйлеров путь: маршрут, проходящий каждое ребро ровно один раз.
///
/// Возвращает `None`, если такого пути нет. Критерий Эйлера: у
/// неориентированного графа либо все степени чётны (тогда путь -- цикл,
/// начинается где угодно), либо ровно две вершины имеют нечётную степень
/// (тогда путь начинается в одной из них). Для ориентированного графа
/// аналогично, но по разности полустепеней исхода и захода. Сам путь строится
/// алгоритмом Иерархольцера; если рёбра не съедены до конца -- граф
/// несвязен, и ответа нет.
pub fn find_eulerian_path(g: &Graph) -> Option<Vec<usize>> {
    let n = g.node_count();
    if g.edge_count() == 0 {
        return if n > 0 { Some(vec![0]) } else { None };
    }

    // 1. Критерий Эйлера: в какой вершине начинать, существует ли путь вообще.
    let start = if g.directed {
        let mut out = vec![0usize; n];
        let mut inn = vec![0usize; n];
        for e in &g.edges {
            out[e.from] += 1;
            inn[e.to] += 1;
        }
        let mut start = None;
        let mut end = None;
        for u in 0..n {
            let diff = out[u] as i64 - inn[u] as i64;
            match diff {
                0 => {}
                1 => {
                    if start.is_some() {
                        return None;
                    }
                    start = Some(u);
                }
                -1 => {
                    if end.is_some() {
                        return None;
                    }
                    end = Some(u);
                }
                _ => return None,
            }
        }
        match start {
            Some(u) => u,
            None => (0..n).find(|&u| g.degree(u) > 0)?,
        }
    } else {
        // Петля (u -> u) в модели даёт степень 1, а критерий Эйлера
        // требует, чтобы она давала 2: добавляем петли к степени.
        let mut odd = None;
        let mut odd_count = 0;
        for u in 0..n {
            let loops = g.edges.iter().filter(|e| e.from == u && e.to == u).count();
            if (g.degree(u) + loops) % 2 == 1 {
                odd_count += 1;
                odd.get_or_insert(u);
            }
        }
        if odd_count != 0 && odd_count != 2 {
            return None;
        }
        match odd {
            Some(u) => u,
            None => (0..n).find(|&u| g.degree(u) > 0)?,
        }
    };

    // 2. Иерархольцер: обход, съедающий рёбра.
    //    Для неориентированного графа ребро лежит в списках обеих вершин;
    //    `used` не даёт съесть его дважды.
    let adj = g.adj.clone();
    let mut next = vec![0usize; n]; // следующая нерассмотренная позиция в списке
    let mut used = vec![false; g.edge_count()];
    let mut stack = vec![start];
    let mut trail = Vec::new();

    while let Some(&u) = stack.last() {
        // Пропускаем уже съеденные рёбра. adj[u][next[u]] -- пара
        // (сосед, номер ребра); если ребро этой записи уже использовано
        // (с другого конца), запись больше не рассматривается.
        while next[u] < adj[u].len() && used[adj[u][next[u]].1] {
            next[u] += 1;
        }
        if next[u] < adj[u].len() {
            let (v, e) = adj[u][next[u]];
            next[u] += 1;
            used[e] = true;
            stack.push(v);
        } else {
            trail.push(u);
            stack.pop();
        }
    }

    // 3. Все ли рёбра съедены? Если нет -- ребра лежат в другой компоненте.
    if used.iter().any(|&x| !x) {
        return None;
    }
    trail.reverse();
    Some(trail)
}

/// Двудольный ли граф; если да -- раскраска вершин в два цвета (0 и 1).
///
/// Раскраска строится обходом: соседи получают противоположный цвет; если
/// сосед уже окрашен в тот же цвет -- в графе есть нечётный цикл, и граф
/// не двудольный (`None`).
pub fn is_bipartite(g: &Graph) -> Option<Vec<usize>> {
    let n = g.node_count();
    let mut color = vec![None; n];
    let mut q = VecDeque::new();

    for start in 0..n {
        if color[start].is_some() {
            continue;
        }
        color[start] = Some(0);
        q.push_back(start);
        while let Some(u) = q.pop_front() {
            let cu = color[u].unwrap();
            for &(v, _) in &g.adj[u] {
                match color[v] {
                    None => {
                        color[v] = Some(1 - cu);
                        q.push_back(v);
                    }
                    Some(cv) if cv == cu => return None,
                    _ => {}
                }
            }
        }
    }
    Some(color.into_iter().map(|c| c.unwrap()).collect())
}

/// Мосты -- рёбра, удаление которых увеличивает число компонент связности.
///
/// Алгоритм Тарьяна: обход в глубину с временами входа `tin` и величинами
/// `low` (самое раннее время входа, достижимое по обратным рёбрам).
/// Ребро `(u, v)` -- мост, если $"low"(v) > "tin"(u)`. Только для
/// неориентированных графов; параллельные рёбра мостами не считаются.
/// Рекурсивный: для очень больших графов может переполнить стек вызовов.
pub fn bridges(g: &Graph) -> Vec<(usize, usize)> {
    assert!(
        !g.directed,
        "bridges предназначен для неориентированных графов"
    );
    let n = g.node_count();
    let mut tin = vec![0usize; n];
    let mut low = vec![0usize; n];
    let mut timer = 0usize;
    let mut result = Vec::new();

    #[allow(clippy::too_many_arguments)] // рекурсивный обход Тарьяна: параметры -- состояние обхода
    fn visit(
        u: usize,
        parent_edge: Option<usize>,
        g: &Graph,
        tin: &mut [usize],
        low: &mut [usize],
        timer: &mut usize,
        result: &mut Vec<(usize, usize)>,
    ) {
        *timer += 1;
        tin[u] = *timer;
        low[u] = *timer;
        for &(v, e) in &g.adj[u] {
            if Some(e) == parent_edge {
                continue; // то же ребро, по которому пришли, -- не обратное
            }
            if tin[v] != 0 {
                low[u] = low[u].min(tin[v]); // обратное ребро в предка
            } else {
                visit(v, Some(e), g, tin, low, timer, result);
                low[u] = low[u].min(low[v]);
                if low[v] > tin[u] {
                    result.push((u.min(v), u.max(v)));
                }
            }
        }
    }

    for start in 0..n {
        if tin[start] == 0 {
            visit(start, None, g, &mut tin, &mut low, &mut timer, &mut result);
        }
    }
    result.sort_unstable(); // детерминированный порядок для вывода
    result
}

/// Точки сочленения -- вершины, удаление которых увеличивает число компонент.
///
/// Тот же обход Тарьяна: некорневая вершина `u` -- точка сочленения, если
/// у неё есть ребёнок `v` с $"low"(v) >= "tin"(u)`; корень DFS-дерева --
/// если у него больше одного ребёнка. Только для неориентированных графов.
/// Рекурсивный: для очень больших графов может переполнить стек вызовов.
pub fn articulation_points(g: &Graph) -> Vec<usize> {
    assert!(
        !g.directed,
        "articulation_points предназначен для неориентированных графов"
    );
    let n = g.node_count();
    let mut tin = vec![0usize; n];
    let mut low = vec![0usize; n];
    let mut timer = 0usize;
    let mut is_art = vec![false; n];

    #[allow(clippy::too_many_arguments)] // рекурсивный обход Тарьяна: параметры -- состояние обхода
    fn visit(
        u: usize,
        parent_edge: Option<usize>,
        root: usize,
        g: &Graph,
        tin: &mut [usize],
        low: &mut [usize],
        timer: &mut usize,
        is_art: &mut [bool],
    ) {
        *timer += 1;
        tin[u] = *timer;
        low[u] = *timer;
        let mut children = 0usize;
        for &(v, e) in &g.adj[u] {
            if Some(e) == parent_edge {
                continue;
            }
            if tin[v] != 0 {
                low[u] = low[u].min(tin[v]);
            } else {
                visit(v, Some(e), root, g, tin, low, timer, is_art);
                low[u] = low[u].min(low[v]);
                if low[v] >= tin[u] && u != root {
                    is_art[u] = true;
                }
                children += 1;
            }
        }
        if u == root && children > 1 {
            is_art[u] = true;
        }
    }

    for start in 0..n {
        if tin[start] == 0 {
            visit(
                start,
                None,
                start,
                g,
                &mut tin,
                &mut low,
                &mut timer,
                &mut is_art,
            );
        }
    }
    (0..n).filter(|&u| is_art[u]).collect()
}

/// Жадная вершинная раскраска.
///
/// Вершины красятся по порядку номеров; каждой даётся наименьший цвет
/// (0, 1, 2, ...), которого нет ни у одного уже окрашенного соседа.
/// Число цветов зависит от порядка вершин и не обязано быть минимальным:
/// на двудольном графе неудачный порядок может заставить жадный алгоритм
/// использовать три цвета, хотя хватает двух.
pub fn greedy_coloring(g: &Graph) -> Vec<usize> {
    let n = g.node_count();
    let mut color = vec![0usize; n];
    for u in 0..n {
        let mut taken = vec![false; n + 1];
        for e in &g.edges {
            let v = if e.from == u {
                e.to
            } else if e.to == u {
                e.from
            } else {
                continue;
            };
            if v < u {
                taken[color[v]] = true; // только уже окрашенные соседи
            }
        }
        color[u] = taken.iter().position(|&t| !t).unwrap();
    }
    color
}

/// Расстояние между вершинами $u$ и $v$ (число рёбер в кратчайшем пути).
///
/// `None`, если $v$ недостижима из $u$. Веса игнорируются (это
/// невзвешенное расстояние из определений главы).
pub fn distance(g: &Graph, u: usize, v: usize) -> Option<usize> {
    let dist = bfs(g, u).dist;
    (dist[v] != usize::MAX).then_some(dist[v])
}

/// Эксцентриситет вершины: максимум расстояний до достижимых вершин.
pub fn eccentricity(g: &Graph, u: usize) -> Option<usize> {
    bfs(g, u)
        .dist
        .into_iter()
        .filter(|&d| d != usize::MAX)
        .max()
}

/// Диаметр графа: максимум расстояний между всеми парами вершин.
///
/// Для несвязного графа -- максимум внутри компонент (между вершинами из
/// разных компонент расстояния нет). Пустой граф даёт `None`.
pub fn diameter(g: &Graph) -> Option<usize> {
    let mut best: Option<usize> = None;
    for u in 0..g.node_count() {
        if let Some(d) = eccentricity(g, u) {
            best = Some(best.map_or(d, |b| b.max(d)));
        }
    }
    best
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Квадрат 0-1-2-3-0 (неориентированный).
    fn square() -> Graph {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (2, 3), (3, 0)]);
        g
    }

    /// Путь 0-1-2-3 (неориентированный).
    fn path() -> Graph {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (2, 3)]);
        g
    }

    #[test]
    fn bfs_distances_on_square() {
        let res = bfs(&square(), 0);
        assert_eq!(res.dist, vec![0, 1, 2, 1]);
        assert_eq!(res.parent, vec![None, Some(0), Some(1), Some(0)]);
    }

    #[test]
    fn bfs_marks_unreachable_as_max() {
        let mut g = Graph::undirected();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_edge(0, 1);
        let res = bfs(&g, 0);
        assert_eq!(res.dist[2], usize::MAX);
    }

    #[test]
    fn dfs_pre_post_intervals_nest() {
        // Родитель в DFS: pre(parent) < pre(child) < post(child) < post(parent).
        let res = dfs(&path());
        for u in 0..4 {
            if let Some(p) = res.parent[u] {
                assert!(res.pre[p] < res.pre[u]);
                assert!(res.post[u] < res.post[p]);
            }
        }
    }

    #[test]
    fn connected_components_count() {
        let mut g = Graph::undirected();
        for i in 0..5 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (3, 4)]);
        let (count, comp) = connected_components(&g);
        assert_eq!(count, 2);
        assert_eq!(comp[0], comp[1]);
        assert_eq!(comp[0], comp[2]);
        assert_eq!(comp[3], comp[4]);
        assert_ne!(comp[0], comp[3]);
    }

    #[test]
    fn scc_of_cycle_with_tail() {
        let mut g = Graph::directed();
        for i in 0..5 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (2, 0), (1, 3), (3, 4)]);
        let sccs = strongly_connected_components(&g);
        assert_eq!(sccs.len(), 3);
        let mut sizes: Vec<usize> = sccs.iter().map(|c| c.len()).collect();
        sizes.sort_unstable();
        assert_eq!(sizes, vec![1, 1, 3]);
    }

    #[test]
    fn cycle_detection() {
        assert!(is_cyclic(&square()));
        assert!(!is_cyclic(&path()));

        let mut g = Graph::undirected();
        let a = g.add_node("a");
        g.add_edge(a, a);
        assert!(is_cyclic(&g)); // петля -- цикл

        let mut d = Graph::directed();
        for i in 0..3 {
            d.add_node(i.to_string());
        }
        d.add_edges(&[(0, 1), (1, 2)]);
        assert!(!is_cyclic(&d));
        d.add_edge(2, 0);
        assert!(is_cyclic(&d));
    }

    #[test]
    fn topological_sort_orders_prerequisites() {
        let mut g = Graph::directed();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (0, 2), (1, 3), (2, 3)]);
        let order = topological_sort(&g).unwrap();
        assert_eq!(order[0], 0);
        assert_eq!(order[3], 3);
    }

    #[test]
    fn topological_sort_rejects_cycles() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (2, 0)]);
        assert!(topological_sort(&g).is_none());
    }

    #[test]
    fn dijkstra_finds_shortcut_through_middle() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 4);
        g.add_weighted_edge(0, 2, 1);
        g.add_weighted_edge(2, 1, 2);
        let (dist, _) = dijkstra(&g, 0);
        assert_eq!(dist, vec![Some(0), Some(3), Some(1)]);
    }

    #[test]
    fn dijkstra_unreachable_is_none() {
        let mut g = Graph::directed();
        for i in 0..2 {
            g.add_node(i.to_string());
        }
        let (dist, _) = dijkstra(&g, 0);
        assert_eq!(dist[1], None);
    }

    #[test]
    fn bellman_ford_handles_negative_edges() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 4);
        g.add_weighted_edge(1, 2, -3);
        let (dist, _) = bellman_ford(&g, 0).unwrap();
        assert_eq!(dist, vec![Some(0), Some(4), Some(1)]);
    }

    #[test]
    fn bellman_ford_detects_negative_cycle() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 1);
        g.add_weighted_edge(1, 2, -5);
        g.add_weighted_edge(2, 1, 1); // цикл 1 -> 2 -> 1 веса -4
        assert!(bellman_ford(&g, 0).is_none());
    }

    #[test]
    fn kruskal_builds_spanning_tree() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 1);
        g.add_weighted_edge(1, 2, 2);
        g.add_weighted_edge(2, 3, 3);
        g.add_weighted_edge(3, 0, 10);
        g.add_weighted_edge(0, 2, 100);
        let tree = min_spanning_tree(&g);
        assert_eq!(tree.len(), 3); // 4 вершины -- 3 ребра
        let total: i64 = tree.iter().map(|&e| g.edge_weight(e)).sum();
        assert_eq!(total, 6);
    }

    #[test]
    fn eulerian_circuit_on_square() {
        let trail = find_eulerian_path(&square()).unwrap();
        assert_eq!(trail.len(), 5); // 4 ребра, 5 вершин
        assert_eq!(trail[0], trail[4]); // цикл
                                        // Каждое ребро пройдено ровно один раз -- проверим по парам.
        let mut used = 0;
        for w in trail.windows(2) {
            if square().adjacent(w[0], w[1]) {
                used += 1;
            }
        }
        assert_eq!(used, 4);
    }

    #[test]
    fn eulerian_path_with_two_odd_vertices() {
        // Путь 0-1-2-3: нечётные степени у 0 и 3.
        let trail = find_eulerian_path(&path()).unwrap();
        assert_eq!(trail.len(), 4); // 3 ребра, 4 вершины
        assert_eq!(trail[0], 0);
        assert_eq!(trail[3], 3);
    }

    #[test]
    fn star_is_not_eulerian() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (0, 2), (0, 3)]); // три нечётные степени
        assert!(find_eulerian_path(&g).is_none());
    }

    #[test]
    fn disconnected_even_graph_has_no_eulerian_path() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 0), (2, 3), (3, 2)]); // два отдельных цикла
        assert!(find_eulerian_path(&g).is_none());
    }

    #[test]
    fn bipartite_square_ok_triangle_not() {
        assert_eq!(is_bipartite(&square()).unwrap(), vec![0, 1, 0, 1]);
        let mut tri = Graph::undirected();
        for i in 0..3 {
            tri.add_node(i.to_string());
        }
        tri.add_edges(&[(0, 1), (1, 2), (2, 0)]);
        assert!(is_bipartite(&tri).is_none());
    }

    #[test]
    fn bridges_of_path_are_all_edges() {
        let bs = bridges(&path());
        assert_eq!(bs, vec![(0, 1), (1, 2), (2, 3)]);
    }

    #[test]
    fn square_has_no_bridges() {
        assert!(bridges(&square()).is_empty());
    }

    #[test]
    fn articulation_points_of_path() {
        assert_eq!(articulation_points(&path()), vec![1, 2]);
    }

    #[test]
    fn articulation_points_of_square_empty() {
        assert!(articulation_points(&square()).is_empty());
    }

    #[test]
    fn greedy_coloring_of_triangle_uses_three_colors() {
        let mut tri = Graph::undirected();
        for i in 0..3 {
            tri.add_node(i.to_string());
        }
        tri.add_edges(&[(0, 1), (1, 2), (2, 0)]);
        let colors = greedy_coloring(&tri);
        assert_eq!(colors.iter().max().unwrap() + 1, 3);
        // Соседи всегда разных цветов.
        for e in &tri.edges {
            assert_ne!(colors[e.from], colors[e.to]);
        }
    }

    #[test]
    fn distance_diameter_on_square() {
        assert_eq!(distance(&square(), 0, 2), Some(2));
        assert_eq!(diameter(&square()), Some(2));
    }

    #[test]
    fn empty_graph_edge_cases() {
        let g = Graph::undirected();
        assert_eq!(connected_components(&g), (0, vec![]));
        assert!(diameter(&g).is_none());
        assert!(!is_cyclic(&g));
        assert!(min_spanning_tree(&g).is_empty());
        assert!(find_eulerian_path(&g).is_none());
        assert!(greedy_coloring(&g).is_empty());
        // Топсорт и КСС -- только для ориентированных графов.
        let d = Graph::directed();
        assert_eq!(topological_sort(&d), Some(vec![]));
        assert!(strongly_connected_components(&d).is_empty());
    }

    #[test]
    fn single_vertex_edge_cases() {
        let mut g = Graph::undirected();
        g.add_node("only");
        assert_eq!(diameter(&g), Some(0));
        assert_eq!(find_eulerian_path(&g), Some(vec![0]));
        let (dist, _) = dijkstra(&g, 0);
        assert_eq!(dist, vec![Some(0)]);
    }

    #[test]
    fn parallel_edges_form_a_cycle_and_no_bridge() {
        let mut g = Graph::undirected();
        for i in 0..2 {
            g.add_node(i.to_string());
        }
        g.add_edge(0, 1);
        g.add_edge(0, 1);
        assert!(is_cyclic(&g));
        assert!(bridges(&g).is_empty());
    }

    #[test]
    fn dijkstra_on_undirected_graph() {
        let mut g = Graph::undirected();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_weighted_edge(0, 1, 2);
        g.add_weighted_edge(1, 2, 3);
        let (dist, _) = dijkstra(&g, 0);
        assert_eq!(dist, vec![Some(0), Some(2), Some(5)]);
    }

    #[test]
    fn euler_path_on_directed_chain() {
        let mut g = Graph::directed();
        for i in 0..3 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2)]);
        assert_eq!(find_eulerian_path(&g), Some(vec![0, 1, 2]));
    }

    #[test]
    fn topological_sort_of_edgeless_graph_is_identity() {
        let mut g = Graph::directed();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        assert_eq!(topological_sort(&g), Some(vec![0, 1, 2, 3]));
    }

    #[test]
    fn greedy_coloring_of_star_uses_two_colors() {
        let mut g = Graph::undirected();
        for i in 0..4 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (0, 2), (0, 3)]);
        let colors = greedy_coloring(&g);
        assert!(*colors.iter().max().unwrap() <= 1);
        // Соседи всегда разных цветов.
        for e in &g.edges {
            assert_ne!(colors[e.from], colors[e.to]);
        }
    }

    #[test]
    fn greedy_coloring_of_square_uses_two_colors() {
        // Классический жадный алгоритм на 4-цикле обходится двумя цветами.
        let colors = greedy_coloring(&square());
        assert!(*colors.iter().max().unwrap() <= 1);
    }

    #[test]
    fn greedy_coloring_bipartite_bad_order_uses_three() {
        // Двудольный граф (доли {0, 2, 4} и {1, 3}), но жадный алгоритм
        // в естественном порядке использует три цвета: вершина 4 видит
        // соседа 1 цвета 1 и соседа 3 цвета 0 -- свободен только цвет 2.
        let mut g = Graph::undirected();
        for i in 0..5 {
            g.add_node(i.to_string());
        }
        g.add_edges(&[(0, 1), (1, 2), (3, 4), (1, 4)]);
        assert!(is_bipartite(&g).is_some());
        let colors = greedy_coloring(&g);
        assert_eq!(colors, vec![0, 1, 0, 0, 2]);
        for e in &g.edges {
            assert_ne!(colors[e.from], colors[e.to]);
        }
    }

    #[test]
    fn eccentricity_of_square_corner() {
        assert_eq!(eccentricity(&square(), 0), Some(2));
    }

    #[test]
    fn euler_circuit_with_self_loop() {
        // Петля даёт степени 2 по критерию Эйлера: цикл существует.
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        g.add_edge(a, a);
        assert_eq!(find_eulerian_path(&g), Some(vec![0, 0]));
    }

    #[test]
    fn euler_rejects_two_loops_and_a_tail() {
        // Петли (2 + 2) и ребро 0-1: нечётная степень у 1 -- путь есть.
        let mut g = Graph::undirected();
        for i in 0..2 {
            g.add_node(i.to_string());
        }
        g.add_edge(0, 0);
        g.add_edge(0, 0);
        g.add_edge(0, 1);
        let trail = find_eulerian_path(&g).unwrap();
        assert_eq!(trail.len(), 4); // 3 ребра
    }

    #[test]
    #[should_panic(expected = "предназначен для ориентированных")]
    fn topological_sort_rejects_undirected() {
        topological_sort(&square());
    }

    #[test]
    #[should_panic(expected = "предназначен для ориентированных")]
    fn scc_rejects_undirected() {
        strongly_connected_components(&square());
    }
}
