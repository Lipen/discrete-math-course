//! Combinational circuits as DAGs of gates.
//!
//! A circuit is a directed acyclic graph: its sources are the primary inputs
//! and the constants 0/1, its internal nodes are logic gates (AND, OR, XOR,
//! NOT), and its sinks are the outputs. Because a gate may only reference
//! nodes created before it, the builder keeps the node list in topological
//! order and acyclicity holds by construction -- a signal never loops back.
//!
//! Two measures describe a circuit:
//!
//! * **size** -- the number of gates (the hardware cost, chip area);
//! * **depth** -- the longest path from an input to an output (the signal
//!   delay, the clock rate).
//!
//! Parallel branches count only once toward depth: two gates feeding a third
//! both sit one level below it, so together they add one, not two.

use std::fmt;

/// A node id: an index into a [`Circuit`]`'s node table.
pub type NodeId = usize;

/// A circuit node: a source (input or constant) or a logic gate.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Gate {
    /// The `i`-th primary input.
    Input(usize),
    /// The constant 0 or 1.
    Const(bool),
    /// `a AND b`.
    And(NodeId, NodeId),
    /// `a OR b`.
    Or(NodeId, NodeId),
    /// `a XOR b`.
    Xor(NodeId, NodeId),
    /// `NOT a`.
    Not(NodeId),
}

impl Gate {
    /// Whether this node is a gate (not a source). Gates are what size counts.
    pub fn is_gate(self) -> bool {
        matches!(
            self,
            Gate::And(..) | Gate::Or(..) | Gate::Xor(..) | Gate::Not(..)
        )
    }
}

/// An error from simulating or querying a circuit.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum CircuitError {
    /// The assignment did not provide the needed primary input index.
    MissingInput(usize),
    /// A node id was not part of this circuit.
    UnknownNode(NodeId),
    /// A bit-slice of the wrong width was fed to an adder.
    WidthMismatch {
        /// The number of bits the adder expects per operand.
        expected: usize,
        /// The width of the first operand that was passed.
        got_x: usize,
        /// The width of the second operand that was passed.
        got_y: usize,
    },
}

impl fmt::Display for CircuitError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CircuitError::MissingInput(i) => {
                write!(f, "no value for primary input {i} in the assignment")
            }
            CircuitError::UnknownNode(n) => write!(f, "node {n} is not part of this circuit"),
            CircuitError::WidthMismatch {
                expected,
                got_x,
                got_y,
            } => write!(
                f,
                "adder expects {expected} bits per operand, got {got_x} and {got_y}"
            ),
        }
    }
}

impl std::error::Error for CircuitError {}

/// A combinational circuit: a DAG of gates held in topological order.
///
/// Build a circuit by creating sources ([`Circuit::input`],
/// [`Circuit::constant`]) and combining them with the gate constructors.
/// Each constructor returns a fresh [`NodeId`] that later gates may feed on.
///
/// ```
/// use circuits::Circuit;
///
/// // (x AND y) OR NOT z -- size 3, depth 2.
/// let mut c = Circuit::new();
/// let x = c.input(0);
/// let y = c.input(1);
/// let z = c.input(2);
/// let xy = c.and(x, y);
/// let nz = c.not(z);
/// let f = c.or(xy, nz);
///
/// assert_eq!(c.size(), 3);
/// assert_eq!(c.depth(), 2);
/// assert!(c.eval(f, &[true, true, false]).unwrap());
/// assert!(!c.eval(f, &[true, false, true]).unwrap());
/// ```
#[derive(Debug, Clone, Default)]
pub struct Circuit {
    nodes: Vec<Gate>,
    inputs: Vec<Option<NodeId>>,
    consts: [Option<NodeId>; 2],
}

impl Circuit {
    /// An empty circuit with no nodes.
    pub fn new() -> Self {
        Self::default()
    }

    /// The `i`-th primary input, creating it once and reusing it on later
    /// calls. Reusing the node lets one input feed several gates (fan-out).
    pub fn input(&mut self, index: usize) -> NodeId {
        if let Some(n) = self.inputs.get(index).copied().flatten() {
            return n;
        }
        let node = self.nodes.len();
        self.nodes.push(Gate::Input(index));
        if self.inputs.len() <= index {
            self.inputs.resize(index + 1, None);
        }
        self.inputs[index] = Some(node);
        node
    }

    /// The constant `value` (0 or 1), created once and reused.
    pub fn constant(&mut self, value: bool) -> NodeId {
        if let Some(n) = self.consts[value as usize] {
            return n;
        }
        let node = self.nodes.len();
        self.nodes.push(Gate::Const(value));
        self.consts[value as usize] = Some(node);
        node
    }

    /// The constant 0.
    pub fn zero(&mut self) -> NodeId {
        self.constant(false)
    }

    /// The constant 1.
    pub fn one(&mut self) -> NodeId {
        self.constant(true)
    }

    /// A new `a AND b` gate.
    pub fn and(&mut self, a: NodeId, b: NodeId) -> NodeId {
        self.push(Gate::And(a, b))
    }

    /// A new `a OR b` gate.
    pub fn or(&mut self, a: NodeId, b: NodeId) -> NodeId {
        self.push(Gate::Or(a, b))
    }

    /// A new `a XOR b` gate.
    pub fn xor(&mut self, a: NodeId, b: NodeId) -> NodeId {
        self.push(Gate::Xor(a, b))
    }

    /// A new `NOT a` gate.
    pub fn not(&mut self, a: NodeId) -> NodeId {
        self.push(Gate::Not(a))
    }

    fn push(&mut self, gate: Gate) -> NodeId {
        let node = self.nodes.len();
        self.nodes.push(gate);
        node
    }

    /// Total number of nodes (sources and gates).
    pub fn node_count(&self) -> usize {
        self.nodes.len()
    }

    /// Number of distinct primary inputs.
    pub fn input_count(&self) -> usize {
        self.nodes
            .iter()
            .filter_map(|g| match g {
                Gate::Input(i) => Some(*i),
                _ => None,
            })
            .max()
            .map_or(0, |i| i + 1)
    }

    /// Size: the number of gates (sources and constants are not counted).
    pub fn size(&self) -> usize {
        self.nodes.iter().filter(|g| g.is_gate()).count()
    }

    /// Depth: the longest path from a source to any node, in gates.
    /// Sources sit at depth 0; each gate adds one to its deepest input.
    pub fn depth(&self) -> usize {
        self.depths().into_iter().max().unwrap_or(0)
    }

    /// Depth of the sub-circuit feeding `node`, in gates.
    ///
    /// # Panics
    ///
    /// Panics if `node` does not belong to this circuit.
    pub fn node_depth(&self, node: NodeId) -> usize {
        self.depths()[node]
    }

    /// One depth value per node, in node order.
    fn depths(&self) -> Vec<usize> {
        let mut d = vec![0; self.nodes.len()];
        for (id, gate) in self.nodes.iter().enumerate() {
            d[id] = match *gate {
                Gate::Input(_) | Gate::Const(_) => 0,
                Gate::And(a, b) | Gate::Or(a, b) | Gate::Xor(a, b) => 1 + d[a].max(d[b]),
                Gate::Not(a) => 1 + d[a],
            };
        }
        d
    }

    /// Simulate the circuit. `inputs` is indexed by primary input number and
    /// must cover every input the circuit reads. Returns one value per node.
    pub fn simulate(&self, inputs: &[bool]) -> Result<Vec<bool>, CircuitError> {
        let mut values = vec![false; self.nodes.len()];
        for (id, gate) in self.nodes.iter().enumerate() {
            values[id] = match *gate {
                Gate::Input(i) => *inputs.get(i).ok_or(CircuitError::MissingInput(i))?,
                Gate::Const(v) => v,
                Gate::And(a, b) => at(&values, a)? & at(&values, b)?,
                Gate::Or(a, b) => at(&values, a)? | at(&values, b)?,
                Gate::Xor(a, b) => at(&values, a)? ^ at(&values, b)?,
                Gate::Not(a) => !at(&values, a)?,
            };
        }
        Ok(values)
    }

    /// Simulate and return the value of a single output node.
    pub fn eval(&self, node: NodeId, inputs: &[bool]) -> Result<bool, CircuitError> {
        let values = self.simulate(inputs)?;
        values
            .get(node)
            .copied()
            .ok_or(CircuitError::UnknownNode(node))
    }
}

fn at(values: &[bool], node: NodeId) -> Result<bool, CircuitError> {
    values
        .get(node)
        .copied()
        .ok_or(CircuitError::UnknownNode(node))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn size_and_depth_of_a_small_circuit() {
        let mut c = Circuit::new();
        let x = c.input(0);
        let y = c.input(1);
        let z = c.input(2);
        let xy = c.and(x, y);
        let nz = c.not(z);
        c.or(xy, nz);

        // AND and NOT sit on level 1, OR on level 2.
        assert_eq!(c.size(), 3);
        assert_eq!(c.depth(), 2);
        assert_eq!(c.input_count(), 3);
        assert_eq!(c.node_count(), 6); // 3 inputs + 3 gates
    }

    #[test]
    fn inputs_and_constants_are_reused() {
        let mut c = Circuit::new();
        let x = c.input(0);
        assert_eq!(c.input(0), x);
        let z = c.zero();
        assert_eq!(c.zero(), z);
        let o = c.one();
        assert_eq!(c.one(), o);
        // One node per input and constant, regardless of how often requested.
        assert_eq!(c.node_count(), 3);
        assert_eq!(c.size(), 0); // no gates yet
    }

    #[test]
    fn simulate_matches_the_truth_table() {
        let mut c = Circuit::new();
        let x = c.input(0);
        let y = c.input(1);
        let xy = c.and(x, y);
        let nx = c.not(x);
        let f = c.or(xy, nx);

        // f(x, y) = (x AND y) OR NOT x.
        for (x, y, expected) in [
            (false, false, true),
            (false, true, true),
            (true, false, false),
            (true, true, true),
        ] {
            let got = c.eval(f, &[x, y]).unwrap();
            assert_eq!(got, expected, "x={x}, y={y}");
        }
    }

    #[test]
    fn missing_input_is_reported() {
        let mut c = Circuit::new();
        let x = c.input(0);
        let y = c.input(1);
        let f = c.and(x, y);
        assert_eq!(c.eval(f, &[true]), Err(CircuitError::MissingInput(1)));
    }

    #[test]
    fn parallel_branches_count_once_toward_depth() {
        let mut c = Circuit::new();
        let x = c.input(0);
        let y = c.input(1);
        let z = c.input(2);
        // depth 2 even though three gates are on the path-like chain.
        let xy = c.and(x, y);
        let nz = c.not(z);
        let f = c.or(xy, nz);
        assert_eq!(c.node_depth(f), 2);

        // A serial XOR chain grows with each gate.
        let mut d = Circuit::new();
        let a = d.input(0);
        let b = d.input(1);
        let ab = d.xor(a, b);
        let cin = d.input(2);
        let s = d.xor(ab, cin);
        assert_eq!(d.node_depth(s), 2);
    }
}
