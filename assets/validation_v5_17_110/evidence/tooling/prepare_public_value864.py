"""Publish portable reproductions without private packages or saved games."""
from pathlib import Path
import ast, re

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
helpers=Path(__file__).parent;dest=root/'assets/validation_v5_17_110';dest.mkdir(exist_ok=False)
source=(helpers/'run_value864_full.py').read_text(encoding='utf-8')
source,n=re.subn(r'^ROOT=Path\([^\n]+\)', 'ROOT=Path(__file__).resolve().parents[2]', source, count=1, flags=re.M);assert n==1
(dest/'run_value.py').write_text(source,encoding='utf-8',newline='\n')
source=(helpers/'prepare_value864_02.py').read_text(encoding='utf-8')
start=source.index("root = Path(");end=source.index('out.mkdir(exist_ok=False)',start)
source=source[:start]+'''import argparse
root = Path(__file__).resolve().parents[2]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--runtime', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args();runtime = a.runtime.resolve(strict=True);out = a.output.resolve()
out.relative_to(root/'build')
'''+source[end:]
anchor="excluded = ['Inventory', 'CaelumPlayer', 'CaelumCombatActor', 'CaelumStashChest']"
assert source.count(anchor)==1
source=source.replace(anchor,anchor+"\nassert ancestry('CaelumCombatActor') == ['CaelumCombatActor', 'Actor']\nfor other in ('Inventory', 'CaelumPlayer', 'CaelumStashChest'):\n    assert 'CaelumCombatActor' not in ancestry(other)")
(dest/'prepare_value.py').write_text(source,encoding='utf-8',newline='\n')
source=(helpers/'run_contact_scene864.py').read_text(encoding='utf-8')
source,n=re.subn(r'^root=Path\([^\n]+\)', 'root=Path(__file__).resolve().parents[2]', source, count=1, flags=re.M);assert n==1
source,n=re.subn(r'^layer=Path\([^\n]+\)\n', '', source, count=1, flags=re.M);assert n==1
source=source.replace("a=p.parse_args();logpath=", "p.add_argument('--presentation-layer',type=Path,required=True)\na=p.parse_args();layer=a.presentation_layer.resolve(strict=True);logpath=")
(dest/'run_scene.py').write_text(source,encoding='utf-8',newline='\n')
for p in dest.glob('*.py'):ast.parse(p.read_text(encoding='utf-8'))
(dest/'NATIVE_CONTRACT.txt').write_text('''#864 native contamination Value dispatch verification

Current release: inherited from repository README. Author acceptance remains pending.
Runtime, engine, IWAD, saves and test PK3/WAD files are local prerequisites and are not distributed here.

The prototype builder requires the immutable pre-change runtime (5.17.109),
produces one deterministic private source overlay in a fresh build/ directory,
and proves exclusive class ancestry plus exact preservation outside Value.
The final runtime includes that identical source and two release-string changes.

Example reproduction from repository root:
python assets/validation_v5_17_110/prepare_value.py --runtime build/issue861-hands01.pk3 --output build/repro864-prototype
python assets/validation_v5_17_110/run_value.py --runtime build/issue864-value03.pk3 --reference-runtime build/issue861-hands01.pk3 --output build/repro864-fresh

Use --candidate PATH for a private overlay, and --load PATH for the native saved
game emitted by a prior run. Preserve original saves. The same saved diagnostic
class names support baseline, upgrade, reload and direct baseline rollback.
The reference-runtime argument always selects the immutable old Value/Get code;
do not use the candidate itself as its independent reference.

The native matrix compares independent body records and exposure nodes, including
pending first-read settlement, equal/future timestamps and an old record revision.
Existing stack/vessel ownership tests are reused with their current schema constant.
Microbenchmarks alternate original/candidate order and report every measured class;
they measure repeated synchronous reads, not complete frame cost. Persistence seeds
deliberately isolate environmental exposure; first-read exposure effects are covered
separately by the paired matrix. This is not author confirmation of ordinary play.

Exact original-source sampled profiles reuse the retained tools:
assets/validation_v5_17_104/prepare_environment.py --deep (CA851 service labels)
assets/validation_v5_17_103/prepare_storage.py --types (CA849 type labels)
Their old diagnostic label names do not identify a different production runtime;
the manifests and native launch records identify the actual immutable input.

run_scene.py requires --label, --runtime and --presentation-layer; use --map MAP03
--siege for the approved normal deployment, --ground for the peaceful ground view,
or --map MAP01/MAP02 for reference entrances. --overlay and --types are diagnostic.
Its shared observer retains normal gameplay and records actual census and state.
Never use retired 6,000-attacker cases. One unpaused hidden engine at 5% audio only;
no simultaneous heavy builds, hashing or validation during presentation windows.
Queue-present intervals are application submissions, not monitor scanout. Tic
intervals include pacing and frame work. Sampled nested timers cannot be added.
Fixed entrances and bounded siege windows do not establish full-map fluency.
''',encoding='utf-8',newline='\n')
print('Prepared three portable scripts and the native contract.')
