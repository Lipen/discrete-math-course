// Typst math aliases for LaTeX compatibility (internal planning docs).
// All symbols defined via sym.* (code mode), NOT $...$ (math mode),
// so they work both inside and outside math blocks.

// Logic
#let neg = sym.not
#let implies = sym.arrow.r
#let iff = sym.arrow.l.r
#let to = sym.arrow.r
#let models = sym.tack.rr
#let entails = sym.tack.r
#let satisfies = models
#let nand = $overline("and")$
#let nor = $overline("or")$
#let uparrow = sym.arrow.t // nand, Sheffer stroke
#let downarrow = sym.arrow.b // nor, Peirce arrow

// Sets and functions
#let setminus = sym.without
#let symdiff = sym.triangle
#let notin = sym.in.not
#let ceiling = math.op("ceil")

// Parameterized
#let powerset(x) = $cal(P)(#x)$
#let card(x) = $abs(#x)$
#let choose(n, k) = $binom(#n, #k)$

// Reductions
#let mreduce = math.class("relation", $scripts(<=)_m$)
#let preduce = math.class("relation", $scripts(<=)_p$)

// Relations and order
#let sim = sym.tilde
#let nsim = sym.tilde.not

// Special symbols
#let langle = "⟨"
#let rangle = "⟩"
#let empty = sym.emptyset
#let epsilon = "ε"
#let oplus = "⊕"
#let sq = "□"
#let Diamond = "□"
#let coloneqq = "≔"

// Inequality
#let le = "≤"
#let ge = "≥"
#let neq = "≠"
#let leq = "≤"
#let geq = "≥"

// Text labels for math mode (content blocks --- safe inside/outside math)
#let T(t) = text(style: "italic", t)

#let SAT = T("SAT")
#let HALT = T("HALT")
#let EMPTY = T("EMPTY")
#let TSP = T("TSP")
#let DFS = T("DFS")
#let BFS = T("BFS")
#let DAG = T("DAG")
#let RSA = T("RSA")
#let ALU = T("ALU")
#let CPU = T("CPU")
#let RAM = T("RAM")
#let SQL = T("SQL")
#let PCP = T("PCP")
#let ZFC = T("ZFC")
#let CDCL = T("CDCL")
#let DPLL = T("DPLL")
#let QBF = T("QBF")
#let BQP = T("BQP")
#let FPT = T("FPT")
#let APX = T("APX")
#let AES = T("AES")
#let ILP = T("ILP")
#let PH = T("PH")
#let TCP = T("TCP")
#let OSPF = T("OSPF")
#let CFG = T("CFG")
#let MST = T("MST")
#let CE = T("CE")
#let NP = T("NP")
#let P = T("P")
#let EXP = T("EXP")
#let PSPACE = T("PSPACE")
#let TIME = T("TIME")
#let coNP = T("coNP")
