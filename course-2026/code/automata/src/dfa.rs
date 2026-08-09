//! Детерминированные конечные автоматы (ДКА).

/// Детерминированный конечный автомат над алфавитом из `char`.
///
/// Состояния --- целые числа `0..states`; переходы задаются таблицей
/// `delta[state][индекс символа]`. Не заданный переход ведёт в
/// состояние-ловушку (число `states`).
#[derive(Debug, Clone)]
pub struct Dfa {
    states: usize,
    start: usize,
    accepting: Vec<bool>,
    alphabet: Vec<char>,
    delta: Vec<Vec<usize>>,
}

impl Dfa {
    /// Создаёт автомат с `states` состояниями, стартовым `start`
    /// и алфавитом `alphabet`. Все состояния по умолчанию непринимающие.
    pub fn new(states: usize, start: usize, alphabet: Vec<char>) -> Self {
        let delta = vec![vec![states; alphabet.len()]; states];
        Dfa {
            states,
            start,
            accepting: vec![false; states],
            alphabet,
            delta,
        }
    }

    /// Задаёт переход из состояния `from` по символу `sym` в состояние `to`.
    pub fn set_transition(&mut self, from: usize, sym: char, to: usize) {
        let idx = self
            .alphabet
            .iter()
            .position(|&c| c == sym)
            .expect("символ не принадлежит алфавиту");
        self.delta[from][idx] = to;
    }

    /// Помечает состояния как принимающие (по одному флагу на состояние).
    pub fn set_accepting(&mut self, accepting: Vec<bool>) {
        assert_eq!(accepting.len(), self.states);
        self.accepting = accepting;
    }

    /// Принимает ли автомат слово `word`.
    pub fn accepts(&self, word: &str) -> bool {
        let mut state = self.start;
        for c in word.chars() {
            let Some(idx) = self.alphabet.iter().position(|&x| x == c) else {
                return false; // символ вне алфавита
            };
            state = self.delta[state][idx];
            if state >= self.states {
                return false; // ушли в состояние-ловушку
            }
        }
        self.accepting[state]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// ДКА из главы m17: язык слов с чётным числом единиц.
    fn even_ones() -> Dfa {
        let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
        dfa.set_transition(0, '0', 0);
        dfa.set_transition(0, '1', 1);
        dfa.set_transition(1, '0', 1);
        dfa.set_transition(1, '1', 0);
        dfa.set_accepting(vec![true, false]);
        dfa
    }

    #[test]
    fn even_ones_accepts_correct_words() {
        let dfa = even_ones();
        assert!(dfa.accepts(""));
        assert!(dfa.accepts("0"));
        assert!(dfa.accepts("11"));
        assert!(dfa.accepts("1100"));
        assert!(dfa.accepts("101")); // две единицы --- чёт
        assert!(!dfa.accepts("1"));
        assert!(!dfa.accepts("10")); // одна единица --- нечёт
        assert!(!dfa.accepts("111"));
    }

    #[test]
    fn symbol_outside_alphabet_is_rejected() {
        let dfa = even_ones();
        assert!(!dfa.accepts("2"));
        assert!(!dfa.accepts("01a"));
    }
}
