"""Reproduce #118's inventory extraction from the accepted #117 baseline.

The manifest uses baseline source ranges, then records concrete method names.
Only the player, service and two physical-item sources are written. No fields move.
"""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'assets/validation_500'))
from audit_sources import declarations, mask

BASE = 'da7d33b88b76241331bd8ddc007773b2e2c8b9f8'
PLAYER = 'src/caelum/player/CaelumPlayer.zs'
SERVICE = 'src/caelum/equipment/CaelumInventoryService.zs'
RANGES = [(1006,1080),(1800,2064),(2145,2409),(2448,2808),
          (3120,3577),(3605,3619),(4230,4341),(4370,4370),
          (4418,5947),(6775,6775),(6805,6805),(8067,8105),
          (8183,8860),(8902,9010),(9206,10809),(10856,11238),
          (11304,11442),(14808,14808)]
EXTERNAL = [
    ('src/caelum/equipment/CaelumSpecialItems.zs', 'CaelumMagicBox', 'EnsureOwned', 'EnsureOwnedMagicBox'),
    ('src/caelum/equipment/CaelumTarotDeck.zs', 'CaelumTarotDeckRules', 'Owned', 'FindOwnedTarotDeck'),
    ('src/caelum/equipment/CaelumTarotDeck.zs', 'CaelumTarotDeckRules', 'Grant', 'GrantTarotDeck'),
]
# Reject foreign owned references before touching the item or the requesting pawn.
# Detached incoming pickups and already owned stacks have different contracts.
GUARDS = {
    'EnsureEquipmentItemId': 'if (item != null && item.Owner != null && item.Owner != user) return 0;',
    'ActivateExactEquippedWeapon': 'if (item != null && item.Owner != user) return false;',
    'ApplyFormalInventorySelection': 'if (entry != null && entry.Owner != user) return;',
    'AddRecoveredMaterial': 'if ((existing != null && existing.Owner != user) || (detached != null && detached.Owner != null && detached.Owner != user)) return;',
}
for operation, parameter in [('Equipment','item'),('Ammo','ammunition'),('Consumable','consumable'),('Special','specialItem'),('Key','keyItem')]:
    GUARDS[f'PrepareNative{operation}Pickup'] = f'if ({parameter} != null && {parameter}.Owner != null && {parameter}.Owner != user) return false;'
for operation, parameter in [('Ammo','ammunition'),('Consumable','consumable'),('Special','specialItem')]:
    GUARDS[f'PrepareNative{operation}StackPickup'] = f'if ({parameter} != null && {parameter}.Owner != user) return false;'


def baseline():
    return subprocess.check_output(['git','show',f'{BASE}:{PLAYER}'],cwd=ROOT).decode('utf-8')


def arguments(signature):
    params = signature[signature.index('(')+1:signature.rindex(')')]
    return params, [p.split('=')[0].split()[-1] for p in params.split(',') if p.strip()]


def selected(source, pawn):
    return [m for m in pawn['methods'] if any(a <= source.count('\n',0,m['body_start'])+1 <= b for a,b in RANGES)]


def extract():
    original=baseline()
    pawn=next(c for c in declarations(original) if c['name']=='CaelumPlayer')
    methods=selected(original,pawn)
    names={m['name'] for m in pawn['methods']}
    for field in pawn['fields']:
        for part in field['declaration'].split(','):
            names.add(re.sub(r'\[.*','',part.split()[-1]))
    names.update('player health Inv Pos Angle Vel Height Radius FloorZ A_StartSound A_StopSound FindInventory GiveInventoryType TakeInventory UseInventory DropInventory AddInventory SetWeapon WaterLevel CurSector'.split())
    constants=set(re.findall(r'\bconst\s+(\w+)\s*=', mask(original)))
    # Engine Spawn is static Actor.Spawn; qualify it explicitly outside Actor.
    output=['// #118: inventario nativo único; los adaptadores conservan campos y firmas.\n',
            '// Cada operación recibe al propietario; esta clase no guarda estado.\n',
            'class CaelumInventoryService : Object play\n{\n']
    edits=[]
    for m in methods:
        signature=m['signature']; params,args=arguments(signature)
        body=original[m['body_start']:m['body_end']+1]; clean=mask(body)
        replacements=[]
        for token in re.finditer(r'\b\w+\b',clean):
            word=token.group()
            if clean[:token.start()].rstrip().endswith('.'): continue
            if word=='self': replacement='user'
            elif word=='Spawn': replacement='Actor.Spawn'
            elif word in constants: replacement='CaelumPlayer.'+word
            elif word in names and word not in args: replacement='user.'+word
            else: continue
            replacements.append((token.start(),token.end(),replacement))
        for a,b,value in reversed(replacements): body=body[:a]+value+body[b:]
        if m['name'] in GUARDS:
            body=body[:1]+'\n        '+GUARDS[m['name']]+body[1:]
        sig=signature[:signature.index('(')+1]+'CaelumPlayer user'+(', '+params.strip() if params.strip() else '')+')'
        output.append('    static '+sig+'\n    '+body+'\n\n')
        call='CaelumInventoryService.'+m['name']+'(self'+(', '+', '.join(args) if args else '')+');'
        if not signature.startswith('void '): call='return '+call
        edits.append((m['body_start'],m['body_end']+1,'{\n        '+call+'\n    }'))
    external_sources={}
    external_edits={}
    for path,cls,name,replacement in EXTERNAL:
        if path not in external_sources:
            external_sources[path]=subprocess.check_output(['git','show',f'{BASE}:{path}'],cwd=ROOT).decode('utf-8')
        source=external_sources[path]
        decl=next(c for c in declarations(source) if c['name']==cls)
        method=next(m for m in decl['methods'] if m['name']==name)
        signature=method['signature']
        params,args=arguments(signature)
        body=source[method['body_start']:method['body_end']+1]
        if cls=='CaelumTarotDeckRules':
            body=re.sub(r'\bOwned\(user\)', 'FindOwnedTarotDeck(user)',body)
            body=re.sub(r'\bREVISION\b','CaelumTarotDeckRules.REVISION',body)
        output.append('    '+signature.replace(name+'(',replacement+'(',1)+'\n    '+body+'\n\n')
        call='return CaelumInventoryService.'+replacement+'('+', '.join(args)+');'
        external_edits.setdefault(path,[]).append((method['body_start'],method['body_end']+1,'{\n        '+call+'\n    }'))
    for path, changes in external_edits.items():
        result=external_sources[path]
        for a,b,value in sorted(changes,reverse=True): result=result[:a]+value+result[b:]
        (ROOT/path).write_text(result,encoding='utf-8',newline='\n')
    output.append('}\n')
    (ROOT/SERVICE).write_text(''.join(output),encoding='utf-8',newline='\n')
    result=original
    for a,b,value in sorted(edits,reverse=True): result=result[:a]+value+result[b:]
    (ROOT/PLAYER).write_text(result,encoding='utf-8',newline='\n')
    print(f'Extracted {len(methods)} operations; removed {len(original.splitlines())-len(result.splitlines())} pawn lines')


if __name__=='__main__': extract()
