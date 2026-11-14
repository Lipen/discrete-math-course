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

# Build the site hub (site/dist)
site:
    python3 site/build.py

# Build the site with local copies of the PDFs and serve it on http://localhost:8765
site-serve:
    python3 site/build.py --preview
    python3 -m http.server -d site/dist 8765

# Build all homeworks
homework:
    just homework/all

# Run all Rust crate tests
test:
    just code/test
