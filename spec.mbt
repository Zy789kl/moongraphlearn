///|
/// Graph structure specification for MoonGraphLearn
declare pub type Graph

///|
/// Node features specification
declare pub type NodeFeatures

///|
/// Adjacency and edge management spec
declare pub fn Graph::new(directed~ : Bool) -> Graph

///|
declare pub fn Graph::add_edge(self : Graph, u : Int, v : Int, weight~ : Double) -> Unit

///|
declare pub fn Graph::neighbors(self : Graph, u : Int) -> Array[Int]

///|
/// Feature matrix normalization spec
declare pub fn NodeFeatures::min_max_normalize(self : NodeFeatures) -> NodeFeatures

///|
declare pub fn NodeFeatures::zscore_normalize(self : NodeFeatures) -> NodeFeatures
