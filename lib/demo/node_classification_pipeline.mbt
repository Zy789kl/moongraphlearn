///|
/// Stores accuracy metrics (`train_acc`, `val_acc`, `test_acc`) and predicted classes (`preds`).
pub(all) struct PipelineResult {
  train_acc : Double
  val_acc : Double
  test_acc : Double
  preds : Array[Int]
} derive(Debug)

///|
/// Runs an end-to-end node classification toy pipeline on any graph dataset:
/// 1. Splits nodes deterministically into Train, Val, and Test masks.
/// 2. Converts ground truth `labels` into one-hot feature distribution.
/// 3. Propagates and diffuses label features across structural neighborhoods via `@msgpass.label_propagation`.
/// 4. Computes classification predictions via argmax and reports exact accuracies.
pub fn run_node_classification_pipeline(
  graph : @graph.Graph,
  labels : Array[Int],
  num_classes : Int,
  alpha? : Double = 0.5,
  max_iter? : Int = 30,
) -> PipelineResult {
  let n = graph.node_count()
  let split = @preprocess.train_val_test_split_nodes(
    n,
    train_ratio=0.5,
    val_ratio=0.2,
    seed=42,
  )
  let onehot = []
  for i in 0..<n {
    let row = []
    let l = if i < labels.length() { labels[i] } else { 0 }
    for c in 0..<num_classes {
      if c == l {
        row.push(1.0)
      } else {
        row.push(0.0)
      }
    }
    onehot.push(row)
  }
  let init_features = @graph.NodeFeatures::from_arrays(onehot)
  let diffused = @msgpass.label_propagation(
    graph,
    init_features,
    split.train_mask,
    alpha~,
    max_iter~,
  )
  let preds = []
  let mut train_corr = 0
  let mut train_cnt = 0
  let mut val_corr = 0
  let mut val_cnt = 0
  let mut test_corr = 0
  let mut test_cnt = 0
  for i in 0..<n {
    let row = diffused.get(i)
    let mut best_c = 0
    let mut best_v = -1.0e30
    for c in 0..<num_classes {
      if row[c] > best_v {
        best_v = row[c]
        best_c = c
      }
    }
    preds.push(best_c)
    let true_l = if i < labels.length() { labels[i] } else { 0 }
    if split.train_mask[i] {
      train_cnt += 1
      if best_c == true_l {
        train_corr += 1
      }
    } else if split.val_mask[i] {
      val_cnt += 1
      if best_c == true_l {
        val_corr += 1
      }
    } else if split.test_mask[i] {
      test_cnt += 1
      if best_c == true_l {
        test_corr += 1
      }
    }
  }
  let train_acc = if train_cnt > 0 {
    train_corr.to_double() / train_cnt.to_double()
  } else {
    0.0
  }
  let val_acc = if val_cnt > 0 {
    val_corr.to_double() / val_cnt.to_double()
  } else {
    0.0
  }
  let test_acc = if test_cnt > 0 {
    test_corr.to_double() / test_cnt.to_double()
  } else {
    0.0
  }
  { train_acc, val_acc, test_acc, preds }
}
