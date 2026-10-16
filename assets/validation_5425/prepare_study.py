"""Build deterministic MAP06 controls from current source; never alter campaign balance."""
import argparse
import ast
import importlib.util
import json
import re
from pathlib import Path
from prepare import ROOT, HERE, package

spec=importlib.util.spec_from_file_location('audit',ROOT/'assets/validation_500/audit_sources.py')
audit=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit)

def replace_once(text,old,new):
    assert text.count(old)==1,old
    return text.replace(old,new)

def inject(members,filename,cls,method,code):
    path=next(p for p in members if p.endswith('/'+filename+'.zs'))
    text=members[path].decode('utf-8-sig')
    methods=[m for c in audit.declarations(text) if c['name']==cls for m in c['methods'] if m['name']==method]
    assert len(methods)==1,(cls,method)
    start=methods[0]['body_start']+1
    members[path]=(text[:start]+'\n'+code+'\n'+text[start:]).encode()

def thermal_off(members):
    entries=[('CaelumThermalBody','Get','if(body is "CaelumCombatActor")return null;'),
             ('CaelumThermalRuntime','NPCStep','return;'),
             ('CaelumThermalService','Impulse','if(body is "CaelumCombatActor")return;')]
    entries += [('CaelumThermalMotion',m,'if(body is "CaelumCombatActor")return;') for m in ('Path','Physics','SetVelocity')]
    entries += [('CaelumThermalMotion','Support','if(body is "CaelumCombatActor")return null;')]
    for cls,method,guard in entries:inject(members,cls,cls,method,guard)
    return entries

def soldier_models():
    frames={'DOID':{'A':0},'DOWK':{'A':14,'B':18},'DOMI':{c:0 for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'},
            'CAGN':dict(zip('ABCDEF',[0,14,18,50,56,60])),
            'CAGC':dict(zip('ABCD',[150,50,56,60])),'SHGW':dict(zip('ABCDEF',[0,14,18,50,56,60]))}
    frames['DOMI'].update(dict(zip('KLMNOPQR',[34,36,38,40,42,44,46,47])))
    frames['DOMI'].update(dict(zip('STUVWXYZ',[72,76,80,84,88,92,96,100])))
    lines=['Model CaelumPortDefender {','Path "models/caelum/domingo"','Model 0 "domingo.md3"',
           'Skin 0 "domingo_skin.png"','Scale 1 1 1','DontCullBackFaces']
    lines += [f'FrameIndex {s} {f} 0 {n}' for s,fs in frames.items() for f,n in fs.items()]
    return ('\n'.join(lines)+'\n}\n').encode()

SELECTED={
 'CaelumCombatActor':{'Tick':0,'CA121NativeTick':1,'CollidedWith':2,'UpdateImpactContactLatch':3,'UpdateCombatHealthEffects':4,'UpdateActorOffensiveStatistics':5,'PulseResourceRecovery':6},
 'CaelumDemonService':{'UpdateBreath':7,'UpdatePotions':8},
 'CaelumPortSiege':{'Tick':9,'AttackerTarget':10,'ElectCommands':11,'RefreshTargets':13,'RefillCrews':14,'OrderGuns':15,'CannonTarget':16,'WalkTo':17,'Pulse':18},
 'CaelumPopulationState':{'Refresh':19},'CaelumHostileMachine':{'ObserveGuards':20},'CaelumCannon':{'Tick':21},
 'CaelumCannonProjectile':{'Tick':22},'CaelumPlayer':{'Tick':23},'CaelumElementalStatus':{'Tick':24},
 'CaelumCorpseArchive':{'Tick':26},'CaelumActorProjectile':{'Tick':27},'CaelumActorSimpleElementalProjectile':{'Tick':28},
 'CaelumSiegeReinforcements':{'RefreshLiving':29,'Place':30,'Tick':31},'CaelumThermalRuntime':{'NPCStep':32},
 'CaelumThermalService':{'Advance':33,'Integrate':35},'CaelumThermalEnvironment':{'Sample':34},
 'CaelumThermalMotion':{'Physics':36},'CaelumThermalFire':{'Sample':37},'CaelumThermalBody':{'Refresh':38},
 'CaelumDemonBreath':{'Tick':39}}

def profile(members):
    # Reuse only the reviewed wrapper function; importing its old module would
    # rebuild unrelated historical packages through module-level side effects.
    old=(ROOT/'assets/validation_512/prepare_profile.py').read_text(encoding='utf-8')
    tree=ast.parse(old);function=next(n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='instrument')
    scope={'audit':audit,'selected':SELECTED,'re':re}
    exec(compile(ast.Module(body=[function],type_ignores=[]),'reused_profile_wrapper','exec'),scope)
    methods=[]
    for path,data in list(members.items()):
        if not path.endswith('.zs'):continue
        text=data.decode('utf-8-sig').replace('\r\n','\n')
        if path.endswith('/CaelumCombatActor.zs'):
            method=next(m for c in audit.declarations(text) if c['name']=='CaelumCombatActor' for m in c['methods'] if m['name']=='Tick')
            start,end=method['body_start'],method['body_end']
            text=text[:start]+text[start:end+1].replace('Super.Tick();','CA121NativeTick();')+'\n void CA121NativeTick(){Super.Tick();}\n'+text[end+1:]
        if path.endswith('/CaelumPortSiege.zs'):
            text=re.sub(r'([\w.]+)\.CheckSight\((\w+)\)',r'CA121Profiler.LOS(\1,\2)',text)
        if any(c['name'] in SELECTED for c in audit.declarations(text)):
            members[path]=scope['instrument'](text,methods).encode()
    members['ZSCRIPT']+=b'\n#include "ca304_profile.zs"\n'
    old=(ROOT/'assets/validation_505/observer.zs').read_text(encoding='utf-8')
    members['ca304_profile.zs']=old[:old.index('class CA121Observer')].encode()
    members['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA121Profiler" }\n'
    return methods

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--directory',required=True)
    a=parser.parse_args();assert all(c.isalnum() or c in '-_' for c in a.directory)
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    data=json.loads((HERE/'study.json').read_text())
    base={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    key='caelum/world/CaelumSiegeReinforcements.zs';text=base[key].decode('utf-8-sig').replace('\r\n','\n')
    text=replace_once(text,'const LIVING_CAP = 2000;',f'const LIVING_CAP = {data["mandinga_living_cap"]};')
    text=replace_once(text,'const TOTAL = 6000;',f'const TOTAL = {data["mandinga_total"]};')
    text=replace_once(text,'Pending, GroupStart;','Pending, GroupStart, GroupCount;')
    text=replace_once(text,'if(Living>CaelumReinforcementData.LIVING_CAP-CaelumReinforcementData.GROUP_SIZE\n                || Remaining<CaelumReinforcementData.GROUP_SIZE)return;\n            GroupStart=Successful;Pending=CaelumReinforcementData.GROUP_SIZE;',
        'GroupCount=Min(CaelumReinforcementData.GROUP_SIZE,Remaining);\n            if(Living>CaelumReinforcementData.LIVING_CAP-GroupCount)return;\n            GroupStart=Successful;Pending=GroupCount;')
    text=text.replace('i<CaelumReinforcementData.GROUP_SIZE','i<GroupCount')
    text=text.replace('%CaelumReinforcementData.TOTAL','%CaelumPortData.MandingaCount()')
    base[key]=text.encode()
    manifest={'settings':data,'variants':{},'scope':'Diagnostic copies only. Native production corpse archive shared by every variant.'}
    for variant in ('base','thermal-off','target-3s','models','profile-base','profile-thermal-off'):
        members=base.copy();meta={}
        if 'thermal-off' in variant:meta['disabled_entries']=thermal_off(members)
        if variant=='target-3s':
            key='caelum/world/CaelumPortData.zs';t=members[key].decode('utf-8-sig')
            t,n=re.subn(r'TARGET_UPDATE_TICS\s*=\s*8',f'TARGET_UPDATE_TICS = {data["target_period_tics"]}',t);assert n==1
            members[key]=t.encode()
        if variant=='models':members['MODELDEF']+=b'\n'+soldier_models()
        if variant.startswith('profile-'):meta['methods']=profile(members)
        meta['sha256']=package(out/(variant+'.pk3'),members);manifest['variants'][variant]=meta
    constants=f'''class CA304Data : Object {{
 const LIVING_CAP={data['mandinga_living_cap']}; const TOTAL={data['mandinga_total']};
 const WARMUP={data['warmup_tics']}; const WINDOW={data['observation_tics']};
 const ANGLE={data['camera_angle']};
 const RENDER_PITCH={data['render_pitch']};
 static vector3 Camera(){{return ({','.join(map(str,data['camera']))});}}
 static vector3 RenderCamera(){{return ({','.join(map(str,data['render_camera']))});}}
 static vector3 SoldierPosition(int i){{return ({data['render_origin'][0]}+(i%{data['render_columns']})*{data['render_spacing']},{data['render_origin'][1]}-(i/{data['render_columns']})*{data['render_spacing']},{data['render_origin'][2]});}}
}}\n'''
    manifest['observer_sha256']=package(out/'observer.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "data.zs"\n#include "observer.zs"\n',
        'data.zs':constants.encode(),'observer.zs':(HERE/'observer.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA304Observer" }\n',
        'CVARINFO':b'server bool ca304_render_control=false; server bool ca304_budget_control=false; server int ca304_window=0;\n'})
    for variant in ('study','render','budget','long','bench'):
        commands='ca_test_siege_reinforcements true; '
        if variant=='render':commands+='ca304_render_control true; '
        if variant=='budget':commands+='ca304_budget_control true; '
        duration=data['observation_tics']
        if variant=='long':duration=7000;commands+=f'ca304_window {duration}; '
        if variant=='bench':commands+='ca304_render_control true; wait 500; bench; screenshot scene.png; profilethinkers -t; '
        commands+=f'wait {data["warmup_tics"]+duration+110}; quit\n'
        (out/(variant+'.cfg')).write_text(commands,encoding='utf-8')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(out)

if __name__=='__main__':main()
