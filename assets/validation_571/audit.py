"""Audit #404 resource data against the existing runtime without changing it."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent


def read(relative):
    return (ROOT / relative).read_text(encoding="utf-8")


def main():
    catalog = json.loads(read("assets/generators/resource_catalog.json"))
    constants = read(catalog["baseline_authorities"]["materials"])
    ids = {key: int(value) for key, value in re.findall(
        r"const (MATERIAL_\w+) = (\d+);", constants)}
    economy = read(catalog["baseline_authorities"]["raw_prices"])
    prices = {key: float(value) for key, value in re.findall(
        r"case CaelumConstants\.(MATERIAL_\w+): return ([\d.]+);", economy)}
    assert ids["MATERIAL_COTTON"] == 72 and ids["MATERIAL_COAL"] == 61
    assert ids["MATERIAL_CARBINE_KIT"] == 79 and ids["MATERIAL_SHOTGUN_KIT"] == 80
    assert ids["MATERIAL_TYPE_COUNT"] == 81, "#404 must not append runtime identities"
    assert catalog["unit_kg"] == float(re.search(
        r"const MATERIAL_UNIT_WEIGHT = ([\d.]+);", constants)[1])
    assert catalog["recovery_fraction_per_game_day"] == float(re.search(
        r"const NATURAL_RESOURCE_RECOVERY_PER_GAME_DAY = ([\d.]+);", constants)[1])
    veins = read("src/caelum/world/CaelumMineralVeins.zs")
    observed = []
    pattern = (r"class (CaelumVein\w+) : CaelumMineralVeinEnvironmentProp\s*\{"
               r".*?return CaelumConstants\.(MATERIAL_\w+);.*?"
               r"GetResourceHardness\(\) \{ return ([\d.]+); \}.*?"
               r"GetResourceAbundance\(\) \{ return ([\d.]+); \}")
    for actor, material, hardness, abundance in re.findall(pattern, veins, re.S):
        observed.append(dict(actor=actor, material=material, material_id=ids[material],
                             hardness=float(hardness), abundance=float(abundance),
                             copper_per_gram=prices[material]))
    assert len(observed) == 11
    keys = [row["key"] for row in catalog["sources"] + catalog["processing"]]
    assert len(keys) == len(set(keys))
    assert len(catalog["sources"]) == 7
    for row in catalog["sources"]:
        assert row["capacity_g"] > 0 and row["consumers"]
        assert row["slice_access"] in ("MAP03_import", "MAP03_local_MAP01_decorative")
        if row["material_constant"]:
            assert row["material_constant"] in ids
    systems = read("docs/SYSTEMS.md")
    for row in observed:
        expected = f'| {row["material_id"]} | {row["material"][9:]} | {row["hardness"]:g} | {row["abundance"]:g} | {row["copper_per_gram"]:g} |'
        assert expected in systems, expected
    for row in catalog["sources"]:
        assert f'| `{row["key"]}` | {row["capacity_g"]} |' in systems
    # This issue changes no gameplay bytes; only the required release diagnostics.
    changed = subprocess.check_output(
        ["git", "diff", "feat/issue408-water-quality", "--name-only", "--", "src"],
        cwd=ROOT, text=True).splitlines()
    permitted = {"src/caelum/world/CaelumSewerMaze.zs",
                 "src/caelum/world/CaelumPhysicalHazards.zs"}
    assert set(changed) <= permitted, changed
    for name in changed:
        old = subprocess.check_output(
            ["git", "show", f"feat/issue408-water-quality:{name}"], cwd=ROOT)
        assert old.replace(b"[Caelum 5.7.0]", b"[Caelum 5.7.1]").replace(b"\r\n", b"\n") == (ROOT/name).read_bytes().replace(b"\r\n", b"\n")
    authority_paths = sorted(set(catalog["baseline_authorities"].values())
                             | {"assets/generators/resource_catalog.json",
                                "src/caelum/world/CaelumMineralVeins.zs"})
    validation = subprocess.run([sys.executable, "validate_project.py"], cwd=ROOT,
                                capture_output=True, text=True, encoding="utf-8")
    assert validation.returncode == 0, validation.stdout + validation.stderr
    (OUT/"project-validation.json").write_text(validation.stdout, encoding="utf-8")
    report = {"issue": 404, "version": "5.7.1", "status": "pass",
              "existing_mineral_families": observed, "approved_source_rows": 7,
              "processing_or_marine_rows": len(catalog["processing"]),
              "gameplay_changed": False, "native_test": "Not required for data/documentation-only scope",
              "source_hashes": {p: hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
                                for p in authority_paths}}
    (OUT/"report.json").write_text(json.dumps(report, indent=2)+"\n", encoding="utf-8")
    print("PASS #404: 11 existing mineral families, 7 approved sources, unchanged gameplay.")


if __name__ == "__main__":
    main()
