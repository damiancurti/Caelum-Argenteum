"""Check the installed #460 gesture manifest and generated native bindings."""
import hashlib
import json
from pathlib import Path
from assets.generators import generate_rest_motion_data as generated

ROOT=Path(__file__).resolve().parents[2]

def validate(root=ROOT):
    errors=[]
    try:
        source=root/'assets/source/art/rest_motion_460'
        manifest=json.loads((source/'MODELS.json').read_text(encoding='utf-8'))
        def check(path,expected):
            if hashlib.sha256(path.read_bytes()).hexdigest()!=expected:
                errors.append('Rest motion: stale '+str(path.relative_to(root)))
        check(source/'MEAL_POSES.json',manifest['config_sha256'])
        check(root/'assets/generators/export_rest_motion_models.py',manifest['generator_sha256'])
        for family in manifest['families']:
            check(root/family['source'],family['source_sha256'])
            for name,expected in family['sha256'].items():check(root/'src'/name,expected)
        outputs={generated.TARGET:generated.render(),**{p:s.encode('utf-8') for p,s in generated.extra_outputs().items()}}
        for path,expected in outputs.items():
            target=root/path.relative_to(generated.ROOT)
            if target.read_bytes()!=expected:errors.append('Rest motion: stale '+str(target.relative_to(root)))
    except (OSError,ValueError,KeyError) as exc:errors.append('Rest motion: '+str(exc))
    return errors

if __name__=='__main__':
    result=validate();print(json.dumps({'errors':result}));raise SystemExit(bool(result))
