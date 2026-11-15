"""Bound evidence reuse to the seven changed Chonchon death/rest model frames."""
from pathlib import Path
import argparse
import hashlib
import json
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
MODEL = 'models/caelum/folklore/heads/chonchon.md3'


def digest(blob):
    return hashlib.sha256(blob).hexdigest()


def split_model(blob):
    header = struct.unpack_from('<4sI64s9I', blob)
    frames = [[blob[header[8]+i*56:header[8]+(i+1)*56]] for i in range(header[4])]
    static = [blob[:header[8]]]
    offset = header[10]
    for _ in range(header[6]):
        surface = struct.unpack_from('<4s64s10I', blob, offset)
        static.append(blob[offset:offset+surface[10]])
        for i in range(surface[3]):
            start = offset+surface[10]+i*surface[5]*8
            frames[i].append(blob[start:start+surface[5]*8])
        offset += surface[-1]
    assert offset == len(blob)
    return static, frames


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['before', 'after', 'output']:
        parser.add_argument('--'+name, type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.relative_to(ROOT/'build')
    with zipfile.ZipFile(args.before) as before, zipfile.ZipFile(args.after) as after:
        assert set(before.namelist()) == set(after.namelist())
        changed = [n for n in sorted(before.namelist()) if before.read(n) != after.read(n)]
        assert changed == [MODEL], changed
        old_static, old_frames = split_model(before.read(MODEL))
        new_static, new_frames = split_model(after.read(MODEL))
        assert old_static == new_static
        changed_frames = [i for i, (a, b) in enumerate(zip(old_frames, new_frames)) if a != b]
        assert len(old_frames) == len(new_frames) == 23
        assert changed_frames == [12, 13, 14, 15, 16, 17, 22], changed_frames
        report = dict(issue=803, passed=True, before_sha256=digest(args.before.read_bytes()),
                      after_sha256=digest(args.after.read_bytes()), changed_members=changed,
                      changed_frames=changed_frames, native_topology_uv_bindings_unchanged=True,
                      other_runtime_and_art_bytes_identical=True,
                      reuse='Prior continuity, actions/loot, Umita captures and idle presentation measurements remain applicable to unchanged code, bindings and frames. Recheck final Chonchon death/rest captures in the engine; this audit is not author art acceptance.')
    out.write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8', newline='\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
