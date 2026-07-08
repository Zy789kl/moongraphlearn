///|
/// Helper LCG generator.
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
/// Generates Zachary's Karate Club social graph (34 nodes, 78 edges)
/// along with community ground truth labels (`label = 0` for Mr. Hi faction, `label = 1` for John A faction).
pub fn karate_club_graph() -> (@graph.Graph, Array[Int]) {
  let g = @graph.Graph::new(directed=false)
  for i in 0..<34 {
    g.add_node(i)
  }
  let edges = [
    (0, 1),
    (0, 2),
    (0, 3),
    (0, 4),
    (0, 5),
    (0, 6),
    (0, 7),
    (0, 8),
    (0, 10),
    (0, 11),
    (0, 12),
    (0, 13),
    (0, 17),
    (0, 19),
    (0, 21),
    (0, 31),
    (1, 2),
    (1, 3),
    (1, 7),
    (1, 13),
    (1, 17),
    (1, 19),
    (1, 21),
    (1, 30),
    (2, 3),
    (2, 7),
    (2, 8),
    (2, 9),
    (2, 13),
    (2, 27),
    (2, 28),
    (2, 32),
    (3, 7),
    (3, 12),
    (3, 13),
    (4, 6),
    (4, 10),
    (5, 6),
    (5, 10),
    (5, 16),
    (6, 16),
    (8, 30),
    (8, 32),
    (8, 33),
    (9, 33),
    (13, 33),
    (14, 32),
    (14, 33),
    (15, 32),
    (15, 33),
    (18, 32),
    (18, 33),
    (19, 33),
    (20, 32),
    (20, 33),
    (22, 32),
    (22, 33),
    (23, 25),
    (23, 27),
    (23, 29),
    (23, 32),
    (23, 33),
    (24, 25),
    (24, 27),
    (24, 31),
    (25, 31),
    (26, 29),
    (26, 33),
    (27, 33),
    (28, 31),
    (28, 33),
    (29, 32),
    (29, 33),
    (30, 32),
    (30, 33),
    (31, 32),
    (31, 33),
    (32, 33),
  ]
  for e in edges {
    let (u, v) = e
    g.add_edge(u, v)
  }
  // Ground truth community labels (0: Mr. Hi, 1: Officer)
  let labels = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1,
  ]
  (g, labels)
}

///|
/// Generates a Stochastic Block Model (SBM) synthetic graph.
/// `num_nodes` nodes partitioned equally into `num_classes` communities.
/// Edge probability within the same community is `p_in`, between different communities is `p_out`.
pub fn random_block_model(
  num_nodes : Int,
  num_classes : Int,
  p_in? : Double = 0.3,
  p_out? : Double = 0.05,
  seed? : Int = 42,
) -> (@graph.Graph, Array[Int]) {
  let g = @graph.Graph::new(directed=false)
  let labels = []
  for i in 0..<num_nodes {
    g.add_node(i)
    labels.push(i % num_classes)
  }
  let mut current_seed = seed
  for u in 0..<num_nodes {
    for v in (u + 1)..<num_nodes {
      current_seed = next_rand(current_seed)
      let rand_val = (current_seed % 1000000).to_double() / 1000000.0
      let prob = if labels[u] == labels[v] { p_in } else { p_out }
      if rand_val < prob {
        g.add_edge(u, v)
      }
    }
  }
  (g, labels)
}
