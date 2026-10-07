"""Apply #120's explicit receiver/ownership guards to the #119 baseline.

The manifest distinguishes read-only queries from commands and records exact
guard text. All existing bodies, signatures and serialized fields remain.
"""
from pathlib import Path
import json,re,subprocess,sys
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
BASE='c4b717c7e8ab49e0cbe1a6f67e7f15f18c850b52'
sys.path.insert(0,str(ROOT/'assets/validation_500'))
from audit_sources import declarations,mask

def source(path):return subprocess.check_output(['git','show',f'{BASE}:{path}'],cwd=ROOT).decode('utf-8')
def write(path,s):(ROOT/path).write_text(s,encoding='utf-8',newline='\n')
def fallback(signature,name):
    kind=signature.split('(')[0].split()[-2]
    if name=='ReadNewCharacterDraft':return 'return fallback;'
    if name=='GetMagicBoxWeightDivisor':return 'return 1;'
    if name=='GetEquipmentTaskBlockReason':return 'return CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED;'
    return {'void':'return;','bool':'return false;','int':'return 0;','double':'return 0;','Name':"return 'None';",'String':'return "";'}.get(kind,'return null;')

manifest=[]
paths=['src/caelum/player/CaelumPlayerCharacter.zs','src/caelum/player/CaelumPlayerResources.zs',
       'src/caelum/player/CaelumPlayerPresentation.zs','src/caelum/equipment/CaelumInventoryService.zs']
query_mutators={'CanCompletePreparedMaterialOutput','CanCompletePreparedEquipmentOutput','CanCompletePreparedDismantle','KnowsWeaponRepairRecipe','GetEquipmentTaskBlockReason'}
for path in paths:
    s=source(path);changes=[]
    for cls in declarations(s):
        for m in cls['methods']:
            body=s[m['body_start']:m['body_end']+1]
            if not re.search(r'\buser\b',mask(body)):continue
            name=m['name'];ret=fallback(m['signature'],name)
            query=bool(re.match(r'^(Get|Find|Has|Is|Can|Count|Calculate|Knows|FormalInventoryEntryMatchesFilter|PalomoTransactionCapacityFits|ReadNewCharacter|NewCharacterDraftIsReady|ValidateLoadedNewCharacterDraft)',name)) and name not in query_mutators
            guard='if (!CaelumPlayerAuthority.'+('CanRead' if query else 'CanMutate')+'(user)) '+ret
            if 'CaelumPersistentCharacterState persistentState' in m['signature']:
                guard+='\n        if (!CaelumPlayerAuthority.OwnsRecord(user, persistentState)) '+ret
            if 'CaelumCraftingBrowser preview' in m['signature']:
                guard+='\n        if (preview != null && preview != user.CraftingBrowser) '+ret
            if name=='BuildEquipmentTaskMaterials':
                guard+='\n        if (item == null || item.Owner != user) return false;'
            if name=='FillFormalInventoryRow':
                guard+='\n        if (entry != null && entry.Owner != user) return;'
            if name=='ValidateLoadedNewCharacterDraft':
                guard+='\n        if (user.CharacterProfile == null || user.CharacterAllocation == null) return false;'
            changes.append((m['body_start']+1,guard))
            manifest.append(dict(path=path,cls=cls['name'],name=name,query=query,guard=guard))
    for at,guard in sorted(changes,reverse=True):s=s[:at]+'\n        '+guard+s[at:]
    write(path,s)

path='src/caelum/core/CaelumTarotService.zs';s=source(path);changes=[]
guards={
    'EnsureRevision':'if (record == null || !CaelumPlayerAuthority.OwnsRecord(CaelumPlayer(record.Owner), record)) return;',
    'ValidUser':'if (!CaelumPlayerAuthority.CanMutate(user)) return false;',
    'Advance':'if (!CaelumPlayerAuthority.CanMutate(user)) return;',
    'RestoreNativeEffect':'if (!CaelumPlayerAuthority.CanMutate(user)) return;',
    'HasTarotCard':'if (record == null) return false;',
    'CountTarotCards':'if (record == null) return 0;',
    'GetTarotAttributeBonusPercent':'if (record == null) return 0;',
    'GetTarotMinorBaseBonus':'if (record == null) return 0;',
    'CanCaptureMainM00Fool':'if (record == null || !CaelumPlayerAuthority.OwnsRecord(CaelumPlayer(record.Owner), record)) return false;',
    'RecordMainM00FoolCapture':'if (record == null || !CaelumPlayerAuthority.OwnsRecord(CaelumPlayer(record.Owner), record)) return false;',
    'CanApproach':'if (!CaelumPlayerAuthority.CanMutate(user)) return false;',
    'IsAvailable':'if (essence == null || !CaelumPlayerAuthority.CanRead(user)) return false;',
    'IsRevealedFor':'if (essence == null || record == null) return false;',
    'RecordCapture':'if (essence == null || !CaelumPlayerAuthority.OwnsRecord(essence.CaptureUser, record)) return false;',
    'Reveal':'if (record == null || !CaelumPlayerAuthority.OwnsRecord(CaelumPlayer(record.Owner), record)\n            || card < 0 || card >= CaelumConstants.TAROT_CARD_COUNT) return;',
    'RefreshJournalSnapshot':'if (!CaelumPlayerAuthority.OwnsRecord(user, persistentState)) return;'
}
for m in declarations(s)[0]['methods']:
    if m['name'] not in guards:continue
    guard=guards[m['name']];changes.append((m['body_start']+1,guard))
    manifest.append(dict(path=path,cls='CaelumTarotService',name=m['name'],guard=guard,query=m['name'] in ['HasTarotCard','CountTarotCards','GetTarotAttributeBonusPercent','GetTarotMinorBaseBonus','IsAvailable','IsRevealedFor']))
for at,guard in sorted(changes,reverse=True):s=s[:at]+'\n        '+guard+s[at:]
write(path,s)

path='src/caelum/player/CaelumPlayer.zs';s=source(path)
m=next(m for c in declarations(s) if c['name']=='CaelumPlayer' for m in c['methods'] if m['name']=='GetPersistentCharacterState')
b=s[m['body_start']:m['body_end']+1]
b=b.replace('{','{\n        if (!CaelumPlayerAuthority.CanRead(self)) return null;',1)
b=b.replace('if (persistentState == null && createState)','if (persistentState != null && persistentState.Owner != self) return null;\n        if (persistentState == null && createState && CaelumPlayerAuthority.CanMutate(self))')
s=s[:m['body_start']]+b+s[m['body_end']+1:];write(path,s)

path='src/caelum/hud/CaelumJournalOverlay.zs';s=source(path)
s=s.replace('CaelumPlayer requestingPlayer = CaelumPlayer(players[e.Player].mo);','CaelumPlayer requestingPlayer = CaelumPlayerAuthority.FromNetworkPlayer(e.Player);')
write(path,s)
for game in ['Trucazo','Truco']:
    path=f'src/caelum/trucazo/Caelum{game}Menu.zs';s=source(path)
    s=s.replace(f'if(e.Name!="ca_{game.lower()}" || e.Player<0 || e.Player>=MAXPLAYERS || !playeringame[e.Player])return;\n        let match=Caelum{game}Match.Get(CaelumPlayer(players[e.Player].mo));',
        f'if(e.Name!="ca_{game.lower()}")return;\n        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);\n        if(user==null)return;\n        let match=Caelum{game}Match.Get(user);')
    write(path,s)
path='src/caelum/core/CaelumTarotPowers.zs';write(path,source(path).replace('const REVISION = 1;','const REVISION = CaelumTarotService.REVISION;'))
path='src/ZSCRIPT';write(path,source(path).replace('#include "caelum/core/CaelumTarotService.zs"','#include "caelum/player/CaelumPlayerAuthority.zs"\n#include "caelum/core/CaelumTarotService.zs"'))
(HERE/'authority_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(f'Added {len(manifest)} explicit operation guards; retained existing bodies and fields.')
