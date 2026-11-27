"""Retain exact independent-startup evidence and superseded attempt explanations."""
from pathlib import Path
import hashlib,json,shutil,zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent


def sha(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()


def main():
    evidence=HERE/'evidence';evidence.mkdir(exist_ok=True)
    validation=json.loads((ROOT/'build/issue467-validation.json').read_text(encoding='utf8'))
    assert validation['version']=='5.18.1' and not validation['errors']
    final=ROOT/'build/issue467-final04';package=final/'caelum_argenteum.ipk3'
    manifest=json.loads((final/'MANIFEST.json').read_text(encoding='utf8'))
    assert manifest['sha256']==sha(package)==sha(ROOT/'build/issue467-repeat03/caelum_argenteum.ipk3')
    assert len(manifest['files'])==19055 and len(manifest['excluded_development_maps'])==5
    for name in ['run_release.ps1','migrate_standalone_save.py']:
        assert (final/name).read_bytes()==(ROOT/name).read_bytes()
    with zipfile.ZipFile(package) as z:
        assert z.testzip() is None
        assert set(z.namelist())=={r['path'] for r in manifest['files']}
        for row in manifest['files']:assert hashlib.sha256(z.read(row['path'])).hexdigest()==row['sha256'],row['path']
    # Pilot save evidence remains applicable: actor/map bytes are unchanged.
    with zipfile.ZipFile(ROOT/'build/issue467-dist05/caelum_argenteum.ipk3') as prior,zipfile.ZipFile(package) as current:
        changes=[name for name in prior.namelist() if prior.read(name)!=current.read(name)]
        assert sorted(changes)==['TEXTURES','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
        for name in changes:
            if name!='TEXTURES':assert prior.read(name).replace(b'5.18.0',b'5.18.1')==current.read(name)
        include=b'#include "caelum/data/standalone.textures"'
        assert [line for line in prior.read('TEXTURES').splitlines() if line!=include]==current.read('TEXTURES').splitlines()
        assert include in current.read('TEXTURES.caelum467')
        assert set(current.namelist())-set(prior.namelist())=={'TEXTURES.caelum467'}
    runs={}
    for label,folder in [('native','issue467-final-native04'),('migration','issue467-migration02'),
        ('legacy-fresh','issue467-legacy-native01'),('legacy-reload','issue467-legacy-reload01'),('launcher','issue467-launcher04')]:
        source=ROOT/'build'/folder;target=evidence/label;target.mkdir(exist_ok=True)
        report=json.loads((source/'SUMMARY.json').read_text());runs[label]=report
        for child in source.rglob('*'):
            if child.is_file() and child.suffix.lower() in ['.json','.txt','.log','.cfg','.ini','.png']:
                output=target/child.relative_to(source);output.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(child,output)
    assert runs['native']['passed_checks']==100 and not runs['native']['failures'] and runs['native']['exit']==0
    assert runs['native']['native_voice_targets_verified']==60 and not runs['native']['commercial_iwad_loaded']
    assert not runs['native']['registration_overlay']
    assert runs['native']['package_sha256']==manifest['sha256']
    for key in ['legacy-fresh','legacy-reload']:assert runs[key]['passed_checks']==97 and runs[key]['completed'] and not runs[key]['failures']
    for key in ['forward_native','rollback_native']:assert runs['migration'][key]['passed_checks']==10 and runs['migration'][key]['exit']==0
    assert runs['launcher']['launcher_exit']==0 and runs['launcher']['absolute_save_path_rejected']
    attempts={
        'issue467-native01':'Project IWADINFO Mapinfo tried to override a core lump. Fixed installed core selection plus ordinary project MAPINFO include.',
        'issue467-native02':'Fixture textures.zs collided with reserved TEXTURES short lump. Renamed texture_probe.zs.',
        'issue467-native03':'Two false resolved-name sound assertions; title menu also left world paused. Rejected active-world evidence.',
        'issue467-native04':'Unpaused world; two false sound queries. Native channel stores original alias ID, not resolved target.',
        'issue467-native05':'Successful earlier 82-check pilot; final native evidence adds armor/dimensions/live effects.',
        'issue467-native06':'Gallery fixture used CR_WHITE without Font qualification. Compile failure; fixed fixture, not runtime.',
        'issue467-native07':'97 checks passed. Gallery captured at title did not render; image rejected as resource evidence.',
        'issue467-migration01':'MAP02 loaded, but stored hub needed original CA464AudioPoint diagnostic class. Restored exact fixture declaration; never stripped saved objects. Also resolved saved ARM1A0 using own icons.',
        'issue467-launcher01':'PowerShell GUI invocation returned before GZDoom and LASTEXITCODE was empty. Added Out-Host pipeline to wait and report actual exit.',
        'issue467-final-native01':'100 checks passed; first gallery still overlapped the gameplay HUD. Moved diagnostic cells above HUD.',
        'issue467-final-native03':'Nested caelum/data/TEXTURES was not registered; known missing native menu textures stopped the probe. Root TEXTURES.caelum467 registration fixes this without changing the pinned shared TEXTURES source.',
        'issue467-root-registration01':'Diagnostic root registration overlay passed 100 checks; final evidence repeats without this overlay in the actual corrected package.'}
    for folder,reason in attempts.items():
        source=ROOT/'build'/folder;target=evidence/'attempts'/folder;target.mkdir(parents=True,exist_ok=True)
        for name in ['SUMMARY.json','stdout.txt','command.json','observation.json','ATTEMPT.json']:
            if (source/name).is_file():shutil.copyfile(source/name,target/name)
    shutil.copyfile(ROOT/'build/issue467-validation.json',evidence/'project-validation.json')
    shutil.copyfile(ROOT/'build/issue467-validation-attempt01.json',evidence/'project-validation-attempt01.json')
    shutil.copyfile(ROOT/'build/issue467-validation-attempt02.json',evidence/'project-validation-attempt02.json')
    inventory=json.loads((ROOT/'assets/distribution/INVENTORY.json').read_text(encoding='utf8'))
    assert inventory['runtime_files']==19060 and not inventory['errors']
    report={'issue':467,'version':'5.18.1','package_sha256':manifest['sha256'],'package_bytes':manifest['bytes'],
        'source_files':19060,'distribution_files':19055,'manifest_matches_package':True,'deterministic_repeat':True,
        'inventory_sha256':sha(ROOT/'assets/distribution/INVENTORY.json'),'manifest_sha256':sha(final/'MANIFEST.json'),
        'launcher_sha256':sha(final/'run_release.ps1'),'converter_sha256':sha(final/'migrate_standalone_save.py'),
        'pilot_reuse_changes':{'labels_and_include_registration':changes,'new_registration_lump':'TEXTURES.caelum467','actor_and_map_behavior_unchanged':True},'runs':runs,'attempts':attempts,
        'environment':'Windows 11 build 26200; GZDoom startup g4.14.2, executable version g4.14.2-m; Ryzen 9 5950X / RTX 3070 Ti; Vulkan; 1280x720; unpaused background, 5% master volume.',
        'author_acceptance':'Pending CA467-STARTUP-01 and all 112 earlier author checks.',
        'limits':['Clean disposable profiles on the recorded machine, not another provisioned machine.',
            'Legacy MAP02 evidence uses a fresh matching revision-5 checkpoint, not an arbitrary historical author save.',
            'Native rollback intentionally loads the prior development IWAD; independent forward/startup tests do not.',
            'Later campaign, full mode integration, Internet multiplayer and siege fluency are not established here.',
            'Art/voice/attribution remain subject to author review; source-specific rights and audio quality qualifications remain.']}
    (evidence/'SUMMARY.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf8',newline='\n')
    print(json.dumps({'issue':467,'native_checks':100,'voice_targets':60,'migration_checks':20,'legacy_checks':194,'deterministic_repeat':True,'author_acceptance':False}))


if __name__=='__main__':main()
