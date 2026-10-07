"""Reproduce the #119 extraction from the accepted 5.0.2 source.

Serialized fields and legacy signatures stay in their original classes.
The manifest records each moved body for independent equivalence checks.
"""
from pathlib import Path
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT/'assets/validation_500'))
from audit_sources import declarations, mask

BASE = '135ae0f91de84a7d4f4b3c0f803da254aeacd0ad'
SERVICE = 'src/caelum/core/CaelumTarotService.zs'
sources, edits, manifest = {}, {}, []
output = ['// #119: una implementación de Tarot, sin una segunda copia del estado.\n',
          '// El Inventory viajero conserva campos y revisiones; el servicio recibe al propietario.\n',
          'class CaelumTarotService : Object play\n{\n',
          '    const REVISION = 1;\n\n']


def source(path):
    if path not in sources:
        sources[path] = subprocess.check_output(['git','show',f'{BASE}:{path}'],cwd=ROOT).decode('utf-8')
    return sources[path]


def move(path, cls, name, target=None, receiver=None, pure=False, replacements=()):
    original = source(path)
    decl = next(c for c in declarations(original) if c['name']==cls)
    method = next(m for m in decl['methods'] if m['name']==name)
    sig = method['signature']
    params = sig[sig.index('(')+1:sig.rindex(')')]
    args = [p.split('=')[0].split()[-1] for p in params.split(',') if p.strip()]
    body = original[method['body_start']:method['body_end']+1]
    target = target or name
    if receiver:
        fields = set()
        for field in decl['fields']:
            for part in field['declaration'].split(','):
                fields.add(re.sub(r'\[.*','',part.split()[-1]))
        fields.update(m['name'] for m in decl['methods'])
        if cls=='CaelumPersistentCharacterState':
            fields.update(['QuestObjectiveKnown','QuestObjectiveTarget','QuestObjectiveProgress'])
        clean = mask(body)
        changes=[]
        for token in re.finditer(r'\b\w+\b', clean):
            word=token.group()
            if clean[:token.start()].rstrip().endswith('.'): continue
            if word in fields and word not in args:
                changes.append((token.start(),token.end(),receiver+'.'+word))
        for a,b,v in reversed(changes): body=body[:a]+v+body[b:]
        params=cls+' '+receiver+(', '+params if params.strip() else '')
    for a,b in replacements: body=body.replace(a,b)
    prefix=sig[:sig.index(name)].replace('static ','').replace('clearscope ','')
    output.append('    static '+('clearscope ' if pure else '')+prefix+target+'('+params+')\n    '+body+'\n\n')
    call='CaelumTarotService.'+target+'('+', '.join((['self'] if receiver else [])+args)+');'
    if prefix.strip()!='void': call='return '+call
    edits.setdefault(path,[]).append((method['body_start'],method['body_end']+1,'{ '+call+' }'))
    manifest.append(dict(path=path,cls=cls,name=name,target=target,receiver=receiver,pure=pure,replacements=replacements))


P='src/caelum/core/CaelumTarotPowers.zs'
for name in ['EnsureRevision','ValidUser','Feedback','Implemented','SelectedCount','Select','Activate','Advance']:
    move(P,'CaelumTarotPowers',name,pure=name in ['Implemented','SelectedCount'])
R='src/caelum/equipment/CaelumPersistentCharacterState.zs'
for name in ['HasTarotCard','CountTarotCards','GetTarotAttributeBonusPercent','GetTarotMinorBaseBonus','CanCaptureMainM00Fool','RecordMainM00FoolCapture']:
    move(R,'CaelumPersistentCharacterState',name,receiver='record',pure=name in ['HasTarotCard','CountTarotCards','GetTarotAttributeBonusPercent','GetTarotMinorBaseBonus'],
         replacements=[('CaelumTarotDetails.MinorTenths(', 'MinorTenths(')])
T='src/caelum/trucazo/CaelumTrucazoRules.zs'
for name in ['Suit','Rank','Minor']: move(T,'CaelumTrucazoRules',name,pure=True)
move('src/caelum/core/CaelumTarotDetails.zs','CaelumTarotDetails','MinorTenths',pure=True,
     replacements=[('CaelumTrucazoRules.', '')])
move('src/caelum/quests/CaelumArcanaProgress.zs','CaelumArcanaProgress','CanCapture','CanCaptureArcana')
C='src/caelum/quests/CaelumMainM00FoolCapture.zs'
for name in ['CanApproach','CommitCapture']:
    move(C,'CaelumMainM00FoolCapture',name,replacements=[('HasOwnedBox(user)', 'CaelumMainM00FoolCapture.HasOwnedBox(user)')])
for name in ['IsAvailable','IsRevealedFor','RecordCapture']:
    move(C,'CaelumM00FoolEssence',name,receiver='essence')

output.append('''    // Lecturas comunes para UI, vuelo y viajes: nunca avanzan el reloj.
    static clearscope int EffectTics(CaelumPersistentCharacterState record)
    { return record == null ? 0 : record.TarotEffectTics; }
    static clearscope int CooldownTics(CaelumPersistentCharacterState record)
    { return record == null ? 0 : record.TarotCooldownTics; }
    static clearscope bool IsActive(CaelumPersistentCharacterState record, int card)
    { return EffectTics(record) > 0 && card >= 0 && card < CaelumConstants.TAROT_CARD_COUNT && record.TarotActive[card]; }
    static clearscope bool IsSelected(CaelumPersistentCharacterState record, int card)
    { return record != null && card >= 0 && card < CaelumConstants.TAROT_CARD_COUNT && record.TarotSelected[card]; }

    // La propiedad física sigue perteneciendo al contrato de inventario.
    static bool HasPhysicalDeck(CaelumPlayer user)
    { return CaelumInventoryService.FindOwnedTarotDeck(user) != null; }

    // GZDoom retira PowerFlight al salir de un hub. El registro conserva el
    // efecto pagado: reponer sólo la instancia ausente, sin pagar ni reiniciar.
    static void RestoreNativeEffect(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || (user.player.cheats & CF_PREDICTING)) return;
        let record = user.GetPersistentCharacterState(false);
        if (IsActive(record, CaelumConstants.TAROT_THE_FOOL)
            && user.FindInventory("CaelumTarotFlight") == null)
            user.GiveInventoryType("CaelumTarotFlight");
    }

    static void Reveal(CaelumPersistentCharacterState record, int card)
    {
        if (card == CaelumConstants.TAROT_THE_FOOL) record.MainM00FoolRevealed = true;
        else record.ArcanaRevealed[card] = true;
    }
''')

# Keep the existing presentation fields as read-only projections, not owners.
V='src/caelum/player/CaelumPlayerPresentation.zs'
v=source(V)
a=v.index('        CaelumTarotPowers.EnsureRevision(persistentState);')
b=v.index('        user.JournalPalomoPlacement',a)
snapshot=v[a:b].replace('CaelumTarotPowers.EnsureRevision','EnsureRevision')
output.append('    static void RefreshJournalSnapshot(CaelumPlayer user, CaelumPersistentCharacterState persistentState)\n    {\n'+snapshot+'    }\n')
edits[V]=[(a,b,'        CaelumTarotService.RefreshJournalSnapshot(user, persistentState);\n')]
output.append('}\n')

for path,changes in edits.items():
    result=source(path)
    for a,b,value in sorted(changes,reverse=True): result=result[:a]+value+result[b:]
    if path==C:
        result=result.replace('if (CardId() == CaelumConstants.TAROT_THE_FOOL) record.MainM00FoolRevealed = true;\n            else record.ArcanaRevealed[CardId()] = true;',
                              'CaelumTarotService.Reveal(record, CardId());')
    (ROOT/path).write_text(result,encoding='utf-8',newline='\n')
service=''.join(output)
# Internal operations call their implementation directly, without adapter round trips.
for method in ['HasTarotCard','CountTarotCards','GetTarotAttributeBonusPercent','GetTarotMinorBaseBonus','CanCaptureMainM00Fool','RecordMainM00FoolCapture']:
    for record in ['record','persistentState']:
        service=service.replace(record+'.'+method+'()',method+'('+record+')')
        service=service.replace(record+'.'+method+'(',method+'('+record+', ')
service=service.replace('CaelumArcanaProgress.CanCapture(', 'CanCaptureArcana(')
for method in ['IsAvailable','IsRevealedFor','RecordCapture']:
    service=service.replace('essence.'+method+'(',method+'(essence, ')
advance=next(m for m in declarations(service)[0]['methods'] if m['name']=='Advance')
service=service[:advance['body_end']]+'    RestoreNativeEffect(user);\n    '+service[advance['body_end']:]
(ROOT/SERVICE).write_text(service,encoding='utf-8',newline='\n')

# Explicit domain consumers; adapters remain callable for serialized classes and old callers.
routes=['src/caelum/player/CaelumPlayer.zs','src/caelum/hud/CaelumJournalOverlay.zs',
        'src/caelum/hud/CaelumHUDOverlay.zs','src/caelum/world/CaelumJourneyPlan.zs',
        'src/caelum/trucazo/CaelumTrucazoMatch.zs','src/caelum/trucazo/CaelumTrucoMatch.zs']
for path in routes:
    result=source(path).replace('CaelumTarotPowers.','CaelumTarotService.')
    result=result.replace('CaelumTarotDeckRules.Owned(', 'CaelumTarotService.HasPhysicalDeck(')
    result=result.replace('record.TarotEffectTics','CaelumTarotService.EffectTics(record)').replace('record.TarotCooldownTics','CaelumTarotService.CooldownTics(record)')
    result=result.replace('record.TarotSelected[card]','CaelumTarotService.IsSelected(record, card)')
    result=result.replace('record.TarotActive[selected]','CaelumTarotService.IsActive(record, selected)')
    result=result.replace('record.HasTarotCard(card)','CaelumTarotService.HasTarotCard(record, card)')
    if path.endswith('/CaelumPlayer.zs'):
        result=result.replace('Super.Travelled();\n        RestorePersistentCharacterState();',
                              'Super.Travelled();\n        RestorePersistentCharacterState();\n        CaelumTarotService.RestoreNativeEffect(self);')
    (ROOT/path).write_text(result,encoding='utf-8',newline='\n')

# Native PowerFlight remains a lifecycle adapter to the saved effect timer.
path=ROOT/P
result=path.read_text(encoding='utf-8')
result=result.replace('record == null || record.TarotEffectTics <= 0\n            || !record.TarotActive[CaelumConstants.TAROT_THE_FOOL]',
                      '!CaelumTarotService.IsActive(record, CaelumConstants.TAROT_THE_FOOL)')
result=result.replace('EffectTics = record.TarotEffectTics + 1;', 'EffectTics = CaelumTarotService.EffectTics(record) + 1;')
path.write_text(result,encoding='utf-8',newline='\n')
path='src/ZSCRIPT'
(ROOT/path).write_text(source(path).replace('#include "caelum/core/CaelumTarotPowers.zs"',
    '#include "caelum/core/CaelumTarotService.zs"\n#include "caelum/core/CaelumTarotPowers.zs"'),encoding='utf-8',newline='\n')
(HERE/'extraction_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(f'Extracted {len(manifest)} methods and the Journal projection; serialized fields retained.')
