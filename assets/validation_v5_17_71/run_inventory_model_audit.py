"""Resolve current project inventory world states and exact MODELDEF coverage.

This isolated, once-only diagnostic reads project classes from the supplied PK3,
observes native Inventory defaults and resolves legal catalogue combinations.
It does not establish model visibility, ordinary handling or author acceptance.
"""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys,time,zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def without_comments(text):
    pattern=r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*[\s\S]*?\*/'
    return re.sub(pattern,lambda m:m[0] if m[0].startswith(('"',"'")) else re.sub(r'[^\n]',' ',m[0]),text)

def included_sources(package,entry):
    seen={}
    def visit(name):
        if name in seen:return
        text=package.read(name).decode('utf-8-sig');seen[name]=text
        for child in re.findall(r'^\s*#include\s+"([^"]+)"',without_comments(text),re.M):
            local=(Path(name).parent/child).as_posix()
            visit(local if local in package.namelist() else child)
    visit(entry);return seen

def inspect_package(path):
    with zipfile.ZipFile(path) as package:
        sources=included_sources(package,'ZSCRIPT');model_sources=included_sources(package,'MODELDEF')
    classes={}
    for name,text in sources.items():
        declarations=re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',lambda m:' '*len(m[0]),without_comments(text))
        for match in re.finditer(r'\bclass\s+(\w+)(?:\s*:\s*(\w+))?',declarations):
            classes[match[1]]=dict(parent=match[2],source=name)
    bindings={}
    for name,text in model_sources.items():
        text=without_comments(text)
        for match in re.finditer(r'\bModel\s+"?(\w+)"?\s*\{',text,re.I):
            end=match.end();depth=1
            while depth and end<len(text):
                if text[end]=='{':depth+=1
                elif text[end]=='}':depth-=1
                end+=1
            if depth:raise ValueError('Unclosed MODELDEF block: '+name)
            pairs=re.findall(r'\bFrameIndex\s+(\w+)\s+(\w+)',text[match.end():end],re.I)
            bindings.setdefault(match[1],[]).append(dict(file=name,pairs=pairs))
    return classes,bindings,{name:hashlib.sha256(text.encode('utf-8')).hexdigest() for name,text in {**sources,**model_sources}.items()}

def native_run(runtime,out,source,handler='CA785InventoryAudit',commands='wait 140; netevent ca785_audit; wait 35; quit\n'):
    if b'"gzdoom.exe"' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).lower():raise RuntimeError('Another native engine is running')
    fixture=out/'fixture.pk3';(out/'audit.zs').write_text(source,encoding='utf-8',newline='\n')
    with zipfile.ZipFile(fixture,'w') as package:
        for name,blob in {'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'maps/CA455V.wad':wad(),'MAPINFO':('gameinfo { AddEventHandlers="'+handler+'" }\nmap CA455V "Inventory model state audit" { sky1="CABASKY",0 nointermission }\n').encode()}.items():
            package.writestr(zipfile.ZipInfo(name,(2026,11,15,0,0,0)),blob)
    (out/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nvid_fullscreen=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\n')
    (out/'commands.cfg').write_text(commands)
    command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','+logfile',str(out/'engine.log'),'+map','CA455V','+exec',str(out/'commands.cfg')]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    with (out/'process.log').open('wb') as stream:
        process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,startupinfo=startup);deadline=time.monotonic()+120
        while process.poll() is None and time.monotonic()<deadline:
            text=(out/'engine.log').read_text(errors='replace') if (out/'engine.log').exists() else ''
            if any(key in text for key in ['Script error','Execution could not continue','VM execution aborted']):break
            time.sleep(.2)
        if process.poll() is None:process.terminate()
        code=process.wait(timeout=10)
    text=(out/'engine.log').read_text(errors='replace') if (out/'engine.log').exists() else ''
    errors=[line for line in text.splitlines() if any(t in line for t in ['Script error','Execution could not continue','VM execution aborted','AUDIT_FAIL','Unknown command','Unable to load model','CA785 FAIL'])]
    return code,text,errors,digest(fixture)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    classes,bindings,inputs=inspect_package(runtime)
    codes=sorted({code for blocks in bindings.values() for block in blocks for code,frames in block['pairs']})
    template=Path(__file__).with_name('inventory_model_audit.zs').read_text(encoding='utf-8')
    source=template.replace('CODES',','.join('"'+code+'"' for code in codes)).replace('PROJECT_NAMES',','.join('"'+name+'"' for name in sorted(classes)))
    code,log,errors,fixture_sha=native_run(runtime,out,source)
    indices={name:int(index) for name,index in re.findall(r'CA785 SPRITE\|([^|]+)\|(\d+)',log)}
    exact={}
    for kind,blocks in bindings.items():
        for block in blocks:
            for sprite,frames in block['pairs']:
                if sprite not in indices:continue
                for frame in frames:exact.setdefault((kind,indices[sprite],ord(frame)-ord('A')),[]).append(dict(file=block['file'],sprite=sprite,frame=frame))
    rows=[]
    for match in re.finditer(r'^CA785 ROW\|(.+)$',log,re.M):
        values=match[1].strip().split('|');row=dict(zip(('family','class','type','tier','slot','essence','sprite','frame','texture','icon','scale_x','scale_y','radius','height'),values))
        for key in ('type','tier','slot','essence','sprite','frame'):row[key]=int(row[key])
        for key in ('scale_x','scale_y','radius','height'):row[key]=float(row[key])
        chain=[];kind=row['class']
        while kind and kind not in chain:chain.append(kind);kind=classes.get(kind,{}).get('parent')
        owner=next((kind for kind in chain if (kind,row['sprite'],row['frame']) in exact),None)
        row['status']='direct' if owner==row['class'] else 'ancestor-candidate' if owner else 'missing'
        row['binding_owner']=owner;row['bindings']=exact.get((owner,row['sprite'],row['frame']),[]);rows.append(row)
    defaults=[dict(zip(('class','undroppable','untossable','visible_spawn'),m[1].strip().split('|'))) for m in re.finditer(r'^CA785 DEFAULT\|(.+)$',log,re.M)]
    done=re.search(r'CA785 AUDIT_COMPLETE rows=(\d+)',log);census=re.search(r'CA785 CENSUS classes=(\d+) visible=(\d+)',log)
    if not done or int(done[1])!=len(rows):errors.append('Incomplete catalogue rows')
    if not census or int(census[1])!=len(defaults) or int(census[2])!=sum(r['family']=='default' for r in rows):errors.append('Incomplete current inventory class census')
    required={'CaelumWeaponPickup','CaelumArmorPickup','CaelumCarbineAmmo','CaelumJavelinAmmo','CA_LimboMagicImplement','CaelumMaterialPickup'}
    if not required<={r['class'] for r in defaults}:errors.append('Current class census omitted required native inventory families')
    if any(r['status']=='missing' for r in rows):errors.append('Unbound native inventory state')
    identities=[tuple(r[k] for k in ['family','class','type','tier','slot','essence']) for r in rows]
    # Some material inputs intentionally normalize all three requested tiers to one.
    normalized_identity_count=len(set(identities))
    families={family:dict(rows=sum(r['family']==family for r in rows),states=len({(r['class'],r['sprite'],r['frame']) for r in rows if r['family']==family}),missing_states=len({(r['class'],r['sprite'],r['frame']) for r in rows if r['family']==family and r['status']=='missing'})) for family in sorted({r['family'] for r in rows})}
    result=dict(issue=785,scope=__doc__.strip(),runtime_sha256=digest(runtime),engine_sha256=digest(ENGINE),fixture_sha256=fixture_sha,source_hashes=inputs,exit_code=code,errors=errors,passed=code==0 and not errors,inventory_defaults=defaults,rows=rows,families=families,normalized_identity_count=normalized_identity_count,limitations=['Ancestor candidates require native visual verification; static association is not proof of rendered model visibility.','Finite catalogue combinations use existing public update functions and legal-essence rules. Some material-tier inputs normalize to the same effective identity. Custom third-party classes and future content are outside this observed package.','Native defaults exclude undroppable/untossable/invisible spawn states; dynamic equipment/material families are covered explicitly.','This is a once-only isolated diagnostic with no campaign or save mutation and no production actor scan.'])
    (out/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(passed=result['passed'],inventory_classes=len(defaults),rows=len(rows),families=families,ancestor=[{k:r[k] for k in ['class','texture','binding_owner']} for r in rows if r['status']=='ancestor-candidate'],errors=errors)),flush=True)
    if not result['passed']:raise SystemExit(1)

if __name__=='__main__':main()
