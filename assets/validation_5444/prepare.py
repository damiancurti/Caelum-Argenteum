"""Private #354 structural-cache research; never modify src or normal packaging."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('production_preparation',ROOT/'assets/validation_5443/prepare.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)

def replace_once(text,needle,replacement):
    assert text.count(needle)==1,needle
    return text.replace(needle,replacement)

def patch(members):
    name='caelum/actors/CaelumActorMaintenance.zs';text=members[name].decode()
    text=replace_once(text,'    void Invalidate()', '''    // #354: sonda privada; los escritores estructurales avisan al propio actor.
    static void StructureChanged(CaelumCombatActor body)
    {
        if(body!=null && body.Maintenance!=null)
        {body.Maintenance.HealthReady=false;body.Maintenance.OffenseReady=false;}
    }

    void Invalidate()''')
    for family in ('Health','Offense'):
        for index in range(1,18):
            text,count=re.subn(r'        double input'+str(index)+r'=.*?;\n        if\('+family+r'Inputs\['+str(index)+r'\]!=input'+str(index)+r'\)changed=true;\n','',text,count=1)
            assert count==1,(family,index)
            text=replace_once(text,f'            {family}Inputs[{index}]=input{index};\n','')
    members[name]=text.encode()
    notice='CaelumActorMaintenance.StructureChanged(self);'
    def modify(cls,method,transform):
        path,text,m=base.prior.method(members,cls,method)
        a,b=m['body_start'],m['body_end'];body=text[a:b+1]
        members[path]=(text[:a]+transform(body)+text[b+1:]).encode()
    for cls,method in [('CaelumCombatActor','PostBeginPlay'),('CaelumBull','PostBeginPlay'),('CaelumGiantRat','PostBeginPlay')]:
        modify(cls,method,lambda t:replace_once(t,'RecalculateCombatStatistics();',notice+'RecalculateCombatStatistics();'))
    for method,needle in [('InitializeCombatArmor','CombatArmor.InitializeUniformLoadout(requestedArmorType, requestedTier);'),
                          ('ClearCombatArmorToBaseClothing','CombatArmor.InitializeDefaults();')]:
        modify('CaelumCombatActor',method,lambda t:replace_once(t,needle,needle+'\n        '+notice))
    modify('CaelumCombatActor','EnsureCombatPersonality',lambda t:replace_once(t,'CombatPersonalityRevision=GetApprovedPersonalityRevision();','CombatPersonalityRevision=GetApprovedPersonalityRevision();\n        '+notice))
    modify('CaelumCombatActor','ReceiveCaelumImpact',lambda t:replace_once(t,'int loss=CaelumToughnessRules.ImpactWear(CombatArmor,slot,wearBySlot[slot]);','int loss=CaelumToughnessRules.ImpactWear(CombatArmor,slot,wearBySlot[slot]);\n            if(loss>0)'+notice))
    modify('CaelumCombatActor','ApplyActorExplosionDefense',lambda t:replace_once(t,'CombatArmor.Durability[slot] -= durabilityLoss;','CombatArmor.Durability[slot] -= durabilityLoss;\n                if(durabilityLoss>0)'+notice))
    modify('CaelumCombatActor','ResolveActorArmorImpact',lambda t:replace_once(t,'            LastCombatArmorDurabilityLoss;','            LastCombatArmorDurabilityLoss;\n        if(LastCombatArmorDurabilityLoss>0)'+notice))
    modify('CaelumRulo','PostBeginPlay',lambda t:replace_once(t,'ConfigureCombatMagicalRange();',notice+'\n        ConfigureCombatMagicalRange();'))
    modify('CaelumAnchoredResident','RestoreRuloPartyHealth',lambda t:replace_once(t,'UpdateCombatHealthEffects();',notice+'\n        UpdateCombatHealthEffects();'))
    return members

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True)
    p.add_argument('--control',type=Path,required=True)
    p.add_argument('--seed',type=Path,required=True)
    a=p.parse_args();out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    with zipfile.ZipFile(a.control) as archive:original={n:archive.read(n) for n in archive.namelist()}
    candidate=patch(dict(original));hashes={}
    for name,members in [('baseline.pk3',original),('current/baseline.pk3',candidate)]:
        (out/name).parent.mkdir(exist_ok=True);hashes[name]=base.prior.base.package(out/name,members)
    observer=(ROOT/'assets/validation_5443/performance.zs').read_text(encoding='utf-8')
    for site,name in [(0,'city.pk3'),(1,'front/city.pk3')]:
        (out/name).parent.mkdir(exist_ok=True)
        hashes[name]=base.prior.base.package(out/name,{'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n',
            'probe.zs':observer.replace('const SITE=0;',f'const SITE={site};').encode(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA353Performance" }\n'})
    unit=(ROOT/'assets/validation_5443/probe.zs').read_text(encoding='utf-8')
    # Direct fixture writes explicitly honor the research mutation contract.
    unit,count=re.subn(r'(npc\.Combat(?:Armor|Personality)\.[A-Za-z]+(?:\[[^\]]+\])?\s*=[^;]+;|npc\.CombatArmor\.InitializeUniformLoadout\([^;]+;)',r'\1CaelumActorMaintenance.StructureChanged(npc);',unit)
    assert count==12,count
    unit=replace_once(unit,'    CaelumCombatActor CheckBody,CheckOther;','    CaelumCombatActor CheckBody,CheckOther;\n    CaelumRulo ResearchRulo;')
    unit=replace_once(unit,'            CheckBody=CaelumCombatActor(', '            ResearchRulo=CaelumRulo(Actor.Spawn("CaelumRulo",(1024,0,0),NO_REPLACE));ResearchRulo.bDormant=true;\n            CheckBody=CaelumCombatActor(')
    unit=replace_once(unit,'        if(Age==45)Checks();','        if(Age==45){Checks();ResearchChecks();}')
    unit=replace_once(unit,'    void TargetChecks(', (HERE/'checks.zs').read_text(encoding='utf-8')+'\n    void TargetChecks(')
    fixture={'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n','probe.zs':unit.encode(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA353Probe" }\nmap MAP99 "Structural cache checks" { sky1="SKY1" }\n','maps/map99.wad':base.flat_map()}
    hashes['quick.pk3']=base.prior.base.package(out/'quick.pk3',fixture)
    (out/'cache-battle.zds').write_bytes(a.seed.read_bytes())
    (out/'measure.cfg').write_text('wait 35; vid_vsync false; vid_maxfps 0; cl_capfps false; con_notifylines 0; wait 700; quit\n');(out/'checks.cfg').write_text('wait 180; quit\n')
    runner=(ROOT/'assets/validation_5422/run_native.ps1').read_text(encoding='utf-8-sig')
    # Startup stays capped; the common observer's settings gate checks the window.
    (out/'run_perf.ps1').write_text(runner,encoding='utf-8-sig')
    manifest=dict(issue=354,release='5.4.44',hashes=hashes,fixture_sha256=hashes['quick.pk3'],control_input_sha256=hashlib.sha256(a.control.read_bytes()).hexdigest(),
        changed_members={n:dict(before=hashlib.sha256(original[n]).hexdigest(),after=hashlib.sha256(v).hexdigest()) for n,v in candidate.items() if original[n]!=v},
        scope='Private research: remove 17 armor/personality reads from each health/offense guard; retain all scalar and weight guards and <=100-tic fallback.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest))

if __name__=='__main__':main()
