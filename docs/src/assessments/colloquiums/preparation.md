# 📖 TM Preparation Guide

## 📅 Study Timeline

### 4 Weeks Before TM

| Focus | Activities |
|-------|-----------|
| **Content Review** | Read all lecture notes systematically |
| **Gap Identification** | List topics you find confusing |
| **Resource Gathering** | Collect textbook sections, homework solutions |
| **Initial Organization** | Create folder structure for study materials |

### 3 Weeks Before TM

| Focus | Activities |
|-------|-----------|
| **Concept Mapping** | Draw connections between topics visually |
| **Definition List** | Compile ALL definitions in one document |
| **Theorem List** | List all theorem statements (no proofs yet) |
| **Weak Area Focus** | Spend extra time on confusing topics |
| **Flashcard Creation** | Start making definition/theorem flashcards |

### 2 Weeks Before TM

| Focus | Activities |
|-------|-----------|
| **Daily Proofs** | Practice 3--5 proofs every day |
| **Study Group** | Form group, meet 2--3 times per week |
| **Flashcard Review** | Daily flashcard sessions (20--30 min) |
| **Office Hours** | Visit instructor/mentors with specific questions |
| **Practice Exams** | Attempt old TM questions under timed conditions |

### 1 Week Before TM

| Focus | Activities |
|-------|-----------|
| **Review Session** | Attend instructor's review session |
| **Practice Problems** | Work through comprehensive problem sets |
| **Definition Mastery** | Can recite all definitions word-perfect? |
| **Theorem Recall** | Practice stating theorems precisely |
| **Mock Exam** | Take full 120-min practice test |
| **Group Quizzing** | Quiz each other on random topics |

### 2--3 Days Before TM

| Focus | Activities |
|-------|-----------|
| **Light Review** | Skim through notes (don't cram new material) |
| **Flashcard Final Pass** | Review all flashcards one last time |
| **Rest & Recovery** | Reduce study intensity, avoid burnout |
| **Confidence Building** | Review what you DO know well |

### Day Before TM

| Focus | Activities |
|-------|-----------|
| **Minimal Study** | 30--60 min light review only |
| **Sleep Priority** | Get 8 hours of quality sleep |
| **Good Nutrition** | Eat healthy meals, stay hydrated |
| **Mental Prep** | Visualize success, stay positive |
| **Logistics** | Know exam location, bring ID |

## 🛠️ Proof Techniques

### Essential Proof Methods

| Type | When to Use | Template | Example |
|------|-------------|----------|---------|
| **Direct** | Straightforward implication | Assume P. Show Q follows. | If n even, then n² even |
| **Contradiction** | Proving impossibility | Assume ¬Q. Derive contradiction. | √2 is irrational |
| **Contrapositive** | Negation easier than direct | Prove ¬Q → ¬P instead of P → Q | If n² odd, then n odd |
| **Induction** | Properties of ℕ | Base case + inductive step | ∑ᵢ₌₁ⁿ i = n(n+1)/2 |
| **Construction** | Existence claims | Build explicit example | Bijection between A and B |
| **Cases** | Multiple scenarios | Case 1: ..., Case 2: ... | Prove for even and odd separately |

### Proof Writing Tips

> **✍️ Structure Every Proof**
>
> 1. **Opening**: State what you're proving
> 2. **Setup**: Define variables, state assumptions
> 3. **Body**: Logical argument with clear steps
> 4. **Conclusion**: "Therefore, ..." or "Thus, ..." or ∎
>
> **Bad**: "It's obvious that..."
> **Good**: "By definition of X, we have... Therefore..."

## 📚 What to Memorize

### 📐 Set Theory Essentials

| Category | Must Know |
|----------|-----------|
| **Set Laws** | Commutative, associative, distributive (3×2=6), De Morgan's (2), identity (2), complement (2), idempotent (2), domination (2), absorption (2), involution (1) = ~19 laws |
| **Power Set** | 𝒫(A) = {B \| B ⊆ A}, \|𝒫(A)\| = 2^|A| |
| **Cantor's Theorem** | For any set A, \|A\| < \|𝒫(A)\| (no surjection A → 𝒫(A)) |
| **Schroeder-Bernstein** | If ∃ injection A → B and ∃ injection B → A, then ∃ bijection A ↔ B |

### 🔗 Relations Essentials

| Category | Must Know |
|----------|-----------|
| **Properties** | Reflexive: ∀x (xRx); Symmetric: ∀x,y (xRy → yRx); Transitive: ∀x,y,z (xRy ∧ yRz → xRz); Antisymmetric: ∀x,y (xRy ∧ yRx → x=y) |
| **Equivalence** | Reflexive + symmetric + transitive ↔ partition |
| **Functions** | Injective: f(a)=f(b) → a=b; Surjective: ∀y ∃x f(x)=y; Bijective: both |
| **Composition** | (g ∘ f)(x) = g(f(x)); associative; inverse if bijective |

### ⚡ Boolean Algebra Essentials

| Category | Must Know |
|----------|-----------|
| **Boolean Laws** | Identity (x∨0=x, x∧1=x), Null (x∨1=1, x∧0=0), Idempotent (x∨x=x, x∧x=x), Complement (x∨¬x=1, x∧¬x=0), De Morgan's (¬(x∨y)=¬x∧¬y, ¬(x∧y)=¬x∨¬y), Absorption (x∨(x∧y)=x, x∧(x∨y)=x) |
| **Normal Forms** | DNF: OR of ANDs (∨ᵢ(∧ⱼ)); CNF: AND of ORs (∧ᵢ(∨ⱼ)) |
| **Completeness** | {AND, OR, NOT}, {NAND}, {NOR} are functionally complete |
| **Gate Symbols** | Know circuit symbols for AND, OR, NOT, NAND, NOR, XOR |

### 🧠 Formal Logic Essentials

| Category | Must Know |
|----------|-----------|
| **Truth Tables** | ¬, ∧, ∨, →, ↔ truth values for all combinations |
| **Natural Deduction** | Modus Ponens (P, P→Q ⊢ Q), Modus Tollens (¬Q, P→Q ⊢ ¬P), ∧-Intro, ∨-Elim, etc. |
| **Soundness vs Completeness** | Soundness: ⊢ implies ⊨ (no false proofs); Completeness: ⊨ implies ⊢ (can prove all truths) |
| **Quantifiers** | ¬(∀x P(x)) ≡ ∃x ¬P(x); ¬(∃x P(x)) ≡ ∀x ¬P(x) |

## 🧠 Study Strategies

### Active Learning Techniques

| Technique | How It Works | Why It's Effective |
|-----------|--------------|-------------------|
| **Active Recall** | Close notes, write from memory | Strengthens retrieval pathways |
| **Spaced Repetition** | Review at increasing intervals | Fights forgetting curve |
| **Teach Others** | Explain concepts to study partner | Best test of understanding |
| **Practice Exams** | Simulate exam conditions | Builds familiarity, reduces anxiety |
| **Whiteboard Practice** | Work standing up, large space | Engages different cognitive pathways |
| **Interleaving** | Mix topics rather than blocking | Improves discrimination and retention |

### Study Group Best Practices

✅ **Do This:**
- Meet regularly (2--3 times per week)
- Quiz each other on definitions/theorems
- Work through proofs together
- Explain difficult concepts to each other
- Share different solution approaches

❌ **Don't Do This:**
- Just socialize without studying
- Let one person do all the explaining
- Skip individual preparation before meeting
- Argue about minutiae; ask instructor to clarify
- Study only in groups (need solo time too!)

## 📖 Resources to Use

### Primary Resources

| Resource | How to Use | Priority |
|----------|-----------|----------|
| **Lecture Slides** | Main source of definitions/theorems | ⭐⭐⭐⭐⭐ |
| **Textbook** | Detailed explanations and examples | ⭐⭐⭐⭐ |
| **Homework Solutions** | See proof techniques in action | ⭐⭐⭐⭐ |
| **Review Sessions** | Clarify confusions, get exam hints | ⭐⭐⭐⭐⭐ |
| **Mentors/Office Hours** | Personalized help on weak areas | ⭐⭐⭐⭐⭐ |

### Supplementary Resources

| Resource | Benefit | When to Use |
|----------|---------|-------------|
| **Online Videos** | Visual explanations | When reading isn't clicking |
| **Math StackExchange** | See different proof approaches | For alternative perspectives |
| **Practice Problems** | Build problem-solving skills | Throughout preparation |
| **Old Exams** | Know question formats | Final week preparation |

## ⚠️ Common Mistakes

### Logical Errors

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| **Circular Reasoning** | Assumes what you're proving | Ensure logical flow: premises → conclusion |
| **Using "Obvious"** | Skips justification | Provide explicit reasoning |
| **Confusing Necessary/Sufficient** | P→Q: Q necessary for P, P sufficient for Q | Remember the direction! |
| **Wrong Quantifier Order** | ∀x∃y P(x,y) ≠ ∃y∀x P(x,y) | Be precise with quantifier scope |
| **Incomplete Cases** | Miss edge cases | Systematically check all scenarios |

### Proof-Writing Errors

| Mistake | Example | Correction |
|---------|---------|------------|
| **No setup** | "Therefore x = 5" | "Let x be arbitrary. Then..." |
| **Jumping steps** | "Clearly A = B" | Show intermediate steps |
| **Poor notation** | Using same variable for different things | Define all variables clearly |
| **No conclusion** | Proof just stops | End with "Therefore..." or ∎ |

## 🌙 Day Before TM

### What TO DO

✅ Light review (1 hour max):
- Skim definition flashcards
- Glance at theorem list
- Review 1--2 key proofs

✅ Self-care:
- **8 hours of sleep** (non-negotiable!)
- Healthy meals throughout the day
- Light exercise or walk
- Relaxation techniques (deep breathing, meditation)

✅ Logistics:
- Confirm exam time and location
- Prepare ID and any allowed materials
- Set multiple alarms
- Plan to arrive 10 min early

### What NOT TO DO

❌ **Don't cram new material** -- if you don't know it now, won't learn it tonight
❌ **Don't stay up late studying** -- sleep > cramming
❌ **Don't drink excessive caffeine** -- disrupts sleep quality
❌ **Don't panic** -- trust your preparation
❌ **Don't compare yourself to others** -- focus on your own readiness

## 💪 Mental Preparation

### Confidence Builders

> **🎯 Positive Self-Talk**
>
> - "I've prepared thoroughly for this."
> - "I know the material well."
> - "Partial credit means every bit of knowledge counts."
> - "I can handle difficult questions -- I'll do my best."
> - "One exam doesn't define me or my understanding."

### During the Exam

| Situation | Response |
|-----------|----------|
| **Can't remember definition** | Move on, come back later; write related concepts |
| **Proof seems impossible** | Write setup, state approach, show what you can |
| **Running out of time** | Prioritize high-value questions; outline remaining proofs |
| **Feeling anxious** | Deep breath, 30-second break, refocus |
| **Blank mind** | Read question again slowly; write anything related |

## 🎓 Final Wisdom

> **Remember**: TMs test understanding, not just memorization. Focus on:
>
> - **Why** definitions are structured that way
> - **How** theorems connect to each other
> - **When** to apply different proof techniques
> - **What** the big ideas are, not just details
>
> Trust your preparation, stay calm, and do your best. Good luck! 🍀
