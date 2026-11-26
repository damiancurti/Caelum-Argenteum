"""Validate hybrid serpent binding and independently inspect native anatomy."""
import json
try:
    from .generate_hybrid_serpent_models import ROOT,geometry
    from .validate_serpent_models import inspect as shared_inspect
    from .validate_beast_men_models import validate as shared_validate
except ImportError:
    from generate_hybrid_serpent_models import ROOT,geometry
    from validate_serpent_models import inspect as shared_inspect
    from validate_beast_men_models import validate as shared_validate
SOURCE='assets/source/art/hybrid_serpents_727'
MODEL='models/caelum/folklore/hybrid_serpents'
DEFINITION='caelum/data/hybrid_serpent_combat.modeldef'
def inspect(root=ROOT,kind='mboi_tui'):
    return shared_inspect(root,kind,SOURCE,MODEL)
def validate(root=ROOT):
    errors=shared_validate(root,SOURCE,MODEL,DEFINITION,geometry,frame_mapping_only=True)
    try:
        config=json.loads((root/SOURCE/'ANIMATION.json').read_text())
        expected=[('mboi_tui','CaelumBestiary048','CA-FOLK-048'),('mboi_yagua','CaelumBestiary052','CA-FOLK-052')]
        if [(k,v['actor'],v['catalogue_id']) for k,v in config['species'].items()]!=expected:errors.append('Unexpected hybrid serpent class binding')
        for kind,_,_ in expected:
            more,_=inspect(root,kind);errors.extend(kind+': '+e for e in more)
    except (OSError,KeyError,ValueError) as exc:errors.append(str(exc))
    return errors
if __name__=='__main__':
    errors=validate();stats={name:inspect(ROOT,name)[1] for name in ['mboi_tui','mboi_yagua']}
    print(json.dumps(dict(errors=errors,geometry=stats)));raise SystemExit(bool(errors))
