"""Export books, a letter, a key, cloth and an ingot from original owned materials."""
from pathlib import Path
try:
    from .generate_inventory_ammunition_models import ROOT, main
except ImportError:
    from generate_inventory_ammunition_models import ROOT, main

if __name__=='__main__':
    main(ROOT/'assets/source/art/inventory_models_647/documents',
         'inventory_documents.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name)
