"""Record completed paired observations before the full validator."""
from pathlib import Path
import hashlib,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
assert (root/'build/issue859-anchors-public.json').read_bytes()==(root/'assets/validation_v5_17_108/grip_anchors.json').read_bytes()
rows=json.loads((root/'build/issue859-presentation-final.json').read_text());assert len(rows)==8
paragraph='''Eight fresh paired one-player windows compare the107 equipped candidate
against108 in studio/mansion/sewer/city fixed views (208 additional passing
fixture assertions). All eight screenshots were directly inspected. GZDoom
4.14.2, Ryzen9 5950X, RTX3070Ti,1280x720, unpaused background and5% audio are
recorded. No heavy build/hash/validator overlaps these windows.

| Scene / mode | Queue presents/s | Present p95 / p99 / max ms | Tic mean / p95 / p99 / max ms |
| --- | ---: | --- | --- |
'''
for row in rows:
 p=row['presentation'];q=p['present_intervals'];t=row['simulation']
 paragraph+=f"| {row['scene']} / {row['kind']} | {p['mean_present_fps']:.3f} | {q['p95_ms']:.3f} / {q['p99_ms']:.3f} / {q['max_ms']:.3f} | {t['mean_ms']:.3f} / {t['p95_ms']:.3f} / {t['p99_ms']:.3f} / {t['max_ms']:.3f} |\n"
paragraph+='''
The city candidate has about4% fewer queue presents/s in this pair, with nearly
equal p99 intervals. This observation does not isolate a causal regression or
prove a speed improvement. The other three means are close. Queue presents are
not monitor scanout; tic intervals include pacing/frame work. These single-view,
one-player measurements do not establish crowd, combat, full-map or siege
performance. The mansion retains its opening dialogue; sewer/city entrances
keep their original world rules. Siege performance remains unresolved.

Evidence: assets/validation_v5_17_108, including exact runtime/source hashes,
canonical/close suites, all recorded attempts and the viewed-image list. The
portable camera-anchor generator reproduces the retained JSON byte-for-byte.
Full project validation is recorded separately when completed.
'''
p=root/'docs/HISTORY.md';s=p.read_text(encoding='utf-8');assert s.count('PERFORMANCE859_PENDING')==1;p.write_text(s.replace('PERFORMANCE859_PENDING',paragraph.rstrip()),encoding='utf-8',newline='\n')
p=root/'build/issue859-visual-review.json';d=json.loads(p.read_text());seen={r['path'] for r in d['directly_viewed']}
for row in rows:
 f=root/row['directory']/'scene.png';name=f.relative_to(root).as_posix();assert name not in seen
 d['directly_viewed'].append({'path':name,'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'final_evidence':True,'qualification':row['kind']+' of the final paired performance comparison'})
d['notes'].append('All8 final paired performance images directly inspected: studio equipped player; mansion opening dialogue; dark sewer entrance; city gate. Control uses107 and candidate108.')
p.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8');print('Qualified8windows;',len(d['directly_viewed']),'viewed images; portable anchors exact.')
