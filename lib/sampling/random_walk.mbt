///|
/// Generates a simple uniform random walk of `walk_length` steps starting from `start_node`.
/// The returned array contains `walk_length` node IDs (`[start_node, v_1, ..., v_{L-1}]`).
pub fn random_walk(
  graph : @graph.Graph,
  start_node : Int,
  walk_length : Int,
  seed? : Int = 42,
) -> Array[Int] {
  if walk_length <= 0 {
    return []
  }
  let walk = [start_node]
  let mut curr = start_node
  let mut current_seed = seed
  for _ in 1..<walk_length {
    let nbrs = graph.neighbors(curr)
    let k = nbrs.length()
    if k == 0 {
      break
    }
    current_seed = next_rand(current_seed)
    let idx = current_seed % k
    curr = nbrs[idx]
    walk.push(curr)
  }
  walk
}

///|
/// Generates a biased random walk (`Node2Vec`) of `walk_length` steps starting from `start_node`.
/// Parameter `p` controls return parameter (likelihood of immediately revisiting the previous node).
/// Parameter `q` controls in-out parameter (likelihood of moving outward (`q < 1.0`) vs inward (`q > 1.0`)).
pub fn node2vec_walk(
  graph : @graph.Graph,
  start_node : Int,
  walk_length : Int,
  p? : Double = 1.0,
  q? : Double = 1.0,
  seed? : Int = 42,
) -> Array[Int] {
  if walk_length <= 0 {
    return []
  }
  let walk = [start_node]
  let mut curr = start_node
  let mut prev : Int? = None
  let mut current_seed = seed
  for _ in 1..<walk_length {
    let nbrs = graph.neighbors(curr)
    let k = nbrs.length()
    if k == 0 {
      break
    }
    match prev {
      None => {
        current_seed = next_rand(current_seed)
        let idx = current_seed % k
        prev = Some(curr)
        curr = nbrs[idx]
        walk.push(curr)
      }
      Some(t) => {
        let weights = []
        let mut total_w = 0.0
        for x in nbrs {
          let alpha = if x == t {
            1.0 / p
          } else if graph.has_edge(t, x) || graph.has_edge(x, t) {
            1.0
          } else {
            1.0 / q
          }
          let w = match graph.edge_weight(curr, x) {
            Some(ew) => ew * alpha
            None => alpha
          }
          total_w += w
          weights.push(w)
        }
        if total_w <= 1.0e-12 {
          current_seed = next_rand(current_seed)
          let idx = current_seed % k
          prev = Some(curr)
          curr = nbrs[idx]
          walk.push(curr)
        } else {
          current_seed = next_rand(current_seed)
          let rand_val = (current_seed % 1000000).to_double() /
            1000000.0 *
            total_w
          let mut cumsum = 0.0
          let mut chosen = nbrs[k - 1]
          for i in 0..<k {
            cumsum += weights[i]
            if rand_val <= cumsum {
              chosen = nbrs[i]
              break
            }
          }
          prev = Some(curr)
          curr = chosen
          walk.push(curr)
        }
      }
    }
  }
  walk
}

///|
/// Simulates a corpus of random walks (`num_walks_per_node` walks for every node in the graph).
/// If `p == 1.0 && q == 1.0`, equivalent to `DeepWalk`. Otherwise performs `Node2Vec` sampling.
pub fn simulate_walks(
  graph : @graph.Graph,
  num_walks_per_node : Int,
  walk_length : Int,
  p? : Double = 1.0,
  q? : Double = 1.0,
  seed? : Int = 42,
) -> Array[Array[Int]] {
  let nodes = graph.nodes()
  let corpus = []
  let mut current_seed = seed
  for _ in 0..<num_walks_per_node {
    for u in nodes {
      current_seed = next_rand(current_seed)
      let walk = node2vec_walk(graph, u, walk_length, p~, q~, seed=current_seed)
      corpus.push(walk)
    }
  }
  corpus
}
