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
  footer: [
    #set text(10pt, fill: gray)
    #datetime.today().display()
    #h(1fr)
    #link("https://github.com/Lipen/discrete-math-course")
  ],
)

#set text(12pt)

#set par(justify: true)
#set heading(numbering: "1.")

#show table.cell.where(y: 0): strong

#show heading.where(level: 1): set block(below: 1em, above: 1.4em)
#show heading.where(level: 2): set block(below: 0.8em, above: 1em)

#show emph: set text(fill: blue.darken(20%))

= Course Information

#grid(
  columns: 2,
  inset: 5pt,
  [*Title:*], [Discrete Mathematics],
  [*Semester:*], [Fall 2025],
  [*Prerequisites:*], [High school mathematics (algebra, basic logic)],
  [*Language:*], [Russian (verbal), English (materials)],
  [*Format:*], [In-person lectures with written assignments and verbal exams],
)

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

== Module 1: Set Theory (Weeks 1-2)
- Basic set operations and notation
- Power sets and cardinality
- Cartesian products and relations
- Russell's paradox and axiomatic foundations
- Applications to computer science

== Module 2: Binary Relations (Weeks 3-7)
- Properties of relations (reflexive, symmetric, transitive)
- Equivalence relations and partitions
- Order relations and lattices
- Functions as special relations
- Composition and closure operations

== Module 3: Boolean Algebra (Weeks 8-10)
- Boolean functions and truth tables
- Normal forms (CNF, DNF)
- Logic gates and digital circuits
- Karnaugh maps and minimization (Quine-McCluskey)
- Applications to computer hardware

== Module 4: Formal Logic (Weeks 11-16)
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

Homework is an essential part of the course.
Each assignment is designed to consolidate the material of one thematic block, prepare students for the corresponding test, and provide an opportunity for independent problem-solving practice.

=== General principles

- Homework assignments are *mandatory* and count toward the final grade.
- Completing homework is a *checkpoint requirement*: each assignment must be passed with a _minimum score_ in order to complete the course.
- Assignments include a mix of basic practice tasks, medium-level exercises, and challenging problems.
  This ensures both systematic practice and deeper engagement with the subject.
  If the students find the assignments _too easy_ or _too hard_, they should *inform the instructor*.
- Students are encouraged to _discuss_ homework problems with peers, but the final solutions must be written _independently_.

=== Homework structure and weight

- There are *four* homework assignments per semester, one for each major topic.
- Each homework consists of approximately 10 problems of varying difficulty.
- Each assignment is worth *10 points*, contributing to a total of *40 points* toward the final grade.

=== Submissions

- Homework must be submitted to Dropbox (links are provided in the course chat).
- Each submission must include the student's full name, group number, and ISU identifier.
- Submissions must be in *PDF* format, neatly formatted and clearly legible.
- All non-PDFs or files larger than 10 MiB will be *rejected*.
- The submission time is determined by the timestamp on the Dropbox server.
- Students are allowed to submit multiple times _before_ the deadline.
  The instructor _may_ or _may not_ consider the additional re-submissions _after_ the deadline.
- *Do not submit the last minute!*

=== Minimum Thresholds

- Each homework has a *minimum passing scope* (typically around 80% of the maximum).
- Submissions below this threshold are considered _incomplete_ and must be _resubmitted_.
- Once the threshold is met, the assignment is consider _passed_.
- Note that the minimum threshold is considered _before_ the penalties, and the final score may be _lower_ than the threshold if penalties are applied, but not less than 50%.
  Submissions scored below 50% are considered _failed_ and must be _resubmitted_.

=== Resubmissions

TODO

=== Deadlines and Late Policy

- Homework assignments are due *the day before the test*.
- Exact deadlines will be announced in advance.
- The deadline time is always 23:55 (GMT+3).
- Late submissions are highly discouraged and will incur penalties:
  - Up to 24 hours late: -1 max point.
  - From 1 to 7 days late: -2 max points.
  - More than 1 week late: only 50% max score possible.

=== Defense

- All homework assignments must be _defended orally_ in a short discussion (typically 10-15 minutes).
- After the submission deadline, the instructor will schedule individual defense sessions.
- During the defense, students will explain their solutions and answer questions.
- The instructor or mentor may ask about solutions, reasoning, or related theory.
- Successful defense is required to receive credit for the assignment.
- Unsuccessful defense may require re-submission and re-defense.
- Failure to attend the defense without valid reason will result in zero score.

=== Evaluation and Penalties

- Each homework worth *10 points*.
- Each problem is graded individually, typically from 0 to 1.
- _Incorrect or unclear_ solutions receive _partial_ credit.
- The total score is the scaled (weighed) sum normalized to 10 points.
- _Partial or incomplete_ solutions are *not accepted*.
- There are two types of *penalties*:
  - _Max score_ (P) penalties, limiting the maximum achievable score.
    - Late submissions (see above).
  - _Score deductions_ (F), directly reducing the final score.
    - Formatting issues: -1 points.
    - Illegible handwriting: -2 points.
    - Missing name or identifier: -1 point.
    - Plagiarism or copying: 0 points (assignment considered failed).

=== Incentives and Contrubutions

- High-quality solutions, neat presentation, or particularly elegant approaches _may_ be rewarded with bonus points and shared with the class (with student's permission).
- Active participation in discussions and helping peers _may_ also be recognized.
- Contrubutions to the course (e.g., suggesting problems, providing feedback, fixing typos) on GitHub or in-person _may_ also yield minor privileges.

== Module Tests (20 points total)

- Long tests (90 minutes) covering material from each completed module.
- Primarily computational problems and short derivations.
- _All sources allowed_ (notes, textbooks), until stated otherwise by the instructor.
- *No collaboration* during tests.

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

*Note:* Both theoretical minimums must be passed and _all homeworks_ must be completed to receive a passing grade, regardless of total points.

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

#let header(body) = block(
  above: 1.2em,
  below: 0.8em,
  sticky: true,
  text(size: 1.2em, weight: "bold", body),
)

#header[Week 1: Set Theory]
- Introduction to sets and notation
- Basic operations: union, intersection, difference
- Power sets and subsets
- Venn diagrams
- Cartesian products and geometric interpretation
- Russell's paradox

#header[Week 2: Set Theory]
- Axiomatic foundations of set theory
- Zermelo-Fraenkel axioms overview
- Axiom of choice and its implications

#header[Week 3: Binary Relations]
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

#header[Week 4: Binary Relations]
- Order relations
- Chains and antichains
- Dilworth's theorem
- (?) Well-ordering principle
- Composition of relations
- Hasse diagrams

#header[Week 5: Binary Relations]
- Functions as special types of relations
- Domain, codomain, range
- Injective, surjective, bijective functions
- Function composition
- Inverse functions
- Image and preimage of sets
- Pigeonhole principle

#header[Week 6: Set Theory (again)]
- Cardinality of sets
- Infinite sets and countability
- Pairing functions
- Cantor's diagonal argument
- Uncountable sets
- Cantor's theorem
- Schroeder-Bernstein theorem
- Line and square paradox

#header[Week 7: Binary Relations]
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

#header[Week 8: Boolean Algebra]
- Boolean functions and truth tables
- Normal forms: CNF and DNF

#header[Week 9: Boolean Algebra]
- Logic gates and digital circuits

#header[Week 10: Boolean Algebra]
- Karnaugh maps and circuit minimization

#line(length: 100%, stroke: 0.4pt)
- Homework 3 due
- Test 3 covering weeks 8-10 material

#header[Week 11: Formal Logic]
- Propositional logic: syntax and semantics
- Logical equivalences and implications

#header[Week 12: Formal Logic]
- Natural deduction proof system
- Basic proof techniques
- Soundness and completeness of propositional logic
- Limitations of propositional logic

#header[Week 13: Formal Logic]
- Introduction to predicate (first-order) logic
- Syntax and semantics of predicate logic
- Quantifiers: universal and existential
- Prenex normal form
- Gödel's completeness theorem
- Gödel's incompleteness theorems

#header[Week 14: Formal Logic]
- Categorical logic
- A, E, I, O statements
- Traditional square of opposition
- Syllogisms and their validity
- Venn diagram representation of syllogisms
- Limitations of categorical logic

#header[Week 15: Formal Logic]
- Review of formal logic concepts

#line(length: 100%, stroke: 0.4pt)
- Homework 4 due
- Test 4 covering weeks 11-15 material
- Theoretical Minimum 2 covering Boolean Algebra and Formal Logic

#header[Week 16: Formal Logic (extra)]
- Ordinal and cardinal numbers
- Introduction to metalogical concepts

#line(length: 100%, stroke: 0.4pt)

#header[Session]
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
