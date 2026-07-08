///|
fn main {
  println(
    "=====================================================================",
  )
  println(
    "   MoonGraphLearn: Graph Machine Learning & Message Passing Library  ",
  )
  println(
    "=====================================================================",
  )
  println("")

  println("--- [1] Zachary's Karate Club Benchmark ---")
  let (kc_graph, kc_labels) = @demo.karate_club_graph()
  let kc_density = @preprocess.density(kc_graph)
  let kc_avg_deg = @preprocess.average_degree(kc_graph)
  println("Nodes: \{kc_graph.node_count()}, Edges: \{kc_graph.edge_count()}")
  println("Graph Density: \{kc_density}, Average Degree: \{kc_avg_deg}")

  println("\nRunning End-to-End Node Classification Pipeline on Karate Club...")
  let kc_res = @demo.run_node_classification_pipeline(
    kc_graph,
    kc_labels,
    2,
    alpha=0.6,
    max_iter=30,
  )
  println(" -> Train Accuracy : \{kc_res.train_acc * 100.0}%")
  println(" -> Val Accuracy   : \{kc_res.val_acc * 100.0}%")
  println(" -> Test Accuracy  : \{kc_res.test_acc * 100.0}%")
  println(
    " -> Sample Predictions: \{kc_res.preds[0]} vs Ground Truth: \{kc_labels[0]}",
  )
  println(
    "---------------------------------------------------------------------",
  )

  println("\n--- [2] Stochastic Block Model (SBM) Synthetic Benchmark ---")
  let (sbm_graph, sbm_labels) = @demo.random_block_model(
    60,
    3,
    p_in=0.6,
    p_out=0.05,
    seed=42,
  )
  println("Nodes: \{sbm_graph.node_count()}, Edges: \{sbm_graph.edge_count()}")
  let sbm_res = @demo.run_node_classification_pipeline(
    sbm_graph,
    sbm_labels,
    3,
    alpha=0.5,
    max_iter=40,
  )
  println(" -> Train Accuracy : \{sbm_res.train_acc * 100.0}%")
  println(" -> Val Accuracy   : \{sbm_res.val_acc * 100.0}%")
  println(" -> Test Accuracy  : \{sbm_res.test_acc * 100.0}%")
  println(
    "=====================================================================",
  )
  println("Execution completed successfully!")
}
