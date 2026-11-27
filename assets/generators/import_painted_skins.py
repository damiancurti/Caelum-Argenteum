"""Install or verify the seven approved atlas corrections from the author's pinned art package."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path("assets/source/art/painted_skins_909/SOURCE.json")


def manifest(root):
    return json.loads((root/SOURCE).read_bytes())


def runtime_digest(source, path, original):
    """Honor a replacement only for the exact original export it was drawn for."""
    if path not in source["source_files"]:
        return original
    if original!=source["original_runtime_sha256"][path]:
        raise ValueError("Original export digest mismatch: "+path)
    return source["source_files"][path]


def validate(root):
    files = manifest(root)["source_files"]
    return ["Painted atlas is stale: "+p for p,expected in files.items()
            if not (root/"src"/p).is_file() or hashlib.sha256((root/"src"/p).read_bytes()).hexdigest()!=expected]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive",type=Path,help="Use a local copy of Caelum_pieles_pintadas.pk3.")
    parser.add_argument("--install",action="store_true",help="Reapply the exact reference after re-exporting original meshes.")
    args = parser.parse_args()
    source = manifest(ROOT)
    files = source["source_files"]
    if args.install:
        blob = (args.archive.read_bytes() if args.archive else subprocess.check_output(
            ["git","show",source["commit"]+":"+source["reference"]],cwd=ROOT))
        if hashlib.sha256(blob).hexdigest() != source["pk3_sha256"]:
            raise ValueError("The archive does not match the pinned author reference.")
        with zipfile.ZipFile(io.BytesIO(blob)) as package:
            by_path = {n.lower():n for n in package.namelist()}
            assets = {p:package.read(by_path[p.lower()]) for p in files}
        if any(hashlib.sha256(data).hexdigest()!=files[p] for p,data in assets.items()):
            raise ValueError("A reference atlas differs from its recorded digest.")
        for p,data in assets.items():
            (ROOT/"src"/p).write_bytes(data)
    errors = validate(ROOT)
    if errors:
        raise ValueError("\n".join(errors))
    print(f"{len(files)} exact author-supplied atlases verified")


if __name__=="__main__":
    main()

