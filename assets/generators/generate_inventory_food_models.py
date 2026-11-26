"""Export approved-reference food geometry using the shared closed-mesh pipeline."""
try:
    from .generate_inventory_consumable_models import ROOT, main
except ImportError:
    from generate_inventory_consumable_models import ROOT, main

if __name__ == '__main__':
    main(ROOT / 'assets/source/art/inventory_models_647/food', 'inventory_food.modeldef')
