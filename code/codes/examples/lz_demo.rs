//! LZ77 and LZ78 side by side on the word "ABRACADABRA".
//!
//! The demo prints the LZ77 triples and the LZ78 pairs for the same input,
//! rebuilds the input from each encoding, and shows the phrase dictionary
//! that LZ78 has learned by the end.

/// Longest match of the remainder against the coded prefix, nearest occurrence preferred.
/// Returns (offset, length), offset counted back from the cursor.
fn longest_match(s: &[char], pos: usize) -> (usize, usize) {
    let mut best = (0usize, 0usize);
    for start in (0..pos).rev() {
        let mut len = 0;
        while len < s.len() - pos && s[start + len] == s[pos + len] {
            len += 1;
        }
        if len > best.1 {
            best = (pos - start, len);
        }
    }
    best
}

/// Encode the input as LZ77 triples over a window equal to the whole prefix.
fn lz77(s: &[char]) -> Vec<(usize, usize, Option<char>)> {
    let mut out = Vec::new();
    let mut pos = 0;
    while pos < s.len() {
        let (o, l) = longest_match(s, pos);
        if l == 0 {
            out.push((0, 0, Some(s[pos])));
            pos += 1;
        } else {
            let fresh = (pos + l < s.len()).then(|| s[pos + l]);
            out.push((o, l, fresh));
            pos += l + usize::from(fresh.is_some());
        }
    }
    out
}

/// Rebuild the text from LZ77 triples, copying from the decoder's own output.
fn lz77_decode(triples: &[(usize, usize, Option<char>)]) -> String {
    let mut out: Vec<char> = Vec::new();
    for &(o, l, fresh) in triples {
        let start = out.len() - o;
        for k in 0..l {
            out.push(out[start + k]);
        }
        if let Some(c) = fresh {
            out.push(c);
        }
    }
    out.into_iter().collect()
}

/// Encode the input as LZ78 pairs, learning one dictionary phrase per pair.
fn lz78(s: &[char]) -> (Vec<(usize, char)>, Vec<String>) {
    let mut dict: Vec<String> = vec![String::new()]; // phrase 0 = empty
    let mut out = Vec::new();
    let mut pos = 0;
    while pos < s.len() {
        // Longest learned phrase that is a prefix of the remaining input.
        let mut best = 0usize;
        for (idx, phrase) in dict.iter().enumerate() {
            if idx > 0
                && phrase.len() > dict[best].len()
                && pos + phrase.len() <= s.len()
                && s[pos..pos + phrase.len()]
                    .iter()
                    .copied()
                    .eq(phrase.chars())
            {
                best = idx;
            }
        }
        let fresh = s[pos + dict[best].len()];
        out.push((best, fresh));
        let mut phrase = dict[best].clone();
        phrase.push(fresh);
        dict.push(phrase);
        pos += dict[best].len() + 1;
    }
    (out, dict)
}

/// Rebuild the text from LZ78 pairs, replaying dictionary growth.
fn lz78_decode(pairs: &[(usize, char)]) -> String {
    let mut dict: Vec<String> = vec![String::new()];
    let mut text = String::new();
    for &(i, c) in pairs {
        let mut phrase = dict[i].clone();
        phrase.push(c);
        text.push_str(&phrase);
        dict.push(phrase);
    }
    text
}

fn main() {
    let input: Vec<char> = "ABRACADABRA".chars().collect();
    println!("LZ77 and LZ78 on \"ABRACADABRA\" ({} letters)", input.len());

    let triples = lz77(&input);
    println!("\nLZ77, window = whole prefix, longest match:");
    for (o, l, fresh) in &triples {
        match fresh {
            Some(c) => println!("  ({o}, {l}, {c})"),
            None => println!("  ({o}, {l})   end of input"),
        }
    }
    let text = lz77_decode(&triples);
    println!(
        "{} triples, decoded = \"{text}\"  matches: {}",
        triples.len(),
        text.chars().eq(input.iter().copied())
    );

    let (pairs, dict) = lz78(&input);
    println!("\nLZ78, growing dictionary of phrases:");
    for (idx, (i, c)) in pairs.iter().enumerate() {
        println!("  ({i}, {c}) adds phrase {} = {}", idx + 1, dict[idx + 1]);
    }
    let text = lz78_decode(&pairs);
    println!(
        "{} pairs, dictionary holds {} phrases, decoded = \"{text}\"  matches: {}",
        pairs.len(),
        dict.len() - 1,
        text == input.iter().collect::<String>()
    );

    // The book example: six triples and seven pairs for eleven letters.
    assert_eq!(triples.len(), 6);
    assert_eq!(pairs.len(), 7);
}
