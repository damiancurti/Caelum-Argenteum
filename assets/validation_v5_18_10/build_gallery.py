"""Local playable inspection fixture using installed Caelum assets."""
import argparse
import io
import json
import re
import struct
import zipfile
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--output",type=Path,default=ROOT/"build/model-gallery")
OUT = parser.parse_args().output.resolve()
OUT.mkdir(parents=True,exist_ok=True)
SRC = ROOT / "src"
defs, exhibits, models, actors, resources = {}, [], [], [], {}
pattern = re.compile(r"(?im)^model\s+(\w+)\s*\{([^}]+)\}")
for path in [SRC/"MODELDEF", *sorted((SRC/"caelum/data").glob("*.modeldef"))]:
    for name, block in pattern.findall(path.read_text(encoding="utf8")):
        if path.name != "bestiary_deaths.modeldef":
            defs.setdefault(name, block)
iqm = ROOT/"assets/source/art/iqm_assessment_834/export"
defs.update(pattern.findall((iqm/"MODELDEF").read_text()))
for path in (iqm/"models").rglob("*.iqm"):
    resources[path.relative_to(iqm).as_posix()] = path.read_bytes()

defs["DomingoOriginal"] = '''
 Path "models/caelum/domingo"
 Model 0 "domingo.md3"
 Skin 0 "domingo_skin.png"
 Scale 1 1 1
 DontCullBackFaces
 FrameIndex D300 A 0 0
'''

def framed_bounds(lines):
    """Read the registered idle bounds without loading the animation payload."""
    block="\n".join(lines)
    folder=re.search(r'(?im)^\s*Path\s+"([^"]+)"',block)
    scales=re.search(r'(?im)^\s*Scale\s+([-.\d]+)\s+([-.\d]+)\s+([-.\d]+)',block)
    sx,sy,sz=map(float,scales.groups()) if scales else (1.,1.,1.)
    offsets=re.search(r'(?im)^\s*Offset\s+([-.\d]+)\s+([-.\d]+)\s+([-.\d]+)',block)
    offset_z=float(offsets[3]) if offsets else 0
    bounds=[]
    for slot,name in re.findall(r'(?im)^\s*Model\s+(\d+)\s+"([^"]+\.md3)"',block):
        model=SRC/(folder[1] if folder else "")/name
        if not model.is_file():
            model=SRC/name
        if not model.is_file():
            continue
        frame=re.search(r'(?im)^\s*FrameIndex\s+\w+\s+\w\s+'+slot+r'\s+(\d+)',block)
        with model.open('rb') as f:
            f.seek(108+56*(int(frame[1]) if frame else 0))
            bounds.append(struct.unpack('<6f',f.read(24)))
    if not bounds:return [170,65,55,85]
    low=[min(row[k] for row in bounds) for k in range(3)]
    high=[max(row[k+3] for row in bounds) for k in range(3)]
    return [(high[2]-low[2])*abs(sz),(high[1]-low[1])*abs(sy),(high[0]-low[0])*abs(sx),((low[2]+high[2])*.5+offset_z)*sz]


def add(name, label, scale="", outfit=None, category="Personajes", identity=None):
    i = len(exhibits)
    cls = f"GalleryModel{i:03}"
    block = defs[name]
    frame = re.search(r"(?i)FrameIndex\s+(\w+)\s+(\w)\s+\d+\s+\d+", block)
    sprite, letter = frame.groups()
    still = [line for line in block.splitlines() if "frameindex" not in line.lower()
             or re.search(rf"(?i)FrameIndex\s+{sprite}\s+{letter}\s", line)]
    models.append("Model "+cls+"\n{\n"+"\n".join(still)+"\n}")
    init = []
    if identity is not None:
        race = ("CaelumConstants.RACE_HUMAN", "CaelumConstants.RACE_CAELITH", "CaelumConstants.RACE_GOBLIN")[identity//2] if identity<6 else "CaelumConstants.RACE_BEAST_MAN"
        form = max(0,(identity-6)//2)
        init.append(f'let profile=CaelumCharacterProfile(new("CaelumCharacterProfile")); profile.Race={race}; profile.Sex={identity%2}; profile.BeastForm={form};')
        init.append('let stats=CaelumDerivedStats(new("CaelumDerivedStats")); Scale=CaelumAppearance.ScaleFor(profile.Race,profile.Sex,profile.BeastForm,stats.GetActorHeightForTier(profile.GetSizeTier()));')
    elif scale:
        init.append("Scale="+scale+";")
    if outfit is not None:
        body, head, hand, foot = outfit
        args = f"{body},{head},{hand},{foot}"
        init.append(f"""int mask=CaelumWornClothingModelData.Hidden({args});
        for(int slot=0;slot<CaelumWornClothingModelData.MODEL_SLOTS;slot++)
            A_ChangeModel('None',slot,CaelumWornClothingModelData.ModelPath(slot),
                CaelumWornClothingModelData.File(slot,{args}),slot,CaelumWornClothingModelData.SkinPath(slot),
                CaelumWornClothingModelData.Skin(slot,{args}), (mask & (1<<slot)) ? CMDL_HIDEMODEL : 0);""")
    height,width,depth,center=framed_bounds(still)
    init.append(f"CameraDistance=Clamp(Max({height:.5f}*Scale.Y*1.30,{width:.5f}*Scale.X*.84)+{depth:.5f}*Scale.X*.42,15,320);")
    init.append(f"EyeHeight=Clamp({center:.5f}*Scale.Y,7,102);")
    actors.append(f"""class {cls} : GalleryExhibit {{
        override void PostBeginPlay() {{ Super.PostBeginPlay(); {' '.join(init)} }}
        States {{ Spawn: {sprite} {letter} -1; Stop; }}
    }}""")
    exhibits.append(dict(station=i+1, label=label, group=category, actor=cls, source=name, bounds=[height,width,depth,center]))

human="CaelumAppearance.ScaleFor(0,0,0,GetDefaultByType('CaelumPlayer').Height)"
for idx,(family,sex) in enumerate((f,s) for f in ("Humano","Caelith","Duende","Lobo","Oso","Puma","Jaguar") for s in ("masculino","femenino")):
    parts=[(f"b{idx}_{part}",f"b{idx}") for part in ("shirt","trousers","belt","boots","gloves")]
    parts.append((f"head{idx}_0",f"head{idx}_0_0"))
    if idx<6:parts.append((f"hair{idx}_0",f"hair{idx}_0_1"))
    name=f"GalleryFamily{idx}"
    body=['Path "models/caelum/players"','CorrectPixelStretch','DontCullBackFaces']
    for j,(mesh,skin) in enumerate(parts):
        body.extend([f'Model {j} "{mesh}.md3"',f'Skin {j} "{skin}.png"'])
    body.extend(f"FrameIndex D300 A {j} 0" for j in range(len(parts)))
    defs[name]="\n".join(body)
    add(name,f"{family} - {sex}",human,category="Jugadores",identity=idx)
for actor, label in [("CaelumMandinga","Mandinga"),("CaelumZupayColossus","Zupay / Supay"),("CaelumGiantRat","Rata gigante")]:
    add(actor,label,f"GetDefaultByType('{actor}').Scale",category="Nuevos modelos")
add("CaelumDomingoPilotBody","Domingo - modular",human)
add("DomingoOriginal","Domingo - cuerpo original",human)
add("CA834IQMPreview","Domingo - prototipo IQM",human)
add("CaelumAutomatonModelBody","Autómata del Tarot")
add("CaelumBullModelBody","Toro","GetDefaultByType('CaelumBull').Scale")
add("CaelumTrainingDummy","Muñeco de entrenamiento")
catalogue=json.loads((ROOT/"assets/bestiary/CATALOGUE.json").read_text("utf8"))["entries"]
for entry in catalogue:
    actor = entry.get("actor_class")
    if actor in defs:
        add(actor, entry["reference_name"],f"GetDefaultByType('{actor}').Scale", category="Bestiario")
missing = {e["reference_name"] for e in catalogue if e.get("actor_class") and e["actor_class"] not in defs}
if missing:
    raise ValueError(f"Bestiary lacks gallery registration: {sorted(missing)}")
body_codes="F FW CS CE CW RS RE RW PS PE PW".split()
head_codes="HF HC HR HW HP".split()
hand_codes="GF GC GW GP".split()
foot_codes="BF BC BR BS BP".split()
add("CaelumWardrobePilotBody","Domingo - cuerpo base",human,(-1,-1,-1,-1),"Vestuario")
for body, code in enumerate(body_codes):
    for foot in range(-1,len(foot_codes)):
        head=(body+foot+1)%len(head_codes)
        hand=(body+foot+1)%len(hand_codes)
        label="Domingo  /  "+" + ".join([code,head_codes[head],hand_codes[hand],foot_codes[foot] if foot>=0 else "descalzo"])
        add("CaelumWardrobePilotBody",label,human,(body,head,hand,foot),"Vestuario")

gear=json.loads((ROOT/"assets/source/art/worn_equipment_904/MODULES.json").read_text())
translations="Espada|Bastón|Carabina|Daga|Hachuela|Machete|Jabalina|Hacha|Mangual|Lanza|Mandoble|Hacha de guerra|Alabarda|Guanteletes gigantes|Escopeta|Arco largo|Ballesta|Campana|Cetro|Orbe|Pico|Bastón utilitario|Boleadoras|Libro|Incensario|Estatuilla|Efigie".split("|")
tier_exhibits=[]
for seq,item in enumerate(gear):
    module=item["module"]
    family=seq%14
    block=defs[f"GalleryFamily{family}"]
    slot=7
    if module.startswith("w"):
        idx,tier=map(int,module[1:].split("_"))
        label=translations[idx]+(f" (T{tier})" if idx in (18,19,23,24,25,26) else "")
    elif module.startswith("s"):
        label=("Broquel","Escudo cometa","Escudo torre","Escudo mágico")[int(module[1:])]
    else:
        part,kind=map(int,module[1:].split("_"))
        label=("Casco","Coraza","Guantes","Botas")[part]+" / "+("magia","ligera","media","pesada")[kind]
    name=f"GalleryGear{seq}"
    if module.startswith("a0_"):
        cut="tuck" if kind==3 else "open"
        block=block.replace('Model 5 "head',f'Model 5 "{cut}/head').replace('Model 6 "hair','Model 6 "tuck/hair')
    if module.startswith("a3_"):
        block=block.replace(f'Model 3 "b{family}_boots.md3"', 'Model 3 "conceal.md3"')
    mesh=f"{module}_f{family//2}" if item.get("family_sha256") and family//2 else module
    defs[name]=block+f'\nModel {slot} "gear/{mesh}.md3"\nSkin {slot} "gear/{module}.png"\nFrameIndex D300 A {slot} 0'
    add(name,label,human,category="Equipo",identity=family)
    if item.get("tier_skin_sha256"):
        for tier in (2,3):
            styled=f"{name}Tier{tier}"
            defs[styled]=defs[name].replace(f'"gear/{module}.png"',f'"gear/{module}_t{tier}.png"')
            tier_exhibits.append((styled,f"{label} (T{tier})",family))
for name,label,family in tier_exhibits:
    add(name,label,human,category="Cascos por tier",identity=family)

n=len(exhibits)
step=140
base=-(n//2)*step
def px(index):
    return base+index*step
def prop(v):
    return json.dumps(v,ensure_ascii=False) if isinstance(v,str) else str(v).lower()
def entity(kind,**props):
    return kind+" { "+" ".join(f"{k}={prop(v)};" for k,v in props.items())+" }"
udmf=['namespace="ZDoom";']
corners=[(px(0)-160,-400),(px(0)-160,220),(px(n-1)+160,220),(px(n-1)+160,-400)]
for x,y in corners:
    udmf.append(entity("vertex",x=x,y=y))
udmf.append(entity("sector",heightfloor=0,heightceiling=240,texturefloor="FLAPISO",textureceiling="FLATECH",lightlevel=232))
for index in range(4):
    udmf.append(entity("sidedef",sector=0,texturemiddle="FLAPARED"))
    udmf.append(entity("linedef",v1=index,v2=(index+1)%4,sidefront=index,blocking=True))
def thing(x,y,ang,typ,tid):
    return entity("thing",x=x,y=y,angle=ang,type=typ,id=tid,**{k:True for k in ["skill1","skill2","skill3","skill4","skill5","single","coop","dm","class1","class2","class3"]})
udmf.append(thing(px(0),-132,90,1,0))
for i,item in enumerate(exhibits):
    udmf.append(thing(px(i),0,270,24000+i,1000+i))
lumps=[("GALERIA",b""),("TEXTMAP","\n".join(udmf).encode()),("ENDMAP",b"")]
data=bytearray(12)
directory=bytearray()
for key,value in lumps:
    directory.extend(struct.pack("<ii8s",len(data),len(value),key.encode()))
    data.extend(value)
struct.pack_into("<4sii",data,0,b"PWAD",len(lumps),len(data))
resources["maps/GALERIA.wad"]=data+directory

def texture(key, base_color, grout, wall=False):
    img=Image.new("RGB",(128,128),base_color)
    draw=ImageDraw.Draw(img)
    draw.line((0,0,127,0),fill=grout,width=2)
    draw.line((0,0,0,127),fill=grout,width=2)
    if wall:
        draw.line((0,99,127,99),fill=(143,125,87),width=2)
        draw.line((0,101,127,101),fill=(72,70,67),width=2)
    buf=io.BytesIO();img.save(buf,"PNG");resources["textures/"+key+".png"]=buf.getvalue()
texture("FLAPISO",(111,105,95),(85,80,72))
texture("FLATECH",(164,160,149),(150,146,138))
texture("FLAPARED",(142,144,141),(113,117,115),True)
labels=",\n".join(json.dumps(e["label"],ensure_ascii=False) for e in exhibits)
events=f"""
class GalleryVisitor : DoomPlayer {{
    override void GiveDefaultInventory() {{}}
}}
class GalleryExhibit : Actor {{
    double CameraDistance, EyeHeight;
    Default {{ +NOGRAVITY +INVULNERABLE Radius 20; Height 64; RenderRadius 180; }}
}}
class GalleryGuide : StaticEventHandler {{
    static clearscope int StationAt(double x) {{return Clamp(int(round((x-({base}))/ {step}.0)),0,{n-1});}}
    override void WorldTick() {{
        if(level.MapName!="GALERIA")return;
        if(level.time==3 && players[0].mo!=null) Focus(players[0].mo,0);
        if(level.time!=4 && level.time!=109) return;
        int ok=0;
        for(int i=0;i<{n};i++) {{
            let iter=ActorIterator.Create(1000+i);
            let a=GalleryExhibit(iter.Next());
            if(a && a.tics==-1 && a.Pos.X==({base})+i*{step} && a.Pos.Y==0 && a.Angle==270 && a.Vel.Length()==0) ok++;
        }}
        Console.Printf("GALERIA t=%d inmoviles=%d total={n}",level.time,ok);
    }}
    static void Focus(Actor a,int i) {{
        let visitor=GalleryVisitor(a);
        if(visitor==null || visitor.player==null)return;
        let it=ActorIterator.Create(1000+i);let sample=GalleryExhibit(it.Next());if(sample==null)return;
        double distance=sample.CameraDistance;
        visitor.ViewHeight=sample.EyeHeight;
        visitor.player.ViewHeight=visitor.ViewHeight;
        visitor.SetOrigin((({base})+i*{step},-distance,0),false);
        visitor.Vel=(0,0,0);visitor.Angle=90;visitor.Pitch=0;
        Console.Printf("GALERIA puesto=%d",i+1);
    }}
    override void NetworkProcess(ConsoleEvent e) {{
        if(level.MapName!="GALERIA")return;
        int change=0;
        if(e.Name=="fila_siguiente")change=1;
        else if(e.Name=="fila_anterior")change=-1;
        else if(e.Name!="fila_puesto")return;
        let a=players[e.Player].mo;
        if(a==null)return;
        int i=Clamp(StationAt(a.Pos.X)+change,0,{n-1});
        if(e.Name=="fila_puesto") i=Clamp(e.Args[0]-1,0,{n-1});
        Focus(a,i);
    }}
    override void RenderOverlay(RenderEvent e) {{
        if(level.MapName!="GALERIA")return;
        let a=players[consoleplayer].mo;if(!a)return;
        static const String labels[]={{{labels}}};
        int i=StationAt(a.Pos.X);
        String s=String.Format("%d / {n}   %s",i+1,labels[i]);
        Screen.DrawText(SmallFont,Font.CR_WHITE,320-SmallFont.StringWidth(s)/2,12,s,
            DTA_VirtualWidth,640,DTA_VirtualHeight,360,DTA_KeepRatio,true);
    }}
}}
"""
resources["ZSCRIPT"]=('version "4.14.2"\n'+events+"\n"+"\n".join(actors)).encode("utf8")
resources["MODELDEF"]=("\n".join(models)).encode()
resources["MAPINFO"]=('gameinfo { PlayerClasses = "GalleryVisitor" EventHandlers = "GalleryGuide" StatusBarClass = "BaseStatusBar" }\n'
    'map GALERIA "Galería de modelos" { cluster = 0 nointermission noautosequences }\n'
    'DoomEdNums {\n'+'\n'.join(f'{24000+i} = {e["actor"]}' for i,e in enumerate(exhibits))+'\n}').encode("utf8")
with zipfile.ZipFile(OUT/"galeria.pk3","w",zipfile.ZIP_DEFLATED) as z:
    for name,content in sorted(resources.items()):
        entry=zipfile.ZipInfo(name,(1980,1,1,0,0,0))
        entry.compress_type=zipfile.ZIP_DEFLATED
        z.writestr(entry,content)
(OUT/"catalogo.txt").write_text("\n".join(f'{e["station"]:3}  {e["group"]}  -  {e["label"]}' for e in exhibits)+"\n","utf-8-sig")
(OUT/"roster.json").write_bytes((json.dumps(exhibits,ensure_ascii=False,indent=2)+"\n").encode())
print(f"{n} stationary exhibits")
