"""Reproduce and verify issue #376's stateless crafting extraction.

This is a source-equivalence check, not native execution or author acceptance.
The accepted lexical declaration reader is reused; quoted literals are retained
in the independent inverse comparison.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "assets/validation_500"))
from audit_sources import declarations, mask

BASE = "92be078e7ee2902a98f2c29603717a35b51647a8"
PLAYER = "src/caelum/player/CaelumPlayer.zs"
SERVICE = "src/caelum/crafting/CaelumCraftingCoordinator.zs"
CLASS = "CaelumCraftingCoordinator"
RANGES = [(3384, 4382), (4633, 5437), (5978, 6023)]


def original(path):
    return subprocess.check_output(
        ["git", "show", f"{BASE}:{path}"], cwd=ROOT
    ).decode("utf-8-sig")


def pawn(source):
    return next(c for c in declarations(source) if c["name"] == "CaelumPlayer")


def body(source, method):
    return source[method["body_start"]:method["body_end"] + 1]


def selection(source, decl):
    return [
        m for m in decl["methods"]
        if any(a <= m["line"] and m["end_line"] <= b for a, b in RANGES)
        and "CaelumInventoryService." not in body(source, m)
    ]


def tokens(source):
    without_comments = re.sub(
        r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*[\s\S]*?\*/',
        lambda m: "" if m.group().startswith(("//", "/*")) else m.group(),
        source,
    )
    return re.findall(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|\w+|[^\s]', without_comments)


def extract():
    source = original(PLAYER)
    decl = pawn(source)
    members = {m["name"] for m in decl["methods"]}
    for field in decl["fields"]:
        for part in field["declaration"].split(","):
            members.add(re.sub(r"\[.*", "", part.split()[-1]))
    members.update("player health Pos A_Log FindInventory".split())
    constants = set(re.findall(r"\bconst\s+(\w+)\s*=", mask(source)))
    output = [
        "// #376: políticas de planificación y sesión; el estado vive en el jugador.\n",
        "// Las reservas y entregas usan exclusivamente CaelumInventoryService.\n",
        f"class {CLASS} : Object play\n{{\n",
    ]
    edits = []
    for method in selection(source, decl):
        signature = method["signature"]
        params = signature[signature.index("(") + 1:signature.rindex(")")]
        args = [p.split("=")[0].split()[-1] for p in params.split(",") if p.strip()]
        contents = body(source, method)
        clean = mask(contents)
        replacements = []
        for token in re.finditer(r"\b\w+\b", clean):
            word = token.group()
            if clean[:token.start()].rstrip().endswith("."):
                continue
            if word == "self":
                replacement = "user"
            elif word in constants:
                replacement = "CaelumPlayer." + word
            elif word in members and word not in args:
                replacement = "user." + word
            else:
                continue
            replacements.append((token.start(), token.end(), replacement))
        for a, b, value in reversed(replacements):
            contents = contents[:a] + value + contents[b:]
        new_signature = (
            signature[:signature.index("(") + 1] + "CaelumPlayer user"
            + (", " + params.strip() if params.strip() else "") + ")"
        )
        output.append("    static " + new_signature + "\n    " + contents + "\n\n")
        call = CLASS + "." + method["name"] + "(self"
        call += (", " + ", ".join(args) if args else "") + ");"
        if not signature.startswith("void "):
            call = "return " + call
        edits.append((method["body_start"], method["body_end"] + 1,
                      "{\n        " + call + "\n    }"))
    output.append("}\n")
    for a, b, value in sorted(edits, reverse=True):
        source = source[:a] + value + source[b:]
    (ROOT / PLAYER).write_text(source, encoding="utf-8", newline="\n")
    (ROOT / SERVICE).write_text("".join(output), encoding="utf-8", newline="\n")
    includes = original("src/ZSCRIPT")
    needle = '#include "caelum/player/CaelumPlayer.zs"'
    assert includes.count(needle) == 1
    includes = includes.replace(
        needle, '#include "caelum/crafting/CaelumCraftingCoordinator.zs"\n' + needle
    )
    (ROOT / "src/ZSCRIPT").write_text(includes, encoding="utf-8", newline="\n")


def verify():
    before = original(PLAYER)
    after = (ROOT / PLAYER).read_text(encoding="utf-8-sig")
    service = (ROOT / SERVICE).read_text(encoding="utf-8-sig")
    old, new = pawn(before), pawn(after)
    services = declarations(service)
    assert len(services) == 1 and services[0]["name"] == CLASS
    assert not services[0]["fields"], "Coordinator must have no stored state"
    assert [f["declaration"] for f in old["fields"]] == [
        f["declaration"] for f in new["fields"]
    ], "Pawn field declarations changed"
    assert [m["signature"] for m in old["methods"]] == [
        m["signature"] for m in new["methods"]
    ], "Pawn signatures changed"
    selected = {m["name"] for m in selection(before, old)}
    moved = {m["name"]: m for m in services[0]["methods"]}
    assert selected == moved.keys()
    manifest = []
    for a, b in zip(old["methods"], new["methods"]):
        if a["name"] not in selected:
            assert tokens(body(before, a)) == tokens(body(after, b)), a["name"]
            continue
        contents = tokens(body(service, moved[a["name"]]))
        inverse = []
        i = 0
        while i < len(contents):
            if contents[i] in ("user", "CaelumPlayer") and i + 1 < len(contents) and contents[i + 1] == ".":
                i += 2
                continue
            inverse.append("self" if contents[i] == "user" else contents[i])
            i += 1
        assert tokens(body(before, a)) == inverse, a["name"]
        signature = a["signature"]
        params = signature[signature.index("(") + 1:signature.rindex(")")]
        args = [p.split("=")[0].split()[-1] for p in params.split(",") if p.strip()]
        call = CLASS + "." + a["name"] + "(self" + (", " + ", ".join(args) if args else "") + ");"
        expected = "{ " + ("" if signature.startswith("void ") else "return ") + call + " }"
        assert tokens(body(after, b)) == tokens(expected), a["name"]
        manifest.append({"method": a["name"], "baseline_lines": [a["line"], a["end_line"]],
                         "body_sha256": hashlib.sha256(" ".join(inverse).encode()).hexdigest()})
    report = {
        "issue": 376, "baseline": BASE, "moved_methods": manifest,
        "preserved_fields": len(old["fields"]), "preserved_signatures": len(old["methods"]),
        "unchanged_other_method_bodies": len(old["methods"]) - len(selected),
        "quoted_literals_preserved": True, "stateless_service": True,
        "production_schema_delta": False,
    }
    (HERE / "EXTRACTION.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"PASS: {len(selected)} moved bodies, {len(old['fields'])} fields, "
          f"{len(old['methods'])} signatures; all other bodies unchanged")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true")
    options = parser.parse_args()
    if options.apply:
        extract()
    verify()
