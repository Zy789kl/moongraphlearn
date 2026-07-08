///|
test "Uniform neighbor sampling without replacement" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(0, 2)
  g.add_edge(0, 3)
  let sampled = uniform_sample_neighbors(g, 0, 2, replacement=false, seed=100)
  assert_eq(sampled.length(), 2)
  assert_true(sampled[0] != sampled[1])
}

///|
test "Random walk and Node2Vec walk" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(1, 2)
  g.add_edge(2, 3)
  let walk = random_walk(g, 0, 4, seed=42)
  assert_eq(walk.length(), 4)
  assert_eq(walk[0], 0)
  let n2v = node2vec_walk(g, 0, 4, p=0.5, q=2.0, seed=42)
  assert_eq(n2v.length(), 4)
}

///|
test "GraphSAGE multi-layer sampling" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(1, 2)
  g.add_edge(2, 3)
  let m_layer = graphsage_multi_layer_sample(
    g,
    [1],
    [2, 1],
    replacement=false,
    seed=10,
  )
  assert_eq(m_layer.layer_nodes.length(), 3)
  assert_eq(m_layer.layer_nodes[0].length(), 1)
  assert_eq(m_layer.layer_nodes[0][0], 1)
  assert_true(m_layer.layer_nodes[1].length() >= 1)
}

///|
test "Negative edge sampling" {
  let g = @graph.Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_node(2) // node 2 has no edges connected to 0
  let negs = sample_negative_edges(g, 1, seed=99)
  assert_eq(negs.length(), 1)
  let (u, v) = negs[0]
  assert_true(u != v)
  assert_eq(g.has_edge(u, v), false)
}
