"""Check source invariants and actual native save omission of transient fields."""
from pathlib import Path
import difflib,json,re,subprocess,zipfile
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
def old(name):return subprocess.check_output(['git','show','HEAD:'+name],cwd=root).decode('utf-8').replace('\r\n','\n')
name='src/caelum/character/CaelumAppearanceHands.zs';before=old(name);after=(root/name).read_text(encoding='utf-8')
marker='    static int Variant';assert before[before.index(marker):]==after[after.index(marker):]
assert 'GetPersistentCharacterState(' not in after
name='src/caelum/equipment/CaelumInventoryService.zs';before=old(name);after=(root/name).read_text(encoding='utf-8');assert after.replace('        CaelumAppearanceHands.Invalidate(user);\n','',1)==before
name='src/caelum/player/CaelumPlayer.zs';before=old(name);after=(root/name).read_text(encoding='utf-8')
added=[line[2:] for line in difflib.ndiff(before.splitlines(),after.splitlines()) if line.startswith('+ ')]
removed=[line for line in difflib.ndiff(before.splitlines(),after.splitlines()) if line.startswith('- ')]
assert not removed and len(added)==6 and all(s.strip().startswith(('transient ','// #861:')) for s in added)
fields=['AppearanceHandStateReady','AppearanceHandState','AppearanceHandLayerReady','AppearanceHandLayerIds','AppearanceHandLayers']
with zipfile.ZipFile(root/'build/issue861-final01/fresh/reach.zds') as archive:
 data=b'\n'.join(archive.read(n).lower() for n in archive.namelist() if n.endswith('.json'))
 assert b'appearancedeathgloves' in data
 assert all(name.lower().encode() not in data for name in fields)
report={'issue':861,'unchanged_variant_resolution_and_pivots':True,'inventory_change_only_adds_cache_invalidation':True,'new_player_fields_all_transient':fields,'native_save_omits_all_new_fields':True,'saved_existing_death_glove_flag_present':True,'native_save':'build/issue861-final01/fresh/reach.zds','cold_state_lookup_does_not_invoke_schema_migrations':True}
(root/'build/issue861-source-review.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))
