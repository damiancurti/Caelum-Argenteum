"""Build deterministic isolated #158 probes; never modify author saves."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue158'

def package(path, source, handler):
    path.parent.mkdir(parents=True, exist_ok=True)
    members = {'MAPINFO': f'GameInfo {{ AddEventHandlers="{handler}" }}\n'.encode(),
               'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
               'checks.zs': (HERE / source).read_bytes()}
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, content in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), content)

def main():
    package(OUT/'checks.pk3', 'checks.zs', 'CA158Checks')
    package(OUT/'reload/checks.pk3', 'reload.zs', 'CA158Reload')
    package(OUT/'done/checks.pk3', 'reload_done.zs', 'CA158ReloadDone')
    for name, commands in {
        'baseline': 'wait 70; quit',
        'checks': 'wait 70; save ca158-active; wait 35; quit',
        'reload': 'wait 70; save ca158-complete; wait 35; quit',
        'done': 'wait 70; quit',
    }.items():
        (OUT/f'{name}.cfg').write_text('unbindall; '+commands+'\n', encoding='utf-8', newline='\n')
    print('Prepared isolated #158 native probes.')

if __name__ == '__main__':
    main()
