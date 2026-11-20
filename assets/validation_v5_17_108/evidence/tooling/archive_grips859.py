"""Preserve focused text/image evidence, explicitly excluding private binaries."""
from pathlib import Path
import hashlib,html,json,zipfile
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');h=Path(__file__).resolve().parent
dest=root/'assets/validation_v5_17_108';out=dest/'evidence';out.mkdir(exist_ok=True)
assert not (out/'SUMMARY.json').exists(), 'Do not overwrite a completed evidence archive.'
allowed={'.py','.zs','.json','.txt','.log','.ini','.cfg','.csv','.png','.html','.modeldef'}
def copy(p,target):
 target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(p.read_bytes())
for directory in sorted((root/'build').glob('issue859-*')):
 if not directory.is_dir():continue
 for p in sorted(directory.rglob('*')):
  if p.is_file() and (p.suffix.lower() in allowed or p.name in ('ZSCRIPT','CVARINFO','MODELDEF','MAPINFO')):copy(p,out/'runs'/directory.name/p.relative_to(directory))
  if p.is_file() and p.name=='checks.pk3':
   with zipfile.ZipFile(p) as archive:
    for name in archive.namelist():
     if name.lower() in ('zscript','cvarinfo','mapinfo','modeldef'):
      target=out/'runs'/directory.name/p.relative_to(directory).parent/'fixture_sources'/name.upper();target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(archive.read(name))
for p in sorted((root/'build').glob('issue859-*')):
 if p.is_file() and p.suffix.lower() in allowed:copy(p,out/'records'/p.name)
for p in sorted(h.glob('*859*')):
 if p.is_file() and p.suffix in ('.py','.zs'):copy(p,out/'tooling'/p.name)
canonical=json.loads((root/'build/issue859-final02/SUMMARY.json').read_text());assert len(canonical)==13 and all(r['passed'] for r in canonical)
close=json.loads((root/'build/issue859-close-summary.json').read_text());assert len(close)==5 and all(r['passed'] for r in close)
right=json.loads((root/'build/issue859-close-right04/RESULTS.json').read_text());assert right['passed'];close.append({'glove':'bare','focus':'Right','directory':'build/issue859-close-right04','passed':True,'pass_lines':sum('EDGE PASS' in x for x in right['checks']),'capture_pose_checks':right['capture_pose_checks']})
performance=json.loads((root/'build/issue859-presentation-final.json').read_text());assert len(performance)==8
scope=json.loads((root/'build/issue859-source-check.json').read_text())
assert all(scope[k] for k in ('all_runtime_bytes_match_src','all_prototype_members_match_final','independent_rebuild_md3_identical','original_sources_unchanged','frame_directives_unchanged'))
assert scope['members']==18767 and scope['resolved_frames']==375
summary=dict(issue=859,version='5.17.108',canonical=canonical,canonical_passes=sum(r['pass_lines'] for r in canonical),close=close,close_passes=sum(r['pass_lines'] for r in close),performance=performance,scope=scope,full_validation_pending=True,qualification='Native PASS counts use actual per-process log lines, excluding inherited handler counters. Finite opt-in reference-body visual correction; original gameplay/default presentation unchanged. Rejected exports/cameras retained separately. No author acceptance.',visual_review=json.loads((root/'build/issue859-visual-review.json').read_text()),private_exclusions=['PK3','WAD','IWAD','ZDS','EXE','DLL','PYC','rejected Blender containers'])
(out/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
hashes={p.relative_to(out).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.rglob('*')) if p.is_file() and p.name!='SHA256.json'}
(out/'SHA256.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
groups=[('Bare hands / full-body native poses','issue859-final02/bare',['grip-front','walk','run','attack','guard','jump-air','landing','death-side']),('Sword hand / close view','issue859-close-right04',['grip-front','run','attack','guard','jump-air','landing','death']),('Shield hand / close view','issue859-close-bare-left01',['grip-front','run'])]
for glove in ['gf','gc','gw','gp']:groups.append((glove.upper()+' actual equipped gloves','issue859-close-'+glove+'-right01',['grip-front','run']))
page='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>First-body grip review — #859</title><style>body{margin:2rem auto;max-width:1250px;padding:0 1rem;background:#15191d;color:#eee;font:17px/1.5 system-ui}a{color:#9ed5ff}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(330px,1fr));gap:1rem}figure{margin:0}img{width:100%;height:auto}figcaption{padding:.4rem 0}h2{margin-top:2rem}</style><h1>First-body grip review — #859</h1><p>Candidate for the final consolidated author review. These are direct GZDoom4.14.2 captures of actual equipped items, not a claim of author acceptance. Click an image for its original resolution.</p><p>The finite correction retains the original sword, shield, glove materials and rig actions. Construction skin is flat; angular hand/wrist shading and original garment, face, hair and death-pose limitations remain. Other bodies, first-person equipment and #736 proposals remain separate.</p><p><a href="../../../validation_v5_17_108/NATIVE_CONTRACT.txt">Reproduction contract</a> · <a href="DESIGN.json">Visual fitting data</a> · <a href="PROVENANCE.json">Provenance</a></p>'''
for label,directory,names in groups:
 page+='<h2>'+html.escape(label)+'</h2><div class="grid">'
 for name in names:
  link='../../../validation_v5_17_108/evidence/runs/'+directory+'/'+name+'.png';assert (root/'assets/source/art/grips_859'/link).is_file()
  page+='<figure><a href="'+link+'"><img loading="lazy" src="'+link+'" alt="'+html.escape(label+' — '+name)+'"></a><figcaption>'+html.escape(name)+'</figcaption></figure>'
 page+='</div>'
page+='</html>\n';(root/'assets/source/art/grips_859/review.html').write_text(page,encoding='utf-8',newline='\n')
print(json.dumps({'archived':len(hashes),'main_assertions':summary['canonical_passes'],'close_assertions':summary['close_passes'],'performance_windows':len(performance)}))
