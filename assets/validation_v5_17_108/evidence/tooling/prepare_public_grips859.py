"""Make the grip diagnostic reproducible and record inspected captures."""
from pathlib import Path
import hashlib,json
h=Path(__file__).resolve().parent;root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');dest=root/'assets/validation_v5_17_108'
s=(h/'grip_anchors859.py').read_text()
s=s.replace('import bpy,json','import argparse,bpy,json,sys')
s=s.replace("root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');art=", "root=Path(__file__).resolve().parents[2];art=")
s=s.replace("author=json.loads", "parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)\nargs=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);output=args.output.resolve();output.relative_to(root/'build');assert not output.exists();assert bpy.app.version==(4,5,3)\nauthor=json.loads",1)
s=s.replace("(root/'assets/validation_v5_17_108/grip_anchors.json').write_text",'output.write_text')
(dest/'build_grip_anchors859.py').write_text(s,encoding='utf-8',newline='\n')
p=dest/'run_grip_motion859.py';s=p.read_text();s=s.replace('argparse.ArgumentParser(description=__doc__)','argparse.ArgumentParser(description=__doc__,epilog="Shared runner arguments: --runtime PATH --output NEW_BUILD_DIRECTORY [--candidate PATH]. --focus supplies a close camera; omit it for full-body motion.")');p.write_text(s,encoding='utf-8',newline='\n')
(dest/'NATIVE_CONTRACT.txt').write_text('''Issue859 - finite first-body sword/shield grips

These are diagnostic tools, not the requested final consolidated author terminal.
Use local GZDoom4.14.2 and owned development dependencies. Run one native engine
at a time, unpaused in the background with5% audio. Every output directory must
be new and remain under build/. Private engines, IWADs, PK3s, WADs and saves are
not distributed. Existing default presentation and native gameplay are retained.

Pinned Blender4.5.3 source/export reproduction, from the repository root:
blender.exe --background --python assets/generators/author_equipment_grips.py -- --output build/grip-source-review
blender.exe --background --python assets/generators/export_equipment_grips.py -- --source build/grip-source-review/grips.blend --output build/grip-export-review
python assets/generators/build_equipment_grip_bindings.py --export build/grip-export-review --output build/grip-binding-review
The optional --install on the last tool deliberately updates candidate src files.
Independent source rebuilds yield identical native bytes. Retained .blend bytes
are provenance, not a claim that Blender container serialization is reproducible.
Compare exported counts/UVs/lengths and all375 samples, including evaluated
Solidify output. Preserve every original source/hash listed in DESIGN.json.

Native motion using actual equipped items:
python assets/validation_v5_17_108/run_grip_motion859.py --glove bare --runtime build/caelum_argenteum_dev.pk3 --output build/grip-motion-review
Repeat in fresh output folders with GF, GC, GW, GP. --focus Left or Right follows
the sampled grip center; omitted focus uses the full-body camera. Native trace
checks verify11 capture poses per run independently from ownership assertions.
Oblique close views may be occluded/misframed; canonical front views and the
full-body sequence are complementary. A capture assertion is not visual review.

Rebuild close-camera anchors without changing the retained file:
blender.exe --background --python assets/validation_v5_17_108/build_grip_anchors859.py -- --output build/grip-anchors-review.json
Compare that JSON byte-for-byte to grip_anchors.json. Anchors use the original
rig action samples; native camera positioning applies actor scale/yaw and
MD3 level.pixelstretch. No camera changes enter src or the packaged gameplay.

Continuity, ownership and paired presentation use the retained portable #857
run_wardrobe_continuity857.py and run_wardrobe_ownership857.py tools. Their
NATIVE_CONTRACT.txt explains modes/dependencies. #859's canonical13-phase plan,
actual commands, package hashes, raw engine traces and separate assertions are
archived in evidence/. Count actual PASS log lines, not saved handler counters.
Death/dead reload uses native -host 1; single-player dead saving stays disallowed.
For rollback disable the candidate, wait for native visual cleanup, save, then
load that cleaned save on the earlier complete runtime.

Performance windows compare5.17.107/108 with one actually equipped player in
studio/mansion/sewer/city views. Queue presents are not monitor scanout; tic
intervals include pacing/frame work. No heavy build/hash/validator overlaps the
measurements. These are not crowd, combat, full traversal or siege results.
The source/capture gallery and exact directly viewed-image list retain visual
limitations. Rejected initial exports/cameras remain labeled evidence. No
author acceptance is inferred; CA859-GRIP-01 waits for the final batch terminal.
''',encoding='utf-8',newline='\n')
p=root/'build/issue859-visual-review.json';d=json.loads(p.read_text());seen={r['path'] for r in d['directly_viewed']}
groups={'issue859-close-right04':['attack','guard','jump-air','landing','death'], 'issue859-close-bare-left01':['grip-front','run']}
for glove in ['gf','gc','gw','gp']:groups['issue859-close-'+glove+'-right01']=['grip-front','run']
for directory,names in groups.items():
 for name in names:
  f=root/'build'/directory/(name+'.png');relative=f.relative_to(root).as_posix()
  if relative not in seen:d['directly_viewed'].append({'path':relative,'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'final_evidence':True})
f=root/'build/issue859-close-right04/guard-grip.png';relative=f.relative_to(root).as_posix()
if relative not in seen:d['directly_viewed'].append({'path':relative,'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'final_evidence':False,'qualification':'Final runtime but oblique close view misses the hand; not contact evidence. The canonical guard.png was directly inspected and is usable.'})
d['notes'].append('Additional corrected close views inspected: bare Left idle/run, bare Right attack/guard/jump-air/landing/death, all4 Right glove idle/run. One oblique guard view is explicitly rejected as contact evidence.')
p.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8');print('Public contract and camera generator prepared;',len(d['directly_viewed']),'images directly reviewed.')
