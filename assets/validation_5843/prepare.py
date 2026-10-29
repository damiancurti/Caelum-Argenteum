"""Prepare deterministic private household-absence native fixtures."""
from pathlib import Path
import argparse
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue502-housekeeping'
BASE = ROOT.parent / 'issue502-furnishing-work/build/issue502-furnishing/final42a/caelum_argenteum_dev.pk3'

def pack(path, members):
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)

parser = argparse.ArgumentParser()
parser.add_argument('--probe', action='store_true')
args = parser.parse_args()
if args.probe:
    names = set(subprocess.check_output(['git', 'diff', '931bee7c', '--name-only', '--', 'src'], cwd=ROOT, text=True).splitlines())
    names.update(subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '--', 'src'], cwd=ROOT, text=True).splitlines())
    changed = {name[4:] for name in names}
    with zipfile.ZipFile(BASE) as archive:
        pack(WORK / 'probe/caelum_argenteum_dev.pk3', {
            name: (ROOT/'src'/name).read_bytes() if name in changed else archive.read(name)
            for name in set(archive.namelist()) | changed})
    print('Probe source changes:', len(changed))
checks = HERE/'away_checks.zs'
if checks.exists():
    common = {
        'ZSCRIPT': b'version "4.14"\n#include "prior.zs"\n#include "checks.zs"\n',
        'prior.zs': (ROOT/'assets/validation_5812/domestic_checks.zs').read_bytes().replace(b'CA502D ', b'CA502A '),
        'MAPINFO': b'GameInfo {AddEventHandlers="CA502AwayChecks"}\n',
    }
    source = checks.read_text(encoding='utf-8')
    pack(WORK/'checks.pk3', common | {'checks.zs': source.encode()})
    legacy = source
    for method in ['Away', 'Limbo', 'Repeat', 'Core', 'Shortages', 'ExtraHome', 'Multiple']:
        start = legacy.index('    void '+method+'(')
        brace = legacy.index('{', start)
        depth, end = 1, brace+1
        while depth:
            depth += (legacy[end]=='{')-(legacy[end]=='}')
            end += 1
        legacy = legacy[:start] + '    void '+method+'(CaelumPlayer u) {Check(true,"original runtime diagnostic loads");}\n' + legacy[end:]
    legacy = legacy.replace('CaelumHouseAwayWork.Civil(u)', 'CaelumScheduleState.Now(u)*3600.0/CaelumWorldClock.TicsPerHour()')
    pack(WORK/'legacy-checks.pk3', common | {'checks.zs': legacy.encode()})
    frames = (HERE/'frame_checks.zs').read_bytes()
    for name, body in [('frames', source), ('legacy-frames', legacy)]:
        pack(WORK/(name+'.pk3'), common | {
            'ZSCRIPT': common['ZSCRIPT']+b'#include "frames.zs"\n',
            'checks.zs': body.encode(), 'frames.zs': frames,
            'MAPINFO': b'GameInfo {AddEventHandlers="CA502AwayChecks","CA502AwayFrames"}\n',
        })
scripts = {
    'seed': 'wait 350; netevent ca502a_market; wait 3; changemap CAH000; wait 150; netevent ca502a_seed; wait 3; save away-home; wait 3; changemap MAP03; wait 100; netevent ca502a_work; wait 3; save away-active; wait 3; changemap CAH000; wait 150; netevent ca502a_back; wait 3; save away-back; wait 3; quit',
    'reload': 'wait 70; netevent ca502a_back; wait 3; quit',
    'limbo': 'wait 70; changemap MAP01; wait 100; netevent ca502a_limbo; wait 3; save away-limbo; wait 3; changemap CAH000; wait 150; netevent ca502a_back; wait 3; quit',
    'resume': 'wait 70; netevent ca502a_repeat; wait 3; changemap CAH000; wait 150; netevent ca502a_back; wait 3; quit',
    'core': 'wait 70; netevent ca502a_core; wait 3; quit',
    'shortages': 'wait 70; changemap MAP03; wait 100; netevent ca502a_shortages; wait 3; quit',
    'prior': 'wait 350; netevent ca502a_market; wait 3; changemap CAH000; wait 150; netevent ca502a_seed; wait 3; save home-prior42; wait 3; quit',
    'migration': 'wait 70; changemap MAP03; wait 100; netevent ca502a_work; wait 3; save away-migrated; wait 3; changemap CAH000; wait 150; netevent ca502a_back; wait 3; save home-migrated; wait 3; quit',
    'rollback': 'wait 70; netevent ca502a_back; wait 3; quit',
    'multiple': 'wait 70; changemap CAH001; wait 150; netevent ca502a_extra; wait 3; changemap MAP03; wait 100; netevent ca502a_multiple; wait 3; save away-multiple; wait 3; quit',
    'frames': 'wait 70; changemap MAP03; wait 885; quit',
}
for name, script in scripts.items():
    (WORK/(name+'.cfg')).write_text(script+'\n', encoding='utf-8')
print('Private household fixtures ready')
