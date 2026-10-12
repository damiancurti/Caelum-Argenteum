"""Retain sanitized native logs and fingerprints; never copy local dependencies."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue207'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    logs = HERE / 'logs'
    logs.mkdir(exist_ok=True)
    records = []
    for metadata in sorted(WORK.glob('*-run.json')):
        record = json.loads(metadata.read_text(encoding='utf-8-sig'))
        raw = (WORK / (record['label'] + '.txt')).read_bytes()
        text = raw.decode('utf-8-sig').replace('\r\n', '\n')
        text = re.sub(r'(?m)^adding .*[\\/]([^/\\]+), (\d+ lumps)$',
                      r'adding <local>/\1, \2', text)
        text = text.replace(str(ROOT).replace('\\', '/'), '<workspace>')
        text = text.replace(str(ROOT), '<workspace>')
        if re.search(r'[A-Za-z]:[\\/]', text):
            raise SystemExit(f'Unredacted absolute path in {record["label"]}.')
        retained = text.encode('utf-8')
        (logs / (record['label'] + '.txt')).write_bytes(retained)
        record['raw_log_sha256'] = sha(raw)
        record['retained_log_sha256'] = sha(retained)
        record['completion'] = re.findall(r'CA207 DONE failures=\d+ passes=\d+', text)
        record['native_assertion_failures'] = re.findall(r'(?m)^CA207 FAIL .+$', text)
        record['vm_abort'] = 'VM execution aborted' in text
        records.append(record)
    (HERE / 'runs.json').write_bytes((json.dumps(records, indent=2) + '\n').encode())
    sources = {'base_commit': '1bf5087e', 'source_sha256': {}}
    paths = [ROOT/'src/ZSCRIPT', ROOT/'src/caelum/core/CaelumConstants.zs',
             ROOT/'src/caelum/player/CaelumPlayer.zs', ROOT/'src/caelum/player/CaelumTutorialSafety.zs',
             ROOT/'src/caelum/player/CaelumPlayerResources.zs', ROOT/'src/caelum/survival/CaelumThermalService.zs',
             ROOT/'src/caelum/world/CaelumJourneyPlan.zs']
    paths += sorted(p for p in HERE.iterdir() if p.suffix in ('.py', '.ps1', '.zs', '.cfg'))
    for path in paths:
        sources['source_sha256'][path.relative_to(ROOT).as_posix()] = sha(path.read_bytes())
    sources['package_sha256'] = json.loads((WORK/'manifest.json').read_text())
    official = ROOT/'build/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(official) as built, zipfile.ZipFile(WORK/'production.pk3') as tested:
        assert set(built.namelist()) == set(tested.namelist()), 'Official membership mismatch'
        assert all(built.read(n) == tested.read(n) for n in built.namelist()), 'Official byte mismatch'
        sources['official_package'] = {'sha256': sha(official.read_bytes()),
                                       'members': len(built.namelist()),
                                       'all_members_equal_tested_runtime': True}
    (HERE/'hashes.json').write_bytes((json.dumps(sources, indent=2)+'\n').encode())
    print(f'Retained {len(records)} runs; official package matches every tested runtime member.')


if __name__ == '__main__':
    main()
