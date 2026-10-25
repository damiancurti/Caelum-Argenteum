"""Retain focused equipment-cleaning evidence and check its packaged source."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

here = Path(__file__).resolve().parent
root = here.parents[1]
work = root / 'build/issue502-hygiene'
out = here / 'cleaning'
labels = ['clean-final05-core-b', 'clean-dev03-sleep-b', 'clean-final04-repair',
          'clean-dev03-bag', 'clean-dev03-save', 'clean-dev03-load',
          'clean-dev03-live', 'clean-dev03-hub', 'clean-dev03-legacy',
          'clean-final04-capture', 'clean-final04-bath', 'clean-final04-toilet', 'clean-final06-keys']
package = work / 'clean-final06/caelum_argenteum_dev.pk3'
digest = hashlib.sha256(package.read_bytes()).hexdigest()
records = []
verified_runtimes = {}
(out / 'native').mkdir(parents=True, exist_ok=True)
for label in labels:
    log = (work / (label + '.txt')).read_text(encoding='utf-8', errors='replace')
    assert not re.search(r'CA502H FAIL|Script error|VM execution aborted|failures=[1-9]', log), label
    assert 'CA502H RESULT' in log, label
    record = json.loads((work / (label + '-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code'] == 0 and not record.get('timed_out'), label
    if record['runtime'] not in verified_runtimes:
        with zipfile.ZipFile(package) as final, zipfile.ZipFile(work / record['runtime'] / 'caelum_argenteum_dev.pk3') as tested:
            tested_names = set(tested.namelist())
            differences = [n for n in final.namelist() if n not in tested_names or final.read(n) != tested.read(n)]
            model = 'caelum/world/CaelumTimeSkipModel.zs'
            ui = {'caelum/ui/CaelumLiveMenu.zs', 'caelum/ui/CaelumLiveMenuControls.zs'}
            assert set(differences) <= {model} | ui, (label, differences)
            if model in differences:
                name = model
                guard = b'            if(!CaelumCleaningSupplies.Cloth(user)){Reason="CA_SKIP_PROVISIONS";Done=true;}\n'
                assert final.read(name).replace(guard, b'') == tested.read(name), label
            with zipfile.ZipFile(work / 'clean-final05/caelum_argenteum_dev.pk3') as before_shortcuts:
                for name in set(differences) & ui:
                    assert tested.read(name) == before_shortcuts.read(name), (label, name)
        verified_runtimes[record['runtime']] = differences
    differences = verified_runtimes[record['runtime']]
    records.append({'label': label, 'passes': len(re.findall(r'^CA502H PASS', log, re.M)),
                    'package_sha256': record['package_sha256'].lower(), 'final_runtime_differences': differences})
    for suffix in ('.txt', '-run.json'):
        shutil.copyfile(work / (label + suffix), out / 'native' / (label + suffix))
with zipfile.ZipFile(package) as current, zipfile.ZipFile(work / 'bath-final05/caelum_argenteum_dev.pk3') as baseline:
    for name in current.namelist():
        assert current.read(name) == (root / 'src' / name).read_bytes(), name
    maps = [n for n in current.namelist() if n.startswith('maps/')]
    art = [n for n in current.namelist() if n.startswith(('sprites/', 'models/', 'graphics/', 'textures/', 'flats/'))]
    for name in maps + art:
        assert current.read(name) == baseline.read(name), name
    count = len(current.namelist())
(out / 'captures').mkdir(exist_ok=True)
for name in ('clean-menu.png', 'clean-live.png'):
    shutil.copyfile(work / name, out / 'captures' / name)
report = {
    'issue': 502, 'version': '5.8.12', 'passes': sum(r['passes'] for r in records), 'runs': records,
    'source_members': count, 'unchanged_maps': len(maps), 'unchanged_art_members': len(art),
    'package_sha256': digest, 'author_test': 'CA502-CLEAN-01 accepted 2026-10-25',
    'retained_prior_runs': ['clean-dev03-core: superseded by the final missing-cloth core check; excluded from the selected total'],
    'limits': ['Voluntary sleep only; calendar-triggered and exhaustion sleep scheduling remain follow-up.',
               'Exact-date forecast supports one piece; the queue followed by sleep retains the explicit unsupported-effect guard.',
               'Repair tests seed a native repair-completion state; they validate the completion hook, not the earlier recipe UI.',
               'Functional native checks, not multiplayer or frame-presentation acceptance.'],
    'resolved_probes': ['Test fixture passed an actor where the item-lock API requires ItemId.',
                        'Box-preservation fixture initially lacked ownership of the Box; use the actual grant API.',
                        'Repeated sleep fixture must restore its synthetic armor equipment slot after profile reconciliation.',
                        'Late-cloth forecast fixture also clears accumulated thermal exposure to isolate the supply guard.'],
}
(out / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
print(json.dumps({k: report[k] for k in ('passes', 'source_members', 'unchanged_maps', 'unchanged_art_members', 'package_sha256')}, indent=2))
