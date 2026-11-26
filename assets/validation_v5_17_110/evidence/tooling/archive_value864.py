"""Retain focused text/image evidence without native binaries or saved games."""
from pathlib import Path
import hashlib, html, json, shutil, zipfile

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
helpers=Path(__file__).parent;dest=root/'assets/validation_v5_17_110';evidence=dest/'evidence'
assert not evidence.exists();evidence.mkdir()
scenes=json.loads((root/'build/issue864-production-performance.json').read_text());assert len(scenes)==6
suite=json.loads((root/'build/issue864-native-suite.json').read_text());assert len(suite)==5
allowed={'.json','.zs','.txt','.log','.ini','.cfg','.csv','.png','.html','.py'}
special={'MAPINFO','ZSCRIPT','MODELDEF','CVARINFO'}
copied=[]
def copy_tree(source,target):
    for p in sorted(source.rglob('*')):
        if not p.is_file() or '__pycache__' in p.parts:continue
        if p.suffix.lower() not in allowed and p.name not in special:continue
        q=target/p.relative_to(source);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
        copied.append(q.relative_to(evidence).as_posix())
def copy_file(source,target):
    target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
    copied.append(target.relative_to(evidence).as_posix())
for row in suite:copy_tree(root/row['directory'],evidence/'native'/row['label'])
for n in ('01','02','03'):copy_tree(root/f'build/issue864-value-checks{n}',evidence/'prototype-checks'/n)
for label in ('deep01','types01'):
    row=json.loads((root/f'build/issue864-{label}-summary.json').read_text())
    copy_tree(root/row['directory'],evidence/'profiles'/label/'native')
    copy_tree(root/f'build/issue864-{label}',evidence/'profiles'/label/'overlay')
    copy_file(root/f'build/issue864-{label}-summary.json',evidence/'profiles'/label/'summary.json')
    analysis=root/f'build/issue864-{label}-analysis.json'
    if analysis.exists():copy_file(analysis,evidence/'profiles'/label/'analysis.json')
for label in ('value01','value02','value-public01'):
    copy_tree(root/f'build/issue864-{label}',evidence/'prototypes'/label)
captures=[]
for row in scenes:
    directory=root/row['directory'];target=evidence/'scenes'/row['label'];copy_tree(directory,target)
    package=directory/'observer.pk3'
    if package.exists():
        with zipfile.ZipFile(package) as z:
            for name in z.namelist():
                if Path(name).name not in special and Path(name).suffix!='.zs':continue
                q=target/'observer-source'/name;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(z.read(name))
                copied.append(q.relative_to(evidence).as_posix())
    image=target/'peer0/scene.png';assert image.is_file()
    captures.append(dict(label=row['label'],path=image.relative_to(dest).as_posix(),
        queue_per_second=row['presentation']['mean_present_fps']))
for name in ('scope','native-suite','production-performance'):
    copy_file(root/f'build/issue864-{name}.json',evidence/(name+'.json'))
copy_file(root/'build/issue864-build03.log',evidence/'build03.log')
names=['prepare_value864.py','prepare_value864_02.py','prepare_value_checks864.py','prepare_value_checks864_full.py',
    'run_value864.py','run_value864_full.py','run_contact_profile864.py','run_contact_scene864.py',
    'run_value_suite864.py','run_performance864.py','integrate_value864.py','prepare_public_value864.py',
    'document_value864.py','archive_value864.py']
for name in names:copy_file(helpers/name,evidence/'tooling'/name)
summary=dict(issue=864,version='5.17.110',canonical_suite=suite,canonical_assertions=sum(r['checks'] for r in suite),
    final_runtime_assertions=sum(r['checks'] for r in suite if r['label'] in ('fresh','upgrade','reload')),
    prior_runtime_assertions=sum(r['checks'] for r in suite if r['label'] in ('baseline','rollback')),
    supplementary_attempts=['value-checks01:745 pass, native-carrier-only candidate slowed NPC fallback',
        'value-checks02:745 pass, candidate02 with explicit NPC fallback','value-checks03:787 pass, added first-read exposure case'],
    performance=scenes,scope=json.loads((root/'build/issue864-scope.json').read_text()),
    captures=captures,direct_visual_review_pending=True,full_validation_pending=True,author_acceptance=False,
    qualification='Exact-source typed Value dispatch only; no concentration cache or skipped settlement. Nested sampled costs and synchronous loops are not whole-frame savings. Fixed references do not establish full-map fluency. Pending author queue and broader batch remain open.')
(evidence/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
figures='\n'.join('<figure><img loading="lazy" src="'+html.escape(r['path'])+'" alt="'+html.escape(r['label'])+'"><figcaption>'+html.escape(r['label'])+' — '+format(r['queue_per_second'],'.3f')+' queue presents/s</figcaption></figure>' for r in captures)
(dest/'review.html').write_text('''<!doctype html><html lang="en"><meta charset="utf-8"><title>#864 native reference views</title>
<style>body{font:16px system-ui;background:#181a1f;color:#eee;max-width:1500px;margin:32px auto;padding:0 20px}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(480px,1fr));gap:24px}figure{margin:0}img{width:100%}figcaption{padding:10px 0}a{color:#8ecbff}</style>
<h1>#864 native reference views</h1><p>Equivalent contamination Value dispatch, release 5.17.110. Retained art and geometry. These fixed views do not establish route coverage, smooth rendering or author acceptance.</p>
<p>Queue presents are application submissions, not monitor scanout. Full frame/tic tails, configuration and exact package hashes are retained in <a href="evidence/SUMMARY.json">the evidence summary</a>. The broader batch and consolidated author review remain open.</p>
<main>'''+figures+'</main></html>\n',encoding='utf-8',newline='\n')
assert not any(p.suffix.lower() in {'.pk3','.wad','.zds','.exe','.dll','.pyc'} for p in evidence.rglob('*') if p.is_file())
print(json.dumps(dict(evidence_files=len(copied)+1,captures=len(captures),canonical_assertions=summary['canonical_assertions'])))
