"""Export seven native material-ingot meshes using unchanged owned icon pixels."""
from pathlib import Path
from generate_inventory_ammunition_models import ROOT, main
if __name__=='__main__':
    main(ROOT/'assets/source/art/inventory_models_647/ingots',
         'inventory_ingots.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name)
