///|
/// Helper linear congruential generator (LCG) for sampling.
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
/// Uniformly samples `num_samples` neighbors of node `u`.
/// If `replacement` is true, sampling is done with replacement.
/// If `replacement` is false and `num_samples >= deg(u)`, all neighbors are returned.
pub fn uniform_sample_neighbors(
  graph : @graph.Graph,
  u : Int,
  num_samples : Int,
  replacement? : Bool = true,
  seed? : Int = 42,
) -> Array[Int] {
  let nbrs = graph.neighbors(u)
  let k = nbrs.length()
  if k == 0 || num_samples <= 0 {
    return []
  }
  let mut current_seed = seed
  if replacement {
    let res = []
    for _ in 0..<num_samples {
      current_seed = next_rand(current_seed)
      let idx = current_seed % k
      res.push(nbrs[idx])
    }
    res
  } else {
    if num_samples >= k {
      return nbrs
    }
    let copy = []
    for v in nbrs {
      copy.push(v)
    }
    for i in 0..<num_samples {
      current_seed = next_rand(current_seed)
      let j = i + current_seed % (k - i)
      let tmp = copy[i]
      copy[i] = copy[j]
      copy[j] = tmp
    }
    let res = []
    for i in 0..<num_samples {
      res.push(copy[i])
    }
    res
  }
}

///|
/// Samples `num_samples` neighbors for a batch of `nodes`.
/// Returns a map from node ID to its sampled neighbors array.
pub fn sample_neighborhood_batch(
  graph : @graph.Graph,
  nodes : Array[Int],
  num_samples : Int,
  replacement? : Bool = true,
  seed? : Int = 42,
) -> Map[Int, Array[Int]] {
  let res : Map[Int, Array[Int]] = {}
  let mut current_seed = seed
  for i, u in nodes {
    current_seed = next_rand(current_seed + i)
    res[u] = uniform_sample_neighbors(
      graph,
      u,
      num_samples,
      replacement~,
      seed=current_seed,
    )
  }
  res
}
