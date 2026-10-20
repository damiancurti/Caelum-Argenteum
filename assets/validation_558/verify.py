"""Verify #369 scope, frozen package and deterministic exported artifacts."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def members(path):
    with zipfile.ZipFile(path) as archive:
        return {name: archive.read(name) for name in archive.namelist() if not name.endswith('/')}


def verify():
    before = members(ROOT / 'build/issue315-contract01/production.pk3')
    after = members(ROOT / 'build/issue369-final01/production.pk3')
    assert after == members(ROOT / 'build/caelum_argenteum_dev.pk3')
    source = {p.relative_to(ROOT/'src').as_posix(): p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert after == source, 'Final package must contain exactly the current src bytes'
    changed = sorted(name for name in before if before[name] != after.get(name))
    added = sorted(set(after)-set(before))
    assert changed == sorted(['CVARINFO', 'MAPINFO', 'MODELDEF', 'TEXTURES', 'ZSCRIPT',
        'caelum/actors/CaelumBull.zs', 'caelum/quests/CaelumMainM00QuestController.zs',
        'caelum/world/CaelumPhysicalHazards.zs', 'caelum/world/CaelumSewerMaze.zs'])
    assert added == sorted(['caelum/actors/CaelumBullModel.zs', 'caelum/actors/CaelumBullModelFrames.zs',
        'graphics/caelum/bull_model.textures', 'graphics/caelum/bull_invisible.png',
        'licenses/BULL_3D_MODEL.txt', 'models/caelum/bull/bull.md3', 'models/caelum/bull/bull_skin.png'])
    assert not set(before)-set(after)
    for name in ['caelum/actors/CaelumBull.zs', 'caelum/quests/CaelumMainM00QuestController.zs']:
        old = before[name].decode('utf-8').replace('\r\n', '\n')
        new = after[name].decode('utf-8').replace('\r\n', '\n')
        if name.endswith('/CaelumBull.zs'):
            new, count = re.subn(r'    CaelumBullModelBody BullModel;.*?(?=\n    double GetBullRunningSpeed)', '', new, flags=re.S)
            assert count == 1
        new = new.replace('        EnsureBullModel();\n', '').replace('A_CaelumBullModelGore(', 'A_CaelumProfiledMeleeAttack(')
        assert new == old, f'Unexpected native gameplay change: {name}'
    art = ROOT/'assets/source/art/bull_3d'
    assert sha(art/'original.glb') == '21c6c3413a009d18512a6106ba52e5032c4423c33f8c67bccf3b01a71d9c0c97'
    export = ROOT/'build/issue369-export03'
    repeat = ROOT/'build/issue369-export04'
    hashes = {}
    for p in export.iterdir():
        if p.is_file():
            assert p.read_bytes() == (repeat/p.name).read_bytes(), p.name
            hashes[p.name] = sha(p)
    for filename, installed in {'bull.md3':'models/caelum/bull/bull.md3',
        'bull_skin.png':'models/caelum/bull/bull_skin.png', 'frames.zs':'caelum/actors/CaelumBullModelFrames.zs',
        'TEXTURES':'graphics/caelum/bull_model.textures', 'bull_invisible.png':'graphics/caelum/bull_invisible.png'}.items():
        assert after[installed] == (export/filename).read_bytes()
    assert (export/'MODELDEF').read_text(encoding='utf-8') in after['MODELDEF'].decode('utf-8')
    report = json.loads((export/'manifest.json').read_text(encoding='utf-8'))
    assert report['source_sha256'] == sha(art/'bull.blend')
    assert (report['surfaces'], report['vertices'], report['triangles'], report['frames']) == (1,4983,6000,136)
    return {'gameplay_preserved':True, 'current_source_matches_frozen_package':True,
        'changed_members':changed, 'added_members':added, 'export_repeat_sha256':hashes,
        'art_source_sha256':{p.name:sha(p) for p in art.iterdir() if p.is_file()},
        'runtime_sha256':sha(ROOT/'build/issue369-final01/production.pk3')}


if __name__ == '__main__':
    print(json.dumps(verify(), indent=2))
