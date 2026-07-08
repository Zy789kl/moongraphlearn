# MoonGraphLearn：图数据机器学习预处理与消息传递实验库

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![MoonBit: v0.1.2026+](https://img.shields.io/badge/MoonBit-v0.1.2026%2B-purple.svg)](https://www.moonbitlang.com/)

**MoonGraphLearn** 是一个专为 [MoonBit](https://www.moonbitlang.com/) 语言打造的高性能、模块化**图机器学习预处理与消息传递（Message Passing）实验库**。本项目深度结合了 **图算法（Graph Algorithms） + 图机器学习（Graph Machine Learning） + 数据分析（Data Analysis）**，旨在填补原生 MoonBit 生态在图神经网络（GNN）底层预处理、邻域采样、图结构特征工程及半监督学习算法上的空白。

## 💡 设计理念与交叉创新

与传统单纯求解最短路径或连通分量的基础图算法库不同，**MoonGraphLearn** 面向**现代图数据驱动的机器学习工作流**：
1. **轻量可落地**：相比庞大臃肿的完整神经网络框架（如 PyG / DGL），MoonGraphLearn 提供了核心计算抽象与纯原生实现，无需复杂的 Python FFI 依赖，可在 WebAssembly、JavaScript 及 Native多端零成本部署；
2. **高新颖性与实验导向**：重点突破图数据的**对称归一化矩阵构建**、**随机游走与邻域多层采样**、**通用消息传递引擎（Message / Aggregate / Update）** 及 **PageRank 结构特征增强**；
3. **极强扩展性**：不仅支持基本的节点分类与半监督标签传播（Label Propagation），其底层算子与采样轨迹还可原生无缝扩展至图表示学习（Node2Vec/DeepWalk）、推荐系统召回以及知识图谱子图分析。

---

## 📦 模块架构与分层包组织

本项目采用标准的 MoonBit 模块化分层架构，所有的包均保持高度内聚和清晰边界：

```
moongraphlearn/moongraphlearn/
├── moon.mod.json                   # 模块根配置 (namespace: moongraphlearn/moongraphlearn)
├── spec.mbt                        # 图机器学习核心接口规约声明 (Spec-driven Development)
├── lib/
│   ├── graph/                      # 图基础建模与特征矩阵库 (`@graph`)
│   │   ├── graph.mbt               # 有向/无向邻接表与边权重表达
│   │   ├── node_features.mbt       # 连续特征向量/矩阵标准化 (Z-score / Min-Max / L2)
│   │   └── graph_io.mbt            # 数据导入导出与邻接矩阵转换
│   ├── preprocess/                 # 图算法预处理库 (`@preprocess`)
│   │   ├── normalization.mbt       # 自环添加 ($A + I$) 与对称归一化 ($\hat{D}^{-1/2} \hat{A} \hat{D}^{-1/2}$)
│   │   ├── split.mbt               # 节点分类与链路预测 Train/Val/Test 划分
│   │   ├── subgraph.mbt            # 诱导子图与 k 阶邻域子图切片
│   │   └── stats.mbt               # 密度、聚类系数与连通分量等图统计学指标
│   ├── sampling/                   # 邻居采样与游走序列库 (`@sampling`)
│   │   ├── neighbor_sampler.mbt    # 均匀邻域有放回/无放回采样
│   │   ├── random_walk.mbt         # 随机游走轨迹生成 (Node2Vec / DeepWalk 核心)
│   │   ├── multi_layer_sampler.mbt # GraphSAGE 风格多层 mini-batch 分层采样
│   │   └── negative_sampler.mbt    # 链路预测负采样
│   ├── features/                   # 结构化特征提取与增强库 (`@features`)
│   │   ├── pagerank.mbt            # 幂迭代 PageRank 与个性化 PageRank (PPR)
│   │   └── structural_features.mbt # 图结构身份特征整合与原始特征矩阵拼接
│   ├── msgpass/                    # 通用消息传递引擎 (`@msgpass`)
│   │   ├── message_passing.mbt     # MessagePassingEngine: Message / Aggregate / Update
│   │   ├── gcn_conv.mbt            # 简化的 GCNConv 图卷积算子实现
│   │   ├── graphsage_conv.mbt      # GraphSAGEConv 均值/最大池化聚合算子
│   │   └── label_propagation.mbt   # Zhu & Ghahramani 半监督标签传播算法
│   └── demo/                       # 综合实验与数据集构建库 (`@demo`)
│       ├── dataset_generator.mbt   # Karate Club 34 节点社交网络与 SBM 合成图
│       └── node_classification_pipeline.mbt # 端到端图分类预处理与准确率评估
└── cmd/main/                       # 交互式与命令行综合演示程序 (`main.mbt`)
```

---

## 🚀 快速上手与示例 (`mbt check` Verified)

通过 `README.mbt.md` 内置的编译器测试代码块，您可以快速验证并体验 MoonGraphLearn 的核心工作流：

### 1. 构建图结构与标准化节点特征

```mbt check
test "create graph and normalize features" {
  // 1. 初始化无向图并添加边
  let graph = @graph.Graph::new(directed=false)
  graph.add_edge(0, 1)
  graph.add_edge(0, 2)
  graph.add_edge(1, 2)
  graph.add_edge(2, 3)

  assert_eq(graph.node_count(), 4)
  assert_eq(graph.edge_count(), 4) // 无向图4条无向边

  // 2. 为各节点配置 2 维原始特征向量
  let raw_feats = @graph.NodeFeatures::from_arrays([
    [10.0, 2.0],
    [20.0, 4.0],
    [30.0, 6.0],
    [40.0, 8.0],
  ])

  // 3. 执行 Min-Max 归一化处理，将数值缩放到 [0.0, 1.0]
  let norm_feats = raw_feats.min_max_normalize()
  inspect(norm_feats.get(0), content="[0.0, 0.0]")
  inspect(norm_feats.get(3), content="[1.0, 1.0]")
}
```

### 2. 计算对称归一化转移矩阵与 PageRank 结构特征

在图神经网络 (GCN) 与扩散模型中，直接使用邻接矩阵 $A$ 会导致度数高节点的特征无限制被放大。我们利用 `@preprocess` 与 `@features` 包计算 $\hat{D}^{-1/2} \hat{A} \hat{D}^{-1/2}$ 及节点 PageRank：

```mbt check
test "symmetric normalization and pagerank" {
  let graph = @graph.Graph::new(directed=false)
  graph.add_edge(0, 1)
  graph.add_edge(1, 2)

  // 1. 添加自环 (A + I) 并计算 GCN 对称归一化转移权重
  let gcn_weights = @preprocess.symmetric_normalized_weights(graph)
  // 此时节点 0, 1, 2 均具备自环及相互平滑的转移概率
  assert_true(gcn_weights.length() > 0)

  // 2. 计算 PageRank 结构重要度指标 (阻尼系数 damping=0.85)
  let pr = @features.pagerank(graph, damping=0.85, max_iter=50)
  // 节点 1 处于拓扑中枢位置，其 PageRank 分数最高
  assert_true(pr[1].unwrap() > pr[0].unwrap())
}
```

### 3. 半监督标签传播与多层消息传递

利用少量已知节点标签（如 0 号节点为类别 0，3 号节点为类别 1），通过 `@msgpass` 的消息传递算子完成全图标签预测：

```mbt check
test "label propagation demo" {
  let graph = @graph.Graph::new(directed=false)
  graph.add_edge(0, 1)
  graph.add_edge(1, 2)
  graph.add_edge(2, 3)

  // 初始标签定义 (Some 表示有标注，None 表示未标注待预测)
  let labels : Array[Int?] = [Some(0), None, None, Some(1)]
  let num_classes = 2

  // 执行半监督标签传播 (Zhu & Ghahramani 算法)
  let pred_probs = @msgpass.label_propagation(
    graph,
    labels,
    num_classes,
    max_iter=20,
    alpha=0.5,
  )

  // 预测出的标签概率矩阵，节点 1 靠近 0 号其类别 0 概率较高，节点 2 靠近 3 号其类别 1 概率较高
  assert_eq(pred_probs.length(), 4)
  assert_true(pred_probs[1][0] > pred_probs[1][1])
  assert_true(pred_probs[2][1] > pred_probs[2][0])
}
```

---

## 🛠️ 编译、运行与测试指南

本项目全面支持 `moonc v0.10.3+` 编译器及 MoonBit native 后端工具链：

```bash
# 1. 语法检查与接口审查
moon check
moon info

# 2. 运行所有模块的单元测试与文档测试
moon test

# 3. 运行端到端综合演示程序 (Karate Club 节点分类流)
moon run cmd/main --target native

# 4. 格式化代码
moon fmt
```

---

## 📜 来源说明与开源协议 (Attribution & License)

- **原创性声明**：本项目由 MoonGraphLearn 团队独立构思与研发。底层的图数据结构、标准化转换、邻接采样、PageRank 及消息传递引擎均采用 **MoonBit 100% 原生编程语言编写**，未复制或机械转换任何第三方库代码。
- **理论算法依据**：
  - GCN 对称归一化依据 *Kipf & Welling, ICLR 2017* (Semi-Supervised Classification with Graph Convolutional Networks);
  - GraphSAGE 采样策略依据 *Hamilton et al., NeurIPS 2017* (Inductive Representation Learning on Large Graphs);
  - 标签传播理论依据 *Zhu & Ghahramani, ICML 2002* (Learning from Labeled and Unlabeled Data with Label Propagation);
  - 合成数据集 Karate Club Graph 来源于 *Zachary, W. W., Journal of Anthropological Research (1977)*。
- **开源协议**：本项目基于 [Apache License 2.0](LICENSE) 授权开源发行。
