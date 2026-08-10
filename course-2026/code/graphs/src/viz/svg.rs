//! Рендер графа в SVG.
//!
//! SVG --- текстовая векторная графика, которую показывает любой браузер
//! и почти любой редактор. Функция [`render`] возвращает готовый документ;
//! сохрани его в файл `graph.svg` и открой.

use crate::graph::Graph;
use crate::viz::{circle_layout, escape, midpoint};

/// Настройки картинки.
pub struct SvgOptions {
    /// Ширина поля (в пикселях).
    pub width: f64,
    /// Высота поля.
    pub height: f64,
    /// Радиус кружка вершины.
    pub node_radius: f64,
    /// Подписывать ли рёбра весами.
    pub show_weights: bool,
}

impl Default for SvgOptions {
    fn default() -> Self {
        SvgOptions {
            width: 600.0,
            height: 450.0,
            node_radius: 22.0,
            show_weights: true,
        }
    }
}

/// Граф целиком в один SVG-документ.
pub fn render(g: &Graph, opts: &SvgOptions) -> String {
    let pos = circle_layout(g.node_count(), opts.width, opts.height);
    let mut out = String::new();

    out.push_str(&format!(
        "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{}\" height=\"{}\" viewBox=\"0 0 {} {}\">\n",
        opts.width, opts.height, opts.width, opts.height
    ));
    if g.directed {
        out.push_str(
            "  <defs><marker id=\"arrow\" viewBox=\"0 0 10 10\" refX=\"9\" refY=\"5\" \
             markerWidth=\"7\" markerHeight=\"7\" orient=\"auto-start-reverse\">\n    \
             <path d=\"M 0 0 L 10 5 L 0 10 z\" fill=\"#3584e4\"/>\n  </marker></defs>\n",
        );
    }

    // Рёбра рисуем под вершинами, чтобы кружки перекрывали линии.
    for e in &g.edges {
        let (x1, y1) = pos[e.from];
        let (x2, y2) = pos[e.to];
        let arrow = if g.directed {
            " marker-end=\"url(#arrow)\""
        } else {
            ""
        };
        out.push_str(&format!(
            "  <line x1=\"{x1:.1}\" y1=\"{y1:.1}\" x2=\"{x2:.1}\" y2=\"{y2:.1}\" \
             stroke=\"#3584e4\" stroke-width=\"1.6\"{arrow}/>\n"
        ));
        if opts.show_weights && e.weight != 1 {
            let (mx, my) = midpoint((x1, y1), (x2, y2));
            out.push_str(&format!(
                "  <text x=\"{mx:.1}\" y=\"{my:.1}\" font-size=\"11\" fill=\"#555\" \
                 text-anchor=\"middle\" font-family=\"sans-serif\">{}</text>\n",
                e.weight
            ));
        }
    }

    for (u, &(x, y)) in pos.iter().enumerate() {
        let r = opts.node_radius;
        out.push_str(&format!(
            "  <circle cx=\"{x:.1}\" cy=\"{y:.1}\" r=\"{r:.0}\" fill=\"#e4f0fb\" \
             stroke=\"#1a5fb4\" stroke-width=\"1.6\"/>\n"
        ));
        out.push_str(&format!(
            "  <text x=\"{x:.1}\" y=\"{y:.1}\" font-size=\"13\" fill=\"#1a5fb4\" \
             text-anchor=\"middle\" dominant-baseline=\"central\" \
             font-family=\"sans-serif\">{}</text>\n",
            escape(g.node_name(u))
        ));
    }

    out.push_str("</svg>\n");
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn tiny_graph() -> Graph {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_weighted_edge(a, b, 5);
        g
    }

    #[test]
    fn svg_contains_nodes_and_weight() {
        let svg = render(&tiny_graph(), &SvgOptions::default());
        assert!(svg.contains("<svg"));
        assert!(svg.contains(">a</text>"));
        assert!(svg.contains(">b</text>"));
        assert!(svg.contains(">5</text>"));
        assert!(svg.ends_with("</svg>\n"));
    }

    #[test]
    fn directed_svg_has_arrow_marker() {
        let mut g = Graph::directed();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_edge(a, b);
        let svg = render(&g, &SvgOptions::default());
        assert!(svg.contains("marker-end"));
    }
}
