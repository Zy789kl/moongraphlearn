///|
/// Performs Label Propagation (or Simplified Graph Convolution / SGC feature diffusion).
/// `initial_labels` (`NodeFeatures`) is the `N x C` initial label distribution or feature matrix.
/// `train_mask` specifies which nodes have fixed ground-truth labels that are reset at each iteration.
/// `alpha` is the diffusion factor (`0 < alpha <= 1`).
pub fn label_propagation(
  graph : @graph.Graph,
  initial_labels : @graph.NodeFeatures,
  train_mask : Array[Bool],
  alpha? : Double = 0.5,
  max_iter? : Int = 50,
  tol? : Double = 1.0e-5,
) -> @graph.NodeFeatures {
  let n = initial_labels.num_nodes
  let dim = initial_labels.feature_dim
  if n == 0 {
    return initial_labels
  }
  let norm_g = @preprocess.symmetric_normalized_graph(
    graph,
    with_self_loops=true,
  )
  let mut curr = initial_labels
  let mut iter = 0
  while iter < max_iter {
    iter += 1
    let prop = propagate(norm_g, curr, Sum, edge_weights=true)
    let next_data = []
    let mut max_diff = 0.0
    for i in 0..<n {
      let row = []
      let p_row = prop.get(i)
      let init_row = initial_labels.get(i)
      let c_row = curr.get(i)
      if train_mask[i] {
        for j in 0..<dim {
          let val = init_row[j]
          let diff = (val - c_row[j]).abs()
          if diff > max_diff {
            max_diff = diff
          }
          row.push(val)
        }
      } else {
        for j in 0..<dim {
          let val = alpha * p_row[j] + (1.0 - alpha) * init_row[j]
          let diff = (val - c_row[j]).abs()
          if diff > max_diff {
            max_diff = diff
          }
          row.push(val)
        }
      }
      next_data.push(row)
    }
    curr = { data: next_data, num_nodes: n, feature_dim: dim }
    if max_diff < tol {
      break
    }
  }
  curr
}
