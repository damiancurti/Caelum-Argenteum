"""Build an adaptive derived surface index with the original lookup oracle."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/survival/CaelumContaminationSurface.zs'
with zipfile.ZipFile(a.runtime) as z:raw=z.read(path)
s=raw.decode('utf-8').replace('\r\n','\n')
start=s.index('    // Tamaño del índice, no un límite de población ni de estado guardado.')
end=s.index('        for(int i=Buckets[h];i>=0;i=Tiles[i].Next)',start)
old=s[start:end]
new='''    // Tamaño inicial y carga técnica: no limitan zonas ni población.
    const BUCKET_COUNT=1024;
    const BUCKET_LOAD_LIMIT=4;
    static int Hash(int kind,int surface,int side,int x,int y,int buckets=BUCKET_COUNT)
    {return ((kind*31+surface*131+side*17+x*37+y*73)&0x7fffffff)%buckets;}
    void Index()
    {
        int count=Buckets.Size();
        if(count>=BUCKET_COUNT && Tiles.Size()/count<BUCKET_LOAD_LIMIT)return;
        count=Max(BUCKET_COUNT,count);
        while(Tiles.Size()/count>=BUCKET_LOAD_LIMIT)count*=2;
        // Sólo reconstruye enlaces derivados. Las zonas conservan identidad,
        // concentración, reloj e historial; el índice anterior puede rehacerse.
        Buckets.Resize(count);for(int i=0;i<count;i++)Buckets[i]=-1;
        for(int i=0;i<Tiles.Size();i++)
        {let t=Tiles[i];int h=Hash(t.Kind,t.Surface,t.Side,t.X,t.Y,count);t.Next=Buckets[h];Buckets[h]=i;}
    }
    CaelumContaminationTile Find(int kind,int surface,int side,int x,int y,bool create=false)
    {
        Index();int h=Hash(kind,surface,side,x,y,Buckets.Size());
'''
candidate=s[:start]+new+s[end:];assert candidate.replace(new,old,1)==s
data=candidate.replace('\n','\r\n' if b'\r\n' in raw else '\n').encode()
with zipfile.ZipFile(out/'prototype.pk3','x') as z:z.writestr(zipfile.ZipInfo(path,(2026,11,21,0,0,0)),data)
(out/'original.zs').write_bytes(raw);(out/'candidate.zs').write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=871,runtime_sha256=sha(a.runtime.read_bytes()),original_sha256=sha(raw),candidate_sha256=sha(data),overlay_sha256=sha((out/'prototype.pk3').read_bytes()),production_change=False,
 qualification='Private candidate. Same hash arithmetic and exact key comparison; divisor follows actual bucket capacity. The index doubles when integer load reaches4, preserving every tile and the insertion/rebuild traversal order. Only existing Buckets/Next derived links change; no new fields or saved schema. Old runtime Index sees a non1024 size and rebuilds its original hash, providing a reversible index migration. Requires native identity/state, growth, save/reversal and measured-cost verification before integration.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(manifest))
