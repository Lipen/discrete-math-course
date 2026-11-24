/* First-order formulas over a finite model with P, Q and R. */

export type Term =
  | { type: "const"; value: number }
  | { type: "var"; name: string };

export type Atom =
  | { type: "atom"; pred: "P" | "Q" | "R"; args: Term[] }
  | { type: "eq"; a: Term; b: Term };

export type Formula =
  | { type: "const"; value: boolean }
  | Atom
  | { type: "not"; a: Formula }
  | { type: "and"; a: Formula; b: Formula }
  | { type: "or"; a: Formula; b: Formula }
  | { type: "impl"; a: Formula; b: Formula }
  | { type: "iff"; a: Formula; b: Formula }
  | { type: "forall"; variable: string; body: Formula }
  | { type: "exists"; variable: string; body: Formula };

export type Env = Record<string, number>;

export interface Model {
  domain: number[];
  preds: {
    P: Set<number>;
    Q: Set<number>;
    R: Set<string>;
  };
}

export interface QuantifierRow {
  value: number;
  truth: boolean;
}

const PREC: Record<Formula["type"], number> = {
  iff: 1, impl: 2, or: 3, and: 4, not: 5, forall: 6, exists: 6, atom: 7, const: 7, eq: 7,
};

/** Quantifiers bind tighter than any connective in the parser, so render them parenthesized there. */
const QUANT_PREC = 0.5;

function quantifierBody(body: Formula): string {
  const text = toTex(body);
  const binary = body.type === "and" || body.type === "or" || body.type === "impl" || body.type === "iff";
  return binary ? "\\left(" + text + "\\right)" : text;
}

type Token =
  | { type: "(" | ")" | "," | "=" }
  | { type: "not" | "and" | "or" | "impl" | "iff" | "forall" | "exists" | "true" | "false" }
  | { type: "number"; value: number }
  | { type: "name"; value: string };

export function normalize(input: string): string {
  return String(input || "")
    .replace(/∀/g, " forall ")
    .replace(/∃/g, " exists ")
    .replace(/↔/g, "<->")
    .replace(/⇔/g, "<->")
    .replace(/→/g, "->")
    .replace(/⇒/g, "->")
    .replace(/∧/g, "&")
    .replace(/∨/g, "|")
    .replace(/¬/g, "!")
    .replace(/⊤/g, "true")
    .replace(/⊥/g, "false");
}

function tokenize(input: string): Token[] {
  const source = normalize(input);
  const tokens: Token[] = [];
  let i = 0;
  while (i < source.length) {
    const ch = source[i];
    if (/\s/.test(ch)) { i++; continue; }
    if (ch === "(" || ch === ")" || ch === "," || ch === "=") { tokens.push({ type: ch }); i++; continue; }
    if (ch === "!") { tokens.push({ type: "not" }); i++; continue; }
    if (ch === "&") { tokens.push({ type: "and" }); i++; continue; }
    if (ch === "|") { tokens.push({ type: "or" }); i++; continue; }
    if (source.startsWith("<->", i)) { tokens.push({ type: "iff" }); i += 3; continue; }
    if (source.startsWith("->", i)) { tokens.push({ type: "impl" }); i += 2; continue; }
    if (/[0-9]/.test(ch)) {
      let j = i + 1;
      while (j < source.length && /[0-9]/.test(source[j])) j++;
      tokens.push({ type: "number", value: Number(source.slice(i, j)) });
      i = j;
      continue;
    }
    if (/[A-Za-z_]/.test(ch)) {
      let j = i + 1;
      while (j < source.length && /[A-Za-z0-9_]/.test(source[j])) j++;
      const name = source.slice(i, j);
      const lower = name.toLowerCase();
      if (lower === "forall" || lower === "exists" || lower === "true" || lower === "false") {
        tokens.push({ type: lower });
      } else {
        tokens.push({ type: "name", value: name });
      }
      i = j;
      continue;
    }
    throw new Error("Неизвестный символ: " + ch);
  }
  return tokens;
}

export function parse(input: string): Formula {
  const tokens = tokenize(input);
  let pos = 0;

  function peek(type: Token["type"]): boolean {
    return Boolean(tokens[pos] && tokens[pos].type === type);
  }
  function take(type: Token["type"]): Token {
    if (!peek(type)) throw new Error("Ожидалось " + type);
    return tokens[pos++];
  }

  function parseIff(): Formula {
    let left = parseImpl();
    while (peek("iff")) { pos++; left = { type: "iff", a: left, b: parseImpl() }; }
    return left;
  }

  function parseImpl(): Formula {
    const left = parseOr();
    if (peek("impl")) { pos++; return { type: "impl", a: left, b: parseImpl() }; }
    return left;
  }

  function parseOr(): Formula {
    let left = parseAnd();
    while (peek("or")) { pos++; left = { type: "or", a: left, b: parseAnd() }; }
    return left;
  }

  function parseAnd(): Formula {
    let left = parseUnary();
    while (peek("and")) { pos++; left = { type: "and", a: left, b: parseUnary() }; }
    return left;
  }

  function parseUnary(): Formula {
    if (peek("not")) { pos++; return { type: "not", a: parseUnary() }; }
    if (peek("forall") || peek("exists")) {
      const token = tokens[pos++];
      if (token.type !== "forall" && token.type !== "exists") throw new Error("Ожидался квантор.");
      const variable = take("name");
      if (variable.type !== "name") throw new Error("Ожидалась переменная квантора.");
      return { type: token.type, variable: variable.value, body: parseUnary() };
    }
    return parseAtomFormula();
  }

  function parseTerm(): Term {
    if (peek("number")) {
      const token = tokens[pos++];
      if (token.type !== "number") throw new Error("Ожидалось число.");
      return { type: "const", value: token.value };
    }
    if (peek("name")) {
      const token = tokens[pos++];
      if (token.type !== "name") throw new Error("Ожидалось имя переменной.");
      return { type: "var", name: token.value };
    }
    throw new Error("Ожидался терм: переменная или число.");
  }

  function parseAtomFormula(): Formula {
    if (peek("(")) {
      pos++;
      const formula = parseIff();
      take(")");
      return formula;
    }
    if (peek("true") || peek("false")) {
      return { type: "const", value: tokens[pos++].type === "true" };
    }
    if (peek("name")) {
      const head = tokens[pos];
      if (head.type !== "name") throw new Error("Ожидалось имя предиката.");
      const name = head.value;
      if (tokens[pos + 1] && tokens[pos + 1].type === "(") {
        pos += 2;
        const args: Term[] = [];
        if (!peek(")")) {
          args.push(parseTerm());
          while (peek(",")) { pos++; args.push(parseTerm()); }
        }
        take(")");
        if (name === "P" || name === "Q") {
          if (args.length !== 1) throw new Error(name + " требует один аргумент.");
          return { type: "atom", pred: name, args };
        }
        if (name === "R") {
          if (args.length !== 2) throw new Error("R требует два аргумента.");
          return { type: "atom", pred: name, args };
        }
        throw new Error("Неизвестный предикат: " + name + ". Доступны P, Q, R.");
      }
      const term = parseTerm();
      if (peek("=")) {
        pos++;
        return { type: "eq", a: term, b: parseTerm() };
      }
      throw new Error("После терма ожидалось =.");
    }
    throw new Error("Ожидалась атомарная формула.");
  }

  if (tokens.length === 0) throw new Error("Пустая формула.");
  const ast = parseIff();
  if (pos !== tokens.length) throw new Error("Лишний фрагмент формулы.");
  return ast;
}

export function freeVars(ast: Formula, bound?: Set<string>): Set<string> {
  const boundSet = bound || new Set<string>();
  const out = new Set<string>();
  if (ast.type === "atom" || ast.type === "eq") {
    const terms: Term[] = ast.type === "atom" ? ast.args : [ast.a, ast.b];
    for (const term of terms) {
      if (term && term.type === "var" && !boundSet.has(term.name)) out.add(term.name);
    }
  } else if (ast.type === "not") {
    for (const name of freeVars(ast.a, boundSet)) out.add(name);
  } else if (ast.type === "forall" || ast.type === "exists") {
    const next = new Set(boundSet);
    next.add(ast.variable);
    for (const name of freeVars(ast.body, next)) out.add(name);
  } else if (ast.type === "and" || ast.type === "or" || ast.type === "impl" || ast.type === "iff") {
    for (const name of freeVars(ast.a, boundSet)) out.add(name);
    for (const name of freeVars(ast.b, boundSet)) out.add(name);
  }
  return out;
}

function termValue(term: Term, env: Env): number {
  if (term.type === "const") return term.value;
  if (!(term.name in env)) throw new Error("Свободная переменная: " + term.name);
  return env[term.name];
}

export function evalFormula(ast: Formula, env: Env, model: Model): boolean {
  switch (ast.type) {
    case "const": return ast.value;
    case "atom": {
      if (ast.pred === "P" || ast.pred === "Q") {
        return model.preds[ast.pred].has(termValue(ast.args[0], env));
      }
      const a = termValue(ast.args[0], env);
      const b = termValue(ast.args[1], env);
      return model.preds.R.has(a + "," + b);
    }
    case "eq": return termValue(ast.a, env) === termValue(ast.b, env);
    case "not": return !evalFormula(ast.a, env, model);
    case "and": return evalFormula(ast.a, env, model) && evalFormula(ast.b, env, model);
    case "or": return evalFormula(ast.a, env, model) || evalFormula(ast.b, env, model);
    case "impl": return !evalFormula(ast.a, env, model) || evalFormula(ast.b, env, model);
    case "iff": return evalFormula(ast.a, env, model) === evalFormula(ast.b, env, model);
    case "forall":
      return model.domain.every((value) => evalFormula(ast.body, { ...env, [ast.variable]: value }, model));
    case "exists":
      return model.domain.some((value) => evalFormula(ast.body, { ...env, [ast.variable]: value }, model));
  }
}

function termTex(term: Term): string {
  return term.type === "const" ? String(term.value) : term.name;
}

export function toTex(ast: Formula, parentPrec?: number): string {
  const quantifier = ast.type === "forall" || ast.type === "exists";
  const prec = quantifier ? QUANT_PREC : (PREC[ast.type] || 0);
  let body: string;
  switch (ast.type) {
    case "const": body = ast.value ? "\\top" : "\\bot"; break;
    case "eq": body = termTex(ast.a) + " = " + termTex(ast.b); break;
    case "atom": body = ast.pred + "(" + ast.args.map(termTex).join(", ") + ")"; break;
    case "not": body = "\\neg " + toTex(ast.a, PREC.not); break;
    case "and": body = toTex(ast.a, PREC.and) + " \\land " + toTex(ast.b, PREC.and); break;
    case "or": body = toTex(ast.a, PREC.or) + " \\lor " + toTex(ast.b, PREC.or); break;
    case "impl": body = toTex(ast.a, PREC.impl + 1) + " \\to " + toTex(ast.b, PREC.impl); break;
    case "iff": body = toTex(ast.a, PREC.iff + 1) + " \\leftrightarrow " + toTex(ast.b, PREC.iff); break;
    case "forall": body = "\\forall " + ast.variable + "\\," + quantifierBody(ast.body); break;
    case "exists": body = "\\exists " + ast.variable + "\\," + quantifierBody(ast.body); break;
  }
  const needParens = parentPrec !== undefined && prec < parentPrec;
  return needParens ? "\\left(" + body + "\\right)" : body;
}

export function initialModel(n: number): Model {
  return {
    domain: Array.from({ length: n }, (_, i) => i + 1),
    preds: {
      P: new Set([1]),
      Q: new Set(n > 1 ? [1, 2] : [1]),
      R: new Set(),
    },
  };
}

export function quantifierRows(ast: Formula, model: Model): QuantifierRow[] | null {
  if (ast.type !== "forall" && ast.type !== "exists") return null;
  return model.domain.map((value) => ({
    value,
    truth: evalFormula(ast.body, { [ast.variable]: value }, model),
  }));
}
