"""Reuse legacy card regressions against #443 with current lifecycle checks."""
from pathlib import Path
import importlib.util
import json
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'assets/validation_v5_12_7'))
import native_sync

spec = importlib.util.spec_from_file_location('card_probe', ROOT / 'assets/validation_v5_12_5/run_card_probe.py')
probe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(probe)
original_fixture = probe.fixture
outputs = []

def fixture(path, *args, **kwargs):
    original_fixture(path, *args, **kwargs)
    with zipfile.ZipFile(path) as archive:
        members = {name: archive.read(name) for name in archive.namelist()}
    old = b"EventHandler.Find('CaelumSessionLifecycle')!=null"
    new = b"StaticEventHandler.Find('CaelumSessionLifecycleEvents')!=null"
    assert members['probe.zs'].count(old) <= 1
    members['probe.zs'] = members['probe.zs'].replace(old, new)
    members = native_sync.instrument(members)
    if '--source-overlay' in sys.argv:
        changed=subprocess.check_output(['git','diff','--name-only','--','src'],cwd=ROOT,text=True).splitlines()
        changed+=subprocess.check_output(['git','ls-files','--others','--exclude-standard','src'],cwd=ROOT,text=True).splitlines()
        for name in changed:
            if name=='src/ZSCRIPT':continue
            source=ROOT/name
            if source.is_file():members[str(source.relative_to(ROOT/'src')).replace('\\','/')]=source.read_bytes()
        rules='caelum/trucazo/CaelumTrucazoRules.zs'
        members[rules]=(ROOT/'src'/rules).read_bytes()+b'\n#include "caelum/data/CaelumTrucazoData.zs"\n#include "caelum/trucazo/CaelumTrucazoGame.zs"\n#include "caelum/trucazo/CaelumTrucazoGameMenu.zs"\n'
    with zipfile.ZipFile(path, 'w', compression=zipfile.ZIP_STORED) as archive:
        for name, content in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 8, 0, 0, 0)), content)
    outputs.append(path.parent)

probe.fixture = fixture
status = 0
try:
    probe.main()
except SystemExit as error:
    status = error.code or 0
finally:
    for directory in outputs:
        result = json.loads((directory / 'results.json').read_text())
        result['tested_release'] = '5.14.0'
        result['base_commit'] = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
        result['fixture_adaptation'] = 'Check the current static lifecycle bridge; instrument native sync without clearing it.'
        for peer in result['peers']:
            log = (directory / f"peer{peer['peer']}" / 'engine.log').read_text(errors='replace')
            peer['native_sync_clean'] = native_sync.clean(log)
            peer['passed'] = peer['passed'] and peer['native_sync_clean']
        result['passed'] = result['passed'] and all(peer['passed'] for peer in result['peers'])
        (directory / 'baseline-results.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
        print(json.dumps({'baseline_directory': str(directory), 'passed': result['passed'],
                          'native_sync_clean': [peer['native_sync_clean'] for peer in result['peers']]}))
        if not result['passed']:
            status = 1
raise SystemExit(status)
