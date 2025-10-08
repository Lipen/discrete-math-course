# ⚡ Module 3: Boolean Algebra

**Duration**: Weeks 8-10

## 📚 Core Topics

### Boolean Functions (Week 8)

- **Truth Tables**: Complete function specification
- **Basic Operations**: AND (∧), OR (∨), NOT (¬), XOR (⊕), NAND (↑), NOR (↓)
- **Boolean Laws**: Commutative, associative, distributive, De Morgan's
- **Duality Principle**: Swapping ∧↔∨ and 0↔1
- **Normal Forms**:
  - DNF (Disjunctive): Sum of products
  - CNF (Conjunctive): Product of sums
  - Perfect/Canonical forms

### Digital Circuits (Week 9)

- **Logic Gates**: Physical implementation of Boolean operations
- **Circuit Design**: From truth table to circuit
- **Analysis**: From circuit to Boolean expression
- **Multi-level Circuits**: Optimization and complexity
- **Functional Completeness**: Minimal operation sets
- **Universal Gates**: NAND and NOR alone suffice

### Minimization (Week 10)

- **Karnaugh Maps (K-maps)**: Visual minimization (2-4 variables)
- **Don't Care Conditions**: Flexible outputs for optimization
- **Quine-McCluskey**: Algorithmic minimization (any number of variables)
- **Prime Implicants**: Essential and non-essential

## 🔑 Key Concepts

| Concept | Definition | Example |
|---------|------------|---------|
| **Boolean Function** | f: {0,1}ⁿ → {0,1} | f(x,y) = x ∧ ¬y |
| **DNF** | Sum of products (OR of ANDs) | (x∧y) ∨ (¬x∧z) |
| **CNF** | Product of sums (AND of ORs) | (x∨y) ∧ (¬x∨z) |
| **Functionally Complete** | Can express any Boolean function | {∧,∨,¬}, {NAND}, {NOR} |

> **💡 De Morgan's Laws:**
> ¬(x ∧ y) = ¬x ∨ ¬y
> ¬(x ∨ y) = ¬x ∧ ¬y

## 💡 Applications

> **Where you'll use this:**

- 💻 Digital circuit design and hardware
- 🖥️ Computer architecture (ALU, CPU design)
- 🧩 SAT solvers and automated reasoning

## ✅ Learning Outcomes

By the end of this module, you will be able to:

- Construct and analyze truth tables for Boolean expressions
- Convert between DNF, CNF, and arbitrary Boolean forms
- Simplify expressions using Boolean laws and duality
- Design and analyze digital circuits using logic gates
- Minimize Boolean functions with Karnaugh maps
- Prove sets of operations are functionally complete
