///|
/// Represents a GraphSAGE convolutional layer (Hamilton et al., 2017).
/// $h_v^{(l+1)} = W_{self} h_v^{(l)} + W_{neigh} \cdot \text{AGG}(\{ h_u^{(l)}, \forall u \in N(v) \}) + b$
pub(all) struct GraphSAGEConv {
  in_dim : Int
  out_dim : Int
  aggregator : Aggregator
  weight_self : Array[Array[Double]]
  weight_neigh : Array[Array[Double]]
  bias : Array[Double]
} derive(Eq, Debug, ToJson)

///|
/// Initializes a new `GraphSAGEConv` layer.
pub fn GraphSAGEConv::init(
  in_dim : Int,
  out_dim : Int,
  aggregator? : Aggregator = Mean,
  seed? : Int = 42,
) -> GraphSAGEConv {
  let scale = Double::sqrt(6.0 / (in_dim + out_dim).to_double())
  let weight_self = []
  let mut current_seed = seed
  for _ in 0..<in_dim {
    let row = []
    for _ in 0..<out_dim {
      current_seed = next_rand(current_seed)
      let rand_val = (current_seed % 1000000).to_double() / 1000000.0
      let w = (rand_val * 2.0 - 1.0) * scale
      row.push(w)
    }
    weight_self.push(row)
  }
  let weight_neigh = []
  for _ in 0..<in_dim {
    let row = []
    for _ in 0..<out_dim {
      current_seed = next_rand(current_seed)
      let rand_val = (current_seed % 1000000).to_double() / 1000000.0
      let w = (rand_val * 2.0 - 1.0) * scale
      row.push(w)
    }
    weight_neigh.push(row)
  }
  let bias = []
  for _ in 0..<out_dim {
    bias.push(0.0)
  }
  { in_dim, out_dim, aggregator, weight_self, weight_neigh, bias }
}

///|
/// Performs forward pass of `GraphSAGEConv`.
/// Raises `GraphError::FeatureDimensionMismatch` if input dimensions mismatch.
pub fn GraphSAGEConv::forward(
  self : GraphSAGEConv,
  graph : @graph.Graph,
  features : @graph.NodeFeatures,
) -> @graph.NodeFeatures raise @graph.GraphError {
  if features.feature_dim != self.in_dim {
    raise @graph.GraphError::FeatureDimensionMismatch(
      expected=self.in_dim,
      actual=features.feature_dim,
    )
  }
  let self_trans = linear_transform(features, self.weight_self, self.bias)
  let neigh_agg = propagate(
    graph,
    features,
    self.aggregator,
    edge_weights=false,
  )
  let zero_bias = []
  for _ in 0..<self.out_dim {
    zero_bias.push(0.0)
  }
  let neigh_trans = linear_transform(neigh_agg, self.weight_neigh, zero_bias)
  let n = features.num_nodes
  let data = []
  for i in 0..<n {
    let row = []
    let s_row = self_trans.get(i)
    let n_row = neigh_trans.get(i)
    for j in 0..<self.out_dim {
      row.push(s_row[j] + n_row[j])
    }
    data.push(row)
  }
  { data, num_nodes: n, feature_dim: self.out_dim }
}
