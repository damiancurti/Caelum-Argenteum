"""Preserve #309 results, failures and exact frozen-package provenance."""
from pathlib import Path
import hashlib
import json
import re

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
DIRECTORIES=('issue309-baseline01','issue309-baseline02','issue309-input01',
             'issue309-catalogue01','issue309-gauntlet02','issue309-verify01',
             'issue309-persist01','issue309-persist02','issue309-persist03','issue309-persist04',
             'issue309-legacy01','issue309-magic01','issue309-magic02','issue309-magic03')


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    report={'issue':309,'release':'5.5.0','runs':[]}
    for directory in DIRECTORIES:
        work=ROOT/'build'/directory
        if not work.exists():continue
        manifest=json.loads((work/'manifest.json').read_text(encoding='utf-8-sig'))
        for log in sorted(work.glob('*.txt')):
            raw=log.read_text(encoding='utf-8-sig')
            assertions=[line for line in raw.splitlines() if line.startswith('CA309 ')]
            errors=[line for line in raw.splitlines() if re.search(r'VM execution|FATAL ERROR|Cannot find savegame|Script error|Called from',line)]
            label=log.stem
            record=work/f'{label}-run.json'
            invocation=json.loads(record.read_text(encoding='utf-8-sig')) if record.exists() else None
            commands=work/f'{label}-commands.cfg'
            report['runs'].append(dict(directory=directory,label=label,
                source_commit=manifest['source_commit'],runtime_sha256=invocation['runtime_sha256'] if invocation else manifest['runtime_sha256'],
                frozen_runtime_sha256=manifest['runtime_sha256'],
                script_hashes=manifest.get('script_hashes',{}),
                fixture_sha256=manifest['fixture_sha256'],log_sha256=digest(log),
                commands_sha256=digest(commands) if commands.exists() else None,
                commands=commands.read_text(encoding='utf-8') if commands.exists() else None,
                completed=len(re.findall(r'^CA309 DONE passes=\d+ failures=0$',raw,re.M))==1
                    and not errors and 'CA309 FAIL' not in raw,
                errors=errors,assertions=assertions,invocation=invocation))
            if directory=='issue309-magic03' and report['runs'][-1]['completed']:
                actual=[tuple(map(int,row)) for row in re.findall(
                    r'^CA309 MAGIC type=(\d+) tier=(\d+) essence=(\d+) shots=(\d+)$',raw,re.M)]
                expected=[(kind,1,essence,12 if kind==17 else 1)
                          for kind in (1,17,18,19) for essence in range(5) for side in range(2)]
                expected += [(kind,1,0,12 if kind==17 else 1) for kind in (17,19) for side in range(2)]
                assert actual==expected,'Magic case order or coverage incomplete'
                assert 'CA309 DONE passes=440 failures=0' in raw
    current=ROOT/'build/issue309-persist03/manifest.json'
    if current.exists():
        hashes=json.loads(current.read_text(encoding='utf-8'))['source_hashes']
        report['final_source_hashes']={name:hashes[name] for name in (
            'caelum/equipment/CaelumPlayableWeapons.zs','caelum/equipment/CaelumWeaponCatalogue.zs',
            'caelum/player/CaelumPlayer.zs','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs')}
        for name,expected in report['final_source_hashes'].items():
            assert digest(ROOT/'src'/name)==expected,f'Final source changed: {name}'
    (HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f"Preserved {len(report['runs'])} runs; {sum(r['completed'] for r in report['runs'])} complete successful runs (includes expected-failure baselines).")


if __name__=='__main__':main()
