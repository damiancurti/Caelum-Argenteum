"""Build isolated sweat probes and preserve the pre-extension package for rollback."""
from prepare import HERE, OUT, package, test_map
import json
import subprocess

if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
    raise SystemExit('Finish the owned native run before replacing probe packages.')
members={'ZSCRIPT':b'version "4.14"\n#include "sweat.zs"\n',
    'sweat.zs':(HERE/'sweat.zs').read_bytes(), 'maps/CA133.wad':test_map(),
    'MAPINFO':b'map CA133 "Sweat validation" { cluster=434 }\nGameInfo { AddEventHandlers="CA133Sweat", "CA133SweatReload" }\n'}
package('sweat.pk3',members)
(OUT/'sweat.cfg').write_text('wait 115; save sweat-current; wait 10; quit\n',encoding='utf-8')
(OUT/'sweat-reload.cfg').write_text('wait 20; quit\n',encoding='utf-8')
(OUT/'sweat-hub.cfg').write_text('wait 5; changemap MAP03; wait 35; changemap CA133; wait 5; quit\n',encoding='utf-8')
(OUT/'sweat-volley.cfg').write_text('wait 500; save sweat-volley-500; wait 950; save sweat-volley-1450; wait 2050; save sweat-volley-3500; wait 10; quit\n',encoding='utf-8')
(OUT/'sweat-combined.cfg').write_text('ca132_stop_tic 10500; wait 10500; save sweat-combined; wait 10; quit\n',encoding='utf-8')

issue=json.loads(subprocess.check_output(['gh','issue','view','133','--json','body'],text=True,encoding='utf-8'))
marker='## Author-approved extension: sweating (2026-10-08)'
if marker not in issue['body']:
    issue['body']+='\n\n'+marker+'''

Keep carbine action heat and its existing Air cost. Add regulated sweating to the thermal service, not a firearm exemption:
- Reference humanoid: 80 kg / 1.75 m, maximum 2 L per world hour, scaled by body surface area.
- Production rises linearly from zero at equivalent exposure E=0 to maximum at E=+5.
- All humanoids, including Mandingas and Zupay, share this initial sweat profile while retaining racial comfort. Bulls and rats retain their existing heat exchange but no invented sweating profile.
- Full production above 20 Thirst points; linear reduction from 20 to zero. Zero means an exhausted gameplay hydration reserve, not an anatomically waterless body.
- Charge all secreted water using the existing mass-based drinking conversion (2 L / 100 points at 80 kg). Only evaporated water removes latent heat, once, at the existing 2.45 MJ/kg. Retained sweat wets clothing; runoff does not cool.
- Reuse humidity/vapor pressure, wind, surface area, clothing and immersion exchange. Preserve signed heat transfer toward energy balance, including metabolic heat.
- Replace the abstract thermal Thirst multiplier with actual sweat loss; retain basal/health/Air-regeneration costs and heat-related Air costs.
- Player hydration remains CurrentThirst; NPCs need an independent finite saved reserve, initialized once without automatic refills. Journey projections must couple water supplies and sweat without mutating live state or inventing real-time thermal damage.
- Validate mass/energy accounting, humidity/wind/clothing/immersion, no cold-induced secretion, authority, migration/save/load, travel supplies, native carbine heat and full-roster controls. Preserve the original thermal-death finding as pre-extension evidence; do not claim sweating necessarily fixes the action-heat calibration.
'''
    (OUT/'issue-sweat-body.md').write_text(issue['body'],encoding='utf-8')
    subprocess.run(['gh','issue','edit','133','--body-file',str(OUT/'issue-sweat-body.md')],check=True)
