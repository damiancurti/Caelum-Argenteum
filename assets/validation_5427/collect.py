"""Preserve escort tests and verify passing runs against the final production files."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directories', nargs='+', type=Path)
    parser.add_argument('--final', type=Path)
    args = parser.parse_args()
    destination = HERE / 'evidence'
    destination.mkdir(exist_ok=True)
    summary = []
    for directory in args.directories:
        runs = sorted(directory.glob('*-run.json'))
        labels = [p.name.removesuffix('-run.json') for p in runs]
        if labels:
            subprocess.run([sys.executable, str(HERE.parent / 'validation_5425/collect_evidence.py'),
                            str(directory), '--destination', str(destination), '--labels', *labels], check=True)
        for source in sorted(directory.glob('*.cfg')) + sorted(directory.glob('*manifest.json')):
            target = destination / (directory.name + '-' + source.name)
            data = source.read_bytes()
            if target.exists() and target.read_bytes() != data:
                raise SystemExit('Refusing to replace evidence: ' + str(target))
            target.write_bytes(data)
        for run in runs:
            record = json.loads(run.read_text(encoding='utf-8-sig'))
            log = run.with_name(run.name.replace('-run.json', '.txt')).read_text(encoding='utf-8-sig', errors='replace')
            item = {'directory': directory.name, 'label': record['label'],
                    'passes': len(re.findall(r'CA307 PASS', log)), 'failures': len(re.findall(r'CA307 FAIL', log)),
                    'exit_code': record['exit_code'], 'runtime_sha256': record['runtime_sha256'],
                    'fixture_sha256': record['fixture_sha256'], 'done': bool(re.search(r'CA307 DONE passes=\d+ failures=0\b', log))}
            summary.append(item)
            if args.final and directory.resolve() == args.final.resolve():
                assert item['done'] and item['failures'] == 0 and item['exit_code'] == 0, item
    result = {'runs': summary}
    if args.final:
        runtime = args.final / 'production.pk3'
        with zipfile.ZipFile(runtime) as archive:
            sources = {p.relative_to(ROOT / 'src').as_posix(): p for p in (ROOT / 'src').rglob('*') if p.is_file()}
            assert set(archive.namelist()) == set(sources)
            mismatches = [name for name, source in sources.items() if source.read_bytes() != archive.read(name)]
            assert not mismatches, mismatches
            result['identical_runtime_members'] = len(sources)
            with zipfile.ZipFile(ROOT / 'build/issue305-02/production.pk3') as previous:
                changed = [name for name in sources if archive.read(name) != previous.read(name)]
                expected = {'caelum/actors/CaelumAnchoredResident.zs', 'caelum/actors/CaelumPrisoners.zs',
                            'caelum/core/CaelumConstants.zs', 'caelum/world/CaelumPhysicalHazards.zs',
                            'caelum/world/CaelumSewerMaze.zs'}
                assert set(changed) == expected, changed
                result['changed_runtime_members'] = sorted(changed)
            with zipfile.ZipFile(ROOT / 'build/caelum_argenteum_dev.pk3') as development:
                assert set(development.namelist()) == set(sources)
                assert all(development.read(name) == archive.read(name) for name in sources)
                result['development_package_matches_tested_runtime'] = True
        with zipfile.ZipFile(args.final / 'escort.pk3') as fixture:
            assert fixture.read('escort.zs') == (HERE / 'escort.zs').read_bytes()
            result['fixture_matches_final_probe_source'] = True
        result['final_runtime_sha256'] = hashlib.sha256(runtime.read_bytes()).hexdigest()
        final_runs = [r for r in summary if r['directory'] == args.final.name]
        assert all(r['runtime_sha256'].lower() == result['final_runtime_sha256'] for r in final_runs)
        result['final_passes'] = sum(r['passes'] for r in final_runs)
    (HERE / 'RESULTS.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    brief = {key: value for key, value in result.items() if key != 'runs'}
    brief['preserved_runs'] = len(summary)
    print(json.dumps(brief, indent=2))


if __name__ == '__main__':
    main()
