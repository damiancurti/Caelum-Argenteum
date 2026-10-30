"""Visible, independent author scenarios for #586 and the #430 speed review."""
from pathlib import Path
import argparse
import datetime
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "build/issue586"
ENGINE = Path("C:/Program Files (x86)/GZDoom/gzdoom.exe")
IWAD = Path("C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD")
RUNTIME = OUT / "current/caelum_argenteum_dev.pk3"
CASES = {
    "1": ("Mandinga y Zupay: inmunidad", "MAP03", OUT / "checks.pk3",
          "netevent ca586_seed; wait 3; netevent ca586_check; save ca586-manual; wait 5; load ca586-manual.zds; wait 10; netevent ca586_reload; toggleconsole",
          'bind F1 "netevent ca586_visit"\nbind F2 "netevent ca586_reload"\nbind F9 "save ca586-manual"\nbind F10 "load ca586-manual.zds; wait 10; netevent ca586_reload"',
          "Debe mostrar 20 PASS de las reglas y 6 PASS de guardado/carga.\nMandinga, Zupay y rata no pierden Vida por contaminacion; si por dano normal.\nCaella es el control susceptible. F1 muestra Vida/contaminacion; F2 repite el filtro.\nF9 guarda y F10 carga. La consola empieza abierta para ver los resultados."),
    "2": ("Leonor frente a Caella: carga y velocidad", "MAP01", ROOT / "build/issue430/pair.pk3",
          "netevent ca430_pair_seed; wait 3; turn180; netevent ca430_pair_start; wait 155; toggleconsole",
          'bind F1 toggleconsole',
          "Observa a ambas correr por el pasillo. Despues se abre la consola.\nEsperado: 7 PASS; Caella lleva unos 22 kg y Leonor 5 kg.\nCon sus recursos iniciales, Leonor corre aproximadamente un 27% mas rapido.\nF1 abre/cierra la consola. Se conserva el balance aprobado.")}


def launch(choice, qa=False):
    title, mapname, fixture, commands, bindings, helptext = CASES[choice]
    if subprocess.check_output(["powershell", "-NoProfile", "-Command",
        "Get-Process | Where-Object ProcessName -eq 'gzdoom' | Select-Object -ExpandProperty Id"], text=True).strip():
        print("Cierra primero el GZDoom abierto.")
        return
    if not RUNTIME.is_file() or not fixture.is_file() or not (OUT / "manual-view.pk3").is_file():
        raise SystemExit("Falta el paquete o escenario preparado; no se inicia una prueba incompleta.")
    folder = OUT / "author" / datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    folder.mkdir(parents=True)
    ini, cfg, log = [folder / name for name in ("test.ini", "test.cfg", "engine.log")]
    ini.write_text("[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=true\n"
        "vid_maxfps=60\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\n"
        "vid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\n"
        "vid_fullscreen=false\nuse_mouse=true\nlanguage=es\n", encoding="utf-8")
    text = 'bind e +use\nbind w +forward\nbind s +back\nbind a +moveleft\nbind d +moveright\nbind grave toggleconsole\n'
    text += bindings + "\nwait 80; " + commands
    if qa:
        text += "; wait 10; bind F1; bind F2; bind F9; bind F10; screenshot author-check.png; wait 10; quit"
    cfg.write_text(text + "\n", encoding="utf-8")
    print("\n" + title + "\n" + helptext + "\nCierra el juego para volver a este menu.\n", flush=True)
    startup = None
    if qa:
        startup = subprocess.STARTUPINFO()
        startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup.wShowWindow = 0
    process = subprocess.Popen([str(ENGINE), "-noautoload", "-iwad", str(IWAD), "-file",
        str(RUNTIME), str(fixture), str(OUT / "manual-view.pk3"), "-config", str(ini), "-savedir", str(folder), "-window",
        "-width", "1280", "-height", "720", "-rngseed", "586", "+logfile", str(log),
        "+map", mapname, "+exec", str(cfg)], cwd=folder, startupinfo=startup)
    (OUT / "author-current.txt").write_text(str(folder) + "\n" + str(process.pid) + "\n", encoding="utf-8")
    process.wait()
    if qa:
        result = log.read_text(encoding="utf-8", errors="replace")
        errors = [line for line in result.splitlines() if any(token in line for token in
            (" FAIL", "Script error", "Execution could not continue", "VM execution aborted", "Unknown command", "Cannot find savegame"))]
        count = 26 if choice == "1" else 7
        if errors or result.count(" PASS") != count:
            raise SystemExit("\n".join(errors) + f"\nExpected {count} PASS, got {result.count(' PASS')}")
        print(f"Verified author launcher: {count} PASS.")
    print("Registro:", log, flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--scenario", choices=CASES)
    parser.add_argument("--qa", action="store_true")
    parser.add_argument("--start", choices=CASES)
    args = parser.parse_args()
    if args.scenario:
        launch(args.scenario, args.qa)
        return
    if args.start:
        launch(args.start)
    while True:
        print("\nCAELUM ARGENTEUM 5.11.8 - PRUEBAS PENDIENTES")
        for key, case in CASES.items():
            print(key + " - " + case[0])
        print("0 - Salir")
        try:
            choice = input("Numero y Enter: ").strip()
        except (EOFError, KeyboardInterrupt):
            return
        if choice == "0":
            return
        if choice in CASES:
            launch(choice)


if __name__ == "__main__":
    main()
