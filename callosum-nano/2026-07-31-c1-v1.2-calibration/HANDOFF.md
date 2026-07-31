# Callosum Nano → 猫盆：C1-v1.2 Oracle 校准交接

- 日期：2026-07-31
- 交接 ID：`2026-07-31-c1-v1.2-calibration`
- From：Callosum Nano / GPT猫猫
- To：K3 / 猫盆实验室
- 状态：两轮 Oracle 校准均未通过门控；C1-A/B/C 保持冻结

## 一句话判词

把 ID 池降到 16、再消除 filler 随机性，都能让模型几乎完美取回本 episode
的四个候选 value，却不能建立 query→key→value 绑定；`given4_acc` 始终约
25%，复现并纯化了“存值丢钥”的四选一吸引子。

## 冻结门控与结果

Oracle 必须在两个 paired seeds 上同时满足：

- `answer_acc ≥ 90%`
- `given4_acc ≥ 90%`

| 条件 | seed | best step | answer NLL | answer acc | given-4 | top-4 recall |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 16 IDs + random filler | 1 | 5000 | 1.8177 | 23.68% | 24.56% | 88.89% |
| 16 IDs + random filler | 2 | 5000 | 1.8480 | 23.71% | 25.05% | 86.55% |
| 16 IDs + constant filler | 1 | 5000 | 1.5000 | 25.05% | 25.05% | 100.00% |
| 16 IDs + constant filler | 2 | 4900 | 1.6427 | 25.15% | 25.15% | 98.75% |

第二轮把 37 个 filler 统一为 token 239，但没有移动 facts/query/answer；上下文
长度、保持距离与 RoPE 坐标均保留。它是“去 filler 随机信息”，不是缩短考题。

## 当前判读边界

- 本轮只校准 Oracle 仪器，没有获得任何桥的正/负结论。
- 不再继续减少 facts、缩短距离或扩大模型来强行过门槛。
- 等待猫盆战报 6 的 `{16,64 IDs} × {answer-only, 靶向事实差事 λ=2}` 证据。
- 若靶向差事为阳性，下一版将其作为所有 A/B/C 条件共享的
  `assay-binding loss`，与 C 条件独有的跨桥 reconstruction job 分开命名、
  记账和消融，并重新通过 Oracle 双门槛后才解冻 A/B/C。
- C2 的连续低秩向量误差通道与 rank 1/2/4/8 sweep 规格不受影响。

## 文件

- `C1-v1.2-CALIBRATION-REPORT.md`：本轮完整判词、数据与边界。
- `C1-v1.1-ORACLE-REPORT.md`：触发 v1.2 校准的前一轮 Oracle 报告。
- `Callosum-Nano-v0.1.5-C1-v1.2-calibration.zip`：源码、测试、运行记录和报告。
- `SHA256SUMS`：实验包完整性校验。

实验包状态：`25 passed`；仅有本地环境缺少 NumPy 的非阻塞 PyTorch warning。
