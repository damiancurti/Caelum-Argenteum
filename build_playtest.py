"""Export a reviewed playtest commit without engine or IWAD files (#17, #82).

Uses committed bytes (not checkout line endings), stable archive metadata and
stored ZIP entries so reproduction does not depend on a compression library.
The output is intentionally larger than a compressed development package.
"""

import argparse
import hashlib
import os
import tempfile
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import zipfile


ROOT = Path(__file__).resolve().parent
STAMP = (1980, 1, 1, 0, 0, 0)
PK3_NAME = "caelum_argenteum_dev.pk3"  # Preserve the established save identity.


def git(*args, input=None):
    return subprocess.check_output(["git", "-C", str(ROOT), *args], input=input)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def json_bytes(value):
    return (json.dumps(value, indent=2, ensure_ascii=False, sort_keys=True) + "\n").encode("utf-8")


def zip_entry(name, size):
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts or "\\" in name or size <= 0:
        raise ValueError(f"Invalid or empty archive entry: {name}")
    info = zipfile.ZipInfo(name, STAMP)
    info.create_system = 3
    info.external_attr = 0o100644 << 16
    info.file_size = size
    return info


def committed_files(commit):
    # Use blob objects directly so export bytes are independent of checkout EOL.
    listing = git("ls-tree", "-r", "-z", commit, "--", "src", "README.md", "LICENSE.md", "assets/playtest")
    entries = {}
    for entry in listing.decode("utf-8").rstrip("\0").split("\0"):
        attributes, name = entry.split("\t", 1)
        mode, kind, oid = attributes.split()
        if kind != "blob" or mode not in {"100644", "100755"}:
            raise ValueError(f"Unsupported Git object: {name}")
        entries[name] = oid
    return entries


def copy_entry(archive, name, stream, size):
    checksum = hashlib.sha256()
    with archive.open(zip_entry(name, size), "w") as entry:
        remaining = size
        while remaining:
            chunk = stream.read(min(1024 * 1024, remaining))
            if not chunk:
                raise ValueError(f"Truncated input: {name}")
            entry.write(chunk)
            checksum.update(chunk)
            remaining -= len(chunk)
    return checksum.hexdigest()


def file_digest(path):
    with path.open("rb") as source:
        return hashlib.file_digest(source, "sha256").hexdigest()


def write_package(runtime, package):
    records = []
    with (
        zipfile.ZipFile(package, "w") as archive,
        subprocess.Popen(
            ["git", "-C", str(ROOT), "cat-file", "--batch"], stdin=subprocess.PIPE, stdout=subprocess.PIPE
        ) as reader,
    ):
        try:
            for name, oid in sorted(runtime.items()):
                reader.stdin.write((oid + "\n").encode("ascii"))
                reader.stdin.flush()
                header = reader.stdout.readline().split()
                if len(header) != 3 or header[:2] != [oid.encode("ascii"), b"blob"]:
                    raise ValueError(f"Git could not read {name}")
                size = int(header[2])
                checksum = copy_entry(archive, name, reader.stdout, size)
                if reader.stdout.read(1) != b"\n":
                    raise ValueError(f"Invalid Git blob boundary: {name}")
                records.append({"path": name, "size": size, "sha256": checksum})
        finally:
            reader.stdin.close()
            reader.stdout.close()
        if reader.wait():
            raise ValueError("Git could not finish reading the package")
    return records


def export(commit, output):
    ids = committed_files(commit)
    files = {
        name: git("cat-file", "blob", oid)
        for name, oid in ids.items()
        if not name.startswith("src/") or name.startswith("src/licenses/")
    }
    runtime = {name[4:]: oid for name, oid in ids.items() if name.startswith("src/")}
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=output) as temporary:
        return write_playtest(commit, output, Path(temporary), files, runtime)


def write_playtest(commit, output, temporary, files, runtime):
    readme = files["README.md"].decode("utf-8")
    version = re.search(r"Current release:\s*(\d+\.\d+\.\d+[a-z]?)", readme).group(1)
    settings = json.loads(files["assets/playtest/EXPORT.json"])
    start, end = "<!-- PLAYTEST_INSTRUCTIONS_BEGIN -->", "<!-- PLAYTEST_INSTRUCTIONS_END -->"
    if readme.count(start) != 1 or readme.count(end) != 1:
        raise ValueError("README must contain one playtest instruction section")
    instructions = readme.split(start, 1)[1].split(end, 1)[0].strip() + "\n"
    for name in runtime:
        if PurePosixPath(name).suffix.lower() in {".exe", ".dll", ".zip", ".pk3", ".ipk3"}:
            raise ValueError(f"Unexpected bundled dependency/archive: {name}")
        if name.lower().endswith(".wad") and name not in settings["runtime_maps"]:
            raise ValueError(f"Unapproved WAD: {name}")
    if sorted(name for name in runtime if name.lower().endswith(".wad")) != sorted(settings["runtime_maps"]):
        raise ValueError("Runtime map inventory differs from the reviewed export manifest")
    if not any(name.startswith("licenses/") for name in runtime):
        raise ValueError("Runtime license notices are missing")
    package = temporary / PK3_NAME
    records = write_package(runtime, package)
    package_hash = file_digest(package)
    manifest = {
        "version": version,
        "issue": settings["issue"],
        "source_commit": commit,
        "repository": "https://github.com/damiancurti/Caelum-Argenteum",
        "archive_format": "ZIP_STORED; sorted paths; 1980-01-01; Unix regular files 0644",
        "package": PK3_NAME,
        "package_sha256": package_hash,
        "runtime_file_count": len(runtime),
        "runtime_files": records,
        "export_settings": settings,
        "reproduce": f"git checkout {commit}\npython build_playtest.py --ref {commit} --output build/reproduced",
    }
    payload = {
        PK3_NAME: package,
        "PLAYTEST.txt": (f"Caelum Argenteum {version}\nSource commit: {commit}\n\n" + instructions).encode(
            "utf-8"
        ),
        "LICENSE.md": files["LICENSE.md"],
        "MANIFEST.json": json_bytes(manifest),
        "launch_playtest.ps1": files["assets/playtest/launch_playtest.ps1"],
        "launch_playtest.bat": files["assets/playtest/launch_playtest.bat"],
    }
    defaults = settings.get("default_controls_file")
    if defaults:
        if defaults != "default_controls.cfg":
            raise ValueError(f"Unapproved first-start configuration: {defaults}")
        payload[defaults] = files["assets/playtest/" + defaults]
    payload.update({name[4:]: data for name, data in files.items() if name.startswith("src/licenses/")})
    checksums = {name: (package_hash if name == PK3_NAME else digest(data)) for name, data in payload.items()}
    payload["SHA256SUMS.txt"] = "".join(
        f"{checksum}  {name}\n" for name, checksum in sorted(checksums.items())
    ).encode("ascii")
    name = f"caelum_argenteum_{version}_playtest.zip"
    bundle = temporary / name
    with zipfile.ZipFile(bundle, "w") as archive:
        for member, data in sorted(payload.items()):
            if member == PK3_NAME:
                with package.open("rb") as stream:
                    copy_entry(archive, member, stream, package.stat().st_size)
            else:
                archive.writestr(zip_entry(member, len(data)), data)
    checksum = file_digest(bundle)
    target = output / name
    try:
        if os.name == "nt":
            os.rename(bundle, target)  # Windows refuses an existing destination, including on exFAT.
        else:
            os.link(bundle, target)
    except FileExistsError:
        if file_digest(target) != checksum:
            raise ValueError(f"Refusing to overwrite a different export: {target}")
    sidecar = temporary / (name + ".sha256")
    sidecar.write_text(f"{checksum}  {name}\n", encoding="ascii", newline="\n")
    os.replace(sidecar, output / sidecar.name)
    return {
        "version": version,
        "commit": commit,
        "zip": str(target),
        "bytes": target.stat().st_size,
        "zip_sha256": checksum,
        "pk3_sha256": package_hash,
        "runtime_files": len(runtime),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ref", required=True, help="Commit/tag containing reviewed sources and instructions")
    parser.add_argument("--output", type=Path, default=ROOT / "build/playtest")
    args = parser.parse_args()
    commit = git("rev-parse", "--verify", "--end-of-options", args.ref + "^{commit}").decode().strip()
    print(json.dumps(export(commit, args.output.resolve()), indent=2))


if __name__ == "__main__":
    main()
