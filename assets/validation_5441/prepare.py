"""Build isolated one-family workload controls; never modify production sources."""
from pathlib import Path
import argparse
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('ca318_tools', ROOT/'assets/validation_issue318/prepare.py')
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)

# Bodies and argument cadence come from a normal 35-tic siege trace.
METHODS = [
    ('CaelumCombatActor', 'Tick', 'p.Record(0,self);', 'return;'),
    ('CaelumPortSiege', 'AttackerTarget', 'p.Record(1,entry.Body,entry);', 'return entry.CommandLeader!=null ? entry.CommandLeader.SharedTarget : entry.CombatTarget;'),
    ('CaelumThermalService', 'Integrate', 'p.Record(2,null,thermal,null,(0,0,0),worldSeconds,realSeconds,activityWatts,magicWatts,fireWatts,logicalActivitySeconds,firearmWatts);', 'return 0;'),
    ('CaelumDemonService', 'UpdateBreath', 'p.Record(3,npc);', 'return;'),
    ('CaelumDemonBreath', 'Mouth', 'p.Record(4,owner);', 'return CA318Solo.CachedMouth(owner);'),
    ('CaelumElementalStatus', 'Tick', 'p.Record(5,owner,self);', 'return;'),
    ('CaelumCombatActor', 'UpdateCombatHealthEffects', 'p.Record(6,self);', 'return;'),
    ('CaelumCombatActor', 'UpdateActorOffensiveStatistics', 'p.Record(7,self);', 'return;'),
    ('CaelumPortSiege', 'WalkTo', 'p.Record(8,body,null,goal,point);', 'return;'),
]


def edit_method(members, clsname, methodname, transform):
    for path, raw in list(members.items()):
        if not path.endswith('.zs'):
            continue
        text = raw.decode('utf-8-sig').replace('\r\n', '\n')
        found = [m for c in base.audit.declarations(text) if c['name'] == clsname
                 for m in c['methods'] if m['name'] == methodname]
        if not found:
            continue
        assert len(found) == 1, (clsname, methodname)
        m = found[0]
        start, end = m['body_start'], m['body_end']
        members[path] = (text[:start+1] + transform(text[start+1:end]) + text[end:]).encode()
        return
    raise AssertionError((clsname, methodname))


def status_copy(members):
    raw = members['caelum/actors/CaelumElementalStatus.zs'].decode('utf-8-sig')
    cls = next(c for c in base.audit.declarations(raw) if c['name'] == 'CaelumElementalStatus')
    # Match fields only outside method bodies; declarations are interspersed.
    spans = [(m['body_start'], m['body_end']) for m in cls['methods']]
    assignments = []
    for m in re.finditer(r'^\s*(?:transient\s+)?(int|double|bool|Actor|String|Name)\s+([^;\n]+);', raw, re.M):
        if '(' in m[2]:
            continue
        if any(a <= m.start() <= b for a,b in spans):
            continue
        for field in m[2].split(','):
            field = field.strip()
            array = re.fullmatch(r'(\w+)\[(\d+)\]', field)
            if array:
                name, count = array.groups()
                assignments.append(f'for(int i=0;i<{count};i++)dst.{name}[i]=src.{name}[i];')
            else:
                assert re.fullmatch(r'\w+', field), field
                assignments.append(f'dst.{field}=src.{field};')
    assert len(assignments) > 25
    return '\n'.join(assignments)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    args = parser.parse_args()
    assert re.fullmatch(r'issue318-isolation[a-z0-9-]+', args.directory)
    out = ROOT/'build'/args.directory
    out.mkdir(exist_ok=False)
    members = {p.relative_to(ROOT/'src').as_posix(): p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    original = members.copy()
    copy_code = status_copy(members)
    base.replace(members,'/CaelumCombatActor.zs','class CaelumCombatActor : Actor\n{',
                 'class CaelumCombatActor : Actor\n{\n vector3 CA318MouthCache;')
    base.replace(members,'/CaelumConsumables.zs','class CaelumRegenerationPower : Powerup\n{',
                 'class CaelumRegenerationPower : Powerup\n{\n override void Tick(){if(CA318Solo.ActiveNow())return;Super.Tick();}')
    gates = []
    # Freeze does not prevent ZScript overrides running before Super.Tick.
    for path, raw in list(members.items()):
        if not path.endswith('.zs'):
            continue
        text = raw.decode('utf-8-sig').replace('\r\n', '\n')
        edits = []
        for cls in base.audit.declarations(text):
            for m in cls['methods']:
                if m['name'] not in ('Tick','WorldTick','WorldThingSpawned'):
                    continue
                if 'void' not in m['signature']:
                    continue
                edits.append(m['body_start']+1)
                gates.append(cls['name']+'.'+m['name'])
        for at in sorted(edits, reverse=True):
            text = text[:at]+'\n if(CA318Solo.BlockExternal())return;\n'+text[at:]
        if edits:
            members[path] = text.encode()
    for key,(cls,method,record,disabled) in enumerate(METHODS):
        def inject(body, key=key, record=record, disabled=disabled, method=method):
            first='\n if(CA318Solo.BlockExternal())return;\n' if method=='Tick' else ''
            return first+f'\n let p=CA318Solo.Get();\n if(p!=null && p.Active && p.Mode!={key}){{{disabled}}}\n if(p!=null && p.Recording){{{record}}}\n if(p!=null && p.Active)p.Executed[{key}]++;\n'+body
        edit_method(members, cls, method, inject)
    # Keep only the selected numerical/query workload, neutralizing effects.
    stops = [
        ('CaelumThermalRuntime','NPCStep','return;'),
        ('CaelumThermalMotion','Physics','return;'),
        ('CaelumDemonService','UpdatePotions','return;'),
        ('CaelumDemonService','StopBreath','return;'),
        ('CaelumDemonBreath','PaidTick','return;'),
        ('CaelumElementalStatus','DealStatusDamage','return;'),
        ('CaelumElementalStatus','UpdateVisualEffects','return;'),
        ('CaelumPortSiege','Pulse','return false;'),
        ('CaelumCombatActor','CollidedWith','return;'),
        ('CaelumCombatActor','RegisterWorldImpact','return;'),
        ('CaelumCombatActor','RegisterStaticImpactFromVelocityLoss','return;'),
        ('CaelumCombatActor','UpdateImpactContactLatch','return;'),
        ('CaelumRegenerationPower','DoEffect','return;'),
    ]
    for cls,method,ret in stops:
        edit_method(members,cls,method,lambda body,ret=ret:'\n if(CA318Solo.ActiveNow()){'+ret+'}\n'+body)
    edit_method(members,'CaelumDemonService','UpdateBreath',lambda body:body.replace(
        'if(npc.DemonBreath==null)\n        {',
        'if(npc.DemonBreath==null)\n        {\n            if(CA318Solo.ActiveNow())return;'))
    # Keep thermal state lookup as an identity dependency, not another workload.
    edit_method(members,'CaelumThermalBody','Get',lambda body:
        '\n if(CA318Solo.ActiveNow()){let n=CaelumCombatActor(body);if(n!=null)return n.ThermalState;}\n'+body)
    # Direct dispatch must not invoke PortDefender/Mandinga subclass Tick work.
    path='caelum/actors/CaelumCombatActor.zs'
    text=members[path].decode()
    method=next(m for c in base.audit.declarations(text) if c['name']=='CaelumCombatActor'
                for m in c['methods'] if m['name']=='Tick')
    start,end=method['body_start'],method['body_end']
    text=text[:start]+'{CA318SoloTick();}\n void CA318SoloTick()'+text[start:end+1]+text[end+1:]
    members[path]=text.encode()
    solo = (HERE/'solo.zs').read_text(encoding='utf-8').replace('// STATUS_COPY',copy_code)
    members['ca318_solo.zs'] = solo.encode()
    members['ZSCRIPT'] += b'\n#include "ca318_solo.zs"\n'
    members['MAPINFO'] += b'\nGameInfo { AddEventHandlers="CA318Solo" }\n'
    members['CVARINFO'] += b'\nserver bool ca318_solo_start=false; server int ca318_solo_mode=-1; server int ca318_solo_site=0; server int ca318_solo_window=350;\n'
    manifest = {'issue':318,'release':'5.4.41','base_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
                'scope':'35-tic recorded cadence over a fixed siege scene; isolated cores, not normal combat FPS',
                'methods':[{'id':i,'class':c,'method':m} for i,(c,m,_,_) in enumerate(METHODS)],
                'gates':gates,'neutralized':stops,'modified_source_members':[p for p in original if members[p]!=original[p]],
                'source_members':len(original),'runtime_sha256':base.package(out/'production.pk3',members),
                'fixture_sha256':base.package(out/'quick.pk3',{'CA318NOTE':b'Isolated controls; see manifest.json\n'})}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    common='vid_vsync false; vid_maxfps 0; cl_capfps false; con_notifylines 0; vid_fps true; '
    (out/'seed.cfg').write_text(common+'wait 3640; save solo-seed; wait 5; netevent solo_seed_done; wait 5; quit\n')
    (out/'compile.cfg').write_text(common+'wait 10; netevent solo_compile; wait 2; quit\n')
    for mode in range(-1,9):
        (out/f'mode{mode}.cfg').write_text('wait 35; '+common+f'ca318_solo_mode {mode}; ca318_solo_start true; ca318_solo_window 350; wait 140; bench; wait 330; quit\n')
    (out/'solo.zs').write_text(solo,encoding='utf-8')
    print(json.dumps({'directory':args.directory,'methods':len(METHODS),'gates':len(gates),'runtime_sha256':manifest['runtime_sha256']}))


if __name__ == '__main__':
    main()
