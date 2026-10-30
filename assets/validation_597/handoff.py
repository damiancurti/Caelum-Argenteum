"""Prepare/open separated V5.9 author scenarios against the final runtime.

No fixture or IWAD is packaged or committed. Each menu choice starts a fresh
isolated test; ordinary native saves remain available within that scenario.
"""
from pathlib import Path
import argparse
import json
import subprocess
import time
import zipfile
from prepare import wad

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/v59-review'
RUNTIME=ROOT/'build/issue423/current/caelum_argenteum_dev.pk3'
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
SCENES={
 '1':('418','Coordinacion de misiones y recompensas','CA418Checks','assets/validation_590/checks.zs','netevent ca418_seed; wait 8; netevent ca418_check; wait 5; netevent ca418_registry; wait 5; netevent ca418_destroyed; netevent ca418_done; toggleconsole'),
 '2':('419','Lectura emocional privada y persistente','CA59Manual','assets/validation_597/manual.zs','netevent ca59_setup 419'),
 '3':('420','Afiliacion, declaracion privada e informe','CA59Manual','assets/validation_597/manual.zs','netevent ca59_setup 420'),
 '4':('421','Historia: llegada y preparacion','CA59Manual','assets/validation_597/manual.zs','netevent ca59_setup 421'),
 '4a':('421','Historia: asedio en curso','CA59Manual','assets/validation_597/manual.zs','netevent ca59_setup 4211'),
 '4b':('421','Historia: victoria registrada','CA59Manual','assets/validation_597/manual.zs','netevent ca59_setup 4212'),
 '5':('422','Casa y testimonios del asedio','CA59Manual','assets/validation_597/manual.zs','netevent ca59_setup 422'),
 '5a':('422','Casa: reembolso de pagos registrados','CA59Manual','assets/validation_597/manual.zs','netevent ca59_setup 4222'),
 '6':('423','Uniformes, rostros y ropa de prisioneros','CA423Checks','assets/validation_597/checks.zs','netevent ca423_seed; wait 10; netevent ca423_visual; netevent ca423_done'),
 '7':('424','Comercio con faccion explicita','CA59Manual','assets/validation_597/manual.zs','netevent ca59_setup 424'),
 '8':('423','Ciudad real: movimiento y rendimiento','CA423Checks','assets/validation_597/checks.zs','netevent ca423_city; netevent ca423_done')}
for suffix,label,rank in [('a','Desconfiado',-50),('b','Amistoso',50),('c','Respetado',250),('d','Venerado',500),('e','Hostil',-250)]:
    SCENES['7'+suffix]=('424','Comercio: '+label,'CA59Manual','assets/validation_597/manual.zs',f'netevent ca59_setup 424; wait 8; netevent ca59_rank {rank}')
GUIDE={
 '1':'Ver PASS y RESULT failures=0. Esta opcion demuestra requisitos ALL/ANY, transiciones y recompensas idempotentes. La casa de la opcion 5 permite corroborar su uso jugable.',
 '2':'Leer las emociones; cerrar y volver a hablar: debe conservar el resultado. Guardar/cargar tampoco repite la tirada. La declaracion de afiliacion y el informe son opciones distintas.',
 '3':'Incorporarse con Leonor. Ir a Rufino e incorporarse tambien. Volver a Leonor: declarar la otra afiliacion no publica el dato; pedir el informe expulsa de Unitarios y aplica -100 una vez. TAB muestra tu reputacion. Leandro no ofrece afiliacion.',
 '4':'Escuchar llegada, consultar la situacion y hablar con el guardia. TAB solo muestra testimonios escuchados. Comparar despues 4a y 4b; son estados narrativos preparados, no una batalla simulada.',
 '4a':'Consultar situacion durante el asedio: no debe anunciar victoria.',
 '4b':'Consultar la victoria y los testimonios: no revela el secreto de Selene ni recuerdos recuperados.',
 '5':'Hablar con el encargado, despues con el guardia y regresar: se restituye la casa sin pago. Escuchar al guardia y a los cuatro rescatados para investigar el asedio. TAB permite abandonar/retomar; los testimonios persisten. Sin pagos previos no hay reembolso inventado.',
 '5a':'La preparacion paga dos alquileres y una compra reales. Completar el reconocimiento con el guardia y volver al encargado: devuelve 102.000 cobres una sola vez. Repetir la charla o cargar no vuelve a pagar.',
 '6':'Acercarse y rodear los cuatro guardias y cuatro prisioneros. Revisar caras/gorras, chaquetas azules, pantalones grises y ropa de los rescatados. No deben aparecer cabezas flotantes ni cambios de cuerpo. F6 guarda/F9 carga.',
 '7':'Comerciante diagnostico de Unitarios: F1 Desconfiado, F2 Neutral, F3 Amistoso, F4 Respetado, F5 Venerado, F7 Hostil. Comparar compra x1,50/1/0,85/0,75/0,66 y venta x0,80/1/1,05/1,10/1,15; hostil rechaza. Las tiendas civiles de campaña siguen sin faccion.',
 '8':'Caminar por Barracas y mirar a los guardias. Comparar fluidez al mirar la ciudad y el suelo. Esta opcion usa el mapa real; las otras usan una sala aislada.'}
for key in SCENES:
    if key.startswith('7') and key!='7':GUIDE[key]=GUIDE['7']+' Esta variante inicia directamente en '+SCENES[key][1]+'.'

def prepare():
    OUT.mkdir(parents=True,exist_ok=True)
    for key,(_,_,handler,source,_) in SCENES.items():
        members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':(ROOT/source).read_bytes()}
        info=f'GameInfo {{ AddEventHandlers="{handler}" }}\n'
        if key!='8':
            mapname='CA423A' if key=='6' else 'CA418A' if key=='1' else 'MAP03'
            members[f'maps/{mapname}.wad']=wad()
            info+=f'map {mapname} "V5.9 - issue {SCENES[key][0]}" {{ }}\n'
        members['MAPINFO']=info.encode()
        with zipfile.ZipFile(OUT/f'issue-{key}.pk3','w',zipfile.ZIP_STORED) as z:
            for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

def launch(key,verify=False):
    running=subprocess.check_output(['powershell','-NoProfile','-Command',"Get-Process | Where-Object ProcessName -eq 'gzdoom' | Select-Object -ExpandProperty Id"],text=True)
    if running.strip():print('Cierra la prueba actual desde Salir y vuelve a elegir.');return False
    label=f'{key}-{time.time_ns()}';folder=OUT/label;folder.mkdir()
    print('\n'+SCENES[key][1]+'\n'+GUIDE[key]+'\n',flush=True)
    (folder/'review.txt').write_text(GUIDE[key]+'\n',encoding='utf-8')
    ini=folder/'test.ini';ini.write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=true\nvid_maxfps=60\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_fullscreen=false\nlanguage=es\n',encoding='utf-8')
    commands=SCENES[key][4]
    cfg='bind e +use; bind w +forward; bind s +back; bind a +moveleft; bind d +moveright; bind Tab ca_journal_toggle; bind F6 quicksave; bind F9 quickload; '
    if key=='7':
        for button,rank in [('F1',-50),('F2',0),('F3',50),('F4',250),('F5',500),('F7',-250)]:cfg+=f'bind {button} "netevent ca59_rank {rank}"; '
    cfg+='wait 80; '+commands
    if verify:
        cfg+='; wait 15; '+('netevent ca59_verify' if SCENES[key][2]=='CA59Manual' else '')+'; screenshot review.png; wait 10; quit'
    cfg+='\n';(folder/'test.cfg').write_text(cfg,encoding='utf-8')
    command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(RUNTIME),str(OUT/f'issue-{key}.pk3'),'-config',str(ini),'-savedir',str(folder),'-window','-width','1280','-height','720','-rngseed',SCENES[key][0],'+logfile',str(folder/'test.log'),'+map','CA423A' if key=='6' else 'CA418A' if key=='1' else 'MAP03','+exec',str(folder/'test.cfg')]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0 if verify else 1
    p=subprocess.Popen(command,cwd=folder,startupinfo=startup);started=time.time()
    while p.poll() is None:
        log=(folder/'test.log').read_text(errors='replace') if (folder/'test.log').exists() else ''
        if verify and (time.time()-started>75 or any(s in log for s in ['Script error','Execution could not continue','VM execution aborted'])):
            p.terminate();break
        time.sleep(.4)
    p.wait(timeout=5)
    log=(folder/'test.log').read_text(errors='replace')
    errors=[s for s in log.splitlines() if any(t in s for t in [' FAIL','Script error','Unknown command','Execution could not continue','VM execution aborted'])]
    (folder/'command.json').write_text(json.dumps({'command':command,'errors':errors,'exit':p.returncode},indent=2)+'\n')
    print('Registro: '+str(folder/'test.log'),flush=True)
    if errors:print('\n'.join(errors),flush=True)
    if verify and (errors or p.returncode):raise SystemExit('Scenario verification failed.')
    return True

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--verify');ap.add_argument('--prepare',action='store_true');a=ap.parse_args()
    prepare()
    if a.prepare:return
    if a.verify:
        for k in a.verify.split(','):launch(k,True)
        return
    while True:
        print('\nCAELUM ARGENTEUM 5.9 - PRUEBAS POR ISSUE\nE usar | TAB Diario | F6 guardar | F9 cargar\nCierra GZDoom para volver a esta terminal. Cada opcion empieza una prueba nueva.\n')
        for k in sorted(SCENES,key=lambda s:(int(s[0]),s[1:])):
            v=SCENES[k];print(f' {k:>2} - #{v[0]} {v[1]}')
        key=input('\nNumero y Enter (Q termina): ').strip().lower()
        if key=='q':return
        if key in SCENES:launch(key)

if __name__=='__main__':main()
