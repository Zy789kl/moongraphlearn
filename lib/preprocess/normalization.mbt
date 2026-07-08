///|
/// Adds self-loops `(u, u)` with specified `weight` to all nodes in the graph.
/// If a self-loop already exists, its weight is incremented by `weight`.
pub fn add_self_loops(
  graph : @graph.Graph,
  weight? : Double = 1.0,
) -> @graph.Graph {
  let g = graph.clone()
  let n = g.node_count()
  for u in 0..<n {
    match g.edge_weight(u, u) {
      Some(_) => {
        let edges = g.neighbor_edges(u)
        let mut found = false
        for e in edges {
          if e.v == u {
            e.weight += weight
            found = true
          }
        }
        if !found {
          g.add_edge(u, u, weight~)
        }
      }
      None => g.add_edge(u, u, weight~)
    }
  }
  g
}

///|
/// Computes the degree vector `D` as an array of floating point weights (`Array[Double]`).
/// For weighted graphs, node degree is the sum of outgoing edge weights.
pub fn degree_vector(graph : @graph.Graph) -> Array[Double] {
  let n = graph.node_count()
  let degs = []
  for u in 0..<n {
    let mut d = 0.0
    for e in graph.neighbor_edges(u) {
      d += e.weight
    }
    degs.push(d)
  }
  degs
}

///|
/// Computes symmetric normalized adjacency matrix weights:
/// `W_{uv} = A_{uv} / sqrt(D_u * D_v)`
/// Returns a Map of adjacency lists with normalized edge weights.
pub fn symmetric_normalized_weights(
  graph : @graph.Graph,
  with_self_loops? : Bool = true,
) -> Map[Int, Array[@graph.Edge]] {
  let g = if with_self_loops {
    add_self_loops(graph, weight=1.0)
  } else {
    graph.clone()
  }
  let degs = degree_vector(g)
  let n = g.node_count()
  let norm_map : Map[Int, Array[@graph.Edge]] = {}
  for u in 0..<n {
    let u_edges = []
    let du = degs[u]
    if du > 1.0e-12 {
      for e in g.neighbor_edges(u) {
        let dv = degs[e.v]
        if dv > 1.0e-12 {
          let denom = Double::sqrt(du * dv)
          let norm_w = e.weight / denom
          u_edges.push(@graph.Edge::{ u: e.u, v: e.v, weight: norm_w })
        } else {
          u_edges.push(@graph.Edge::{ u: e.u, v: e.v, weight: 0.0 })
        }
      }
    }
    norm_map[u] = u_edges
  }
  norm_map
}

///|
/// Returns a new `Graph` whose edge weights are symmetrically normalized (`D^{-1/2} A D^{-1/2}`).
pub fn symmetric_normalized_graph(
  graph : @graph.Graph,
  with_self_loops? : Bool = true,
) -> @graph.Graph {
  let norm_map = symmetric_normalized_weights(graph, with_self_loops~)
  let res = @graph.Graph::new(directed=graph.directed)
  let n = graph.node_count()
  for u in 0..<n {
    res.add_node(u)
  }
  for _, edges in norm_map {
    for e in edges {
      if res.directed || e.u <= e.v {
        res.add_edge(e.u, e.v, weight=e.weight)
      }
    }
  }
  res
}
