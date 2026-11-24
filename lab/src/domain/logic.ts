/* Propositional formulas: parser, truth tables, entailment. */

export type PropEnv = Record<string, boolean>;

export type PropAst =
  | { type: "const"; value: boolean }
  | { type: "var"; name: string }
  | { type: "not"; a: PropAst }
  | { type: "and"; a: PropAst; b: PropAst }
  | { type: "or"; a: PropAst; b: PropAst }
  | { type: "impl"; a: PropAst; b: PropAst }
  | { type: "iff"; a: PropAst; b: PropAst };

export interface TruthRow {
  bits: number[];
  env: PropEnv;
  value: boolean;
}

export interface TruthTable {
  vars: string[];
  rows: TruthRow[];
}

export interface Classified {
  table: TruthTable;
  trueCount: number;
  falseCount: number;
  kind: "tautology" | "contradiction" | "contingent";
}

export interface EntailmentRow {
  bits: number[];
  env: PropEnv;
  premises: boolean[];
  conclusion: boolean;
}

export interface Entailment {
  vars: string[];
  rows: EntailmentRow[];
  holds: boolean;
  counterexample: EntailmentRow | null;
}

const PREC: Record<PropAst["type"], number> = {
  iff: 1,
  impl: 2,
  or: 3,
  and: 4,
  not: 5,
  const: 7,
  var: 7,
};

type Token =
  | { type: "(" | ")" }
  | { type: "not" | "and" | "or" | "impl" | "iff" }
  | { type: "const"; value: boolean }
  | { type: "name"; value: string };

export function normalize(input: string): string {
  return String(input || "")
    .replace(/↔/g, "<->")
    .replace(/⇔/g, "<->")
    .replace(/→/g, "->")
    .replace(/⇒/g, "->")
    .replace(/∧/g, "&")
    .replace(/∨/g, "|")
    .replace(/¬/g, "!")
    .replace(/⊤/g, "1")
    .replace(/⊥/g, "0");
}

function tokenize(input: string): Token[] {
  const source = normalize(input);
  const tokens: Token[] = [];
  let i = 0;
  while (i < source.length) {
    const ch = source[i];
    if (/\s/.test(ch)) {
      i++;
      continue;
    }
    if (ch === "(" || ch === ")") {
      tokens.push({ type: ch });
      i++;
      continue;
    }
    if (ch === "!") {
      tokens.push({ type: "not" });
      i++;
      continue;
    }
    if (ch === "&") {
      tokens.push({ type: "and" });
      i++;
      continue;
    }
    if (ch === "|") {
      tokens.push({ type: "or" });
      i++;
      continue;
    }
    if (source.startsWith("<->", i)) {
      tokens.push({ type: "iff" });
      i += 3;
      continue;
    }
    if (source.startsWith("->", i)) {
      tokens.push({ type: "impl" });
      i += 2;
      continue;
    }
    if (ch === "=" && source[i + 1] === ">") {
      tokens.push({ type: "impl" });
      i += 2;
      continue;
    }
    if (/[A-Za-z_]/.test(ch)) {
      let j = i + 1;
      while (j < source.length && /[A-Za-z0-9_]/.test(source[j])) j++;
      const name = source.slice(i, j);
      const lower = name.toLowerCase();
      if (lower === "true" || lower === "top") tokens.push({ type: "const", value: true });
      else if (lower === "false" || lower === "bot") tokens.push({ type: "const", value: false });
      else tokens.push({ type: "name", value: name });
      i = j;
      continue;
    }
    if (ch === "0" || ch === "1") {
      tokens.push({ type: "const", value: ch === "1" });
      i++;
      continue;
    }
    throw new Error("Неизвестный символ: " + ch);
  }
  return tokens;
}

export function parse(input: string): PropAst {
  const tokens = tokenize(input);
  let pos = 0;

  function peek(type: Token["type"]): boolean {
    return Boolean(tokens[pos] && tokens[pos].type === type);
  }
  function take(type: Token["type"]): Token {
    if (!peek(type)) throw new Error("Ожидалось " + type);
    return tokens[pos++];
  }

  function parseIff(): PropAst {
    let left = parseImpl();
    while (peek("iff")) {
      pos++;
      left = { type: "iff", a: left, b: parseImpl() };
    }
    return left;
  }

  function parseImpl(): PropAst {
    const left = parseOr();
    if (peek("impl")) {
      pos++;
      return { type: "impl", a: left, b: parseImpl() };
    }
    return left;
  }

  function parseOr(): PropAst {
    let left = parseAnd();
    while (peek("or")) {
      pos++;
      left = { type: "or", a: left, b: parseAnd() };
    }
    return left;
  }

  function parseAnd(): PropAst {
    let left = parseNot();
    while (peek("and")) {
      pos++;
      left = { type: "and", a: left, b: parseNot() };
    }
    return left;
  }

  function parseNot(): PropAst {
    if (peek("not")) {
      pos++;
      return { type: "not", a: parseNot() };
    }
    return parseAtom();
  }

  function parseAtom(): PropAst {
    if (peek("(")) {
      pos++;
      const node = parseIff();
      take(")");
      return node;
    }
    if (peek("const")) {
      const token = tokens[pos++];
      if (token.type !== "const") throw new Error("Ожидалась константа.");
      return { type: "const", value: token.value };
    }
    if (peek("name")) {
      const token = tokens[pos++];
      if (token.type !== "name") throw new Error("Ожидалось имя переменной.");
      return { type: "var", name: token.value };
    }
    throw new Error("Ожидалась переменная, константа или скобка.");
  }

  if (tokens.length === 0) throw new Error("Пустая формула.");
  const ast = parseIff();
  if (pos !== tokens.length) throw new Error("Лишний фрагмент формулы.");
  return ast;
}

export function varsOf(ast: PropAst, out?: Set<string>): Set<string> {
  const set = out || new Set<string>();
  if (ast.type === "var") set.add(ast.name);
  else if (ast.type === "not") varsOf(ast.a, set);
  else if (ast.type === "and" || ast.type === "or" || ast.type === "impl" || ast.type === "iff") {
    varsOf(ast.a, set);
    varsOf(ast.b, set);
  }
  return set;
}

export function evaluate(ast: PropAst, env: PropEnv): boolean {
  switch (ast.type) {
    case "const":
      return ast.value;
    case "var":
      return Boolean(env[ast.name]);
    case "not":
      return !evaluate(ast.a, env);
    case "and":
      return evaluate(ast.a, env) && evaluate(ast.b, env);
    case "or":
      return evaluate(ast.a, env) || evaluate(ast.b, env);
    case "impl":
      return !evaluate(ast.a, env) || evaluate(ast.b, env);
    case "iff":
      return evaluate(ast.a, env) === evaluate(ast.b, env);
  }
}

export function allVars(ast: PropAst): string[] {
  return Array.from(varsOf(ast)).sort();
}

function assignments(names: string[]): Array<{ bits: number[]; env: PropEnv }> {
  const out: Array<{ bits: number[]; env: PropEnv }> = [];
  for (let mask = 0; mask < 1 << names.length; mask++) {
    const env: PropEnv = {};
    const bits: number[] = [];
    for (let i = 0; i < names.length; i++) {
      const value = Boolean(mask & (1 << (names.length - 1 - i)));
      env[names[i]] = value;
      bits.push(value ? 1 : 0);
    }
    out.push({ bits, env });
  }
  return out;
}

export function truthTable(ast: PropAst, vars?: string[]): TruthTable {
  const names = vars || allVars(ast);
  const rows = assignments(names).map(({ bits, env }) => ({ bits, env, value: evaluate(ast, env) }));
  return { vars: names, rows };
}

export function classify(ast: PropAst, vars?: string[]): Classified {
  const table = truthTable(ast, vars);
  const trueCount = table.rows.filter((row) => row.value).length;
  return {
    table,
    trueCount,
    falseCount: table.rows.length - trueCount,
    kind: trueCount === table.rows.length ? "tautology" : trueCount === 0 ? "contradiction" : "contingent",
  };
}

export function entails(premiseAsts: PropAst[], conclusionAst: PropAst, vars?: string[]): Entailment {
  const names = vars || Array.from(new Set(premiseAsts.concat([conclusionAst]).flatMap((ast) => allVars(ast)))).sort();
  const rows: EntailmentRow[] = [];
  let counterexample: EntailmentRow | null = null;
  for (const { bits, env } of assignments(names)) {
    const premises = premiseAsts.map((ast) => evaluate(ast, env));
    const conclusion = evaluate(conclusionAst, env);
    const row = { bits, env, premises, conclusion };
    rows.push(row);
    if (!counterexample && premises.every(Boolean) && !conclusion) counterexample = row;
  }
  return { vars: names, rows, holds: !counterexample, counterexample };
}

export function toTex(ast: PropAst, parentPrec?: number): string {
  const prec = PREC[ast.type] || 0;
  let body: string;
  switch (ast.type) {
    case "const":
      body = ast.value ? "\\top" : "\\bot";
      break;
    case "var":
      body = /^[A-Za-z]$/.test(ast.name) ? ast.name : "\\mathrm{" + ast.name.replace(/_/g, "\\_") + "}";
      break;
    case "not":
      body = "\\neg " + toTex(ast.a, PREC.not);
      break;
    case "and":
      body = toTex(ast.a, PREC.and) + " \\land " + toTex(ast.b, PREC.and);
      break;
    case "or":
      body = toTex(ast.a, PREC.or) + " \\lor " + toTex(ast.b, PREC.or);
      break;
    case "impl":
      body = toTex(ast.a, PREC.impl + 1) + " \\to " + toTex(ast.b, PREC.impl);
      break;
    case "iff":
      body = toTex(ast.a, PREC.iff + 1) + " \\leftrightarrow " + toTex(ast.b, PREC.iff);
      break;
  }
  const needParens = parentPrec !== undefined && prec < parentPrec;
  return needParens ? "\\left(" + body + "\\right)" : body;
}

export interface FormulaTree {
  label: string;
  children: FormulaTree[];
}

export function tree(ast: PropAst): FormulaTree {
  if (ast.type === "const") return { label: ast.value ? "⊤" : "⊥", children: [] };
  if (ast.type === "var") return { label: ast.name, children: [] };
  if (ast.type === "not") return { label: "¬", children: [tree(ast.a)] };
  const op = { and: "∧", or: "∨", impl: "→", iff: "↔" }[ast.type];
  return { label: op, children: [tree(ast.a), tree(ast.b)] };
}
