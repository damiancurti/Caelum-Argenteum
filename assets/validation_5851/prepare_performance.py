"""Build the authorized 1,000/600 catch-up fixture and optional prior runtime."""
import argparse
from pathlib import Path
import struct
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HOME = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue415-rounds'
parser = argparse.ArgumentParser()
parser.add_argument('--baseline', help='Git revision to reconstruct in baseline51')
parser.add_argument('--flights', action='store_true', help='Measure one pending volley on the authorized same population')
args = parser.parse_args()
running = subprocess.run(['powershell', '-NoProfile', '-Command',
    '(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'], capture_output=True, text=True)
if running.stdout.strip():
    raise SystemExit('Exit the native session before preparing archives.')


def pack(path, files):
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(files.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)


text = 'namespace="ZDoom";\n'
for x, y in [(-4096, -4096), (-4096, 4096), (4096, 4096), (4096, -4096)]:
    text += f'vertex {{x={x};y={y};}}\n'
for i in range(4):
    text += f'linedef {{v1={i};v2={(i+1)%4};sidefront={i};blocking=true;}}\n'
for i in range(4):
    text += 'sidedef {sector=0;texturemiddle="CMST01";}\n'
text += 'sector {heightfloor=0;heightceiling=256;texturefloor="CMST01";textureceiling="F_SKY1";lightlevel=192;}\n'
text += 'thing {x=-3900;y=-3900;type=1;angle=45;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;}\n'
wad = bytearray(b'PWAD' + struct.pack('<ii', 3, 0))
directory = []
for name, data in [(b'CABS415P', b''), (b'TEXTMAP', text.encode()), (b'ENDMAP', b'')]:
    directory.append((len(wad), len(data), name))
    wad.extend(data)
offset = len(wad)
for row in directory:
    wad.extend(struct.pack('<ii8s', *row))
struct.pack_into('<i', wad, 8, offset)
pack(WORK / ('flightperformance.pk3' if args.flights else 'performance.pk3'), {
    'ZSCRIPT': b'version "4.14.2"\n#include "checks.zs"\n#include "performance.zs"\n',
    'checks.zs': (HOME / 'checks.zs').read_bytes(),
    'performance.zs': (HOME / ('flightperformance.zs' if args.flights else 'performance.zs')).read_bytes(),
    'MENUDEF': b'ListMenu "CA415PerformanceMenu" {Class "CA415PerformanceMenu"}\n' if not args.flights else b'',
    'maps/CABS415P.wad': bytes(wad),
    'MAPINFO': b'GameInfo {AddEventHandlers="CA415Performance"}\nmap CABS415P "Absent combat performance" {cluster=8551 sky1="SKY1"}\n',
})
(WORK / 'perf.cfg').write_text('wait 200; quit\n', encoding='ascii')
(WORK / 'perfstaged.cfg').write_text('wait 1; netevent ca415perf_staged\n', encoding='ascii')
if args.baseline:
    changed = subprocess.check_output(['git', 'diff', args.baseline,
        '--name-only', '--', 'src'], cwd=ROOT, text=True).splitlines()
    with zipfile.ZipFile(WORK / 'probe/caelum_argenteum_dev.pk3') as current:
        files = {name: current.read(name) for name in current.namelist()}
    for name in changed:
        files[name[4:]] = subprocess.check_output(['git', 'show', args.baseline + ':' + name], cwd=ROOT)
    pack(WORK / 'baseline51/caelum_argenteum_dev.pk3', files)
    print(f'Prior runtime: {args.baseline}, {len(changed)} source replacements')
print('Prepared 1000 attackers / 600 defenders; no production map changes')
