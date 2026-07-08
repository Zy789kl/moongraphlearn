///|
test "Symmetric normalization check" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(1, 2)
  let norm_weights = symmetric_normalized_weights(g, with_self_loops=true)
  let edges_0 = norm_weights[0]
  assert_true(edges_0.length() > 0)
}

///|
test "Train/Val/Test node split" {
  let split = train_val_test_split_nodes(
    10,
    train_ratio=0.5,
    val_ratio=0.3,
    seed=123,
  )
  let mut train_count = 0
  let mut val_count = 0
  let mut test_count = 0
  for i in 0..<10 {
    if split.train_mask[i] {
      train_count += 1
    }
    if split.val_mask[i] {
      val_count += 1
    }
    if split.test_mask[i] {
      test_count += 1
    }
  }
  assert_eq(train_count, 5)
  assert_eq(val_count, 3)
  assert_eq(test_count, 2)
}

///|
test "Induced and K-hop subgraph" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(1, 2)
  g.add_edge(2, 3)
  g.add_edge(3, 4)
  let (subg, nodes) = k_hop_subgraph(g, 1, 1)
  assert_eq(nodes.length(), 3)
  assert_eq(subg.node_count(), 3)
  assert_eq(subg.has_edge(0, 1), true)
  assert_eq(subg.has_edge(2, 3), false)
}

///|
test "Graph statistics and clustering coefficient" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(1, 2)
  g.add_edge(2, 0)
  g.add_edge(2, 3)

  let cc_0 = clustering_coefficient(g, 0)
  assert_true((cc_0 - 1.0).abs() < 1.0e-9)

  let comps = connected_components(g)
  assert_eq(comps.length(), 1)
}
