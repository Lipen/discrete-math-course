//! Визуализация графов: как «отрендерить» граф разными способами.
//!
//! Каждый бэкенд -- простая функция, которая превращает `&Graph` в текст:
//!
//! - [`svg`]: картинка в формате SVG (стандарт векторной графики для web);
//! - [`dot`]: описание для Graphviz (утилита `dot` сама рисует картинку);
//! - [`cytoscape`]: JSON для библиотеки cytoscape.js (интерактивные графы
//!   в браузере);
//! - [`html`]: отдельная HTML-страница с картинкой внутри -- открой в браузере.
//!
//! Всем нужен только текст, поэтому у модуля нет внешних зависимостей.
//! Дальше по пути «web» можно идти так: SVG -- вставить в страницу,
//! cytoscape JSON -- скормить cytoscape.js, а для wasm/js/bevy/egui те же
//! данные -- просто структуры, которые передаются в свой рендерер.

pub mod cytoscape;
pub mod dot;
pub mod html;
pub mod svg;

/// Раскладка вершин по кругу: координаты (x, y) для каждой вершины.
///
/// Круг -- простейшая раскладка, которая не зависит от структуры графа и
/// всегда помещается в поле `width` x `height`. Для серьёзных картинок
/// используют силовые алгоритмы (например, Fruchterman--Reingold), но для
/// учебных примеров круга достаточно.
pub fn circle_layout(n: usize, width: f64, height: f64) -> Vec<(f64, f64)> {
    if n == 0 {
        return Vec::new();
    }
    let cx = width / 2.0;
    let cy = height / 2.0;
    let radius = width.min(height) / 2.0 - 24.0;
    if n == 1 {
        return vec![(cx, cy)];
    }
    (0..n)
        .map(|i| {
            let angle = std::f64::consts::TAU * i as f64 / n as f64 - std::f64::consts::FRAC_PI_2;
            (cx + radius * angle.cos(), cy + radius * angle.sin())
        })
        .collect()
}

/// Точка на середине отрезка, чуть сдвинутая в сторону -- для подписи веса.
pub(crate) fn midpoint(a: (f64, f64), b: (f64, f64)) -> (f64, f64) {
    ((a.0 + b.0) / 2.0, (a.1 + b.1) / 2.0)
}

/// Экранировать спецсимволы в тексте так, чтобы он не сломал разметку.
pub(crate) fn escape(text: &str) -> String {
    text.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
}

/// Убрать из имени символы, недопустимые в идентификаторах DOT.
pub(crate) fn dot_id(text: &str) -> String {
    if text.is_empty() {
        return String::from("_");
    }
    let cleaned: String = text
        .chars()
        .map(|c| {
            if c.is_ascii_alphanumeric() || c == '_' {
                c
            } else {
                '_'
            }
        })
        .collect();
    if cleaned.chars().next().unwrap().is_ascii_digit() {
        return format!("n{cleaned}");
    }
    cleaned
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn circle_layout_has_n_points_inside_box() {
        let pts = circle_layout(6, 400.0, 300.0);
        assert_eq!(pts.len(), 6);
        for &(x, y) in &pts {
            assert!((0.0..=400.0).contains(&x));
            assert!((0.0..=300.0).contains(&y));
        }
    }

    #[test]
    fn circle_layout_single_point_is_center() {
        assert_eq!(circle_layout(1, 400.0, 300.0), vec![(200.0, 150.0)]);
    }

    #[test]
    fn escaping_handles_angle_brackets() {
        assert_eq!(escape("a<b>&c"), "a&lt;b&gt;&amp;c");
    }
}
