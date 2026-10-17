"""Sequential current-game door, save, hub and cartography checks."""
from pathlib import Path
import argparse
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
a=p.parse_args();work=ROOT/'build'/a.directory/'current'
scripts={
    'city-save':'wait 140; netevent mapdoors_begin; wait 25; netevent mapdoors_open; screenshot native-map06-door.png; wait 140; netevent mapdoors_done; netevent c318_seed; netevent c318_saved; storesavepic false; save inside.zds; wait 5; netevent c318_done; wait 5; quit\n',
    'city-hub-leave':'wait 20; netevent c318_saved; changemap MAP07; wait 30; netevent c318_hub; storesavepic false; save outside.zds; wait 5; netevent c318_done; wait 5; quit\n',
    'city-hub-return':'wait 20; netevent c318_hub; changemap MAP06; wait 30; netevent c318_saved; netevent mapdoors_begin; wait 25; netevent mapdoors_open; wait 140; netevent mapdoors_done; netevent c318_done; wait 5; quit\n',
}
for label,value in scripts.items():
    target=work/(label+'-commands.cfg');assert not target.exists();target.write_text(value)
for label,mapname,fixture,script,load in [
    ('city-save','MAP06','map-checks.pk3','city-save-commands.cfg',None),
    ('city-hub-leave','MAP06','map-checks.pk3','city-hub-leave-commands.cfg','inside.zds'),
    ('city-hub-return','MAP06','map-checks.pk3','city-hub-return-commands.cfg','outside.zds'),
    ('catalogue','MAP06','map-checks.pk3','catalogue.cfg',None),
    ('npc-home-doors','MAP06','npc-checks.pk3','npc.cfg',None),
    ('motion-save','MAP98','probe.pk3','save.cfg',None),
    ('motion-reload','MAP98','probe.pk3','load.cfg','issue318-native-motion.zds'),
]:
    cmd=[sys.executable,str(HERE/'run.py'),'--directory',a.directory,'--variant','current','--label',label,
         '--map',mapname,'--fixture',fixture,'--script',str(work/script),'--global-presentmon','--timeout','180']
    if load:cmd+=['--load',load]
    subprocess.run(cmd,cwd=ROOT,check=True)
