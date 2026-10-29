"""Verify and archive the native chronological theft integration checkpoint."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

R = Path(__file__).resolve().parents[2]
H = Path(__file__).resolve().parent
W = R / "build/issue415-rounds"
package = W / "probe/caelum_argenteum_dev.pk3"
sha = hashlib.sha256(package.read_bytes()).hexdigest()
labels = ["theft-dispatch05", "theft-death-dispatch03", "theft-combat-dispatch01",
          "theft-hub02", "theft-dispatch-save01", "theft-dispatch-load01",
          "theft-prior-arrival-load01"]
runs = []
for label in labels:
    log = (W / (label + ".txt")).read_text(encoding="utf-8", errors="replace")
    results = re.findall(r"^CA415([TWA]) RESULT passed=(\d+) failed=(\d+)", log, re.M)
    assert results and all(int(f) == 0 for _, _, f in results)
    assert not re.search(r"^CA415[TWA] FAIL|VM execution aborted|Script error", log, re.M)
    data = json.loads((W / (label + "-run.json")).read_text(encoding="utf-8-sig"))
    assert data["package_sha256"].lower() == sha
    for suffix in [".txt", "-run.json"]:
        target = H / "native" / (label + suffix)
        payload = (W / (label + suffix)).read_bytes()
        if target.exists():
            assert target.read_bytes() == payload
        else:
            target.write_bytes(payload)
    runs.append({"label": label, "results": [
        {"suite": suite, "passed": int(passed), "failed": 0} for suite, passed, _ in results]})
members = set(subprocess.check_output(
    ["git", "diff", "8aab788d", "--name-only", "--", "src"], cwd=R, text=True).splitlines())
members.update(subprocess.check_output(
    ["git", "ls-files", "--others", "--exclude-standard", "--", "src"], cwd=R, text=True).splitlines())
with zipfile.ZipFile(package) as archive:
    for member in members:
        assert archive.read(member[4:]) == (R / member).read_bytes(), member
report = {"issue": 415, "date": "2026-10-29", "runtime_sha256": sha,
          "verified_source_members": sorted(members), "runs": runs,
          "assertions": sum(x["passed"] for run in runs for x in run["results"]),
          "qualification": "Native departure/arrival integration for explicitly registered same-map thieves. Includes hub/save/load and preceding arrival-save compatibility. #417 survivors and regional access remain pending. No new resident behavior or author acceptance.",
          "liquid_scope": "Preserves existing temperature/clock state; no new historical fluid climate model is claimed.",
          "harness_corrections": "Initial synthetic positions intersected the fixture wall; corrected interior positions preserve collision constraints. Removed invalid vector-to-string diagnostic formatting. Failures remain private."}
(H / "theft-dispatch-results.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(json.dumps({"assertions": report["assertions"], "verified_members": len(members), "runtime_sha256": sha}))
