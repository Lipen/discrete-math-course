/* Set expressions over A, B and C, evaluated by membership pattern. */

export type SetExpression =
  | { type: "var"; name: "A" | "B" | "C" }
  | { type: "not"; a: SetExpression }
  | { type: "and"; a: SetExpression; b: SetExpression }
  | { type: "or"; a: SetExpression; b: SetExpression }
  | { type: "diff"; a: SetExpression; b: SetExpression }
  | { type: "xor"; a: SetExpression; b: SetExpression };

export interface Membership {
  a: boolean;
  b: boolean;
  c: boolean;
}

export interface Pattern {
  index: number;
  bits: string;
  value: Membership;
}

/** All eight membership types of a universe split by A, B and C. */
export const PATTERNS: Pattern[] = Array.from({ length: 8 }, (_, index) => ({
  index,
  bits: index.toString(2).padStart(3, "0"),
  value: {
    a: Boolean(index & 4),
    b: Boolean(index & 2),
    c: Boolean(index & 1),
  },
}));

function normalize(input: string): string {
  return input
    .replace(/∪/g, "|")
    .replace(/∩/g, "&")
    .replace(/△/g, "^")
    .replace(/∖/g, "\\")
    .replace(/ᶜ/g, "'")
    .replace(/[−–]/g, "-")
    .replace(/∨/g, "|")
    .replace(/∧/g, "&")
    .replace(/¬/g, "!");
}

type TokenType = "var" | "(" | ")" | "and" | "or" | "diff" | "xor" | "not" | "compl";

interface Token {
  type: TokenType;
  name?: "A" | "B" | "C";
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
    if (ch === "^") {
      tokens.push({ type: "xor" });
      i++;
      continue;
    }
    if (ch === "\\" || ch === "-") {
      tokens.push({ type: "diff" });
      i++;
      continue;
    }
    if (ch === "!") {
      tokens.push({ type: "not" });
      i++;
      continue;
    }
    if (ch === "'") {
      tokens.push({ type: "compl" });
      i++;
      continue;
    }
    if (/[abcABC]/.test(ch)) {
      tokens.push({ type: "var", name: ch.toUpperCase() as "A" | "B" | "C" });
      i++;
      continue;
    }
    throw new Error("Неизвестный символ: " + ch);
  }
  return tokens;
}

export function parse(input: string): SetExpression {
  const tokens = tokenize(input);
  let pos = 0;

  function peek(type: TokenType): boolean {
    return Boolean(tokens[pos] && tokens[pos].type === type);
  }

  function take(type: TokenType): Token {
    if (!peek(type)) throw new Error("Ожидалось " + type);
    return tokens[pos++];
  }

  function parseUnion(): SetExpression {
    let left = parseInter();
    while (peek("or") || peek("xor")) {
      const op = tokens[pos++].type;
      const right = parseInter();
      left = { type: op === "or" ? "or" : "xor", a: left, b: right };
    }
    return left;
  }

  function parseInter(): SetExpression {
    let left = parseComplement();
    while (peek("and") || peek("diff")) {
      const op = tokens[pos++].type;
      const right = parseComplement();
      left = { type: op === "and" ? "and" : "diff", a: left, b: right };
    }
    return left;
  }

  function parseComplement(): SetExpression {
    if (peek("not")) {
      pos++;
      return { type: "not", a: parseComplement() };
    }
    let expression = parsePrimary();
    while (peek("compl")) {
      pos++;
      expression = { type: "not", a: expression };
    }
    return expression;
  }

  function parsePrimary(): SetExpression {
    if (peek("(")) {
      pos++;
      const expression = parseUnion();
      take(")");
      return expression;
    }
    const token = take("var");
    if (!token.name) throw new Error("Ожидалось множество A, B или C.");
    return { type: "var", name: token.name };
  }

  if (tokens.length === 0) throw new Error("Пустое выражение.");
  const expression = parseUnion();
  if (pos !== tokens.length) throw new Error("Лишний фрагмент выражения.");
  return expression;
}

export function evaluate(expression: SetExpression, value: Membership): boolean {
  switch (expression.type) {
    case "var":
      return value[expression.name.toLowerCase() as "a" | "b" | "c"];
    case "not":
      return !evaluate(expression.a, value);
    case "and":
      return evaluate(expression.a, value) && evaluate(expression.b, value);
    case "or":
      return evaluate(expression.a, value) || evaluate(expression.b, value);
    case "diff":
      return evaluate(expression.a, value) && !evaluate(expression.b, value);
    case "xor":
      return evaluate(expression.a, value) !== evaluate(expression.b, value);
  }
}

const PREC = { or: 1, xor: 1, and: 2, diff: 2, not: 3, var: 4 } as const;

function tex(expression: SetExpression, parentPrec = 0): string {
  let body: string;
  switch (expression.type) {
    case "var":
      body = expression.name;
      break;
    case "not":
      body = expression.a.type === "var" ? tex(expression.a) + "^{c}" : "\\left(" + tex(expression.a) + "\\right)^{c}";
      break;
    case "and":
      body = tex(expression.a, PREC.and) + " \\cap " + tex(expression.b, PREC.and);
      break;
    case "or":
      body = tex(expression.a, PREC.or) + " \\cup " + tex(expression.b, PREC.or);
      break;
    case "diff":
      body = tex(expression.a, PREC.diff) + " \\setminus " + tex(expression.b, PREC.diff + 1);
      break;
    case "xor":
      body = tex(expression.a, PREC.xor) + " \\triangle " + tex(expression.b, PREC.xor);
      break;
  }
  return PREC[expression.type] < parentPrec ? "\\left(" + body + "\\right)" : body;
}

export function toTex(expression: SetExpression): string {
  return tex(expression);
}

export function patternDescription(pattern: Pattern): string {
  const memberships = [
    pattern.value.a ? "x ∈ A" : "x ∉ A",
    pattern.value.b ? "x ∈ B" : "x ∉ B",
    pattern.value.c ? "x ∈ C" : "x ∉ C",
  ];
  return memberships.join(", ");
}
