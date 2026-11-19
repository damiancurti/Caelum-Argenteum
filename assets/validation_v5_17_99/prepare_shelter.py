"""Prototype an equivalent bounded connectivity test for the existing wall sampler."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/survival/CaelumThermalEnvironment.zs'
with zipfile.ZipFile(a.runtime) as package:original=package.read(path)
source=original.decode('utf-8').replace('\r\n','\n')
old='''        for(int first=0;first<count;first++)
        {
            bool reached[8];reached[first]=true;int linked=1;
            for(int pass=0;pass<count;pass++)for(int i=0;i<count;i++)
                if(!reached[i])for(int j=0;j<count;j++)
                    if(reached[j] && Connected(walls[i],walls[j]))
                    {reached[i]=true;linked++;break;}
            if(linked>=3)return true;
        }
'''
new='''        // En un grafo no dirigido hay un componente de al menos tres planos
        // si y sólo si algún plano tiene dos vecinos distintos. Cada par se
        // comprueba una sola vez; los ocho trazados y sus filtros no cambian.
        int neighbors[8];
        for(int first=0;first<count;first++)for(int second=first+1;second<count;second++)
        {
            if(!Connected(walls[first],walls[second]))continue;
            neighbors[first]++;neighbors[second]++;
            if(neighbors[first]>=2 || neighbors[second]>=2)return true;
        }
'''
assert source.count(old)==1;candidate=source.replace(old,new)
assert candidate.replace(new,old).replace('\n','\r\n').encode('utf-8')==original
data=candidate.replace('\n','\r\n').encode('utf-8')
with zipfile.ZipFile(out/'shelter.pk3','w') as package:package.writestr(zipfile.ZipInfo(path,(2026,11,19,0,0,0)),data)
target=out/'source'/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=842,runtime_sha256=sha(a.runtime.read_bytes()),original_sha256=sha(original),candidate_sha256=sha(data),overlay_sha256=sha((out/'shelter.pk3').read_bytes()),inverse_restoration_exact=True,scope='Only connectivity after the same eight traces and plane deduplication; no saved fields, rules or timing changes.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(manifest))
