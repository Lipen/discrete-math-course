//! Детерминированные конечные автоматы (ДКА).
//!
//! Не заданный переход ведёт в состояние-ловушку (индекс `states`);
//! `accepts` возвращает ложь, попав в ловушку. Операции над языками
//! (дополнение, объединение, пересечение, разность) и минимизация
//! строятся через произведение автоматов и разбиение на классы.

use std::collections::HashMap;

/// Детерминированный конечный автомат над алфавитом из `char`.
///
/// Состояния --- целые числа `0..states`; переходы задаются таблицей
/// `delta[state][индекс символа]`.
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

    /// Число состояний.
    pub fn num_states(&self) -> usize {
        self.states
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

    /// Состояние после перехода по символу (ловушка, если переход не задан).
    fn next_state(&self, state: usize, sym: char) -> usize {
        if state >= self.states {
            return self.states;
        }
        let Some(idx) = self.alphabet.iter().position(|&c| c == sym) else {
            return self.states;
        };
        self.delta[state][idx]
    }

    /// Принимает ли состояние (ловушка --- нет).
    fn is_accepting(&self, state: usize) -> bool {
        state < self.states && self.accepting[state]
    }

    /// Полный автомат: добавляем явную стоковую вершину-ловушку,
    /// чтобы каждый символ имел переход из любого состояния.
    pub fn complete(&self) -> Dfa {
        let mut d = self.clone();
        let dead = d.states;
        d.states += 1;
        d.accepting.push(false);
        d.delta.push(vec![dead; d.alphabet.len()]);
        for row in d.delta.iter_mut() {
            for to in row.iter_mut() {
                if *to >= dead {
                    *to = dead;
                }
            }
        }
        d
    }

    /// Дополнение языка: принимающие и непринимающие состояния меняются местами.
    pub fn complement(&self) -> Dfa {
        let mut d = self.complete();
        for a in d.accepting.iter_mut() {
            *a = !*a;
        }
        d
    }

    /// Произведение двух автоматов: состояния --- достижимые пары.
    fn product(&self, other: &Dfa, combine: fn(bool, bool) -> bool) -> Dfa {
        let mut pairs: Vec<(usize, usize)> = vec![(self.start, other.start)];
        let mut index: HashMap<(usize, usize), usize> = HashMap::new();
        index.insert((self.start, other.start), 0);
        let mut rows: Vec<Vec<usize>> = Vec::new();

        let mut i = 0;
        while i < pairs.len() {
            let (q1, q2) = pairs[i];
            let mut row = Vec::with_capacity(self.alphabet.len());
            for &sym in &self.alphabet {
                let key = (self.next_state(q1, sym), other.next_state(q2, sym));
                let j = *index.entry(key).or_insert_with(|| {
                    pairs.push(key);
                    pairs.len() - 1
                });
                row.push(j);
            }
            rows.push(row);
            i += 1;
        }

        let mut dfa = Dfa::new(pairs.len(), 0, self.alphabet.clone());
        for (i, row) in rows.iter().enumerate() {
            for (sym_idx, &to) in row.iter().enumerate() {
                dfa.set_transition(i, self.alphabet[sym_idx], to);
            }
        }
        let accepting = pairs
            .iter()
            .map(|&(q1, q2)| combine(self.is_accepting(q1), other.is_accepting(q2)))
            .collect();
        dfa.set_accepting(accepting);
        dfa
    }

    /// Объединение языков двух автоматов.
    pub fn union(&self, other: &Dfa) -> Dfa {
        self.product(other, |a, b| a || b)
    }

    /// Пересечение языков двух автоматов.
    pub fn intersection(&self, other: &Dfa) -> Dfa {
        self.product(other, |a, b| a && b)
    }

    /// Разность языков: слова `self`, не принадлежащие `other`.
    pub fn difference(&self, other: &Dfa) -> Dfa {
        self.product(other, |a, b| a && !b)
    }

    /// Минимизация методом Мура: разбиение состояний на неразличимые классы.
    pub fn minimize(&self) -> Dfa {
        // Недостижимые состояния исключаем.
        let mut reachable = vec![false; self.states];
        let mut stack = vec![self.start];
        reachable[self.start] = true;
        while let Some(s) = stack.pop() {
            for &to in &self.delta[s] {
                if to < self.states && !reachable[to] {
                    reachable[to] = true;
                    stack.push(to);
                }
            }
        }

        // Начальное разбиение: принимающие против непринимающих.
        let mut block = vec![usize::MAX; self.states];
        let mut blocks: Vec<Vec<usize>> = Vec::new();
        for s in 0..self.states {
            if !reachable[s] {
                continue;
            }
            let b = if self.accepting[s] { 0 } else { 1 };
            while blocks.len() <= b {
                blocks.push(Vec::new());
            }
            block[s] = b;
            blocks[b].push(s);
        }
        if blocks.is_empty() {
            blocks = vec![Vec::new(); 2];
        }

        // Итеративное уточнение по сигнатуре переходов.
        loop {
            let mut new_blocks: Vec<Vec<usize>> = Vec::new();
            let mut new_block = vec![usize::MAX; self.states];
            let mut refined = false;
            for states_in_block in &blocks {
                let mut groups: HashMap<Vec<usize>, Vec<usize>> = HashMap::new();
                for &s in states_in_block {
                    let sig: Vec<usize> = self.delta[s]
                        .iter()
                        .map(|&to| {
                            if to < self.states {
                                block[to]
                            } else {
                                usize::MAX
                            }
                        })
                        .collect();
                    groups.entry(sig).or_default().push(s);
                }
                for group in groups.values() {
                    if group.len() < states_in_block.len() {
                        refined = true;
                    }
                    let nb = new_blocks.len();
                    new_blocks.push(group.clone());
                    for &s in group {
                        new_block[s] = nb;
                    }
                }
            }
            block = new_block;
            blocks = new_blocks;
            if !refined {
                break;
            }
        }

        // Строим минимальный автомат: по состоянию на блок.
        let m = blocks.len();
        let start_block = block[self.start];
        let mut dfa = Dfa::new(m, start_block, self.alphabet.clone());
        for (b, group) in blocks.iter().enumerate() {
            let rep = group[0];
            for (sym_idx, &to) in self.delta[rep].iter().enumerate() {
                if to < self.states {
                    dfa.set_transition(b, self.alphabet[sym_idx], block[to]);
                }
            }
        }
        let accepting = blocks.iter().map(|g| self.accepting[g[0]]).collect();
        dfa.set_accepting(accepting);
        dfa
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

    /// ДКА: язык слов, заканчивающихся на "0".
    fn ends_with_zero() -> Dfa {
        let mut dfa = Dfa::new(2, 0, vec!['0', '1']);
        dfa.set_transition(0, '0', 1);
        dfa.set_transition(0, '1', 0);
        dfa.set_transition(1, '0', 1);
        dfa.set_transition(1, '1', 0);
        dfa.set_accepting(vec![false, true]);
        dfa
    }

    fn words() -> [&'static str; 6] {
        ["", "0", "1", "10", "110", "010"]
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

    #[test]
    fn complement_flips_language() {
        let dfa = even_ones();
        let comp = dfa.complement();
        for w in words() {
            assert_eq!(comp.accepts(w), !dfa.accepts(w), "слово {w:?}");
        }
    }

    #[test]
    fn union_and_intersection_via_product() {
        let even = even_ones();
        let end0 = ends_with_zero();
        let union = even.union(&end0);
        let inter = even.intersection(&end0);
        for w in words() {
            assert_eq!(
                union.accepts(w),
                even.accepts(w) || end0.accepts(w),
                "union {w:?}"
            );
            assert_eq!(
                inter.accepts(w),
                even.accepts(w) && end0.accepts(w),
                "inter {w:?}"
            );
        }
    }

    #[test]
    fn minimize_preserves_language() {
        // Автомат с избыточным (дублирующим) состоянием.
        let mut dfa = Dfa::new(3, 0, vec!['0', '1']);
        dfa.set_transition(0, '0', 1);
        dfa.set_transition(0, '1', 0);
        dfa.set_transition(1, '0', 2);
        dfa.set_transition(1, '1', 1);
        dfa.set_transition(2, '0', 1);
        dfa.set_transition(2, '1', 2);
        dfa.set_accepting(vec![false, true, true]); // состояния 1 и 2 неразличимы

        let min = dfa.minimize();
        for w in words() {
            assert_eq!(min.accepts(w), dfa.accepts(w), "слово {w:?}");
        }
        assert!(min.states < dfa.states, "автомат должен уменьшиться");
    }
}
