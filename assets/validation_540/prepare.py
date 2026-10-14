"""Build deterministic, isolated attribute-audit fixtures; no production edits."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def package(path, members):
    with zipfile.ZipFile(path, "w", zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--directory", default="issue237", help="Fresh directory name under build/.")
    args = parser.parse_args()
    if not args.directory or any(c not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_" for c in args.directory):
        parser.error("Use a plain directory name with letters, digits, hyphens or underscores.")
    out = ROOT / "build" / args.directory
    if out.exists():
        raise SystemExit("Preserve the existing issue237 packages; use a new evidence directory for a changed fixture.")
    out.mkdir(parents=True)
    manifest = {"source_commit": subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()}
    manifest["production_sha256"] = package(out / "production.pk3", {
        path.relative_to(ROOT / "src").as_posix(): path.read_bytes()
        for path in (ROOT / "src").rglob("*") if path.is_file()})
    manifest["fixture_sha256"] = package(out / "probe.pk3", {
        "ZSCRIPT": b'version "4.14"\n#include "checks/probe.zs"\n',
        "checks/probe.zs": (HERE / "probe.zs").read_bytes(),
        "MAPINFO": b'GameInfo { AddEventHandlers="CA237Probe" }\n'})
    (out / "probe.cfg").write_text(
        "wait 100; netevent c237_audit; wait 15; quit\n", encoding="utf-8")
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(manifest))


if __name__ == "__main__":
    main()
