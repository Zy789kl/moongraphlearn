///|
test "Message passing aggregators and ReLU" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(0, 2)
  let feats = @graph.NodeFeatures::from_arrays([
    [1.0, -1.0],
    [2.0, 3.0],
    [4.0, 5.0],
  ])
  let sum_agg = aggregate_neighbors(g, feats, Sum, edge_weights=false)
  let row0 = sum_agg.get(0)
  assert_eq(row0[0], 6.0) // 2.0 + 4.0
  assert_eq(row0[1], 8.0) // 3.0 + 5.0

  let relu_feats = apply_activation(feats, relu)
  assert_eq(relu_feats.get(0)[1], 0.0)
}

///|
test "GCNConv forward pass" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  let feats = @graph.NodeFeatures::from_arrays([[1.0, 2.0], [3.0, 4.0]])
  let conv = GCNConv::init(2, 3, seed=42)
  let out = conv.forward(g, feats)
  assert_eq(out.num_nodes, 2)
  assert_eq(out.feature_dim, 3)
}

///|
test "GraphSAGEConv forward pass" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  let feats = @graph.NodeFeatures::from_arrays([[1.0, 2.0], [3.0, 4.0]])
  let conv = GraphSAGEConv::init(2, 3, aggregator=Mean, seed=42)
  let out = conv.forward(g, feats)
  assert_eq(out.num_nodes, 2)
  assert_eq(out.feature_dim, 3)
}

///|
test "Label propagation" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(1, 2)
  let labels = @graph.NodeFeatures::from_arrays([
    [1.0, 0.0],
    [0.5, 0.5],
    [0.0, 1.0],
  ])
  let mask = [true, false, true]
  let diffused = label_propagation(g, labels, mask, alpha=0.5, max_iter=20)
  assert_eq(diffused.num_nodes, 3)
  assert_eq(diffused.get(0)[0], 1.0)
  assert_eq(diffused.get(2)[1], 1.0)
}
