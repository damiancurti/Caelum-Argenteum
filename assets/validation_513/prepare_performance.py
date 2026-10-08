"""Reuse #132's observer unchanged for matched legacy and combined controls."""
from prepare import ROOT, HERE, OUT, package
source=(ROOT/'assets/validation_512/observer.zs').read_bytes()
members={'ZSCRIPT':b'version "4.14"\n#include "observer.zs"\n',
         'observer.zs':source,'MAPINFO':b'GameInfo { AddEventHandlers="CA132Observer" }\n',
         'CVARINFO':b'server bool ca132_diagnostic=false; server int ca132_stop_tic=3500;\n'}
package('observer.pk3',members)
members['ZSCRIPT']+=b'#include "combined.zs"\n'
members['combined.zs']=(HERE/'combined.zs').read_bytes()
members['MAPINFO']=b'GameInfo { AddEventHandlers="CA133Combined", "CA132Observer" }\n'
members['CVARINFO']+=b'server int ca133_attack_tic=1750;\n'
package('combined.pk3',members)
members['ZSCRIPT']=b'version "4.14"\n#include "observer.zs"\n#include "volleys.zs"\n'
members['volleys.zs']=(HERE/'volleys.zs').read_bytes()
members['MAPINFO']=b'GameInfo { AddEventHandlers="CA133Volleys", "CA132Observer" }\n'
package('volleys.pk3',members)
(OUT/'performance.cfg').write_text('wait 3500; wait 5; quit\n',encoding='utf-8')
(OUT/'combined.cfg').write_text('ca132_stop_tic 10500; wait 10500; save ca133-combined; wait 10; quit\n',encoding='utf-8')
