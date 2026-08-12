# prolog

A miniature Prolog: terms, unification, and SLD resolution.

A teaching crate for the logic-programming chapter: a deliberately small
model of Prolog's core as a mathematical system. No parser, no REPL, no
arithmetic, no cut -- the language stops where the theory is complete and
a student project begins.

## Quick start

```bash
cargo run -p prolog --example family_tree
cargo run -p prolog --example reachability
cargo run -p prolog --example unify_demo
cargo run -p prolog --example sld_trace
cargo test -p prolog
```

## The idea

A logic program is a set of definite clauses. A fact `parent(alice, bob).`
asserts that a predicate holds; a rule `ancestor(X, Y) :- parent(X, Y).`
says that the head holds whenever the body does. A query `?- ancestor(alice, Y).`
asks which substitutions of `Y` make the goal a logical consequence of the
program.

The solver answers by SLD resolution: it keeps the leftmost goal, matches
it against the program clauses in order by unification, and pushes one
suspended derivation per matching clause. Depth-first search with a stack
of choice points, falling back when a branch dies -- that is backtracking.

The crate models each ingredient separately:

- `Term` -- variables, constants, and structures, with lists as sugar over
  the `.`/`[]` functors;
- `Subst` and `unify` -- solving equations between terms, with the occurs
  check (a variable never binds to a term that contains it);
- `Clause`, `Goal`, `Database` -- facts, rules, and the program;
- `Solver` -- the SLD search, one solution per `next_solution` call, plus a
  bounded variant for studying non-termination and a trace for watching the
  search.

The search tree for `ancestor(alice, Y)` with the base rule first:

```text
?- ancestor(alice, Y).
    ancestor(alice, Y)
    +-- ancestor(alice, Y) :- parent(alice, Y).        -> parent(alice, Y) -> Y = bob
    +-- ancestor(alice, Y) :- parent(alice, Z), ancestor(Z, Y).
        +-- parent(alice, Z) -> Z = bob, ancestor(bob, Y)
            +-- ... (base rule)                        -> Y = carol
            +-- ... (recursive rule)                   -> Y = dave
```

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
| `Query::new`, `Query::answer` | `query` | A goal with named answer variables |
| `Database::add`, `clauses_for` | `database` | The program, indexed by predicate |
| `rename_clause` | `rename` | Standardize a clause apart |
| `Solver::solve` | `solver` | Collect up to N solutions |
| `Solver::solve_bounded` | `solver` | Solve under a step budget |
| `Solver::solve_traced`, `TraceEvent` | `solver` | Solve and record the search |

## Demo

| Demo | Shows |
| --- | --- |
| `family_tree` | Facts and recursive rules over `parent`/`ancestor`; answers in program order |
| `reachability` | Graph reachability as recursive rules; the terminating (right-recursive) form |
| `unify_demo` | Most general unifiers by hand; the occurs check rejecting `X = f(X)` |
| `sld_trace` | The SLD search as a transcript: calls, clause selections, backtracking |

## Tests

Unit tests live next to each module; `tests/scenarios.rs` runs whole
programs end to end (append splitting a list, reverse, reachability).
Every public item carries a doctest.

## Out of scope

The core has no parser, no REPL, no arithmetic, and no cut or negation.
Building a parser for the `term.` / `?- term.` syntax, an arithmetic `is`,
or a cut with its cut barrier on top of `Solver` is a student project.
