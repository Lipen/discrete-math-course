[private]
default:
    @just --list

[doc('Build every PDF deliverable: book, lectures, course, homework.')]
all: book lectures course homework

[doc('Build the book.')]
book:
    just book/build

[doc('Build all lecture decks.')]
lectures:
    just lectures/all

[doc('Build the course documents.')]
course:
    just course/all

[doc('Build the homework sets.')]
homework:
    just homework/all

# Strict on purpose: a page without <!-- @head --> fails the build instead of shipping stale markup.
[doc('Build the lab into lab/dist.')]
lab:
    cd lab && bun run build.ts --strict

[doc('Typecheck, lint, test and build the lab.')]
lab-check:
    cd lab && bunx tsc --noEmit
    cd lab && bun run lint
    cd lab && bun test
    just lab

[doc('Run the browser smoke over lab/dist.')]
lab-smoke:
    cd lab && bun run smoke

[doc('Serve the lab on http://localhost:8765, rebuilding on change.')]
lab-dev:
    cd lab && bun run dev

# site/build.py copies lab/dist, so the hub is never built against a missing lab.
[doc('Build the site hub into site/dist.')]
site: lab
    uv run site/build.py

[doc('Build and serve the site with local PDFs on http://localhost:8765.')]
site-serve: lab
    uv run site/build.py --preview
    bun site/serve.ts site/dist 8765

[doc('Run the Rust crate tests.')]
test:
    just code/test
