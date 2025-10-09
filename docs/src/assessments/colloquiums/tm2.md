# ⚡🧠 TM2 -- Boolean Algebra + Formal Logic

## 📅 Exam Details

| Detail | Information |
|--------|-------------|
| **When** | Week 15 (Fall) -- after Test 4 |
| **Duration** | 120 minutes |
| **Format** | Closed book (no notes, no materials) |
| **Passing** | ≥5.0/10 required |
| **Retake** | Available if needed (different questions) |

## 📚 Coverage

### ⚡ Boolean Algebra (Weeks 8--10)

- Boolean functions and truth tables
- Boolean laws and duality principle
- Normal forms (DNF, CNF)
- Logic gates (\\(\land, \lor, \lnot, \text{NAND}, \text{NOR}, \oplus\\))
- Functional completeness
- Karnaugh maps
- Quine-McCluskey algorithm

### 🧠 Formal Logic (Weeks 11--15)

- Propositional logic (syntax and semantics)
- Tautologies, contradictions, contingencies
- Logical equivalence (\\(\equiv\\)) and consequence (\\(\models\\))
- Natural deduction proof systems
- Soundness and completeness
- Predicate logic with quantifiers (\\(\forall, \exists\\))
- Categorical logic and syllogisms

## 📝 Sample Questions

### Definitions

- Define tautology, contradiction, contingency
- What is functional completeness?
- Define logical consequence
- What is DNF? What is CNF?
- Define soundness vs completeness

### Theorems

- State the completeness theorem (if \\(\Gamma \models \varphi\\) then \\(\Gamma \vdash \varphi\\))
- Show \\(\{\text{NAND}\}\\) is functionally complete
- Every Boolean function has DNF representation
- De Morgan's laws: \\(\lnot(P \lor Q) \equiv \lnot P \land \lnot Q\\) and \\(\lnot(P \land Q) \equiv \lnot P \lor \lnot Q\\)

### Proofs

- Prove \\((P \to Q) \land (Q \to R) \vdash (P \to R)\\) using natural deduction
- Show De Morgan's law using truth table or Boolean algebra
- Prove a tautology is valid in all interpretations
- Show \\(\{\text{NAND}\}\\) can express AND, OR, NOT

### Conceptual

- Relationship between Boolean algebra and logic?
- Difference between soundness and completeness?
- Why can't we use truth tables for predicate logic?
- What makes a gate set universal?

## ✅ What You Must Know

- Boolean operations (\\(\land, \lor, \lnot\\)) and laws
- DNF and CNF normal forms
- Functional completeness concept
- Tautologies, contradictions, contingencies
- Logical equivalence (\\(\equiv\\)) and consequence (\\(\models\\))
- Soundness vs completeness distinction (\\(\vdash \Rightarrow \models\\) vs \\(\models \Rightarrow \vdash\\))
- Natural deduction inference rules (modus ponens, modus tollens, etc.)
- Quantifier negation rules: \\(\lnot(\forall x\, P(x)) \equiv \exists x\, \lnot P(x)\\)
- Key theorems: Completeness theorem, De Morgan's laws, functional completeness proofs
- Proof techniques: truth tables, Boolean algebra, natural deduction, gate construction

## 📖 Preparation Checklist

### ✅ Week 14 (2 weeks before)

- [ ] Review all lecture notes from Weeks 8--15
- [ ] Memorize all Boolean laws
- [ ] List all natural deduction rules
- [ ] Practice 5+ proofs in natural deduction

### ✅ Week 15 (1 week before)

- [ ] Can recite all definitions precisely?
- [ ] Practice functional completeness proofs
- [ ] Join study group, quiz on theorems
- [ ] Attend review session

### ✅ Day Before

- [ ] Review flashcards once
- [ ] Skim theorem statements
- [ ] **Get 8 hours sleep!**
- [ ] Stay calm and confident

## 💡 Pro Tips

> **🎯 Success Strategy**
>
> - **Laws are your tools**: Memorize Boolean laws cold
> - **Name your inference rules**: In proofs, cite "Modus Ponens", "∧-Intro", etc.
> - **Truth tables work**: When stuck, build truth table
> - **K-maps are visual**: Practice grouping patterns
> - **Quantifiers are tricky**: Double-check negations

### Common Pitfalls to Avoid

- ❌ Confusing \\(\models\\) (semantic consequence) and \\(\vdash\\) (syntactic provability)
- ❌ Wrong quantifier negation: \\(\lnot\forall x\, P(x)\\) is \\(\exists x\, \lnot P(x)\\), NOT \\(\forall x\, \lnot P(x)\\)
- ❌ Forgetting to justify proof steps
- ❌ K-map groups not power-of-2 sizes
- ❌ Mixing up soundness and completeness

### What Graders Look For

- ✓ Exact definitions (word-for-word accuracy)
- ✓ Named inference rules in proofs
- ✓ Clear step-by-step Boolean simplifications
- ✓ Correct gate constructions for completeness
- ✓ Proper quantifier manipulation
- ✓ Understanding of soundness/completeness distinction
