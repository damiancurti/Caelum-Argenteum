"""Export six closed raw-material clusters through the shared gem exporter."""
from pathlib import Path
try:
    from .generate_inventory_gems_models import main,output_files as shared_output
except ImportError:
    from generate_inventory_gems_models import main,output_files as shared_output
SOURCE=Path(__file__).resolve().parents[2]/'assets/source/art/inventory_models_647/ores'
GENERATORS=('generate_inventory_ores_models.py','generate_inventory_gems_models.py','generate_inventory_jewelry_models.py','generate_nahuelito_model.py','generate_pombero_model.py')
def output_files():return shared_output(SOURCE,'ores',684,GENERATORS)
if __name__=='__main__':main(SOURCE,'ores',684,GENERATORS)
