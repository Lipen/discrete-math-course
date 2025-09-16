#import "common.typ": *

#let title-slide(content) = {
  set page(header: none, footer: none)
  set align(horizon)
  content
  pagebreak(weak: true)
}

#let current-heading(level: 1) = context {
  let h = query(selector(heading.where(level: level)).before(here()))
  if h.len() > 0 {
    h.last().body
  } else {
    none
  }
}

// Usage:
// #focus-slide(
//   title: [Section Title],
//   epigraph: [Your inspirational quote here],
//   epigraph-author: [Author Name],
//   scholars: ("Name 1", "Name 2", "Name 3", ...)
// )
//
// Note: `title` can be:
//  - none (default): use current heading (level 1)
//  - function: a function that receives the current heading
//  - str: use the provided string as the title
#let focus-slide(
  title: none,
  epigraph: none,
  epigraph-author: none,
  scholars: (),
  dark: false,
) = {
  let title = if title == none {
    current-heading()
  } else if type(title) == function {
    title(current-heading())
  } else {
    title
  }

  // Configuration variables
  let page-margin = 1cm
  let hex-stroke-width = 1pt
  let hex-height = 1in

  let title-font-size = 2.2em
  let title-width = 90%
  let title-inset = 1.2em
  let title-stroke-width = 2pt

  let epigraph-font-size = 1.1em
  let epigraph-width = 80%
  let epigraph-inset = 1em
  let epigraph-author-font-size = 0.9em

  let initials-font-size = 1.2em
  let name-font-size = 0.8em

  // Colors
  let title-color = blue.darken(40%)
  let accent-color = blue.darken(20%)
  let text-color = accent-color

  if dark {
    title-color = title-color.lighten(40%)
    accent-color = accent-color.lighten(40%)
    text-color = accent-color
  }

  // heading(title)

  // Set up the page for the title slide
  set page(
    header: none,
    footer: none,
    margin: page-margin,
  )

  set text(fill: text-color)

  set align(center)

  let scholar-portrait(scholar) = {
    let portrait-content = if type(scholar) == str {
      // Scholar is a string name - create placeholder with initials
      let initials = scholar.split(" ").map(word => word.first()).join("")
      align(horizon)[
        #box(
          height: hex-height,
          inset: 1em,
          radius: 20%,
          fill: gradient.radial(
            accent-color.lighten(70%),
            accent-color.lighten(40%),
          ),
          stroke: hex-stroke-width + accent-color,
        )[
          #text(
            initials,
            initials-font-size,
            weight: "bold",
            fill: text-color.darken(30%),
          )
        ]
      ]
    } else {
      // Scholar is a dict (name, image)
      let img = scholar.at("image")
      box(height: hex-height, box(
        img,
        radius: 20%,
        clip: true,
        stroke: hex-stroke-width + accent-color,
      ))
    }

    let scholar-name = if type(scholar) == str {
      scholar
    } else {
      scholar.at("name")
    }

    (portrait-content, scholar-name)
  }

  grid(
    columns: 1fr,
    // Note: one row for title+epigraph, one for portraits.
    //  - First row fills all available space.
    //  - Second row (optional) is auto-sized to content.
    rows: (1fr, auto),
    align(horizon, stack(
      // Title
      block(
        width: title-width,
        // stroke: .1pt, // debug
      )[
        #block(
          stroke: (bottom: 1pt + title-color),
          inset: 1em,
        )[
          #set text(
            title-font-size,
            weight: "bold",
            font: "Libertinus Sans",
            fill: title-color,
          )
          #title
        ]
      ],

      // Epigraph
      if epigraph != none {
        block(
          width: epigraph-width,
          inset: (top: epigraph-inset),
          // stroke: .1pt, // debug
        )[
          #set text(
            epigraph-font-size,
            style: "italic",
          )
          "#epigraph"

          #if epigraph-author != none [
            #align(right)[
              #set text(
                epigraph-author-font-size,
                weight: "bold",
              )
              --- #epigraph-author
            ]
          ]
        ]
      },
    )),

    // Portraits
    if scholars.len() > 0 {
      grid(
        columns: scholars.len(),
        align: (x, y) => if y == 0 { bottom } else { top },
        column-gutter: .5em,
        row-gutter: .5em,
        // stroke: 1pt + silver,
        ..array
          .zip(..scholars.map(scholar => {
            let (hex, name) = scholar-portrait(scholar)
            (
              box(width: 2cm, hex),
              box(width: 2cm, text(name, name-font-size)),
            )
          }))
          .flatten()
      )
    }
  )

  pagebreak(weak: true)
}

#let slides(
  content,
  title: none,
  subtitle: none,
  date: none,
  authors: (),
  dark: false,
) = {
  // Page dimensions
  let height = 10.5cm
  let width = height * 16 / 9
  let space = 1.6cm

  // Colors
  let title-color = blue.darken(40%)
  let emph-color = blue.darken(20%)

  // Fonts
  let title-font = "Libertinus Sans"

  // Dark mode
  if dark {
    title-color = title-color.lighten(40%)
    emph-color = emph-color.lighten(40%)
  }

  // Common template
  show: template.with(dark: dark)

  // Setup
  set document(title: title, author: authors) if (title != none)
  set page(
    width: width,
    height: height,
    margin: (x: 0.5 * space, top: space, bottom: 0.5 * space),
    header: context {
      // show: body => block(width: 100%, height: 100%, stroke: 1pt + red, body)
      let page = here().page()
      let headings = query(selector(heading.where(level: 2)))
      let heading = headings.rev().find(x => x.location().page() <= page)
      if heading != none {
        set align(bottom)
        set text(
          1.4em,
          weight: "bold",
          font: title-font,
          fill: title-color,
        )
        let body = {
          heading.body
          if not heading.location().page() == page {
            numbering(" [1]", page - heading.location().page() + 1)
          }
        }
        // Note: 'context' is needed *again* for 'measure'
        context {
          body
          place(bottom, dy: 0.4em)[
            #line(
              length: measure(body).width,
              stroke: 0.6pt + title-color,
            )
          ]
        }
      }
    },
    footer: context {
      // show: body => block(width: 100%, height: 100%, stroke: 1pt + red, body)
      set text(0.8em, fill: luma(50%))
      set align(right)
      counter(page).display("1 / 1", both: true)
    },
  )
  set outline(target: heading.where(level: 1), title: none)
  set bibliography(title: none)

  // Rules
  show heading.where(level: 1): it => {
    // Create a simple focus page for regular level 1 headings
    set page(header: none, footer: none, margin: 1cm)

    // Main layout: simple centered title
    align(center + horizon, block(
      inset: 1.2em,
      radius: 20%,
      fill: title-color.lighten(80%),
      stroke: 2pt + title-color.lighten(60%),
    )[
      #set text(
        2em,
        weight: "bold",
        font: title-font,
        fill: title-color,
      )
      #it.body
    ])

    pagebreak(weak: true)
  }
  show heading.where(level: 2): pagebreak(weak: true)
  show heading: set text(1.1em, fill: title-color)

  // Style headings
  set heading(numbering: numbly.numbly(
    sym.section + "{1} ",
    none,
    sym.square + "",
    default: (.., last) => str(last) + ".",
  ))

  // Style lists
  set list(marker: (
    text(fill: title-color)[•],
    text(fill: title-color)[‣],
    text(fill: title-color)[-],
  ))
  set enum(numbering: nums => text(fill: title-color)[*#nums.*])

  // Colored emph
  show emph: set text(fill: emph-color) if emph-color != none

  // Make links underlined
  show link: underline

  // Bold first row in tables
  show table.cell.where(y: 0): strong

  // Title page
  if title != none {
    if (type(authors) != array) {
      authors = (authors,)
    }
    title-slide({
      // Title:
      {
        set text(
          2em,
          weight: "bold",
          font: title-font,
          fill: title-color,
        )
        title
      }
      v(1.4em, weak: true)
      // Subtitle:
      if subtitle != none or date != none {
        set text(1.4em, weight: "bold")
        if subtitle != none {
          subtitle
        }
        if date != none {
          if subtitle != none {
            [, ]
          }
          date
        }
      }
      v(1em, weak: true)
      // Authors:
      {
        authors.join(", ", last: " and ")
      }
    })
  }

  // Content
  content
}
