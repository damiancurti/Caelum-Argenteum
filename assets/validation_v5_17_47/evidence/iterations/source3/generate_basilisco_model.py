"""Export the owned Basilisco anatomy through the established avian pipeline."""
from pathlib import Path
try:
    from .generate_beast_men_models import ROOT, output_files as shared_output, main as shared_main
    from .generate_avian_models import geometry
except ImportError:
    from generate_beast_men_models import ROOT, output_files as shared_output, main as shared_main
    from generate_avian_models import geometry
SOURCE=ROOT/'assets/source/art/basilisco_738'
MODEL_PATH='models/caelum/folklore/basilisco'
DEFINITION='caelum/data/basilisco_combat.modeldef'
def output_files():
    names=['generate_basilisco_model.py','generate_avian_models.py','generate_peuchen_model.py','generate_guardian_models.py','generate_duende_models.py','generate_inventory_clothing_models.py','generate_pombero_model.py','generate_nahuelito_model.py']
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,738,geometry,tuple(Path(__file__).with_name(n) for n in names))
if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
