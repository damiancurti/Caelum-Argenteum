"""Prototype the authored breath route-marker exclusion before visual mutation."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
paths=['caelum/actors/CaelumDemonService.zs','caelum/actors/CaelumDemonBreath.zs'];originals={};files={};edits=[]
with zipfile.ZipFile(a.runtime) as z:
    for name in paths:originals[name]=z.read(name);files[name]=originals[name].decode('utf-8').replace('\r\n','\n')
def change(path,old,new):
    assert files[path].count(old)==1,(path,old,files[path].count(old));files[path]=files[path].replace(old,new);edits.append((path,old,new))
service,breath=paths
change(service,'&& npc.target.bSHOOTABLE && CaelumVisualPerception.Identify(npc,npc.target)','&& npc.target.bSHOOTABLE && !CaelumDemonBreath.IsRouteMarker(npc.target)\n            && CaelumVisualPerception.Identify(npc,npc.target)')
old='''    static bool CanReach(Actor owner,Actor victim)
    {
        // El destino nativo de una ruta es disparable para A_Chase, pero no
        // es un enemigo ni un punto al que orientar el aliento por frio o sogas.
        if(victim is 'CaelumSewerEscapeTarget')return false;'''
new='''    // #855: aplicar la exclusion antes de mutar el reconocimiento visual.
    static bool IsRouteMarker(Actor victim)
    {
        // El destino nativo de una ruta es disparable para A_Chase, pero no
        // es un enemigo ni un punto al que orientar el aliento por frio o sogas.
        return victim is 'CaelumSewerEscapeTarget';
    }

    static bool CanReach(Actor owner,Actor victim)
    {
        if(IsRouteMarker(victim))return false;'''
change(breath,old,new)
change(breath,'if(Emitter.target!=null && CaelumVisualPerception.Identify(Emitter,Emitter.target) && CanReach(Emitter,Emitter.target))','if(Emitter.target!=null && !IsRouteMarker(Emitter.target)\n            && CaelumVisualPerception.Identify(Emitter,Emitter.target) && CanReach(Emitter,Emitter.target))')
restored=files.copy()
for path,old,new in reversed(edits):assert restored[path].count(new)==1;restored[path]=restored[path].replace(new,old)
for path in paths:assert restored[path]==originals[path].decode('utf-8').replace('\r\n','\n')
with zipfile.ZipFile(out/'prototype.pk3','w') as z:
    for name in sorted(paths):
        nl='\r\n' if b'\r\n' in originals[name] else '\n';data=files[name].replace('\n',nl).encode('utf-8')
        z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data);target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=855,runtime_sha256=sha(a.runtime.read_bytes()),baseline_sources={n:sha(b) for n,b in originals.items()},candidate_sources={n:sha((out/'source'/n).read_bytes()) for n in paths},overlay_sha256=sha((out/'prototype.pk3').read_bytes()),inverse_exact=True,new_fields=False,new_rules=False,qualification='Prototype behavior fix. Share the exact existing route-marker type predicate and apply it before Identify in UpdateBreath and PaidTick. General perception, native movement, legitimate targets, cold/bolas, contact heat, costs, state transitions and cadence keep their existing bodies. Navigation-triggered visual-evidence/RNG mutation is intentionally removed; this is not an equivalent full-combat comparison.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),sha256=manifest['overlay_sha256'])))
