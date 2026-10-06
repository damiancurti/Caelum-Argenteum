"""Deterministic native inventory fixtures; generated packages remain in build/."""
from pathlib import Path
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue118'
OUT.mkdir(exist_ok=True)

def package(name,members):
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as z:
        for path,data in members.items():
            z.writestr(zipfile.ZipInfo(path,(2000,1,1,0,0,0)),data)

package('checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "inventory_checks.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers = "CA118Checks" }\n',
    'inventory_checks.zs':(HERE/'inventory_checks.zs').read_bytes()})
package('benchmark.pk3',{'ZSCRIPT':b'version "4.14"\n#include "benchmark.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers = "CA116Benchmark" }\n',
    'benchmark.zs':(HERE/'benchmark.zs').read_bytes()})
for label in ['baseline','current']:
    (OUT/f'{label}.cfg').write_text(f'wait 35; save ca118_{label}; wait 5; changemap MAP02; wait 35; changemap MAP06; wait 35; changemap MAP02; wait 35; changemap MAP03; wait 35; save ca118_{label}_hub; wait 5; quit\n')
(OUT/'reload.cfg').write_text('wait 5; changemap MAP02; wait 35; changemap MAP03; wait 35; save ca118_upgraded; wait 5; quit\n')
(OUT/'reload-only.cfg').write_text('wait 35; quit\n')
(OUT/'ownership.cfg').write_text('wait 35; netevent ca118_ownership; wait 5; quit\n')
(OUT/'transactions.cfg').write_text('wait 35; netevent ca118_transactions; wait 5; quit\n')
(OUT/'pickups.cfg').write_text('wait 35; netevent ca118_pickups; wait 5; quit\n')
(OUT/'benchmark.cfg').write_text('wait 350; profilethinkers -t 20; wait 175; profilethinkers -t 20; wait 175; profilethinkers -t 20; wait 1050; quit\n')
for language in ['enu','es']:
    (OUT/f'ui-{language}.cfg').write_text(
        'wait 35; ca_journal_open true; ca_journal_page 0; netevent ca118_ui; wait 15; '
        f'screenshot "{(OUT/f"inventory-{language}.png").as_posix()}"; '
        'netevent ca_inventory_next; wait 10; '
        f'screenshot "{(OUT/f"selection-{language}.png").as_posix()}"; wait 5; quit\n')
