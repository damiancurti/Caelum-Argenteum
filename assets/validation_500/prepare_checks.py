"""Package native contract checks and console schedules outside src/."""
from pathlib import Path
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue116'
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as package:
    for name,data in {
        'ZSCRIPT':b'version "4.14"\n#include "snapshot_checks.zs"\n',
        'MAPINFO':b'GameInfo { AddEventHandlers = "CA116SnapshotChecks", "CA116ReloadObserver" }\n',
        'snapshot_checks.zs':(HERE/'snapshot_checks.zs').read_bytes(),
    }.items():
        package.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
(OUT/'checks.cfg').write_text('wait 35; save ca116_snapshot; wait 5; quit\n',encoding='utf-8')
(OUT/'reload.cfg').write_text('wait 35; quit\n',encoding='utf-8')
(OUT/'profile.cfg').write_text('wait 350; profilethinkers -t 20; wait 175; profilethinkers -t 20; wait 175; profilethinkers -t 20; wait 35; quit\n',encoding='utf-8')
(OUT/'baseline.cfg').write_text('wait 1750; quit\n',encoding='utf-8')
for language in ['enu','es']:
    capture=(OUT/f'journal-{language}.png').as_posix()
    tarot=(OUT/f'tarot-{language}.png').as_posix()
    (OUT/f'visual-{language}.cfg').write_text(
        f'wait 35; ca_journal_page 4; event ca_journal_toggle; wait 5; screenshot "{capture}"; '
        f'ca_journal_page 6; wait 5; screenshot "{tarot}"; wait 5; quit\n',encoding='utf-8')
print('Prepared checks and native profiler schedule')
with zipfile.ZipFile(OUT/'probe.pk3','w',zipfile.ZIP_STORED) as package:
    for name,data in {
        'ZSCRIPT':b'version "4.14"\n#include "benchmark.zs"\n#include "input_probe.zs"\n',
        'MAPINFO':b'GameInfo { AddEventHandlers = "CA116Benchmark", "CA116InputProbe" }\n',
        'benchmark.zs':(HERE/'benchmark.zs').read_bytes(),
        'input_probe.zs':(HERE/'input_probe.zs').read_bytes(),
    }.items():
        package.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
(OUT/'probe.cfg').write_text('wait 210; event ca116_probe; wait 175; event ca116_probe; wait 175; event ca116_probe; wait 70; quit\n',encoding='utf-8')
