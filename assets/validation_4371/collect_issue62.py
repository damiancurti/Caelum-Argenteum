"""Collect issue #62 evidence; reject failed/incomplete runs and package drift."""
from pathlib import Path
import hashlib, json, re, shutil, subprocess, sys, zipfile

root=Path(__file__).resolve().parents[2 if Path(__file__).parent.name=='validation_4371' else 1]
out=root/'assets/validation_4371'
out.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
cases={
 'pk3_staff':('MATRIX_DONE weapon=1',40),
 'pk3_book':('MATRIX_DONE weapon=18',40),
 'pk3_bell':('MATRIX_DONE weapon=17',40),
 'pk3_statuette':('MATRIX_DONE weapon=19',40),
 'final_flow':('owned weapon survives',18),
 'legacy_active':('primary=1 secondary=0',2),
 'legacy_complete':('STATE completed stage=45',9),
 'legacy_active_stable':('STATE completed stage=45',12),
 'legacy_complete_upgrade':('completed-reload',3),
 'stable_active_reload':('active-reload',5),
 'stable_complete_reload':('completed-reload',3),
 'rollback_active_final':('active-reload',5),
 'rollback_complete_final':('completed-reload',3),
 'final_delayed_rulo':('Caella and Rulo share one dummy',6),
 'final_active_reload':('checkpoint stage=40 primary=1 secondary=0',3),
 'final_complete_reload':('completed-reload',4),
 'journal':('QA62_VISUAL_DONE',2),
 'clean':('QA62_CLEAN_DONE',0),
}
records=[]
for label,(marker,minimum) in cases.items():
    p=root/f'build/issue62_{label}.log'; text=p.read_text(encoding='utf-8',errors='replace')
    assert not re.search(r'QA62 FAIL|Script error|VM execution aborted|Execution could not continue',text),label
    assert marker in text,(label,marker)
    passed=text.count('QA62 PASS');assert passed>=minimum,(label,passed,minimum)
    evidence='\n'.join(line for line in text.splitlines() if line.startswith(('GZDoom version','adding build/caelum','adding build/issue62','adding src','MAP01','QA62','Partida guardada','Captured','Screenshot')))+'\n'
    (out/f'{label}.txt').write_text(evidence,encoding='utf-8')
    commands=(root/f'build/issue62_{label}.cfg').read_text(encoding='utf-8')
    records.append({'label':label,'pass_assertions':passed,'completion_marker':marker,'commands':commands,'log_sha256':sha(p.read_bytes()),'evidence':f'{label}.txt'})

baseline=root/'build/issue62_baseline_4370.pk3'
package=root/'build/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as z,zipfile.ZipFile(baseline) as old:
    files={p.relative_to(root/'src').as_posix():p for p in (root/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(files),'package inventory differs from src'
    for name,p in files.items():assert z.read(name)==p.read_bytes(),name
    changed=[name for name in z.namelist() if z.read(name)!=old.read(name)]
    newline_only=[name for name in changed if z.read(name).replace(b'\r\n',b'\n')==old.read(name).replace(b'\r\n',b'\n')]
    semantic_changes=[name for name in changed if name not in newline_only]
    expected={'LANGUAGE','caelum/hud/CaelumJournalOverlay.zs','caelum/player/CaelumPlayer.zs','caelum/quests/CaelumMainM00MagicTrial.zs','caelum/quests/CaelumMainM00RuloTrial.zs','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'}
    assert set(semantic_changes)==expected,semantic_changes
    assert 'maps/MAP01.wad' not in changed,changed
    for name in ['caelum/equipment/CaelumPersistentCharacterState.zs','caelum/actors/CaelumActorProjectile.zs','caelum/core/CaelumConstants.zs']:
        assert z.read(name)==old.read(name),name
    runtime={name:sha(z.read(name)) for name in changed}

check=subprocess.run([sys.executable,'validate_project.py'],cwd=root,capture_output=True,text=True,encoding='utf-8')
assert check.returncode==0,check.stdout+check.stderr
(out/'STATIC.json').write_text(check.stdout,encoding='utf-8')
shutil.copytree(root/'build/issue62_qa',out/'fixture',dirs_exist_ok=True)
shutil.copyfile(root/'build/run_issue62.ps1',out/'run_issue62.ps1')
for name in ['complete','journal_es','journal_en']:
    shutil.copyfile(root/f'build/issue62_{name}.png',out/f'{name}.png')

report={
 'issue':62,'version':'4.37.1','date':'2026-10-01',
 'base_commit':'13ba3ccdf76c533a62faca88ff809033ee0f4791',
 'engine':'GZDoom 4.14.2 / Windows 11 / Vulkan / RTX 3070 Ti',
 'author_acceptance':'PENDING: CA-4371-CAELLA-01 in pending_test.txt; prior #61 acceptance does not apply',
 'package':{'path':'build/caelum_argenteum_dev.pk3','sha256':sha(package.read_bytes()),'entries':len(files),'all_entries_match_src':True},
 'baseline':{'version':'4.37.0','sha256':sha(baseline.read_bytes()),'map_and_persistent_state_unchanged':True},
 'runtime_file_hashes':runtime,'semantic_runtime_changes':semantic_changes,'checkout_newline_only_changes':newline_only,'native_cases':records,
 'methodology':[
  'Fresh MAP01 fixtures seed the completed-Argento prerequisite; Begin, casts, impacts, resource ticks, runes, completion and loan returns use production methods. This is not an ordinary full campaign.',
  'Positive attack coverage uses native pending casts and moving projectiles, never directly awards hit flags. Matrix asserts actual pending weapon/essence/mode, no credit on release, and only the corresponding flag after impact.',
  'The fixture temporarily sets MagicalAccuracyPercent=10000 and aims at the torso to control native random dispersion. Production accuracy/costs/cooldowns are unchanged. Initial uncontrolled probes missed normally; those probes are not counted as passing matrix evidence.',
  'The legacy active fixture earned its primary flag by a genuine old-version missed cast. The legacy completed fixture seeds its five practice flags, then uses production rune and completion methods; both are isolated test saves, not private author saves.',
  'Save commands wait for deferred native writes before subsequent attacks; loaded checks wait 140 tics for player initialization. Initial probes with short waits or a cast in the save tic were superseded by stable_* cases.',
  'Delayed-hit fixture slows the actual released secondary projectile, equips an owned sword, then verifies secondary credit from stored projectile metadata. Rulo fixture stages his prerequisite and creates native family selectors before allowing equipment selection to settle and attacking. An earlier combined probe omitted those selectors and was corrected in the fixture, not in production.',
  'Earlier passing native cases have identical gameplay code to the final PK3. Subsequent changes only update required diagnostic release labels and the bilingual Journal location heading. The final PK3 separately passes the 40-case matrix, clean startup, delayed/Rulo, reload and visual checks.',
  'No IWAD, executable, PK3, private save or test overlay is packaged with the runtime. Captures/logs are isolated engine evidence, not author acceptance.'
 ],
 'reproduction':[
  'From the repository root, build_dev.ps1 produces the current runtime. Supply a local licensed Doom II IWAD, GZDoom 4.14.2 and build/gzdoom.ini; edit local paths in run_issue62.ps1 if needed.',
  'Run assets/validation_4371/run_issue62.ps1 -Label <label> -Package -Fixture assets/validation_4371/fixture -Commands <recorded commands> -Wait. Save/load cases additionally need -LoadSave build/issue62_saves/<name>.zds.',
  'Create legacy62_active and legacy62_complete with the 4.37.0 package built from base_commit in a separate checkout. Select it with -Runtime <path>; keep the basename caelum_argenteum_dev.pk3. Then run legacy_active_stable/legacy_complete_upgrade and subsequent reload/rollback cases.',
  'Legacy cases use the old package; pk3_* and final_* use the current PK3. The clean case adds -Clean. Logs/captures/saves remain under build; only retained evidence and fixture sources are tracked.'
 ]
}
(out/'RESULTS.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps({'cases':len(records),'pass_assertions':sum(r['pass_assertions'] for r in records),'package_entries':len(files),'changed_runtime_files':changed},indent=2))
