"""Prepare an isolated copy of the installed native engine for the viewed-pawn check.

Windows GZDoom reads bots from progdir/zcajun/bots.cfg. The original installation
is untouched; nothing from this local engine directory may be distributed.
Pass its absolute gzdoom.exe path to run_check.ps1 -Engine for viewed.cfg.
"""
from pathlib import Path
import shutil

source=Path('C:/Program Files (x86)/GZDoom')
target=Path(__file__).resolve().parents[2]/'build/issue131/engine'
target.mkdir(exist_ok=True)
for path in source.iterdir():
    if path.is_file() and (path.name=='gzdoom.exe' or path.suffix in ['.dll','.pk3']):
        shutil.copy2(path,target/path.name)
(target/'zcajun').mkdir(exist_ok=True)
(target/'zcajun/bots.cfg').write_text('{ name "QA131" aiming 0 perfection 0 reaction 0 isp 0 playerclass "CaelumPlayer" }\n')
