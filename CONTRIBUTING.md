# MoonGraphLearn 贡献指南与算法数理规范 (CONTRIBUTING & SPECIFICATION)

感谢您对 **MoonGraphLearn** 的关注！本库作为首个基于 **MoonBit 原生零依赖开发** 的图机器学习预处理与消息传递算子库，旨在为图数据结构、邻居采样算法及图神经网络 (GNN) 提供轻量、稳定且高效的实验与落地底座。

---

## 1. 算法数理规范 (Mathematical Specifications)

在向 `lib/msgpass` 贡献新的 GNN 卷积算子或优化现有算子时，必须严格遵守以下数理契约与维度规范：

### 1.1 GCNConv 空间卷积算子
图卷积网络（Kipf & Welling, 2017）的逐层特征传播公式为：
\[
H^{(l+1)} = \sigma \left( \hat{D}^{-1/2} \hat{A} \hat{D}^{-1/2} H^{(l)} W^{(l)} + b^{(l)} \right)
\]
* $\hat{A} = A + I_N$ 为注入自环后的带自环邻接矩阵。
* $\hat{D}_{ii} = \sum_j \hat{A}_{ij}$ 为对应的对角度数矩阵。
* $H^{(l)} \in \mathbb{R}^{N \times D_{in}}$ 为第 $l$ 层节点输入特征张量，权重矩阵 $W^{(l)} \in \mathbb{R}^{D_{in} \times D_{out}}$。
* 代码中通过 `preprocess.symmetric_normalized_graph` 完成图拓扑变换，由 `message_passing.propagate` 实现矩阵乘积累加。

### 1.2 GraphSAGEConv 分层聚合算子
GraphSAGE（Hamilton et al., 2017）通过拼接/相加自身及邻接局部邻域聚合表示来更新节点特征：
\[
h_v^{(l+1)} = \sigma \left( W_{self}^{(l)} h_v^{(l)} + W_{neigh}^{(l)} \cdot \text{AGGREGATE}_k \left( \{ h_u^{(l)}, \forall u \in \mathcal{N}(v) \} \right) + b^{(l)} \right)
\]
* $\text{AGGREGATE}_k \in \{ \text{Mean}, \text{Sum}, \text{Max} \}$ 为可插拔的聚合器算子。
* 在代码 `graphsage_conv.mbt` 中实现了对自身通道 (`weight_self`) 与邻居通道 (`weight_neigh`) 的显式解耦。

### 1.3 Label Propagation 半监督特征扩散
标签传播（Zhu & Ghahramani, 2002）及简化图卷积（SGC - Wu et al., 2019）公式为：
\[
Y^{(k+1)} = \alpha \left( \hat{D}^{-1/2} \hat{A} \hat{D}^{-1/2} Y^{(k)} \right) + (1 - \alpha) Y^{(0)}
\]
并在每次迭代末尾对训练集已知节点执行硬重置：$\forall u \in \mathcal{V}_{train}, \; Y^{(k+1)}[u] = Y^{(0)}[u]$。

---

## 2. 开发与提交规范 (Development Conventions)

1. **零外部依赖 (Zero-Dependency)**：所有算法必须基于 MoonBit 标准库开发，严禁引入第三方重量级 C/C++ 依赖。
2. **包管理要求**：新模块需在根目录下建立独立的 `lib/<module_name>` 目录，并配套极简的 `moon.pkg` 文件。
3. **测试准则**：新功能提交前必须配套单元测试文件 `*_test.mbt`，执行以下命令确保通过：
   ```bash
   moon check
   moon test -u
   moon fmt
   ```
4. **提交日志规范 (Conventional Commits)**：
   * `feat(module): ...` 添加新特性/新算法
   * `fix(module): ...` 修复计算逻辑或边界逻辑 Bug
   * `docs: ...` 完善 API 文档或数学公式说明
   * `test(module): ...` 补充或强化单元测试用例
