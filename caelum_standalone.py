"""Launch isolated native matches from the in-game Multiplayer menu (#597).

GZDoom creates its lockstep network at process startup. The menu writes a small
request to its own log and exits; this bridge validates it and starts a fresh
process. No profile registry or campaign save is read, copied or published.
"""
from __future__ import annotations
import argparse
import datetime
import ipaddress
import json
import os
from pathlib import Path
import re
import subprocess
import uuid
import zipfile

from caelum_sessions import manifest, verify_manifest, write_new, control_preset
from caelum_profiles import ProfileError

ROOT = Path(__file__).resolve().parent
MARKER = 'CA_STANDALONE_REQUEST '


def endpoint(value: str) -> str:
    value = value.strip()
    if not value or len(value) > 253:
        raise ValueError('Invalid host address.')
    try:
        ipaddress.ip_address(value)
    except ValueError:
        if not re.fullmatch(r'[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?', value):
            raise ValueError('Invalid host address.')
    return value


def request(line: str) -> dict:
    if not line.startswith(MARKER):
        raise ValueError('Not a standalone menu request.')
    fields = line[len(MARKER):].split('|')
    if len(fields) != 8 or any('\r' in x or '\n' in x for x in fields):
        raise ValueError('Malformed standalone menu request.')
    role, mode, preset, count, port, venue = map(int, fields[:6])
    if role not in (0, 1) or mode not in range(4) or preset not in range(4):
        raise ValueError('Unknown standalone selection.')
    if not 2 <= count <= 8 or not 1024 <= port <= 65527 or venue not in (0, 1):
        raise ValueError('Invalid session size, port or venue.')
    return dict(role=role, mode=mode, preset=preset, players=count, port=port,
                venue=venue, host=endpoint(fields[6]), session=fields[7].strip())


def isolated_config() -> bytes:
    return (b'[GlobalSettings]\nvid_fullscreen=false\nvid_activeinbackground=true\n'
            b'i_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\n')


def prepare(selection: dict, directory: Path, engine: Path, iwad: Path,
            packages: list[Path]) -> tuple[list[str], dict]:
    """Create a fresh local participant directory; never reuse a campaign INI."""
    # Validate even callers that did not originate in the native menu.
    selection = request(MARKER + '|'.join(str(selection[k]) for k in
        ('role', 'mode', 'preset', 'players', 'port', 'venue', 'host', 'session')))
    directory.mkdir(parents=True, exist_ok=False)
    if selection['role'] == 0:
        session = dict(revision=1, token=str(uuid.uuid4()), mode=selection['mode'],
                       venue=selection['venue'], players=selection['players'],
                       port=selection['port'], manifest=manifest(engine, iwad, packages))
        write_new(directory/'session.json', (json.dumps(session, indent=2)+'\n').encode())
        network = ['-host', str(session['players']), '-port', str(session['port']), '-netmode', '0']
    else:
        session = json.loads(Path(selection['session']).resolve(strict=True).read_text(encoding='utf-8'))
        if (session.get('revision') != 1 or session.get('mode') not in range(4)
                or session.get('venue') not in (0, 1) or not 2 <= session.get('players', 0) <= 8
                or not 1024 <= session.get('port', 0) <= 65527):
            raise ValueError('Invalid standalone session file.')
        verify_manifest(session['manifest'], engine, iwad, packages)
        # Native joining assigns the slot; no campaign identity is claimed.
        host=selection['host'];host=f'[{host}]' if ':' in host else host
        network = ['-join', f'{host}:{session["port"]}', '-port', '0']
    write_new(directory/'game.ini', isolated_config())
    write_new(directory/'controls.cfg', control_preset(packages[0]).encode())
    # The tiny activation package has deterministic bytes and only selects the
    # class already owned by the pinned runtime. It contains no campaign data.
    activation=directory/'standalone.pk3'
    with zipfile.ZipFile(packages[0]) as runtime:
        setup=runtime.read('caelum/data/standalone.mapinfo')
    with zipfile.ZipFile(activation,'x') as package:
        package.writestr(zipfile.ZipInfo('MAPINFO',(2000,1,1,0,0,0)),setup)
    cmd = [str(engine), '-noautoload', '-iwad', str(iwad), '-file', *map(str, packages),
           str(activation),
           '-config', str(directory/'game.ini'), '-savedir', str(directory), *network,
           '+logfile', str(directory/'engine.log'), '+exec', str(directory/'controls.cfg'),
           '+ca_standalone_mode', str(session['mode']+1),
           '+ca_standalone_preset', str(selection['preset'])]
    if selection['role'] == 0:
        cmd += ['+map', 'CARING' if session['venue'] == 0 else 'CASEWER']
    write_new(directory/'command.json', (json.dumps(cmd, indent=2)+'\n').encode())
    return cmd, session


def run_menu(engine: Path, iwad: Path, packages: list[Path], config: Path, root: Path) -> int:
    """A failed/cancelled launch never modifies the caller's save directory."""
    root.mkdir(parents=True, exist_ok=True)
    while True:
        attempt = root/(datetime.datetime.now().strftime('%Y%m%d-%H%M%S-')+uuid.uuid4().hex[:8])
        attempt.mkdir()
        log=attempt/'menu.log'
        cmd=[str(engine),'-noautoload','-iwad',str(iwad),'-file',*map(str,packages),
             '-config',str(config),'+logfile',str(log),'+ca_standalone_bridge','1']
        if not config.exists():cmd+=['+exec',str(ROOT/'assets/playtest/default_controls.cfg')]
        code=subprocess.call(cmd)
        text=log.read_text(encoding='utf-8',errors='replace') if log.exists() else ''
        lines=[line for line in text.splitlines() if line.startswith(MARKER)]
        if code != 0 or not lines:return code
        try:
            if len(lines)!=1:raise ValueError('Multiple launch requests; no session started.')
            selection=request(lines[0])
            command,session=prepare(selection,attempt/'match',engine,iwad,packages)
            print('Session:',attempt/'match/session.json',flush=True)
            print('Players:',session['players'],'Port:',session['port'],flush=True)
            code=subprocess.call(command)
            print('Match ended:',code,flush=True)
        except (ValueError,OSError,KeyError,ProfileError) as exc:
            print('Session not started:',exc,flush=True)
        # A new title process starts with the original campaign config only.


def main() -> int:
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine',type=Path,required=True)
    parser.add_argument('--iwad',type=Path,required=True)
    parser.add_argument('--package',type=Path,action='append',required=True)
    parser.add_argument('--config',type=Path,default=ROOT/'build/gzdoom.ini')
    parser.add_argument('--root',type=Path,default=Path(os.environ.get('LOCALAPPDATA',str(Path.home())))/'CaelumArgenteum/matches')
    args=parser.parse_args()
    engine=args.engine.resolve(strict=True);iwad=args.iwad.resolve(strict=True)
    packages=[p.resolve(strict=True) for p in args.package]
    manifest(engine,iwad,packages)
    return run_menu(engine,iwad,packages,args.config.resolve(),args.root.resolve())


if __name__=='__main__':raise SystemExit(main())
