"""Build bounded environmental service scopes from an immutable runtime."""
from pathlib import Path
import argparse, hashlib, json, re, zipfile

ROOT = Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--runtime', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
p.add_argument('--deep', action='store_true')
a = p.parse_args()
out = a.output.resolve(); out.relative_to(ROOT/'build'); out.mkdir(exist_ok=False)
specs = [
    ('NPC', 'Step', 'npc,thermal,seconds'),
    ('NPC', 'Capture', 'npc,thermal'),
    ('NPC', 'AdvanceCaptured', 'npc,seconds,ambient'),
    ('NPC', 'CommitCaptured', 'npc'),
    ('Surface', 'NPCContact', 'npc,thermal,seconds'),
    ('Surface', 'ConfigureObject', 'body,tile'),
    ('Surface', 'FloorTile', 'user,sheet,create'),
    ('Surface', 'WallTile', 'user,sheet,create'),
    ('Surface', 'ObjectSupport', 'item,seconds'),
    ('Contact', 'Observe', 'item'),
    ('Contact', 'Collision', 'body,other'),
    ('Contact', 'Touching', ''),
    ('Contact', 'Exchange', 'seconds'),
    ('Contact', 'Tick', ''),
    ('Object', 'Eligible', 'body'),
    ('Object', 'Sample', 'world'),
    ('Object', 'Replay', 'value,now'),
    ('Object', 'Settle', 'now'),
    ('Object', 'Tick', ''),
    ('Environment', 'ReferenceAt', 'body'),
    ('Exposure', 'ReadLive', ''),
    ('Exposure', 'Advance', 'illness,ambient,seconds'),
]
if a.deep:
    specs = [('Contact','Exchange','seconds'),('Combat','Exterior','body,slot,reuse'),
        ('Combat','ActorPoint','body,reuse'),('Combat','ModelPoint','entry,reuse'),
        ('Combat','Transfer','first,second,area,seconds'),('State','Get','body,create,raw'),
        ('State','Value','body'),('State','IsShielded','body'),('Object','SettleNow',''),
        ('Stack','TouchPoints','first,second,area,seconds'),('Stack','Eligible','item')]
originals = {}; files = {}; edits = []; metrics = []
with zipfile.ZipFile(a.runtime) as package:
    for i, (short, method, arguments) in enumerate(specs):
        path = 'caelum/survival/CaelumContamination'+short+'.zs'
        if path not in files:
            originals[path] = package.read(path)
            files[path] = originals[path].decode('utf-8').replace('\r\n', '\n')
        source = files[path]
        matches = list(re.finditer(r'    (?:(static|override|virtual) )?(\w+) '+method+r'\(([^)]*)\)\s*\{', source))
        matches = [m for m in matches if ','.join(part.split('=')[0].split()[-1] for part in m[3].split(',') if part.strip()) == arguments]
        assert len(matches) == 1, (path, method, len(matches))
        m = matches[0]; kind = m[2]; signature = m[0][:-1].rstrip()
        renamed = signature.replace(' '+method+'(', ' CA844Body_'+method+'(')
        renamed = renamed.replace('override ', '').replace('virtual ', '')
        result = 'CA844Body_'+method+'('+arguments+');'
        invoke = result if kind == 'void' else kind+' ca844Result='+result
        ret = '' if kind == 'void' else 'return ca844Result;'
        wrapper = signature+'''\n    {
        CA844ServiceProbe ca844Probe=null;double ca844Start=0;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {ca844Probe=CA844ServiceProbe(StaticEventHandler.Find('CA844ServiceProbe'));if(ca844Probe!=null)ca844Start=MSTimeF();}
        '''+invoke+f'''
        if(ca844Probe!=null)ca844Probe.Record({i},ca844Start);
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
class CA844ServiceProbe : StaticEventHandler
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
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA844 SERVICE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA844 SERVICES_COMPLETE");
    }
}
'''.replace('METRIC_COUNT', str(len(specs)))
files['caelum/survival/CaelumContamination'+specs[0][0]+'.zs'] += handler
files['MAPINFO'] = 'gameinfo { AddEventHandlers="CA844ServiceProbe" }\n'
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
