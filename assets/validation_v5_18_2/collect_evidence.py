"""Retain per-scenario independent integration evidence without shipping saves."""
from pathlib import Path
import hashlib,json,shutil,zipfile

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent

def sha(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

def retain(source,target):
    for child in source.rglob('*'):
        if child.is_file() and child.suffix.lower() in ['.json','.txt','.log','.cfg','.ini','.png','.csv']:
            dest=target/child.relative_to(source);dest.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(child,dest)
        if child.is_file() and child.name=='observer.pk3':
            with zipfile.ZipFile(child) as z:
                for name in z.namelist():
                    if '/' not in name and '\\' not in name:
                        dest=target/child.relative_to(source).parent/'observer-source'/name
                        dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(z.read(name))

def read(path):return json.loads(path.read_text(encoding='utf8'))

def main():
    evidence=HERE/'evidence';evidence.mkdir(exist_ok=True)
    cases={}
    for label,folder,report in [
        ('vacancy','issue468-vacancy01','result.json'),
        ('deathmatch','issue468-deathmatch01','results.json'),
        ('deathmatch_reload','issue468-deathmatch-reload01','results.json'),
        ('team','issue468-team01','results.json'),
        ('team_reload','issue468-team-reload01','results.json'),
        ('capture','issue468-capture01','results.json'),
        ('anchor','issue468-anchor01','results.json'),
        ('transfer','issue468-transfer03','results.json'),
        ('static','issue468-static01','results.json')]:
        source=ROOT/'build'/folder;data=read(source/report)
        assert data['passed'],label
        cases[label]=dict(report=report,passed=True,source=folder)
        retain(source,evidence/label)
    matrix=read(ROOT/'build/issue468-matrix01/MATRIX.json')
    assert len(matrix['cases'])==13 and all(row['passed'] for row in matrix['cases'])
    retain(ROOT/'build/issue468-matrix01',evidence/'modes')
    references=read(ROOT/'build/issue468-references01/MATRIX.json')
    assert len(references['rows'])==4 and all(row['passed'] for row in references['rows'][:3])
    assert not references['rows'][-1]['passed']
    retain(ROOT/'build/issue468-references01',evidence/'references-initial')
    corrected=read(ROOT/'build/issue468-references02/MATRIX.json')
    assert len(corrected['rows'])==3 and all(row['passed'] for row in corrected['rows'])
    retain(ROOT/'build/issue468-references02',evidence/'references-current')
    mansion=read(ROOT/'build/issue468-references03/MATRIX.json')
    assert len(mansion['rows'])==1 and mansion['rows'][0]['passed']
    retain(ROOT/'build/issue468-references03',evidence/'references-mansion')
    performance={}
    for name in ['MAP01','MAP02','MAP03']:
        folder={'MAP01':'references-mansion','MAP02':'references-initial','MAP03':'references-current'}[name]
        data=read(evidence/folder/name/'presentation.json')
        performance[name]=data['peers'][0]
    retain(ROOT/'build/issue468-transfer02',evidence/'attempts'/'transfer02')
    package=ROOT/'build/issue468-review01/caelum_argenteum.ipk3'
    pilot=ROOT/'build/issue467-final04/caelum_argenteum.ipk3'
    changes=[]
    with zipfile.ZipFile(pilot) as old,zipfile.ZipFile(package) as new:
        assert old.namelist()==new.namelist()
        for name in old.namelist():
            before,after=old.read(name),new.read(name)
            if before!=after:
                changes.append(name);assert before.replace(b'5.18.1',b'5.18.2')==after,name
    assert sorted(changes)==['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
    validation=read(ROOT/'build/issue468-validation.json')
    assert validation['version']=='5.18.2' and not validation['errors']
    shutil.copyfile(ROOT/'build/issue468-validation.json',evidence/'project-validation.json')
    sources={name:sha(ROOT/name) for name in ['caelum_sessions.py','caelum_standalone.py','caelum_new_campaign.py','caelum_transfer_verify.py','assets/profiles/verification.zs']}
    static=read(ROOT/'build/issue468-static01/results.json')
    for name,digest in static['sources'].items():assert sources[name]==digest
    attempts=[dict(case='transfer01',result='Correct refusal: anchor had an active native conversation. Original untouched; native cancellation saved a new anchor.'),
        dict(case='transfer02',result='Real verifier timeout: narrative and verification saves coexisted. Original heads/reservations retained; selection fixed before transfer03.'),
        dict(case='references01/menu',result='Outdated fixture expected a direct main-menu link. Current accepted menu routes through CaelumMultiplayerMenu; fixture now verifies both links. No production menu change.'),
        dict(case='references01/MAP01+MAP03',result='Native traces completed but captures showed an active mansion dialogue and an obsolete city camera inside a house. Current views retain authored player-start positions.'),
        dict(case='references02/MAP01',result='Native conversation cancellation alone left the visible menu open. The final mansion observer also closes the current native menu before observation; the third capture is checked explicitly.')]
    report=dict(issue=468,version='5.18.2',package_sha256=sha(package),pilot_sha256=sha(pilot),
        equivalent_runtime_except_printed_labels=changes,production_sources=sources,cases=cases,
        mode_cases=matrix['cases'],references=references['rows'],current_references=corrected['rows'],mansion_reference=mansion['rows'],performance=performance,attempts=attempts,
        validation='Full project validation passed before the final external verifier selection fix; final affected Python regression and native transfer checks passed afterward. Document-index freshness checked after final prose.',
        environment='Windows 11 build 26200; Ryzen 9 5950X; RTX 3070 Ti; GZDoom startup g4.14.2 / file version g4.14.2-m; Vulkan; 5% background audio, unpaused.',
        reuse='The #467 matching-map forward/rollback evidence applies to identical runtime actor/map bytes. Mode matrix uses that identical pilot runtime; transfer, peaceful references and native menu use the final #468 package.',
        limits=['QueuePresent calls measure application presentation requests, not monitor scanout.',
            'Loopback peers share one machine; no Internet/separate-machine acceptance.',
            'Peaceful real-map references do not resolve the documented severe siege rendering limitation.',
            'Finale predicate checks do not author later campaign routes/scenes.',
            'All 114 author checks remain pending.'],author_acceptance=False)
    (evidence/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
    print(json.dumps(dict(issue=468,mode_cases=len(matrix['cases'])+5,managed_transfer=True,peaceful_references=3,author_acceptance=False)))

if __name__=='__main__':main()
