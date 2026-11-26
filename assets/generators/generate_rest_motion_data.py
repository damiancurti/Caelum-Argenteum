"""Generate approved rest-animation timings without altering model frame identities."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/source/art/rest_motion_460/DESIGN.json"
TARGET = ROOT / "src/caelum/data/CaelumRestMotionData.zs"
FRAMES = ROOT / "src/caelum/character/CaelumDomingoPilotFrames.zs"
MARKER = "    // BEGIN ISSUE460 REST STATES"
MEALS = json.loads((SOURCE.parent / "MEAL_POSES.json").read_text(encoding="utf-8"))

def transitions():
    data = json.loads(SOURCE.read_text(encoding="utf-8"))
    legacy = json.loads((ROOT / "assets/source/art/domingo_3d_pilot/DESIGN.json").read_text(encoding="utf-8"))["export_actions"]
    starts = {}; cursor = 0
    for name, row in legacy.items():
        starts[name] = cursor
        cursor += len(row["frames"])
    result = []
    for key, name in [("SIT_DOWN", "SitDown"), ("STAND_UP", "StandUp"), ("LIE_DOWN", "LieDown"), ("GET_UP", "GetUp")]:
        source = legacy[name]["frames"]
        duration = data["durations_seconds"][key] * 35
        samples = [round(frame * duration / source[-1]) for frame in source]
        for i, tick in enumerate(samples):
            result.append({"phase": key, "tick": tick, "model_frame": starts[name] + i,
                           "duration": samples[i+1]-tick if i+1<len(samples) else -1})
    return result

def poses():
    result = transitions()
    count = MEALS["samples_per_pose"]
    duration = json.loads(SOURCE.read_text(encoding="utf-8"))["durations_seconds"]["EAT"] * 35
    assert duration % count == 0
    for index in range(count * len(MEALS["base_actions"])):
        result.append({"phase": "MEAL", "tick": index % count * duration // count,
                       "model_frame": index, "duration": duration // count})
    return result

def render_states():
    lines = [MARKER]
    for index, row in enumerate(poses()):
        sprite, letter = f"R4{index//26:02X}", chr(65+index%26)
        lines += [f"    RM{index}:", f"        {sprite} {letter} {row['duration']};",
                  "        Stop;" if row["duration"]<0 or index==len(poses())-1 else f"        Goto RM{index+1};"]
    return "\n".join(lines)+"\n    // END ISSUE460 REST STATES\n"

def merge_states(original):
    if MARKER in original:
        original = original[:original.index(MARKER)] + "    }\n}\n"
    pos = original.rfind("    }\n}")
    if pos < 0:
        raise ValueError("Expected original generated state block")
    return original[:pos]+render_states()+original[pos:]

def extra_outputs():
    rows = poses()
    output = {}
    definitions = []
    for filename in ["domingo_modules.modeldef", "wardrobe_candidate.modeldef"]:
        text = (ROOT / "src/caelum/data" / filename).read_text(encoding="utf-8")
        header = text[:text.index("FrameIndex")].rstrip()+"\n"
        slots = [int(n) for n in re.findall(r"^\s*Model (\d+) ", header, re.M)]
        for index, row in enumerate(transitions()):
            for slot in slots:
                header += f"    FrameIndex R4{index//26:02X} {chr(65+index%26)} {slot} {row['model_frame']}\n"
        definitions.append(header+"}\n")
        header = text[:text.index("FrameIndex")].rstrip()+"\n"
        header = re.sub(r'^\s*Path "[^"]+"\n', '\n', header, flags=re.M)
        def model(match):
            path = match[2]
            if '/' not in path:
                path = 'models/caelum/characters/domingo/' + path
            return f'    Model {match[1]} "{path.replace("characters/", "characters/rest_motion/eat/")}"'
        header = re.sub(r'^\s*Model (\d+) "([^"]+)"', model, header, flags=re.M)
        header = re.sub(r'(Skin \d+ ")domingo_skin.png', r'\1models/caelum/characters/domingo/domingo_skin.png', header)
        for index, row in enumerate(rows[len(transitions()):], len(transitions())):
            for slot in slots:
                header += f"    FrameIndex R4{index//26:02X} {chr(65+index%26)} {slot} {row['model_frame']}\n"
        definitions.append(header+"}\n")
    output[ROOT/"src/caelum/data/rest_motion.modeldef"] = "\n".join(definitions)
    output[ROOT/"src/caelum/data/rest_motion.textures"] = "\n".join(
        f'Sprite "R4{i//26:02X}{chr(65+i%26)}0", 1, 1 {{ Patch "graphics/caelum/domingo_invisible.png", 0, 0 }}'
        for i in range(len(rows)))+"\n"
    output[FRAMES] = merge_states(FRAMES.read_text(encoding="utf-8"))
    return output

def render():
    data = json.loads(SOURCE.read_text(encoding="utf-8"))
    durations = data["durations_seconds"]
    lines = ["// Generado desde rest_motion_460/DESIGN.json; tiempos aprobados del #460.",
             "class CaelumRestMotionData : Object", "{",
             f"    const REVISION={data['schema_revision']};", "    const NONE=0;"]
    lines += [f"    const {name}={index};" for index, name in enumerate(durations, 1)]
    lines += [f"    const TRANSITION_STATES={len(transitions())};",
              f"    const MEAL_SAMPLES={MEALS['samples_per_pose']};"]
    lines += ["    static clearscope int Duration(int motion)", "    {",
              "        switch(motion)", "        {"]
    lines += [f"        case {name}: return {seconds}*TICRATE;" for name, seconds in durations.items()]
    lines += ["        }", "        return 0;", "    }",
              "    static clearscope int StateIndex(int motion,int elapsed,bool sleeping=false)", "    {",
              "        if(motion==EAT || motion==DRINK)",
              "            return TRANSITION_STATES+(sleeping?MEAL_SAMPLES:0)+Clamp(elapsed*MEAL_SAMPLES/Duration(motion),0,MEAL_SAMPLES-1);"]
    for i, row in reversed(list(enumerate(transitions()))):
        lines += [f"        if(motion=={row['phase']} && elapsed>={row['tick']})return {i};"]
    lines += ["        return -1;", "    }",
              "    static clearscope int SampleTic(int index)", "    {", "        switch(index)", "        {"]
    lines += [f"        case {i}: return {row['tick']};" for i,row in enumerate(poses())]
    lines += ["        }", "        return 0;", "    }",
              "    static clearscope int NativeFrame(int index)", "    {", "        switch(index)", "        {"]
    lines += [f"        case {i}: return {row['model_frame']};" for i,row in enumerate(poses())]
    lines += ["        }", "        return 0;", "    }",
              "    static clearscope String ModelPath(String original,int motion)", "    {",
              "        if(motion!=EAT && motion!=DRINK)return original;",
              '        String path=original;path.Replace("characters/",motion==EAT?"characters/rest_motion/eat/":"characters/rest_motion/drink/");return path;',
              "    }", "    static clearscope String BaseFile(int slot)", "    {", "        switch(slot)", "        {"]
    groups=json.loads((ROOT/'assets/source/art/character_modules_458/MODULES.json').read_text(encoding='utf-8'))['groups']
    lines += [f'        case {i}: return "{name}.md3";' for i,name in enumerate(groups)]
    lines += ['        }', '        return "";', '    }', '}', '']
    return "\n".join(lines).encode("utf-8")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    outputs = {TARGET: render(), **{p:s.encode("utf-8") for p,s in extra_outputs().items()}}
    if args.check:
        stale = [str(p.relative_to(ROOT)) for p,b in outputs.items() if not p.exists() or p.read_bytes()!=b]
        if stale:
            raise SystemExit("Rest motion data is stale: "+", ".join(stale))
        print("Rest motion data is current")
    else:
        for path, expected in outputs.items():
            path.write_bytes(expected)
        print("Generated approved rest motion data")
