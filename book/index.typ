// Предметный указатель: термины определений.
// Метки ставятся макросом #idx в блоках definition.
#import "common.typ": *

#set heading(numbering: none)

#heading(level: 1, numbering: none)[Предметный указатель] <chap:index>

#let cyr = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
#let lat = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

#let idx-entry(e) = par(
  hanging-indent: 1.1em,
  justify: false,
  leading: 0.6em,
)[
  #e.t#h(0.3em)#text(size: 0.9em, fill: luma(40%))[#e.ps.map(str).join(", ")]
]

#context {
  let ms = query(metadata).filter(m => type(m.value) == dictionary and "idx" in m.value)
  let acc = (:)
  for m in ms {
    let t = m.value.idx
    let p = counter(page).at(m.location()).first()
    let base = lower(t.replace(regex("\([^)]*\)"), "").trim())
    let e = acc.at(base, default: none)
    if e == none {
      acc.insert(base, (t: t, ps: (p,)))
    } else if not e.ps.contains(p) {
      acc.insert(base, (t: e.t, ps: e.ps + (p,)))
    }
  }
  let es = acc.values().sorted(key: e => {
    let c = upper(e.t.clusters().at(0, default: ""))
    (if cyr.contains(c) { 0 } else if lat.contains(c) { 1 } else { 2 }, lower(e.t))
  })

  let groups = (:)
  for e in es {
    let c = upper(e.t.clusters().at(0, default: ""))
    groups.insert(c, groups.at(c, default: ()) + (e,))
  }

  for c in groups.keys().sorted(key: k => {
    (if cyr.contains(k) { 0 } else if lat.contains(k) { 1 } else { 2 }, k)
  }) {
    let items = groups.at(c)
    let half = calc.ceil(items.len() / 2)
    let cells = ()
    for i in range(half) {
      cells.push(idx-entry(items.at(i)))
      cells.push(if i + half < items.len() { idx-entry(items.at(i + half)) } else { [] })
    }
    table(
      columns: (1fr, 1fr),
      stroke: none,
      inset: (x: 0.9em, y: 0.18em),
      column-gutter: 1.2em,
      table.header(table.cell(colspan: 2)[
        #text(size: 1.15em, weight: "bold", fill: luma(30%))[#c]
      ]),
      ..cells,
    )
    v(0.6em)
  }
}
