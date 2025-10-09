# 🧠 Test 4 -- Formal Logic

## 📅 Test Details

| Detail | Information |
|--------|-------------|
| **Week** | Week 15 (Fall) |
| **Coverage** | Weeks 11--15 |
| **Duration** | 90 minutes |
| **Topics** | Propositional logic, natural deduction, predicate logic, quantifiers, syllogisms |

## 📚 Topics Covered

### Core Concepts

- **Propositional Logic**: Syntax, semantics, truth tables
- **Natural Deduction**: Proof systems and inference rules
- **Logical Equivalence**: Tautologies and contradictions
- **Logical Consequence**: Validity and entailment
- **Predicate Logic**: First-order logic with variables
- **Quantifiers**: Universal (∀) and existential (∃)
- **Categorical Logic**: Aristotelian syllogisms

### Key Inference Rules

| Rule | Form | Example |
|------|------|---------|
| **Modus Ponens** | P, P → Q ⊢ Q | "If raining, wet. Raining. ∴ Wet." |
| **Modus Tollens** | ¬Q, P → Q ⊢ ¬P | "If raining, wet. Not wet. ∴ Not raining." |
| **Disjunctive Syllogism** | P ∨ Q, ¬P ⊢ Q | "Coffee or tea. No coffee. ∴ Tea." |
| **Conjunction** | P, Q ⊢ P ∧ Q | "Raining. Cold. ∴ Raining and cold." |
| **Simplification** | P ∧ Q ⊢ P | "Raining and cold. ∴ Raining." |

### Quantifier Equivalences

| Equivalence | Formula |
|-------------|---------|
| **Negation** | ¬(∀x P(x)) ≡ ∃x ¬P(x) |
| **Negation** | ¬(∃x P(x)) ≡ ∀x ¬P(x) |
| **Distribution** | ∀x (P(x) ∧ Q(x)) ≡ (∀x P(x)) ∧ (∀x Q(x)) |

## 🎯 Sample Problem Types

| Type | Example |
|------|---------|
| **Tautologies** | Determine if (P → Q) ∨ (Q → P) is a tautology |
| **Proofs** | Prove P → Q, Q → R ⊢ P → R using natural deduction |
| **Equivalence** | Show (P → Q) ≡ (¬P ∨ Q) using truth tables |
| **Translation** | Translate "Every student loves some professor" to predicate logic |
| **Validity** | Determine if ∀x P(x) → Q(x), P(a) ⊢ Q(a) is valid |
| **Syllogisms** | Analyze "All men are mortal. Socrates is a man. ∴ Socrates is mortal." |

## ✅ Key Skills You'll Need

- ✓ **Semantic analysis** -- use truth tables to check tautologies/contradictions
- ✓ **Proof construction** -- apply inference rules in natural deduction
- ✓ **Logical reasoning** -- recognize valid argument forms
- ✓ **Quantifier manipulation** -- push/pull negations through ∀ and ∃
- ✓ **Translation skills** -- convert English to formal logic notation
- ✓ **Syllogistic logic** -- analyze classical argument forms

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
> - Quantifier negation: ¬(∀x P(x)) is ∃x ¬P(x), NOT ∀x ¬P(x)
> - Scope matters: ∀x (P(x) → Q(x)) ≠ (∀x P(x)) → (∀x Q(x))
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
