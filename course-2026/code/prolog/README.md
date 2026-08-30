# prolog

Terms, substitutions, unification, and clause databases.

A deliberately small model of Prolog's *data* as a mathematical system. No parser, no REPL, no
arithmetic, no cut, no solver -- the library stops where the theory of terms and unification is
complete, and a student project begins.

## Quick start

```bash
cargo run -p prolog --example family_tree
cargo run -p prolog --example unify_demo
cargo test -p prolog
```

## The idea

A logic program is a set of definite clauses. A fact `parent(alice, bob).`
asserts that a predicate holds; a rule `ancestor(X, Y) :- parent(X, Y).`
says that the head holds whenever the body does. This crate models the
ingredients of such a program, and nothing more:

- `Term` -- variables, constants, and structures, with lists as sugar over
  the `.`/`[]` functors;
- `Subst` and `unify` -- solving equations between terms, with the occurs
  check (a variable never binds to a term that contains it);
- `Clause`, `Goal`, `Database` -- facts, rules, and the program, indexed by
  predicate.

What is *missing* is the engine that runs a query: the depth-first SLD
resolver with backtracking. It matches a goal against clause heads by
unification, pushes one suspended derivation per matching clause, and falls
back when a branch dies. Building that resolver on top of these pieces is
the student project.

## API

| Item | Module | Purpose |
| --- | --- | --- |
| `Term::var`, `Term::atom`, `Term::struct_` | `term` | Build terms |
| `Term::nil`, `Term::cons`, `Term::list` | `term` | Build lists |
| `Term::vars`, `Term::contains` | `term` | Variable introspection, occurs check |
| `Subst` | `subst` | A substitution: `HashMap<usize, Term>` |
| `apply`, `apply_goal` | `subst` | Apply a substitution to a term / goal |
| `unify`, `UnifyError` | `unify` | Unify two terms, extending a substitution |
| `Goal::true_`, `Goal::call`, `Goal::conj` | `goal` | Build goals |
| `Clause::fact`, `Clause::rule` | `clause` | Build facts and rules |
| `Database::add`, `clauses_for` | `database` | The program, indexed by predicate |

## Demo

| Demo | Shows |
| --- | --- |
| `family_tree` | Facts and recursive rules over `parent`/`ancestor`, plus unifying a goal against a fact |
| `unify_demo` | Most general unifiers by hand; the occurs check rejecting `X = f(X)` |

## Tests

Unit tests live next to each module. Every public item carries a doctest.

## Out of scope

The core has no parser, no REPL, no arithmetic, no cut or negation, and no
SLD resolver. Building a parser for the `term.` / `?- term.` syntax, an
arithmetic `is`, a cut with its cut barrier, and the SLD resolver with
backtracking on top of this core is a student project.
