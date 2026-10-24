from pathlib import Path
import importlib.util,zipfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2];WORK=ROOT/'build/issue411-placement'
def main():
 spec=importlib.util.spec_from_file_location('placement',HERE.parent/'prepare.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 spec=importlib.util.spec_from_file_location('wad',ROOT/'assets/validation_580/prepare.py');w=importlib.util.module_from_spec(spec);spec.loader.exec_module(w)
 text=m.room().replace('texturefloor="CMST01"','texturefloor="CMGR01A"',1)
 members={'ZSCRIPT':b'version "4.14"\n#include "deploy.zs"\n','deploy.zs':(HERE/'checks.zs').read_bytes(),
 'MAPINFO':b'GameInfo {AddEventHandlers="CA411DeployChecks"}\ncluster 8419 {hub}\nmap MAP01 "Camp checks" {cluster=8419}\nmap CDEP411 "Camp return" {cluster=8419}\n',
 'maps/MAP01.wad':w.wad(text,'MAP01'),'maps/CDEP411.wad':w.wad(text,'CDEP411')}
 with zipfile.ZipFile(WORK/'deploy.pk3','w',zipfile.ZIP_STORED) as z:
  for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
 scripts={'deploy-legacytask':'wait 5; netevent ca411d_legacytask; wait 5; quit',
 'deploy-wide':'wait 35; netevent ca411d_wide; wait 5; quit',
 'deploy-handoff':'wait 35; netevent ca411d_handoff; wait 5; quit',
 'deploy-measure':'wait 35; netevent ca411d_measure; wait 5; quit',
 'deploy-climate':'wait 35; netevent ca411d_climate; wait 5; quit',
 'deploy-land':'wait 35; netevent ca411d_land; wait 5; quit',
 'deploy-taskseed':'wait 35; netevent ca411d_taskseed; save ca411d-task-ready; wait 5; quit',
 'deploy-taskload':'wait 5; netevent ca411d_taskload; wait 5; quit',
 'deploy-taskhub':'wait 5; netevent ca411d_taskload; changemap CDEP411; wait 35; netevent ca411d_taskload; wait 5; quit',
 'deploy-wait':'wait 35; netevent ca411d_wait; wait 5; quit',
 'deploy-core':'wait 35; netevent ca411d_core; wait 5; quit',
 'deploy-save':'wait 35; netevent ca411d_seed; save ca411d-ready; wait 5; quit',
 'deploy-load':'wait 5; netevent ca411d_loaded; wait 5; quit',
 'deploy-hub':'wait 5; netevent ca411d_loaded; changemap CDEP411; wait 35; netevent ca411d_loaded; changemap MAP01; wait 35; netevent ca411d_loaded; wait 5; quit'}
 for name,s in scripts.items():(WORK/(name+'.cfg')).write_text(s+'\n',encoding='utf-8')
 (WORK/'deploy-manual.cfg').write_text('exec ../../assets/playtest/default_controls.cfg\nbind F2 "netevent ca411d_report; toggleconsole"\nbind F3 "netevent ca411d_paving"\nbind F4 "netevent ca411d_garden"\nbind F5 "netevent ca411d_fast"\nwait 35; netevent ca411d_manual\n',encoding='utf-8')
if __name__=='__main__':main()
