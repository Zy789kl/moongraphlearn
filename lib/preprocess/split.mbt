///|
/// Represents boolean masks (`Array[Bool]`) for Train, Validation, and Test node splits.
pub(all) struct NodeSplit {
  train_mask : Array[Bool]
  val_mask : Array[Bool]
  test_mask : Array[Bool]
} derive(Eq, Debug, ToJson)

///|
/// Represents split edges (`Array[Edge]`) for link prediction evaluation.
pub(all) struct EdgeSplit {
  train_edges : Array[@graph.Edge]
  val_edges : Array[@graph.Edge]
  test_edges : Array[@graph.Edge]
} derive(Eq, Debug, ToJson)

///|
/// Helper linear congruential generator (LCG) for deterministic shuffling.
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
/// Splits `num_nodes` into Train, Validation, and Test subsets deterministically using `seed`.
pub fn train_val_test_split_nodes(
  num_nodes : Int,
  train_ratio? : Double = 0.6,
  val_ratio? : Double = 0.2,
  seed? : Int = 42,
) -> NodeSplit {
  let indices = []
  for i in 0..<num_nodes {
    indices.push(i)
  }
  let mut current_seed = seed
  for i in 0..<num_nodes {
    current_seed = next_rand(current_seed)
    let j = current_seed % (i + 1)
    let tmp = indices[i]
    indices[i] = indices[j]
    indices[j] = tmp
  }
  let train_mask = []
  let val_mask = []
  let test_mask = []
  for _ in 0..<num_nodes {
    train_mask.push(false)
    val_mask.push(false)
    test_mask.push(false)
  }
  let n_double = num_nodes.to_double()
  let num_train = (n_double * train_ratio).to_int()
  let num_val = (n_double * val_ratio).to_int()
  for idx in 0..<num_nodes {
    let node_id = indices[idx]
    if idx < num_train {
      train_mask[node_id] = true
    } else if idx < num_train + num_val {
      val_mask[node_id] = true
    } else {
      test_mask[node_id] = true
    }
  }
  { train_mask, val_mask, test_mask }
}

///|
/// Splits edges of a `graph` into Train, Validation, and Test sets for link prediction.
pub fn train_val_test_split_edges(
  graph : @graph.Graph,
  train_ratio? : Double = 0.8,
  val_ratio? : Double = 0.1,
  seed? : Int = 42,
) -> EdgeSplit {
  let all_edges = graph.edges()
  let m = all_edges.length()
  let mut current_seed = seed
  for i in 0..<m {
    current_seed = next_rand(current_seed)
    let j = current_seed % (i + 1)
    let tmp = all_edges[i]
    all_edges[i] = all_edges[j]
    all_edges[j] = tmp
  }
  let train_edges = []
  let val_edges = []
  let test_edges = []
  let m_double = m.to_double()
  let num_train = (m_double * train_ratio).to_int()
  let num_val = (m_double * val_ratio).to_int()
  for idx in 0..<m {
    let e = all_edges[idx]
    if idx < num_train {
      train_edges.push(e)
    } else if idx < num_train + num_val {
      val_edges.push(e)
    } else {
      test_edges.push(e)
    }
  }
  { train_edges, val_edges, test_edges }
}
