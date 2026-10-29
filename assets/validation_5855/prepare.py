from pathlib import Path
import zipfile,shutil
R=Path(__file__).resolve().parents[2];A=Path(__file__).parent;W=R/'build/issue417-incidents'
with zipfile.ZipFile(W/'review410.pk3') as z:files={n:z.read(n) for n in z.namelist()}
files['ZSCRIPT']+=b'\n#include "rally.zs"\n';files['rally.zs']=(A/'checks.zs').read_bytes()
files['MAPINFO']+=b'\nGameInfo {AddEventHandlers="CA415RallyChecks"}\n'
with zipfile.ZipFile(W/'review415-rally.pk3','w') as z:
 for n,b in sorted(files.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
(W/'review415-rally.cfg').write_text('wait 140; netevent ca415rally_checks; wait 10; save review55-rally; wait 10; quit\n')
(W/'review415-load.cfg').write_text('wait 70; netevent ca415rally_load; wait 10; quit\n')
old=R.parent/'issue417-incidents-work/build/issue417-incidents'
shutil.copy2(old/'review-perf.pk3',W/'review-perf.pk3')
(W/'review-perf.cfg').write_text('wait 105; netevent ca415r_firstvisit 3600; wait 2; netevent ca415_await 7;\n')
