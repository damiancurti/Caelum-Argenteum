"""Ground the neutral worn helmet meshes and register their existing three skins."""
import hashlib
import json

from character_mesh_frames import ROOT, Surface, encode, read_model

SRC = ROOT / "src"
GEAR = SRC / "models/caelum/players/gear"
ART = ROOT / "assets/source/art"
SOURCE = ART / "inventory_models_647/armor_helmets/DESIGN.json"
MODULES = ART / "worn_equipment_904"
OUTPUT = GEAR / "ground"


def main():
    artwork = json.loads(SOURCE.read_bytes())
    roster = json.loads((MODULES / "MODULES.json").read_bytes())
    by_key = {row["module"]: row for row in roster}
    OUTPUT.mkdir(exist_ok=True)
    blocks = []
    hashes = {}
    # The neutral human is 56 map units tall for 170 model units. The native
    # pickup already applies a scale of 0.25 to every registered model.
    render_scale = 56 / 170 / 0.25
    for design in artwork["variants"].values():
        key = f"a0_{design['item_type']}"
        source = (GEAR / (key + ".md3")).read_bytes()
        assert hashlib.sha256(source).hexdigest() == by_key[key]["sha256"]
        meshes = read_model(source)
        floor = min(surface.positions[0, :, 2].min() for surface in meshes)
        ground = []
        for mesh in meshes:
            points = mesh.positions[:1].copy()
            points[:, :, 2] -= floor
            ground.append(Surface(points, mesh.faces, mesh.uv, mesh.shader))
        target = OUTPUT / (key + ".md3")
        target.write_bytes(encode(key + " ground", ground))
        hashes[target.relative_to(ROOT).as_posix()] = hashlib.sha256(target.read_bytes()).hexdigest()
        for tier, frame in enumerate("BCD", 1):
            skin = key if tier == 1 else f"{key}_t{tier}"
            blocks.append(f'Model CaelumArmorPickup {{ Path "models/caelum/players/gear" '
                          f'Model 0 "ground/{key}.md3" Skin 0 "{skin}.png" '
                          f'Scale {render_scale:.8f} {render_scale:.8f} {render_scale:.8f} '
                          f'CorrectPixelStretch DontCullBackFaces FrameIndex {design["sprite"]} {frame} 0 0 }}')

    binding = SRC / "caelum/data/ground_helmet_tiers.modeldef"
    binding.write_bytes(("\n".join(blocks) + "\n").encode())
    hashes[binding.relative_to(ROOT).as_posix()] = hashlib.sha256(binding.read_bytes()).hexdigest()
    manifest = {
        "issue": 933,
        "source": "frame 0 of the four human worn helmets",
        "generator": "assets/generators/generate_helmet_drops.py",
        "sha256": hashes,
    }
    (MODULES / "GROUND_HELMETS.json").write_bytes((json.dumps(manifest, indent=2) + "\n").encode())


if __name__ == "__main__":
    main()
