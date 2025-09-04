#import "theme.typ": *
#show: slides.with(
  title: [Course Syllabus],
  subtitle: "Discrete Mathematics",
  date: "Fall 2025",
  authors: "Konstantin Chukharev",
  // dark: true,
)

#show heading.where(level: 1): none

#show table.cell.where(y: 0): strong

#set quote(block: true)
#show quote: set par(justify: false)
#show quote: set align(left)

#let iff = symbol(math.arrow.double.l.r.long, ("not", math.arrow.double.l.r.not))
#let power(x) = $cal(P)(#x)$
#let pair(a, b) = $angle.l #a, #b angle.r$
#let rel(x) = math.class("relation", x)
#let nrel(x) = rel(math.cancel(x))
#let matrel(x) = $bracket.double.l #x bracket.double.r$
#let Dom = math.op("Dom")
#let Cod = math.op("Cod")
#let Range = math.op("Range")
#let equinumerous = symbol(math.approx, ("not", math.approx.not))
#let smaller = symbol(math.prec, ("eq", math.prec.eq))
#let Join = math.or
#let Meet = math.and
#let nand = $overline(and)$
#let nor = $overline(or)$

#let Green(x) = text(green.darken(20%), x)
#let Red(x) = text(red.darken(20%), x)
#let Blue(x) = text(blue.darken(20%), x)

#let True = Green(`true`)
#let False = Red(`false`)

#let YES = Green(sym.checkmark)
#let NO = Red(sym.crossmark)

#import cetz: canvas, draw

// Helper function for creating visual elements
#let visual-box(content, color: blue, icon: none) = {
  let bg = color.transparentize(90%)
  let border = color.darken(20%)

  block(
    fill: bg,
    stroke: 2pt + border,
    radius: 8pt,
    inset: 1em,
    width: 100%,
  )[
    #if icon != none [
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0.5em,
        align: (center, left),
        text(size: 1.5em, fill: border)[#icon], content,
      )
    ] else [
      #content
    ]
  ]
}

= Discrete Mathematics
#focus-slide(
  epigraph: [Mathematics is not about numbers, equations, computations, or algorithms: \ it is about understanding.],
  epigraph-author: "William Paul Thurston",
)

== Course Overview

#let course-overview-visual() = {
  canvas(length: 1cm, {
    import draw: *

    // Central node
    circle((0, 0), radius: 1.5, fill: blue.lighten(70%), stroke: 2pt + blue, name: "central")
    content((0, 0), align(center, text(size: 1em, weight: "bold")[*Discrete* \ *Math*]))

    // Branch nodes
    let positions = (
      (-3, 2), // Set Theory
      (3, 2), // Binary Relations
      (-3, -2), // Boolean Algebra
      (3, -2), // Formal Logic
    )

    let topics = (
      "Set Theory",
      "Binary Relations",
      "Boolean Algebra",
      "Formal Logic",
    )

    let colors = (blue, green, purple, orange)

    for (i, (pos, topic, color)) in array.zip(positions, topics, colors).enumerate() {
      // Topic circle
      circle(pos, radius: 1, fill: color.lighten(80%), stroke: 2pt + color, name: "node-" + topic)
      content(pos, block(width: 1.5cm, align(center, text(size: 0.8em, weight: "bold")[#topic])))

      // Connection line
      line("central", "node-" + topic, stroke: 1pt + gray)
    }
  })
}

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  [
    #visual-box(color: blue, icon: emoji.clipboard)[
      *Course information*

      - *Title:* Discrete Mathematics
      - *Semester:* Fall 2025
      - *Prerequisites:* High school math
      - *Language:* Russian + English
      - *Format:* Lectures, assignments, exam
    ]

    #v(1em)

    #visual-box(color: green, icon: emoji.darts)[
      *What you'll master*

      - Mathematical structures & reasoning
      - Discrete (vs continuous) mathematics
      - Proof construction & validation
      - CS foundations & applications
    ]
  ],
  [
    #align(center)[
      #course-overview-visual()
      // #v(1em)
      // _Four interconnected modules building mathematical maturity_
    ]
  ],
)

== Learning Journey: From Foundations to Mastery

#let learning-path() = {
  canvas(length: 1cm, {
    import draw: *

    let steps = (
      (emoji.numbers, [Sets], blue),
      (emoji.hands.shake, [Relations, Functions], green),
      (emoji.lightbulb, [Boolean Logic], purple),
      (emoji.page.pencil, [Formal Proofs], orange),
      (emoji.mortarboard, [Mathematical Maturity], red),
    )

    for (i, (icon, label, color)) in steps.enumerate() {
      let x = i * 3
      let y = 0

      // Step circle
      circle((x, y), radius: 0.8, fill: color.lighten(80%), stroke: 2pt + color)
      content((x + .11, y + .09), text(size: 26pt)[#icon])

      // Label below
      content((x, y - 1.5), align(center, text(size: 0.8em, weight: "bold")[#label]))

      // Arrow to next step
      if i < steps.len() - 1 {
        line((x + 0.8, y), (x + 2.2, y), stroke: 2pt + gray, mark: (end: ">"))
      }
    }
  })
}

#v(1em)
#align(center)[
  #learning-path()
]
#v(1em)

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    #visual-box(color: blue, icon: emoji.darts)[
      *Core skills you'll develop*

      + Work confidently with sets, relations, functions, logic, proofs
      + Design Boolean circuits
      + Construct mathematical proofs
      + Apply discrete math to CS problems
    ]
  ],
  [
    #visual-box(color: purple, icon: emoji.rocket)[
      *Why this matters?*

      - Foundation for computer science
      - Critical thinking & logical reasoning
      - Problem-solving methodology
      - Preparation for advanced courses
      - Real-world applications
    ]
  ],
)

== The Four Pillars of Discrete Mathematics

#let module-visual(number, title, icon, color, topics, applications) = {
  visual-box(color: color)[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      align: (center, left),
      [
        #text(size: 3em, fill: color.darken(20%))[#icon]
        #v(2em, weak: true)
        #text(size: 1.5em, weight: "bold", fill: color.darken(30%))[#number]
      ],
      [
        #block(below: .8em, text(size: 1.2em, weight: "bold", fill: color.darken(20%))[#title])

        #topics

        *Applications:*
        #text(style: "italic", fill: color.darken(10%))[#applications]
      ],
    )
  ]
}

#grid(
  columns: (1fr, 1fr),
  rows: (1fr, 1fr),
  column-gutter: 1em,
  row-gutter: 1em,

  module-visual(
    "1",
    "Set Theory",
    emoji.numbers,
    blue,
    list[Basic operations & notation][Power sets & cardinality][Russell's paradox],
    "Database design, data structures, algorithm analysis",
  ),

  module-visual(
    "2",
    "Binary Relations",
    emoji.hands.shake,
    green,
    list[Relation properties][Equivalence relations][Functions as relations],
    "Database relations, sorting algorithms, object hierarchies",
  ),

  module-visual(
    "3",
    "Boolean Algebra",
    emoji.lightbulb,
    purple,
    list[Boolean functions & truth tables][Logic gates & circuits][Circuit minimization],
    "Computer hardware, digital design, optimization",
  ),

  module-visual(
    "4",
    "Formal Logic",
    emoji.page.pencil,
    orange,
    list[Propositional logic][Natural deduction][Predicate logic intro],
    "Program verification, AI reasoning, formal methods",
  ),
)

== Ready to Begin Your Mathematical Journey?

#let journey-visual() = {
  canvas(length: 0.8cm, {
    import draw: *

    // Journey path - more compact
    let path-points = (
      (0, 0), // Start
      (1.5, 0.5), // Sets
      (3, 0), // Relations
      (4.5, 0.5), // Boolean
      (6, 0), // Logic
      (7.5, 1), // Success!
    )

    let labels = ("Start", "Sets", "Relations", "Boolean", "Logic", "Success!")
    let colors = (gray, blue, green, purple, orange, red)

    // Draw path
    for i in range(path-points.len() - 1) {
      line(path-points.at(i), path-points.at(i + 1), stroke: 1.5pt + gray.darken(30%))
    }

    // Draw nodes
    for (i, (point, label, color)) in array.zip(path-points, labels, colors).enumerate() {
      let radius = if i == 0 or i == path-points.len() - 1 { 0.5 } else { 0.4 }
      circle(point, radius: radius, fill: color.lighten(70%), stroke: 1.5pt + color)

      if i == 0 {
        content(point, text(size: 0.5em, weight: "bold")[🚀])
      } else if i == path-points.len() - 1 {
        content(point, text(size: 0.5em, weight: "bold")[🎓])
      } else {
        content(point, text(size: 0.4em, weight: "bold")[#str(i)])
      }

      // Label below
      content((point.at(0), point.at(1) - 0.8), text(size: 0.4em, weight: "bold")[#label])
    }
  })
}

// #align(center)[
//   #journey-visual()
// ]

// #v(1em)

// #grid(
//   columns: (1fr, 1fr, 1fr),
//   column-gutter: 1.5em,
//   [
//     #visual-box(color: blue, icon: "🎯")[
//       *What awaits:* Deep mathematical thinking, practical CS applications, rigorous proof techniques
//     ]
//   ],
//   [
//     #visual-box(color: green, icon: "🏆")[
//       *Your goals:* Pass all assessments, master each module, build proof confidence
//     ]
//   ],
//   [
//     #visual-box(color: purple, icon: "🌟")[
//       *Why it's worth it:* Foundation for advanced CS, enhanced logical thinking, academic preparation
//     ]
//   ],
// )

== Assessment: Your Path to Success

#let assessment-visual() = {
  canvas(length: 0.8cm, {
    import draw: *

    let components = (
      ("Homework", 40, blue),
      ("Tests", 20, green),
      ("Theory", 20, purple),
      ("Exam", 20, orange),
    )

    let bar-width = 0.8
    let max-height = 3
    let gap = 1.6

    for (i, (name, points, color)) in components.enumerate() {
      let x = i * gap
      let height = points / 40 * max-height // normalize to max 40 points

      // Draw bar
      rect((x - bar-width / 2, 0), (x + bar-width / 2, height), fill: color.lighten(70%), stroke: 1pt + color)

      // Points label on bar
      content((x, height), padding: .2, anchor: "south", text(size: 0.8em, weight: "bold")[#points])

      // Name label below
      content((x, 0), padding: .2, anchor: "north", text(size: 0.8em, weight: "bold")[#name])
    }

    // Total label
    content((gap * 3 + bar-width / 2, max-height - 0.4), anchor: "east", text(
      size: 0.8em,
      weight: "bold",
    )[Total: 100 Points])
  })
}

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  row-gutter: 1.5em,

  align(center)[
    #assessment-visual()
  ],

  visual-box(color: blue, icon: emoji.books)[
    *Homework (40% - Most Important!)*
    - 4 assignments, 10 points each
    - Computational & proof problems
    - Collaboration allowed, write independently
    - Oral defense required
  ],

  visual-box(color: red, icon: emoji.warning)[
    *Critical Requirements*
    - Both Theoretical Minimums must be passed
    - All homework must be completed
    - Academic integrity enforced
  ],

  visual-box(color: green, icon: emoji.page.pencil)[
    *Tests, Theory, Exams*
    - _Module tests:_ Computational tasks
    - _Theoretical minimums:_ Checks deep understanding
    - _Exam:_ Written + Verbal + Practical
  ],
)

== Grading Scale

#align(center)[
  #v(2em)

  #table(
    columns: 3,
    align: (center, center, left),
    stroke: (x, y) => if y == 0 { (bottom: 1pt + blue.lighten(50%)) },
    fill: (x, y) => if y == 0 { blue.lighten(90%) },
    table.header([*Grade*], [*Points*], [*Description*]),
    [5], [91--100], [Excellent],
    [4], [74--90], [Good],
    [3], [60--73], [Pass],
    [F], [< 60], [Fail],
  )

  // #v(2em)

  // #visual-box(color: red, icon: "⚠️")[
  //   *Important:* Both theoretical minimums must be passed and all homework must be completed to receive a passing grade, regardless of total points.
  // ]
]

== Course Timeline: 17 Weeks of Mathematical Adventure

#let timeline-visual() = {
  canvas(length: 0.7cm, {
    import draw: *

    // Timeline parameters
    let total-width = 17 // 17 weeks total
    let timeline-height = 1.2
    let skew = 0.2 // Parallelogram skew amount

    // Module definitions with week ranges
    let modules = (
      ("Set Theory", 1, 2, blue, emoji.numbers),
      ("Binary Relations", 3, 7, green, emoji.hands.shake),
      ("Boolean Algebra", 8, 10, purple, emoji.lightbulb),
      ("Formal Logic", 11, 16, orange, emoji.page.pencil),
      ("Finals", 17, 17, red, emoji.mortarboard),
    )

    // Draw main timeline background (simple rectangle)
    let base-y = -timeline-height / 2
    let top-y = timeline-height / 2

    // rect((0, base-y), (total-width, top-y), fill: gray.lighten(90%), stroke: 1pt + gray.darken(20%))

    // Draw individual week parallelograms
    for week in range(1, 18) {
      let x-start = week - 1
      let x-end = week
      let week-base-y = base-y + 0.1
      let week-top-y = top-y - 0.1

      // Find which module this week belongs to
      let (module-name, module-color) = {
        for (name, start-week, end-week, color, icon) in modules {
          if week >= start-week and week <= end-week {
            (name, color)
            break
          }
        }
      }

      // Draw parallelogram for each week
      let parallelogram-points = (
        (x-start + skew, week-base-y), // Bottom left
        (x-end + skew, week-base-y), // Bottom right
        (x-end, week-top-y), // Top right
        (x-start, week-top-y), // Top left
      )

      // Fill the parallelogram
      for i in range(parallelogram-points.len()) {
        let next-i = calc.rem(i + 1, parallelogram-points.len())
        line(
          parallelogram-points.at(i),
          parallelogram-points.at(next-i),
          stroke: 1pt + module-color.darken(10%),
          fill: if i == 0 { module-color.lighten(80%) } else { none },
        )
      }

      // Week number
      let center-x = (x-start + x-end) / 2 + skew / 2
      content((center-x, 0), text(size: 0.4em, weight: "bold", fill: module-color.darken(30%))[Week #week])

      // Add activity markers for specific weeks
      let marker-y = top-y + 0.4

      // Homework due weeks (end of each module)
      if week == 4 or week == 8 or week == 12 or week == 16 {
        circle((center-x, marker-y), radius: 0.15, fill: blue, stroke: 1pt + white)
        content((center-x, marker-y), text(size: 0.3em, fill: white, weight: "bold")[HW])
      }

      // Test weeks (start of next module)
      if week == 5 or week == 9 or week == 13 or week == 17 {
        circle((center-x, marker-y + 0.5), radius: 0.15, fill: green, stroke: 1pt + white)
        content((center-x, marker-y + 0.5), text(size: 0.3em, fill: white, weight: "bold")[T])
      }

      // Theoretical Minimums
      if week == 8 {
        circle((center-x, marker-y + 1), radius: 0.2, fill: purple, stroke: 2pt + white)
        content((center-x, marker-y + 1), text(size: 0.3em, fill: white, weight: "bold")[TM1])
      }
      if week == 16 {
        circle((center-x, marker-y + 1), radius: 0.2, fill: purple, stroke: 2pt + white)
        content((center-x, marker-y + 1), text(size: 0.3em, fill: white, weight: "bold")[TM2])
      }
    }

    // Module labels at the bottom
    for (name, start-week, end-week, color, icon) in modules {
      let center-x = (start-week + end-week - 1) / 2 + skew / 2
      content((center-x, base-y - 0.6), text(size: 0.6em, weight: "bold", fill: color.darken(20%))[#icon #name])
    }
  })
}

#v(1em)

#align(center)[
  #timeline-visual()
]

// #visual-box(color: gray, icon: "📝")[
//   *Legend*

//   🔵 HW = Homework
//   🟢 T = Test
//   🟣 TM = Theoretical Minimum
// ]

#v(1em)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,

  visual-box(color: blue, icon: emoji.calendar)[
    *Key Milestones*

    - *Week 3:* First homework due
    - *Week 4:* Module 1 Test
    - *Week 8:* Theoretical Minimum 1
  ],

  visual-box(color: green, icon: emoji.lightbulb)[
    *Study Strategy*

    - Start homework early!
    - Form study groups for collaboration
    - Attend office hours for help
    - Read the textbook alongside lectures
  ],
)

== Resources & Materials

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  [
    #visual-box(color: blue, icon: emoji.books)[
      *Course Materials*
      - *Primary:* Lecture notes
      - *Reference:* Kenneth Rosen's textbook
      - *Website:* #link("https://github.com/Lipen/discrete-math-course")
    ]

    #visual-box(color: purple, icon: emoji.book.open)[
      *Additional Resources*
      - Online tutorials and videos
      - Practice problem sets
      - Mathematical proof guides
      - LaTeX formatting help
      - GitHub course repository
    ]
  ],
  [
    #visual-box(color: orange, icon: emoji.lightning)[
      *Academic Integrity*
      - Homework: collaboration allowed
      - Tests/Exams: Individual work only
      - Plagiarism = automatic failure
      - When in doubt, ask!
    ]

    #visual-box(color: red, icon: emoji.clipboard)[
      *Submission Guidelines*
      - PDF format only (no exceptions)
      - Include name, group, ISU ID
      - Submit before deadline (23:55 GMT+3)
      - Use Dropbox submission links
      - Late submissions are punished
    ]
  ],
)

== You're Not Alone!

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,
  [
    #visual-box(color: green, icon: emoji.hands.shake)[
      *Getting Help*
      - Instructor office hours: [TBA]
      - Teaching assistant hours: [TBA]
      - Telegram chat for Q&A: [TBA]
      - Study groups encouraged!
      - GitHub for course feedback
    ]

    #visual-box(color: blue, icon: emoji.silhouette.double)[
      *Study Community*
      - Form study groups with classmates
      - Discuss problems
      - Share learning strategies
      - Help each other understand concepts
      - Celebrate successes together
    ]
  ],
  [
    #visual-box(color: purple, icon: emoji.arm.muscle)[
      *Success Strategies*
      - Work steadily, don't cram
      - Do problems beyond homework
      - Ask early and often
      - Regularly review the concepts
      - Mathematical maturity takes time!
    ]

    #visual-box(color: orange, icon: emoji.darts)[
      *Learning Tips*
      - Attend every lecture
      - Start homework assignments early
      - Practice writing clear explanations
      - Don't just memorize --- understand!
    ]
  ],
)
