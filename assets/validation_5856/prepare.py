from pathlib import Path
import zipfile
R=Path(__file__).resolve().parents[2];W=R/'build/issue417-incidents'
with zipfile.ZipFile(W/'review416-music.pk3','w') as z:
 for n,b in {'ZSCRIPT':b'version "4.14"\n#include "music.zs"\n','music.zs':(Path(__file__).parent/'checks.zs').read_bytes(),'MAPINFO':b'GameInfo {AddEventHandlers="CA416MusicChecks"}\n'}.items():z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
(W/'review416-music.cfg').write_text('wait 210; quit\n')
