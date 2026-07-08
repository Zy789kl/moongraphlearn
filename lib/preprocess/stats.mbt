///|
/// Computes graph density (`E / (V * (V - 1))` or `2E / (V * (V - 1))`).
pub fn density(graph : @graph.Graph) -> Double {
  let n = graph.node_count().to_double()
  if n <= 1.0 {
    return 0.0
  }
  let m = graph.edge_count().to_double()
  let max_edges = n * (n - 1.0)
  if graph.directed {
    m / max_edges
  } else {
    2.0 * m / max_edges
  }
}

///|
/// Computes average node degree.
pub fn average_degree(graph : @graph.Graph) -> Double {
  let n = graph.node_count()
  if n == 0 {
    return 0.0
  }
  let mut total_deg = 0
  for u in 0..<n {
    total_deg += graph.degree(u)
  }
  total_deg.to_double() / n.to_double()
}

///|
/// Computes the local clustering coefficient of node `u`.
pub fn clustering_coefficient(graph : @graph.Graph, u : Int) -> Double {
  let nbrs = graph.neighbors(u)
  let k = nbrs.length()
  if k < 2 {
    return 0.0
  }
  let mut connected_pairs = 0
  for i in 0..<k {
    for j in (i + 1)..<k {
      if graph.has_edge(nbrs[i], nbrs[j]) || graph.has_edge(nbrs[j], nbrs[i]) {
        connected_pairs += 1
      }
    }
  }
  let max_pairs = k * (k - 1) / 2
  connected_pairs.to_double() / max_pairs.to_double()
}

///|
/// Finds all connected components in an undirected graph using BFS.
pub fn connected_components(graph : @graph.Graph) -> Array[Array[Int]] {
  let n = graph.node_count()
  let visited : Map[Int, Bool] = {}
  let components = []
  for u in 0..<n {
    if !visited.contains(u) {
      let comp = []
      let queue = [u]
      visited[u] = true
      let mut head = 0
      while head < queue.length() {
        let curr = queue[head]
        head += 1
        comp.push(curr)
        for nxt in graph.neighbors(curr) {
          if !visited.contains(nxt) {
            visited[nxt] = true
            queue.push(nxt)
          }
        }
        if graph.directed {
          for nxt in graph.in_neighbors(curr) {
            if !visited.contains(nxt) {
              visited[nxt] = true
              queue.push(nxt)
            }
          }
        }
      }
      comp.sort()
      components.push(comp)
    }
  }
  components
}
