"""Run one bounded native scenario, preserving logs, configuration and hashes."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import time

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "build/issue422"
ENGINE = Path("C:/Program Files (x86)/GZDoom/gzdoom.exe")
IWAD = Path("C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("label")
    parser.add_argument("--legacy", action="store_true")
    parser.add_argument("--city", action="store_true")
    parser.add_argument("--load")
    parser.add_argument("--map", default="MAP03")
    parser.add_argument("--language", default="enu")
    parser.add_argument("--commands", default="netevent ca422_seed; wait 8; netevent ca422_open; netevent ca422_rules; netevent ca422_done")
    args = parser.parse_args()
    running = subprocess.check_output(["powershell", "-NoProfile", "-Command",
        "Get-Process | Where-Object ProcessName -eq 'gzdoom' | Select-Object -ExpandProperty Id"], text=True)
    if running.strip():
        raise SystemExit("A native engine is already running; preserve it before starting another.")
    log = OUT / f"{args.label}.log"
    if log.exists():
        raise SystemExit("Use a new label to preserve previous evidence.")
    ini = OUT / f"{args.label}.ini"
    ini.write_text("[LastRun]\nVersion=225\n[GlobalSettings]\n"
        "vid_preferbackend=1\nvid_vsync=true\nvid_maxfps=60\ncl_capfps=false\n"
        "vid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\n"
        "i_soundinbackground=true\nsnd_mastervolume=0.05\nvid_fullscreen=false\nuse_mouse=false\n"
        f"language={args.language}\n", encoding="utf-8")
    cfg = OUT / f"{args.label}.cfg"
    cfg.write_text("wait 80; " + args.commands + "; wait 10; quit\n", encoding="utf-8")
    folder = OUT / ("legacy" if args.legacy else "current")
    packages = [folder / "caelum_argenteum_dev.pk3", folder / ("city-checks.pk3" if args.city else "checks.pk3")]
    command = [str(ENGINE), "-noautoload", "-nomouse", "-iwad", str(IWAD), "-file",
        *map(str, packages), "-config", str(ini), "-savedir", str(OUT), "-window", "-width", "1280",
        "-height", "720", "-rngseed", "422", "+logfile", str(log)]
    if args.load:
        save = OUT / args.load
        if not save.is_file():
            raise SystemExit(f"Missing input save: {save}")
        command += ["-loadgame", save.name]
    else:
        command += ["+map", args.map]
    command += ["+exec", str(cfg)]
    startup = subprocess.STARTUPINFO()
    startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startup.wShowWindow = 0
    started = time.time()
    process = subprocess.Popen(command, cwd=OUT, startupinfo=startup)
    evidence = {"command": command, "pid": process.pid,
                "packages": {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in packages}}
    failed = False
    while process.poll() is None:
        text = log.read_text(encoding="utf-8", errors="replace") if log.exists() else ""
        if any(token in text for token in ("Script error", "VM execution aborted", "Execution could not continue",
                "errors while parsing", "DIED WITH FATAL ERROR", "Unknown command")) or time.time() - started > 90:
            process.terminate(); failed = True
            break
        time.sleep(0.5)
    process.wait(timeout=10)
    evidence.update(exit_code=process.returncode, elapsed_seconds=round(time.time() - started, 3))
    text = log.read_text(encoding="utf-8", errors="replace") if log.exists() else ""
    failures = [line for line in text.splitlines() if "CA422 FAIL" in line]
    evidence.update(failures=failures, pass_count=text.count("CA422 PASS"))
    (OUT / f"{args.label}.json").write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    for line in text.splitlines():
        if "CA422" in line or any(s in line for s in ("error", "Error", "Execution could not", "Unknown", "Trying to", "Cannot ")):
            print(line)
    if failed or failures or "CA422 RESULT" not in text or "Unknown command" in text or process.returncode:
        print(text[-3500:])
        raise SystemExit("Native scenario failed; diagnostics preserved.")
    print(f"Completed {args.label}: {evidence['pass_count']} PASS, {evidence['elapsed_seconds']} s")


if __name__ == "__main__":
    main()
