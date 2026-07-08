///|
test "Stochastic Block Model medium scale stress test" {
  let (g, labels) = random_block_model(120, 3, p_in=0.5, p_out=0.03, seed=100)
  assert_eq(g.node_count(), 120)
  assert_true(g.edge_count() > 300)
  let res = run_node_classification_pipeline(
    g,
    labels,
    3,
    alpha=0.55,
    max_iter=35,
  )
  assert_eq(res.preds.length(), 120)
  assert_true(res.train_acc == 1.0)
}
