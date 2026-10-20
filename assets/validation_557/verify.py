"""Freeze #315 documentation arithmetic and unchanged-runtime evidence."""
from pathlib import Path
import hashlib
import json
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    old=ROOT/'build/issue314-current07/production.pk3';new=ROOT/'build/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(old) as a,zipfile.ZipFile(new) as b:
        assert set(a.namelist())==set(b.namelist())
        changed=sorted(n for n in a.namelist() if a.read(n)!=b.read(n))
        assert changed==['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'],changed
        for name in changed:
            assert a.read(name).decode().replace('\r\n','\n').replace('[Caelum 5.5.6]','[Caelum 5.5.7]')==b.read(name).decode().replace('\r\n','\n')
    catalogue=ROOT/'assets/validation_550/matrix.json';matrix=json.loads(catalogue.read_text())
    power=(200/100)*(1+7*(20**2+25*20)/(125*100))
    rows=[{'weapon':r['weapon'],'tier':r['tier'],'base_hp':r['damage'],'nominal_air':r['air'],
           'matched_rulo_profile_raw_hp':round(r['damage']*power,6)} for r in matrix['configurations']
          if r['weapon'] in ('Dagger','Sword','Greatsword') and r['essence']==0]
    assert len(rows)==9
    report={'issue':315,'release':'5.5.7','decision':'Author explicitly deferred conversion and retained current damage on 2026-10-19.',
        'runtime_changes':changed,'gameplay_member_bytes_unchanged':True,
        'baseline_sha256':sha(old),'current_sha256':sha(new),'matrix_sha256':sha(catalogue),
        'comparison_profile':{'source':'CaelumRulo authored mass/Strength; neutral extra modifiers, healthy; not a new player default.',
            'body_mass_kg':200,'strength':20,'raw_multiplier':power},'comparisons':rows,
        'war_axe_raw':{'normal':220*power,'charged':440*power,'existing_native_rounded':[662,1324],
            'evidence':'validation_5212/tools.zs; forced Dexterity secures hit, not ordinary accuracy/timing.'},
        'candidate_physical_parameters':'Unapproved and unresolved; no production implementation.',
        'pending_author_tests':None}
    evidence=HERE/'evidence'
    if evidence.exists():
        log=(evidence/'smoke.txt').read_text(encoding='utf-8')
        assert 'CA315 PASS' in log and 'Script error' not in log
        report['native_smoke']={'checks':1,'files':{p.name:sha(p) for p in evidence.iterdir()}}
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'unchanged_gameplay':True,'comparisons':len(rows),'raw_multiplier':power}))
if __name__=='__main__':main()
