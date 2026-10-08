"""Reuse the accepted native HUD scene for the author's color follow-up."""
from prepare import HERE, OUT, ROOT, package
import zipfile

with zipfile.ZipFile(OUT / 'checks.pk3') as z:
    room = z.read('maps/CA140.wad')
package('hud.pk3', {
    'maps/CA140.wad': room,
    'MAPINFO': b'map CA140 "Exposure label colors" { }\nGameInfo { AddEventHandlers="CA131Visual" }\n',
    'ZSCRIPT': b'version "4.14"\n#include "visual.zs"\n',
    'visual.zs': (ROOT / 'assets/validation_511/visual.zs').read_bytes(),
    'CVARINFO': b'server int ca131_case=0;\n',
})
commands = ['unbindall', 'wait 80']
for case in (0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11):
    commands += [f'ca131_case {case}', 'wait 5',
                 f'screenshot exposure-{case:02}.png']
commands += ['wait 5', 'quit']
(OUT / 'hud.cfg').write_text('; '.join(commands) + '\n', encoding='utf-8')
print('Prepared bounded native exposure-color captures.')
