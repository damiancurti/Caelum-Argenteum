"""Prepare the focused scenery fixture by reusing the existing exposure laboratory."""
from pathlib import Path
import runpy,subprocess,zipfile
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue502-scenery'
def main():
    active=subprocess.run(['powershell','-NoProfile','-Command','(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'],capture_output=True,text=True)
    if active.stdout.strip():raise RuntimeError('Close GZDoom before preparing fixtures.')
    WORK.mkdir(parents=True,exist_ok=True)
    (ROOT/'build/issue502-hygiene').mkdir(parents=True,exist_ok=True)
    runpy.run_path(str(ROOT/'assets/validation_5812/prepare_objects.py'))
    with zipfile.ZipFile(ROOT/'build/issue502-hygiene/object-checks.pk3') as old:
        members={n:old.read(n) for n in old.namelist()}
    members['checks.zs']+=b'\n'+(ROOT/'assets/validation_5816/checks.zs').read_bytes()
    members['MAPINFO']=members['MAPINFO'].replace(b'CA502ObjectChecks',b'CA502SceneryChecks')
    members['MENUDEF']=b'ListMenu CaelumLiveMenu { Class CA502SceneryMenu }\n'
    with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as out:
        for name,data in sorted(members.items()):out.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    commands={
        'core':'wait 70; netevent ca502s_seed 1; wait 3; netevent ca502s_core; wait 3; quit',
        'before':'wait 70; netevent ca502s_seed 0; wait 3; netevent ca502s_core; wait 3; quit',
        'seed':'wait 70; netevent ca502s_seed 1; wait 3; netevent ca502s_saveseed; save scenery-new; wait 3; quit',
        'oldseed':'wait 70; netevent ca502s_seed 0; wait 3; netevent ca502s_saveseed; save scenery-old; wait 3; quit',
        'load':'wait 1; netevent ca502s_load 1; wait 3; quit',
        'rollback':'wait 1; netevent ca502s_load 0; wait 3; quit',
        'census':'wait 350; netevent ca502o_census; wait 3; quit',
        'regression':'wait 70; netevent ca502o_prepare; wait 3; netevent ca502o_core; netevent ca502o_math; wait 3; quit',
        'manual-check':'wait 70; netevent ca502s_seed 1; wait 3; netevent ca502s_reset; netevent ca502s_rain; netevent ca502s_expose; wait 3; quit',
    }
    controls='; '.join(line.strip() for line in (ROOT/'assets/playtest/default_controls.cfg').read_text(encoding='utf-8').splitlines() if line.strip() and not line.lstrip().startswith('//'))
    commands['manual']=controls+'; bind F1 "netevent ca502s_reset"; bind F2 "netevent ca502s_read; toggleconsole"; bind F3 "netevent ca502s_expose"; bind F4 "netevent ca502s_rain"; wait 70; netevent ca502s_seed 1; wait 3; netevent ca502s_reset; echo CA502S INPUT ready'
    commands['manual-capture']=commands['manual']+'; wait 35; screenshot scenery-ready.png; netevent ca502s_rain; wait 3; screenshot scenery-rain.png; wait 3; quit'
    for name,text in commands.items():(WORK/(name+'.cfg')).write_text(text+'\n',encoding='utf-8')
if __name__=='__main__':main()
