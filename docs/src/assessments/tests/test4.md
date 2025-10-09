# 🧠 Test 4 -- Formal Logic

## 📅 Test Details

| Detail | Information |
|--------|-------------|
| **Week** | Week 15 (Fall) |
| **Coverage** | Weeks 11--15 |
| **Duration** | 90 minutes |
| **Topics** | Propositional logic, natural deduction, predicate logic, quantifiers, syllogisms |

## 📚 Topics Covered

- Propositional logic (syntax and semantics)
- Natural deduction proofs
- Logical equivalence (\\(\equiv\\)) and consequence (\\(\models\\))
- Predicate logic basics
- Quantifiers (\\(\forall\\) universal, \\(\exists\\) existential)
- Categorical logic and syllogisms

## 🎯 Sample Problem Types

- **Tautologies**: Determine if \\((P \to Q) \lor (Q \to P)\\) is a tautology
- **Proofs**: Prove \\(P \to Q, Q \to R \vdash P \to R\\) using natural deduction
- **Equivalence**: Show \\((P \to Q) \equiv (\lnot P \lor Q)\\) using truth tables
- **Translation**: Translate "Every student loves some professor" to predicate logic
- **Validity**: Determine if \\(\forall x\, (P(x) \to Q(x)), P(a) \vdash Q(a)\\) is valid
- **Syllogisms**: Analyze "All men are mortal. Socrates is a man. \\(\therefore\\) Socrates is mortal."

## ✅ Key Skills You'll Need

- Semantic analysis using truth tables
- Constructing proofs with natural deduction
- Logical reasoning with inference rules
- Manipulating quantifiers correctly
- Translating between English and formal logic
- Understanding syllogistic logic

## 📖 Preparation Guide

### Review Materials

1. **Lecture Notes**: Module 4 (Weeks 11--15)
2. **Homework**: Rework all HW4 problems
3. **Textbook**: Rosen Ch 1.1--1.5
4. **Practice**: Natural deduction proofs (10+ examples)

### Practice Problems

- **Tautologies**: Test 10--15 formulas using truth tables
- **Proofs**: Complete natural deduction proofs for common theorems
- **Equivalences**: Show logical equivalence for 5--10 pairs
- **Translation**: Convert 20+ English sentences to predicate logic
- **Quantifiers**: Negate complex quantified formulas
- **Syllogisms**: Analyze validity of classical argument forms

### Common Pitfalls

> **⚠️ Watch Out!**
>
> - Quantifier negation: \\(\lnot(\forall x\, P(x))\\) is \\(\exists x\, \lnot P(x)\\), NOT \\(\forall x\, \lnot P(x)\\)
> - Scope matters: \\(\forall x\, (P(x) \to Q(x)) \not\equiv (\forall x\, P(x)) \to (\forall x\, Q(x))\\)
> - In proofs: justify every step with a rule name
> - Translation: "only" is not the same as "all" (contrapositive!)
> - Syllogisms: check for fallacies (undistributed middle, etc.)

## 💡 Pro Tips

- **Truth tables work** -- when unsure about tautology, build the table
- **Proof strategy** -- work backwards from conclusion to find needed steps
- **Name your rules** -- explicitly cite modus ponens, ∧-intro, etc.
- **Quantifier scope** -- use parentheses to clarify scope clearly
- **Practice translation** -- "all", "some", "no", "only" have precise meanings
- **Check validity** -- valid argument = impossible for premises true and conclusion false
