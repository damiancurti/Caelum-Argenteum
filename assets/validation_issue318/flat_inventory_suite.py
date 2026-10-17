"""Matched inventory ablations, using unchanged runtime/observer bytes."""
from pathlib import Path
import argparse
import subprocess
import sys
from flat_army_fixture import package

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
p.add_argument('--prepare',action='store_true');a=p.parse_args();base=f'build/{a.directory}/current'
if a.prepare:
    dest=ROOT/base/'no-inventory.pk3';assert not dest.exists()
    package(dest,{'ZSCRIPT':b'version "4.14"\n#include "inventory.zs"\n',
       'inventory.zs':(HERE/'flat_inventory.zs').read_bytes(),
       'MAPINFO':b'GameInfo { AddEventHandlers="CA318FlatInventory" }\n'})
else:
    # Keep the paired sprite inventory comparison in ABBA order; then two
    # visual-model repetitions and an instrumented run of the same ablation.
    for variant,label,empty,model in [
        ('current','inventory-kept-01',False,False),
        ('current','inventory-empty-02',True,False),
        ('current','inventory-empty-03',True,False),
        ('current','inventory-kept-04',False,False),
        ('current','inventory-empty-models-01',True,True),
        ('current','inventory-empty-models-02',True,True),
        ('profile','inventory-empty-profile',True,False)]:
        cmd=[sys.executable,str(HERE/'run.py'),'--directory',a.directory,'--variant',variant,'--label',label,
             '--map','MAP98','--warmup','35','--window','175','--timeout','240','--postwait','10','--global-presentmon']
        if empty:cmd+=['--addon2',base+'/no-inventory.pk3']
        if model:cmd+=['--addon',base+'/domingo.pk3']
        subprocess.run(cmd,cwd=ROOT,check=True)
