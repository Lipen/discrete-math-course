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

- **Truth Tables**: Construct truth table for given Boolean expression
- **Normal Forms**: Convert given function to DNF and CNF
- **Simplification**: Simplify Boolean expressions using laws
- **Circuits**: Design circuit for majority function
- **K-Maps**: Use K-map to minimize given function
- **Completeness**: Prove {NAND} is functionally complete

## 📖 Preparation Guide

### Review Materials

1. **Lecture Notes**: Module 3 (Boolean Algebra)
2. **Homework**: HW 3
3. **Textbook**: Kenneth Rosen

### Practice Problems

- **Truth Tables**: Build tables for 5--10 complex expressions
- **DNF/CNF**: Convert between forms for various functions
- **Boolean Laws**: Simplify 10+ expressions step-by-step
- **Circuits**: Draw circuits for common functions (adders, multiplexers)
- **K-Maps**: Minimize 20+ random functions (including don't cares)
- **Completeness**: Practice expressing AND, OR, NOT with NAND

### Common Pitfalls

> **⚠️ Watch Out!**
>
> - De Morgan's Laws: \\( \overline{x \vee y} = \overline{x} \wedge \overline{y} \\), and \\( \overline{x \wedge y} = \overline{x} \vee \overline{y} \\)
> - K-map groupings: must be rectangles with power-of-2 sizes (1, 2, 4, 8...)
> - Circuit notation: distinguish AND from OR gate symbols
> - DNF vs CNF: DNF is OR of ANDs; CNF is AND of ORs
> - Don't forget: NOT gate inverts (circles on circuit diagrams)

## 💡 Pro Tips

- **Truth tables first** -- when stuck, build truth table
- **K-maps are visual** -- look for largest groupings first
- **Simplify before circuits** -- smaller expressions = fewer gates
- **Test with cases** -- verify circuit with sample inputs
- **Know your laws** -- memorize De Morgan's, distributive, absorption
- **Draw clearly** -- messy circuits lead to errors
