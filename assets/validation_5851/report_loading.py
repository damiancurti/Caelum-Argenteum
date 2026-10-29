"""Archive final loading/save evidence and compare unchanged native outcomes."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HOME = Path(__file__).parent
WORK = ROOT / "build/issue415-rounds"
labels = ["load-day-baseline01", "load-day-current01", "retained-save01", "retained-load01",
          "retained-prior-arrival01", "retained-prior-theft01"]
runs = []
for label in labels:
    log = (WORK / (label + ".txt")).read_text(encoding="utf-8", errors="replace")
    assert not re.search(r"^CA415\w* FAIL|Script error|VM execution aborted", log, re.M), label
    results = re.findall(r"^CA415\w* RESULT passed=(\d+) failed=(\d+)", log, re.M)
    assert results and all(int(failed) == 0 for _, failed in results), label
    record = json.loads((WORK / (label + "-run.json")).read_text(encoding="utf-8-sig"))
    assert not record.get("timed_out") and (record["exit_code"] == 0 or record.get("stopped_on_result")), label
    frames = sorted(map(float, re.findall(r"^CA415A FRAME ([0-9.]+)", log, re.M)))
    timing = re.findall(r"^CA415A LOAD wall_ms=([0-9.]+)", log, re.M)
    outcomes = re.findall(r"^CA415A OUTCOME (.*)", log, re.M)
    row = {"label": label, "runtime_sha256": record["package_sha256"], "addon_sha256": record["addon_sha256"],
           "results": results, "outcomes": outcomes}
    if timing:
        row["loading_ms"] = float(timing[0])
        row["renderer_callback_intervals"] = {"count": len(frames), "p95_ms": frames[int(.95 * (len(frames)-1))],
                                               "p99_ms": frames[int(.99 * (len(frames)-1))], "maximum_ms": max(frames)}
    runs.append(row)
    for suffix in [".txt", "-run.json"]:
        target = HOME / "native" / (label + suffix)
        payload = (WORK / (label + suffix)).read_bytes()
        if target.exists():
            assert target.read_bytes() == payload, target
        else:
            target.write_bytes(payload)
assert runs[0]["outcomes"] == runs[1]["outcomes"] and runs[0]["outcomes"]
package = WORK / "probe/caelum_argenteum_dev.pk3"
source_count = 0
line_ending_only = []
release_label_only = []
with zipfile.ZipFile(package) as archive:
    for path in (ROOT / "src").rglob("*"):
        if path.is_file():
            name = path.relative_to(ROOT / "src").as_posix()
            packaged, source = archive.read(name), path.read_bytes()
            if name in {"caelum/world/CaelumPhysicalHazards.zs", "caelum/world/CaelumSewerMaze.zs"}:
                adjusted = source.replace(b"[Caelum 5.8.51]", b"[Caelum 5.8.50]")
                if source != adjusted:
                    release_label_only.append(name)
                    source = adjusted
            if packaged != source:
                assert b"\0" not in source and packaged.replace(b"\r\n", b"\n") == source.replace(b"\r\n", b"\n"), path
                line_ending_only.append(name)
            source_count += 1
report = {"version": "5.8.51", "issue": 415, "runs": runs,
          "loading_reduction_percent": (1-runs[1]["loading_ms"]/runs[0]["loading_ms"])*100,
          "verified_package_members": source_count, "runtime_sha256": hashlib.sha256(package.read_bytes()).hexdigest(),
          "source_checkout_line_ending_only": line_ending_only,
          "post_test_diagnostic_release_label_only": release_label_only,
          "performance_scope": "Paused actual city-day preparation. Individual outcomes unchanged; longer loading-screen callback tails. No presented-frame/FPS claim or new active-gameplay policy.",
          "preservation": "Native partial prepared-frame save/reload; preceding combat/theft partial-save fixtures. Prior 21 original 5.8.50 checks remain applicable to unchanged geometry/state aliases.",
          "prototype": "thermal_cache_prototype.zs is validation-only. 60 equivalence assertions; actual hour had 7614 hits / 194649 misses, insufficient benefit for production integration.",
          "author_acceptance": "Deferred to complete V5.8 grouped handoff. No pending author entry removed."}
(HOME / "loading-results.json").write_text(json.dumps(report, indent=2)+"\n", encoding="utf-8")
print(json.dumps({"reduction_percent": report["loading_reduction_percent"], "members": source_count, "native_runs": len(runs)}))
