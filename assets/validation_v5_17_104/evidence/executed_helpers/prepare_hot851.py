"""Build bounded combat-service scopes from an immutable runtime."""
from pathlib import Path
import argparse, hashlib, json, re, zipfile

ROOT = Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--runtime', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
out = a.output.resolve(); out.relative_to(ROOT/'build'); out.mkdir(exist_ok=False)
specs = [('caelum/actors/CaelumCommunication.zs', 'Pulse', 'body'), ('caelum/actors/CaelumCommunication.zs', 'ObserveAlly', 'observer,candidate'), ('caelum/actors/CaelumCommunication.zs', 'Eligible', 'sender,receiver'), ('caelum/actors/CaelumCommunication.zs', 'Pending', 'body'), ('caelum/actors/CaelumVisualPerception.zs', 'CanSee', 'observer,candidate,knownDistance'), ('caelum/actors/CaelumVisualPerception.zs', 'Touching', 'observer,candidate'), ('caelum/actors/CaelumVisualPerception.zs', 'Candidate', 'observer'), ('caelum/actors/CaelumVisualPerception.zs', 'Acquire', 'observer,hint'), ('caelum/actors/CaelumVisualEvidence.zs', 'Observe', 'observer,candidate'), ('caelum/world/CaelumPortSiege.zs', 'Pulse', 'body'), ('caelum/world/CaelumPortSiege.zs', 'AttackerTarget', 'entry'), ('caelum/world/CaelumPortSiege.zs', 'WalkTo', 'body,goal,point'), ('caelum/actors/CaelumCombatActor.zs', 'ThermalChase', 'melee,missile,flags'), ('caelum/actors/CaelumCombatActor.zs', 'ThermalTryMove', 'destination'), ('caelum/actors/CaelumCombatActor.zs', 'PulseResourceRecovery', ''), ('caelum/actors/CaelumDemonService.zs', 'UpdateBreath', 'npc'), ('caelum/survival/CaelumAltitudeService.zs', 'Update', 'body')]
originals = {}; files = {}; edits = []; metrics = []
with zipfile.ZipFile(a.runtime) as package:
    for i, (short, method, arguments) in enumerate(specs):
        path = short
        if path not in files:
            originals[path] = package.read(path)
            files[path] = originals[path].decode('utf-8').replace('\r\n', '\n')
        source = files[path]
        matches = list(re.finditer(r'    (?:(static|override|virtual) )?(\w+) '+method+r'\(([^)]*)\)\s*\{', source))
        matches = [m for m in matches if ','.join(part.split('=')[0].split()[-1] for part in m[3].split(',') if part.strip()) == arguments]
        assert len(matches) == 1, (path, method, len(matches))
        m = matches[0]; kind = m[2]; signature = m[0][:-1].rstrip()
        renamed = signature.replace(' '+method+'(', ' CA851Body_'+method+'(')
        renamed = renamed.replace('override ', '').replace('virtual ', '')
        result = 'CA851Body_'+method+'('+arguments+');'
        invoke = result if kind == 'void' else kind+' ca851Result='+result
        ret = '' if kind == 'void' else 'return ca851Result;'
        wrapper = signature+'''\n    {
        CA851ServiceProbe ca851Probe=null;double ca851Start=0;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {ca851Probe=CA851ServiceProbe(StaticEventHandler.Find('CA851ServiceProbe'));if(ca851Probe!=null)ca851Start=MSTimeF();}
        '''+invoke+f'''
        if(ca851Probe!=null)ca851Probe.Record({i},ca851Start);
        {ret}
    }}
'''+renamed+'\n    {'
        files[path] = source[:m.start()]+wrapper+source[m.end():]
        edits.append((path, m[0], wrapper)); metrics.append(dict(id=i, path=path, method=method))
restored = dict(files)
for path, old, new in reversed(edits):
    assert restored[path].count(new) == 1
    restored[path] = restored[path].replace(new, old)
for path, source in restored.items():
    assert source.replace('\n', '\r\n').encode('utf-8') == originals[path], path
handler = '''
class CA851ServiceProbe : StaticEventHandler
{
    const METRICS=METRIC_COUNT;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA851 SERVICE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA851 SERVICES_COMPLETE");
    }
}
'''.replace('METRIC_COUNT', str(len(specs)))
files[specs[0][0]] += handler
files['MAPINFO'] = 'gameinfo { AddEventHandlers="CA851ServiceProbe" }\n'
with zipfile.ZipFile(out/'services.pk3', 'w') as package:
    for path, source in sorted(files.items()):
        data = (source.replace('\n', '\r\n') if path in originals else source).encode('utf-8')
        package.writestr(zipfile.ZipInfo(path, (2026,11,19,0,0,0)), data)
        target=out/'source'/path; target.parent.mkdir(parents=True, exist_ok=True); target.write_bytes(data)
sha = lambda b: hashlib.sha256(b).hexdigest()
manifest = dict(runtime_sha256=sha(a.runtime.read_bytes()), overlay_sha256=sha((out/'services.pk3').read_bytes()),
    originals_restored_exactly={path:sha(data) for path,data in originals.items()}, period=17, metrics=metrics,
    qualification='Inclusive sampled bodies; do not sum nested scopes. Lookup/timer overhead remains; not production throughput.')
(out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
print(json.dumps({'output':str(out), 'metrics':len(specs), 'overlay_sha256':manifest['overlay_sha256']}))
