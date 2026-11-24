[private]
default:
    @just --list

# Build everything (book, lectures, course docs, homeworks)
all: book lectures course homework

# Build the book
book:
    just book/build

# Build all lectures
lectures:
    just lectures/all

# Build all course documents
course:
    just course/all

# Build the lab bundles and pages into lab/dist
lab:
    cd lab && bun run build

# Strict lab build: every page must be on the new pipeline
lab-strict:
    cd lab && bun run build.ts --strict

# Typecheck, unit tests and strict build of the lab
lab-check:
    cd lab && bunx tsc --noEmit
    cd lab && bun test
    cd lab && bun run build.ts --strict

# Browser smoke over lab/dist
lab-smoke:
    cd lab && bun run smoke

# Rebuild the lab on change and serve it on http://localhost:8765
lab-dev:
    cd lab && bun run dev

# Build the site hub (site/dist); rebuilds the lab first
site: lab
    python3 site/build.py

# Build the site with local copies of the PDFs and serve it on http://localhost:8765
site-serve: lab
    python3 site/build.py --preview
    python3 -m http.server -d site/dist 8765

# Build all homeworks
homework:
    just homework/all

# Run all Rust crate tests
test:
    just code/test
