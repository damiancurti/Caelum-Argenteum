#!/usr/bin/env python3
"""Build the deterministic source-only Caelum Argenteum 4.33.0c patch."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import subprocess
import sys
import zipfile
from pathlib import Path


FIXED_ZIP_TIME = (2026, 9, 9, 15, 0, 0)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_audit(project: Path):
    path = project / "tools/audit_4_33_0c.py"
    spec = importlib.util.spec_from_file_location("caelum_audit_4_33_0c", path)
    require(spec is not None and spec.loader is not None, "no se pudo cargar auditoría")
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
    parser.add_argument("--baseline-0b-runtime", type=Path, required=True)
    parser.add_argument("--full-runtime", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    baseline = args.baseline_0b_runtime.resolve()
    runtime = args.full_runtime.resolve()
    output = args.output.resolve()
    audit = load_audit(project)

    audit_command = [
        sys.executable,
        str(project / "tools/audit_4_33_0c.py"),
        "--project-root", str(project),
        "--baseline-0b-runtime", str(baseline),
        "--full-runtime", str(runtime),
    ]
    subprocess.run(audit_command, check=True)

    entries: dict[str, Path] = {
        f"src/{relative}": project / "src" / relative
        for relative in audit.RUNTIME_FILES
    }
    entries.update({relative: project / relative for relative in audit.PROJECT_FILES})
    require(set(entries) == audit.expected_package_entries(),
            "cambió el conjunto de entradas del paquete")
    require(all(path.is_file() for path in entries.values()),
            "falta una entrada del paquete")
    require(not any(name.lower().endswith(".pk3") for name in entries),
            "el paquete fuente no puede contener PK3")

    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", allowZip64=True) as archive:
        for name in sorted(entries):
            archive.writestr(
                zip_info(name),
                entries[name].read_bytes(),
                compress_type=zipfile.ZIP_DEFLATED,
                compresslevel=9,
            )

    subprocess.run(audit_command + ["--package", str(output)], check=True)
    print(f"Built source-only patch: {output}")
    print(f"Entries: {len(entries)}")
    print(f"Bytes: {output.stat().st_size}")
    print(f"SHA-256: {sha256(output)}")


if __name__ == "__main__":
    main()
