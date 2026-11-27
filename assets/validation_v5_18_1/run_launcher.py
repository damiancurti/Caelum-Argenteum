"""Exercise the delivered PowerShell launcher using a disposable native profile."""
from pathlib import Path
import argparse,json,re,subprocess,time

ROOT=Path(__file__).resolve().parents[2]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--launcher',type=Path)
    args=parser.parse_args();directory=args.directory.resolve(strict=True)
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    commands=out/'commands.cfg'
    commands.write_text('wait 105; echo CA467_LAUNCH_READY; screenshot startup.png; wait 3; quit\n')
    config=out/'gzdoom.ini'
    config.write_text('[GlobalSettings]\nvid_fullscreen=false\nwin_w=1296\nwin_h=759\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n\n[CaelumArgenteum.AutoExec]\nPath='+commands.as_posix()+'\n')
    launcher=(args.launcher or directory/'run_release.ps1').resolve(strict=True)
    command=['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(launcher),'-Package',str(directory/'caelum_argenteum.ipk3'),'-ProfileDirectory',str(out)]
    (out/'command.json').write_text(json.dumps(command,indent=2)+'\n')
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    with (out/'stdout.txt').open('wb') as stream:
        result=subprocess.run(command,cwd=out,startupinfo=startup,stdout=stream,stderr=stream,timeout=180)
    log=(out/'latest.log').read_text(errors='replace')
    assert result.returncode==0 and 'CA467_LAUNCH_READY' in log and (out/'startup.png').exists()
    assert not re.search(r'adding .*[/\\](?:DOOM2?\.WAD|id24res\.wad)',log,re.I)
    stored=config.read_text(errors='replace')
    assert 'language=en' in stored and re.search(r'snd_mastervolume=0\.05',stored)
    bad=subprocess.run(command+['-LoadSave','C:/not-a-leaf.zds'],cwd=out,startupinfo=startup,capture_output=True,timeout=30)
    (out/'rejected-path.txt').write_bytes(bad.stdout+bad.stderr)
    assert bad.returncode!=0 and b'LoadSave must be a filename' in bad.stderr
    report={'issue':467,'launcher_exit':result.returncode,'native_completion':True,'commercial_iwad_loaded':False,
        'existing_language_volume_preserved':True,'absolute_save_path_rejected':True,'profile':str(out)}
    (out/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))


if __name__=='__main__':main()
