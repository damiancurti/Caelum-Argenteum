"""Extend retained local/group relation fixtures with current-light equivalence."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
original=ROOT/'assets/validation_v5_17_104/run_local_edges.py'
source=original.read_text(encoding='utf-8')
end="exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})"
assert source.count(end)==1
extra=(Path(__file__).resolve().parent/'light_edges873.zs').read_text(encoding='utf-8')
marker='        Console.Printf("CA836 EDGE_RESULT checks='
files="    files={'ZSCRIPT':"
inject='    source=source.replace('+repr(marker)+','+repr(extra+marker)+',1)\n'+files
replacement='source=source.replace('+repr(files)+','+repr(inject)+')\n'+end
source=source.replace(end,replacement)
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
