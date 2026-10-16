"""Record bounded native evidence, deterministic art and final package/source parity."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    cases = [
        ("issue284-final-02", "contract-01", "compound combat/personality contract"),
        ("issue284-final-02", "native-01", "native machete and projectile actions"),
        ("issue284-compat-01", "upgrade-02", "original-save migration"),
        ("issue284-compat-01", "reload-travel-01", "migrated-save reload and hub return"),
        ("issue284-author-01", "manual-smoke-01", "author controls with ordinary demon attributes"),
        ("issue284-author-02", "preview-01", "final front/side OBJ review"),
        ("issue284-legacy", "seed-01", "old-package save seed"),
        ("issue284-legacy", "rollback-02", "untouched old-save rollback"),
    ]
    runs = []
    for directory, label, scope in cases:
        folder = ROOT / "build" / directory
        log = folder / (label+".txt")
        text = log.read_text(encoding="utf-8-sig", errors="replace")
        assert "CA284 DONE failures=0" in text, log
        assert not re.search(r"CA284 FAIL|VM execution aborted|DIED WITH FATAL ERROR|Script error", text), log
        manifest = json.loads((folder / "manifest.json").read_text())
        runs.append({"stage": directory, "label": label, "scope": scope,
            "assertions_in_this_log": len(re.findall(r"^CA284 PASS ", text, re.M)),
            "log_sha256": sha(log), **manifest})
    generated = [ROOT / p for p in (
        "src/models/caelum/projectiles/ca_zupay_rock.obj", "src/MODELDEF",
        "src/graphics/caelum/zupay_rock.textures")]
    before = {p.relative_to(ROOT).as_posix(): sha(p) for p in generated}
    subprocess.run(["python", str(ROOT / "assets/generators/generate_zupay_rock.py")], check=True)
    assert before == {p.relative_to(ROOT).as_posix(): sha(p) for p in generated}
    with zipfile.ZipFile(ROOT / "build/caelum_argenteum_dev.pk3") as archive:
        expected = {p.relative_to(ROOT / "src").as_posix(): p.read_bytes()
                    for p in (ROOT / "src").rglob("*") if p.is_file()}
        assert set(archive.namelist()) == set(expected)
        assert all(archive.read(name) == value for name, value in expected.items())
    captures = {name: sha(ROOT / "build/issue284-author-02" / name)
                for name in ("rock-front.png", "rock-side.png")}
    result = {"issue": 284, "version": "5.4.24", "author_acceptance": "pending CA284-01",
        "native_runs": runs, "assertions": sum(run["assertions_in_this_log"] for run in runs),
        "current_runtime_sha256": sha(ROOT / "build/issue284-author-02/production.pk3"),
        "package_source_members": len(expected), "deterministic_art": before,
        "local_render_capture_sha256": captures,
        "scope_qualification": "Combat/action evidence predates only comment spelling and the cosmetic OBJ UV correction. The final visual run tests that correction. Save evidence covers unchanged personality/rock migration and serialization; later cold-defense and generic-prop combat changes do not execute in that frozen compatibility fixture. Old-package seed/rollback remain separate from current-runtime tests.",
        "preserved_iterations": ["issue284-01 initialization timing", "issue284-02/03 fixture evasion", "issue284-04 missing native shield item", "issue284-compat-01/upgrade-01 absolute save argument", "issue284-legacy/rollback-01 missing final marker", "issue284-preview-02/03 player-camera relocation", "issue284-preview-04 side UV stretching"]}
    (HERE / "evidence.json").write_text(json.dumps(result, indent=2)+"\n", encoding="utf-8")
    print(json.dumps({"assertions": result["assertions"], "runs": len(runs), "package_members": len(expected)}))

if __name__ == "__main__":
    main()
