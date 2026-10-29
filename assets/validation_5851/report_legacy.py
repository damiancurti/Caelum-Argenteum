"""Archive the original-save migration sequence; keep original saves local."""
from pathlib import Path
import hashlib
import json
import re

R = Path(__file__).resolve().parents[2]
H = Path(__file__).resolve().parent
W = R / "build/issue415-rounds"
runs = []
for label, purpose in [("legacy-original03", "original 5.8.50 seed"),
                       ("legacy-upgrade03", "current upgrade"),
                       ("legacy-resume01", "current reload"),
                       ("legacy-rollback01", "original-save rollback in 5.8.50")]:
    raw = (W / f"{label}.txt").read_bytes()
    log = raw.decode("utf-8", errors="replace")
    result = re.search(r"CA415L RESULT passed=(\d+) failed=(\d+)", log)
    assert result and int(result[2]) == 0 and "CA415L FAIL" not in log
    for suffix in [".txt", "-run.json"]:
        target = H / "native" / (label + suffix)
        data = (W / (label + suffix)).read_bytes()
        if target.exists():
            assert target.read_bytes() == data
        else:
            target.write_bytes(data)
    runs.append({"label": label, "purpose": purpose, "passed": int(result[1]), "failed": 0})
report = {"issue": 415, "date": "2026-10-29", "runs": runs,
          "assertions": sum(row["passed"] for row in runs),
          "qualification": "21 scenario assertions, including repeated identity invariants; separate from the 335-check combat matrix. No author acceptance.",
          "saves": {name: hashlib.sha256((W / name).read_bytes()).hexdigest()
                    for name in ["original50-city.zds", "upgraded51-city.zds"]},
          "policy": "Preserve recorded bodies and inventory; first departure starts tracking at its actual date, with no invented historical combat. An overdue existing event is due at that boundary.",
          "runtime_changed": False}
(H / "legacy-results.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(json.dumps(report, indent=2))
