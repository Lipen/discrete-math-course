// Custom theorem environments for Discrete Math lecture notes.
// Zero third-party dependencies --- pure Typst block + counter.
//
// All code blocks use semicolons (`;`) so the file is robust against
// formatters that collapse line breaks. Do NOT remove the semicolons.
//
// API:
//   #definition[body]                --- numbered, no subtitle
//   #definition[Subtitle][body]      --- numbered with subtitle
//   #theorem[body] / #theorem[Name][body]
//   #lemma[body] / #lemma[Name][body]
//   #corollary[body] / #corollary[Name][body]
//   #proposition[body] / #proposition[Name][body]
//   #proof[body]                     --- with QED square
//   #proof-sketch[body]              --- light, no QED
//   #example[body]                   --- italic title, unnumbered
//   #note[body]                      --- bold title, unnumbered
//   #remark[body]                    --- boxed, bold title, unnumbered

// --- Counters ---
#let def-ctr = counter("definition");
#let thm-ctr = counter("theorem");

// --- Internal: numbered box (no subtitle) ---
#let _numbered(label, ctr, fill, body) = {
ctr.step(); block(fill: fill, inset: 0.8em, radius: 4pt, width: 100%)[
    #strong[#label #context ctr.display()]
    #body
]; }

// --- Internal: numbered box with subtitle ---
#let _numbered-sub(label, subtitle, ctr, fill, body) = {
ctr.step(); block(fill: fill, inset: 0.8em, radius: 4pt, width: 100%)[
    #strong[#label #context ctr.display() (#subtitle)]
    #body
]; }

// --- Helper: sink-based dispatch for 1 or 2 content blocks ---
// #env[body]              → pos.len() = 1, pos.at(0) = body
// #env[Subtitle][body]    → pos.len() ≥ 2, pos.at(0) = subtitle, pos.at(1) = body
#let _dispatch(label, ctr, fill, ..args) = {
let pos = args.pos(); if pos.len() >= 2 { _numbered-sub(label, pos.at(0), ctr, fill, pos.at(1)); } else { _numbered(label, ctr, fill, pos.at(0)); } }

// --- Numbered environments ---
#let definition(..args)    = _dispatch("Definition", def-ctr, rgb("#e8f8e8"), ..args);
#let theorem(..args)       = _dispatch("Theorem", thm-ctr, rgb("#e8e8f8"), ..args);
#let lemma(..args)         = _dispatch("Lemma", thm-ctr, rgb("#efe8f8"), ..args);
#let corollary(..args)     = _dispatch("Corollary", thm-ctr, rgb("#f8e8e8"), ..args);
#let proposition(..args)   = _dispatch("Proposition", thm-ctr, rgb("#f8f8e8"), ..args);

// --- Proof environments ---
#let proof(body) = {
  block(inset: (x: 0em, y: 0em), width: 100%)[
    #strong[Proof.]
    #body
    #align(right, $square$)
]; }

#let proof-sketch(body) = {
  block(inset: (x: 0em, y: 0em), width: 100%)[
    #strong[Proof sketch.]
    #body
]; }

// --- Unnumbered environments (support 1 or 2 content blocks) ---
#let example(..args) = {
let pos = args.pos(); let (title, body) = if pos.len() >= 2 { (pos.at(0), pos.at(1)); } else { ([Example], pos.at(0)); }; block(inset: (x: 0em, y: 0.4em), width: 100%)[
    #text(style: "italic")[#title]
    #body
]; }

#let note(..args) = {
let pos = args.pos(); let (title, body) = if pos.len() >= 2 { (pos.at(0), pos.at(1)); } else { ([Note], pos.at(0)); }; block(inset: (x: 0em, y: 0.4em), width: 100%)[
    #strong[#title]
    #body
]; }

#let remark(..args) = {
let pos = args.pos(); let (title, body) = if pos.len() >= 2 { (pos.at(0), pos.at(1)); } else { ([Remark], pos.at(0)); }; block(fill: rgb("#fafafa"), stroke: 0.5pt + luma(80%), inset: (x: 1em, y: 0.8em), radius: 3pt, width: 100%)[
    #strong[#title]
    #body
]; }

// --- Chapter overview ---
#let chapter-overview(body) = {
  block(fill: luma(95%), inset: 1em, radius: 4pt, width: 100%)[
    #set text(size: 11pt);
    #body
]; }

// --- Horizontal rule ---
#let hrule = line(length: 100%);
