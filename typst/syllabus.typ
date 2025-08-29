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

#show heading.where(level: 1): set block(below: 1em, above: 1.4em)
#show heading.where(level: 2): set block(below: 0.8em, above: 1em)

#set enum(numbering: it => text(fill: navy)[*#numbering("1.", it)*])

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
- Normal forms (CNF, DNF) and minimization
- Logic gates and digital circuits
- Karnaugh maps and circuit design
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
  table.header([*Component*], [*Points Each*], [*Total Points*]),
  [Homework Assignments (4)], [10], [40],
  [Module Tests (4)], [5], [20],
  [Theoretical Minimums (2)], [10], [20],
  [Final Exam], [20], [20],
  [*Total*], [—], [*100*],
)

== Homework Assignments (40 points total)
- One homework per module, due at the end of each 4-week period
- Mix of computational problems and proof exercises
- Late submissions: -20% per day late
- Collaboration allowed, but solutions must be written independently

== Module Tests (20 points total)
- Short tests (45 minutes) covering material from each completed module
- Primarily computational problems and short derivations
- Closed book, but formula sheets may be provided

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
- More than 3 unexcused absences may result in course failure
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

Last updated: August 29, 2025
