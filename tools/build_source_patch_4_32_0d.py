#!/usr/bin/env python3
"""Build the deterministic, source-only Caelum Argenteum 4.32.0d patch."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import subprocess
import sys
import zipfile
from pathlib import Path


FIXED_ZIP_TIME = (2026, 9, 6, 12, 0, 0)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def sha256(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def load_audit(project: Path):
    audit_path = project / "tools/audit_4_32_0d.py"
    spec = importlib.util.spec_from_file_location("caelum_audit_4_32_0d", audit_path)
    require(spec is not None and spec.loader is not None, "cannot load audit module")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def zip_info(name: str) -> zipfile.ZipInfo:
    info = zipfile.ZipInfo(name, FIXED_ZIP_TIME)
    info.compress_type = zipfile.ZIP_DEFLATED
    info.create_system = 3
    info.external_attr = 0o100644 << 16
    return info


def write_entry(archive: zipfile.ZipFile, name: str, data: bytes) -> None:
    archive.writestr(
        zip_info(name), data, compress_type=zipfile.ZIP_DEFLATED,
        compresslevel=9,
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--baseline-runtime", type=Path, required=True)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    runtime = args.runtime_root.resolve()
    baseline = args.baseline_runtime.resolve()
    project = args.project_root.resolve()
    output = args.output.resolve()
    audit = load_audit(project)
    delta, _changed, _new, _icons = audit.expected_runtime_delta(project, baseline)

    subprocess.run([
        sys.executable, str(project / "tools/audit_4_32_0d.py"),
        "--runtime-root", str(runtime),
        "--baseline-runtime", str(baseline),
        "--project-root", str(project),
    ], check=True)

    entries: dict[str, Path] = {
        f"src/{relative}": runtime / relative for relative in delta
    }
    entries.update({relative: project / relative for relative in audit.PROJECT_FILES})
    require(all(path.is_file() for path in entries.values()), "a package input is missing")
    require(not any(name.lower().endswith(".pk3") for name in entries),
            "source package cannot contain a PK3")
    require(not any(name.startswith("build/") for name in entries),
            "source package cannot contain build output")

    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", allowZip64=True) as archive:
        for name in sorted(entries):
            write_entry(archive, name, entries[name].read_bytes())

    subprocess.run([
        sys.executable, str(project / "tools/audit_4_32_0d.py"),
        "--runtime-root", str(runtime),
        "--baseline-runtime", str(baseline),
        "--project-root", str(project),
        "--package", str(output),
    ], check=True)
    print(f"Built source-only patch: {output}")
    print(f"Entries: {len(entries)}")
    print(f"Bytes: {output.stat().st_size}")
    print(f"SHA-256: {sha256(output)}")


if __name__ == "__main__":
    main()

