// Unified math notation for Discrete Math lecture notes.
// Only aliases that add value: awkward stdlib symbols, parameterized forms, custom operators.
// Simple symbols ($and$, $union$, $subset$, $->$, etc.) --- write directly in math mode.

// === Numeric sets ===
#let NN = $NN$
#let ZZ = $ZZ$
#let QQ = $QQ$
#let RR = $RR$

// === Complex symbols (awkward in stdlib) ===
#let symdiff = $Delta$
#let models = sym.tack.rr
#let vdash = sym.tack.r    // turnstile, "доказуемо"
#let imply = sym.arrow.r
#let iff = sym.arrow.l.r
#let setminus = sym.without
#let sim = sym.tilde

// === Helpers ===
#let rel(x) = math.class("relation", x)

// === Custom math operators (only those actually used across modules) ===
#let dist = math.op("dist")
#let diam = math.op("diam")
#let EE = math.op("E")       // expected value
#let Var = math.op("Var")    // variance

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
#let partialto = symbol("\u{21C0}")  // стрелка частичной функции

// === Logic gates (aliases for readability) ===
#let nand = sym.arrow.t    // штрих Шеффера: $nand$
#let nor = sym.arrow.b      // стрелка Пирса: $nor$
#let sheffer = sym.arrow.t  // штрих Шеффера (aliased)
#let peirce = sym.arrow.b   // стрелка Пирса (aliased)

// === Reductions (computability / complexity) ===
#let mreduce = rel($scripts(<=)_m$)
#let preduce = rel($scripts(<=)_p$)

// === Отношение неразличимости Майхилла--Нерода (индекс, не предел) ===
#let meq = $scripts(tilde.eq)$

// === Решётки (m05, m07) ===
#let join = $or$          // join (супремум в решётке)
#let meet = $and$         // meet (инфимум в решётке)

// === Лямбда-исчисление (m17, m18) ===

// Стрелки и отношения редукции (beta сверху, без scripts).
#let beta-red = $->^beta$                     // ->^beta (одношаговая)
#let beta-reds = $->>^beta$                   // ->>^beta (многошаговая)
#let beta-eq = $=^beta$                       // =^β (эквивалентность)
#let alpha-eq = $=^alpha$                     // =^α (α-эквивалентность)
#let par-red = $succ.eq$                       // ≽ --- параллельная редукция (Church-Rosser proof)
#let par-red-rel(M, N) = $#M succ.eq #N$       // M ≽ N

// Макросы для lambda-конструкций --- принимают content, возвращают math.
#let lam(x, body) = $lambda #x . #body$
#let app(M, N) = $#M #N$
#let subst(M, x, N) = $#M \[ #x := #N \]$
#let betared(M, N) = $#M ->^beta #N$
#let betareds(M, N) = $#M ->>^beta #N$
#let betaeq(M, N) = $#M =^beta #N$

// Нотация для часто используемых термов:
#let Church-true = $"true"$
#let Church-false = $"false"$
#let ty-Nat = $"Nat"$
#let ty-Bool = $"Bool"$
