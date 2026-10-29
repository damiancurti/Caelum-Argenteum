"""Archive native transaction/clock evidence; does not claim route integration."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

R = Path(__file__).resolve().parents[2]
H = Path(__file__).resolve().parent
W = R / "build/issue415-rounds"
package = W / "probe/caelum_argenteum_dev.pk3"
sha = hashlib.sha256(package.read_bytes()).hexdigest()
runs = []
for label in ["theft-transfer03", "theft-load02", "theft-plan02", "theft-planload01"]:
    raw = (W / f"{label}.txt").read_bytes()
    log = raw.decode("utf-8", errors="replace")
    result = re.search(r"^CA415T RESULT passed=(\d+) failed=(\d+)", log, re.M)
    assert result and int(result[2]) == 0 and not re.search(r"^CA415T FAIL|VM execution aborted|Script error", log, re.M)
    metadata = json.loads((W / f"{label}-run.json").read_text(encoding="utf-8-sig"))
    assert metadata["package_sha256"].lower() == sha and metadata["exit_code"] == 0
    for suffix in [".txt", "-run.json"]:
        destination = H / "native" / (label + suffix)
        data = (W / (label + suffix)).read_bytes()
        if destination.exists():
            assert destination.read_bytes() == data
        else:
            destination.write_bytes(data)
    runs.append({"label": label, "passed": int(result[1]), "failed": 0})
members = ["ZSCRIPT", "caelum/data/CaelumTheftData.zs", "caelum/world/CaelumTheftTransfer.zs", "caelum/world/CaelumTheftPlan.zs"]
with zipfile.ZipFile(package) as archive:
    for member in members:
        assert archive.read(member) == (R / "src" / member).read_bytes()
report = {"issue": 415, "date": "2026-10-29", "runtime_sha256": sha,
          "verified_source_members": members, "runs": runs, "assertions": sum(run["passed"] for run in runs),
          "qualification": "Native transaction and saved-clock checks. Real route capture, chronological combat integration and #417 thief registration remain pending. No author acceptance.",
          "harness_fix": "Anchor CA diagnostic prefixes: unanchored case-insensitive matching misread 'capacity failure' inside a PASS label as a failed assertion."}
(H / "theft-results.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(json.dumps(report, indent=2))
