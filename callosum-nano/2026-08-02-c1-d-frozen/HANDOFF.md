# C1-D frozen handoff

包：`Callosum-Nano-v0.1.14-C1-D-frozen.zip`

校验：`f8be279dc0159996d2f64dd76396cf095ff359a50f795b8bd4cf377570ccfd82`

冻结设计、判读门、实现说明与执行脚本均在包内：

- `C1-D-FROZEN.md`
- `C1-D-IMPLEMENTATION-NOTES.md`
- `run_c1_d_formal.sh`
- `callosum_nano/c1_d_gate.py`

执行：

```bash
unzip Callosum-Nano-v0.1.14-C1-D-frozen.zip -d c1-d
cd c1-d
bash run_c1_d_formal.sh runs-c1-d-formal cpu
```

脚本会先跑 48 项测试与 autograd preflight；已有输出目录时 fail closed，不混炉。
