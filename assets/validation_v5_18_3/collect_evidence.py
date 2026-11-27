"""Retain final delivery evidence without shipping packages, IWAD data or saves."""
from pathlib import Path
import hashlib,json,shutil

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent

def sha(path):
    with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

def read(path):return json.loads(path.read_text(encoding='utf8'))

def copy(source,target):
    target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)

def retain(source,target):
    for path in source.rglob('*'):
        if not path.is_file() or 'extracted' in path.relative_to(source).parts:continue
        if path.suffix.lower() in ['.json','.txt','.log','.cfg','.ini','.png','.zs']:
            copy(path,target/path.relative_to(source))

def main():
    evidence=HERE/'evidence';evidence.mkdir(exist_ok=True)
    static=read(ROOT/'build/issue469-final-static.json');assert static['passed']
    copy(ROOT/'build/issue469-final-static.json',evidence/'final-static.json')
    validation=read(ROOT/'build/issue469-validation.json')
    assert validation['version']=='5.18.3' and not validation['errors']
    copy(ROOT/'build/issue469-validation.json',evidence/'project-validation.json')
    extraction=read(ROOT/'build/issue469-extract03/SUMMARY.json');assert extraction['passed']
    retain(ROOT/'build/issue469-extract03',evidence/'extraction')
    launches={}
    for name in ['play02','multiplayer01']:
        source=ROOT/('build/issue469-live-'+name);result=read(source/'SUMMARY.json');assert result['passed']
        launches[name]=result;retain(source,evidence/'launchers'/name)
    native=ROOT/'build/author-889/issue469-terminal-native06'
    matrix=read(native/'MATRIX.json');assert matrix['passed'] and len(matrix['rows'])==10
    retain(native,evidence/'terminal-native')
    for name in ['issue469-catalog01','issue469-catalog02']:
        copy(ROOT/'build/author-889'/name/'RESULTS.json',evidence/'catalog'/(name+'.json'))
    config=ROOT/'build/issue469-terminal02/session-config.json';copy(config,evidence/'session-config.json')
    composition=ROOT/'build/issue469-compositions01'
    for part in ['components','ceilings','municipal','waterline']:
        copy(composition/part/'MANIFEST.json',evidence/'compositions'/part/'MANIFEST.json')
    release=ROOT/'build/CaelumArgenteum-5.18.3-prologue-review03'
    for name in ['DELIVERY.json','SHA256SUMS.txt','PLAYER_GUIDE.txt']:
        copy(release/name,evidence/'delivery'/name)
    copy(release.parent/(release.name+'.zip.sha256'),evidence/'delivery/archive.sha256')
    for label,source in [('extract01','build/issue469-extract01'),('live-play01','build/issue469-live-play01'),
                         ('motion01','build/author-889/issue469-motion01'),
                         ('native01','build/author-889/issue469-terminal-native01'),
                         ('native02','build/author-889/issue469-terminal-native02'),
                         ('native03','build/author-889/issue469-terminal-native03'),
                         ('native04','build/author-889/issue469-terminal-native04'),
                         ('native05','build/author-889/issue469-terminal-native05'),
                         ('menu-investigation','build/author-889/issue469-menu-investigation01')]:
        retain(ROOT/source,evidence/'attempts'/label)
    report=dict(issue=469,version='5.18.3',passed=True,archive_sha256=static['archive_sha256'],runtime_sha256=static['runtime_sha256'],
        zip_bytes=(release.parent/(release.name+'.zip')).stat().st_size,delivered_files=extraction['delivered_files'],
        runtime_members=extraction['runtime_members'],deterministic_repeat=True,pending_author_checks=115,
        prepared_native_actions=static['prepared_native_actions'],catalog_actions=static['catalog_actions'],
        terminal_native_cases=matrix['rows'],launchers=launches,author_acceptance=False,
        environment='Windows 11 build 26200; Ryzen 9 5950X; RTX 3070 Ti; GZDoom g4.14.2 / executable g4.14.2-m. Native checks unpaused in background at 5% audio.',
        attempts=[
            'extract01 exposed omitted transitive migrate_arena_save.py; support export and AST import guard corrected. review03/extract03 is final.',
            'live-play01 exposed early ca_controls_defaults alias invocation; launcher now expands the authoritative packaged preset before startup.',
            'catalog01 refused 26 stale runtime-bound environment manifests. Canonical builders regenerated them; all seven overlays are byte-identical to prior evidence. catalog02 passed those 26 paths.',
            'motion01 capture exposed the new independent RGB332 palette coloring old Doom fixture textures incorrectly. Local development observers now read the installed IWAD palette; neither palette bytes nor fixture packages enter the distribution or source commit.',
            'native01/native02 reload failed the save-menu assertion. native03 also incorrectly used the class name as menu name. Native04/investigation proved SaveGameMenu opens then is closed one tick later by the inherited automated static probe, whose Manual flag resets on load. The manual subclass now disables that menu-closing UiTick and recovers its existing camera after save restoration. The final observer requests the declared SaveGameMenu (class SaveMenu) with Menu.On; assertions and real save/reload remain required.',
            'native05 used ActorIterator.Create with a class instead of its TID argument. The once-per-restore typed camera lookup now uses the established ThinkerIterator API.',
            'The original sky helper was unavailable; unified Computer Use observed title screens and normal window close. Injected Escape did not establish menu navigation and is not counted as a pass.'
        ],
        qualifications=[
            'All 148 native action paths were prepared; the final common observer palette/menu corrections were then exercised by the focused native matrix. No claim that all historical scenes were replayed.',
            'The final runtime differs from #468 only in two printed version labels; unchanged mode, transfer, audio and matching-map migration/rollback evidence is reused explicitly.',
            'Fresh extraction was tested on the recorded machine. No clean second-machine, Internet or public-store certification.',
            'Native save/menu API checks and automated rest/meal assertions do not establish physical-key or artistic author acceptance.',
            'Later campaign authoring, siege rendering fluency and earlier visual decisions remain pending.',
            'The temporary keep-awake helper remains active under the author request until return; the visible terminal owns an additional releasable lease.'
        ])
    (evidence/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
    fingerprints={p.relative_to(evidence).as_posix():sha(p) for p in evidence.rglob('*') if p.is_file() and p.name!='SHA256.json'}
    (evidence/'SHA256.json').write_text(json.dumps(fingerprints,indent=2)+'\n')
    print(json.dumps(dict(passed=True,native_cases=len(matrix['rows']),evidence_files=len(fingerprints),pending=115)))

if __name__=='__main__':main()
