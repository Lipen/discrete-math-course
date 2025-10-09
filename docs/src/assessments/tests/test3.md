# ⚡ Test 3 -- Boolean Algebra

## 📅 Test Details

| Detail | Information |
|--------|-------------|
| **Week** | Week 10 (Fall) |
| **Coverage** | Weeks 8--10 |
| **Duration** | 90 minutes |
| **Topics** | Boolean functions, normal forms, circuits, K-maps, minimization |

## 📚 Topics Covered

### Core Concepts

- **Boolean Functions**: Truth tables and Boolean expressions
- **Normal Forms**: DNF (Disjunctive), CNF (Conjunctive)
- **Logic Gates**: AND, OR, NOT, NAND, NOR, XOR
- **Circuits**: Gate-level design and analysis
- **Karnaugh Maps**: Visual minimization technique (2--4 variables)
- **Boolean Simplification**: Using algebraic laws
- **Functional Completeness**: Universal gate sets

### Essential Boolean Laws

| Law | Formula |
|-----|---------|
| **Identity** | x ∨ 0 = x, x ∧ 1 = x |
| **Null** | x ∨ 1 = 1, x ∧ 0 = 0 |
| **Idempotent** | x ∨ x = x, x ∧ x = x |
| **Complement** | x ∨ ¬x = 1, x ∧ ¬x = 0 |
| **De Morgan's** | ¬(x ∨ y) = ¬x ∧ ¬y, ¬(x ∧ y) = ¬x ∨ ¬y |
| **Absorption** | x ∨ (x ∧ y) = x, x ∧ (x ∨ y) = x |

## 🎯 Sample Problem Types

| Type | Example |
|------|---------|
| **Truth Tables** | Construct truth table for (x ∧ y) ∨ (¬x ∧ z) |
| **Normal Forms** | Convert f(x,y,z) = (x → y) ∧ z to DNF and CNF |
| **Simplification** | Simplify x ∧ (¬x ∨ y) using Boolean laws |
| **Circuits** | Design circuit for majority function (3 inputs) |
| **K-Maps** | Use K-map to minimize f(w,x,y,z) given minterms |
| **Completeness** | Prove {NAND} is functionally complete |

## ✅ Key Skills You'll Need

- ✓ **Truth table construction** -- systematic enumeration of all cases
- ✓ **Normal form conversions** -- DNF from truth table, CNF by negation
- ✓ **Expression simplification** -- apply Boolean laws correctly
- ✓ **Circuit design** -- translate Boolean expressions to gates
- ✓ **K-map technique** -- grouping minterms in powers of 2
- ✓ **Understanding completeness** -- express all functions with given gates

## 📖 Preparation Guide

### Review Materials

1. **Lecture Notes**: Module 3 (Weeks 8--10)
2. **Homework**: Rework all HW3 problems
3. **Textbook**: Rosen Ch 12.1--12.4
4. **Practice**: K-maps for 2, 3, and 4 variables

### Practice Problems

- **Truth Tables**: Build tables for 5--10 complex expressions
- **DNF/CNF**: Convert between forms for various functions
- **Boolean Laws**: Simplify 10+ expressions step-by-step
- **Circuits**: Draw circuits for common functions (adders, multiplexers)
- **K-Maps**: Minimize 20+ functions (including don't cares)
- **Completeness**: Practice expressing AND, OR, NOT with NAND

### Common Pitfalls

> **⚠️ Watch Out!**
>
> - De Morgan's Laws: distribute negation through AND/OR correctly
> - K-map groupings: must be rectangles with power-of-2 sizes (1, 2, 4, 8...)
> - Circuit notation: distinguish AND (∧) from OR (∨) symbols
> - DNF vs CNF: DNF is OR of ANDs; CNF is AND of ORs
> - Don't forget: NOT gate inverts (bubble on circuit diagrams)

## 💡 Pro Tips

- **Truth tables first** -- when stuck, build truth table
- **K-maps are visual** -- look for largest groupings first
- **Simplify before circuits** -- smaller expressions = fewer gates
- **Test with cases** -- verify circuit with sample inputs
- **Know your laws** -- memorize De Morgan's, distributive, absorption
- **Draw clearly** -- messy circuits lead to errors
