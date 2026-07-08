///|
/// Creates a Graph from a list of `(u, v)` edge pairs with default weight 1.0.
pub fn Graph::from_edge_list(
  edges : Array[(Int, Int)],
  directed? : Bool = false,
) -> Graph {
  let g = Graph::new(directed~)
  for pair in edges {
    let (u, v) = pair
    g.add_edge(u, v, weight=1.0)
  }
  g
}

///|
/// Creates a Graph from a list of weighted edge tuples `(u, v, weight)`.
pub fn Graph::from_weighted_edge_list(
  edges : Array[(Int, Int, Double)],
  directed? : Bool = false,
) -> Graph {
  let g = Graph::new(directed~)
  for item in edges {
    let (u, v, w) = item
    g.add_edge(u, v, weight=w)
  }
  g
}

///|
/// Converts the graph into a dense adjacency matrix `(num_nodes x num_nodes)`.
/// Missing edges have weight 0.0.
pub fn Graph::to_adjacency_matrix(self : Graph) -> Array[Array[Double]] {
  let n = self.num_nodes
  let mat = []
  for _ in 0..<n {
    let row = []
    for _ in 0..<n {
      row.push(0.0)
    }
    mat.push(row)
  }
  for u in 0..<n {
    match self.adj.get(u) {
      Some(edges) =>
        for e in edges {
          mat[u][e.v] = e.weight
        }
      None => ()
    }
  }
  mat
}

///|
/// Creates a Graph from a dense adjacency matrix (`Array[Array[Double]]`).
/// Edges with absolute weight `> 1.0e-12` are added to the graph.
pub fn Graph::from_adjacency_matrix(
  matrix : Array[Array[Double]],
  directed? : Bool = false,
) -> Graph {
  let g = Graph::new(directed~)
  let n = matrix.length()
  for i in 0..<n {
    g.add_node(i)
    for j in 0..<n {
      let w = matrix[i][j]
      if w.abs() > 1.0e-12 {
        if directed || i <= j {
          g.add_edge(i, j, weight=w)
        }
      }
    }
  }
  g
}
