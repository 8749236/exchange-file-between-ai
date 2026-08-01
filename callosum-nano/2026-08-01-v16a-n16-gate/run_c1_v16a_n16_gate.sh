#!/usr/bin/env bash
set -euo pipefail

# Run this script from the unpacked Callosum-Nano v0.1.9 source root:
#   bash /path/to/run_c1_v16a_n16_gate.sh [output_root] [device]

output_root="${1:-runs-c1-v1.6a-n16-gate}"
device="${2:-cpu}"

if [[ -e "$output_root" ]]; then
  echo "refusing to mix with existing output: $output_root" >&2
  exit 2
fi

python -m pytest -q

common=(
  --steps 4000
  --eval-interval 200
  --validation-episodes 1024
  --learning-rate 3e-3
  --lr-decay-steps 4000
  --min-lr-ratio 1.0
  --weight-decay 0
  --grad-clip 1.0
  --data-mode chain-two-hop
  --filler-mode random
  --id-count 16
  --layers 2
  --heads 2
  --branch-width 64
  --position-encoding learned
  --seeds 1 2
  --conditions oracle-left
  --device "$device"
)

echo "===== C1-v1.6a H: actual harness bundle ====="
python -m callosum_nano.c1_compare \
  --output "$output_root/H" \
  --batch-size 32 \
  --warmup-steps 100 \
  --full-lm-lambda 1.0 \
  --assay-label C1-v1.6a-N16-H \
  "${common[@]}"

gate_summary() {
  local summary_path="$1"
  local gate_path="$2"
  python - "$summary_path" "$gate_path" <<'PY'
import json
import sys

summary_path, gate_path = sys.argv[1:]
summary = json.load(open(summary_path, encoding="utf-8"))
rows = []
for result in summary["results"]:
    endpoint = result["endpoint_validation"]
    passed = (
        endpoint["free_code_acc"] >= 0.90
        and endpoint["free_v_given4_acc"] >= 0.90
        and endpoint["free_chain_exact_acc"] >= 0.90
    )
    rows.append(
        {
            "seed": result["train"]["seed"],
            "endpoint_step": result["endpoint_step"],
            "free_code_acc": endpoint["free_code_acc"],
            "free_v_given4_acc": endpoint["free_v_given4_acc"],
            "free_chain_exact_acc": endpoint["free_chain_exact_acc"],
            "passed": passed,
        }
    )
gate = {
    "rule": "both seeds endpoint free_code/free_v_given4/free_chain_exact >= 0.90",
    "passed": len(rows) == 2 and all(row["passed"] for row in rows),
    "seeds": rows,
}
with open(gate_path, "w", encoding="utf-8") as handle:
    json.dump(gate, handle, indent=2, sort_keys=True)
print(json.dumps(gate, indent=2, sort_keys=True))
raise SystemExit(0 if gate["passed"] else 3)
PY
}

if gate_summary "$output_root/H/summary.json" "$output_root/H/gate.json"; then
  echo "C1-v1.6a H passed: M is pre-registered as not run. Stop before N64 LONG."
  exit 0
fi

echo "===== C1-v1.6a M: ref2-aligned training bundle ====="
python -m callosum_nano.c1_compare \
  --output "$output_root/M" \
  --batch-size 64 \
  --warmup-steps 1 \
  --full-lm-lambda 0.0 \
  --assay-label C1-v1.6a-N16-M \
  "${common[@]}"

if gate_summary "$output_root/M/summary.json" "$output_root/M/gate.json"; then
  echo "C1-v1.6a M passed: stop and isolate the training bundle. Do not run N64 LONG."
else
  status=$?
  echo "C1-v1.6a M failed: stop and audit remaining model differences. Do not run N64 LONG."
  exit "$status"
fi

