"""Verify deterministic Chemistry data/art exports without changing accepted assets."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
GENERATORS = ROOT / "assets/generators"
spec = json.loads((GENERATORS / "chemistry_supplies_art.json").read_text(encoding="utf-8"))
paths = [ROOT / "src/LANGUAGE", ROOT / "src/caelum/data/CaelumChemistryData.zs",
         ROOT / "src/caelum/data/chemistry_resources.modeldef",
         ROOT / "src/caelum/data/chemistry_resources.textures",
         GENERATORS / "chemistry_supplies_art_manifest.json"]
for item in spec["assets"]:
    paths += [ROOT / f"src/models/caelum/world/alchemy_ingredients/{item['key']}.obj",
              ROOT / f"src/graphics/caelum/icons/materials/ca_material_{item['key']}.png"]
def hashes():
    return {str(path.relative_to(ROOT)).replace("\\", "/"): hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
before = hashes()
for run in range(2):
    for script in ("generate_chemistry_recipes.py", "generate_chemistry_supplies_art.py"):
        subprocess.run([sys.executable, str(GENERATORS / script)], check=True, cwd=ROOT)
    assert hashes() == before, f"Generator run {run + 1} changed an output"
(HERE / "determinism.json").write_text(json.dumps({"runs": 2, "outputs": before}, indent=2) + "\n", encoding="utf-8")
print(f"Two deterministic runs: {len(paths)} identical outputs")
