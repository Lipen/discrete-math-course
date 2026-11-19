/* First-order formulas over a finite model with P, Q and R. */
(function () {
  "use strict";

  const PREC = { iff: 1, impl: 2, or: 3, and: 4, not: 5, quant: 6, forall: 6, exists: 6, atom: 7, const: 7, eq: 7, var: 7 };

  function normalize(input) {
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

  function tokenize(input) {
    const source = normalize(input);
    const tokens = [];
    let i = 0;
    while (i < source.length) {
      const ch = source[i];
      if (/\s/.test(ch)) { i++; continue; }
      if ("(),=".includes(ch)) { tokens.push({ type: ch }); i++; continue; }
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

  function parse(input) {
    const tokens = tokenize(input);
    let pos = 0;
    function peek(type) { return tokens[pos] && tokens[pos].type === type; }
    function take(type) {
      if (!peek(type)) throw new Error("Ожидалось " + type);
      return tokens[pos++];
    }

    function parseIff() {
      let left = parseImpl();
      while (peek("iff")) { pos++; left = { type: "iff", a: left, b: parseImpl() }; }
      return left;
    }

    function parseImpl() {
      const left = parseOr();
      if (peek("impl")) { pos++; return { type: "impl", a: left, b: parseImpl() }; }
      return left;
    }

    function parseOr() {
      let left = parseAnd();
      while (peek("or")) { pos++; left = { type: "or", a: left, b: parseAnd() }; }
      return left;
    }

    function parseAnd() {
      let left = parseUnary();
      while (peek("and")) { pos++; left = { type: "and", a: left, b: parseUnary() }; }
      return left;
    }

    function parseUnary() {
      if (peek("not")) { pos++; return { type: "not", a: parseUnary() }; }
      if (peek("forall") || peek("exists")) {
        const type = tokens[pos++].type;
        const variable = take("name").value;
        return { type: type === "forall" ? "forall" : "exists", variable, body: parseUnary() };
      }
      return parseAtom();
    }

    function parseTerm() {
      if (peek("number")) return { type: "const", value: tokens[pos++].value };
      if (peek("name")) return { type: "var", name: tokens[pos++].value };
      throw new Error("Ожидался терм: переменная или число.");
    }

    function parseAtom() {
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
        const name = tokens[pos].value;
        if (tokens[pos + 1] && tokens[pos + 1].type === "(") {
          pos += 2;
          const args = [];
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

  function freeVars(ast, bound) {
    const boundSet = bound || new Set();
    const out = new Set();
    if (!ast) return out;
    if (ast.type === "atom" || ast.type === "eq") {
      for (const term of (ast.args || [ast.a, ast.b])) {
        if (term && term.type === "var" && !boundSet.has(term.name)) out.add(term.name);
      }
    } else if (ast.type === "not") {
      for (const name of freeVars(ast.a, boundSet)) out.add(name);
    } else if (ast.type === "forall" || ast.type === "exists") {
      const next = new Set(boundSet);
      next.add(ast.variable);
      for (const name of freeVars(ast.body, next)) out.add(name);
    } else if (ast.a && ast.b) {
      for (const name of freeVars(ast.a, boundSet)) out.add(name);
      for (const name of freeVars(ast.b, boundSet)) out.add(name);
    }
    return out;
  }

  function termValue(term, env) {
    if (term.type === "const") return term.value;
    if (!(term.name in env)) throw new Error("Свободная переменная: " + term.name);
    return env[term.name];
  }

  function evalFormula(ast, env, model) {
    switch (ast.type) {
      case "const": return ast.value;
      case "atom": {
        if (ast.pred === "P" || ast.pred === "Q") {
          const value = termValue(ast.args[0], env);
          return model.preds[ast.pred].has(value);
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
        return model.domain.every((value) => evalFormula(ast.body, Object.assign({}, env, { [ast.variable]: value }), model));
      case "exists":
        return model.domain.some((value) => evalFormula(ast.body, Object.assign({}, env, { [ast.variable]: value }), model));
      default:
        throw new Error("Неизвестный узел формулы.");
    }
  }

  function toTex(ast, parentPrec) {
    const prec = PREC[ast.type] || 0;
    let body;
    switch (ast.type) {
      case "const": body = ast.value ? "\\top" : "\\bot"; break;
      case "eq": body = termTex(ast.a) + " = " + termTex(ast.b); break;
      case "atom": body = ast.pred + "(" + ast.args.map(termTex).join(", ") + ")"; break;
      case "not": body = "\\neg " + toTex(ast.a, PREC.not); break;
      case "and": body = toTex(ast.a, PREC.and) + " \\land " + toTex(ast.b, PREC.and); break;
      case "or": body = toTex(ast.a, PREC.or) + " \\lor " + toTex(ast.b, PREC.or); break;
      case "impl": body = toTex(ast.a, PREC.impl + 1) + " \\to " + toTex(ast.b, PREC.impl); break;
      case "iff": body = toTex(ast.a, PREC.iff + 1) + " \\leftrightarrow " + toTex(ast.b, PREC.iff); break;
      case "forall": body = "\\forall " + ast.variable + "\\," + toTex(ast.body, PREC.quant); break;
      case "exists": body = "\\exists " + ast.variable + "\\," + toTex(ast.body, PREC.quant); break;
      default: body = "?";
    }
    const needParens = parentPrec !== undefined && prec < parentPrec;
    return needParens ? "\\left(" + body + "\\right)" : body;
  }

  function termTex(term) {
    return term.type === "const" ? String(term.value) : term.name;
  }

  function initialModel(n) {
    return {
      domain: Array.from({ length: n }, (_, i) => i + 1),
      preds: {
        P: new Set([1]),
        Q: new Set(n > 1 ? [1, 2] : [1]),
        R: new Set(),
      },
    };
  }

  function quantifierRows(ast, model) {
    if (ast.type !== "forall" && ast.type !== "exists") return null;
    return model.domain.map((value) => ({
      value,
      truth: evalFormula(ast.body, { [ast.variable]: value }, model),
    }));
  }

  window.FOL = {
    parse,
    evalFormula,
    freeVars,
    toTex,
    initialModel,
    quantifierRows,
  };
})();
