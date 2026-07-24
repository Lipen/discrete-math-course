// Unified math notation for Discrete Math lecture notes.
// Only aliases that add value: awkward stdlib symbols, parameterized forms, custom operators.
// Simple symbols ($and$, $union$, $subset$, $arrow.r$, etc.) --- write directly in math mode.

// === Numeric sets ===
#let NN = $NN$
#let ZZ = $ZZ$
#let QQ = $QQ$
#let RR = $RR$

// === Complex symbols (awkward in stdlib) ===
#let symdiff = $Delta$
#let models = sym.tack.rr
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
#let partialto = $⇀$  // стрелка частичной функции: f: A ⇀ B

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

// === Лямбда-исчисление (m17, m18) ===
#let lam = $lambda$                           // λ (строчная лямбда)
#let beta-red = $scripts(->)_beta$            // →_β (одношаговая β-редукция)
#let beta-reds = $scripts(->>)_beta$          // ↠_β (многошаговая β-редукция)
#let beta-eq = $scripts(=)_beta$              // =_β (β-эквивалентность)
#let alpha-eq = $scripts(=)_alpha$            // =_α (α-эквивалентность)
#let Church-true = $"true"$                   // булево значение Чёрча
#let Church-false = $"false"$                 // булево значение Чёрча
#let ty-Nat = $"Nat"$                         // тип натуральных чисел
#let ty-Bool = $"Bool"$                       // тип булевых значений
