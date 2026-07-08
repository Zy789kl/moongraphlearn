///|
/// Supported neighborhood message aggregation types.
pub(all) enum Aggregator {
  Sum
  Mean
  Max
} derive(Eq, Debug, ToJson)

///|
/// ReLU activation function (`max(0.0, x)`).
pub fn relu(x : Double) -> Double {
  if x > 0.0 {
    x
  } else {
    0.0
  }
}

///|
/// Sigmoid activation function (`1 / (1 + exp(-x))`).
pub fn sigmoid(x : Double) -> Double {
  1.0 / (1.0 + @math.exp(-x))
}

///|
/// Applies a point-wise activation function to each element of `NodeFeatures`.
pub fn apply_activation(
  features : @graph.NodeFeatures,
  act : (Double) -> Double,
) -> @graph.NodeFeatures {
  let n = features.num_nodes
  let dim = features.feature_dim
  let data = []
  for i in 0..<n {
    let row = []
    let old_row = features.get(i)
    for j in 0..<dim {
      row.push(act(old_row[j]))
    }
    data.push(row)
  }
  { data, num_nodes: n, feature_dim: dim }
}

///|
/// Aggregates neighbor feature messages for all nodes according to `agg`.
/// If `edge_weights` is true, each neighbor message is scaled by `edge_weight(u, v)`.
pub fn aggregate_neighbors(
  graph : @graph.Graph,
  features : @graph.NodeFeatures,
  agg : Aggregator,
  edge_weights? : Bool = true,
) -> @graph.NodeFeatures {
  let n = features.num_nodes
  let dim = features.feature_dim
  let data = []
  for u in 0..<n {
    let row = []
    for _ in 0..<dim {
      row.push(0.0)
    }
    let edges = graph.neighbor_edges(u)
    let k = edges.length()
    if k > 0 {
      match agg {
        Sum =>
          for e in edges {
            let v = e.v
            let w = if edge_weights { e.weight } else { 1.0 }
            if v < n {
              let v_feat = features.get(v)
              for j in 0..<dim {
                row[j] = row[j] + v_feat[j] * w
              }
            }
          }
        Mean => {
          let mut total_w = 0.0
          for e in edges {
            let v = e.v
            let w = if edge_weights { e.weight } else { 1.0 }
            total_w += w
            if v < n {
              let v_feat = features.get(v)
              for j in 0..<dim {
                row[j] = row[j] + v_feat[j] * w
              }
            }
          }
          if total_w > 1.0e-12 {
            for j in 0..<dim {
              row[j] = row[j] / total_w
            }
          }
        }
        Max => {
          for j in 0..<dim {
            row[j] = -1.0e30
          }
          let mut found_any = false
          for e in edges {
            let v = e.v
            let w = if edge_weights { e.weight } else { 1.0 }
            if v < n {
              found_any = true
              let v_feat = features.get(v)
              for j in 0..<dim {
                let val = v_feat[j] * w
                if val > row[j] {
                  row[j] = val
                }
              }
            }
          }
          if !found_any {
            for j in 0..<dim {
              row[j] = 0.0
            }
          }
        }
      }
    }
    data.push(row)
  }
  { data, num_nodes: n, feature_dim: dim }
}

///|
/// Generic message propagation operator across the graph structure.
pub fn propagate(
  graph : @graph.Graph,
  features : @graph.NodeFeatures,
  agg : Aggregator,
  edge_weights? : Bool = true,
) -> @graph.NodeFeatures {
  aggregate_neighbors(graph, features, agg, edge_weights~)
}
