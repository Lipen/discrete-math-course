//! Terms: the data of logic programming.
//!
//! A term is a tree built from variables, constant atoms, and structures.
//! Terms are what Prolog programs compute over: a fact like `parent(alice, bob)` is a term, and so is the list `[a, b, c]`.

use std::fmt::{self, Display};

/// A logic-programming term.
///
/// A term is either a variable (with a unique id), a constant atom (a name with no arguments, like `alice` or `[]`), or a structure: a functor applied to argument terms, like `parent(alice, bob)`.
///
/// ```
/// use prolog::term::Term;
///
/// let alice = Term::atom("alice");
/// let parent = Term::struct_("parent", vec![Term::atom("alice"), Term::atom("bob")]);
/// assert_eq!(parent.to_string(), "parent(alice, bob)");
/// assert_eq!(alice, Term::atom("alice"));
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Term {
    /// A variable, identified by a unique natural number.
    Var(usize),
    /// A constant: a name with no arguments.
    Atom(String),
    /// A compound term: a functor applied to argument terms.
    Struct(String, Vec<Term>),
}

impl Term {
    /// A variable with the given id.
    ///
    /// Variables are numbered so that renaming (standardizing clauses apart) can give every use of a clause fresh ids.
    ///
    /// ```
    /// use prolog::term::Term;
    /// assert_eq!(Term::var(0).to_string(), "_0");
    /// ```
    pub fn var(id: usize) -> Self {
        Term::Var(id)
    }

    /// A constant atom.
    ///
    /// ```
    /// use prolog::term::Term;
    /// assert_eq!(Term::atom("bob").to_string(), "bob");
    /// ```
    pub fn atom(name: impl Into<String>) -> Self {
        Term::Atom(name.into())
    }

    /// A structure: `functor(arg1, arg2, ...)`.
    ///
    /// ```
    /// use prolog::term::Term;
    /// let t = Term::struct_("edge", vec![Term::atom("a"), Term::atom("b")]);
    /// assert_eq!(t.to_string(), "edge(a, b)");
    /// ```
    pub fn struct_(functor: impl Into<String>, args: Vec<Term>) -> Self {
        Term::Struct(functor.into(), args)
    }

    /// The empty list.
    ///
    /// Lists are sugar over the structure `.(head, tail)`, ending in the atom `[]`.
    ///
    /// ```
    /// use prolog::term::Term;
    /// assert_eq!(Term::nil().to_string(), "[]");
    /// ```
    pub fn nil() -> Self {
        Term::atom("[]")
    }

    /// A list cell: `cons(head, tail)` is the list `[head | tail]`.
    ///
    /// ```
    /// use prolog::term::Term;
    /// let xs = Term::cons(Term::atom("a"), Term::nil());
    /// assert_eq!(xs.to_string(), "[a]");
    /// ```
    pub fn cons(head: Term, tail: Term) -> Self {
        Term::struct_(".", vec![head, tail])
    }

    /// A closed list of terms.
    ///
    /// ```
    /// use prolog::term::Term;
    /// let xs = Term::list([Term::atom("a"), Term::atom("b")]);
    /// assert_eq!(xs.to_string(), "[a, b]");
    /// ```
    pub fn list<I: IntoIterator<Item = Term>>(items: I) -> Self
    where
        I::IntoIter: DoubleEndedIterator,
    {
        let mut out = Term::nil();
        for item in items.into_iter().rev() {
            out = Term::cons(item, out);
        }
        out
    }

    /// The ids of all variables occurring in this term, in no particular order.
    ///
    /// ```
    /// use prolog::term::Term;
    /// let t = Term::struct_("f", vec![Term::var(0), Term::var(3)]);
    /// let mut ids = t.vars();
    /// ids.sort();
    /// assert_eq!(ids, vec![0, 3]);
    /// ```
    pub fn vars(&self) -> Vec<usize> {
        match self {
            Term::Var(id) => vec![*id],
            Term::Struct(_, args) => {
                let mut out = Vec::new();
                for arg in args {
                    out.extend(arg.vars());
                }
                out
            }
            Term::Atom(_) => Vec::new(),
        }
    }

    /// Whether `var` occurs anywhere in this term, at any depth.
    ///
    /// This is the predicate behind the occurs check: a variable may not be
    /// bound to a term that contains it.
    ///
    /// ```
    /// use prolog::term::Term;
    /// let t = Term::struct_("f", vec![Term::atom("a"), Term::var(1)]);
    /// assert!(t.contains(1));
    /// assert!(!t.contains(0));
    /// ```
    pub fn contains(&self, var: usize) -> bool {
        match self {
            Term::Var(id) => *id == var,
            Term::Struct(_, args) => args.iter().any(|arg| arg.contains(var)),
            Term::Atom(_) => false,
        }
    }
}

impl Display for Term {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if let Some(rendered) = as_list(self) {
            return write!(f, "[{}]", rendered);
        }
        match self {
            Term::Var(id) => write!(f, "_{}", id),
            Term::Atom(name) => write!(f, "{}", name),
            Term::Struct(functor, args) => {
                let parts = args
                    .iter()
                    .map(ToString::to_string)
                    .collect::<Vec<_>>()
                    .join(", ");
                write!(f, "{}({})", functor, parts)
            }
        }
    }
}

/// Render a list built from `.`/`[]` in Prolog notation.
///
/// A proper list `[a, b]` is `.(a, .(b, []))`.
/// An open list `[a | T]` ends in a non-empty tail.
/// Anything that is not a `.` spine returns `None`, so it falls through to the ordinary structure display.
fn as_list(term: &Term) -> Option<String> {
    let mut items: Vec<String> = Vec::new();
    let mut cur = term;
    loop {
        match cur {
            Term::Atom(name) if name == "[]" => return Some(items.join(", ")),
            Term::Struct(functor, args) if functor == "." && args.len() == 2 => {
                items.push(args[0].to_string());
                cur = &args[1];
            }
            _ => {
                if items.is_empty() {
                    return None;
                }
                return Some(format!("{} | {}", items.join(", "), cur));
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::Term;

    #[test]
    fn list_is_a_dot_structure() {
        let xs = Term::list([Term::atom("a"), Term::atom("b")]);
        let expected = Term::struct_(
            ".",
            vec![
                Term::atom("a"),
                Term::struct_(".", vec![Term::atom("b"), Term::nil()]),
            ],
        );
        assert_eq!(xs, expected);
    }

    #[test]
    fn open_list_renders_with_tail() {
        let xs = Term::cons(Term::atom("a"), Term::var(0));
        assert_eq!(xs.to_string(), "[a | _0]");
    }
}
