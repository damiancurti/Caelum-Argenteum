"""Build a direct Limbo predicate using the unchanged canonical mansion mapping."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/world/CaelumWorldCatalogue.zs'
with zipfile.ZipFile(a.runtime) as z:original=z.read(path)
source=original.decode('utf-8').replace('\r\n','\n')
old='return LocationForMap(mapName) == LOCATION_MANSION;'
new='return mapName ~== MapForLocation(LOCATION_MANSION);'
assert source.count(old)==1
lookup=source[source.index('    static clearscope int LocationForMap('):source.index('    static clearscope String MapForLocation(')]
reverse=source[source.index('    static clearscope String MapForLocation('):source.index('    static clearscope bool IsLimboMap(')]
assert lookup.count('return LOCATION_MANSION;')==1
assert 'if (mapName ~== "MAP01") return LOCATION_MANSION;' in lookup
assert 'if (id == LOCATION_MANSION) return "MAP01";' in reverse
constants={name:int(value) for name,value in re.findall(r'const (LOCATION_\w+) = (\d+);',source)}
returned=set(re.findall(r'return (LOCATION_\w+);',lookup))
assert all(constants[n]!=constants['LOCATION_MANSION'] for n in returned if n!='LOCATION_MANSION')
candidate=source.replace(old,new).replace('\n','\r\n').encode()
assert candidate.replace(new.encode(),old.encode())==original
with zipfile.ZipFile(out/'location.pk3','w') as z:z.writestr(zipfile.ZipInfo(path,(2026,11,19,0,0,0)),candidate)
target=out/'source'/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(candidate)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(runtime_sha256=sha(a.runtime.read_bytes()),original_sha256=sha(original),candidate_sha256=sha(candidate),overlay_sha256=sha((out/'location.pk3').read_bytes()),inverse_exact=True,proof='The original lookup returns the unique MANSION ID iff its first case-insensitive MAP01 comparison succeeds. The unchanged reverse mapping for MANSION is MAP01. Other returned IDs differ. The predicate is therefore equal for every string, not only sampled names.',returned_location_ids={n:constants[n] for n in sorted(returned)},no_fields_or_mapping_changes=True)
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(manifest))
