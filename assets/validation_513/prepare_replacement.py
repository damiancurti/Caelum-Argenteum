"""Add a read/write diagnostic handler beside the unchanged saved route fixture."""
from prepare import HERE, OUT, package
(OUT/'replacement').mkdir(exist_ok=True)
package('replacement/routes.pk3',{
    'ZSCRIPT':b'version "4.14"\n#include "routes.zs"\n#include "replacement.zs"\n',
    'routes.zs':(HERE/'routes.zs').read_bytes(),
    'replacement.zs':(HERE/'replacement.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA133Routes", "CA133Replacement" }\n'})
(OUT/'replacement.cfg').write_text('wait 3500; save ca133-replacement; wait 10; quit\n',encoding='utf-8')
