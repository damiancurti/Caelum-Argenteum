"""Collect the focused #414 native evidence, excluding superseded attempts."""
from pathlib import Path
import hashlib
import json
import shutil

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / "build/issue414"
LABELS = ["feasibility-02", "save-01", "load-01", "hub-01", "flow-save-02", "flow-load-01", "visual-02", "final-suite-01"]


def main():
    records = []
    native = HERE / "native"
    native.mkdir(exist_ok=True)
    for label in LABELS:
        log = (OUT / f"{label}.txt").read_text(encoding="utf-8-sig")
        run = json.loads((OUT / f"{label}-run.json").read_text(encoding="utf-8-sig"))
        count = sum(line.startswith("CA414 PASS ") for line in log.splitlines())
        assert count > 0 and "CA414 RESULT" in log and "CA414 FAIL" not in log, label
        assert run["exit_code"] == 0 and not run.get("timed_out"), label
        assert not any(s in log for s in ["Script error", "VM execution aborted", "Execution could not continue"]), label
        for suffix in [".txt", "-run.json"]:
            shutil.copyfile(OUT / f"{label}{suffix}", native / f"{label}{suffix}")
        records.append({"label": label, "pass": count, "exit_code": run["exit_code"],
                        "package_sha256": run["package_sha256"], "addon_sha256": run["addon_sha256"]})
    captures = HERE / "captures"
    captures.mkdir(exist_ok=True)
    for name in ["levels-before.png", "levels-after.png"]:
        shutil.copyfile(OUT / name, captures / name)
    result = {"issue": 414, "version": "5.8.0", "scope": "private feasibility prototype; production changes only synchronize two diagnostic release labels",
              "native_runs": records, "pass": sum(r["pass"] for r in records), "fail": 0,
              "quality_limitation": "existing reader returns -1; control-sector quality is 2; no mixing assertion",
              "superseded_attempts": {"feasibility-01": "last queued check needed a wait before quit",
                                      "visual-01": "camera framing improved",
                                      "flow-save-01": "runner rejected missing RESULT marker; corrected command script"},
              "author_acceptance": "pending CA414-PROTOTYPE-01"}
    (HERE / "report.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"runs": len(records), "pass": result["pass"], "fail": 0}))


if __name__ == "__main__":
    main()
