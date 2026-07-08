///|
test "PageRank and Personalized PageRank" {
  let g = @graph.Graph::new(directed=true)
  g.add_edge(0, 1)
  g.add_edge(1, 2)
  g.add_edge(2, 0)
  let pr = pagerank(g, damping=0.85, max_iter=100)
  let pr0 = pr[0]
  assert_true((pr0 - 1.0 / 3.0).abs() < 1.0e-4)

  let ppr = personalized_pagerank(g, { 0: 1.0, 1: 0.0, 2: 0.0 }, damping=0.85)
  assert_true(ppr[0] > ppr[1])
}

///|
test "Structural features extraction and augmentation" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(1, 2)
  let s_feats = extract_structural_features(g)
  assert_eq(s_feats.num_nodes, 3)
  assert_eq(s_feats.feature_dim, 4)

  let raw_feats = @graph.NodeFeatures::from_arrays([
    [1.0, 2.0],
    [3.0, 4.0],
    [5.0, 6.0],
  ])
  let aug = augment_node_features(raw_feats, s_feats)
  assert_eq(aug.num_nodes, 3)
  assert_eq(aug.feature_dim, 6)
}
