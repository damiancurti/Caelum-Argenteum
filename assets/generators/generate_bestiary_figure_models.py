"""Export four distinct reference figures through the owned anatomy/garment pipeline."""
from pathlib import Path
try:
    from .generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from .generate_head_apparition_models import geometry as base_geometry
except ImportError:
    from generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from generate_head_apparition_models import geometry as base_geometry

SOURCE=ROOT/'assets/source/art/bestiary_figures_821'
MODEL_PATH='models/caelum/folklore/bestiaryfigures'
DEFINITION='caelum/data/bestiary_figure_combat.modeldef'


def geometry(design):
    mesh=base_geometry(design)
    # Keep cropped facial projections inside their original atlas cell.
    for shape in design['shapes']:
        projection=shape.get('front_projection',{})
        if not projection.get('clamp_to_material_cell'):continue
        material=projection['material'];left,top,right,bottom=design['materials'][material]['uv_rect']
        indices={i for owner,tri in mesh.faces if owner==material for i in tri}
        for i in indices:
            u,v=mesh.uv[i];mesh.uv[i]=(max(left,min(right,u)),max(top,min(bottom,v)))
    mesh.vertices=[tuple(v*s for v,s in zip(point,design['anatomy_scale'])) for point in mesh.vertices]
    return mesh


def output_files():
    names=['generate_bestiary_figure_models.py','generate_head_apparition_models.py',
           'generate_quadruped_models.py','generate_basilisco_model.py','generate_serpent_models.py',
           'generate_avian_models.py','generate_peuchen_model.py','generate_guardian_models.py',
           'generate_duende_models.py','generate_inventory_clothing_models.py',
           'generate_pombero_model.py','generate_nahuelito_model.py']
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,821,geometry,
                         tuple(Path(__file__).with_name(n) for n in names))



if __name__=='__main__':
    shared_main(SOURCE,DEFINITION,output_files)
