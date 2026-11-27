"""Run native #899 regressions against one built Caelum PK3 with GZDoom 4.14.2.

Pass --engine, --iwad, --package and --output. Every run creates fresh
peer directories, temporary QA-only PK3s, per-peer logs and results.json.
"""

from __future__ import annotations

import argparse
from itertools import combinations
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
from zipfile import ZIP_DEFLATED, ZipFile


SCENARIOS = {
    "free-departure": (1, 1),
    "votes-before-departure": (2, 2),
    "captive-departure": (3, 2),
}
LANGUAGES = ("es", "enu")
CHECKS = (*SCENARIOS, *LANGUAGES, "eight-arrivals")
STRINGS = Path(__file__).with_name("native_strings.json")
READY = re.compile(r"^CA899_READY slot=(\d+) members=7$", re.MULTILINE)
ERRORS = ("VM execution aborted", "Execution could not continue", "Script error")
ARRIVAL_MAPS = ("MAP01", "CAH000")

ARRIVALS = '''version "4.14.2"
class CaelumAuditArrivalRegression : StaticEventHandler
{
    bool Reported, TravelRequested;
    override void WorldLoaded(WorldEvent e)
    {
        Reported = false;
        TravelRequested = false;
    }
    override void WorldTick()
    {
        if (Reported)
        {
            if (!TravelRequested && level.MapName == "MAP01" && level.time >= 47)
            {
                TravelRequested = true;
                Level.ChangeLevel("CAH000", 0, CHANGELEVEL_NOINTERMISSION);
            }
            return;
        }
        if ((level.MapName != "MAP01" && level.MapName != "CAH000") || level.time < 35) return;
        Reported = true;
        int count = 0, pairs = 0, overlaps = 0;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            let body = CaelumPlayer(players[i].mo);
            if (body == null || body.Health <= 0) continue;
            count++;
            Console.Printf("CA899_ARRIVAL_BODY peer=%d map=%s slot=%d x=%.9f y=%.9f z=%.9f radius=%.9f",
                consoleplayer, level.MapName, i, body.Pos.X, body.Pos.Y, body.Pos.Z, body.Radius);
            for (int j = 0; j < i; j++)
            {
                if (!playeringame[j]) continue;
                let other = CaelumPlayer(players[j].mo);
                if (other == null || other.Health <= 0) continue;
                pairs++;
                double width = body.Radius + other.Radius;
                if (Abs(body.Pos.X - other.Pos.X) < width && Abs(body.Pos.Y - other.Pos.Y) < width)
                    overlaps++;
            }
        }
        Console.Printf("CA899_ARRIVALS peer=%d map=%s count=%d pairs=%d overlaps=%d",
            consoleplayer, level.MapName, count, pairs, overlaps);
    }
}
'''
ARRIVAL_RESULT = re.compile(
    r"^CA899_ARRIVALS peer=(\d+) map=(\w+) count=(\d+) pairs=(\d+) overlaps=(\d+)$", re.MULTILINE)
ARRIVAL_BODY = re.compile(
    r"^CA899_ARRIVAL_BODY peer=(\d+) map=(\w+) slot=(\d+) x=([-\d.]+) y=([-\d.]+) z=([-\d.]+) radius=([-\d.]+)$",
    re.MULTILINE)

HUNT = '''version "4.14.2"
class CaelumAuditNetworkRegression : StaticEventHandler
{
    int Phase;
    const Depart = DEPARTURE_SLOT;
    const Scenario = CASE_NUMBER;

    override void WorldTick()
    {
        let m = CaelumStandaloneMatch.View();
        if (m == null || !m.Started || m.Hunt == null) return;
        int active = m.ActiveMembers();
        if (Phase == 0 && m.Members == 7 && active == 7 && level.time >= 25)
        {
            Console.Printf("CA899_READY slot=%d members=%d", consoleplayer, m.Members);
            if (Scenario == 2)
                for (int i = 0; i < 3; i++) m.Hunt.CapturePlayer(CaelumPlayer(players[i].mo));
            if (Scenario == 3)
            {
                m.Hunt.CapturePlayer(CaelumPlayer(players[Depart].mo));
                Console.Printf("CA899_CAPTURED slot=%d target=%d held=%d",
                    consoleplayer, Depart, m.Hunt.Captive(Depart));
            }
            Phase = 1;
            return;
        }
        if (Phase == 1 && Scenario == 2 && m.Finished && active == 7)
        {
            for (int i = 0; i < 3; i++) if (i != Depart) m.VoteRematch(i);
            Console.Printf("CA899_WAIT slot=%d votes=%d restarting=%d",
                consoleplayer, m.RematchVotes, m.Restarting);
            Phase = 2;
            return;
        }
        int survivors = 7 ^ (1 << Depart);
        if (Phase == 1 && Scenario != 2 && active == survivors && level.time > 30)
        {
            Console.Printf("CA899_DEPART slot=%d left=%d active=%d seekers=%d ghost=%d",
                consoleplayer, Depart, active, m.Seekers(), m.Hunt.Captive(Depart));
            for (int i = 0; i < 3; i++) if (m.Seeker(i)) m.Hunt.CapturePlayer(CaelumPlayer(players[i].mo));
            Phase = 2;
            return;
        }
        if (Phase == 2 && Scenario != 2 && m.Finished)
        {
            Console.Printf("CA899_WIN slot=%d active=%d captive=%d finished=%d winner=%d",
                consoleplayer, active, m.Hunt.CaptiveMask, m.Finished, m.Winner);
            for (int i = 0; i < 3; i++) if ((active & (1 << i)) != 0) m.VoteRematch(i);
            Console.Printf("CA899_VOTES slot=%d active=%d votes=%d restarting=%d",
                consoleplayer, active, m.RematchVotes, m.Restarting);
            Phase = 3;
            return;
        }
        // Exigir el mapa nuevo, el padrón reducido y el reinicio de la votación.
        if (((Phase == 2 && Scenario == 2) || Phase == 3) && m.Members == survivors
            && m.Members == active && !m.Finished && !m.Restarting)
        {
            Console.Printf("CA899_NEW slot=%d active=%d members=%d finished=%d votes=%d",
                consoleplayer, active, m.Members, m.Finished, m.RematchVotes);
            Phase = 4;
        }
    }
}
'''


def make_probe(target, script, handler, mapinfo=b""):
    with ZipFile(target, "w", ZIP_DEFLATED) as package:
        package.writestr("ZSCRIPT", script)
        registration = f'\ngameinfo {{ AddEventHandlers = "{handler}" }}\n'.encode()
        package.writestr("MAPINFO", mapinfo + registration)


def start_engine(args, directory, probe, options, language="enu", *, low_memory=False):
    directory.mkdir()
    config = directory / "review.ini"
    software = "vid_rendermode=0\n" if low_memory else ""
    config.write_text(
        f"[GlobalSettings]\n{software}vid_preferbackend=0\nvid_fullscreen=false\nvid_maxfps=65\n"
        "i_pauseinbackground=false\ni_soundinbackground=true\nvid_lowerinbackground=false\nvid_activeinbackground=true\nsnd_mastervolume=0.05\n"
        f"language={language}\n", encoding="utf-8")
    resources = [] if args.iwad == args.package else [str(args.package)]
    command = [str(args.engine), "-stdout", "-noautoload", "-iwad", str(args.iwad),
               "-file", *resources, str(probe), "-config", str(config), "-savedir",
               str(directory), "-window", "-width", "320", "-height", "240", "+logfile",
               str(directory / "engine.log"), "+vid_preferbackend", "0"]
    if low_memory:
        command.extend(["+vid_rendermode", "0"])
    command.extend(options)
    env = os.environ.copy()
    if sys.platform.startswith("linux") and not (env.get("DISPLAY") or env.get("WAYLAND_DISPLAY")):
        env.setdefault("SDL_VIDEODRIVER", "offscreen")
        env.setdefault("LIBGL_ALWAYS_SOFTWARE", "1")
        env.setdefault("LP_NUM_THREADS", "2")
        env.setdefault("ALSOFT_DRIVERS", "null")
    if os.name == "posix":
        env.update(XDG_CACHE_HOME=str(directory.parent / "cache"),
                   XDG_CONFIG_HOME=str(directory.parent / "config"),
                   XDG_DATA_HOME=str(directory.parent / "data"))
    if low_memory:
        env.update(LP_NUM_THREADS="1", MALLOC_ARENA_MAX="1")
    startup = None
    if os.name == "nt":
        startup = subprocess.STARTUPINFO()
        startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup.wShowWindow = 4  # Show without activating the test window.
    with (directory / "process.log").open("wb") as output:
        return subprocess.Popen(command, cwd=directory, env=env, startupinfo=startup, stdout=output, stderr=subprocess.STDOUT)


def read_log(directory):
    path = directory / "engine.log"
    if not path.exists():
        path = directory / "process.log"
    text = path.read_text(encoding="utf-8", errors="replace")
    if any(marker in text for marker in ERRORS):
        raise RuntimeError(f"Native error in {path}\n{text[-1300:]}")
    return text


def stop(processes):
    for process in processes:
        if process.poll() is None:
            process.terminate()
    for process in processes:
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


def quit_config(directory, process_index):
    # Wait until GZDoom opens its next command file to deliver a normal quit.
    temp = directory / "quit.cfg"
    target = directory / f"poll-{process_index}.cfg"
    temp.write_text("quit\n", encoding="utf-8")
    for attempt in range(10):
        try:
            temp.replace(target)
            return
        except PermissionError:
            if attempt == 9:
                raise
            time.sleep(.1)


def arrival_evidence(logs, map_name):
    snapshots = {}
    markers = {}
    slots = set(range(8))
    for log in logs:
        reports = [m for m in ARRIVAL_RESULT.finditer(log) if m.group(2) == map_name]
        if len(reports) != 1:
            raise AssertionError(f"Expected one {map_name} arrival report per client, got {len(reports)}")
        result = reports[0]
        who, _, count, pairs, overlaps = result.groups()
        observer = int(who)
        if observer not in slots or observer in snapshots:
            raise AssertionError(f"Unexpected or repeated native observer {observer}")
        if (count, pairs, overlaps) != ("8", "28", "0"):
            raise AssertionError(result.group())
        bodies = {}
        for reporter, area, native_slot, x, y, z, radius in ARRIVAL_BODY.findall(log):
            if area != map_name:
                continue
            slot = int(native_slot)
            if int(reporter) != observer or slot in bodies or float(radius) <= 0:
                raise AssertionError(f"Invalid body {slot} reported by observer {observer}")
            bodies[slot] = tuple(map(float, (x, y, z, radius)))
        if bodies.keys() != slots:
            raise AssertionError(f"Observer {observer} saw players {sorted(bodies)}")
        for a, b in combinations(range(8), 2):
            ax, ay, _, ar = bodies[a]
            bx, by, _, br = bodies[b]
            if abs(ax - bx) < ar + br and abs(ay - by) < ar + br:
                raise AssertionError(f"Observer {observer} saw overlapping horizontal bounds for players {a}, {b}")
        snapshots[observer] = bodies
        markers[observer] = result.group()
    if snapshots.keys() != slots:
        raise AssertionError(f"Missing client reports: {sorted(slots - snapshots.keys())}")
    if any(bodies != snapshots[0] for bodies in snapshots.values()):
        raise AssertionError("Clients recorded different positions or radii for the same arrival")
    return {"peers": markers, "position_and_radius_by_slot": snapshots[0], "pairs_per_peer": 28}


def check_arrivals(args, directory):
    probe = directory / "arrivals-probe.pk3"
    make_probe(probe, ARRIVALS, "CaelumAuditArrivalRegression")
    directories = [directory / f"process-{index}" for index in range(8)]
    processes = []
    try:
        for index, peer in enumerate(directories):
            if index == 0:
                network = ["-host", "8", "-port", str(args.port), "-netmode", "0"]
            else:
                network = ["-join", f"127.0.0.1:{args.port}", "-port", str(args.port + index)]
            processes.append(start_engine(args, peer, probe, ["-warp", "1", *network], low_memory=True))
            time.sleep(.5)
        deadline = time.monotonic() + args.timeout
        while time.monotonic() < deadline:
            logs = [read_log(peer) for peer in directories]
            if all({m[1] for m in ARRIVAL_RESULT.findall(log)} == set(ARRIVAL_MAPS) for log in logs):
                return {area: arrival_evidence(logs, area) for area in ARRIVAL_MAPS}
            for index, process in enumerate(processes):
                if process.poll() is not None:
                    raise RuntimeError(f"Unexpected engine exit {process.returncode}: {directories[index]}")
            time.sleep(.25)
        raise TimeoutError(f"Missing eight client reports from the trip MAP01 -> CAH000. See {directory}")
    finally:
        stop(processes)


def check_hunt(args, directory, name):
    case, departure = SCENARIOS[name]
    active = 7 ^ (1 << departure)
    remaining = [slot for slot in range(3) if slot != departure]
    script = HUNT.replace("DEPARTURE_SLOT", str(departure)).replace("CASE_NUMBER", str(case))
    probe = directory / "network-probe.pk3"
    with ZipFile(args.package) as package:
        descriptor = package.read("caelum/data/standalone.mapinfo")
    make_probe(probe, script, "CaelumAuditNetworkRegression", descriptor)
    directories = [directory / f"process-{i}" for i in range(3)]
    processes = []
    quitting = None
    try:
        for i, peer in enumerate(directories):
            startup = directory / f"start-{i}.cfg"
            switch = directory / f"poll-{i}.cfg"
            startup.write_text(f'wait 20; exec "{switch.as_posix()}"\n', encoding="utf-8")
            switch.write_text(f'wait 20; exec "{startup.as_posix()}"\n', encoding="utf-8")
            if i == 0:
                options = ["-host", "3", "-port", str(args.port), "-netmode", "0"]
            else:
                options = ["-join", f"127.0.0.1:{args.port}", "-port", str(args.port + i)]
            options += ["+ca_standalone_mode", "4", "+ca_standalone_palomo", "0",
                        "+ca_standalone_preset", str(i), "+exec", str(startup)]
            if i == 0:
                options.extend(["+map", "CAHUNT"])
            processes.append(start_engine(args, peer, probe, options))
            time.sleep(.45)
        deadline = time.monotonic() + args.timeout
        while time.monotonic() < deadline:
            logs = [read_log(peer) for peer in directories]
            # Native slots depend on connection order, independent of the process index.
            slots = {int(m.group(1)): i for i, log in enumerate(logs) if (m := READY.search(log))}
            if quitting is None and set(slots) == {0, 1, 2}:
                marker = {1: "CA899_READY ", 2: "CA899_WAIT ", 3: "CA899_CAPTURED "}[case]
                if all(marker in log for log in logs):
                    quitting = slots[departure]
                    quit_config(directory, quitting)
            if quitting is not None and all("CA899_NEW " in logs[slots[slot]] for slot in remaining):
                break
            for index, process in enumerate(processes):
                if index != quitting and process.poll() is not None:
                    raise RuntimeError(f"Unexpected engine exit {process.returncode}: {directories[index]}")
            time.sleep(.25)
        else:
            raise TimeoutError(f"Missing hunt or restart markers. See {directory}")
        markers = {}
        for slot in remaining:
            expected = [f"CA899_NEW slot={slot} active={active} members={active} finished=0 votes=0"]
            if case == 2:
                expected.append(f"CA899_WAIT slot={slot} votes={active} restarting=0")
            else:
                expected.extend([
                    f"CA899_DEPART slot={slot} left={departure} active={active} seekers={active} ghost=0",
                    f"CA899_WIN slot={slot} active={active} captive={active} finished=1 winner=-1",
                    f"CA899_VOTES slot={slot} active={active} votes={active} restarting=1",
                ])
            if case == 3:
                expected.append(f"CA899_CAPTURED slot={slot} target={departure} held=1")
            lines = [line for line in logs[slots[slot]].splitlines() if line.startswith("CA899_")]
            missing = set(expected).difference(lines)
            if missing:
                raise AssertionError(f"Missing native markers on slot {slot}: {sorted(missing)}")
            markers[str(slot)] = lines
        return {"departed_slot": departure, "slots_to_processes": slots, "markers": markers}
    finally:
        stop(processes)


def check_language(args, directory, language):
    translations = json.loads(STRINGS.read_text(encoding="utf-8"))
    source = ['version "4.14.2"', 'class CaelumAuditLanguageRegression : StaticEventHandler {',
              'bool Printed;', 'override void WorldTick() {',
              'if (Printed || level.time < 3) return;', 'Printed = true;']
    for key in translations:
        source.append(f'Console.Printf("CA899_STRING {key}=%s", StringTable.Localize("{key}", false));')
    source += ['Console.Printf("CA899_LANGUAGE_END");', '}', '}']
    probe = directory / "language-probe.pk3"
    make_probe(probe, "\n".join(source), "CaelumAuditLanguageRegression")
    peer = directory / "process-0"
    process = start_engine(args, peer, probe, ["+language", language, "+map", "MAP01" if args.iwad == args.package else "TACTORS"], language)
    try:
        deadline = time.monotonic() + args.timeout
        while time.monotonic() < deadline:
            log = read_log(peer)
            if "CA899_LANGUAGE_END" in log:
                break
            if process.poll() is not None:
                raise RuntimeError(f"Unexpected engine exit {process.returncode}. See {peer}")
            time.sleep(.25)
        else:
            raise TimeoutError(f"Missing language markers. See {peer}")
        actual = dict(re.findall(r"^CA899_STRING (CA_[A-Z0-9_]+)=(.*)$", log, re.MULTILINE))
        differences = {key: [values[language], actual.get(key)] for key, values in translations.items()
                       if actual.get(key) != values[language]}
        if differences:
            raise AssertionError(json.dumps(differences, ensure_ascii=False, indent=2))
        return {"language": language, "matched": len(actual)}
    finally:
        stop([process])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for label in ("engine", "iwad", "package", "output"):
        parser.add_argument("--" + label, required=True, type=Path)
    parser.add_argument("--checks", nargs="+", choices=CHECKS, default=CHECKS)
    parser.add_argument("--port", type=int, default=25414, help="First UDP port for the host and local guests")
    parser.add_argument("--timeout", type=int, default=180, help="Maximum seconds per native scenario")
    args = parser.parse_args()
    max_port = 65528 if "eight-arrivals" in args.checks else 65533
    if not 1024 <= args.port <= max_port or args.timeout < 1:
        parser.error(f"Use ports 1024–{max_port} and a positive timeout")
    for label in ("engine", "iwad", "package"):
        path = getattr(args, label).resolve(strict=True)
        if not path.is_file():
            parser.error(f"Expected a file for --{label}")
        setattr(args, label, path)
    args.output.mkdir(parents=True, exist_ok=True)
    run = Path(tempfile.mkdtemp(prefix="native-899-", dir=args.output.resolve()))
    print(f"Native evidence: {run}", flush=True)
    results = {}
    try:
        for name in dict.fromkeys(args.checks):
            directory = run / name
            directory.mkdir()
            if name == "eight-arrivals":
                results[name] = check_arrivals(args, directory)
            elif name in LANGUAGES:
                results[name] = check_language(args, directory, name)
            else:
                results[name] = check_hunt(args, directory, name)
            print(f"{name} passed", flush=True)
    finally:
        (run / "results.json").write_text(json.dumps(results, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
