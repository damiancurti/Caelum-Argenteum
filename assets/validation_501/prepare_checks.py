"""Build isolated, deterministic native fixtures and console schedules for #117."""
from pathlib import Path
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue117'
OUT.mkdir(exist_ok=True)


def package(name, members):
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as target:
        for path, data in members.items():
            target.writestr(zipfile.ZipInfo(path,(2000,1,1,0,0,0)),data)


package('checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "domain_checks.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers = "CA117Checks" }\n',
    'domain_checks.zs':(HERE/'domain_checks.zs').read_bytes()})
package('benchmark.pk3',{'ZSCRIPT':b'version "4.14"\n#include "benchmark.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers = "CA116Benchmark" }\n',
    'benchmark.zs':(ROOT/'assets/validation_500/benchmark.zs').read_bytes()})
package('ui.pk3',{'ZSCRIPT':b'version "4.14"\n#include "ui_probe.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers = "CA117UIProbe" }\n',
    'ui_probe.zs':(HERE/'ui_probe.zs').read_bytes()})
(OUT/'ui.cfg').write_text(
    'wait 35; bind TAB ca_journal_toggle; bind m togglemap; bind SPACE +jump; '
    'bind w +forward; bind F9 "openmenu CaelumNewCharacterMenu"; '
    f'bind F12 screenshot; screenshot_dir "{OUT.as_posix()}"\n',encoding='utf-8')
for label in ['baseline','current']:
    (OUT/f'{label}.cfg').write_text(
        f'wait 35; save ca117_{label}; wait 5; changemap MAP02; wait 35; '
        f'changemap MAP06; wait 35; changemap MAP02; wait 35; '
        f'changemap MAP03; wait 35; save ca117_{label}_hub; wait 5; quit\n',encoding='utf-8')
(OUT/'reload.cfg').write_text('wait 5; changemap MAP02; wait 35; changemap MAP03; wait 35; save ca117_upgraded; wait 5; quit\n',encoding='utf-8')
(OUT/'reload-only.cfg').write_text('wait 35; quit\n',encoding='utf-8')
(OUT/'benchmark.cfg').write_text('wait 1750; quit\n',encoding='utf-8')
(OUT/'benchmark-profile.cfg').write_text('wait 350; profilethinkers -t 20; wait 175; profilethinkers -t 20; wait 175; profilethinkers -t 20; wait 1050; quit\n',encoding='utf-8')
for language in ['enu','es']:
    def shot(name):
        return f'screenshot "{(OUT/f"{name}-{language}.png").as_posix()}"; wait 5; '
    steps='wait 35; +forward; wait 10; -forward; +jump; wait 5; -jump; wait 30; '
    steps+='ca_journal_page 0; event ca_journal_toggle; wait 5; '+shot('journal')
    steps+='event ca_journal_toggle; wait 5; event ca117_open_creator; wait 5; '+shot('creator-race')
    steps+='event ca117_creator_next; wait 5; '*5
    steps+='event ca117_creator_allocate; wait 5; event ca117_creator_next; wait 5; '
    steps+='event ca117_creator_allocate; wait 5; event ca117_creator_next; wait 5; '+shot('creator-summary')
    steps+='event ca117_creator_next; wait 5; event ca117_intro_next; wait 10; '+shot('introduction')
    # StartGameDirect requires a native menu input callback, not ConsoleProcess.
    # The console start below tests the real menu-produced draft at PostBeginPlay.
    steps+='closemenu; map MAP01; wait 70; '+shot('created-map01')
    steps+=f'save ca117_created_{language}; wait 5; quit\n'
    (OUT/f'ui-{language}.cfg').write_text(steps,encoding='utf-8')
print('Prepared native fixtures; production includes remain separate')
