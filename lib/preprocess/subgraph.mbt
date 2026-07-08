///|
/// Extracts the induced subgraph containing only `nodes` and the edges between them.
pub fn induce_subgraph(
  graph : @graph.Graph,
  nodes : Array[Int],
) -> @graph.Graph {
  let node_set : Map[Int, Bool] = {}
  for u in nodes {
    node_set[u] = true
  }
  let subg = @graph.Graph::new(directed=graph.directed)
  for u in nodes {
    subg.add_node(u)
    for e in graph.neighbor_edges(u) {
      if node_set.contains(e.v) {
        if subg.directed || u <= e.v {
          subg.add_edge(u, e.v, weight=e.weight)
        }
      }
    }
  }
  subg
}

///|
/// Extracts the `k`-hop neighborhood subgraph surrounding `start_node`.
/// Returns `(subgraph, neighborhood_nodes)`.
pub fn k_hop_subgraph(
  graph : @graph.Graph,
  start_node : Int,
  k : Int,
) -> (@graph.Graph, Array[Int]) {
  let visited : Map[Int, Bool] = {}
  let queue = [start_node]
  let distances : Map[Int, Int] = {}
  visited[start_node] = true
  distances[start_node] = 0
  let mut head = 0
  while head < queue.length() {
    let curr = queue[head]
    head += 1
    let d = distances[curr]
    if d < k {
      for nxt in graph.neighbors(curr) {
        if !visited.contains(nxt) {
          visited[nxt] = true
          distances[nxt] = d + 1
          queue.push(nxt)
        }
      }
    }
  }
  let subg = induce_subgraph(graph, queue)
  (subg, queue)
}
