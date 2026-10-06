"""Reproduce the #117 stateless extraction from the accepted #116 commit.

Token qualification preserves comments, strings, constants and call order.
This script only writes the three explicitly named runtime sources.
"""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'assets/validation_500'))
from audit_sources import declarations, mask

BASE = '6e8f0d66d718740f503a5ccf181241711d20140f'
PLAYER = 'src/caelum/player/CaelumPlayer.zs'
DOMAINS = {
    'CaelumPlayerCharacter': '''ReadNewCharacterDraft ReadNewCharacterLayer
        ReadNewCharacterAttribute NewCharacterDraftIsReady ClearNewCharacterDraftReady
        ValidateLoadedNewCharacterDraft ConsumeNewCharacterDraft InitializeDirectMapCharacter
        EnsureCurrentAttributeBalance ApplyCharacterProfile'''.split(),
    'CaelumPlayerResources': '''AddAdrenaline AddCombatAdrenaline MarkCombatActivity
        UpdateAdrenalineDecay ApplyConsumableRegenerationPulse ApplyLocalizedLucidityLoss
        GetLuciditySleepDebuffMultiplier UpdateLucidityState UpdateLucidityAccuracyEffects
        UpdateLucidityPhysicalStun UpdatePainImmobilization CalculateSurvivalState
        GetSurvivalStateMultiplier IsSubmergedInPotableWater UpdateSurvivalResources
        UpdateSurvivalStates UpdateHealthStateEffects UpdateEffectiveOffensiveDamageMultiplier
        ApplyCriticalSurvivalDamage ApplyNaturalHealthRegeneration ApplyAirRegeneration
        HasUnderwaterAirExemption GetUnderwaterBaseAirCostPerSecond RecoverUnderwaterAirDebt
        UpdateUnderwaterAirForState UpdateUnderwaterAir ConsumeJumpAir GetAirRatio
        UpdateAirStateEffects'''.split(),
}


def baseline():
    return subprocess.check_output(['git', 'show', f'{BASE}:{PLAYER}'], cwd=ROOT).decode('utf-8')


def arguments(signature):
    params = signature[signature.index('(') + 1:signature.rindex(')')]
    return params, [p.split('=')[0].split()[-1] for p in params.split(',') if p.strip()]


def extract():
    original = baseline()
    pawn = next(c for c in declarations(original) if c['name'] == 'CaelumPlayer')
    names = {m['name'] for m in pawn['methods']}
    for field in pawn['fields']:
        for part in field['declaration'].split(','):
            names.add(re.sub(r'\[.*', '', part.split()[-1]))
    names.update('player health Inv Mass A_SetSize WaterLevel CurSector bInvulnerable DamageMobj Angle Die'.split())
    edits = []
    for service, selected in DOMAINS.items():
        output = [f'// #117: operaciones sin estado propio; el jugador conserva los datos serializados.\n'
                  f'// El coordinador mantiene el orden de llamadas y la inicialización explícita.\n'
                  f'class {service} : Object play\n{{\n']
        for name in selected:
            method = next(m for m in pawn['methods'] if m['name'] == name)
            signature = method['signature']
            params, args = arguments(signature)
            body = original[method['body_start']:method['body_end'] + 1]
            clean = mask(body)
            replacements = []
            for token in re.finditer(r'\b\w+\b', clean):
                word = token.group()
                if word == 'self':
                    replacements.append((token.start(), token.end(), 'user'))
                elif word in names and word not in args and not clean[:token.start()].rstrip().endswith('.'):
                    replacements.append((token.start(), token.end(), 'user.' + word))
            for start, end, replacement in reversed(replacements):
                body = body[:start] + replacement + body[end:]
            helper_sig = signature[:signature.index('(')+1] + 'CaelumPlayer user' + (', ' + params.strip() if params.strip() else '') + ')'
            output.append('    static ' + helper_sig + '\n    ' + body + '\n\n')
            call = service + '.' + name + '(self' + (', ' + ', '.join(args) if args else '') + ');'
            if not signature.startswith('void '):
                call = 'return ' + call
            edits.append((method['body_start'], method['body_end'] + 1, '{\n        ' + call + '\n    }'))
        output.append('}\n')
        (ROOT / f'src/caelum/player/{service}.zs').write_text(''.join(output), encoding='utf-8', newline='\n')
    changed = original
    for start, end, replacement in sorted(edits, reverse=True):
        changed = changed[:start] + replacement + changed[end:]
    (ROOT / PLAYER).write_text(changed, encoding='utf-8', newline='\n')
    print(f'Extracted {len(edits)} methods; player reduced by {len(original.splitlines()) - len(changed.splitlines())} lines')


if __name__ == '__main__':
    extract()
