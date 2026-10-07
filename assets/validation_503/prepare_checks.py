"""Build deterministic native Tarot fixtures outside the shipping sources."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue119'
OUT.mkdir(exist_ok=True)
for name,cls in [('tarot_checks','CA119Checks'),('benchmark','CA116Benchmark')]:
    with zipfile.ZipFile(OUT/('checks.pk3' if name=='tarot_checks' else 'benchmark.pk3'),'w',zipfile.ZIP_STORED) as z:
        for path,data in {'ZSCRIPT':f'version "4.14"\n#include "{name}.zs"\n'.encode(),
                          'MAPINFO':f'GameInfo {{ AddEventHandlers = "{cls}" }}\n'.encode(),
                          name+'.zs':(HERE/(name+'.zs')).read_bytes()}.items():
            z.writestr(zipfile.ZipInfo(path,(2000,1,1,0,0,0)),data)
for label in ['baseline','current']:
    (OUT/f'{label}.cfg').write_text(f'wait 35; save ca119_{label}; wait 10; changemap MAP02; wait 35; netevent ca119_capture_map; wait 5; changemap MAP06; wait 35; netevent ca119_capture_map; wait 5; changemap MAP02; wait 70; save ca119_{label}_hub; wait 35; quit\n')
(OUT/'smoke.cfg').write_text('wait 10; quit\n')
(OUT/'reload.cfg').write_text('wait 105; netevent ca119_dump; wait 10; save ca119_upgraded; wait 35; quit\n')
(OUT/'reload-only.cfg').write_text('wait 105; netevent ca119_dump; wait 35; quit\n')
(OUT/'benchmark.cfg').write_text('wait 350; profilethinkers -t 20; wait 175; profilethinkers -t 20; wait 175; profilethinkers -t 20; wait 1050; quit\n')
for lang in ['enu','es']:
    (OUT/f'ui-{lang}.cfg').write_text('wait 35; ca_journal_open true; ca_journal_page 6; ca_journal_tarot_selected 0; wait 10; '
        f'screenshot "{(OUT/f"tarot-{lang}.png").as_posix()}"; ca_journal_open false; '
        'netevent ca119_match 0; wait 10; '
        f'screenshot "{(OUT/f"trucazo-{lang}.png").as_posix()}"; netevent ca119_match_hide; closemenu; '
        'netevent ca119_match 1; wait 10; '
        f'screenshot "{(OUT/f"truco-{lang}.png").as_posix()}"; netevent ca119_match_hide; closemenu; wait 5; quit\n')
for label in ['baseline','current']:
    for lang in ['enu','es']:
        (OUT/f'menus-{label}-{lang}.cfg').write_text('wait 105; netevent ca119_match 0; wait 35; '
            f'save ca119_{label}_tc; wait 35; screenshot "{(OUT/f"trucazo-{lang}.png").as_posix()}"; '
            'netevent ca119_match_hide; closemenu; wait 35; netevent ca119_match 1; wait 35; '
            f'save ca119_{label}_tr; wait 35; screenshot "{(OUT/f"truco-{lang}.png").as_posix()}"; '
            'netevent ca119_match_hide; closemenu; wait 35; quit\n')
for mode in ['tc','tr']:
    (OUT/f'menu-reload-{mode}.cfg').write_text('wait 105; '
        f'screenshot "{(OUT/f"loaded-{mode}.png").as_posix()}"; netevent ca119_match_hide; closemenu; wait 35; quit\n')
