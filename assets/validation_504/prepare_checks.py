"""Package isolated owner, integration and observation fixtures deterministically."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue120'
OUT.mkdir(exist_ok=True)
def package(name,members):
    p=OUT/name;p.parent.mkdir(exist_ok=True,parents=True)
    with zipfile.ZipFile(p,'w',zipfile.ZIP_STORED) as z:
        for n,b in members.items():z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
for category,source,cls in [('player','validation_501/domain_checks.zs','CA117Checks'),('inventory','validation_502/inventory_checks.zs','CA118Checks'),('tarot','validation_503/tarot_checks.zs','CA119Checks'),('authority','validation_504/authority_checks.zs','CA120AuthorityChecks')]:
    package(category+'/checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
        'MAPINFO':f'GameInfo {{ AddEventHandlers = "{cls}" }}\n'.encode(),
        'checks.zs':(ROOT/'assets'/source).read_bytes()})
package('benchmark.pk3',{'ZSCRIPT':b'version "4.14"\n#include "benchmark.zs"\n#include "input_probe.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers = "CA116Benchmark", "CA116InputProbe" }\n',
    'benchmark.zs':(ROOT/'assets/validation_503/benchmark.zs').read_bytes(),
    'input_probe.zs':(ROOT/'assets/validation_500/input_probe.zs').read_bytes()})
for domain in ['player','inventory','tarot']:
    for label in ['baseline','current']:
        start='wait 105; '
        route='changemap MAP02; wait 35; changemap MAP06; wait 35; changemap MAP02; wait 70; '
        if domain in ['player','inventory']:route+='changemap MAP03; wait 70; '
        if domain=='tarot':route='changemap MAP02; wait 35; netevent ca119_capture_map; wait 5; changemap MAP06; wait 35; netevent ca119_capture_map; wait 5; changemap MAP02; wait 70; '
        (OUT/f'{domain}-{label}.cfg').write_text(start+f'save ca120_{domain}_{label}; wait 35; '+route+f'save ca120_{domain}_{label}_hub; wait 35; quit\n')
    (OUT/f'{domain}-reload.cfg').write_text(f'wait 105; save ca120_{domain}_upgraded; wait 35; quit\n')
package('projection/checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers = "CA116SnapshotChecks", "CA116ReloadObserver" }\n',
    'checks.zs':(ROOT/'assets/validation_500/snapshot_checks.zs').read_bytes()})
package('ui/checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "ui_observer.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers = "CA119Checks", "CA120UIObserver" }\n',
    'checks.zs':(ROOT/'assets/validation_503/tarot_checks.zs').read_bytes(),
    'ui_observer.zs':(HERE/'ui_observer.zs').read_bytes()})
(OUT/'ui-journal.cfg').write_text('wait 105; ca_journal_open true; ca_journal_page 6; ca_journal_tarot_selected 36\n')
package('creation.pk3',{'ZSCRIPT':b'version "4.14"\n#include "ui_probe.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers = "CA117UIProbe" }\n',
    'ui_probe.zs':(ROOT/'assets/validation_501/ui_probe.zs').read_bytes()})
for language in ['enu','es']:
    steps='wait 35; +forward; wait 10; -forward; +jump; wait 5; -jump; wait 30; '
    steps+='ca_journal_page 0; event ca_journal_toggle; wait 5; event ca_journal_toggle; wait 5; event ca117_open_creator; wait 5; '
    steps+='event ca117_creator_next; wait 5; '*5
    steps+='event ca117_creator_allocate; wait 5; event ca117_creator_next; wait 5; '
    steps+='event ca117_creator_allocate; wait 5; event ca117_creator_next; wait 5; '
    steps+='event ca117_creator_next; wait 5; event ca117_intro_next; wait 10; '
    steps+='closemenu; map MAP01; wait 105; '
    steps+=f'save ca120_created_{language}; wait 35; quit\n'
    (OUT/f'creation-{language}.cfg').write_text(steps)
(OUT/'projection-reload.cfg').write_text('wait 105; save ca120_projection_upgraded; wait 35; quit\n')
(OUT/'bots.cfg').write_text('wait 105; addbot; wait 210; quit\n')
(OUT/'reload.cfg').write_text('wait 105; save ca120_upgraded; wait 35; quit\n')
(OUT/'reload-only.cfg').write_text('wait 105; quit\n')
(OUT/'transactions.cfg').write_text('wait 105; netevent ca118_transactions; wait 35; quit\n')
(OUT/'pickups.cfg').write_text('wait 105; netevent ca118_pickups; wait 35; quit\n')
(OUT/'benchmark.cfg').write_text('wait 350; profilethinkers -t 20; wait 150; event ca116_probe; wait 25; profilethinkers -t 20; wait 175; profilethinkers -t 20; wait 300; event ca116_probe; wait 500; event ca116_probe; wait 250; quit\n')
(OUT/'benchmark-long.cfg').write_text((OUT/'benchmark.cfg').read_text().replace('wait 250; quit','wait 600; quit'))
print('Prepared authority, player, inventory, Tarot and matched observation addons')
