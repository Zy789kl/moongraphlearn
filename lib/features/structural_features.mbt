///|
/// Computes local clustering coefficient of node `u`.
fn local_clustering_coeff(graph : @graph.Graph, u : Int) -> Double {
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
/// Extracts a 4-dimensional structural identity feature vector for every node:
/// `[Normalized Out-Degree, Normalized In-Degree, PageRank Score, Local Clustering Coefficient]`.
pub fn extract_structural_features(graph : @graph.Graph) -> @graph.NodeFeatures {
  let n = graph.node_count()
  if n == 0 {
    return @graph.NodeFeatures::zeros(0, 4)
  }
  let pr = pagerank(graph, damping=0.85, max_iter=50)
  let mut max_out = 1.0
  let mut max_in = 1.0
  for u in 0..<n {
    let dout = graph.degree(u).to_double()
    let din = graph.in_degree(u).to_double()
    if dout > max_out {
      max_out = dout
    }
    if din > max_in {
      max_in = din
    }
  }
  let data = []
  for u in 0..<n {
    let dout_norm = graph.degree(u).to_double() / max_out
    let din_norm = graph.in_degree(u).to_double() / max_in
    let pr_val = match pr.get(u) {
      Some(v) => v
      None => 0.0
    }
    let cc_val = local_clustering_coeff(graph, u)
    data.push([dout_norm, din_norm, pr_val, cc_val])
  }
  @graph.NodeFeatures::from_arrays(data)
}

///|
/// Concatenates two node feature matrices horizontally (`raw_features` and `structural_features`).
/// Raises `GraphError::FeatureDimensionMismatch` if node counts do not match.
pub fn augment_node_features(
  raw_features : @graph.NodeFeatures,
  structural_features : @graph.NodeFeatures,
) -> @graph.NodeFeatures raise @graph.GraphError {
  if raw_features.num_nodes != structural_features.num_nodes {
    raise @graph.GraphError::FeatureDimensionMismatch(
      expected=raw_features.num_nodes,
      actual=structural_features.num_nodes,
    )
  }
  let n = raw_features.num_nodes
  let new_dim = raw_features.feature_dim + structural_features.feature_dim
  let data = []
  for i in 0..<n {
    let row = []
    for val in raw_features.get(i) {
      row.push(val)
    }
    for val in structural_features.get(i) {
      row.push(val)
    }
    data.push(row)
  }
  { data, num_nodes: n, feature_dim: new_dim }
}
