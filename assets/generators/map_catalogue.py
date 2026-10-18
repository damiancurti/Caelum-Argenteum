"""Shared authored map identifiers; location/connection IDs are independent."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def map_name(role, root=ROOT):
    data = json.loads((root/'assets/map_catalogue/MAPS.json').read_text(encoding='utf-8'))
    return data['maps'][role]['lump']
