///|
/// Represents continuous node features matrix (`num_nodes x feature_dim`).
pub(all) struct NodeFeatures {
  data : Array[Array[Double]]
  num_nodes : Int
  feature_dim : Int
} derive(Debug)

///|
/// Creates `NodeFeatures` from a 2D array (`Array[Array[Double]]`).
/// Assumes all rows have the exact same feature dimension.
pub fn NodeFeatures::from_arrays(data : Array[Array[Double]]) -> NodeFeatures {
  let num_nodes = data.length()
  let feature_dim = if num_nodes > 0 { data[0].length() } else { 0 }
  { data, num_nodes, feature_dim }
}

///|
/// Creates a zero-initialized node feature matrix of shape `(num_nodes, feature_dim)`.
pub fn NodeFeatures::zeros(num_nodes : Int, feature_dim : Int) -> NodeFeatures {
  let data = []
  for _ in 0..<num_nodes {
    let row = []
    for _ in 0..<feature_dim {
      row.push(0.0)
    }
    data.push(row)
  }
  { data, num_nodes, feature_dim }
}

///|
/// Returns feature vector for `node`. Panics if `node` is out of bounds.
pub fn NodeFeatures::get(self : NodeFeatures, node : Int) -> Array[Double] {
  self.data[node]
}

///|
/// Sets feature vector for `node`. Raises `GraphError` if dimension mismatches.
pub fn NodeFeatures::set(
  self : NodeFeatures,
  node : Int,
  features : Array[Double],
) -> Unit raise GraphError {
  if features.length() != self.feature_dim {
    raise GraphError::FeatureDimensionMismatch(
      expected=self.feature_dim,
      actual=features.length(),
    )
  }
  self.data[node] = features
}

///|
/// Performs Min-Max normalization column-wise to scale each feature to [0.0, 1.0].
pub fn NodeFeatures::min_max_normalize(self : NodeFeatures) -> NodeFeatures {
  if self.num_nodes == 0 || self.feature_dim == 0 {
    return self.clone()
  }
  let mins = []
  let maxs = []
  for j in 0..<self.feature_dim {
    let mut min_v = self.data[0][j]
    let mut max_v = self.data[0][j]
    for i in 1..<self.num_nodes {
      let v = self.data[i][j]
      if v < min_v {
        min_v = v
      }
      if v > max_v {
        max_v = v
      }
    }
    mins.push(min_v)
    maxs.push(max_v)
  }
  let res = NodeFeatures::zeros(self.num_nodes, self.feature_dim)
  for i in 0..<self.num_nodes {
    for j in 0..<self.feature_dim {
      let diff = maxs[j] - mins[j]
      if diff > 1.0e-12 {
        res.data[i][j] = (self.data[i][j] - mins[j]) / diff
      } else {
        res.data[i][j] = 0.0
      }
    }
  }
  res
}

///|
/// Performs Z-score standardization column-wise (mean=0, std=1).
pub fn NodeFeatures::zscore_normalize(self : NodeFeatures) -> NodeFeatures {
  if self.num_nodes == 0 || self.feature_dim == 0 {
    return self.clone()
  }
  let means = []
  let stds = []
  let n = self.num_nodes.to_double()
  for j in 0..<self.feature_dim {
    let mut sum = 0.0
    for i in 0..<self.num_nodes {
      sum += self.data[i][j]
    }
    let mean = sum / n
    means.push(mean)
    let mut var_sum = 0.0
    for i in 0..<self.num_nodes {
      let d = self.data[i][j] - mean
      var_sum += d * d
    }
    let std_dev = Double::sqrt(var_sum / n)
    stds.push(std_dev)
  }
  let res = NodeFeatures::zeros(self.num_nodes, self.feature_dim)
  for i in 0..<self.num_nodes {
    for j in 0..<self.feature_dim {
      if stds[j] > 1.0e-12 {
        res.data[i][j] = (self.data[i][j] - means[j]) / stds[j]
      } else {
        res.data[i][j] = 0.0
      }
    }
  }
  res
}

///|
/// Performs L2 normalization row-wise (each node feature vector has L2 norm = 1.0).
pub fn NodeFeatures::l2_normalize(self : NodeFeatures) -> NodeFeatures {
  let res = NodeFeatures::zeros(self.num_nodes, self.feature_dim)
  for i in 0..<self.num_nodes {
    let mut norm_sq = 0.0
    for j in 0..<self.feature_dim {
      let v = self.data[i][j]
      norm_sq += v * v
    }
    let norm = Double::sqrt(norm_sq)
    for j in 0..<self.feature_dim {
      if norm > 1.0e-12 {
        res.data[i][j] = self.data[i][j] / norm
      } else {
        res.data[i][j] = 0.0
      }
    }
  }
  res
}

///|
/// Clones the feature matrix.
pub fn NodeFeatures::clone(self : NodeFeatures) -> NodeFeatures {
  let data = []
  for i in 0..<self.num_nodes {
    let row = []
    for j in 0..<self.feature_dim {
      row.push(self.data[i][j])
    }
    data.push(row)
  }
  { data, num_nodes: self.num_nodes, feature_dim: self.feature_dim }
}
