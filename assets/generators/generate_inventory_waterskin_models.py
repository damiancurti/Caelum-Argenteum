"""Export the approved ration waterskin and cup as an original owned 3D prop."""
from pathlib import Path
try:
    from .generate_inventory_ammunition_models import ROOT,main
except ImportError:
    from generate_inventory_ammunition_models import ROOT,main
if __name__=='__main__':
    main(ROOT/'assets/source/art/inventory_models_647/waterskin',
         'inventory_waterskin.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name)
