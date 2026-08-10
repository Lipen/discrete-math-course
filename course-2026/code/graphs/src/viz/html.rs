//! Граф в виде отдельной HTML-страницы.
//!
//! Самый простой способ «показать граф человеку»: функция [`render`]
//! возвращает целую страницу с картинкой SVG внутри. Сохрани результат в
//! `graph.html` и открой в браузере --- ничего устанавливать не нужно.

use crate::graph::Graph;
use crate::viz::svg::{render as render_svg, SvgOptions};

/// Готовая HTML-страница с картинкой графа.
pub fn render(g: &Graph) -> String {
    let svg = render_svg(g, &SvgOptions::default());
    let title = if g.directed {
        "Ориентированный граф"
    } else {
        "Неориентированный граф"
    };
    format!(
        "<!doctype html>\n\
         <html lang=\"ru\">\n\
         <head>\n\
         <meta charset=\"utf-8\">\n\
         <title>{title}</title>\n\
         </head>\n\
         <body style=\"font-family: sans-serif; display: flex; flex-direction: column; \
         align-items: center; gap: 0.5em;\">\n\
         <h1>{title}</h1>\n\
         {svg}\
         <p style=\"color: #888; font-size: 12px;\">\
         Сгенерировано крейтом graphs. Веса рёбер, отличные от 1, подписаны.</p>\n\
         </body>\n\
         </html>\n"
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn page_embeds_svg() {
        let mut g = Graph::undirected();
        let a = g.add_node("a");
        let b = g.add_node("b");
        g.add_edge(a, b);
        let page = render(&g);
        assert!(page.starts_with("<!doctype html>"));
        assert!(page.contains("<svg"));
        assert!(page.contains("</html>"));
    }
}
