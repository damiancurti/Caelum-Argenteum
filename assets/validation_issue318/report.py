"""Regenerate per-run tables and verify the delivered source/package fingerprints."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
def digest(data):return hashlib.sha256(data).hexdigest()
def number(value):return '-' if value is None else f'{value:.2f}'
directories=('issue318-audit-02','issue318-contact-01','issue318-contact-02')
lines=['Application-present intervals are ETW observations, not monitor refresh. '
       'N<30 is a short sample: tails are omitted here; raw descriptive quantiles '
       'remain in JSON. A transition stall may lie outside the trimmed ETW '
       'intervals; consult full native window/tic timestamps and raw CSV too.\n']
for directory in directories:
    results=json.loads((ROOT/'build'/directory/'analysis.json').read_text())
    lines+=['### '+directory,'','| Run | Window/process | Tics/s | App FPS | N | Mean ms | p95 ms | p99 ms | Max ms |',
            '| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |']
    for r in results:
        pm=r.get('presentmon',{});dt=pm.get('MsBetweenPresents',{});n=pm.get('sample_count',0)
        state='complete' if r.get('completed') else 'window complete / exit failed' if r.get('measurement_window_complete') else 'incomplete/failed'
        lines.append('| '+ ' | '.join([r['label'],state,number(r.get('tics_per_second')),
             number(pm.get('application_present_fps')),str(n),number(dt.get('mean')),
             number(dt.get('p95') if n>=30 else None),number(dt.get('p99') if n>=30 else None),number(dt.get('max'))])+' |')
    lines+=['']
final=json.loads((ROOT/'build/issue318-contact-02/analysis.json').read_text())
profile=next(r for r in final if r['label']=='army1000-final-profile')
lines+=['### Final 1,000-attacker profile','',
        f"{profile['profile_sample_tics']} sampled onset tics; inclusive/exclusive times include probe overhead. "
        'Do not add nested inclusive costs. No ElementalStream.Transfer call occurs in this window.','',
        '| Method | Inclusive ms/sample tic | Exclusive ms/sample tic | Calls/sample tic |',
        '| --- | ---: | ---: | ---: |']
selected=profile['profile'][:18]+[x for x in profile['profile'][18:] if 'BurnHeat' in x['name']]
for row in selected:lines.append(f"| {row['name']} | {row['inclusive_ms_per_sample_tic']:.4f} | {row['exclusive_ms_per_sample_tic']:.4f} | {row['calls_per_sample_tic']:.2f} |")
report=HERE/'RESULTS.md';text=report.read_text(encoding='utf-8')
text=re.sub(r'<!-- MEASUREMENTS_START -->.*?<!-- MEASUREMENTS_END -->',
            '<!-- MEASUREMENTS_START -->\n'+'\n'.join(lines)+'\n<!-- MEASUREMENTS_END -->',text,flags=re.S)
report.write_text(text,encoding='utf-8')

source={p.relative_to(ROOT/'src').as_posix():digest(p.read_bytes()) for p in sorted((ROOT/'src').rglob('*')) if p.is_file()}
package=ROOT/'build/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as z:packed={n:digest(z.read(n)) for n in z.namelist()}
assert source==packed,'Normal package differs from source'
with zipfile.ZipFile(ROOT/'build/issue318-functional-07/current/runtime.pk3') as z:
    tested={n:digest(z.read(n)) for n in z.namelist()}
assert source==tested,'Final native package differs from source'
with zipfile.ZipFile(ROOT/'build/issue318-functional-06/current/runtime.pk3') as z:
    earlier={n:z.read(n) for n in z.namelist()}
differences=[n for n,h in source.items() if digest(earlier[n])!=h]
labels=['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
assert sorted(differences)==sorted(labels)
for n in labels:assert earlier[n].replace(b'[Caelum 5.4.27]',b'[Caelum 5.4.28]')==(ROOT/'src'/n).read_bytes()
verification={'source_members':len(source),'normal_package_sha256':digest(package.read_bytes()),
 'source_tree_sha256':digest(json.dumps(source,sort_keys=True).encode()),
 'normal_package_matches_source':True,'final_native_package_matches_source':True,
 'functional06_to_final_changes':'Only two diagnostic release-label strings; exact replacement verified',
 'diagnostic_label_members':differences,'source_member_sha256':source}
(HERE/'PACKAGE_VERIFICATION.json').write_text(json.dumps(verification,indent=2)+'\n')
print('Verified',len(source),'members; final package',verification['normal_package_sha256'])
