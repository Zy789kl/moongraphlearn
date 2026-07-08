///|
/// Helper linear congruential generator for weight initialization.
fn next_rand(seed : Int) -> Int {
  let a = 1103515245
  let c = 12345
  let m = 2147483647
  let n = a * seed + c
  if n < 0 {
    -n % m
  } else {
    n % m
  }
}

///|
/// Represents a Graph Convolutional Network (GCNConv) layer.
/// $H^{(l+1)} = \hat{D}^{-1/2} \hat{A} \hat{D}^{-1/2} H^{(l)} W + b$
pub(all) struct GCNConv {
  in_dim : Int
  out_dim : Int
  weight : Array[Array[Double]]
  bias : Array[Double]
} derive(Eq, Debug, ToJson)

///|
/// Initializes a new `GCNConv` layer with pseudo-random weights (Xavier-like scaling) and zero bias.
pub fn GCNConv::init(in_dim : Int, out_dim : Int, seed? : Int = 42) -> GCNConv {
  let scale = Double::sqrt(6.0 / (in_dim + out_dim).to_double())
  let weight = []
  let mut current_seed = seed
  for _ in 0..<in_dim {
    let row = []
    for _ in 0..<out_dim {
      current_seed = next_rand(current_seed)
      let rand_val = (current_seed % 1000000).to_double() / 1000000.0
      let w = (rand_val * 2.0 - 1.0) * scale
      row.push(w)
    }
    weight.push(row)
  }
  let bias = []
  for _ in 0..<out_dim {
    bias.push(0.0)
  }
  { in_dim, out_dim, weight, bias }
}

///|
/// Performs linear transformation `X * W + b` on node features.
pub fn linear_transform(
  features : @graph.NodeFeatures,
  weight : Array[Array[Double]],
  bias : Array[Double],
) -> @graph.NodeFeatures {
  let n = features.num_nodes
  let in_dim = features.feature_dim
  let out_dim = bias.length()
  let data = []
  for i in 0..<n {
    let row = []
    let old_row = features.get(i)
    for j in 0..<out_dim {
      let mut val = bias[j]
      for k in 0..<in_dim {
        val += old_row[k] * weight[k][j]
      }
      row.push(val)
    }
    data.push(row)
  }
  { data, num_nodes: n, feature_dim: out_dim }
}

///|
/// Performs forward pass of the `GCNConv` layer.
/// Raises `GraphError::FeatureDimensionMismatch` if input feature dimensions do not match `self.in_dim`.
pub fn GCNConv::forward(
  self : GCNConv,
  graph : @graph.Graph,
  features : @graph.NodeFeatures,
  add_self_loops? : Bool = true,
) -> @graph.NodeFeatures raise @graph.GraphError {
  if features.feature_dim != self.in_dim {
    raise @graph.GraphError::FeatureDimensionMismatch(
      expected=self.in_dim,
      actual=features.feature_dim,
    )
  }
  let norm_graph = @preprocess.symmetric_normalized_graph(
    graph,
    with_self_loops=add_self_loops,
  )
  let agg_feats = propagate(norm_graph, features, Sum, edge_weights=true)
  linear_transform(agg_feats, self.weight, self.bias)
}
