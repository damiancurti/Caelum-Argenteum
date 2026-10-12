"""Generate native control defaults from the approved #149 catalogue."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
catalog=json.loads(Path(__file__).with_name('controls_catalog.json').read_text(encoding='utf-8'))
keys=catalog['defaults']
removals=[f'unmapbind {key}' for key in catalog['automap_unbind']]
commands='; '.join([f'bind {key} {command}' for key,command in keys.items()]+removals)
path=ROOT/'src/KEYCONF'
text=path.read_text(encoding='utf-8')
marker='// BEGIN GENERATED CONTROL DEFAULTS'
if marker in text:text=text[:text.index(marker)]
text=text.rstrip()+'\n\n'+marker+'\n'
text+='// Sólo el primer inicio del lanzador o un reset solicitado aplican el preset.\n'
text+=f'alias ca_controls_defaults "{commands}"\n'
text+='alias ca_controls_reset "resetb2defaults; ca_controls_defaults"\n'
path.write_text(text,encoding='utf-8')
(ROOT/'src/DEFBINDS').write_text('// Native defaults load before existing INI bindings.\n'+''.join(f'bind {key} "{command}"\n' for key,command in keys.items()),encoding='utf-8')
(ROOT/'assets/playtest/default_controls.cfg').write_text('// First start only; generated from controls_catalog.json.\n'+''.join(f'bind {key} "{command}"\n' for key,command in keys.items())+'\n'.join(removals)+'\n',encoding='utf-8')
