///|
test "Karate Club dataset generator" {
  let (g, labels) = karate_club_graph()
  assert_eq(g.node_count(), 34)
  assert_eq(g.edge_count(), 78)
  assert_eq(labels.length(), 34)
}

///|
test "Stochastic Block Model generator" {
  let (g, labels) = random_block_model(20, 2, p_in=0.8, p_out=0.05, seed=12)
  assert_eq(g.node_count(), 20)
  assert_eq(labels.length(), 20)
}

///|
test "Karate Club node classification pipeline" {
  let (g, labels) = karate_club_graph()
  let res = run_node_classification_pipeline(
    g,
    labels,
    2,
    alpha=0.6,
    max_iter=30,
  )
  assert_eq(res.preds.length(), 34)
  assert_true(res.train_acc == 1.0)
  assert_true(res.test_acc > 0.6)
}
