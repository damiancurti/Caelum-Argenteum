"""Prepare the final author's actual-inventory equipment room.

Setup supplies canonical clothing, light armor, sword/buckler and a Box/chest
only inside a disposable diagnostic room. Normal inventory and input controls
remain authoritative after setup. No source gameplay or campaign save changes.
One-player cooperative mode permits saving the diagnostic corpse natively.
"""
from pathlib import Path
import argparse,importlib.util,json,re,subprocess,zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','output']:p.add_argument('--'+name,type=Path,required=True)
    p.add_argument('--interactive',action='store_true')
    a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    spec=importlib.util.spec_from_file_location('equipment_room',ROOT/'assets/validation_5100/prepare.py')
    room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
    old=ROOT/'assets/validation_v5_17_107'
    camera=(old/'wardrobe_continuity857.zs').read_text(encoding='utf-8')
    camera=camera[camera.index('class CA857Camera : Actor'):camera.index('class CA857Witness : Inventory')]
    source='\n'.join([(ROOT/'assets/validation_541/session.zs').read_text(encoding='utf-8'),
                     (old/'wardrobe_equipment857.zs').read_text(encoding='utf-8'),camera,
                     (HERE/'equipment_author.zs').read_text(encoding='utf-8')])
    mapinfo='gameinfo { PlayerClasses="CaelumDomingoPilotPlayer" AddEventHandlers="CA889EquipmentAuthor" }\n'
    mapinfo+='cluster 98 { hub } map CA836A "Equipment author room" { cluster=98 } map CA889B "Equipment travel room" { cluster=98 }\n'
    fixture=out/'equipment.pk3'
    with zipfile.ZipFile(fixture,'x') as z:
        for name,data in sorted({'ZSCRIPT':('version "4.14.2"\n'+source).encode(),
                 'MAPINFO':mapinfo.encode(),'maps/CA836A.wad':room.room(),'maps/CA889B.wad':room.room()}.items()):
            z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),data)
    (out/'equipment.zs').write_text(source,encoding='utf-8',newline='\n')
    config=out/'session.ini'
    config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=es\n',encoding='utf-8',newline='\n')
    # Native slot constants are read from the authoritative source, not inferred.
    constants=(ROOT/'src/caelum/core/CaelumConstants.zs').read_text(encoding='utf-8')
    slots={name:int(re.search(r'const\s+ARMOR_SLOT_'+name+r'\s*=\s*(\d+)',constants)[1]) for name in ['BODY','HEAD','HANDS','FEET']}
    commands='set ca_wardrobe_candidate true; wait 140; netevent ca889_setup; wait 10; '
    commands+='bind F1 "netevent ca889_view"; '
    for key,region in [(2,'BODY'),(3,'HEAD'),(4,'HANDS'),(5,'FEET')]:
        commands+=f'bind F{key} "netevent ca889_region {slots[region]}"; '
    commands+='bind F6 "netevent ca889_weapon"; bind F7 "netevent ca889_sex"; bind F8 "netevent ca889_moon"; '
    commands+='bind F9 "toggle ca_wardrobe_candidate"; bind F10 "changemap CA889B"; bind F11 "changemap CA836A"; bind F12 "netevent ca889_death";\n'
    cfg=out/'start.cfg';cfg.write_text(commands,encoding='utf-8',newline='\n')
    command=[str(ENGINE),'-host','1','-noautoload','-iwad',str(IWAD),'-file',str(a.runtime.resolve(strict=True)),str(fixture),
             '-config',str(config),'-savedir',str(out),'-window','-width','1280','-height','720',
             '+logfile',str(out/'engine.log'),'+map','CA836A','+exec',str(cfg)]
    print('F1 cámara / F2 cuerpo / F3 sombrero / F4 guantes / F5 calzado / F6 espada-carabina-bastón / F7 sexo / F8 clones de diagnóstico / F9 candidato / F10 otra sala / F11 regresar / F12 muerte de prueba. Inventario normal, Caja y cofre disponibles. Guardar desde Escape.',flush=True)
    if a.interactive:
        raise SystemExit(subprocess.call(command,cwd=out))
    (out/'prepared.json').write_text(json.dumps(dict(command=command,cwd=str(out)),indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':
    main()
