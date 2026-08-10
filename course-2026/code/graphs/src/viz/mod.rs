//! Визуализация графов: как «отрендерить» граф разными способами.
//!
//! Раскладку (где какая вершина) рисовать самим не нужно: это делают
//! готовые инструменты. Крейт выдаёт им текст:
//!
//! - [`dot`]: описание для Graphviz. Утилиты `dot`, `neato`, `fdp`, `circo`
//!   сами выберут раскладку и нарисуют картинку в любом формате;
//! - [`cytoscape`]: JSON для библиотеки cytoscape.js. Она сама раскладывает
//!   граф (алгоритмы `cose`, `circle`, `concentric`, ...) и делает его
//!   интерактивным в браузере.
//!
//! Оба формата -- текст, так что для Graphviz не нужно ничего, кроме
//! самого `dot`, а для cytoscape -- только `serde_json`.

pub mod cytoscape;
pub mod dot;

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
