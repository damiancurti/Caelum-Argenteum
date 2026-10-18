"""Retain #327 functional evidence, including diagnosed fixture failures."""
from pathlib import Path
import gzip
import hashlib
import json
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue327-native'


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def main():
    out=HERE/'evidence';out.mkdir(exist_ok=True)
    records=[];fixtures={}
    for source in sorted(WORK.glob('*.json')):
        record=json.loads(source.read_text())
        if 'label' not in record:continue
        target=out/source.name;target.write_bytes(source.read_bytes())
        if source.name.endswith('-metadata-original.json'):continue
        label=record['label'];records.append(record)
        text=(WORK/f'{label}.txt').read_text(encoding='utf-8',errors='replace')
        for value in (str(ROOT),ROOT.as_posix()):text=text.replace(value,'<PROJECT>')
        for value in (r'C:\Program Files (x86)', 'C:/Program Files (x86)'):text=text.replace(value,'<PROGRAM_FILES>')
        (out/f'{label}.txt.gz').write_bytes(gzip.compress(text.encode(),mtime=0))
        script=WORK/label/'commands.cfg'
        if script.exists():
            assert digest(script.read_bytes())==record['commands_sha256']
            (out/f'{label}.cfg').write_bytes(script.read_bytes())
        fixture=WORK/label/'checks.pk3'
        if not fixture.exists() and label in ('geometry-01','portals-01'):
            fixture=WORK/'fixture-v1-recovered.pk3'
        if not fixture.exists():fixture=WORK/'siege-01/checks.pk3'
        assert digest(fixture.read_bytes())==record['fixture_sha256'],label
        fixtures[record['fixture_sha256']]=fixture
    for sha,source in fixtures.items():
        target=out/'fixtures'/sha;target.mkdir(parents=True,exist_ok=True)
        with zipfile.ZipFile(source) as z:
            for name in z.namelist():
                assert '/' not in name and '\\' not in name
                (target/name).write_bytes(z.read(name))
    for source in WORK.glob('geometry-*.png'):
        shutil.copyfile(source,out/source.name)
    passed=[r for r in records if r['exit_code']==0 and r['done'] and not r['failures']]
    failed=[r['label'] for r in records if r not in passed]
    result={'issue':327,'runtime_sha256':sorted({r['runtime_sha256'] for r in records}),
            'passed_runs':len(passed),'assertions':sum(r['passes'] for r in passed),
            'runs':records,'qualified_fixture_failures':failed,
            'limitations':'Functional fixtures only; no new FPS result, natural battle fluency or manual acceptance. No 6000 simultaneous test.'}
    (HERE/'NATIVE.json').write_text(json.dumps(result,indent=2)+'\n')
    manifest={p.relative_to(HERE).as_posix():digest(p.read_bytes()) for p in sorted(out.rglob('*')) if p.is_file()}
    (HERE/'EVIDENCE_SHA256.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(f"Archived {len(manifest)} artifacts; {len(passed)} passing runs, {result['assertions']} assertions; failures retained: {failed}")


if __name__=='__main__':main()
