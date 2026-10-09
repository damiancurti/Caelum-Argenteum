"""Prepare comparable elemental-flight scenes in a local, isolated native room."""
from pathlib import Path
import importlib.util, subprocess, json, struct

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue137'
spec=importlib.util.spec_from_file_location('ca137_room',ROOT/'assets/validation_516/prepare.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base);base.OUT=OUT

def water_room():
    wad=base.room();_,count,directory=struct.unpack('<4sii',wad[:12])
    entries=[struct.unpack('<ii8s',wad[directory+i*16:directory+(i+1)*16]) for i in range(count)]
    start,length,_=next(e for e in entries if e[2].rstrip(b'\0')==b'TEXTMAP')
    text=wad[start:start+length].decode().replace('sector { heightfloor=0; heightceiling=256;', 'sector { id=77; heightfloor=0; heightceiling=256;')
    for x,y in [(-256,-256),(-256,-192),(-192,-192),(-192,-256)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
    for i in range(4):
        special='special=160; arg0=77; arg1=2; arg2=0; arg3=96;' if i==0 else ''
        text+=f'sidedef {{ sector=2; texturemiddle="CMST01"; }}\nlinedef {{ v1={6+i}; v2={6+(i+1)%4}; sidefront={8+i}; blocking=true; {special} }}\n'
    text+='sector { heightfloor=0; heightceiling=128; texturefloor="CMST02"; textureceiling="CMST02"; lightlevel=160; }\n'
    payload=b'';table=b''
    for name,content in [('CA137',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
        table+=struct.pack('<ii8s',12+len(payload),len(content),name.encode().ljust(8,b'\0'));payload+=content
    return struct.pack('<4sii',b'PWAD',3,12+len(payload))+payload+table

def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Finish the current native session before replacing fixtures.')
    OUT.mkdir(exist_ok=True)
    (OUT/'current').mkdir(exist_ok=True)
    base.package('current/caelum_argenteum_dev.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    for fixture in ['gallery','showcase','invariance','checks','stress','persist','water','deathframes']:
        file=HERE/(fixture+'.zs')
        if not file.exists():continue
        base.package(fixture+'.pk3',{
            'maps/CA137.wad':water_room() if fixture=='water' else base.room().replace(b'CA143',b'CA137'),
            'maps/CA137B.wad':base.room().replace(b'CA143',b'C137B'),
            'MAPINFO':f'cluster 437 {{ hub }}\nmap CA137 "Elemental VFX" {{ cluster=437 }}\nmap CA137B "Return" {{ cluster=437 }}\nGameInfo {{ AddEventHandlers="CA137{fixture.title()}" }}\n'.encode(),
            'ZSCRIPT':f'version "4.14"\n#include "{fixture}.zs"\n'.encode(),
            fixture+'.zs':file.read_bytes(),
            'CVARINFO':b'server int ca137_view=0;\nserver int ca137_mode=0;\n'})
    commands='unbindall;r_drawplayersprites false;wait 70;'
    for stage in range(27):
        commands+=f'ca137_view {stage};wait 4;screenshot flight-{stage}-early.png;wait 5;screenshot flight-{stage}-late.png;wait 21;'
    commands+='ca137_mode 1;wait 15;screenshot statuses-dark.png;wait 30;screenshot statuses-motion.png;ca137_mode 2;wait 15;screenshot statuses-bright.png;wait 20;exec bright.cfg\n'
    (OUT/'gallery.cfg').write_text(commands,encoding='utf-8')
    bright='ca137_mode 0;'
    for stage in range(27,36):bright+=f'ca137_view {stage};wait 4;screenshot bright-{stage}.png;wait 26;'
    bright+='ca137_mode 4;wait 15;screenshot varied-sizes.png;wait 25;quit\n'
    (OUT/'bright.cfg').write_text(bright,encoding='utf-8')
    (OUT/'sizes.cfg').write_text('unbindall;r_drawplayersprites false;ca137_view 27;ca137_mode 4;wait 90;screenshot varied-sizes.png;wait 35;quit\n',encoding='utf-8')
    commands='unbindall;r_drawplayersprites false;wait 70;'
    for stage in range(27):
        commands+=f'ca137_view {stage};'
        for frame in range(12):commands+=f'wait 2;screenshot movie-{stage*12+frame:04d}.png;'
    commands+='ca137_mode 4;wait 35;quit\n'
    (OUT/'flight-video.cfg').write_text(commands,encoding='utf-8')
    commands='unbindall;r_drawplayersprites false;wait 70;'
    for stage in range(18):
        commands+=f'ca137_view {stage};wait 4;screenshot showcase-{stage}-a.png;wait 10;screenshot showcase-{stage}-b.png;wait 16;'
    commands+='ca137_view 18;wait 5;screenshot javelin-up.png;wait 10;screenshot javelin-apex.png;wait 10;screenshot javelin-down.png;ca137_view 19;wait 15;quit\n'
    (OUT/'showcase.cfg').write_text(commands,encoding='utf-8')
    (OUT/'checks.cfg').write_text('unbindall;wait 130;quit\n',encoding='utf-8')
    (OUT/'water.cfg').write_text('unbindall;r_drawplayersprites false;wait 82;screenshot submerged.png;wait 40;quit\n',encoding='utf-8')
    (OUT/'invariance-before.cfg').write_text('unbindall;ca137_mode 0;wait 865;quit\n',encoding='utf-8')
    (OUT/'invariance-after.cfg').write_text('unbindall;ca137_mode 1;wait 865;quit\n',encoding='utf-8')
    (OUT/'persist.cfg').write_text('unbindall;wait 90;save ca137-legacy;wait 8;quit\n',encoding='utf-8')
    (OUT/'reload.cfg').write_text('unbindall;wait 70;save ca137-upgraded;wait 30;quit\n',encoding='utf-8')
    (OUT/'hub.cfg').write_text('unbindall;wait 70;changemap CA137B;wait 70;changemap CA137;wait 30;quit\n',encoding='utf-8')
    (OUT/'rollback.cfg').write_text('unbindall;wait 70;quit\n',encoding='utf-8')
    commands='unbindall;r_drawplayersprites false;wait 70;'
    for stage in range(16):
        commands+=f'ca137_view {stage};wait 3;screenshot death-frame-{stage}.png;wait 2;'
    commands+='ca137_view 16;wait 65;screenshot domingo-corpse.png;ca137_view 17;wait 40;screenshot rat-corpse.png;ca137_view 18;wait 5;quit\n'
    (OUT/'deathframes.cfg').write_text(commands,encoding='utf-8')
    for population in [0,24,499]:
        (OUT/f'stress-{population}.cfg').write_text(f'unbindall;r_drawplayersprites false;ca137_mode {population};wait 200;bench;wait 405;quit\n',encoding='utf-8')
    (OUT/'battle.cfg').write_text('unbindall;r_drawplayersprites false;ca137_view 1;ca137_mode 499;wait 200;bench;wait 250;screenshot dense-battle.png;wait 470;quit\n',encoding='utf-8')
    (OUT/'manual.cfg').write_text('bind w +forward;bind s +back;bind a +moveleft;bind d +moveright;bind mouse1 +attack;bind mouse2 +altattack;bind r +reload;bind z +zoom;bind c +crouch;wait 70\n',encoding='utf-8')
    # Reuse the validated launcher/error gate, scoped to this issue's evidence.
    for name in ['run_native.ps1','run_check.ps1']:
        text=(ROOT/'assets/validation_517'/name).read_text(encoding='utf-8-sig')
        text=text.replace('issue136','issue137').replace('CA136','CA137').replace("[string]$Map = 'MAP06'","[string]$Map = 'CA137'")
        if name=='run_native.ps1':text=text.replace('    $executionScript = Join-Path $work "$Label-exec.cfg"','    if ($commands.Contains(\'exec bright.cfg\')) {\n        $nextScript = Join-Path $work "$Label-bright.cfg"\n        $nextCommands = [IO.File]::ReadAllText((Join-Path $work \'bright.cfg\')).Replace(\'screenshot \', "screenshot $Label-")\n        [IO.File]::WriteAllText($nextScript,$nextCommands)\n        $commands = $commands.Replace(\'exec bright.cfg\',"exec $Label-bright.cfg")\n    }\n    $executionScript = Join-Path $work "$Label-exec.cfg"')
        if name=='run_native.ps1':text=text.replace('    $argsList += @(\'+exec\', "`"$executionScript`"")','    # Chunk after adding labels: GZDoom\'s exec parser has a bounded line buffer.\n    if ($commands.Length -gt 1500) {\n        $chunks = [Collections.Generic.List[string]]::new()\n        $part = \'\'\n        foreach ($command in ($commands -split \';\')) {\n            if ($part.Length + $command.Length -gt 1500) { $chunks.Add($part); $part = \'\' }\n            $part += $command + \';\'\n        }\n        if ($part.Length) { $chunks.Add($part) }\n        for ($index=0; $index -lt $chunks.Count; $index++) {\n            $path = if ($index -eq 0) { $executionScript } else { Join-Path $work "$Label-part-$index.cfg" }\n            $body = $chunks[$index]\n            if ($index+1 -lt $chunks.Count) { $body += "exec $Label-part-$($index+1).cfg" }\n            [IO.File]::WriteAllText($path,$body)\n        }\n    }\n    $argsList += @(\'+exec\', "`"$executionScript`"")')
        (HERE/name).write_text(text,encoding='utf-8')
    print('Prepared #137 runtime, fixtures and scoped native runner.')

if __name__=='__main__':main()
