"""Issue #431: deterministic diagnostic overlays; production src stays intact."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build/issue431'

# Signature, call arguments, label. Wrappers retain the original method bodies.
SPECS = {
    'actors/CaelumCombatActor.zs': [
        ('override void Tick()', '', 'NPC'),
        ('void UpdateCombatResourceRecovery(bool sleeping)', 'sleeping', 'Resources'),
        ('void UpdateImpactContactLatch()', '', 'Contact'),
        ('void UpdateCombatHealthEffects()', '', 'HealthEffects'),
        ('void UpdateActorOffensiveStatistics()', '', 'Offense'),
        ("void ThermalChase(statelabel melee='_a_chase_default',statelabel missile='_a_chase_default',int flags=0)", 'melee,missile,flags', 'Chase'),
    ],
    'world/CaelumPortSiege.zs': [('override void Tick()', '', 'Controller'),
        ('void ElectCommands()', '', 'Election'), ('void RefreshTargets()', '', 'Lanes')],
    'survival/CaelumThermalRuntime.zs': [
        ('static void NPCStep(CaelumCombatActor npc,bool force=false)', 'npc,force', 'ThermalSchedule')],
    'survival/CaelumThermalMotion.zs': [
        ('static void Physics(Actor body,vector3 before,vector3 velocity,bool grounded,vector2 propelled,\n        Sector supportSector,F3DFloor supportFloor,double supportHeight)',
         'body,before,velocity,grounded,propelled,supportSector,supportFloor,supportHeight', 'ThermalMotion')],
    'survival/CaelumContaminationNPC.zs': [
        ('static void IllnessStep(CaelumCombatActor npc)', 'npc', 'Illness'),
        ('static void Step(CaelumCombatActor npc,CaelumThermalState thermal,double seconds)', 'npc,thermal,seconds', 'Contamination')],
    'survival/CaelumThermalService.zs': [
        ('static void Advance(Actor body,double worldSeconds,double realSeconds,\n        double activityWatts=0,double magicWatts=0,double fireWatts=0,double firearmWatts=0,int surfaceKind=-1)',
         'body,worldSeconds,realSeconds,activityWatts,magicWatts,fireWatts,firearmWatts,surfaceKind', 'ThermalAdvance')],
    'actors/CaelumVisualPerception.zs': [
        ('static Actor Candidate(CaelumCombatActor observer)', 'observer', 'Candidate'),
        ('static Actor Acquire(CaelumCombatActor observer,Actor hint=null)', 'observer,hint', 'Acquire')],
    'actors/CaelumCommunication.zs': [('static void Pulse(CaelumCombatActor body)', 'body', 'Communication')],
    'actors/CaelumNoise.zs': [('static void Emit(Actor origin,int kind,double overrideRange=-1)', 'origin,kind,overrideRange', 'Noise')],
}


def wrap(source, signature, args, label, slot):
    # Whitespace differences are immaterial; every match must be unique.
    pattern = r'\s*'.join(re.escape(x) for x in re.split(r'\s+', signature.strip()))
    found = list(re.finditer(pattern, source))
    if len(found) != 1:
        raise ValueError(f'{label}: expected exactly one signature, got {len(found)}')
    match = found[0]
    original = match.group()
    name = re.search(r'(\w+)\s*\(', original).group(1)
    result = re.search(r'(void|Actor|double)\s+' + name, original).group(1)
    renamed = original.replace('override ', '').replace(name + '(', 'CA511Original' + name + '(', 1)
    source = source[:match.start()] + renamed + source[match.end():]
    call = f'CA511Original{name}({args});'
    if result != 'void':
        call = result + ' value=' + call
    wrapper = f'''\n    {original}
    {{
        let sample=CA511Profile(EventHandler.Find("CA511Profile"));
        bool measured=sample!=null && sample.Running && level.time%17==0;
        if(measured)sample.Begin({slot});
        {call}
        if(measured)sample.End({slot});
        {'return value;' if result != 'void' else ''}
    }}\n'''
    # Insert in the owning class, immediately after the original method. Some
    # source files contain several classes, so the final brace is not sufficient.
    start = source.index('{', match.start() + len(renamed))
    depth = 0
    for token in re.finditer(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\{|\}', source[start:]):
        if token.group() == '{':
            depth += 1
        elif token.group() == '}':
            depth -= 1
            if depth == 0:
                pos = start + token.end()
                break
    else:
        raise ValueError(f'{label}: unterminated original method')
    return source[:pos] + wrapper + source[pos:]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--variant', choices=('current', 'full35', 'reduced5', 'simplified'), default='current')
    parser.add_argument('--scene', choices=('peaceful', 'siege'), default='siege')
    parser.add_argument('--timers', action='store_true')
    parser.add_argument('--tag', default='')
    parser.add_argument('--contacts', action='store_true')
    parser.add_argument('--surfaces', action='store_true')
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    files, hashes, labels = {}, {}, []
    if args.contacts or args.surfaces:
        SPECS['survival/CaelumContaminationNPC.zs'] += [
            ('void Capture(CaelumCombatActor npc,CaelumThermalState thermal)', 'npc,thermal', 'ContaminationCapture'),
            ('void AdvanceCaptured(CaelumCombatActor npc,double seconds,double ambient)', 'npc,seconds,ambient', 'ContaminationBalance')]
        SPECS['survival/CaelumContaminationSurface.zs'] = [
            ('static void NPCContact(CaelumCombatActor npc,CaelumThermalState thermal,double seconds)', 'npc,thermal,seconds', 'SurfaceContact')]
        SPECS['survival/CaelumContaminationContact.zs'] = [
            ('static void Observe(Actor item)', 'item', 'ContactQuery')]
    if args.surfaces:
        SPECS['survival/CaelumContaminationSurface.zs'] += [
            ('void Sync(double now,double civilOffset,CaelumWeatherSample outside,CaelumWeatherSample local)', 'now,civilOffset,outside,local', 'SurfaceHistory'),
            ('static double Evolve(double value,double ambient,double rain,double seconds)', 'value,ambient,rain,seconds', 'SurfaceBalance'),
            ('static void ConfigureObject(Actor body,CaelumContaminationTile tile)', 'body,tile', 'SurfaceConfiguration')]
    if args.timers:
        for file, methods in SPECS.items():
            raw = (ROOT / 'src/caelum' / file).read_bytes()
            text = raw.decode('utf-8').replace('\r\n', '\n')
            hashes[file] = hashlib.sha256(raw).hexdigest()
            for signature, call, label in methods:
                text = wrap(text, signature, call, label, len(labels))
                labels.append(label)
            files['caelum/' + file] = text
    if args.variant in ('full35', 'reduced5'):
        key = 'caelum/survival/CaelumThermalRuntime.zs'
        hashes[key] = hashlib.sha256((ROOT / 'src' / key).read_bytes()).hexdigest()
        text = files.get(key, (ROOT / 'src' / key).read_text(encoding='utf-8'))
        interval = '1' if args.variant == 'full35' else '5*TICRATE'
        needle = 'thermal.NextUpdateTic=level.maptime+TICRATE;'
        assert text.count(needle) == 1
        files[key] = text.replace(needle, f'thermal.NextUpdateTic=level.maptime+{interval};')
    if args.variant == 'simplified':
        # Experimental one-step moisture/thermoregulation quadrature. The
        # original model, contact, damage and all energy inputs still execute.
        # NOT approved for production: integration error is measured separately.
        key = 'caelum/survival/CaelumThermalService.zs'
        hashes[key] = hashlib.sha256((ROOT / 'src' / key).read_bytes()).hexdigest()
        text = files.get(key, (ROOT / 'src' / key).read_text(encoding='utf-8'))
        needle = 'int steps=(thermal.Sweats || thermal.CanShiver) && thermal.Available ? Max(1,int(Ceil(Max(0.0,worldSeconds)/CaelumThermalData.SWEAT_STEP_SECONDS))) : 1;'
        assert text.count(needle) == 1
        files[key] = text.replace(needle, 'int steps=1; // Diagnostic one-step quadrature only.')
    if args.timers:
        begin = 3600 if args.scene == 'siege' else 350
        end = begin + 700
        output = '\n'.join(f'Console.Printf("CA511 SCOPE {name} calls=%d inclusive_ms=%.6f exclusive_ms=%.6f",Calls[{i}],Inclusive[{i}],Exclusive[{i}]);' for i, name in enumerate(labels))
        key = 'caelum/actors/CaelumCommunication.zs'
        files[key] += f'''
class CA511Profile : EventHandler
{{
    int Age,Depth,Calls[{len(labels)}];
    double Inclusive[{len(labels)}],Exclusive[{len(labels)}];
    Array<double> Starts,Children;
    bool Running;
    void Begin(int slot)
    {{ Starts.Push(MSTimeF());Children.Push(0);Depth++;Calls[slot]++; }}
    void End(int slot)
    {{
        Depth--;double duration=MSTimeF()-Starts[Depth];
        Inclusive[slot]+=duration;Exclusive[slot]+=duration-Children[Depth];
        Starts.Pop();Children.Pop();if(Depth>0)Children[Depth-1]+=duration;
    }}
    override void WorldTick()
    {{
        Age++;Running=Age>={begin} && Age<{end};
        if(Age=={end}){{{output}
            Console.Printf("CA511 PROFILE_END depth=%d variant={args.variant}",Depth);
        }}
    }}
}}
'''
        files['MAPINFO'] = 'GameInfo { AddEventHandlers="CA511Profile" }\n'
    name = f'{args.variant}-{args.scene}' + ('-timers' if args.timers else '') + args.tag
    package = OUT / (name + '.pk3')
    if package.exists():
        raise SystemExit('Choose a fresh --tag to preserve the earlier diagnostic overlay.')
    with zipfile.ZipFile(package, 'w', zipfile.ZIP_STORED) as archive:
        for key, text in sorted(files.items()):
            archive.writestr(zipfile.ZipInfo(key, (2000, 1, 1, 0, 0, 0)), text.encode('utf-8'))
    manifest = dict(variant=args.variant, scene=args.scene, timers=args.timers,
        sampling='Every seventeenth simulation tic, inclusive and nested-exclusive wall scopes.',
        source_sha256=hashes, overlay_sha256=hashlib.sha256(package.read_bytes()).hexdigest(),
        labels=labels, production_changes=False)
    (OUT / (name + '.json')).write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    print(package)


if __name__ == '__main__':
    main()
