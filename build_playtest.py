"""Export issue #17 from an explicit Git commit, without engine or IWAD files.

Uses committed bytes (not checkout line endings), stable archive metadata and
stored ZIP entries so reproduction does not depend on a compression library.
The output is intentionally larger than a compressed development package.
"""

import argparse
import hashlib
import io
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


def archive_bytes(files):
    """Produce byte-identical ZIPs on supported Python versions/platforms."""
    output = io.BytesIO()
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_STORED) as archive:
        for name, data in sorted(files.items()):
            path = PurePosixPath(name)
            if path.is_absolute() or ".." in path.parts or "\\" in name or not data:
                raise ValueError(f"Invalid or empty archive entry: {name}")
            info = zipfile.ZipInfo(name, STAMP)
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            archive.writestr(info, data)
    return output.getvalue()


def committed_files(commit):
    # git archive can apply checkout conversions, including core.autocrlf.
    # Reading the blob objects directly makes the contract independent of Git config.
    listing = git("ls-tree", "-r", "-z", commit, "--", "src", "README.md", "LICENSE.md", "assets/playtest")
    members = []
    for entry in listing.decode("utf-8").rstrip("\0").split("\0"):
        attributes, name = entry.split("\t", 1)
        mode, kind, oid = attributes.split()
        if kind != "blob" or mode not in {"100644", "100755"}:
            raise ValueError(f"Non-regular export source: {name}")
        members.append((name, oid))
    objects = io.BytesIO(git("cat-file", "--batch", input="".join(oid + "\n" for _, oid in members).encode("ascii")))
    result = {}
    for name, expected_oid in members:
        oid, kind, size = objects.readline().decode("ascii").split()
        if oid != expected_oid or kind != "blob":
            raise ValueError(f"Unexpected Git object: {name}")
        result[name] = objects.read(int(size))
        if len(result[name]) != int(size) or objects.read(1) != b"\n":
            raise ValueError(f"Truncated Git object: {name}")
    return result


def export(commit, output):
    files = committed_files(commit)
    readme = files["README.md"].decode("utf-8")
    version = re.search(r"Current release:\s*(\d+\.\d+\.\d+[a-z]?)", readme).group(1)
    settings = json.loads(files["assets/playtest/EXPORT.json"])
    start, end = "<!-- PLAYTEST_INSTRUCTIONS_BEGIN -->", "<!-- PLAYTEST_INSTRUCTIONS_END -->"
    if readme.count(start) != 1 or readme.count(end) != 1:
        raise ValueError("README must contain one playtest instruction section")
    instructions = readme.split(start, 1)[1].split(end, 1)[0].strip() + "\n"
    runtime = {path[4:]: data for path, data in files.items() if path.startswith("src/")}
    for name in runtime:
        if PurePosixPath(name).suffix.lower() in {".exe", ".dll", ".zip", ".pk3", ".ipk3"}:
            raise ValueError(f"Unexpected bundled dependency/archive: {name}")
        if name.lower().endswith(".wad") and name not in settings["runtime_maps"]:
            raise ValueError(f"Unapproved WAD: {name}")
    if sorted(name for name in runtime if name.lower().endswith(".wad")) != sorted(settings["runtime_maps"]):
        raise ValueError("Runtime map inventory differs from the reviewed export manifest")
    if not any(name.startswith("licenses/") for name in runtime):
        raise ValueError("Runtime license notices are missing")
    package = archive_bytes(runtime)
    records = [{"path": name, "size": len(data), "sha256": digest(data)} for name, data in sorted(runtime.items())]
    manifest = {
        "version": version, "issue": 17, "source_commit": commit,
        "repository": "https://github.com/damiancurti/Caelum-Argenteum",
        "archive_format": "ZIP_STORED; sorted paths; 1980-01-01; Unix regular files 0644",
        "package": PK3_NAME, "package_sha256": digest(package),
        "runtime_file_count": len(runtime), "runtime_files": records,
        "export_settings": settings,
        "reproduce": f"git checkout {commit}\npython build_playtest.py --ref {commit} --output build/reproduced",
    }
    payload = {
        PK3_NAME: package,
        "PLAYTEST.txt": (f"Caelum Argenteum {version}\nSource commit: {commit}\n\n" + instructions).encode("utf-8"),
        "LICENSE.md": files["LICENSE.md"],
        "MANIFEST.json": json_bytes(manifest),
        "launch_playtest.ps1": files["assets/playtest/launch_playtest.ps1"],
        "launch_playtest.bat": files["assets/playtest/launch_playtest.bat"],
    }
    payload.update({name: data for name, data in runtime.items() if name.startswith("licenses/")})
    payload["SHA256SUMS.txt"] = "".join(f"{digest(data)}  {name}\n" for name, data in sorted(payload.items())).encode("ascii")
    bundle = archive_bytes(payload)
    name = f"caelum_argenteum_{version}_playtest.zip"
    output.mkdir(parents=True, exist_ok=True)
    target = output / name
    if target.exists() and target.read_bytes() != bundle:
        raise ValueError(f"Refusing to overwrite a different export: {target}")
    target.write_bytes(bundle)
    checksum = output / (name + ".sha256")
    checksum.write_text(f"{digest(bundle)}  {name}\n", encoding="ascii", newline="\n")
    return {"version": version, "commit": commit, "zip": str(target), "bytes": len(bundle),
            "zip_sha256": digest(bundle), "pk3_sha256": digest(package), "runtime_files": len(runtime)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ref", required=True, help="Commit/tag containing reviewed sources and instructions")
    parser.add_argument("--output", type=Path, default=ROOT / "build/playtest")
    args = parser.parse_args()
    commit = git("rev-parse", "--verify", "--end-of-options", args.ref + "^{commit}").decode().strip()
    print(json.dumps(export(commit, args.output.resolve()), indent=2))


if __name__ == "__main__":
    main()
