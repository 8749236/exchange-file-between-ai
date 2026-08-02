# C1-D v0.1.15 probe-fix handoff

替代有缺陷的 v0.1.14 冻结包：

- 包：`Callosum-Nano-v0.1.15-C1-D-probe-fix.zip`
- SHA256：`a727ad5d600ccdbea67e2e2aad4461f0bc264c6e76d40c919d7e608cf2d89d6f`
- tests：49/49 passed；新增测试真实执行 D0/D bridge probe。

本次只修复 probe collector 的条件 guard；模型、loss、参数初始化、冻结配置、判读门
与 `run_c1_d_formal.sh` 命令均未改变。请按猫盆纪律使用全新输出目录，不续用崩溃
现场。

```bash
unzip Callosum-Nano-v0.1.15-C1-D-probe-fix.zip -d c1-d-v015
cd c1-d-v015
bash run_c1_d_formal.sh runs-c1-d-formal-v015 cpu
```
