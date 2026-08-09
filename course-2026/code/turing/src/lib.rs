//! Машины Тьюринга (глава m19).
//!
//! Ядро смоделировано по дизайну экспериментального репозитория
//! `~/dev/nexus/turing`: лента с головкой на двух стеках, таблица переходов,
//! трасса конфигураций. Адаптировано под определение главы ---
//! принимающее и отвергающее состояния.

use std::collections::HashMap;
use std::hash::Hash;

/// Направление сдвига головки.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Direction {
    Left,
    Right,
    Stay,
}

/// Переход: записать `write`, сдвинуться, перейти в `next_state`.
#[derive(Debug, Clone)]
pub struct Transition<Sym, State> {
    pub write: Sym,
    pub direction: Direction,
    pub next_state: State,
}

/// Лента с головкой.
///
/// Символы слева и справа от головки хранятся в двух стеках, поэтому
/// движение --- перенос символа между `left`, `head` и `right`.
#[derive(Debug, Clone)]
pub struct Tape<Sym> {
    head: Sym,
    left: Vec<Sym>,
    right: Vec<Sym>,
    blank: Sym,
}

impl<Sym: Clone + Eq> Tape<Sym> {
    /// Пустая лента; головка на пустом символе.
    pub fn new(blank: Sym) -> Self {
        Self {
            head: blank.clone(),
            left: Vec::new(),
            right: Vec::new(),
            blank,
        }
    }

    /// Лента со словом `word`; головка на первом символе.
    pub fn with_word(word: &[Sym], blank: Sym) -> Self {
        let mut tape = Tape::new(blank.clone());
        let mut i = 0;
        for sym in word {
            tape.write(sym.clone());
            if i + 1 < word.len() {
                tape.move_right();
            }
            i += 1;
        }
        // Возвращаемся к первому символу.
        for _ in 1..word.len() {
            tape.move_left();
        }
        tape
    }

    pub fn read(&self) -> &Sym {
        &self.head
    }

    pub fn write(&mut self, sym: Sym) {
        self.head = sym;
    }

    pub fn move_left(&mut self) {
        self.right.push(self.head.clone());
        self.head = self.left.pop().unwrap_or_else(|| self.blank.clone());
    }

    pub fn move_right(&mut self) {
        self.left.push(self.head.clone());
        self.head = self.right.pop().unwrap_or_else(|| self.blank.clone());
    }

    pub fn move_head(&mut self, direction: Direction) {
        match direction {
            Direction::Left => self.move_left(),
            Direction::Right => self.move_right(),
            Direction::Stay => {}
        }
    }

    /// Содержимое ленты: `left` + `head` + `right`.
    pub fn content(&self) -> Vec<Sym> {
        let mut content = Vec::new();
        content.extend(self.left.iter().cloned());
        content.push(self.head.clone());
        content.extend(self.right.iter().rev().cloned());
        content
    }
}

/// Конфигурация: текущее состояние и лента.
#[derive(Debug, Clone)]
pub struct Configuration<Sym, State> {
    pub state: State,
    pub tape: Tape<Sym>,
}

/// Исход работы машины на входе.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Outcome {
    /// Достигнуто принимающее состояние.
    Accepted,
    /// Достигнуто отвергающее состояние.
    Rejected,
    /// Нет применимого перехода: машина не принимает и не отвергает.
    Stuck,
}

/// Трасса вычисления вместе с исходом.
#[derive(Debug, Clone)]
pub struct Run<Sym, State> {
    pub outcome: Outcome,
    pub configs: Vec<Configuration<Sym, State>>,
}

/// Машина Тьюринга: таблица переходов, стартовое, принимающее
/// и отвергающее состояния.
#[derive(Debug, Clone)]
pub struct Machine<Sym, State> {
    transitions: HashMap<(State, Sym), Transition<Sym, State>>,
    start: State,
    accept: State,
    reject: State,
}

impl<Sym, State> Machine<Sym, State>
where
    Sym: Clone + Eq + Hash,
    State: Clone + Eq + Hash,
{
    pub fn new(
        transitions: HashMap<(State, Sym), Transition<Sym, State>>,
        start: State,
        accept: State,
        reject: State,
    ) -> Self {
        Self {
            transitions,
            start,
            accept,
            reject,
        }
    }

    /// Следующая конфигурация по правилу для текущего состояния и символа.
    pub fn next(&self, config: &Configuration<Sym, State>) -> Option<Configuration<Sym, State>> {
        let sym = config.tape.read().clone();
        self.transitions
            .get(&(config.state.clone(), sym))
            .map(|tr| {
                let mut tape = config.tape.clone();
                tape.write(tr.write.clone());
                tape.move_head(tr.direction);
                Configuration {
                    state: tr.next_state.clone(),
                    tape,
                }
            })
    }

    /// Запускает машину на ленте `tape` и возвращает трассу с исходом.
    pub fn run(&self, tape: Tape<Sym>) -> Run<Sym, State> {
        let mut config = Configuration {
            state: self.start.clone(),
            tape,
        };
        let mut configs = Vec::new();
        let outcome = loop {
            configs.push(config.clone());
            if config.state == self.accept {
                break Outcome::Accepted;
            }
            if config.state == self.reject {
                break Outcome::Rejected;
            }
            match self.next(&config) {
                Some(next) => config = next,
                None => break Outcome::Stuck,
            }
        };
        Run { outcome, configs }
    }
}

/// Примеры машин из главы m19.
pub mod examples {
    use super::*;

    fn tr<Sym: Clone, State>(
        write: Sym,
        direction: Direction,
        next_state: State,
    ) -> Transition<Sym, State> {
        Transition {
            write,
            direction,
            next_state,
        }
    }

    /// Машина из главы m19, принимающая строки над `{0, 1}`,
    /// заканчивающиеся на `0`. Пустой символ ленты --- пробел.
    ///
    /// Состояние `q0` --- «последний символ был 1», `q1` --- «был 0».
    pub fn ends_with_zero() -> Machine<char, &'static str> {
        let mut t = HashMap::new();
        t.insert(("q0", '0'), tr('0', Direction::Right, "q1"));
        t.insert(("q0", '1'), tr('1', Direction::Right, "q0"));
        t.insert(("q0", ' '), tr(' ', Direction::Right, "reject"));
        t.insert(("q1", '0'), tr('0', Direction::Right, "q1"));
        t.insert(("q1", '1'), tr('1', Direction::Right, "q0"));
        t.insert(("q1", ' '), tr(' ', Direction::Right, "accept"));
        Machine::new(t, "q0", "accept", "reject")
    }

    /// Машина из главы m19, распознающая язык `0^n 1^n` (n >= 0).
    ///
    /// Многократно вычёркивает один `0` слева и одну `1` справа буквой `X`;
    /// принимает, когда все символы вычеркнуты.
    pub fn zero_n_one_n() -> Machine<char, &'static str> {
        let mut t = HashMap::new();
        // q0: поиск первого невычеркнутого 0.
        t.insert(("q0", '0'), tr('X', Direction::Right, "q1"));
        t.insert(("q0", 'X'), tr('X', Direction::Right, "accept"));
        t.insert(("q0", '1'), tr('1', Direction::Right, "reject"));
        t.insert(("q0", ' '), tr(' ', Direction::Right, "accept")); // пустое слово
                                                                    // q1: движение вправо к концу строки.
        t.insert(("q1", '0'), tr('0', Direction::Right, "q1"));
        t.insert(("q1", '1'), tr('1', Direction::Right, "q1"));
        t.insert(("q1", 'X'), tr('X', Direction::Right, "q1"));
        t.insert(("q1", ' '), tr(' ', Direction::Left, "q2"));
        // q2: поиск первой невычеркнутой 1 справа (вычеркнутые X пропускаем).
        t.insert(("q2", '1'), tr('X', Direction::Left, "q3"));
        t.insert(("q2", 'X'), tr('X', Direction::Left, "q2"));
        t.insert(("q2", '0'), tr('0', Direction::Left, "reject"));
        t.insert(("q2", ' '), tr(' ', Direction::Left, "reject"));
        // q3: возврат влево к началу.
        t.insert(("q3", '1'), tr('1', Direction::Left, "q3"));
        t.insert(("q3", '0'), tr('0', Direction::Left, "q3"));
        t.insert(("q3", 'X'), tr('X', Direction::Right, "q0"));
        Machine::new(t, "q0", "accept", "reject")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ends_with_zero_accepts_correct_words() {
        let machine = examples::ends_with_zero();
        for (word, expect) in [
            ("0", true),
            ("10", true),
            ("010", true),
            ("00", true),
            ("", false),
            ("1", false),
            ("11", false),
            ("01", false),
        ] {
            let tape = Tape::with_word(&word.chars().collect::<Vec<_>>(), ' ');
            let outcome = machine.run(tape).outcome;
            assert_eq!(outcome == Outcome::Accepted, expect, "слово {word:?}");
        }
    }

    #[test]
    fn zero_n_one_n_accepts_correct_words() {
        let machine = examples::zero_n_one_n();
        for (word, expect) in [
            ("", true),
            ("01", true),
            ("0011", true),
            ("000111", true),
            ("001", false),
            ("011", false),
            ("10", false),
            ("00111", false),
        ] {
            let tape = Tape::with_word(&word.chars().collect::<Vec<_>>(), ' ');
            let outcome = machine.run(tape).outcome;
            assert_eq!(outcome == Outcome::Accepted, expect, "слово {word:?}");
        }
    }
}
