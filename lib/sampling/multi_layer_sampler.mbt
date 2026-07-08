///|
/// Represents multi-layer sampled neighborhood structures (`GraphSAGE` style).
/// `layer_nodes[l]` stores unique node IDs at hop `l` (`l = 0` is the target batch).
/// `layer_adjs[l]` maps each node in `layer_nodes[l]` to its sampled neighbors in `layer_nodes[l + 1]`.
pub(all) struct MultiLayerNeighborhood {
  layer_nodes : Array[Array[Int]]
  layer_adjs : Array[Map[Int, Array[Int]]]
} derive(Debug)

///|
/// Performs GraphSAGE-style multi-layer mini-batch neighborhood sampling.
/// For each layer `l` with fanout `fanouts[l]`, samples neighbors from layer `l` nodes to form layer `l + 1`.
pub fn graphsage_multi_layer_sample(
  graph : @graph.Graph,
  target_nodes : Array[Int],
  fanouts : Array[Int],
  replacement? : Bool = false,
  seed? : Int = 42,
) -> MultiLayerNeighborhood {
  let layer_nodes = [target_nodes]
  let layer_adjs = []
  let mut current_seed = seed
  for l in 0..<fanouts.length() {
    let fanout = fanouts[l]
    let curr_nodes = layer_nodes[l]
    let next_set : Map[Int, Bool] = {}
    let adj_map : Map[Int, Array[Int]] = {}
    for u in curr_nodes {
      next_set[u] = true
    }
    for idx, u in curr_nodes {
      current_seed = next_rand(current_seed + idx)
      let sampled = uniform_sample_neighbors(
        graph,
        u,
        fanout,
        replacement~,
        seed=current_seed,
      )
      adj_map[u] = sampled
      for v in sampled {
        next_set[v] = true
      }
    }
    let next_nodes = []
    for k, _ in next_set {
      next_nodes.push(k)
    }
    next_nodes.sort()
    layer_nodes.push(next_nodes)
    layer_adjs.push(adj_map)
  }
  { layer_nodes, layer_adjs }
}
