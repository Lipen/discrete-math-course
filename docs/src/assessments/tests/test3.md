# ⚡ Test 3 -- Boolean Algebra

## 📅 Test Details

| Detail | Information |
|--------|-------------|
| **Week** | Week 10 (Fall) |
| **Coverage** | Weeks 8--10 |
| **Duration** | 90 minutes |
| **Topics** | Boolean functions, normal forms, circuits, K-maps, minimization |

## 📚 Topics Covered

- Boolean functions and truth tables
- Normal forms (DNF, CNF)
- Logic gates and circuits
- Karnaugh maps for minimization
- Boolean simplification using laws
- Functional completeness

## 🎯 Sample Problem Types

- **Truth Tables**: Construct truth table for \\((x \land y) \lor (\lnot x \land z)\\)
- **Normal Forms**: Convert \\(f(x,y,z) = (x \to y) \land z\\) to DNF and CNF
- **Simplification**: Simplify \\(x \land (\lnot x \lor y)\\) using Boolean laws
- **Circuits**: Design circuit for majority function (3 inputs)
- **K-Maps**: Use K-map to minimize \\(f(w,x,y,z)\\) given minterms
- **Completeness**: Prove \\(\{\text{NAND}\}\\) is functionally complete

## ✅ Key Skills You'll Need

- Building truth tables systematically
- Converting to normal forms
- Simplifying Boolean expressions
- Designing logic circuits
- Using K-map technique for minimization
- Understanding functional completeness

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
> - De Morgan's Laws: \\(\lnot(x \lor y) = \lnot x \land \lnot y\\) and \\(\lnot(x \land y) = \lnot x \lor \lnot y\\)
> - K-map groupings: must be rectangles with power-of-2 sizes (1, 2, 4, 8...)
> - Circuit notation: distinguish AND (\\(\land\\)) from OR (\\(\lor\\)) symbols
> - DNF vs CNF: DNF is OR of ANDs; CNF is AND of ORs
> - Don't forget: NOT gate inverts (bubble on circuit diagrams)

## 💡 Pro Tips

- **Truth tables first** -- when stuck, build truth table
- **K-maps are visual** -- look for largest groupings first
- **Simplify before circuits** -- smaller expressions = fewer gates
- **Test with cases** -- verify circuit with sample inputs
- **Know your laws** -- memorize De Morgan's, distributive, absorption
- **Draw clearly** -- messy circuits lead to errors
