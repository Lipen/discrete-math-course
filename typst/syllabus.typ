#import "common.typ": *
#show: template

#set page(
  paper: "a4",
  margin: 2.5cm,
  header: [
    #set text(11pt)
    #smallcaps[*Syllabus*]
    #h(1fr)
    *Discrete Mathematics, Fall 2025*
    #place(bottom, dy: 0.4em)[
      #line(length: 100%, stroke: 0.6pt)
    ]
  ],
)

#set text(12pt)

#set par(justify: true)
#set heading(numbering: "1.")

#show table.cell.where(y: 0): strong

#show heading.where(level: 1): set block(below: 1em, above: 1.4em)
#show heading.where(level: 2): set block(below: 0.8em, above: 1em)

= Course Information

*Course Title:* Discrete Mathematics \
*Semester:* Fall 2025 \
*Prerequisites:* High school mathematics (algebra, basic logic) \
*Language:* Russian (verbal), English (materials) \
*Format:* In-person lectures with written assignments

= Course Description

This course covers fundamental concepts in discrete mathematics that form the foundation for computer science, mathematics, and logic. Students will learn to work with mathematical structures that are fundamentally discrete (rather than continuous) and develop skills in mathematical reasoning and proof.

The course emphasizes both theoretical understanding and practical applications. Students will learn to read, write, and construct mathematical proofs while solving problems in set theory, relations, Boolean algebra, and formal logic.

= Learning Objectives

By the end of this course, students will be able to:

+ Work confidently with sets, including operations, power sets, and cardinality
+ Understand and apply different types of binary relations (equivalence, order, functions)
+ Design and analyze Boolean expressions and digital logic circuits
+ Construct formal proofs using natural deduction and understand basic metalogical concepts
+ Read and write mathematical proofs with proper logical structure
+ Apply discrete mathematical concepts to problems in computer science and mathematics

= Course Modules

The course is organized into four main modules:

== Module 1: Set Theory (Weeks 1-4)
- Basic set operations and notation
- Power sets and cardinality
- Cartesian products and relations
- Russell's paradox and axiomatic foundations
- Applications to computer science

== Module 2: Binary Relations (Weeks 5-8)
- Properties of relations (reflexive, symmetric, transitive)
- Equivalence relations and partitions
- Order relations and lattices
- Functions as special relations
- Composition and closure operations

== Module 3: Boolean Algebra (Weeks 9-12)
- Boolean functions and truth tables
- Normal forms (CNF, DNF)
- Logic gates and digital circuits
- Karnaugh maps and minimization (Quine-McCluskey)
- Applications to computer hardware

== Module 4: Formal Logic (Weeks 13-16)
- Propositional logic: syntax and semantics
- Natural deduction and proof systems
- Traditional categorical logic and syllogisms
- Introduction to predicate logic
- Soundness and completeness theorems

= Assessment Structure

Your final grade will be calculated as follows:

#table(
  columns: 3,
  align: (left, center, right),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([Component], [Points Each], [Total Points]),
  [Homework Assignments (4)], [10], [40],
  [Module Tests (4)], [5], [20],
  [Theoretical Minimums (2)], [10], [20],
  [Final Exam], [20], [20],
  table.hline(stroke: 0.4pt),
  [*Total*], [], [*100*],
)

== Homework Assignments (40 points total)
- One homework per module, due at the end of each 4-week (approx) period
- Mix of computational problems and proof exercises
- Late submissions: punished
- Collaboration allowed, but solutions must be written independently

== Module Tests (20 points total)
- Long tests (90 minutes) covering material from each completed module
- Primarily computational problems and short derivations
- All sources allowed (notes, textbooks)
- No collaboration during tests

== Theoretical Minimums (20 points total)
- Two comprehensive exams testing deeper understanding
- TM1: Set Theory + Binary Relations (after week 8)
- TM2: Boolean Algebra + Formal Logic (after week 16)
- Include proof construction and theoretical questions
- Must pass both to receive credit for the course

== Final Exam (20 points total)
The final exam has three components:
+ *Written portion:* Problem solving across all modules
+ *Oral portion:* Explanation of key concepts and proof techniques
+ *Practical portion:* Application problems (circuit design, logical reasoning)

= Grading Scale

#table(
  columns: 2,
  align: center,
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Grade*], [*Points*]),
  [5], [91-100],
  [4], [74-90],
  [3], [60-73],
  [F], [< 60],
)

*Note:* Both theoretical minimums must be passed and all homeworks must be completed to receive a passing grade, regardless of total points.

= Course Policies

== Attendance
- Lectures are mandatory
- Material covered in lectures is essential for success

== Academic Integrity
- Homework: Collaboration encouraged, but write solutions independently
- Tests and exams: Individual work only
- Plagiarism or cheating will result in course failure

== Late Work
- Homework: -20% per day late, no submissions accepted after 1 week
- Tests: Make-up exams only for documented emergencies
- No extensions on theoretical minimums or final exam

= Materials

- *Primary:* Course lecture notes and homework assignments
- *Reference:* "Discrete Mathematics and Its Applications" by Kenneth Rosen

#pagebreak()

= Course Schedule

// TODO: reorganize the table
#table(
  columns: 4,
  align: (center, left, left, left),
  stroke: (x, y) => if y == 0 { (bottom: 0.8pt) },
  table.header([*Week*], [*Module*], [*Topics*], [*Assessments*]),
  [1-4], [Set Theory], [Sets, operations, cardinality, paradoxes, axiomatization], [HW1 due end of week 4],
  [5], [Binary Relations], [Introduction to relations, properties], [Test 1],
  [6-8], [Binary Relations], [Equivalence, order, functions, composition], [HW2 due end of week 8],
  [9], [—], [Theoretical Minimum 1], [TM1 exam, Test 2],
  [10-12], [Boolean Algebra], [Boolean functions, circuits, minimization], [HW3 due end of week 12],
  [13], [Formal Logic], [Propositional logic basics], [Test 3],
  [14-16], [Formal Logic], [Natural deduction, categorical logic, predicate logic], [HW4 due end of week 15],
  [16], [—], [Theoretical Minimum 2], [TM2 exam, Test 4],
  [17], [Finals], [Final examination period], [Final exam],
)

== Week 1: Set Theory
- Introduction to sets and notation
- Basic operations: union, intersection, difference
- Power sets and subsets
- Venn diagrams
- Cartesian products and geometric interpretation
- Russell's paradox

== Week 2: Set Theory
- Axiomatic foundations of set theory
- Zermelo-Fraenkel axioms overview
- Axiom of choice and its implications

== Week 3: Binary Relations
- Introduction to relations
- Graph representations of relations
- Matrix representation of relations
- Operations on relations
- Closures of relations
- Properties of homogeneous relations
- Reflexive, symmetric, transitive relations
- Equivalence relations and partitions

#line(length: 100%, stroke: 0.4pt)
- Homework 1 due
- Test 1 covering weeks 1-2 material

== Week 4: Binary Relations
- Order relations
- Chains and antichains
- Dilworth's theorem
- (?) Well-ordering principle
- Composition of relations
- Hasse diagrams

== Week 5: Binary Relations
- Functions as special types of relations
- Domain, codomain, range
- Injective, surjective, bijective functions
- Function composition
- Inverse functions
- Image and preimage of sets
- Pigeonhole principle

== Week 6: Set Theory (again)
- Cardinality of sets
- Infinite sets and countability
- Pairing functions
- Cantor's diagonal argument
- Uncountable sets
- Cantor's theorem
- Schroeder-Bernstein theorem
- Line and square paradox

== Week 7: Binary Relations
- Order theory
- Partially ordered sets (posets)
- Greatest lower bound and least upper bound
- Lattices and their properties
- Modular and distributive lattices
- Boolean algebras as special lattices

#line(length: 100%, stroke: 0.4pt)
- Homework 2 due
- Test 2 covering weeks 3-7 material
- Theoretical Minimum 1 covering Set Theory and Binary Relations

== Week 8: Boolean Algebra
- Boolean functions and truth tables
- Normal forms: CNF and DNF

== Week 9: Boolean Algebra
- Logic gates and digital circuits

== Week 10: Boolean Algebra
- Karnaugh maps and circuit minimization

#line(length: 100%, stroke: 0.4pt)
- Homework 3 due
- Test 3 covering weeks 8-10 material

== Week 11: Formal Logic
- Propositional logic: syntax and semantics
- Logical equivalences and implications

== Week 12: Formal Logic
- Natural deduction proof system
- Basic proof techniques
- Soundness and completeness of propositional logic
- Limitations of propositional logic

== Week 13: Formal Logic
- Introduction to predicate (first-order) logic
- Syntax and semantics of predicate logic
- Quantifiers: universal and existential
- Prenex normal form
- Gödel's completeness theorem
- Gödel's incompleteness theorems

== Week 14: Formal Logic
- Categorical logic
- A, E, I, O statements
- Traditional square of opposition
- Syllogisms and their validity
- Venn diagram representation of syllogisms
- Limitations of categorical logic

== Week 15: Formal Logic
- Review of formal logic concepts

#line(length: 100%, stroke: 0.4pt)
- Homework 4 due
- Test 4 covering weeks 11-15 material
- Theoretical Minimum 2 covering Boolean Algebra and Formal Logic

== Week 16: Formal Logic (extra)
- Ordinal and cardinal numbers
- Introduction to metalogical concepts

== Session
- Final exam covering all course material

= Getting Help

== Office Hours
- Instructor office hours: [To be announced]
- Teaching assistant hours: [To be announced]

== Additional Resources
- Course website: #link("https://github.com/Lipen/discrete-math-course")
- Study groups encouraged

== Communication
- Telegram chat for questions and announcements: [To be announced]

= Important Notes

- This course requires consistent effort throughout the semester
- Mathematical maturity develops gradually - expect initial difficulty with proofs
- Start homework assignments early to allow time for questions
- Form study groups, but ensure you understand material individually
- Attend every lecture --- discrete mathematics builds concepts cumulatively

*Success in this course requires active engagement with the material, not just memorization of formulas.*

#line(length: 100%, stroke: 0.4pt)

*This syllabus is subject to change with advance notice. Students are responsible for staying informed of any modifications.*
