// Unified math notation for Discrete Math lecture notes.
// Only aliases that add value: awkward stdlib symbols, parameterized forms, custom operators.
// Simple symbols ($and$, $union$, $subset$, $arrow.r$, etc.) --- write directly in math mode.

// === Complex symbols (awkward in stdlib) ===
#let symdiff = $Delta$
#let models = sym.tack.rr
#let entails = sym.tack.r
#let imply = sym.arrow.r
#let iff = sym.arrow.l.r
#let sim = sym.tilde
#let nsim = sym.tilde.not
#let setminus = sym.without
#let notin = sym.in.not
#let nand = $overline(and)$
#let nor = $overline(or)$

// === Parameterized aliases ===
#let powerset(x) = $cal(P)(#x)$
#let card(x) = $abs(#x)$
#let choose(n, k) = $binom(#n, #k)$
#let perm(n, k) = $P(#n, #k)$
// Composition ∘ is the built-in Typst symbol `compose` : use directly: $g compose f$
#let id(x) = $"id"_#x$
#let inv(x) = $#x^(-1)$
#let rel(x) = math.class("relation", x)
#let lang(l) = $L(#l)$
#let config(q, w) = $la #q, #w ra$

// === Custom math operators ===
#let deg(v) = $"deg"(#v)$
#let dist = math.op("dist")
#let diam = math.op("diam")
#let rad = math.op("rad")
#let ecc = math.op("ecc")
#let girth = math.op("girth")
#let Center = math.op("center")
#let Adj = math.op("Adj")
#let Floor = math.op("floor")
#let Ceil = math.op("ceil")

// === Truth values (colored) ===
#let Green(x) = text(fill: green.darken(20%), x)
#let Red(x) = text(fill: red.darken(20%), x)
#let True = Green[`true`]
#let False = Red[`false`]
#let T = Green[`T`]
#let F = Red[`F`]

// === Special symbols and constants ===
#let la = $chevron.l$
#let ra = $chevron.r$
#let Blank = math.class("normal", sym.square.stroked)
#let qAccept = $q_"accept"$
#let qReject = $q_"reject"$

// === Reductions (computability / complexity) ===
#let mreduce = rel($scripts(<=)_m$)
#let preduce = rel($scripts(<=)_p$)
