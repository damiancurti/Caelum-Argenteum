"""Build isolated soldier-posture fixtures; do not distribute runtime packages."""
from pathlib import Path
import subprocess,zipfile,struct,hashlib
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue143'
BASE='5e550484f1a6c9cc7101dae37e8daaa8e47d03c2'
def package(name,members):
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
    return hashlib.sha256((OUT/name).read_bytes()).hexdigest()
def room():
    text='namespace="ZDoom";\n'
    for x,y in ((0,0),(0,8192),(6000,8192),(8192,8192),(8192,0),(6000,0)):
        text+=f'vertex {{ x={x}; y={y}; }}\n'
    for i in range(6):
        sector=0 if i in (0,1,5) else 1
        text+=f'sidedef {{ sector={sector}; texturemiddle="CMST01"; }}\nlinedef {{ v1={i}; v2={(i+1)%6}; sidefront={i}; blocking=true; }}\n'
    text+='sidedef { sector=0; texturetop="CMST01"; }\nsidedef { sector=1; texturetop="CMST01"; }\n'
    text+='linedef { v1=2; v2=5; sidefront=6; sideback=7; twosided=true; }\n'
    for height in (256,40):text+=f'sector {{ heightfloor=0; heightceiling={height}; texturefloor="CMST02"; textureceiling="CMST01"; lightlevel=224; }}\n'
    text+='thing { x=2048; y=4096; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }\n'
    payload=b'';directory=b''
    for name,data in [('CA143',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(payload),len(data),name.encode().ljust(8,b'\0'));payload+=data
    return struct.pack('<4sii',b'PWAD',3,12+len(payload))+payload+directory
def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():raise SystemExit('Finish native runs before replacing packages.')
    OUT.mkdir(exist_ok=True)
    package('production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    for fixture in ('checks','live','visual'):
        if not (HERE/(fixture+'.zs')).exists():continue
        extra=',"CA143Persistence"' if fixture=='checks' else ''
        package(fixture+'.pk3',{'maps/CA143.wad':room(),'maps/CA143B.wad':room().replace(b'CA143',b'C143B'),
            'MAPINFO':f'cluster 443 {{ hub }}\nmap CA143 "Posture test" {{ cluster=443 }}\nmap CA143B "Return test" {{ cluster=443 }}\nGameInfo {{ AddEventHandlers="CA143{fixture.title()}"{extra} }}\n'.encode(),
            'ZSCRIPT':f'version "4.14"\n#include "{fixture}.zs"\n'.encode(),fixture+'.zs':(HERE/(fixture+'.zs')).read_bytes(),
            'CVARINFO':b'server int ca143_view=0;\nserver bool ca143_manual=false;\n'})
    (OUT/'checks.cfg').write_text('unbindall; wait 85; save ca143-posture; wait 130; quit\n',encoding='utf-8')
    (OUT/'reload.cfg').write_text('wait 130; quit\n',encoding='utf-8')
    (OUT/'hub.cfg').write_text('wait 5; changemap CA143B; wait 5; changemap CA143; wait 5; quit\n',encoding='utf-8')
    (OUT/'live.cfg').write_text('unbindall; wait 1550; quit\n',encoding='utf-8')
    commands='unbindall; r_drawplayersprites false; wait 80; '
    for stage in range(32):commands+=f'ca143_view {stage}; wait 15; screenshot soldier-{stage}.png; '
    commands+='r_drawplayersprites true; wait 10; chase; +crouch; +zoom; wait 20; -zoom; wait 20; +attack; wait 100; -attack; wait 50; screenshot player-crouch.png; wait 15; -crouch; wait 55; screenshot player-standing.png; wait 10; quit\n'
    (OUT/'visual.cfg').write_text(commands,encoding='utf-8')
    (OUT/'manual.cfg').write_text('ca143_manual true; r_drawplayersprites false\n',encoding='utf-8')
    print('Prepared current soldier-posture package and isolated rooms.')
if __name__=='__main__':main()
