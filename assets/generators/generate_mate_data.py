"""Export the author's #472 vessel table and derived hemisphere geometry."""
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(__file__).with_name("mate_vessels.json")
DATA = json.loads(SOURCE.read_text(encoding="utf-8"))

def main():
    rows = DATA["vessels"]
    methods = {name: [] for name in ("Capacity", "WaterCapacity", "YerbaGrams", "Radius", "Wall", "Conductivity", "CoatingWall", "CoatingConductivity", "BodyHeatCapacity", "EmptyMass", "NameKey", "ItemClass", "PrimaryMaterial", "PrimaryGrams", "SecondaryMaterial", "SecondaryGrams", "BronzeGrams")}
    for i, row in enumerate(rows):
        body, coat = row["body"], row["coating"]
        r = (3 * row["capacity_liters"] / 1000 / (2 * math.pi)) ** (1 / 3)
        outer = r + row["wall_meters"]
        mass = 2 * math.pi / 3 * (outer ** 3 - r ** 3) * DATA["density_kg_m3"][body]
        coat_mass = 0 if not coat else 2 * math.pi / 3 * ((outer + row["coating_meters"]) ** 3 - outer ** 3) * DATA["density_kg_m3"][coat]
        values = {"Capacity": row["capacity_liters"], "WaterCapacity": row["water_liters"],
                  "YerbaGrams": row["yerba_grams"], "Radius": r, "Wall": row["wall_meters"],
                  "Conductivity": DATA["conductivity_w_mk"][body], "CoatingWall": row["coating_meters"],
                  "CoatingConductivity": 1 if not coat else DATA["conductivity_w_mk"][coat],
                  "BodyHeatCapacity": mass * DATA["specific_heat_j_kgk"][body] + (coat_mass * DATA["specific_heat_j_kgk"][coat] if coat else 0),
                  "EmptyMass": mass + coat_mass + DATA["fixed_bronze_straw_kg"],
                  "NameKey": f'"CA_MATE_{row["key"].upper()}"', "ItemClass": f"'CaelumMate{row['key'].title()}'",
                  "PrimaryMaterial": DATA["dry_gourd_material"] if i == 0 else "CaelumConstants.MATERIAL_WOOD",
                  "PrimaryGrams": row["recipe_grams"].get("dry_gourd", row["recipe_grams"].get("wood")),
                  "SecondaryMaterial": "CaelumConstants.MATERIAL_BRONZE_INGOT" if i == 0 else f"CaelumConstants.MATERIAL_{coat.upper()}_INGOT",
                  "SecondaryGrams": row["recipe_grams"]["bronze" if i == 0 else coat],
                  "BronzeGrams": 0 if i == 0 else row["recipe_grams"]["bronze"]}
        for name, value in values.items():
            methods[name].append(value)
    lines = ["// Generado desde mate_vessels.json; geometría y tabla aprobadas (#472).", "class CaelumMateData : Object", "{"]
    constants = {"REVISION": DATA["schema_revision"], "FIRST_RECIPE": DATA["first_recipe"], "FIRST_CONSUMABLE": DATA["first_consumable"], "COUNT": len(rows), "DRY_GOURD": DATA["dry_gourd_material"], "HOT_MIN_C": DATA["hot_minimum_c"], "HOT_MAX_C": DATA["hot_maximum_c"], "HOT_USES": DATA["hot_uses_per_load"], "RESOURCE_RATIO": DATA["resource_to_nominal_hydration_ratio"], "DRY_GOURD_VALUE": DATA["acquisition"]["material_price_copper_per_gram"]["dry_gourd"], "DRY_GOURD_STOCK": DATA["acquisition"]["provisions_dry_gourd_grams"], "MATE_STOCK": DATA["acquisition"]["provisions_stock_per_mate"], "BOOK_STOCK": DATA["acquisition"]["library_copies_per_recipe"]}
    for key, value in constants.items():
        lines.append(f"    const {key}={value};")
    lines += ["    static clearscope bool IsRecipe(int recipe){return recipe>=FIRST_RECIPE && recipe<FIRST_RECIPE+COUNT;}", "    static clearscope bool IsConsumable(int kind){return kind>=FIRST_CONSUMABLE && kind<FIRST_CONSUMABLE+COUNT;}"]
    for name, values in methods.items():
        kind = "String" if name == "NameKey" else "Name" if name == "ItemClass" else "int" if name.endswith(("Material", "Grams")) else "double"
        lines += [f"    static clearscope {kind} {name}(int variant)", "    {", "        switch(variant)", "        {"]
        for i, value in enumerate(values):
            lines.append(f"            case {i}: return {value:.15g};" if isinstance(value, float) else f"            case {i}: return {value};")
        lines += [f"            default: return {values[0]:.15g};" if isinstance(values[0], float) else f"            default: return {values[0]};", "        }", "    }"]
    lines += ["}"]
    (ROOT / "src/caelum/data/CaelumMateData.zs").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    language = ROOT / "src/LANGUAGE"
    original = language.read_text(encoding="utf-8")
    marker = "// BEGIN GENERATED MATE DATA (#472)"
    end_marker = "// END GENERATED MATE DATA (#472)"
    strings = dict(DATA["ui"])
    for row in rows:
        strings[f"CA_MATE_{row['key'].upper()}"] = {"en": row["en"], "es": row["es"]}
    generated = [marker]
    for locale, code in (("en", "enu default"), ("es", "es")):
        generated.append(f"[{code}]")
        for key, value in strings.items():
            generated.append(f"{key} = {json.dumps(value[locale], ensure_ascii=False)};")
    generated.append(end_marker)
    block = "\n".join(generated) + "\n"
    if marker in original:
        before, after = original.split(marker, 1)
        after = after.split(end_marker, 1)[1].lstrip("\n") if end_marker in after else ""
        original = before + block + after
    else:
        original += "\n" + block
    language.write_text(original, encoding="utf-8", newline="\n")
    print("Generated three approved mate vessels and bilingual UI")

if __name__ == "__main__":
    main()
