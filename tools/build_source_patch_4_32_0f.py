#!/usr/bin/env python3
"""Build the deterministic source-only Caelum Argenteum 4.32.0f patch."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import subprocess
import sys
import zipfile
from pathlib import Path


FIXED_ZIP_TIME = (2026, 9, 6, 20, 0, 0)


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
    audit_path = project / "tools/audit_4_32_0f.py"
    spec = importlib.util.spec_from_file_location("caelum_audit_4_32_0f", audit_path)
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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--baseline-0e", type=Path, required=True)
    parser.add_argument("--base-runtime", type=Path, required=True)
    parser.add_argument("--supplied-assets", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    baseline = args.baseline_0e.resolve()
    base_runtime = args.base_runtime.resolve()
    output = args.output.resolve()
    audit = load_audit(project)

    audit_command = [
        sys.executable,
        str(project / "tools/audit_4_32_0f.py"),
        "--project-root", str(project),
        "--baseline-0e", str(baseline),
        "--base-runtime", str(base_runtime),
    ]
    if args.supplied_assets is not None:
        audit_command.extend([
            "--supplied-assets", str(args.supplied_assets.resolve())
        ])
    subprocess.run(audit_command, check=True)

    entries: dict[str, Path] = {
        f"src/{relative}": project / "src" / relative
        for relative in audit.RUNTIME_FILES
    }
    entries.update({relative: project / relative for relative in audit.PROJECT_FILES})
    require(all(path.is_file() for path in entries.values()), "a package input is missing")
    require(set(entries) == audit.expected_package_entries(), "package input set changed")
    require(not any(name.lower().endswith((".pk3", ".wad")) for name in entries),
            "source package cannot contain compiled output")

    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", allowZip64=True) as archive:
        for name in sorted(entries):
            archive.writestr(
                zip_info(name),
                entries[name].read_bytes(),
                compress_type=zipfile.ZIP_DEFLATED,
                compresslevel=9,
            )

    subprocess.run(
        audit_command + ["--package", str(output)],
        check=True,
    )
    print(f"Built source-only patch: {output}")
    print(f"Entries: {len(entries)}")
    print(f"Bytes: {output.stat().st_size}")
    print(f"SHA-256: {sha256(output)}")


if __name__ == "__main__":
    main()
