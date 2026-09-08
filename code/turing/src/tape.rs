//! The tape: an infinite sequence of cells holding symbols,
//! with a head that can read, write, and move left or right.
//!
//! The tape is modelled as two stacks (`left` and `right`) with the head
//! between them. Moving the head transfers a symbol between the stacks,
//! so every operation is O(1). A blank symbol fills cells that have never
//! been written.

/// The direction the head moves after writing.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Direction {
    /// Move the head one cell to the left.
    Left,
    /// Move the head one cell to the right.
    Right,
    /// Leave the head on the same cell.
    Stay,
}

/// A Turing-machine tape with a head.
///
/// Symbols to the left of the head sit in the `left` stack (the top is the
/// nearest cell); symbols to the right sit in `right` (the top is the nearest
/// cell). Moving the head pops from one stack and pushes onto the other.
/// Every cell that has never been visited holds the `blank` symbol.
///
/// ```
/// use turing::Tape;
///
/// let mut tape: Tape<char> = Tape::new('_');
/// assert_eq!(*tape.read(), '_');
///
/// tape.write('a');
/// tape.move_right();
/// assert_eq!(*tape.read(), '_'); // moved onto a fresh blank cell
/// tape.move_left();
/// assert_eq!(*tape.read(), 'a'); // back where we were
/// ```
#[derive(Debug, Clone)]
pub struct Tape<Sym> {
    head: Sym,
    left: Vec<Sym>,
    right: Vec<Sym>,
    blank: Sym,
}

impl<Sym: Clone + Eq> Tape<Sym> {
    /// Creates a tape filled entirely with `blank`; the head sits on a blank cell.
    ///
    /// ```
    /// use turing::Tape;
    ///
    /// let tape: Tape<char> = Tape::new('_');
    /// assert_eq!(*tape.read(), '_');
    /// ```
    pub fn new(blank: Sym) -> Self {
        Self {
            head: blank.clone(),
            left: Vec::new(),
            right: Vec::new(),
            blank,
        }
    }

    /// Creates a tape containing `word`; the head is positioned on the first
    /// symbol. Cells beyond the word are blank.
    ///
    /// ```
    /// use turing::Tape;
    ///
    /// let tape = Tape::with_word(&['0', '1', '1'], ' ');
    /// assert_eq!(*tape.read(), '0');
    /// assert_eq!(tape.content(), vec!['0', '1', '1']);
    /// ```
    pub fn with_word(word: &[Sym], blank: Sym) -> Self {
        let mut tape = Tape::new(blank.clone());
        for (i, sym) in word.iter().enumerate() {
            tape.write(sym.clone());
            if i + 1 < word.len() {
                tape.move_right();
            }
        }
        // Return to the first symbol.
        for _ in 1..word.len() {
            tape.move_left();
        }
        tape
    }

    /// Returns the symbol under the head.
    ///
    /// ```
    /// use turing::Tape;
    ///
    /// let tape: Tape<char> = Tape::new('_');
    /// assert_eq!(*tape.read(), '_');
    /// ```
    pub fn read(&self) -> &Sym {
        &self.head
    }

    /// Overwrites the symbol under the head.
    ///
    /// ```
    /// use turing::Tape;
    ///
    /// let mut tape: Tape<char> = Tape::new('_');
    /// tape.write('X');
    /// assert_eq!(*tape.read(), 'X');
    /// ```
    pub fn write(&mut self, sym: Sym) {
        self.head = sym;
    }

    /// Moves the head one cell to the left.
    ///
    /// The current symbol is pushed onto `right`; the left neighbour becomes
    /// the new head (or a blank if the left stack is empty).
    ///
    /// ```
    /// use turing::Tape;
    ///
    /// let mut tape = Tape::with_word(&['a', 'b'], '_');
    /// assert_eq!(*tape.read(), 'a');
    /// tape.move_right();
    /// assert_eq!(*tape.read(), 'b');
    /// tape.move_left();
    /// assert_eq!(*tape.read(), 'a');
    /// ```
    pub fn move_left(&mut self) {
        self.right.push(self.head.clone());
        self.head = self.left.pop().unwrap_or_else(|| self.blank.clone());
    }

    /// Moves the head one cell to the right.
    ///
    /// The current symbol is pushed onto `left`; the right neighbour becomes
    /// the new head (or a blank if the right stack is empty).
    ///
    /// ```
    /// use turing::Tape;
    ///
    /// let mut tape = Tape::with_word(&['x', 'y'], '_');
    /// tape.move_right();
    /// assert_eq!(*tape.read(), 'y');
    /// ```
    pub fn move_right(&mut self) {
        self.left.push(self.head.clone());
        self.head = self.right.pop().unwrap_or_else(|| self.blank.clone());
    }

    /// Moves the head in the given direction.
    ///
    /// ```
    /// use turing::{Tape, Direction};
    ///
    /// let mut tape = Tape::with_word(&['0', '1'], '_');
    /// tape.move_head(Direction::Right);
    /// assert_eq!(*tape.read(), '1');
    /// tape.move_head(Direction::Left);
    /// assert_eq!(*tape.read(), '0');
    /// tape.move_head(Direction::Stay);
    /// assert_eq!(*tape.read(), '0');
    /// ```
    pub fn move_head(&mut self, direction: Direction) {
        match direction {
            Direction::Left => self.move_left(),
            Direction::Right => self.move_right(),
            Direction::Stay => {}
        }
    }

    /// Returns the tape content as `left` (bottom to top) + `head` + `right`
    /// (reversed so the nearest cell comes first).
    ///
    /// Blanks that the head has visited are included.
    ///
    /// ```
    /// use turing::Tape;
    ///
    /// let tape = Tape::with_word(&['0', '1', '0'], '_');
    /// assert_eq!(tape.content(), vec!['0', '1', '0']);
    /// ```
    pub fn content(&self) -> Vec<Sym> {
        let mut content = Vec::new();
        content.extend(self.left.iter().cloned());
        content.push(self.head.clone());
        content.extend(self.right.iter().rev().cloned());
        content
    }

    /// Returns the tape content with leading and trailing blanks trimmed.
    ///
    /// Useful for displaying the "meaningful" part of the tape after a
    /// computation that may have wandered into blank territory.
    ///
    /// ```
    /// use turing::Tape;
    ///
    /// let tape = Tape::with_word(&['0', '1'], ' ');
    /// assert_eq!(tape.content_trimmed(), vec!['0', '1']);
    /// ```
    pub fn content_trimmed(&self) -> Vec<Sym> {
        let content = self.content();
        let start = content
            .iter()
            .position(|s| s != &self.blank)
            .unwrap_or(content.len());
        let end = content
            .iter()
            .rposition(|s| s != &self.blank)
            .map_or(0, |i| i + 1);
        if start >= end {
            Vec::new()
        } else {
            content[start..end].to_vec()
        }
    }
}
