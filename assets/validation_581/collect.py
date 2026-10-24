"""Collect bounded #413 native evidence, package identity and timing limits."""
from pathlib import Path
import hashlib
import json
import math
import re
import shutil
import statistics
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / "build/issue413"
FUNCTIONAL = ["final-suite-03", "final-migrate-01", "final-save-02", "final-load-02", "final-hub-02"]
CONTROLS = ["legacy-save-01", "rollback-01"]
PERFORMANCE = ["perf-baseline-city600-02", "perf-current-city600-02",
               "perf-baseline-city600-down", "perf-current-city600-down",
               "perf-baseline-mansion", "perf-current-mansion",
               "perf-baseline-sewer", "perf-current-sewer"]


def copy(name, folder):
    destination = HERE / folder / name
    destination.parent.mkdir(exist_ok=True)
    shutil.copy2(WORK/name, destination)
    return destination.relative_to(HERE).as_posix()


def checked(label):
    log = (WORK/f"{label}.txt").read_text(encoding="utf-8", errors="replace")
    record = json.loads((WORK/f"{label}-run.json").read_text(encoding="utf-8-sig"))
    assert record["exit_code"] == 0 and not record.get("timed_out"), label
    assert not re.search(r'CA413 FAIL|Script error|VM execution aborted|Execution could not continue|Fatal:|This savegame needs', log), label
    assert "CA413 RESULT" in log or "CA413 LEGACY" in log, label
    row = {"label": label, "pass": len(re.findall(r'^CA413 PASS ', log, re.M)),
           "package_sha256": record["package_sha256"].lower(),
           "addon_sha256": record["addon_sha256"].lower(),
           "artifacts": [copy(f"{label}.txt", "native"), copy(f"{label}-run.json", "native")]}
    return log, row


def main():
    runs = [checked(label)[1] for label in FUNCTIONAL+CONTROLS]
    timings = []
    for label in PERFORMANCE:
        log, row = checked(label)
        values = sorted(float(v) for v in re.findall(r'^CA413 FRAME ([\d.]+)', log, re.M))
        assert values, label
        start, end, tics = re.search(r'CA413 PERF start_ms=([\d.]+) end_ms=([\d.]+) tics=(\d+)', log).groups()
        living, dense = re.search(r'CA413 CENSUS living=(\d+) high_density=(\d+)', log).groups()
        row.update(samples=len(values), mean_ms=statistics.mean(values),
                   p95_ms=values[math.ceil(len(values)*.95)-1],
                   p99_ms=values[math.ceil(len(values)*.99)-1], worst_ms=max(values),
                   simulation_tics_per_second=int(tics)*1000/(float(end)-float(start)),
                   living_combatants=int(living), high_density=bool(int(dense)))
        row["presentation_artifacts"] = [copy(label+suffix, "native") for suffix in
            ("-presentmon.txt", "-presentmon-error.txt", "-presentmon.json")]
        if (WORK/f"{label}.csv").exists():
            row["presentation_artifacts"].append(copy(f"{label}.csv", "native"))
        timings.append(row)
    package = WORK / "current/caelum_argenteum_dev.pk3"
    with zipfile.ZipFile(package) as archive:
        files = {f.relative_to(ROOT/"src").as_posix(): f for f in (ROOT/"src").rglob('*') if f.is_file()}
        assert set(archive.namelist()) == set(files)
        for name, source in files.items():
            assert archive.read(name) == source.read_bytes(), name
    diagnostics = []
    for path in sorted(WORK.glob('*.txt')):
        if path.name.endswith(('presentmon.txt', 'presentmon-error.txt')):
            continue
        log = path.read_text(encoding='utf-8', errors='replace')
        metadata = path.with_name(path.stem+'-run.json')
        record = json.loads(metadata.read_text(encoding='utf-8-sig')) if metadata.exists() else {}
        if record.get('timed_out') or record.get('exit_code', 0) != 0 or re.search(r'CA413 FAIL|Script error|VM execution aborted|Fatal:|This savegame needs', log):
            diagnostics.append(copy(path.name, 'diagnostics'))
            if metadata.exists():
                diagnostics.append(copy(metadata.name, 'diagnostics'))
    result = {
        "issue": 413, "release": "5.8.1", "date": "2026-10-23",
        "package": {"entries": len(files), "all_entries_equal_src": True,
                    "sha256": hashlib.sha256(package.read_bytes()).hexdigest()},
        "native_runs": runs,
        "native_pass_assertions": sum(row['pass'] for row in runs),
        "functional_suite_assertions": runs[0]['pass'],
        "old_save_and_original_runtime_rollback": "passed; original save preserved",
        "ui_callback_timing": timings,
        "presentation": {"status": "unavailable", "reason": "PresentMon ETW access denied by Windows; no frame presentation/GPU claim"},
        "diagnostic_failures": diagnostics,
        "author_acceptance": "CA413-01 pending",
        "limits": ["UI callbacks are not application presents or GPU timing.",
                   "Fixed scenes are not whole-map or siege performance acceptance.",
                   "Save/hub checks precede a source-comment-only correction; final suite and timing use the complete final rebuild.",
                   "No unapproved underwater ability, card effect or mountain route profile is enabled."]}
    (HERE/'report.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({"assertions": result['native_pass_assertions'], "package": result['package'],
                      "timing": [{k:v for k,v in row.items() if k in ('label','mean_ms','p95_ms','p99_ms','worst_ms','living_combatants','high_density')} for row in timings]}, indent=2))


if __name__ == '__main__':
    main()
