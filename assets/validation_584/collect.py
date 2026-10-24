"""Verify packaged sources, repeat encoding, native playback and source identity."""
from pathlib import Path
import hashlib
import json
import zipfile

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue496'


def digest(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()


def main():
    provenance=json.loads((ROOT/'assets/source/audio/map_music_496/PROVENANCE.json').read_text(encoding='utf-8'))
    repeat=json.loads((WORK/'repeat/assets/source/audio/map_music_496/PROVENANCE.json').read_text(encoding='utf-8'))
    if provenance!=repeat:raise RuntimeError('Second encode was not byte-identical')
    for track in provenance['tracks']:
        for key,hash_key in [('source','source_sha256'),('runtime','runtime_sha256')]:
            if digest(ROOT/track[key])!=track[hash_key]:raise RuntimeError(f'Stale hash: {track[key]}')
    package=WORK/'current/caelum_argenteum_dev.pk3'
    expected={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(package) as archive:
        names=[n for n in archive.namelist() if not n.endswith('/')]
        if set(names)!=set(expected) or len(names)!=len(expected):raise RuntimeError('Package entry mismatch')
        for name,path in expected.items():
            if archive.read(name)!=path.read_bytes():raise RuntimeError(f'Package differs: {name}')
    log=(WORK/'playback-03.txt').read_text(encoding='utf-8-sig',errors='replace')
    run=json.loads((WORK/'playback-03-run.json').read_text(encoding='utf-8-sig'))
    if run['package_sha256'].lower()!=digest(package):raise RuntimeError('Native run used a different package')
    if 'CA496 RESULT played=19 failures=0' not in log or 'CA496 FAIL' in log:raise RuntimeError('Native playback incomplete')
    for track in provenance['tracks']:
        if f"{track['music_name']}" not in log:raise RuntimeError('Missing native track')
    report={'issue':496,'tracks':len(provenance['tracks']),'repeat_encoding_identical':True,
        'fully_decoded_tracks':19,'native_playback_passes':19,'source_entries_verified':len(expected),
        'package_sha256':digest(package),'total_seconds':sum(t['duration_seconds'] for t in provenance['tracks']),
        'source_bytes':sum(t['source_bytes'] for t in provenance['tracks']),
        'runtime_bytes':sum(t['runtime_bytes'] for t in provenance['tracks']),
        'author_acceptance':'Pending CA496-MUSIC-01; automatic start/decode does not establish listening acceptance.'}
    (ROOT/'assets/validation_584/report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,indent=2))


if __name__=='__main__':main()
