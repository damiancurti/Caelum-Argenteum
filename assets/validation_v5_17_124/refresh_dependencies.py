"""Refresh shared TEXTURES fingerprints only after proving an append-only include."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
BASE='0953a15e056d02ea65e24b62c7b3be4909b1451c'

def main():
    old=subprocess.check_output(['git','show',BASE+':src/TEXTURES'],cwd=ROOT)
    current=(ROOT/'src/TEXTURES').read_bytes()
    assert current.startswith(old), 'Existing TEXTURES bytes changed'
    assert current[len(old):].strip()==b'#include "caelum/data/rest_motion.textures"'
    old_hash=hashlib.sha256(old).hexdigest();new_hash=hashlib.sha256(current).hexdigest()
    root=ROOT/'assets/source/art/inventory_models_647'
    names=['ammunition','bladed_weapons','axes','polearms','articulated_weapons','ranged_weapons',
           'armor_helmets','armor_hands','armor_feet','armor_torso','ingots']
    updated=[]
    for path in [*(root/name/'EXPORT.json' for name in names),root/'effective_weapon_references/PROVENANCE.json']:
        blob=path.read_bytes();data=json.loads(blob)
        field='external_source_sha256' if path.name=='EXPORT.json' else 'source_sha256'
        actual=data[field]['src/TEXTURES']
        assert actual in [old_hash,new_hash], str(path)+' has an unrelated source baseline'
        if actual==old_hash:
            assert blob.count(old_hash.encode())==1
            path.write_bytes(blob.replace(old_hash.encode(),new_hash.encode()))
        updated.append(path.relative_to(ROOT).as_posix())
    evidence={'issue':460,'base':BASE,'source':'src/TEXTURES','previous_sha256':old_hash,
              'current_sha256':new_hash,'original_prefix_byte_identical':True,
              'only_append':'#include "caelum/data/rest_motion.textures"','refreshed_manifests':updated}
    Path(__file__).with_name('evidence').joinpath('dependency-proof.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print('Verified unchanged aliases; refreshed',len(updated),'dependency fingerprints')

if __name__=='__main__':main()
