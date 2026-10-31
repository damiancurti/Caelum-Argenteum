"""Explicitly distinct diagnostic worlds; never used by production registration."""
from caelum_campaigns import unpack, pack
import json


def independent_world(data: bytes, label: str) -> bytes:
    members, name, level = unpack(data)
    # The fixture reuses geometry/inventory, not the identity of an existing
    # character. Update the object once so all in-world title references agree.
    for member, raw in list(members.items()):
        if not member.endswith('.map.json'):
            continue
        current = level if member == name else json.loads(raw)
        for obj in current['objects']:
            if obj.get('classtype') == 'CaelumLawfulIdentity':
                state = obj['class:CaelumLawfulIdentity']
                key = next(k for k in state if k.casefold() == 'token')
                state[key] = 'diagnostic-' + label + '-' + state[key]
        if member != name:
            members[member] = json.dumps(current, separators=(',', ':')).encode()
    return pack(members, name, level)
