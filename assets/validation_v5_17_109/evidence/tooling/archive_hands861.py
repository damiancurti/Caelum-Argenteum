"""Archive reproducible #861 text/image evidence, excluding private binaries."""
from pathlib import Path
import hashlib,html,json,zipfile
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');h=Path(__file__).resolve().parent
dest=root/'assets/validation_v5_17_109';out=dest/'evidence';out.mkdir(exist_ok=True)
assert not (out/'SUMMARY.json').exists(),'Do not overwrite a completed evidence archive.'
allowed={'.py','.zs','.json','.txt','.log','.ini','.cfg','.csv','.png','.html','.modeldef'}
def copy(p,target):
 target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(p.read_bytes())
for directory in sorted((root/'build').glob('issue861-*')):
 if not directory.is_dir():continue
 for p in sorted(directory.rglob('*')):
  if not p.is_file() or '__pycache__' in p.parts:continue
  if p.suffix.lower() in allowed or p.name in ('ZSCRIPT','CVARINFO','MODELDEF','MAPINFO'):copy(p,out/'runs'/directory.name/p.relative_to(directory))
  if p.name=='checks.pk3':
   with zipfile.ZipFile(p) as archive:
    for name in archive.namelist():
     if name.lower() in ('zscript','cvarinfo','mapinfo','modeldef'):
      target=out/'runs'/directory.name/p.relative_to(directory).parent/'fixture_sources'/name.upper();target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(archive.read(name))
for p in sorted((root/'build').glob('issue861-*')):
 if p.is_file() and p.suffix.lower() in allowed:copy(p,out/'records'/p.name)
for p in sorted(h.glob('*861*')):
 if p.is_file() and p.suffix in ('.py','.zs'):copy(p,out/'tooling'/p.name)
canonical=json.loads((root/'build/issue861-final05/SUMMARY.json').read_text());assert len(canonical)==16 and all(r['passed'] for r in canonical)
actions=json.loads((root/'build/issue861-actions-final.json').read_text());assert len(actions)==4 and all(r['passed'] for r in actions)
consumers=[]
for name in ('issue861-consumers-male01','issue861-consumers-female01','issue861-ordinary01'):
 report=json.loads((root/'build'/name/'RESULTS.json').read_text());assert report['passed']
 consumers.append(dict(directory='build/'+name,pass_lines=sum('EDGE PASS' in x for x in report['checks'])))
performance=json.loads((root/'build/issue861-presentation-final.json').read_text());assert len(performance)==8
scope=json.loads((root/'build/issue861-scope.json').read_text());assert scope['all_runtime_bytes_match_src'] and scope['all_prototype02_members_match_final'] and scope['no_added_or_removed_runtime_members']
source=json.loads((root/'build/issue861-source-review.json').read_text());assert source['native_save_omits_all_new_fields']
summary=dict(issue=861,version='5.17.109',canonical=canonical,canonical_passes=sum(r['pass_lines'] for r in canonical),actions=actions,action_passes=sum(r['pass_lines'] for r in actions),consumers=consumers,consumer_passes=sum(r['pass_lines'] for r in consumers),performance=performance,performance_passes=sum(r['pass_lines'] for r in performance),scope=scope,source_review=source,full_validation_pending=True,visual_review=json.loads((root/'build/issue861-visual-review.json').read_text()),qualification='Counts use actual per-process PASS lines, excluding inherited handler counters. First7 final03 continuity phases are reused because subsequent diagnostic edits concern Pose checks and an optional legacy-death expectation only. Counter overlay is separate from production. Failed attempts remain archived and are not final qualification. No author acceptance.',private_exclusions=['PK3','WAD','IWAD','ZDS','EXE','DLL','PYC'])
(out/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n')
hashes={p.relative_to(out).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.rglob('*')) if p.is_file() and p.name!='SHA256.json'}
(out/'SHA256.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8',newline='\n')
groups=[('Same actual GP item: historical scope and current extension',[('issue861-save-baseline04/hands.png','Before109: documented armor-only scope'),('issue861-final03/fresh/hands.png','109: actual clothing glove selects retained art')])]
for sex in [0,1]:
 for glove in ['bare','GP']:
  groups.append((('Male' if sex==0 else 'Female')+' / '+glove,[(f'issue861-final05/motion-{sex}-{glove}/{pose}.png',pose) for pose in ('idle','attack','guard','restored')]+[(f'issue861-actions-{sex}-{glove}01/{pose}.png',pose) for pose in ('carbine-ready','carbine-reload','carbine-loaded','staff-ready','staff-charge','staff-restored')]))
groups.append(('Actual appearance editor',[(f'issue861-consumers-{sex}01/preview-{glove}.png',sex+' / '+glove) for sex in ('male','female') for glove in ('gloves','bare')]))
page='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Shared hand selection — #861</title><style>body{margin:2rem auto;max-width:1250px;padding:0 1rem;background:#15191d;color:#eee;font:17px/1.5 system-ui}a{color:#9ed5ff}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(330px,1fr));gap:1rem}figure{margin:0}img{width:100%;height:auto}figcaption{padding:.4rem 0}h2{margin-top:2rem}</style><h1>Shared hand selection — #861</h1><p>Native captures prepared for the final consolidated author review. The four actual clothing glove types select the existing shared male/female glove image; no material-specific art, weapon pose or pivot is added. This is not author acceptance.</p><p>Frontal guard intentionally hides the sword and keeps shield/left hand. The existing carbine reload framing leaves much of the hands below the image; state checks do not prove complete hand contact. The exact directly inspected image list is separate from this capture gallery.</p><p><a href="NATIVE_CONTRACT.txt">Reproduction and limits</a> · <a href="evidence/SUMMARY.json">Qualified evidence and viewed-image hashes</a></p>'''
for label,items in groups:
 page+='<h2>'+html.escape(label)+'</h2><div class="grid">'
 for name,caption in items:
  link='evidence/runs/'+name;assert (dest/link).is_file()
  page+='<figure><a href="'+link+'"><img loading="lazy" src="'+link+'" alt="'+html.escape(label+' / '+caption)+'"></a><figcaption>'+html.escape(caption)+'</figcaption></figure>'
 page+='</div>'
(dest/'review.html').write_text(page+'</html>\n',encoding='utf-8',newline='\n')
print(json.dumps({k:summary[k] for k in ('canonical_passes','action_passes','consumer_passes','performance_passes')}));print('Archived',len(hashes),'evidence files.')
