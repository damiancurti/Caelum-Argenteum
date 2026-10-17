"""Open an author-requested interactive house preview with isolated config/saves."""
from pathlib import Path
import argparse
import json
import re
import subprocess
from house_fixture import package
from run import ENGINE, IWAD, ROOT

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory',required=True)
a=p.parse_args();work=ROOT/'build'/a.directory/'current'
assert (work/'runtime.pk3').is_file()
running=subprocess.run(['powershell','-NoProfile','-Command','(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'],capture_output=True,text=True)
assert not running.stdout.strip(), 'An existing engine is still open'
source='''class CA318PreviewMark : Inventory
{
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA318HousePreview : EventHandler
{
    int Age;
    ui bool ClosedInitialMenu;
    override void UiTick()
    {
        if(ClosedInitialMenu || Age<5)return;
        let menu=Menu.GetCurrentMenu();if(menu!=null)menu.Close();ClosedInitialMenu=true;
    }
    override void WorldTick()
    {
        Age++;
        let user=CaelumPlayer(players[0].mo);if(user==null || Age<5)return;
        if(user.FindInventory("CA318PreviewMark")!=null)return;
        user.GiveInventoryType("CA318PreviewMark");
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
        user.ApplyCharacterProfile();
        let record=user.GetPersistentCharacterState(true);
        record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
        vector3 point=CaelumCityData.DoorOutside(158);
        user.SetOrigin(point,false);user.FindFloorCeiling();user.ClearInterpolation();
        user.Angle=180;user.Pitch=0;
        Console.Printf("CA318 PREVIEW ready house=158; normal input enabled; isolated author preview");
    }
}
'''
package(work/'preview.pk3',{'ZSCRIPT':b'version "4.14"\n#include "preview.zs"\n',
    'preview.zs':source.encode(),'MAPINFO':b'GameInfo { AddEventHandlers="CA318HousePreview" }\n'})
config_source=ROOT/'build/gzdoom.ini'
config=config_source.read_text(encoding='utf-8-sig') if config_source.exists() else '[GlobalSettings]\n'
settings={'vid_preferbackend':'1','vid_vsync':'false','vid_maxfps':'0','cl_capfps':'false',
          'vid_fullscreen':'false','vid_defwidth':'1280','vid_defheight':'720','win_w':'1296','win_h':'759',
          'vid_activeinbackground':'true','i_pauseinbackground':'false','vid_lowerinbackground':'false',
          'snd_mastervolume':'0.05','use_mouse':'true','vid_fps':'true','language':'es','win_maximized':'false'}
for key,value in settings.items():
    pattern='^'+re.escape(key)+'=.*$'
    if re.search(pattern,config,re.M):config=re.sub(pattern,key+'='+value,config,flags=re.M)
    else:config=config.replace('[GlobalSettings]','[GlobalSettings]\n'+key+'='+value,1)
cfg=work/'author-preview.ini';assert not cfg.exists();cfg.write_text(config,encoding='utf-8')
args=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(work/'runtime.pk3'),str(work/'preview.pk3'),
      '-config',str(cfg),'-savedir',str(work),'-width','1280','-height','720','-window',
      '+logfile',str(work/'author-preview.txt'),'+map','MAP06']
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=1
proc=subprocess.Popen(args,cwd=work,startupinfo=startup)
(work/'author-preview-process.json').write_text(json.dumps({'pid':proc.pid,'args':args,'author_requested_visible':True},indent=2)+'\n')
print('AUTHOR PREVIEW PID',proc.pid,flush=True)
