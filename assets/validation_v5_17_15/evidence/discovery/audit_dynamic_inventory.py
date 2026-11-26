"""Private #647 discovery: resolve catalogue world states in native GZDoom."""
from pathlib import Path
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'build/v517/work-672'
OUT = ROOT / 'build/v516/dynamic-inventory-02'
OUT.mkdir(exist_ok=False)
sys.path.insert(0, str(WORK / 'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad
spec = importlib.util.spec_from_file_location('coverage', ROOT / 'build/v516/audit_inventory_model_coverage.py')
coverage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(coverage)
codes = sorted({code for blocks in coverage.bindings.values() for block in blocks for code, frame in block['pairs']})
kinds = [row['class_name'] for row in coverage.rows]
source = r'''
class CA647DynamicAudit : EventHandler
{
    int Count;
    void Report(Inventory item, String family, int type, int tier, int slot, int essence)
    {
        if(item==null){Console.Printf("CA647 AUDIT_FAIL null %s %d",family,type);return;}
        let state=item.CurState;
        TextureID texture=state.GetSpriteTexture(0,0,(0,0),item.sprite,item.frame);
        Console.Printf("CA647 ROW|%s|%s|%d|%d|%d|%d|%d|%d|%s|%s|%.6f|%.6f|%.6f|%.6f",
            family,item.GetClassName(),type,tier,slot,essence,item.sprite,item.frame,
            TexMan.GetName(texture),TexMan.GetName(item.Icon),item.Scale.X,item.Scale.Y,item.Radius,item.Height);
        Count++; item.Destroy();
    }
    void Equipment(class<CaelumEquipmentItem> kind, String family, int types, int slots)
    {
        for(int type=0;type<types;type++)for(int slot=0;slot<slots;slot++)for(int tier=1;tier<=3;tier++)
        {
            if(family=="clothing" && tier>1)continue;
            if(family=="weapon" && tier>1 && CaelumWeaponModel.IsSingleTierType(type))continue;
            int essenceCount=family=="weapon"?CaelumConstants.ESSENCE_TYPE_COUNT:1;
            for(int essence=0;essence<essenceCount;essence++)
            {
                if(family=="weapon" && !CaelumSupportImplementData.ValidEssence(type,essence))continue;
                let item=CaelumEquipmentItem(Actor.Spawn(kind,(0,0,128),NO_REPLACE));
                item.args[0]=family=="armor"?slot:type;
                item.args[1]=family=="armor"?type:tier;
                item.args[2]=family=="armor"?tier:0;
                item.args[4]=essence+1;
                item.UpdateWorldSprite();
                Report(item,family,item.PreviewItemType(),item.PreviewTier(),item.PreviewArmorSlot(),item.PreviewEssenceType());
            }
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca647_audit")return;
        Count=0;
        Array<String> codes={CODES};
        for(int i=0;i<codes.Size();i++)Console.Printf("CA647 SPRITE|%s|%d",codes[i],Actor.GetSpriteIndex(codes[i]));
        Array<class<Inventory> > kinds={KINDS};
        for(int i=0;i<kinds.Size();i++)Report(Inventory(Actor.Spawn(kinds[i],(0,0,128),NO_REPLACE)),"default",-1,-1,-1,-1);
        Equipment('CaelumArmorPickup',"armor",CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT,CaelumConstants.ARMOR_SLOT_COUNT);
        Equipment('CaelumShieldPickup',"shield",CaelumConstants.SHIELD_TYPE_COUNT,1);
        Equipment('CaelumAmuletPickup',"amulet",CaelumConstants.AMULET_TYPE_COUNT,1);
        Equipment('CaelumSealPickup',"seal",CaelumConstants.SEAL_TYPE_COUNT,1);
        Equipment('CaelumClothingPickup',"clothing",CaelumClothingData.COUNT,1);
        Equipment('CaelumWeaponPickup',"weapon",CaelumConstants.WEAPON_TYPE_COUNT,1);
        for(int type=0;type<CaelumConstants.MATERIAL_TYPE_COUNT;type++)for(int tier=1;tier<=3;tier++)
        {
            let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',(0,0,128),NO_REPLACE));
            item.args[0]=type;item.args[1]=tier;item.UpdateMaterialVisuals();
            Report(item,"material",item.GetSpecialType(),item.GetSpecialTier(),-1,-1);
        }
        Console.Printf("CA647 AUDIT_COMPLETE rows=%d",Count);
    }
}
'''.replace('CODES', ','.join('"'+code+'"' for code in codes)).replace('KINDS', ','.join("'"+kind+"'" for kind in kinds))
(OUT/'audit.zs').write_text(source, encoding='utf-8', newline='\n')
with zipfile.ZipFile(OUT/'fixture.pk3','w') as z:
    for name,value in {'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'maps/CA455V.wad':wad(),
                       'MAPINFO':b'gameinfo { AddEventHandlers="CA647DynamicAudit" }\nmap CA455V "Read-only inventory audit" { sky1="CABASKY",0 nointermission }'}.items():
        z.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),value)
(OUT/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
(OUT/'commands.cfg').write_text('wait 140; netevent ca647_audit; wait 35; quit\n')
runtime=WORK/'build/issue672-locks01.pk3'
engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
assert b'"gzdoom.exe"' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).lower()
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
command=[str(engine),'-noautoload','-iwad',str(iwad),'-file',str(runtime),str(OUT/'fixture.pk3'),'-config',str(OUT/'session.ini'),'-savedir',str(OUT),'-window','+logfile',str(OUT/'engine.log'),'+map','CA455V','+exec',str(OUT/'commands.cfg')]
with (OUT/'process.log').open('wb') as stream:
    process=subprocess.Popen(command,cwd=OUT,stdout=stream,stderr=stream,startupinfo=startup)
    deadline=time.monotonic()+120
    while process.poll() is None and time.monotonic()<deadline:
        log=(OUT/'engine.log').read_text(errors='replace') if (OUT/'engine.log').exists() else ''
        if any(token in log for token in ('Script error','Execution could not continue','VM execution aborted')):break
        time.sleep(.2)
    if process.poll() is None:process.terminate()
    code=process.wait(timeout=10)
log=(OUT/'engine.log').read_text(errors='replace')
errors=[line for line in log.splitlines() if any(t in line for t in ('Script error','Execution could not continue','VM execution aborted','AUDIT_FAIL','Unknown command','Unable to load model'))]
done=re.search(r'CA647 AUDIT_COMPLETE rows=(\d+)',log)
if code or errors or not done:
    print(json.dumps(dict(exit=code,errors=errors,tail=log.splitlines()[-15:]),indent=2));sys.exit(1)
indices={name:int(index) for name,index in re.findall(r'CA647 SPRITE\|([^|]+)\|(\d+)',log)}
exact={}
for kind,blocks in coverage.bindings.items():
    for block in blocks:
        for sprite,frames in block['pairs']:
            for frame in frames:
                exact.setdefault((kind,indices[sprite],ord(frame)-ord('A')),[]).append(dict(file=block['file'],sprite=sprite,frame=frame))
rows=[]
for match in re.finditer(r'^CA647 ROW\|(.+)$',log,re.M):
    values=match.group(1).strip().split('|')
    row=dict(zip(('family','class','type','tier','slot','essence','sprite','frame','texture','icon','scale_x','scale_y','radius','height'),values))
    for key in ('type','tier','slot','essence','sprite','frame'):row[key]=int(row[key])
    for key in ('scale_x','scale_y','radius','height'):row[key]=float(row[key])
    chain=[];kind=row['class']
    while kind and kind not in chain:chain.append(kind);kind=coverage.parents.get(kind)
    owner=next((kind for kind in chain if (kind,row['sprite'],row['frame']) in exact),None)
    row['status']='direct' if owner==row['class'] else 'ancestor-candidate' if owner else 'missing'
    row['bindings']=exact.get((owner,row['sprite'],row['frame']),[])
    if owner is None:
        row['same_state_candidates']=[dict(class_name=kind,bindings=value) for (kind,sprite,frame),value in exact.items() if sprite==row['sprite'] and frame==row['frame']]
    rows.append(row)
assert len(rows)==int(done.group(1))
families={family:dict(rows=sum(r['family']==family for r in rows),states=len({(r['class'],r['sprite'],r['frame']) for r in rows if r['family']==family}),missing_states=len({(r['class'],r['sprite'],r['frame']) for r in rows if r['family']==family and r['status']=='missing'})) for family in sorted({r['family'] for r in rows})}
report=dict(scope='Private one-shot catalogue discovery, not model visibility or gameplay acceptance. Defaults plus legal weapon essence filters and material/equipment world presentation resolved by native public functions. No campaign/save mutation.',runtime_sha256=hashlib.sha256(runtime.read_bytes()).hexdigest(),rows=rows,families=families)
(OUT/'REPORT.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(rows=len(rows),families=families),indent=2))
