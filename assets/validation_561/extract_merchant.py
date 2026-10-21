"""Verify issue #377's adapters, state owners and bounded policy changes."""
from pathlib import Path
import json
import re
import subprocess
import sys
import importlib.util

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "assets/validation_500"))
from audit_sources import declarations, mask
spec = importlib.util.spec_from_file_location("crafting_audit", ROOT / "assets/validation_560/extract_crafting.py")
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)
tokens = audit.tokens

BASE = "2c90af69"
PLAYER = "src/caelum/player/CaelumPlayer.zs"
CITY = "src/caelum/equipment/CaelumCityTrade.zs"
SERVICE = "src/caelum/equipment/CaelumMerchantCoordinator.zs"
CLASS = "CaelumMerchantCoordinator"
PAWN_METHODS = {
    "GetPalomoMerchantQuantityForIndex", "GetPalomoMerchantConsumableType",
    "GetPalomoMerchantMaterialType", "HasPalomoMerchantReputationDiscount",
    "RefreshPalomoMerchantSnapshot", "IsActivePalomoMerchantSessionValid",
    "OpenPalomoMerchant", "ClosePalomoMerchant", "UpdatePalomoMerchantSession",
    "CyclePalomoMerchantSelection", "TogglePalomoMerchantMode",
    "CyclePalomoMerchantQuantity", "ExecutePalomoMerchantTransaction",
}
CITY_METHODS = {"Open", "Refresh", "Cycle", "Capacity", "Execute"}


def original(path):
    return subprocess.check_output(["git", "show", f"{BASE}:{path}"], cwd=ROOT).decode("utf-8-sig")


def fields(decl):
    names = set()
    for field in decl["fields"]:
        for part in field["declaration"].split(","):
            names.add(re.sub(r"\[.*", "", part.split()[-1]))
    return names


def qualify(body, names, receiver, constants=()):
    clean = mask(body)
    changes = []
    for token in re.finditer(r"\b\w+\b", clean):
        word = token.group()
        if clean[:token.start()].rstrip().endswith("."):
            continue
        if word == "self":
            value = receiver
        elif word in constants:
            value = "CaelumPlayer." + word
        elif word in names:
            value = receiver + "." + word
        else:
            continue
        changes.append((token.start(), token.end(), value))
    for a, b, value in reversed(changes):
        body = body[:a] + value + body[b:]
    return body


def render():
    files = {}
    output = [
        "// #377: coordinación de comercio; cada sesión conserva su propietario.\n",
        "// Inventario, dinero y transferencias se confirman en el servicio compartido.\n",
        f"class {CLASS} : Object play\n{{\n",
    ]
    manifest = []
    for path, class_name, selected, receiver in [
        (PLAYER, "CaelumPlayer", PAWN_METHODS, "user"),
        (CITY, "CaelumCityTradeSession", CITY_METHODS, "session"),
    ]:
        source = original(path)
        decl = next(c for c in declarations(source) if c["name"] == class_name)
        members = fields(decl) | {m["name"] for m in decl["methods"]}
        if path == PLAYER:
            members.update("health Distance3D A_StartSound".split())
        constants = set(re.findall(r"\bconst\s+(\w+)\s*=", mask(source))) if path == PLAYER else set()
        edits = []
        for method in decl["methods"]:
            if method["name"] not in selected:
                continue
            # The audit parser masks string defaults; retain the source declaration.
            prefix = source[:method["body_start"]]
            match = list(re.finditer(r"(?m)^[ \t]*(?:static\s+)?(?:void|bool|int|Class<Inventory>)\s+"
                                    + re.escape(method["name"]) + r"\s*\(", prefix))[-1]
            signature = prefix[match.start():].strip()
            params = signature[signature.index("(") + 1:signature.rindex(")")]
            args = [p.split("=")[0].split()[-1] for p in params.split(",") if p.strip()]
            contents = source[method["body_start"]:method["body_end"] + 1]
            if path == PLAYER:
                contents = qualify(contents, members - set(args), receiver, constants)
                new_signature = signature[:signature.index("(") + 1] + "CaelumPlayer user"
                new_signature += (", " + params if params.strip() else "") + ")"
                arguments = "self" + (", " + ", ".join(args) if args else "")
                target_name = method["name"]
            else:
                target_name = method["name"] + "CityTrade"
                # Pure static utilities remain on the retained session type.
                instance_members = fields(decl) | {"Refresh", "Cycle", "Capacity", "Execute"}
                contents = qualify(contents, instance_members - set(args), "session")
                for name in ["Boxed", "SetBoxed", "Sellable", "Stack"]:
                    contents = re.sub(r"(?<![.\w])" + name + r"\(", "CaelumCityTradeSession." + name + "(", contents)
                new_signature = signature.removeprefix("static ").replace(method["name"] + "(", target_name + "(", 1)
                if method["name"] != "Open":
                    new_signature = new_signature.replace("(", "(CaelumCityTradeSession session,", 1)
                    arguments = "self, " + ", ".join(args)
                else:
                    arguments = ", ".join(args)
            output.append("    static " + new_signature + "\n    " + contents + "\n\n")
            call = CLASS + "." + target_name + "(" + arguments + ");"
            if not signature.removeprefix("static ").startswith("void "):
                call = "return " + call
            edits.append((method["body_start"], method["body_end"] + 1, "{\n        " + call + "\n    }"))
            manifest.append({"source": path, "method": method["name"], "coordinator": target_name})
        for a, b, value in sorted(edits, reverse=True):
            source = source[:a] + value + source[b:]
        files[path] = source
    output.append("}\n")
    files[SERVICE] = "".join(output)
    includes = original("src/ZSCRIPT")
    needle = '#include "caelum/equipment/CaelumInventoryService.zs"'
    includes = includes.replace(needle, needle + '\n#include "caelum/equipment/CaelumMerchantCoordinator.zs"', 1)
    files["src/ZSCRIPT"] = includes
    return files, manifest


def main():
    expected, manifest = render()
    report = {"baseline": BASE, "methods": manifest, "owners": []}
    for path, name in [(PLAYER, "CaelumPlayer"), (CITY, "CaelumCityTradeSession"),
                       (CITY, "CaelumCityMerchant")]:
        before = next(c for c in declarations(original(path)) if c["name"] == name)
        after = next(c for c in declarations((ROOT / path).read_text(encoding="utf-8-sig")) if c["name"] == name)
        assert before["fields"] == after["fields"] or (
            [f["declaration"] for f in before["fields"]] == [f["declaration"] for f in after["fields"]])
        assert [m["signature"] for m in before["methods"]] == [m["signature"] for m in after["methods"]]
        report["owners"].append({"class": name, "fields": len(before["fields"]), "methods": len(before["methods"])})
    for path in [PLAYER, CITY, "src/ZSCRIPT"]:
        assert tokens(expected[path]) == tokens((ROOT / path).read_text(encoding="utf-8-sig")), path
    actual = (ROOT / SERVICE).read_text(encoding="utf-8-sig")
    old_methods = declarations(expected[SERVICE])[0]["methods"]
    new = declarations(actual)[0]
    assert not new["fields"], "Coordinator must remain stateless"
    methods = {m["name"]: m for m in new["methods"]}
    changed = {"OpenPalomoMerchant", "ExecutePalomoMerchantTransaction", "OpenCityTrade",
               "RefreshCityTrade", "CycleCityTrade", "CapacityCityTrade", "ExecuteCityTrade"}
    for old in old_methods:
        current = methods[old["name"]]
        assert old["signature"] == current["signature"], old["name"]
        if old["name"] not in changed:
            assert tokens(audit.body(expected[SERVICE], old)) == tokens(audit.body(actual, current)), old["name"]
    report["reviewed_policy_changes"] = sorted(changed)
    report["new_stateless_session_guard"] = "IsCurrentCityTrade"
    inventory_path = "src/caelum/equipment/CaelumInventoryService.zs"
    inventory = (ROOT / inventory_path).read_text(encoding="utf-8-sig")
    decl = declarations(inventory)[0]
    names = {"PrepareMerchantCurrencyObjects", "AttachMerchantCurrencyObjects",
             "CommitPalomoProductAndCurrency", "CommitCityMerchantTransfer"}
    for method in sorted((m for m in decl["methods"] if m["name"] in names), key=lambda m: m["body_start"], reverse=True):
        # Remove the new method declaration plus body, retaining unrelated comments.
        end = method["body_end"] + 1
        prefix = inventory[:method["body_start"]]
        start = list(re.finditer(r"(?m)^[ \t]*static\s+\w+\s+" + method["name"] + r"\s*\(", prefix))[-1].start()
        inventory = inventory[:start] + inventory[end:]
    assert tokens(inventory) == tokens(original(inventory_path)), "Existing inventory commits changed"
    report["existing_inventory_methods_unchanged"] = True
    report["production_schema_delta"] = False
    (Path(__file__).parent / "manifest.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("PASS: 18 compatible adapters, existing owner fields and inventory methods unchanged; 7 policy deltas require native tests.")


if __name__ == "__main__":
    main()
