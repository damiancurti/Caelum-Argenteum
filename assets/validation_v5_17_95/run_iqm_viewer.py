"""Prepare the isolated format viewer for the final consolidated author session."""
from pathlib import Path
import argparse, json, subprocess, sys, zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from run_iqm_preview import ENGINE, IWAD, candidate_package, digest, view_data, wad, write_console_chain

VIEWER = '''
// #834: controles del visor aislado; no altera el juego normal.
class CA834AuthorEvents : CA834PreviewEvents
{
    override bool InputProcess(InputEvent e){return false;}
    override void RenderOverlay(RenderEvent e)
    {
        if(Camera==null)return;
        String kind=Selected==0?"MD3":Selected==1?"IQM":"Hybrid (MD3 cape)";
        String label=String.Format("#834 candidate: %s / pose %d / view %d",kind,Pose,Rotation);
        Screen.DrawText(Font.GetFont("CaelumMono"),Font.CR_WHITE,8,8,label,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_KEEPRATIO,true);
        Screen.DrawText(Font.GetFont("CaelumMono"),Font.CR_WHITE,8,22,"F1 MD3 / F2 IQM / F3 hybrid / F4 view / F5 pose",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_KEEPRATIO,true);
        Screen.DrawText(Font.GetFont("CaelumMono"),Font.CR_WHITE,8,36,"F6 walk / F7 rest / F8 hide hair / F9 restore",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_KEEPRATIO,true);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca834_play")
        {Reference.Animate();Candidate.Animate();Hybrid.Animate();return;}
        if(e.Name=="ca834_smoke")
        {
            Check(Reference.Live && Candidate.Live && Hybrid.Live,"all viewer formats animate");
            Check(Candidate.BindingsReady && Hybrid.BindingsReady,"viewer skeletal bindings ready");
            Check(Candidate.CurState==Reference.CurState && Hybrid.CurState==Reference.CurState,"viewer animation samples remain synchronized");
            return;
        }
        Super.NetworkProcess(e);
    }
}
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for key in ['runtime', 'candidate', 'output']:
        parser.add_argument('--' + key, type=Path, required=True)
    parser.add_argument('--smoke', action='store_true', help='Run a bounded hidden viewer check; do not hand off to the author.')
    args = parser.parse_args()
    tasks = subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/FO', 'CSV', '/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in tasks.lower():
        parser.error('Another native engine is running.')
    runtime = args.runtime.resolve(strict=True)
    candidate = args.candidate.resolve(strict=True)
    out = args.output.resolve(); out.relative_to(ROOT / 'build'); out.mkdir(parents=True, exist_ok=False)
    overlay = candidate_package(candidate, out / 'candidate.pk3')
    source = view_data(candidate, runtime) + Path(__file__).with_name('iqm_preview.zs').read_text(encoding='utf-8') + VIEWER
    with zipfile.ZipFile(runtime) as package:
        definition = package.read('caelum/data/domingo_modules.modeldef').decode('utf-8').replace('CaelumDomingoPilotBody', 'CA834MD3Preview')
    fixture = out / 'viewer.pk3'
    with zipfile.ZipFile(fixture, 'w') as package:
        for name, data in {'ZSCRIPT': ('version "4.14.2"\n' + source).encode(), 'MODELDEF': definition.encode(),
                           'maps/CA455V.wad': wad(224), 'MAPINFO': b'gameinfo { AddEventHandlers="CA834AuthorEvents" }\nmap CA455V "Format candidate viewer" { sky1="CABASKY",0 nointermission }\n'}.items():
            package.writestr(zipfile.ZipInfo(name, (2026, 11, 19, 0, 0, 0)), data)
    (out / 'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=enu\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\n', encoding='utf-8')
    commands = 'screenblocks 12; fov 60; crosshair 0; con_notifytime 0; wait 140; netevent ca834_prepare; wait 20; '
    for count, key, event in [(8, 'F4', 'rotate'), (24, 'F5', 'pose')]:
        for index in range(count):
            commands += f'alias ca834_{event}{index} "netevent ca834_{event} {index}; bind {key} ca834_{event}{(index+1)%count}"; '
        commands += f'bind {key} ca834_{event}1; '
    commands += 'bind F1 "netevent ca834_select 0"; bind F2 "netevent ca834_select 1"; bind F3 "netevent ca834_select 2"; bind F6 "netevent ca834_pose 1; netevent ca834_play"; bind F7 "netevent ca834_pose 0"; bind F8 "netevent ca834_module 4 0"; bind F9 "netevent ca834_restore"; '
    if args.smoke:
        commands += 'netevent ca834_select 2; netevent ca834_pose 1; netevent ca834_play; wait 11; netevent ca834_smoke; screenshot viewer.png; wait 5; quit;'
    write_console_chain(out, 'viewer', commands)
    command = [str(ENGINE), '-noautoload', '-nomouse', '-iwad', str(IWAD), '-file', str(runtime), str(overlay), str(fixture), '-config', str(out / 'session.ini'), '-savedir', str(out), '-window', '+logfile', str(out / 'engine.log'), '+map', 'CA455V', '+exec', str(out / 'viewer.cfg')]
    print('F1 MD3 / F2 IQM / F3 hybrid / F4 view / F5 pose / F6 walk / F7 rest / F8 hide hair / F9 restore. Isolated candidate review.', flush=True)
    if not args.smoke:
        subprocess.run(command, cwd=out, check=True)
        return
    startup = subprocess.STARTUPINFO(); startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW; startup.wShowWindow = 0
    with (out / 'process.log').open('wb') as stream:
        result = subprocess.run(command, cwd=out, startupinfo=startup, stdout=stream, stderr=stream, timeout=120)
    log = (out / 'engine.log').read_text(errors='replace')
    errors = [line for line in log.splitlines() if any(token in line for token in ['Script error', 'Execution could not continue', 'VM execution aborted', 'Unknown command', 'CA834 FAIL'])]
    count = sum(line.startswith('CA834 PASS') for line in log.splitlines())
    report = {'issue': 834, 'runtime_sha256': digest(runtime), 'fixture_sha256': digest(fixture), 'exit_code': result.returncode, 'errors': errors, 'assertions': count, 'passed': result.returncode == 0 and not errors and count == 6, 'qualification': 'Automated bounded viewer smoke; not an author session or acceptance.'}
    (out / 'RESULTS.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report))
    raise SystemExit(not report['passed'])


if __name__ == '__main__':
    main()
