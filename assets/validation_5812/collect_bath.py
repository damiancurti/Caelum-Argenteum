"""Retain selected native bath evidence and verify the final packaged source."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
here=Path(__file__).resolve().parent
root=here.parents[1]
work=root/'build/issue502-hygiene'
out=here/'bathing'
labels=['bath-core04','bath-save03','bath-load03','bath-hub03','bath-water04e',
        'bath-live04','bath-final-capture05','bath-final-toilet05','bath-final-pose05',
        'bath-final-oldpose05','bath-final-rollback05','bath-final-legacy05b']
records=[]
(out/'native').mkdir(parents=True,exist_ok=True)
for label in labels:
    log=(work/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    assert not re.search(r'CA502H FAIL|Script error|VM execution aborted|failures=[1-9]',log),label
    assert 'CA502H RESULT' in log,label
    record=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code']==0 and not record.get('timed_out'),label
    records.append({'label':label,'passes':len(re.findall(r'^CA502H PASS',log,re.M)),
                    'package_sha256':record['package_sha256']})
    for suffix in ('.txt','-run.json'):shutil.copyfile(work/(label+suffix),out/'native'/(label+suffix))
package=work/'bath-final05/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as current,zipfile.ZipFile(work/'pose-final03/caelum_argenteum_dev.pk3') as baseline:
    for name in current.namelist():assert current.read(name)==(root/'src'/name).read_bytes(),name
    maps=[n for n in current.namelist() if n.startswith('maps/')]
    art=[n for n in current.namelist() if n.startswith(('sprites/','models/','graphics/','textures/','flats/'))]
    for name in maps+art:assert current.read(name)==baseline.read(name),name
    count=len(current.namelist())
    # Earlier bath behavior/save evidence differs only in view/localization/forecast files.
    comparisons={}
    for label in ('bath-dev03','bath-dev04'):
        with zipfile.ZipFile(work/label/'caelum_argenteum_dev.pk3') as old:
            changes=[n for n in current.namelist() if n not in old.namelist() or current.read(n)!=old.read(n)]
            allowed={'caelum/ui/CaelumBathUI.zs','LANGUAGE','localization/index.json','localization/INDEX.md'}
            if label=='bath-dev03':allowed|={'caelum/world/CaelumTimeSkipModel.zs','caelum/ui/CaelumLiveMenu.zs','caelum/ui/CaelumLiveMenuControls.zs'}
            assert set(changes)<=allowed,(label,changes)
            comparisons[label]=changes
(out/'captures').mkdir(exist_ok=True)
for name in ('bath-menu.png','bath-live.png'):shutil.copyfile(work/name,out/'captures'/name)
report={'issue':502,'version':'5.8.12','passes':sum(r['passes'] for r in records),'runs':records,
        'source_members':count,'unchanged_maps':len(maps),'unchanged_art_members':len(art),
        'package_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),
        'earlier_evidence_runtime_differences':comparisons,'author_test':'CA502-BATH-01 accepted2026-10-25 without qualifications',
        'limitations':'Functional native checks, not campaign-wide acceptance or frame-time measurements. Gear cleaning, surface/combat contacts and NPC routines remain pending.',
        'resolved_probes':['Initial compile: instance Sync call and explicit Actor assignment.',
         'Fixture pickup: use the native AttachToOwner API, not protected TryPickup.',
         'Campaign water fixture: arrival conversation correctly blocked bathing; end it explicitly before interaction.',
         'Campaign water fixture: MAP01 restores its actual100kg body; expected costs must use current mass rather than assume80kg.']}
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:report[k] for k in ('passes','source_members','unchanged_maps','unchanged_art_members','package_sha256')},indent=2))
