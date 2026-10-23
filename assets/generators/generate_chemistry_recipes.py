"""Generate the authored chemistry catalogue; no inferred recipe or economy values."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
DATA = json.loads((HERE / "chemistry_recipes.json").read_text(encoding="utf-8"))


def quoted(value):
    return json.dumps(value, ensure_ascii=False)


def switch_function(name, kind, rows, fallback):
    result = [f"    static clearscope {kind} {name}(int id)", "    {", "        switch(id)", "        {"]
    for item_id, value in rows:
        result.append(f"            case {item_id}: return {value};")
    result.extend([f"            default: return {fallback};", "        }", "    }"])
    return result


def main():
    materials, recipes = DATA["materials"], DATA["recipes"]
    assert [r["id"] for r in recipes] == list(range(DATA["first_recipe"], DATA["first_recipe"] + len(recipes)))
    assert [m["id"] for m in materials] == list(range(DATA["first_material"], DATA["first_material"] + len(materials)))
    lines = ["// Generado desde chemistry_recipes.json; los valores requieren aprobación del autor.",
             "class CaelumChemistryData : Object", "{",
             f"    const REVISION={DATA['schema_revision']};",
             f"    const FIRST_MATERIAL={DATA['first_material']};",
             f"    const MATERIAL_COUNT={len(materials)};",
             f"    const FIRST_RECIPE={DATA['first_recipe']};",
             f"    const RECIPE_COUNT={len(recipes)};",
             "    static clearscope bool IsRecipe(int id)",
             "    {return id>=FIRST_RECIPE && id<FIRST_RECIPE+RECIPE_COUNT;}",
             "    static clearscope bool IsMaterial(int id)",
             "    {return id>=FIRST_MATERIAL && id<FIRST_MATERIAL+MATERIAL_COUNT;}"]
    lines += switch_function("MaterialKey", "String", [(m["id"], quoted("CA_MATERIAL_" + m["key"].upper())) for m in materials], '""')
    lines += switch_function("MaterialIcon", "String", [(m["id"], quoted("graphics/caelum/icons/materials/ca_material_" + m.get("icon_key", m["key"]) + ".png")) for m in materials], '""')
    lines += switch_function("UnitWeight", "double", [(m["id"], m.get("unit_weight_kg", 0.001)) for m in materials], "CaelumConstants.MATERIAL_UNIT_WEIGHT")
    lines += switch_function("RecipeKey", "String", [(r["id"], quoted("CA_CHEMISTRY_" + r["key"].upper())) for r in recipes], '""')
    lines += switch_function("Price", "double", [(m["id"], m["base_value"]) for m in materials if "base_value" in m], -1)
    lines += switch_function("ImportStock", "int", [(m["id"], m["import_stock"]) for m in materials if "import_stock" in m], 0)
    lines += switch_function("IsFermentation", "bool", [(r["id"], str(r["mode"] == "fermentation").lower()) for r in recipes], "false")
    lines += switch_function("UsesDexterity", "bool", [(r["id"], str(r["mode"] == "preparation").lower()) for r in recipes], "false")
    lines += switch_function("RecipeForMaterial", "int", [(r["output_material"], r["id"]) for r in recipes if "output_material" in r], -1)
    for method, key, kind, default in (
        ("OutputMaterial", "output_material", "int", -1),
        ("OutputConsumable", "output_consumable", "int", -1),
        ("OutputUnits", "output_units", "int", 0),
        ("WaterLiters", "water_liters", "double", 0),
        ("WorkingLiters", "working_liters", "double", 0),
        ("Seconds", "world_seconds", "double", 0),
    ):
        lines += switch_function(method, kind, [(r["id"], r.get(key, default)) for r in recipes], default)
    for method, column in (("InputMaterial", 0), ("InputUnits", 1)):
        lines.extend([f"    static clearscope int {method}(int id,int slot)", "    {"])
        for recipe in recipes:
            for slot, pair in enumerate(recipe["inputs"]):
                lines.append(f"        if(id=={recipe['id']} && slot=={slot})return {pair[column]};")
        lines.extend([f"        return {-1 if column == 0 else 0};", "    }"])
    lines.append("}")
    (ROOT / "src/caelum/data/CaelumChemistryData.zs").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    language = ROOT / "src/LANGUAGE"
    start, end = "// BEGIN GENERATED CHEMISTRY\n", "// END GENERATED CHEMISTRY\n"
    block = start
    for locale, field in (("enu default", "en"), ("es", "es")):
        block += f"[{locale}]\n"
        for prefix, rows in (("CA_MATERIAL_", materials), ("CA_CHEMISTRY_", recipes)):
            for row in rows:
                block += f"{prefix}{row['key'].upper()} = {quoted(row[field])};\n"
        for key, row in DATA.get("ui", {}).items():
            block += f"{key} = {quoted(row[field])};\n"
        block += "\n"
    block += end
    original = language.read_text(encoding="utf-8")
    if start in original:
        before, remainder = original.split(start, 1)
        _, after = remainder.split(end, 1)
        original = before + block + after
    else:
        original += "\n" + block
    language.write_text(original, encoding="utf-8", newline="\n")
    models, textures = [], []
    for material in materials:
        key, number = material.get("icon_key", material["key"]), material["id"]
        model = material.get("model_key", material["key"])
        if model:
            models.append(f'Model CaelumMaterialPickup {{ Path "models/caelum/world/alchemy_ingredients" Model 0 "{model}.obj" Scale 4 4 4 CorrectPixelStretch DontCullBackFaces FrameIndex M{number:03d} A 0 0 }}')
        textures.append(f'Sprite "M{number:03d}A0", 128, 128 {{ Offset 64, 128 Patch "graphics/caelum/icons/materials/ca_material_{key}.png", 0, 0 }}')
    for suffix, rows in (("modeldef", models), ("textures", textures)):
        (ROOT / f"src/caelum/data/chemistry_resources.{suffix}").write_text("\n".join(rows) + "\n", encoding="utf-8", newline="\n")
    print(f"Generated {len(materials)} material identities and {len(recipes)} approved recipe(s)")


if __name__ == "__main__":
    main()
