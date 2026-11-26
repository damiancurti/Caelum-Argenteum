"""Prepare exact carrier dispatch and eligibility shortcuts for measured types."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
sha=lambda b:hashlib.sha256(b).hexdigest();originals={};files={};proof={}
classes={}
for path in (ROOT/'src/caelum').rglob('*.zs'):
    for name,parent in re.findall(r'^class\s+(\w+)\s*:\s*(\w+)',path.read_text(encoding='utf-8'),re.M):
        classes[name]=(parent,path.relative_to(ROOT).as_posix(),sha(path.read_bytes()))
def ancestry(name):
    result=[name]
    while name in classes:
        name=classes[name][0];assert name not in result;result.append(name)
    return result
excluded=['Inventory','CaelumPlayer','CaelumDiningBlock','CaelumDiningTable','CaelumStorageFurnitureItem','CaelumDecorBody','CaelumRestFurniture','CaelumPortableDiningTable','CaelumPortableReadingDesk','CaelumSofa','CaelumSofaSeat','CaelumStashChest','CaelumPortableReadingShelf','CaelumPortableBookcaseStorage','CaelumCityMerchant','CaelumTarotRock','CaelumPhysicalScenery']
for family in ('CaelumCombatActor','CaelumGateBlocker','CaelumVehiclePart'):
    chain=ancestry(family);assert chain==[family,'Actor'],(family,chain)
    for other in excluded:assert family not in ancestry(other) and other not in chain,(family,other)
proof['ancestry']={n:ancestry(n) for n in ['CaelumCombatActor','CaelumGateBlocker','CaelumVehiclePart','CaelumMachineBlock','CaelumRamBlock','CaelumRamHead','CaelumCannonBlock',*excluded]}
proof['class_sources']={n:dict(parent=classes[n][0],path=classes[n][1],sha256=classes[n][2]) for n in set(x for chain in proof['ancestry'].values() for x in chain) if n in classes}
with zipfile.ZipFile(a.runtime) as z:
    for name in ('CaelumContaminationState','CaelumContaminationObject','CaelumContaminationStack'):
        path='caelum/survival/'+name+'.zs';originals[path]=z.read(path);files[path]=originals[path].decode('utf-8').replace('\r\n','\n')
assert 'if(item==null)return false;' in files['caelum/survival/CaelumContaminationStack.zs']
path='caelum/survival/CaelumContaminationState.zs';source=files[path];start=source.index('    static CaelumContaminationState Get(Actor body,');end=source.index('    static double Value(Actor body)',start);old=source[start:end]
npc_start=old.index('        let npc=CaelumCombatActor(body);');carrier_start=old.index('        let carrier=CaelumContaminationCarrier(');npc=old[npc_start:carrier_start];carrier=old[carrier_start:]
assert carrier.endswith('    }\n')
guard="        if(body==null || body is 'CaelumPlayer')return null;\n";assert old.count(guard)==1
dispatch='''    // Las familias medidas usan su portador individual, no muebles delegados.
    static clearscope bool NativeCarrierBody(Actor body)
    {return body is 'CaelumGateBlocker' || body is 'CaelumVehiclePart';}
'''
new=old.replace(npc,'').replace(guard,guard+npc+'        if(NativeCarrierBody(body))return GetCarrier(body,create,npc);\n')
assert new.count(carrier)==1
new=new.replace(carrier,'''        return GetCarrier(body,create,npc);
    }
    static CaelumContaminationState GetCarrier(Actor body,bool create,CaelumCombatActor npc)
    {
'''+carrier)
new=dispatch+new
files[path]=source[:start]+new+source[end:];assert files[path].replace(new,old)==source
proof['storage_change']='Move the existing warm NPC block before mutually exclusive pure casts. Native GateBlocker (including MachineBlock/Ram/Cannon) and VehiclePart families bypass those same furniture/stack branches. The original carrier tail is copied exactly into GetCarrier; all other dispatch and mutating migration/ownership bodies are unchanged.'
proof['carrier_tail_sha256']=sha(carrier.encode());proof['npc_block_sha256']=sha(npc.encode())
path='caelum/survival/CaelumContaminationObject.zs';source=files[path]
guard="        if(body==null || body.bDestroyed || body is 'CaelumPlayer' || body is 'CaelumCombatActor' || body.bMissile)return false;\n";assert source.count(guard)==1
extra='''        // Estos cuerpos no pueden ser inventarios ni muebles con propietario delegado.
        if(CaelumContaminationStorage.NativeCarrierBody(body))
            return (body.bSolid || GetDefaultByType(body.GetClass()).bSolid) && body.Radius>0 && body.Height>0;
'''
files[path]=source.replace(guard,guard+extra);assert files[path].replace(extra,'')==source
proof['eligibility_change']='After the unchanged null/destroyed/player/NPC/missile guards, the two native-carrier families cannot match any intervening type branch or the DiningTable/PhysicalScenery terms in the final expression. Their result is the same current/default solid and positive dimensions; no state is shared across parts.'
files.pop('caelum/survival/CaelumContaminationStack.zs')
with zipfile.ZipFile(out/'carrier.pk3','w') as z:
    for path,source in sorted(files.items()):
        data=source.replace('\n','\r\n' if b'\r\n' in originals[path] else '\n').encode();z.writestr(zipfile.ZipInfo(path,(2026,11,19,0,0,0)),data);target=out/'source'/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
manifest=dict(issue=849,runtime_sha256=sha(a.runtime.read_bytes()),overlay_sha256=sha((out/'carrier.pk3').read_bytes()),proof=proof,original_sha256={n:sha(b) for n,b in originals.items()},candidate_sha256={n:sha((out/'source'/n).read_bytes()) for n in files},no_fields_caches_or_gameplay_data_changed=True,inverse_exact=True)
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),sha256=manifest['overlay_sha256'])))
