"""Export five reference-led southern figures from owned closed anatomy data."""
from pathlib import Path
try:
    from .generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from .generate_head_apparition_models import geometry as base_geometry
    from .generate_duende_models import material_uv
except ImportError:
    from generate_beast_men_models import ROOT,output_files as shared_output,main as shared_main
    from generate_head_apparition_models import geometry as base_geometry
    from generate_duende_models import material_uv

SOURCE=ROOT/'assets/source/art/austral_figures_815'
MODEL_PATH='models/caelum/folklore/australfigures'
DEFINITION='caelum/data/austral_figure_combat.modeldef'


def geometry(design):
    mesh=base_geometry(design)
    # Project authored paint coherently across neighboring body volumes.
    for region in design.get('skin_projections',[]):
        duplicates={};left,right=region['y_bounds'];bottom,top=region['z_bounds']
        for index,(material,tri) in enumerate(mesh.faces):
            if material!=region['from'] or any(mesh.parts[i]!=region['part'] for i in tri):continue
            if sum(mesh.vertices[i][0] for i in tri)/3<region['minimum_x']:continue
            mapped=[]
            for i in tri:
                if i not in duplicates:
                    x,y,z=mesh.vertices[i]
                    u=max(0,min(1,(y-left)/(right-left)));v=max(0,min(1,(top-z)/(top-bottom)))
                    duplicates[i]=mesh.vertex((x,y,z),material_uv(design,region['material'],u,v),mesh.parts[i])
                mapped.append(duplicates[i])
            mesh.faces[index]=(region['material'],tuple(mapped))
    mesh.vertices=[tuple(v*s for v,s in zip(p,design['anatomy_scale'])) for p in mesh.vertices]
    return mesh


def output_files():
    names=['generate_austral_figure_models.py','generate_head_apparition_models.py',
           'generate_quadruped_models.py','generate_basilisco_model.py','generate_serpent_models.py',
           'generate_avian_models.py','generate_peuchen_model.py','generate_guardian_models.py',
           'generate_duende_models.py','generate_inventory_clothing_models.py',
           'generate_pombero_model.py','generate_nahuelito_model.py']
    return shared_output(SOURCE,MODEL_PATH,DEFINITION,815,geometry,
                         tuple(Path(__file__).with_name(n) for n in names))


if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
