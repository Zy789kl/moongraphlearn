///|
test "Graph basic operations undirected" {
  let g = Graph::new(directed=false)
  g.add_edge(0, 1)
  g.add_edge(1, 2, weight=2.5)
  assert_eq(g.node_count(), 3)
  assert_eq(g.edge_count(), 2)
  assert_eq(g.degree(1), 2)
  assert_eq(g.has_edge(0, 1), true)
  assert_eq(g.has_edge(1, 0), true)
  assert_true(g.edge_weight(1, 2).unwrap() == 2.5)
}

///|
test "Graph basic operations directed" {
  let g = Graph::new(directed=true)
  g.add_edge(0, 1)
  assert_eq(g.has_edge(0, 1), true)
  assert_eq(g.has_edge(1, 0), false)
  assert_eq(g.degree(0), 1)
  assert_eq(g.in_degree(1), 1)
}

///|
test "NodeFeatures Min-Max normalization" {
  let nf = NodeFeatures::from_arrays([[0.0, 10.0], [5.0, 20.0], [10.0, 30.0]])
  let norm = nf.min_max_normalize()
  debug_inspect(
    norm.get(0),
    content=(
      #|[0, 0]
    ),
  )
  debug_inspect(norm.get(1), content="[0.5, 0.5]")
  debug_inspect(
    norm.get(2),
    content=(
      #|[1, 1]
    ),
  )
}

///|
test "NodeFeatures Z-Score normalization" {
  let nf = NodeFeatures::from_arrays([[1.0, 100.0], [2.0, 100.0], [3.0, 100.0]])
  let norm = nf.zscore_normalize()
  assert_true(norm.get(1)[0].abs() < 1.0e-9)
  assert_true(norm.get(0)[1].abs() < 1.0e-9)
}

///|
test "NodeFeatures L2 normalization" {
  let nf = NodeFeatures::from_arrays([[3.0, 4.0], [0.0, 0.0]])
  let norm = nf.l2_normalize()
  debug_inspect(norm.get(0), content="[0.6, 0.8]")
  debug_inspect(
    norm.get(1),
    content=(
      #|[0, 0]
    ),
  )
}

///|
test "Graph IO conversion" {
  let mat = [[0.0, 1.0, 0.0], [1.0, 0.0, 2.0], [0.0, 2.0, 0.0]]
  let g = Graph::from_adjacency_matrix(mat, directed=false)
  assert_eq(g.edge_count(), 2)
  assert_eq(g.has_edge(1, 2), true)
  assert_true(g.edge_weight(1, 2).unwrap() == 2.0)
}
