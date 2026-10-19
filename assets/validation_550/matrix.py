"""Export the #309 four-input matrix from preserved native catalogue output."""
from pathlib import Path
import argparse
import hashlib
import json
import re

NAMES = ['Sword','Wand','Carbine','Dagger','Hatchet','Machete','Javelin','Axe',
         'Flail','Spear','Greatsword','War axe','Halberd','Giant gauntlets',
         'Shotgun','Longbow','Crossbow','Bell','Book','Statuette','Pickaxe',
         'Utility staff','Bolas']
MAGIC = {1,17,18,19}
RANGED = {2,14,15,16}
EFFECTS = [('Fire/Burn','Light/Dazzle'),('Water/push','Ice/Freeze'),
           ('Earth/Lucidity','Poison'),('Air/Cut','Lightning/Stun'),
           ('Quintessence/double damage','Independent secondary-effect rolls')]


def fields(line):
    values = dict(re.findall(r'(\w+)=([^ ]+)',line.strip()))
    for name,value in values.items():
        try: values[name] = float(value) if '.' in value else int(value)
        except ValueError: pass
    return values


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('log',type=Path)
    p.add_argument('--output',type=Path,default=Path(__file__).with_name('matrix.json'))
    args=p.parse_args()
    text=args.log.read_text(encoding='utf-8-sig')
    assert text.count('CA309 DONE')==1 and 'CA309 DONE passes=112 failures=0' in text
    assert 'CA309 FAIL' not in text and 'VM execution aborted' not in text
    configurations=[fields(line) for line in text.splitlines() if line.startswith('CA309 ROW ')]
    physical={(v['type'],v['tier']):v for line in text.splitlines()
              if line.startswith('CA309 PHYSICAL ') for v in [fields(line)]}
    assert len(configurations)==111 and len(physical)==51
    expected={(kind,tier,essence) for kind in range(23)
              for tier in range(1,2 if kind in (20,21,22) else 4)
              for essence in range(5 if kind in MAGIC else 1)}
    assert {(c['type'],c['tier'],c['essence']) for c in configurations}==expected
    routes=[]
    for c in configurations:
        kind=c['type'];magic=kind in MAGIC;ranged=kind in RANGED
        c['weapon']=NAMES[kind]
        c['value_scope']='Native model base values; final actor attributes, charge, armor and target effects apply at execution.'
        if not magic: c['catalogue_details']=physical[(kind,c['tier'])]
        for button in ('Fire','AltFire','Reload','Zoom'):
            r=dict(type=kind,tier=c['tier'],essence=c['essence'],input=button,
                   status='implemented',identity='Exact equipped item selected by native family adapter; pending release captures item ID.',
                   source='CaelumPlayableWeapons -> CaelumPlayer',evidence=['541','#309 catalogue'],
                   rule='physical',action='primary' if button=='Fire' else 'secondary')
            if magic:
                r.update(rule='magic',effect=EFFECTS[c['essence']][button=='AltFire'],
                         delivery={1:'one direct projectile',17:'twelve independent-critical projectiles',
                                   18:'one homing projectile',19:'one explosive projectile'}[kind],evidence=['529','541','#309 catalogue','#309 native T1 casts: all essences/both faces; count/payment, not victim effects'])
            if ranged:
                r.update(rule='ranged',ammo={2:'CaelumCarbineAmmo',14:'CaelumShotgunAmmo',15:'CaelumArrowAmmo',16:'CaelumBoltAmmo'}[kind],evidence=['5210','541','#309 auto/reload'])
                if button=='AltFire':r.update(action='toggle ADS once per press',rule='aim')
            if kind==6 and button=='AltFire':r.update(action='throw; close-target melee fallback',rule='javelin')
            if kind==9 and button=='AltFire':r.update(status='intentionally unauthored',action='no attack',rule='none')
            if kind==13 and button=='AltFire':r.update(action='blunt uppercut with upward push',evidence=['#309 gauntlet'])
            if kind==21:r.update(rule='stream',source='CaelumPlayableWeapons -> CaelumPlayer -> CaelumUtilityStaff',action='held fire/heat' if button=='Fire' else 'held ice/cooling',evidence=['5115','5212'])
            if kind==22:r.update(rule='bolas',source='CaelumBolas.Update / Throw',action='throw actual item' if button=='Fire' else 'hold preparation to reduce dispersion',evidence=['541','5212'])
            if button=='Reload':
                r.update(rule='reload' if ranged else 'charge',action='one request per press',evidence=['#309 reload/persistence/boundaries'])
                if kind in (21,22):r.update(status='intentional no-op for this weapon',rule='none',action='no weapon charge; restraint cutting has its separate controller')
            if button=='Zoom':
                if ranged:r.update(rule='aim',action='toggle ADS once per press')
                elif kind in (10,11,12):r.update(rule='sweep',action='one 360-degree sweep per press')
                else:r.update(rule='block',action='gauntlet weapon block' if kind==13 else 'shield block when compatible shield is equipped')
            if button in ('Reload','Zoom'):
                r.pop('effect',None);r.pop('delivery',None)
            routes.append(r)
    assert len(routes)==444
    rules={
      'physical':dict(owner='BeginPhysicalAttackCycle -> PerformDebugSwordAttack / CaelumWeaponUseRules',
          target='LineAttack with catalogue melee range in MU, actual anatomy/armor/contact; one hit.',
          cadence='CaelumAttackRules.Duration: BASE_TICS adjusted by attributes and weapon/glove weight versus capacity.',
          costs='Catalogue primary/secondary Air, actor consumption and heat multipliers; charged cost/damage x2.',
          wear='Damage-based wear on captured actual item; charge captured/consumed when preparation is accepted, restored only for the pending impact calculation.',
          interruptions='Existing menus, immobilization, cooldown, item/identity changes and pending-action guards.'),
      'magic':dict(owner='PerformDebugStaffAttack -> ReleasePendingStaffAttack -> CaelumMagicProjectiles / projectile effects',
          target='Essence effect on struck body; Book homes; Statuette area is authored explosion, charged area x2.',
          cadence='Existing casting/recovery clock, attributes and implement weight.',
          costs='Base Anima x tier 1/1.6/2.5 x charge 1/2 / Eloquence divisor, paid once per cast.',
          wear='Captured exact item and existing successful-effect wear; no extra payment per Bell projectile.',
          interruptions='Existing pending cast, insufficient Anima, cooldown, menus, immobilization and item changes.'),
      'ranged':dict(owner='BeginPhysicalAttackCycle -> PerformCarbineAttack -> CaelumRangedRules / CaelumShotgunRules',
          target='Native projectile, range in catalogue meters converted to MU; authored penetration exclusions; shotgun twelve pellets per cartridge.',
          cadence='Physical preparation/recovery; empty-magazine Fire requests idempotent reload.',
          costs='One ammunition unit and existing Air per shot; independent magazines and migration unchanged.',
          wear='Existing item-ID wear routing, independent of number of pellets/victims.',
          interruptions='Existing attack guards; active reload blocks shot until completion.'),
      'charge':dict(owner='RequestWeaponReloadOrCharge / UpdateWeaponCharge',target='Self/next attack',
          cadence='2 s base adjusted by attack/casting multiplier; 3 s prepared window.',
          costs='No attack payment until execution; next accepted attack pays x2.',wear='No damage-based wear during preparation.',
          interruptions='Item mismatch, immobilization, block and existing cancellation; held R does not restart after expiry.'),
      'reload':dict(owner='RequestRangedReload / UpdateRangedReload',target='Self/current magazine',
          cadence='CaelumRangedRules reload duration and existing progress multiplier.',
          costs='Existing reserve/capacity rule and firearm muscular heat; repeated requests do not begin heat again.',
          wear='No new reload wear.',interruptions='Item mismatch, block, immobilization; empty reserve cannot start.'),
      'aim':dict(owner='ToggleRangedAim and native A_ZoomFactor',target='Self',cadence='Latched toggle until release.',
          costs='Existing doubled accuracy/FOV rules; no new charge.',wear='None.',interruptions='Existing reload, block, charge and item-change rules.'),
      'block':dict(owner='ToggleCombatBlockMode',target='Self/coverage',cadence='Latched Zoom toggle.',
          costs='Existing shield/gauntlet defense and received-hit resource rules.',wear='Existing defense item rules.',
          interruptions='Compatible equipment required; ordinary attacks cancel block; utility stream is interrupted by block.'),
      'sweep':dict(owner='PerformLargeWeaponSweep -> BeginPhysicalAttackCycle',target='Nearby valid enemies, line of sight, primary range; one hit per body.',
          cadence='Primary duration, one execution per Zoom press.',costs='3x primary Air once; charged 6x, never per body.',
          wear='Actual successful-hit wear; captured item ID.',interruptions='Existing cooldown, resource, cast, charge and immobilization guards.'),
      'javelin':dict(owner='HasJavelinMeleeFallbackTarget / physical release',target='Close melee target or native thrown projectile.',
          cadence='Existing physical cycle; secondary input latched.',costs='Catalogue Air once.',
          wear='One durability on a real throw; ordinary damage-based wear on fallback.',interruptions='Existing physical guards and exact-item identity.'),
      'stream':dict(owner='CaelumUtilityStaff / CaelumElementalStream',target='Bounded visible contact stream; existing #162 range/heat rules.',
          cadence='Held input, continuous cost with existing contact cadence.',costs='Anima per second from shared breath rules and actor modifiers.',
          wear='Contact damage-based wear, no free repeated victim payment.',interruptions='Release, block, immobilization, depleted Anima, equipment change.'),
      'bolas':dict(owner='CaelumBolas',target='Native projectile and existing restraint eligibility.',
          cadence='AltFire preparation to authored limit; Fire throw.',costs='Existing Air once; actual item transferred out of inventory.',
          wear='Binary integrity, no wear.',interruptions='Existing preparation/restraint/cooldown/equipment guards.'),
      'none':dict(owner='Explicit catalogue/controller no-op',target='None',cadence='None',costs='None',wear='None',interruptions='Not an authored attack.')}
    report=dict(issue=309,release='5.5.0',native_log=args.log.as_posix(),
        log_sha256=hashlib.sha256(args.log.read_bytes()).hexdigest(),
        limitation='Catalogue rows verify selectors/metadata, not 444 newly executed keyboard cases. Accepted evidence is reused where production is unchanged.',
        evidence={'529':'#192 magic/projectiles/cost/personality', '5210':'#192 ranged penetration and actual shotgun controls/save',
          '541':'#259 dispersion, physical/magic/player/NPC release coverage','5115':'#162 continuous utility-staff input',
          '5212':'#195 resident tools, bolas and native player regressions'},
        configurations=configurations,rules=rules,routes=routes)
    args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f'{len(configurations)} configurations; {len(routes)} input routes; {args.output}')


if __name__=='__main__':main()
