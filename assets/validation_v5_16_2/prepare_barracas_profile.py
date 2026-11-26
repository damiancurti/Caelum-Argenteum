"""Create an isolated inclusive-timing overlay from the exact tested runtime.

Reuses the #428 profiling method and the normal 3600..4300 siege window.
No source or gameplay rule is changed. Inclusive Acquire/Candidate scopes overlap.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import zipfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    out = args.output.resolve(); out.relative_to(root / 'build'); out.mkdir(exist_ok=False)
    specs = [
        ('caelum/world/CaelumCityNavigation.zs', 'CaelumCityNavigation', '', 'bool', 'BuildFor', 'CaelumCombatActor body', 'body', 'Navigation'),
        ('caelum/actors/CaelumVisualPerception.zs', 'CaelumVisualPerception', 'static ', 'Actor', 'Candidate', 'CaelumCombatActor observer', 'observer', 'Candidate'),
        ('caelum/actors/CaelumVisualPerception.zs', 'CaelumVisualPerception', 'static ', 'Actor', 'Acquire', 'CaelumCombatActor observer,Actor hint=null', 'observer,hint', 'Acquire'),
        ('caelum/actors/CaelumNoise.zs', 'CaelumNoise', 'static ', 'void', 'Emit', 'Actor origin,int kind,double overrideRange=-1', 'origin,kind,overrideRange', 'Noise'),
        ('caelum/actors/CaelumCommunication.zs', 'CaelumCommunication', 'static ', 'void', 'Pulse', 'CaelumCombatActor body', 'body', 'Communication'),
    ]
    files = {}
    with zipfile.ZipFile(args.runtime) as runtime:
        for path, cls, prefix, result, name, parameters, arguments, metric in specs:
            source = files.get(path, runtime.read(path)).decode('utf-8')
            anchor = f'{prefix}{result} {name}('
            assert source.count(anchor) == 1, anchor
            assert re.findall(r'^class\s+(\w+)', source, re.M)[-1] == cls
            source = source.replace(anchor, f'{prefix}{result} Unprofiled{name}(', 1)
            call = f'Unprofiled{name}({arguments});'
            if result != 'void': call = f'{result} value=' + call
            extra = ''
            if metric == 'Navigation':
                extra = "perf.NavigationMaximum=Max(perf.NavigationMaximum,elapsed);perf.NavigationSamples.Push(elapsed);if(body is 'CaelumPortDefender')perf.DefenderCalls++;else perf.FrontCalls++;"
            wrapper = f'''
    {prefix}{result} {name}({parameters})
    {{
        let perf=CA454NavigationTimings(EventHandler.Find('CA454NavigationTimings'));
        bool measured=perf!=null && perf.Running;
        double start=measured ? MSTimeF() : 0;
        {call}
        if(measured){{double elapsed=MSTimeF()-start;perf.{metric}MS+=elapsed;perf.{metric}Calls++;{extra}}}
        {'return value;' if result != 'void' else ''}
    }}
'''
            pos = source.rfind('}'); files[path] = (source[:pos] + wrapper + source[pos:]).encode()
    metrics = ['Navigation', 'Candidate', 'Acquire', 'Noise', 'Communication']
    fields = ''.join(f'double {m}MS;int {m}Calls;\n' for m in metrics)
    prints = ''.join(f'Console.Printf("CA454 COST {m} ms=%.6f calls=%d",{m}MS,{m}Calls);\n' for m in metrics)
    handler = f'''
class CA454NavigationTimings : EventHandler
{{
    {fields}
    int Age,DefenderCalls,FrontCalls;bool Running;
    double NavigationMaximum;Array<double> NavigationSamples;
    override void WorldTick()
    {{
        Age++;Running=Age>=3600 && Age<4300;
        if(Age!=4300)return;
        {prints}
        Console.Printf("CA454 COST navigation_split defenders=%d fronts=%d max_ms=%.6f",DefenderCalls,FrontCalls,NavigationMaximum);
        for(int i=0;i<NavigationSamples.Size();i++)Console.Printf("CA454 NAV_SAMPLE %.6f",NavigationSamples[i]);
    }}
}}
'''
    files['caelum/world/CaelumCityNavigation.zs'] += handler.encode()
    files['MAPINFO'] = b'gameinfo { AddEventHandlers="CA454NavigationTimings" }\n'
    with zipfile.ZipFile(out / 'profile.pk3', 'w', zipfile.ZIP_STORED) as archive:
        for name, blob in sorted(files.items()):
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)), blob)
    (out / 'manifest.json').write_text(json.dumps({'issue': 454, 'scope': __doc__.strip(),
        'runtime_sha256': hashlib.sha256(args.runtime.read_bytes()).hexdigest(),
        'overlay_sha256': hashlib.sha256((out / 'profile.pk3').read_bytes()).hexdigest(),
        'instrumented_functions': [row[1] + '.' + row[4] for row in specs],
        'qualification': 'Timing wrappers add diagnostic overhead. Overlapping inclusive scopes must not be summed as independent costs.'}, indent=2) + '\n')
    print(out / 'profile.pk3')


if __name__ == '__main__':
    main()
