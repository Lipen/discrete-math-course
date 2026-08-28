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

# Build all homeworks
homework:
    just homework/all

# Run all Rust crate tests
test:
    just code/test
