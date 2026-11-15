"""Export the owned Basilisco anatomy through the established avian pipeline."""
from pathlib import Path
import copy
try:
    from .generate_beast_men_models import ROOT, output_files as shared_output, main as shared_main
    from .generate_avian_models import geometry as avian_geometry
    from .generate_serpent_models import sweep
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_beast_men_models import ROOT, output_files as shared_output, main as shared_main
    from generate_avian_models import geometry as avian_geometry
    from generate_serpent_models import sweep
    from generate_nahuelito_model import Mesh
SOURCE=ROOT/'assets/source/art/basilisco_738'
MODEL_PATH='models/caelum/folklore/basilisco'
DEFINITION='caelum/data/basilisco_combat.modeldef'
def geometry(design):
    """Use the established closed sweep for repeated, unrolled tail UVs."""
    mesh=Mesh()
    for shape in design['shapes']:
        one=copy.deepcopy(design);one['shapes']=[shape]
        piece=sweep(design,shape)[0] if shape['kind']=='sweep' else avian_geometry(one)
        begin=len(mesh.vertices)
        for point,uv,part in zip(piece.vertices,piece.uv,piece.parts):mesh.vertex(point,uv,part)
        mesh.faces.extend((material,tuple(begin+i for i in tri)) for material,tri in piece.faces)
    return mesh

def output_files():
    names=['generate_serpent_models.py','generate_basilisco_model.py','generate_avian_models.py','generate_peuchen_model.py','generate_guardian_models.py','generate_duende_models.py','generate_inventory_clothing_models.py','generate_pombero_model.py','generate_nahuelito_model.py']
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,738,geometry,tuple(Path(__file__).with_name(n) for n in names))
if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
