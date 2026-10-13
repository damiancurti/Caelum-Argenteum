"""Archive native logs/metadata and verify the exact delivered runtime payload."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT/'build/issue211'


def main():
    runs = []
    (HERE/'logs').mkdir(exist_ok=True)
    for record in sorted(WORK.glob('*-run.json')):
        item = json.loads(record.read_text(encoding='utf-8-sig'))
        label = item['label']
        log = WORK/f'{label}.txt'
        data = log.read_text(encoding='utf-8-sig') if log.exists() else ''
        data = data.replace(str(ROOT), '${ROOT}').replace(str(ROOT).replace('\\','/'), '${ROOT}')
        # Preserve raw local logs; archived text only normalizes trailing space.
        data = '\n'.join(line.rstrip() for line in data.splitlines())+'\n'
        (HERE/'logs'/log.name).write_text(data,encoding='utf-8',newline='\n')
        item['result_markers'] = re.findall(r'CA211 DONE failures=\d+ passes=\d+',data)
        item['log_sha256'] = hashlib.sha256((HERE/'logs'/log.name).read_bytes()).hexdigest()
        for key in ['arguments','initial_config']:
            item[key] = [v.replace(str(ROOT),'${ROOT}') for v in item[key]] if isinstance(item[key],list) else item[key]
        runs.append(item)
    (HERE/'runs.json').write_text(json.dumps(runs,indent=2)+'\n',encoding='utf-8')
    (HERE/'manifest.json').write_bytes((WORK/'manifest.json').read_bytes())
    with zipfile.ZipFile(WORK/'production.pk3') as tested, zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as delivered:
        assert set(tested.namelist()) == set(delivered.namelist()), 'Different package members'
        for name in tested.namelist():
            assert tested.read(name) == delivered.read(name), f'Different payload: {name}'
        matched = len(tested.namelist())
    source = {name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in [
        'src/caelum/player/CaelumPlayer.zs','src/caelum/actors/CaelumCombatActor.zs',
        'src/caelum/actors/CaelumBull.zs','src/caelum/actors/CaelumBullRules.zs',
        'src/caelum/core/CaelumImpactEnergy.zs','src/caelum/core/CaelumConstants.zs',
        'src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs']}
    (HERE/'package-check.json').write_text(json.dumps({'matched_members':matched,
        'official_sha256':hashlib.sha256((ROOT/'build/caelum_argenteum_dev.pk3').read_bytes()).hexdigest(),
        'runtime_sources':source},indent=2)+'\n',encoding='utf-8')
    if (WORK/'power-request.json').exists():
        (HERE/'power-request.json').write_bytes((WORK/'power-request.json').read_bytes())
    print(f'Archived {len(runs)} runs; all {matched} runtime members match the official build.')


if __name__ == '__main__':
    main()
