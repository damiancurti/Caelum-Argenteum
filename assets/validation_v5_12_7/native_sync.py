"""Instrument the engine's native sync flag without changing it or game state."""
from pathlib import Path

SOURCE=Path(__file__).with_name('native_sync_probe.zs')

def instrument(members):
    members=dict(members)
    members['ZSCRIPT']=members.get('ZSCRIPT',b'version "4.14.2"\n')+b'\n#include "native_sync.zs"\n'
    members['MAPINFO']=members.get('MAPINFO',b'')+b'\ngameinfo { AddEventHandlers="CA435NativeSyncProbe" }\n'
    members['native_sync.zs']=SOURCE.read_bytes()
    return members

def clean(log):
    return 'CA435SYNC OK' in log and 'CA435SYNC FAIL' not in log
