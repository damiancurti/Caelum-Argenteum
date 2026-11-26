"""Check food geometry, source hashes and item/table bindings without art tools."""
from pathlib import Path
import json
try:
    from .validate_inventory_consumable_models import validate as validate_shared
except ImportError:
    from validate_inventory_consumable_models import validate as validate_shared

ROOT = Path(__file__).resolve().parents[2]


def validate(root=ROOT):
    return validate_shared(root, 'food', 'inventory_food.modeldef')


if __name__ == '__main__':
    errors = validate()
    print(json.dumps({'errors': errors}))
    raise SystemExit(bool(errors))
