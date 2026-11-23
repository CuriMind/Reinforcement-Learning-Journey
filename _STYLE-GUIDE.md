# 写作规范与纪律（强化学习之旅 v2 · 全卷共享）

> 本文件是**契约**，不是正文。每章作者写作前通读、写作时逐条对照；维护者改目录时同步改第四节的边界表。

---

## 一、读者与定位

- **读者**：会写 PyTorch、读过 Transformer、想真正能训模型/能判断论文真假的工程师与研究者。**不假设**读过 Sutton & Barto 全书。
- **定位**：可自学的教材 + 可执行的实验手册。**不是论文综述，不是框架文档。**
- **语言**：简体中文。术语首次出现给英文原文（如"优势函数（advantage function）"），之后用中文。
- **可读性硬要求**：先直觉后公式；公式紧跟"逐项读"；禁止"综上所述""值得注意的是"等填充语。

---

## 二、每章固定骨架（缺一项即不合格）

```
## N. 章标题

> **本章回答的问题**：一句话说清这一章解决什么。

> **证据强度**：📙 单篇报告 —— 一句话说清本章最强与最弱的结论各是什么。
> （若章内某节证据更弱，在该节再标一次，如 10 章的 ORM/PRM 之争标 📓）

> **本章边界**：必须写什么 / **不写什么（去哪一章）**。

### N.1 小节标题（标题即结论，不写"概述""简介"）

> **本节回答的问题**：…

（机制拆解 → 公式 → **逐项读** → 对比表 → 工程提示 / ⚠️ 常见错误）

**小结**：一句话结论 + 与下一节的衔接。

---

（每两个 `###` 之间一条 `---`）

**本章收束**：① 本章解决了什么；② 与下一章的接口是什么；③ 留在哪一章的哪个未解问题上。
```

**证据强度四级**（页首必须标，且只用这四种）：

| 标记 | 含义 | 使用条件 |
|---|---|---|
| 📕 教科书结论 | ≥5 年、多本教材一致、无需引用单一论文 | 贝尔曼方程、PPO 的 clip 目标、TD 收敛性 |
| 📗 多篇独立复现 | ≥2 个独立团队/论文结论方向一致 | RLHF 有效、RFT/STaR 可固化收益、DQN 可训 |
| 📙 单篇报告 | 单一论文或单一团队，方向可信但未经独立复现 | GRPO、DAPO、GSPO、XRPO、StepPO 等 2024–2026 方法 |
| 📓 争议中 / 工程经验 | 存在反例，或仅来自工程实践与二手转述 | pass@k 反转之争、ORM vs PRM、harness 分工、防作弊细节 |

> **纪律**：**单篇报告（📙）不得写成"事实"。** 写法是"论文报告了 X（📙），其反例见 Y"。存在反例时必须在同一章并列，不得省略。

---

## 三、三条数字纪律

1. **能推导的就给推导**：遗憾界、方差、显存账、token 成本、pass@k 估计式，都写出来。
2. **凡具体数值必须标口径**：
   - 采样：`n`（每组样本数）× 上下文长度 × 轮数 $T$ → 总 token；标明是否含 rollout 与验证；
   - pass@k：必须给 $n$ 与温度，否则数字无意义；
   - 熵：给估计方式（token 级 vs 序列级、是否 length-normalized）；
   - 加速/省钱：给基线（相对谁、什么硬件、什么 batch）。
3. **区分解析推导与论文报告值**：写"解析推导，未实测"或"论文报告值（📙）"。

---

## 四、33 章边界表（本卷最容易出错的地方）

| 章 | 必须写 | **禁止写**（属于他章） |
|:--:|---|---|
| 0 | 时间轴、两条主线 + 序列表征对照线 + 粒度暗线、DAG、粒度账本表首版、证据四级 | 任何技术细节 |
| 1 | 遗憾界、UCB/Thompson/ε-greedy、contextual bandit、探索即预算 | MDP 的状态转移（→2）；推荐系统实例（→28） |
| 2 | MDP 定义、回报、$V/Q$、贝尔曼期望/最优、压缩映射 | LLM 场景（→9）；算法（→3/4） |
| 3 | DP、策略评估/改进、截断策略迭代、收敛性 | 无模型方法（→4）；函数逼近（→5） |
| 4 | MC、TD、SARSA、Q-learning、on/off-policy、重要性采样 | 探索算法（→1）；DQN（→5） |
| 5 | 线性逼近、半梯度、致命三要素、DQN 家族 | 分布式 RL；离线 RL（→8） |
| 6 | PG 定理、REINFORCE、基线、A2C、GAE | PPO 的 clip（→7）；token 级 MDP（→9） |
| 7 | TRPO→PPO、KL 约束、单调改进、clip、工程要点 | 错误实现清单（→E1 实验）；GRPO（→12） |
| 8 | 行为策略/覆盖/分布偏移、BC、保守估计动机、DT、RvS、条件生成式决策 | 离线 RL 进阶算法；扩散模型推导（跨课程引用） |
| 9 | 三种形式化对照、RM/BT、KL 约束（β vs δ）、RLHF 三阶段、DPO 闭式解与前提 | 多轮 step 级（→16）；GRPO 推导（→12） |
| 10 | ORM vs PRM、PRM800K 成本、RM 训练与数据、过优化/Goodhart、长度与位置偏置 | 验证器工程（→11）；多轮过程奖励（→17） |
| 11 | RLVR 主轴、解析器 hack、隐藏/变形测试、沙箱、RLAIF 与自奖励边界 | 多轮（→17）；验证器覆盖度的**规模**问题（→23） |
| 12 | 组内归一化、优势估计、与 PPO 的显存/算力对比、成本模型、去 critic 的条件性 | 修正方法（→13/14）；agentic（→16） |
| 13 | 长度膨胀（缺陷 + 混淆）、熵崩塌、DAPO 四补丁、Dr.GRPO、梯度真空 | 序列级/价值基线（→14）；长度的方法论讨论（→15） |
| 14 | GSPO、VAPO、CISPO、CoDaPO | 重复 13 章缺陷分析；agentic（→17） |
| 15 | pass@k 反转、分布锐化 vs 能力、length control、证伪实验设计 | 长度膨胀的工程处理（→13）；具体算法（→12–14） |
| 16 | 动作=步骤、状态=历史、三种形式化的工程后果、上下文截断的影响 | 重复 9 章 POMDP 推导；信用分配算法（→17） |
| 17 | 四种信用分配范式并列（StepPO/GVPO/ELPO/CARD）与各自的方差/样本成本 | 环境设计（→18）；harness（→19） |
| 18 | 工具结果作为部分可验证信号、VPR、环境合成、难度校准 | harness 工程（→19/31）；验证器防作弊（→11） |
| 19 | 内化/外化的判据、重试与权限的归属、可恢复性设计 | 训练框架细节（→31）；稳定性（→25） |
| 20 | 任务成功率、步数、工具正确率、退化、每步成本 | 训练级评估（→32） |
| 21 | XRPO、CoDaPO、GTPO/GRPO-S、算力分配的可优化形式 | 多轮分配（→17）；成本模型推导（→12） |
| 22 | ProRL v2、参考策略重置、异步/流式、部分 rollout、训练 vs 推理算力 | agentic 异步环境（→18/23） |
| 23 | 环境合成、日志回放、难度校准、验证器覆盖度、数据飞轮度量 | 算法（→12–14）；防作弊机制（→11） |
| 24 | Mamba/混合架构 × RL、world model 与规划、长序列取舍 | 架构推导（跨课程）；多目标（→26） |
| 25 | 熵管理栈、停滞检查清单、RL grokking | 多轮稳定性（→20）；安全（→26） |
| 26 | 帕累托、约束 RL、谄媚、reward hacking 案例、sandbagging、CoT 不忠实、窄 RL 失准 | 验证器机制（→11）；空谈伦理 |
| 27 | STaR/RFT/拒绝采样、on-policy 蒸馏、后训练流水线、接入 harness | 推理工程（→31）；算法推导（→12–14） |
| 28 | 推荐/广告/搜索的形式化、探索预算、离线评估陷阱、长期价值 | bandit 基础（→1）；RL 基础（→2–6） |
| 29 | AlphaZero/MCTS/自我对弈、模仿+RL、sim-to-real、扩散策略 | 扩散模型推导（跨课程）；多目标（→26） |
| 30 | 分子材料/芯片/物流/天气、RL vs BO/进化 | 多目标（→26）；环境合成（→23） |
| 31 | 最小可跑基座（钉版本）、框架横向对比、训推同步、显存水位 | 算法原理（→12–14） |
| 32 | 四件套控制实验、方差诊断、种子与数据版本、污染检测 | 任务级指标定义（→20） |
| 33 | 三个项目、三级验收、评分细则 | 新算法内容 |

> **跨章引用写法**：只用文字——`见第 12 章` / `见 12.3 节`。**禁止写跨文件的 Markdown 链接**（锚点由维护者统一生成与校验）。

---

## 五、最容易混的符号（RL 版，替换第一版的扩散符号串稿）

> ⚠️ **七组同名不同义，写错不报错、只掉点**：

| 易混对 | 区别 | 后果 |
|---|---|---|
| **PPO 的 clip ε vs ε-greedy 的 ε** | 前者是信赖域宽度，后者是探索概率 | 讲义里出现"ε=0.2"必须能一眼分辨 |
| **γ（折扣）vs λ（GAE 迹衰减）** | 一个衰减未来奖励，一个衰减 TD 误差加权 | 写反曲线仍能涨，但方差估计全错 |
| **KL 惩罚系数 β vs KL 约束阈值 δ** | 拉格朗日乘子 vs 信赖域半径 | 混用会让"KL 受控"变成假象 |
| **回报 $G$ vs 优势 $A$ vs 值 $V$** | 三个不同的期望量 | 论文记号污染的头号来源 |
| **on-policy vs off-policy vs offline** | 数据来源 vs 数据是否收集完毕 | 中文都译"离线"，灾难级混淆；DPO 是 offline |
| **GRPO 组内 std vs 全局 std** | Dr.GRPO 的全部论点建立在此 | 除错 std 就是 Dr.GRPO 要修的那个 bug |
| **分布式 RL（distributional）vs 分布式训练（distributed）** | 前者学"回报的分布"（C51/QR-DQN），后者是多卡并行；中文都叫"分布式" | 本书第 5 章说不覆盖前者、第 31 章讲的是后者，**混读会以为自相矛盾** || **采样温度 $T$ vs 熵系数** | 一个改变分布，一个改变正则 | 熵管理章节必踩 |

另外三条本课程特有的口径警告：

1. **pass@k 的 $k$ 与 $n$**：$k$ 是取前 $k$ 次里至少一次正确，$n$ 是估计用的采样数。**$n$ 不够时 pass@k 的方差极大**，报数字必须带 $(n, T)$。
2. **"长度"是缺陷也是混淆变量**：13 章讲它作为 reward hacking 的**缺陷**，15 章讲它作为**混淆变量**。两处都写，但不得混为一谈。
3. **"去 critic" 不是进步**：12 章必须写明这是**有条件的取舍**（组采样省显存但费采样；长时域任务上 VAPO 把 critic 加回来了）。

---

## 六、文献白名单

**格式**：`作者 et al., *标题*, 年份, [arXiv:xxxx.xxxxx](https://arxiv.org/abs/xxxx.xxxxx)`，并标注**核实状态**：✅ 已核实 ｜ ⚠️ 待核准（名称/描述可能有误）｜ ❓ 未确证。

**只允许引用下表条目**；白名单外的工作写成"（相关工作，未在此列出出处）"，**严禁编造编号**。

### 6.1 经典与基础（📕/📗）
- Sutton & Barto, *Reinforcement Learning: An Introduction*, 2nd ed., 2018
- Mnih et al., *Human-level control through deep RL (DQN)*, 2015 — arXiv:1312.5602
- Schulman et al., *Trust Region Policy Optimization*, 2015 — arXiv:1502.05477
- Schulman et al., *High-Dimensional Continuous Control Using GAE*, 2016 — arXiv:1506.02438
- Schulman et al., *Proximal Policy Optimization Algorithms*, 2017 — arXiv:1707.06347
- Haarnoja et al., *Soft Actor-Critic*, 2018 — arXiv:1801.01290
- Lillicrap et al., *DDPG*, 2016 — arXiv:1509.02971
- Fujimoto et al., *BCQ (离线 RL)*, 2019 — arXiv:1812.02900
- Kumar et al., *Conservative Q-Learning (CQL)*, 2020 — arXiv:2006.04779
- Chen et al., *Decision Transformer*, 2021 — arXiv:2106.01345
- Emmons et al., *RvS: RvS / 监督学习能否替代 RL*, 2021 — arXiv:2107.08241
- Piché et al., *Is Conditional Generative Modeling All You Need for Decision Making?*, 2023 — arXiv:2211.15657

### 6.2 LLM 后训练（📗/📙）
- Ouyang et al., *InstructGPT*, 2022 — arXiv:2203.02155
- Christiano et al., *Deep RL from Human Preferences*, 2017 — arXiv:1706.03741
- Rafailov et al., *Direct Preference Optimization*, 2023 — arXiv:2305.18290
- Lightman et al., *Let's Verify Step by Step (PRM800K)*, 2023 — arXiv:2305.20050
- Bai et al., *Constitutional AI*, 2022 — arXiv:2212.08073
- Yuan et al., *Self-Rewarding Language Models*, 2024 — arXiv:2401.10020
- Zelikman et al., *STaR*, 2022 — arXiv:2203.14465
- Gulcehre et al., *ReST / RFT*, 2023 — arXiv:2308.08998
- Agarwal et al., *GKD: On-Policy Distillation of LMs*, 2023 — arXiv:2306.13649

### 6.3 GRPO 与修正（📙）
- Shao et al., *DeepSeekMath (GRPO)*, 2024 — arXiv:2402.03300
- DeepSeek-AI, *DeepSeek-R1*, 2025 — arXiv:2501.12948
- Yu et al., *DAPO*, 2025 — arXiv:2503.14476
- Liu et al., *Dr. GRPO (Understanding R1-Zero-Like Training)*, 2025 — arXiv:2503.20783
- Zheng et al., *GSPO (Group Sequence Policy Optimization)*, 2025 — arXiv:2507.18071
- Yue et al., *VAPO*, 2025 — arXiv:2504.05118 ✅
- MiniMax, *CISPO / MiniMax-M1*, 2025 — arXiv:2506.13585
- GTPO & GRPO-S, *Token and Sequence-Level Reward Shaping with Policy Entropy*, 2025 — arXiv:2508.04349 ✅

### 6.4 Scaling 与探索（📙）
- XRPO, *Pushing the Limits of GRPO with Targeted Exploration and Exploitation*, 2025 — arXiv:2510.06672 ✅
- Hu et al., *ProRL (Beyond the 80/20 Rule)*, 2025 — arXiv:2504.13837 ✅
- **ProRL v2** — ⚠️ 待核准（第一版仅写"ProRL v2，3000+ 步"，未给编号）

### 6.5 Agentic RL（📙/📓）
- StepPO, *Step-Aligned Policy Optimization for Agentic RL*, 2026 — arXiv:2604.18401 ✅
- ELPO, *Learning from the Irrecoverable*（Error-Localized Policy Optimization）, 2026 — arXiv:2602.09598 ✅
- VPR, *Verifiable Process Rewards for Agentic Reasoning*, 2026 — arXiv:2605.10325 ✅
- CARD, *Internalizing Expert Critique into RL for Deep Search*, 2026 — NeurIPS 2026 ✅
- OC-GRPO, *Off-Context GRPO: Learning to Reason on Hard Problems using Privileged Information*, 2026 — arXiv:2607.19313 ✅
- **GVPO** — ⚠️ **描述须核**：检索到的同名为 *Group **Variance** Policy Optimization*，2025 — arXiv:2504.19599 ✅；第一版写作"过程可验证塑形"，二者不符
- **多轮工具版 GTPO** — ❓ 未确证；GTPO 已确证的版本是 token/序列级（见 6.3）

### 6.6 架构底座（📙）
- Davidson et al., *DRAMA: Mamba-enabled Model-based RL*, ICLR 2025 ✅
- *CORMA: Constraint-Routed Decision Mamba*, 2026 — arXiv:2610.34208 ✅
- *Decision Mamba*, NeurIPS 2024 ✅
- **ODM** — ❓ 疑为 *Online Decision Mamba*（IEEE CogMI 2025），须确认

### 6.7 评估与安全（📗/📓）
- Carlini et al., *Extracting Training Data*, 2023 — arXiv:2301.13188
- Sharma et al., *Towards Understanding Sycophancy in LMs*, 2023 — arXiv:2310.13548

> **维护规则**：新增引用必须写"核实状态"。**⚠️ 与 ❓ 条目不允许成为某一章的骨架**，只能作为"并列的一种解法"或"研究前沿"出现。

---

### 6.8 方法替换协议（模块三专用）

模块三（16–20 章）以**问题**为骨架，方法只是答案。这是刻意设计——2026 年的单篇工作半年后可能被证伪或被超越，而问题不会。所以替换一个方法时必须守住四条**不变量**：

| 不变量（换方法时**不可改**） | 可变部分（**可以随时替换**） |
|---|---|
| 小节标题（= 问题名，如"信用分配：span / turn / 步骤"） | 该节引用的具体方法名 |
| 五列对照表的结构（信号来源 / 额外资源 / 主方差 / 适用结构 / 备注） | 表格里填的方法与数字 |
| 本章边界声明（不写什么、去哪一章） | 例证、图与 arXiv 编号 |
| 与前后章的接口句（"与下一章的接口是…"） | 方法间的比较结论（📙 可能被推翻） |

**替换时的三步**：

1. **只改表格行与正文例证**，不动标题与边界；
2. **新方法的证据强度必须标注**（📙 起步，若有独立复现升 📗）；
3. 重跑 `check-docs-v2.ps1`——它校验标题层级、小节结构与跨章链接，能挡住"替换时顺手改坏结构"。

> **判据**：替换后若某章的小节数、边界行、章末收束三项都没变，说明替换是"外科式"的；若变了，说明你在改问题，而不只是换方法——那需要同步改第 0 章的模块表与本节边界表。

---
## 七、篇幅与质量要求

| 项 | 要求 |
|---|---|
| 单章 | **140–240 行**为目标区间；内容确实需要时可达 320 行（不设硬上限，但超过 240 需自查是否注水） |
| 小节 | 4–7 个 `###`，每节可有 1–3 个 `####`（**不强制**，短小节不要切碎） |
| 公式 | 目标 6 个独立公式块（**软下限**，5 个可接受）；硬要求是每个新公式都有"逐项读" |
| 表格 | 每章至少 3 张对比表 |
| 工程提示 | 每章至少 3 处 `> **工程提示**` 或 `> ⚠️ **常见错误**` |
| 争议处理 | 凡有反例的结论，必须并列反例并给适用条件 |

---

## 八、交付自检清单

- [ ] `## N.` 章标题；`### N.Y`；无跳级、无 `#####`
- [ ] 页首三行齐全：**本章回答的问题** / **证据强度**（四级之一）/ **本章边界**
- [ ] 每个 `###` 有"本节回答的问题"与 `**小结**`
- [ ] 章末有且仅有一个 `**本章收束**`
- [ ] 每个新公式有"逐项读"
- [ ] 至少 3 张表、3 处工程提示
- [ ] 数字带口径（n/温度/成本/基线）
- [ ] 争议并列，单篇报告未写成事实
- [ ] 跨章引用只用文字，**零跨文件链接**
- [ ] 未越界（对照第四节）
- [ ] 篇幅 140–240 行
