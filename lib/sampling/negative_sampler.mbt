///|
/// Samples `num_samples` negative edges `(u, v)` where no edge exists between `u` and `v`
/// (`u != v` and `!graph.has_edge(u, v)`).
pub fn sample_negative_edges(
  graph : @graph.Graph,
  num_samples : Int,
  seed? : Int = 42,
) -> Array[(Int, Int)] {
  let nodes = graph.nodes()
  let n = nodes.length()
  if n < 2 || num_samples <= 0 {
    return []
  }
  let res = []
  let seen : Map[String, Bool] = {}
  let mut current_seed = seed
  let mut attempts = 0
  let max_attempts = num_samples * 20
  while res.length() < num_samples && attempts < max_attempts {
    attempts += 1
    current_seed = next_rand(current_seed)
    let idx_u = current_seed % n
    current_seed = next_rand(current_seed)
    let idx_v = current_seed % n
    let u = nodes[idx_u]
    let v = nodes[idx_v]
    if u != v && !graph.has_edge(u, v) && !graph.has_edge(v, u) {
      let key = if u <= v { "\{u}-\{v}" } else { "\{v}-\{u}" }
      if !seen.contains(key) {
        seen[key] = true
        res.push((u, v))
      }
    }
  }
  res
}
