///|
/// Computes PageRank scores for all nodes using power iteration.
/// `damping` is the teleportation factor (usually 0.85).
/// `tol` is the convergence threshold for L1 norm difference.
pub fn pagerank(
  graph : @graph.Graph,
  damping? : Double = 0.85,
  max_iter? : Int = 100,
  tol? : Double = 1.0e-6,
) -> Map[Int, Double] {
  let nodes = graph.nodes()
  let n = nodes.length()
  let scores : Map[Int, Double] = {}
  if n == 0 {
    return scores
  }
  let init_val = 1.0 / n.to_double()
  for u in nodes {
    scores[u] = init_val
  }
  let out_degs : Map[Int, Double] = {}
  for u in nodes {
    let mut deg = 0.0
    for e in graph.neighbor_edges(u) {
      deg += e.weight
    }
    out_degs[u] = deg
  }
  let mut iter = 0
  while iter < max_iter {
    iter += 1
    let mut dangling_sum = 0.0
    for u in nodes {
      let d = out_degs[u]
      if d <= 1.0e-12 {
        dangling_sum += scores[u]
      }
    }
    let next_scores : Map[Int, Double] = {}
    let base = (1.0 - damping) / n.to_double() +
      damping * (dangling_sum / n.to_double())
    let mut diff = 0.0
    for v in nodes {
      let mut incoming_val = 0.0
      for e in graph.in_neighbor_edges(v) {
        let u = e.u
        let du = out_degs[u]
        if du > 1.0e-12 {
          incoming_val += scores[u] * (e.weight / du)
        }
      }
      let new_score = base + damping * incoming_val
      diff += (new_score - scores[v]).abs()
      next_scores[v] = new_score
    }
    for u in nodes {
      scores[u] = next_scores[u]
    }
    if diff < tol {
      break
    }
  }
  scores
}

///|
/// Computes Personalized PageRank (PPR) scores for all nodes.
/// `personalization` maps node IDs to their prior teleportation weights (will be normalized to sum to 1.0).
pub fn personalized_pagerank(
  graph : @graph.Graph,
  personalization : Map[Int, Double],
  damping? : Double = 0.85,
  max_iter? : Int = 100,
  tol? : Double = 1.0e-6,
) -> Map[Int, Double] {
  let nodes = graph.nodes()
  let n = nodes.length()
  let scores : Map[Int, Double] = {}
  if n == 0 {
    return scores
  }
  let norm_p : Map[Int, Double] = {}
  let mut p_sum = 0.0
  for u in nodes {
    let val = match personalization.get(u) {
      Some(v) => if v > 0.0 { v } else { 0.0 }
      None => 0.0
    }
    norm_p[u] = val
    p_sum += val
  }
  for u in nodes {
    if p_sum > 1.0e-12 {
      norm_p[u] = norm_p[u] / p_sum
    } else {
      norm_p[u] = 1.0 / n.to_double()
    }
    scores[u] = norm_p[u]
  }
  let out_degs : Map[Int, Double] = {}
  for u in nodes {
    let mut deg = 0.0
    for e in graph.neighbor_edges(u) {
      deg += e.weight
    }
    out_degs[u] = deg
  }
  let mut iter = 0
  while iter < max_iter {
    iter += 1
    let mut dangling_sum = 0.0
    for u in nodes {
      let d = out_degs[u]
      if d <= 1.0e-12 {
        dangling_sum += scores[u]
      }
    }
    let next_scores : Map[Int, Double] = {}
    let mut diff = 0.0
    for v in nodes {
      let mut incoming_val = 0.0
      for e in graph.in_neighbor_edges(v) {
        let u = e.u
        let du = out_degs[u]
        if du > 1.0e-12 {
          incoming_val += scores[u] * (e.weight / du)
        }
      }
      let pv = norm_p[v]
      let new_score = (1.0 - damping) * pv +
        damping * (incoming_val + dangling_sum * pv)
      diff += (new_score - scores[v]).abs()
      next_scores[v] = new_score
    }
    for u in nodes {
      scores[u] = next_scores[u]
    }
    if diff < tol {
      break
    }
  }
  scores
}
