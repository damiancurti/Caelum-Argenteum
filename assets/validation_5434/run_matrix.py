"""Run one native engine at a time and verify actual autosave files, not just requests."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--long', action='store_true')
    parser.add_argument('--regressions', action='store_true')
    parser.add_argument('--legacy-save', type=Path)
    args = parser.parse_args()
    if not re.fullmatch(r'[a-z0-9_-]+', args.directory): parser.error('Plain lowercase directory required')
    out = ROOT/'build'/args.directory
    record_path=out/'files.json'
    records=json.loads(record_path.read_text()) if record_path.exists() else []

    def files():
        result = {}
        for path in sorted(out.glob('*.zds')):
            with zipfile.ZipFile(path) as archive: info = json.loads(archive.read('info.json'))
            result[path.name] = {'sha256':hashlib.sha256(path.read_bytes()).hexdigest(), 'map':info['Current Map']}
        return result

    def run(label, script=None, load=None, map_name='MAP99', writes=None, maps=None):
        before = files()
        command = ['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(ROOT/'assets/validation_5422/run_native.ps1'),
                   '-Directory',args.directory,'-Label',label,'-Script',script or label+'.cfg','-Map',map_name]
        if load: command += ['-LoadGame',load]
        process = subprocess.run(command, cwd=ROOT)
        after = files()
        log = (out/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
        saved = len(re.findall(r'^Game saved\.',log,re.M))
        changed = {name:item for name,item in after.items() if name.startswith('auto') and item != before.get(name)}
        record = {'label':label,'exit':process.returncode,'native_writes':saved,'before':before,'after':after,'changed_auto':changed}
        records.append(record)
        (out/'files.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
        assert process.returncode == 0, record
        if writes is not None: assert saved == writes, record
        if maps is not None: assert sorted(item['map'] for item in changed.values()) == sorted(maps), record
        return before, after

    if args.long:
        run('long',writes=1,maps=['MAP99'])
        run('load-long','load.cfg',load='auto01.zds',writes=0)
        return

    if args.regressions:
        run('direct-travel',writes=1,maps=['MAP98'])
        run('native-paused',writes=1,maps=['MAP99'])
        run('cancel-travel',writes=1,maps=['MAP98'])
        run('saved-travel',writes=1,maps=['MAP99'])
        run('late-travel',writes=1,maps=['MAP99'])
        run('late-invalid',writes=2,maps=['MAP99','MAP99'])
        run('consecutive',writes=2,maps=['MAP99','MAP99'])
        return

    run('timer',writes=1,maps=['MAP99'])
    run('load-timer','load.cfg',load='auto01.zds',writes=0)
    for label in ('pause','menu','console','checkpoint','defer','queued-death'):
        run(label,writes=1,maps=['MAP99'])
    run('travel',writes=1,maps=['MAP98'])
    run('travel-disabled',writes=0,maps=[])
    run('roundtrip',writes=2,maps=['MAP98','MAP99'])
    base=(out/'queued-travel.cfg').read_text()
    for delay in range(5):
        label=f'travel-delay{delay}'
        script=base.replace('wait 1; changemap',f'wait {delay}; changemap') if delay else base.replace('wait 1; changemap','changemap')
        if delay>=2: script=script.replace('event c324_saved;', 'event c324_saved 2;')
        (out/(label+'.cfg')).write_text(script,encoding='utf-8')
        run(label,writes=1 if delay<3 else 2,maps=['MAP98'] if delay<3 else ['MAP98','MAP99'])
    run('native',writes=1,maps=['MAP99'])
    run('one-slot',writes=2,maps=['MAP99'])
    run('fast',writes=0,maps=[])
    run('reload',writes=1,maps=['MAP99'])
    for label in ('disabled','zero-slots'):
        before,after=run(label,writes=0,maps=[])
        assert before==after, (label,before,after)
    run('manual-save',writes=1,maps=[])
    before,after=run('slots',writes=5,maps=['MAP99','MAP99'])
    assert before['manual.zds']==after['manual.zds']
    assert sorted(n for n in after if n.startswith('auto'))==['auto00.zds','auto01.zds']
    run('rulo',map_name='MAP01',writes=1,maps=['MAP01'])
    run('load-rulo','load.cfg',load='auto01.zds',writes=0)
    if args.legacy_save:
        (out/'legacy.zds').write_bytes(args.legacy_save.read_bytes())
        run('load-legacy','load.cfg',load='legacy.zds',map_name='MAP02',writes=0)

if __name__=='__main__': main()
