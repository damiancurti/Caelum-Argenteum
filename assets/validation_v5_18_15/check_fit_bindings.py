"""Compare each automatically selected helmet against an explicit native model binding."""
import argparse
import json
from pathlib import Path
import re

from PIL import Image, ImageChops

from fitting_room import controls, fixture, run_engine


def changed(a, b):
    with Image.open(a) as first, Image.open(b) as second:
        width, height = first.size
        crop = (width*2//5, height//6, width*3//5, height*3//5)
        delta = ImageChops.difference(first.convert("RGB").crop(crop), second.convert("RGB").crop(crop))
        return sum(delta.convert("L").histogram()[12:])


def verify(game, out):
    out.mkdir(parents=True, exist_ok=True)
    overlay, sockets = fixture(out, game)
    helmets = [i for i, (slot, _, _) in enumerate(sockets) if slot == 2]
    # Hold the same piece through successive family changes. Force the human
    # shell as a negative control, then restore the exact reference before moving on.
    poses = [(form, item) for item in helmets for form in range(14)]
    config = controls(out, [])
    with config.open("a", encoding="utf8") as stream:
        stream.write("wait 140; exec check0.cfg\n")
    for index, (form, item) in enumerate(poses):
        commands = [f"netevent outfit_select {form} {item}", "wait 12", f"netevent outfit_select {form} {item}",
                    "wait 10", f"screenshot actual{index}.png"]
        for mode, label in ((1, "expected"), (2, "human")):
            commands += [f"netevent outfit_reference {mode}", "wait 12", f"netevent outfit_reference {mode}",
                         "wait 10", f"screenshot {label}{index}.png"]
        commands += ["netevent outfit_reference 1", "wait 10",
                     "quit" if index+1 == len(poses) else f"exec check{index+1}.cfg"]
        (out / f"check{index}.cfg").write_bytes(("; ".join(commands)+"\n").encode())
    log = run_engine(game, overlay, out, config, poses)
    scores = []
    controls_seen = {tuple(map(int, row)) for row in re.findall(r"REFERENCE form=(\d+) item=(\d+) mode=(\d+)", log)}
    for index, (form, item) in enumerate(poses):
        assert {(form, item, 1), (form, item, 2)} <= controls_seen, (form, item)
        positive = changed(out/f"actual{index}.png", out/f"expected{index}.png")
        negative = changed(out/f"expected{index}.png", out/f"human{index}.png")
        assert not positive and (form < 2 or negative > 0), (form, item, positive, negative)
        scores.append(negative)
    report = {"compared_player_helmets": len(poses), "different_from_human_control": sum(n>0 for n in scores),
              "minimum_nonhuman_control_changed_pixels": min(n for n in scores if n)}
    (out/"bindings.json").write_bytes((json.dumps(report, indent=2)+"\n").encode())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    verify(args.game.resolve(), args.output.resolve())
