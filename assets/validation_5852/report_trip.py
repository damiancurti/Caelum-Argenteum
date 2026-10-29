"""Collect transport evidence without redistributing packages, saves or IWADs."""
from pathlib import Path
import hashlib
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / "build/issue416-network"
OUT = Path(__file__).resolve().parent
RUNS = {
    "trip-stop04": "Final full package: actual boarding, physiological clock, fixed safe stop and saved progress",
    "trip-resume03": "Final full package: saved resumption and arrival without duplicate payment",
    "trip-cycle02": "Saved interruption, paid reacquisition, reverse route and exact ground-pile persistence",
    "vehicles-ba03": "Native four-service footing and access in Buenos Aires",
    "vehicles-coast05": "Native four-service footing and access in Mar del Plata",
    "service-ship01": "Native ship timetable and arrival; earlier focused runtime checkpoint",
    "service-horse01": "Native horse arrival; earlier focused runtime checkpoint",
    "service-train01": "Native train timetable and arrival; earlier focused runtime checkpoint",
    "portstop01": "Actual ship exit at the intermediate Barracas port; earlier focused runtime checkpoint",
    "legacy-upgrade01": "Untouched 5.8.50 city save opens with new services and no old-map geometry change",
    "legacy-resume01": "Updated native city save reloads without repeated migration",
    "ticket-migration01": "Old paid ledger migrates idempotently to inactive revision two and resumes without payment",
    "long-train06": "Full twelve-hour railway journey with real provisions and retained survival",
}
rows = []
for label, purpose in RUNS.items():
    log = (WORK / f"{label}.txt").read_text(encoding="utf-8-sig")
    record = json.loads((WORK / f"{label}-run.json").read_text(encoding="utf-8-sig"))
    assert not re.search(r"CA\w+ FAIL|failed=[1-9]|VM execution aborted|Invalid state|Script error", log), label
    passed = len(re.findall(r"^CA\w+ PASS ", log, re.M))
    assert passed and (record.get("exit_code") == 0 or record.get("stopped_on_result")), label
    for suffix in (".txt", "-run.json"):
        shutil.copyfile(WORK / (label + suffix), OUT / (label + suffix))
    rows.append({"run": label, "purpose": purpose, "executed_assertions": passed,
                 "package_sha256": record["package_sha256"],
                 "log_sha256": hashlib.sha256((WORK / f"{label}.txt").read_bytes()).hexdigest()})
report = {"issue": 416, "date": "2026-10-29", "runs": rows,
          "qualification": "Native scenario assertions, including repeated setup; each run retains its own tested package hash. Earlier focused runs are identified, not relabeled as the final build. No author acceptance or presentation-FPS claim.",
          "long_trip": "The twelve-hour clock/provision fixture uses an allocated Toughness 100 character to isolate travel from the separately approved illness lethality. Unprotected controls died from retained disease after about 6.2 world hours; survival is not frozen. Its total elapsed test time is not rendering/FPS evidence.",
          "private_fixture_corrections": [
              "trip-cycle01 used a private save predating the unreleased service-sign class split; trip-stop03 regenerated it without changing any accepted save.",
              "long-train03 changed only live Toughness, which is rebuilt from saved character allocation on travel; the fixture now allocates the actual attribute.",
              "long-train04 inspected the final calendar tic before its queued native map transfer; the observer now waits for arrival finalization.",
              "long-train05 assumed final Hunger must fall despite automatic meals; the assertion now checks the actual food debit when a meal replenishes it."]}
(OUT / "trip-results.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(f"Collected {len(rows)} scoped native runs")
