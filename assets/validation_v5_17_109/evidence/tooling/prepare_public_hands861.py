"""Expose portable ownership and counter reproduction without private paths."""
from pathlib import Path
import ast
h=Path(__file__).resolve().parent;root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');dest=root/'assets/validation_v5_17_109'
for kind in ('ownership','cache'):
 (dest/f'hand_{kind}861.zs').write_text((h/f'hands861_{kind}_full.zs').read_text(encoding='utf-8'),encoding='utf-8',newline='\n')
 source=(h/f'run_hands861_{kind}.py').read_text(encoding='utf-8').replace("root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')","root=Path(__file__).resolve().parents[2]").replace(f'hands861_{kind}_full.zs',f'hand_{kind}861.zs')
 (dest/f'run_hand_{kind}861.py').write_text(source,encoding='utf-8',newline='\n');ast.parse(source)
source=(h/'prepare_hands861_cache.py').read_text(encoding='utf-8');source=source[:source.index("s=(h/'hands861_candidate.zs')")]
a=source.index('h=Path(');b=source.index('\nplayer=',a)
source=source[:a]+'''import argparse
root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();out=args.output.resolve()
if not out.is_relative_to((root/'build').resolve()):parser.error('--output must be a new directory under this checkout/build')
out.mkdir(exist_ok=False)
'''.rstrip()+source[b:]
(dest/'build_hand_counter_overlay861.py').write_text(source,encoding='utf-8',newline='\n');ast.parse(source)
print('Portable ownership and lookup-counter tools prepared.')
