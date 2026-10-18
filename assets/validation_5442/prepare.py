"""Build private 100-tic scheduling experiments without changing production code."""
from pathlib import Path
import argparse
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('solo_tools', ROOT/'assets/validation_5441/prepare.py')
solo = importlib.util.module_from_spec(spec)
spec.loader.exec_module(solo)
base = solo.base


def method(members, clsname, name):
    for path, raw in members.items():
        if not path.endswith('.zs'): continue
        text = raw.decode('utf-8-sig').replace('\r\n', '\n')
        for cls in base.audit.declarations(text):
            if cls['name'] != clsname: continue
            for m in cls['methods']:
                if m['name'] == name: return path, text, m
    raise AssertionError((clsname, name))


def wrap(members, cls, name, wrapper):
    path, text, m = method(members, cls, name)
    start, end = m['body_start'], m['body_end']
    signature = m['signature'].replace('override ', '').replace('virtual ', '')
    signature = re.sub(r'\b'+name+r'\s*\(', 'CA318Raw'+name+'(', signature)
    members[path] = (text[:start]+'{\n'+wrapper+'\n}\n'+signature+'\n'+text[start:end+1]+text[end+1:]).encode()


HEALTH_OUT = ['CombatHealthState','CombatHealthPerformanceMultiplier','CombatHealthPainMultiplier',
              'CombatAdrenalineGainMultiplier','EffectiveCombatEvasionChance','Speed']
OFFENSE_OUT = ['CombatEffectiveDexterity','CombatEffectiveInsight','CombatEffectiveIntelligence',
               'CombatPhysicalAccuracyPercent','CombatMagicalAccuracyPercent',
               'CombatPhysicalCriticalChancePercent','CombatMagicalCriticalChancePercent',
               'CombatPhysicalPushMultiplier','CombatMagicalPushMultiplier']
COMMON = ['Mass'] + [f'(CombatArmor!=null ? CombatArmor.{field}[{i}] : -1)' for field in ['ArmorType','Tier','Durability'] for i in range(4)]
PERSONALITY = ['(CombatPersonality!=null ? CombatPersonality.PersonalityRevision : -1)'] + [f'(CombatPersonality!=null ? CombatPersonality.Personality[{i}] : -1)' for i in range(4)]
HEALTH_IN = COMMON + PERSONALITY + ['health','CombatMaximumHealth','CombatPatience','CombatAgility',
    'CurrentCombatAdrenaline','MaximumCombatAdrenaline','CombatBaseSpeed','CaelumThermalEffects.Speed(self)',
    '(ElementalStatus!=null ? ElementalStatus.GetMovementMultiplier() : 1.0)']
OFFENSE_IN = COMMON + PERSONALITY + ['CombatDexterity','CombatInsight','CombatIntelligence','CombatStrength']


def cache_wrapper(name, key, inputs, outputs):
    letters = 'HO'
    tag = letters[key]
    code = [f'if(CA318Work==null || (CA318Work.Mode&1)==0){{CA318Raw{name}();return;}}',
            'let w=CA318Work;',f'w.Requested[{key}]++;',
            f'bool changed=!w.{tag}Ready || level.time>=w.{tag}Due;']
    for i, value in enumerate(inputs):
        code += [f'double d{i}={value};', f'if(w.{tag}Inputs[{i}]!=d{i})changed=true;']
    code += ['if(changed){', f'w.Computed[{key}]++;', f'CA318Raw{name}();']
    for i in range(len(inputs)): code += [f'w.{tag}Inputs[{i}]=d{i};']
    for i, value in enumerate(outputs): code += [f'w.{tag}Outputs[{i}]={value};']
    code += [f'w.{tag}Ready=true;w.{tag}Due=w.NextDue();', '}else{']
    # Derived outputs are assignments, not one-time effects: reload changes Speed.
    for i, value in enumerate(outputs):
        cast = 'int' if value in ['CombatHealthState','CombatEffectiveDexterity','CombatEffectiveInsight','CombatEffectiveIntelligence'] else 'double'
        code += [f'{value}={cast}(w.{tag}Outputs[{i}]);']
    code += [f'if(w.Audit){{CA318Raw{name}();']
    for i, value in enumerate(outputs): code += [f'if({value}!=w.{tag}Outputs[{i}])w.Failure("{name}:{value}");']
    code += ['}}']
    return '\n'.join(code)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',required=True)
    parser.add_argument('--extended-checks',action='store_true',help='Add effective armor and survival-consumption checks; measurement logic is unchanged.')
    args=parser.parse_args()
    assert re.fullmatch(r'issue318-stagger[a-z0-9-]+',args.directory)
    out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
    members={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    original=members.copy()
    base.replace(members,'/CaelumCombatActor.zs','class CaelumCombatActor : Actor\n{',
                 'class CaelumCombatActor : Actor\n{\n CA318Work CA318Work;\n Array<CaelumSiegeCombatant> CA318TargetUsers;')
    base.replace(members,'/CaelumCombatActor.zs',' Array<CaelumSiegeCombatant> CA318TargetUsers;',
        ''' Array<CaelumSiegeCombatant> CA318TargetUsers;
 override void AddInventory(Inventory item){Super.AddInventory(item);CA318Work.InventoryChanged(self);}
 override void RemoveInventory(Inventory item){Super.RemoveInventory(item);CA318Work.InventoryChanged(self);}
 override bool UseInventory(Inventory item){bool used=Super.UseInventory(item);CA318Work.InventoryChanged(self);return used;}
''')
    wrap(members,'CaelumCombatActor','UpdateCombatHealthEffects',cache_wrapper('UpdateCombatHealthEffects',0,HEALTH_IN,HEALTH_OUT))
    wrap(members,'CaelumCombatActor','UpdateActorOffensiveStatistics',cache_wrapper('UpdateActorOffensiveStatistics',1,OFFENSE_IN,OFFENSE_OUT))
    weight_inputs=[f'(CombatArmor!=null ? CombatArmor.{field}[{i}] : -1)' for field in ['ArmorType','Tier','Size'] for i in range(4)]
    code=['if(CA318Work==null || (CA318Work.Mode&2)==0)return CA318RawGetAttackCarriedWeight();',
          'let w=CA318Work;w.Requested[2]++;bool changed=!w.WReady || level.time>=w.WDue || w.InvHead!=Inv;']
    for i,value in enumerate(weight_inputs): code += [f'double d{i}={value};if(w.WInputs[{i}]!=d{i})changed=true;']
    code += ['if(changed){w.Computed[2]++;w.Weight=CA318RawGetAttackCarriedWeight();w.InvHead=Inv;w.WReady=true;w.WDue=w.NextDue();']
    for i in range(len(weight_inputs)):code += [f'w.WInputs[{i}]=d{i};']
    code += ['}else if(w.Audit && w.Weight!=CA318RawGetAttackCarriedWeight())w.Failure("weight");return w.Weight;']
    wrap(members,'CaelumCombatActor','GetAttackCarriedWeight','\n'.join(code))
    # Saturated resources need no recovery; active resources keep exact original steps.
    path,text,m=method(members,'CaelumCombatActor','Tick')
    begin=text.index('        double idleFactor=IsCombatIdle()',m['body_start'])
    end=text.index('        if (CombatLucidityPhysicalStunRemaining',begin)
    resource=text[begin:end]
    resources='''
        bool caRecover=true;
        if(CA318Work!=null && (CA318Work.Mode&4)!=0)
        {
            CA318Work.Requested[3]++;
            caRecover=level.time>=CA318Work.RDue || health<CombatMaximumHealth
                || CurrentCombatAnima<MaximumCombatAnima || CurrentCombatAir<MaximumCombatAir
                || CurrentCombatLucidity<CaelumConstants.MAXIMUM_LUCIDITY;
            if(caRecover){CA318Work.Computed[3]++;CA318Work.RDue=CA318Work.NextDue();}
        }
        if(caRecover){
'''+resource+'\n        }\n'
    members[path]=(text[:begin]+'CA318Resources(sleeping);\n'+text[end:]).encode()
    base.replace(members,'/CaelumCombatActor.zs','class CaelumCombatActor : Actor\n{',
        'class CaelumCombatActor : Actor\n{\n void CA318Resources(bool sleeping){'+resources+'}\n void CA318RawResources(bool sleeping){'+resource+'}\n')
    # Direct notifications on native ownership/pickup/use paths. No polling registry.
    hooks='''
 override Inventory CreateTossable(int amt){let old=Owner;let result=Super.CreateTossable(amt);CA318Work.InventoryChanged(old);return result;}
'''
    for cls,path in [('CaelumConsumableItem','caelum/equipment/CaelumConsumables.zs')]:
        text=members[path].decode('utf-8-sig').replace('\r\n','\n')
        text=re.sub(r'(class '+cls+r'\s*:\s*\w+\s*\{)',lambda m:m[0]+hooks,text,count=1)
        members[path]=text.encode()
    # Wrap existing equipment stack handler; consumable inherits the native one.
    wrap(members,'CaelumEquipmentItem','HandlePickup','bool result=CA318RawHandlePickup(item);CA318Work.InventoryChanged(Owner);return result;')
    wrap(members,'CaelumEquipmentItem','CreateTossable','let old=Owner;let result=CA318RawCreateTossable(tossAmount);CA318Work.InventoryChanged(old);return result;')
    path='caelum/equipment/CaelumConsumables.zs'
    text=members[path].decode();needle='class CaelumConsumableItem : PowerupGiver\n{'
    text=text.replace(needle,needle+'\n override bool HandlePickup(Inventory item){bool result=Super.HandlePickup(item);CA318Work.InventoryChanged(Owner);return result;}')
    members[path]=text.encode()
    solo.edit_method(members,'CaelumConsumableItem','Use',lambda b:b.replace('return used;','CA318Work.InventoryChanged(Owner);return used;'))
    solo.edit_method(members,'CaelumDemonService','UpdatePotions',lambda b:b.replace('npc.UseInventory(item);','npc.UseInventory(item);CA318Work.InventoryChanged(npc);'))
    solo.edit_method(members,'CaelumDemonService','ReleaseLoot',lambda b:b.replace('supply.Amount--;','supply.Amount--;CA318Work.InventoryChanged(npc);'))
    # Damage callbacks invalidate only the affected body and its subscribed groups.
    # The group's local target cache still performs native visibility/range checks.
    base.replace(members,'/CaelumPortSiege.zs','class CaelumPortSiege : CaelumSiegeEncounter\n{',
        'class CaelumPortSiege : CaelumSiegeEncounter\n{\n int CA318Mode;int CA318Queries;')
    solo.edit_method(members,'CaelumPortSiege','UpdateSharedTarget',lambda b:b.replace(
        'leader.NextSharedTargetTic=level.time+CaelumPortData.TARGET_UPDATE_TICS;',
        '''leader.NextSharedTargetTic=level.time+CaelumPortData.TARGET_UPDATE_TICS;
        CA318Queries++;
        if((CA318Mode&8)!=0){
            int phase=Max(0,leader.CommandGroup)*CA318Work.PERIOD/Max(1,Groups);
            leader.NextSharedTargetTic=level.time+1+(phase-(level.time+1)%CA318Work.PERIOD+CA318Work.PERIOD)%CA318Work.PERIOD;
            let victim=CaelumCombatActor(leader.SharedTarget);
            if(victim!=null){bool found=false;for(int i=0;i<victim.CA318TargetUsers.Size();i++)if(victim.CA318TargetUsers[i]==leader)found=true;if(!found)victim.CA318TargetUsers.Push(leader);}
        }'''))
    # Temperature already uses 35-tic scheduling; only the relaxed variant uses 100.
    solo.edit_method(members,'CaelumThermalRuntime','NPCStep',lambda b:
        b.replace('if(npc.health<=0)return;', '''if(npc.health<=0)return;
        bool caThermal=npc.CA318Work!=null && (npc.CA318Work.Mode&16)!=0;
        if(caThermal && npc.ThermalState!=null && (npc.CurSector!=npc.CA318Work.LastSector || npc.WaterLevel!=npc.ThermalState.LastWaterLevel))force=true;''')
        .replace('1+world.NextPhase++%TICRATE','1+world.NextPhase++%(caThermal?CA318Work.PERIOD:TICRATE)')
        .replace('thermal.NextUpdateTic=level.maptime+TICRATE;', '''thermal.NextUpdateTic=level.maptime+TICRATE;
        if(caThermal){
            npc.CA318Work.Computed[4]++;npc.CA318Work.LastSector=npc.CurSector;
            thermal.NextUpdateTic=level.maptime+1+(npc.CA318Work.Phase-(level.maptime+1)%CA318Work.PERIOD+CA318Work.PERIOD)%CA318Work.PERIOD;
        }'''))
    # Count original thermal and target bodies, all branches use the same counters.
    for key,name in enumerate(['CA318RawUpdateCombatHealthEffects','CA318RawUpdateActorOffensiveStatistics','CA318RawGetAttackCarriedWeight']):
        solo.edit_method(members,'CaelumCombatActor',name,lambda b,key=key:f'\n if(CA318Work!=null)CA318Work.RawCalls[{key}]++;\n'+b)
    # Author-requested maximum adrenaline; a separate bit isolates algebraic simplification.
    solo.edit_method(members,'CaelumCombatActor','Tick',lambda b:
        '\n if(CA318Work!=null && (CA318Work.Mode&32)!=0)CurrentCombatAdrenaline=MaximumCombatAdrenaline;\n'+b.replace(
            'else if (CurrentCombatAdrenaline > 0.0)',
            'else if (CurrentCombatAdrenaline > 0.0 && (CA318Work==null || (CA318Work.Mode&32)==0))'))
    solo.edit_method(members,'CaelumCombatActor','GetCombatAdrenalineRatio',lambda b:
        '\n if(CA318Work!=null && (CA318Work.Mode&32)!=0 && MaximumCombatAdrenaline>0)return 1;\n'+b)
    # The author keeps hunger/thirst consumption and damage; maximum adrenaline
    # already suppresses their performance penalty in the existing player rule.
    path='caelum/player/CaelumPlayer.zs'
    text=members[path].decode('utf-8-sig').replace('\r\n','\n')
    text,count=re.subn(r'(class CaelumPlayer\s*:\s*\w+\s*\{)',r'\1\n bool CA318SiegeFocus;',text,count=1)
    assert count==1
    members[path]=text.encode()
    for name in ['UpdateSurvivalStates','UpdateHealthStateEffects','UpdateAdrenalineDecay']:
        solo.edit_method(members,'CaelumPlayerResources',name,lambda b,name=name:
            b.replace('if (!CaelumPlayerAuthority.CanMutate(user)) return;',
                'if (!CaelumPlayerAuthority.CanMutate(user)) return;\n if(user.CA318SiegeFocus && user.DerivedStats!=null)user.CurrentAdrenaline=user.DerivedStats.MaximumAdrenaline;')
            .replace('if (user.CurrentAdrenaline <= 0.0)', 'if(user.CA318SiegeFocus)return;\n if (user.CurrentAdrenaline <= 0.0)' if name=='UpdateAdrenalineDecay' else 'if (user.CurrentAdrenaline <= 0.0)'))
    fast='''
        if(CA318Work!=null && (CA318Work.Mode&96)==96 && MaximumCombatAdrenaline>0)
        {
            CA318Work.RawCalls[0]++;
            double ratio=CombatMaximumHealth>0?Clamp(double(health)/CombatMaximumHealth,0,1):1;
            double intensity=1;
            if(ratio<=CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD){CombatHealthState=CaelumConstants.HEALTH_STATE_BADLY_WOUNDED;intensity=CaelumConstants.HEALTH_BADLY_WOUNDED_INTENSITY_MULTIPLIER;}
            else if(ratio<=CaelumConstants.HEALTH_WOUNDED_THRESHOLD){CombatHealthState=CaelumConstants.HEALTH_STATE_WOUNDED;intensity=CaelumConstants.HEALTH_WOUNDED_INTENSITY_MULTIPLIER;}
            else CombatHealthState=CaelumConstants.HEALTH_STATE_NORMAL;
            CombatHealthPerformanceMultiplier=1;CombatHealthPainMultiplier=1;
            CombatAdrenalineGainMultiplier=intensity*CaelumPersonalityRules.Adrenaline(self);
            int agility=CombatAgility+GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_AGILITY);
            EffectiveCombatEvasionChance=CaelumGrowthRules.Bonus(agility)*(100.0/(Mass/2.0+50.0))*CaelumPersonalityRules.Evasion(self);
            Speed=CombatBaseSpeed*CaelumThermalEffects.Speed(self)*(ElementalStatus!=null?ElementalStatus.GetMovementMultiplier():1);
            return;
        }
'''
    path,text,m=method(members,'CaelumCombatActor','CA318RawUpdateCombatHealthEffects')
    reference=text[m['body_start']:m['body_end']+1]
    base.replace(members,'/CaelumCombatActor.zs','class CaelumCombatActor : Actor\n{',
        'class CaelumCombatActor : Actor\n{\n void CA318ReferenceHealth()'+reference+'\n')
    solo.edit_method(members,'CaelumCombatActor','CA318RawUpdateCombatHealthEffects',lambda b:fast+b)
    solo.edit_method(members,'CaelumCombatActor','CA318Resources',lambda b:b.replace('if(caRecover){\n','if(caRecover){\n if(CA318Work!=null)CA318Work.RawCalls[3]++;'))
    solo.edit_method(members,'CaelumThermalRuntime','NPCStep',lambda b:b.replace('double dr=Max(',
        '''if(npc.CA318Work!=null){npc.CA318Work.RawCalls[4]++;if(force)npc.CA318Work.ThermalForced++;else npc.CA318Work.ThermalPeriodic++;}
        double dr=Max('''))
    members['ca318_work.zs']=(HERE/'work.zs').read_bytes()
    probe=(HERE/'probe.zs').read_text(encoding='utf-8')
    probe=probe.replace('void Checks(){Console.Printf("CA282 DONE passes=1 failures=0");}',(HERE/'checks.zs').read_text(encoding='utf-8'))
    if args.extended_checks:
        probe=probe.replace('    int CheckPasses,CheckFailures;', (HERE/'extended_checks.zs').read_text(encoding='utf-8')+'\n    int CheckPasses,CheckFailures;')
        probe=probe.replace('        ThermalChecks();','        ExtendedChecks(npc,user);\n        ThermalChecks();')
    members['ca318_probe.zs']=probe.encode()
    members['ZSCRIPT']+=b'\n#include "ca318_work.zs"\n#include "ca318_probe.zs"\n'
    members['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA318StaggerProbe" }\n'
    members['CVARINFO']+=b'\nserver int ca318_stagger_mode=0; server bool ca318_stagger_start=false; server bool ca318_stagger_audit=false; server int ca318_stagger_site=0; server bool ca318_stagger_checks=false;\n'
    manifest={'issue':318,'release':'5.4.42','source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'measurement_start_tic':3750,
        'period':100,'modes':{'0':'baseline','1':'statistics','2':'inventory','4':'saturated resources','7':'stats+inventory+resources','15':'7+targets100','23':'7+thermal100','31':'all','39':'7+maximum adrenaline, original formulas','103':'39+simplified wound formulas','127':'all+maximum adrenaline+simplification'},
        'modified_source_members':[p for p in original if members[p]!=original[p]],
        'runtime_sha256':base.package(out/'production.pk3',members),
        'fixture_sha256':base.package(out/'quick.pk3',{'CA318NOTE':b'Private scheduling trial; not production adoption.\n'})}
    if args.extended_checks:manifest['extended_checks']='Effective armor types, break/repair and survival consumption; only inactive test methods differ.'
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    common='vid_vsync false; vid_maxfps 0; cl_capfps false; vid_fps true; con_notifylines 0; '
    (out/'seed.cfg').write_text(common+'wait 3640; save stagger-seed; wait 5; netevent stagger_seed_done; wait 2; quit\n')
    (out/'compile.cfg').write_text(common+'wait 10; netevent stagger_compile; wait 2; quit\n')
    (out/'checks.cfg').write_text(common+'ca318_stagger_checks true; wait 180; netevent stagger_checks_done; wait 3; quit\n')
    for mode in manifest['modes']:
        (out/f'mode{mode}.cfg').write_text('wait 35; '+common+f'ca318_stagger_mode {mode}; ca318_stagger_start true; wait 250; bench; wait 600; quit\n')
    for name in ['work.zs','probe.zs']:(out/name).write_bytes((HERE/name).read_bytes())
    print(json.dumps(manifest))


if __name__=='__main__': main()
