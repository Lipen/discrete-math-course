//! Взлом шифра Цезаря полным перебором (глава m13, раздел «Взлом»).
//!
//! Ключ шифра --- сдвиг от 1 до 32. Пробуем все сдвиги в обратную сторону:
//! осмысленное слово "ШИФР" появится при сдвиге на 3 позиции.

/// Русский алфавит (33 буквы, с Ё).
const RUS: &str = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ";

fn main() {
    let cipher = "ЫЛЧУ";
    println!("Шифротекст: {cipher}");
    println!("Все сдвиги (дешифрование):");

    let letters: Vec<char> = RUS.chars().collect();
    let n = letters.len();
    for k in 1..n {
        let decrypted: String = cipher
            .chars()
            .map(|c| {
                let Some(i) = letters.iter().position(|&x| x == c) else {
                    return c;
                };
                letters[(i + n - k) % n]
            })
            .collect();
        println!("сдвиг {k:>2}: {decrypted}");
    }

    println!("Среди строк есть осмысленная --- это и есть открытый текст.");
}
