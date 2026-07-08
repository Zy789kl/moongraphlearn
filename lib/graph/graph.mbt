///|
/// Error types for graph manipulation and feature checks
pub(all) suberror GraphError {
  InvalidNodeId(Int)
  InvalidEdge(Int, Int)
  FeatureDimensionMismatch(expected~ : Int, actual~ : Int)
} derive(Eq, Debug, ToJson)

///|
/// Represents a directed or undirected edge with weight
pub(all) struct Edge {
  u : Int
  v : Int
  mut weight : Double
} derive(Eq, Debug, ToJson)

///|
/// Graph data structure supporting both directed and undirected graphs
/// using adjacency lists with edge weights.
pub(all) struct Graph {
  directed : Bool
  mut num_nodes : Int
  adj : Map[Int, Array[Edge]]
  in_adj : Map[Int, Array[Edge]]
} derive(Debug)

///|
/// Creates a new Graph instance.
pub fn Graph::new(directed? : Bool = false) -> Graph {
  { directed, num_nodes: 0, adj: {}, in_adj: {} }
}

///|
/// Adds a node with ID `id` into the graph if it does not exist yet.
pub fn Graph::add_node(self : Graph, id : Int) -> Unit {
  if !self.adj.contains(id) {
    self.adj[id] = []
    self.in_adj[id] = []
    if id >= self.num_nodes {
      self.num_nodes = id + 1
    }
  }
}

///|
/// Adds a weighted edge between `u` and `v`.
pub fn Graph::add_edge(
  self : Graph,
  u : Int,
  v : Int,
  weight? : Double = 1.0,
) -> Unit {
  self.add_node(u)
  self.add_node(v)
  let e = { u, v, weight }
  let edges_u = self.adj[u]
  edges_u.push(e)
  let in_edges_v = self.in_adj[v]
  in_edges_v.push(e)
  if !self.directed && u != v {
    let rev_e = { u: v, v: u, weight }
    let edges_v = self.adj[v]
    edges_v.push(rev_e)
    let in_edges_u = self.in_adj[u]
    in_edges_u.push(rev_e)
  }
}

///|
/// Checks if an edge exists from `u` to `v`.
pub fn Graph::has_edge(self : Graph, u : Int, v : Int) -> Bool {
  match self.adj.get(u) {
    Some(edges) => {
      for e in edges {
        if e.v == v {
          return true
        }
      }
      false
    }
    None => false
  }
}

///|
/// Returns the weight of edge `(u, v)` if present.
pub fn Graph::edge_weight(self : Graph, u : Int, v : Int) -> Double? {
  match self.adj.get(u) {
    Some(edges) => {
      for e in edges {
        if e.v == v {
          return Some(e.weight)
        }
      }
      None
    }
    None => None
  }
}

///|
/// Returns the out-neighbors of node `u`.
pub fn Graph::neighbors(self : Graph, u : Int) -> Array[Int] {
  match self.adj.get(u) {
    Some(edges) => edges.map(fn(e) { e.v })
    None => []
  }
}

///|
/// Returns all outgoing edges from node `u`.
pub fn Graph::neighbor_edges(self : Graph, u : Int) -> Array[Edge] {
  match self.adj.get(u) {
    Some(edges) => edges
    None => []
  }
}

///|
/// Returns the in-neighbors of node `u`.
pub fn Graph::in_neighbors(self : Graph, u : Int) -> Array[Int] {
  match self.in_adj.get(u) {
    Some(edges) => edges.map(fn(e) { e.u })
    None => []
  }
}

///|
/// Returns all incoming edges to node `u`.
pub fn Graph::in_neighbor_edges(self : Graph, u : Int) -> Array[Edge] {
  match self.in_adj.get(u) {
    Some(edges) => edges
    None => []
  }
}

///|
/// Returns the out-degree of node `u`.
pub fn Graph::degree(self : Graph, u : Int) -> Int {
  match self.adj.get(u) {
    Some(edges) => edges.length()
    None => 0
  }
}

///|
/// Returns the in-degree of node `u`.
pub fn Graph::in_degree(self : Graph, u : Int) -> Int {
  match self.in_adj.get(u) {
    Some(edges) => edges.length()
    None => 0
  }
}

///|
/// Returns the maximum node ID plus one, or number of distinct nodes.
pub fn Graph::node_count(self : Graph) -> Int {
  self.adj.length()
}

///|
/// Returns the total number of unique edge objects stored.
/// For undirected graphs without self-loops, `edge_count()` equals twice the number of undirected edge pairs.
pub fn Graph::edge_count(self : Graph) -> Int {
  let mut count = 0
  for _, edges in self.adj {
    count += edges.length()
  }
  if self.directed {
    count
  } else {
    count / 2
  }
}

///|
/// Returns all node IDs in ascending order.
pub fn Graph::nodes(self : Graph) -> Array[Int] {
  let res = []
  for k, _ in self.adj {
    res.push(k)
  }
  res.sort()
  res
}

///|
/// Returns a list of all edges in the graph.
pub fn Graph::edges(self : Graph) -> Array[Edge] {
  let res = []
  let seen : Map[String, Bool] = {}
  for u, edges in self.adj {
    for e in edges {
      if self.directed {
        res.push(e)
      } else {
        let min_id = if u <= e.v { u } else { e.v }
        let max_id = if u <= e.v { e.v } else { u }
        let key = "\{min_id}-\{max_id}"
        if !seen.contains(key) {
          seen[key] = true
          res.push({ u: min_id, v: max_id, weight: e.weight })
        }
      }
    }
  }
  res
}

///|
/// Clones the graph.
pub fn Graph::clone(self : Graph) -> Graph {
  let g = Graph::new(directed=self.directed)
  g.num_nodes = self.num_nodes
  for u, _ in self.adj {
    g.add_node(u)
  }
  for u, edges in self.adj {
    let copy = []
    for e in edges {
      copy.push({ u: e.u, v: e.v, weight: e.weight })
    }
    g.adj[u] = copy
  }
  for u, edges in self.in_adj {
    let copy = []
    for e in edges {
      copy.push({ u: e.u, v: e.v, weight: e.weight })
    }
    g.in_adj[u] = copy
  }
  g
}
