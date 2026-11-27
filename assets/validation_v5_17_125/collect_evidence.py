"""Retain audio evidence and prove tested runtime audio stayed unchanged."""
import hashlib,json,shutil,subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
DEST=Path(__file__).with_name('evidence')
BASE='5b84421650fe5043ae01faeddee0cb5941a75665'

def main():
    DEST.mkdir(exist_ok=True)
    changes=subprocess.check_output(['git','diff','--name-only',BASE,'--','src'],cwd=ROOT,text=True).splitlines()
    allowed={'src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs'}
    assert set(changes)<=allowed,changes
    for name in changes:
        previous=subprocess.check_output(['git','show',BASE+':'+name],cwd=ROOT)
        assert (ROOT/name).read_bytes()==previous.replace(b'5.17.124',b'5.17.125'),name
    assert not subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).strip()
    native=ROOT/'build/issue464-native03';summary=json.loads((native/'SUMMARY.json').read_text())
    for phase in summary['phases']:
        source=native/phase['name'];target=DEST/'native'/phase['name'];target.mkdir(parents=True,exist_ok=True)
        for name in ['native.log','stdout.txt','commands.cfg','command.json','session.ini']:
            shutil.copyfile(source/name,target/name)
    shutil.copyfile(native/'maps/dialogue.png',DEST/'dialogue.png')
    shutil.copyfile(ROOT/'build/issue464-audit02/decode.json',DEST/'decode.json')
    attempts=[]
    for name,reason in [('issue464-native01','Fixture referenced unavailable CompareNoCase; replaced with exact approved name comparison.'),
                        ('issue464-native02','Console event used InterfaceProcess instead of ConsoleProcess; missing assertions were rejected.')]:
        target=DEST/'attempts';target.mkdir(exist_ok=True)
        shutil.copyfile(ROOT/'build'/name/'title/stdout.txt',target/(name+'.txt'))
        attempts.append({'directory':name,'reason':reason})
    assets=json.loads((DEST/'audio-index.json').read_text(encoding='utf-8'))
    decoded=json.loads((DEST/'decode.json').read_text())
    assert {x['path']:x['sha256'] for x in assets['assets']}=={x['path']:x['sha256'] for x in decoded['files']}
    report={'issue':464,'version':'5.17.125','author_acceptance':'pending CA464-AUDIO-01',
            'native':summary,'baseline_commit':BASE,'runtime_changes':changes,
            'only_runtime_difference':'Two diagnostic release labels; all audio bytes, assignments and ownership code unchanged',
            'decode_count':len(decoded['files']),'container_differences':len(decoded['container_differences']),
            'reserve_count':assets['reserved_tracks'],'credit_locator_count':sum(bool(x['credit_records']) for x in assets['assets']),
            'failed_attempts':attempts,
            'limits':['Decoder and native metadata/channel evidence does not establish subjective mix/loop listening acceptance.',
                      'No new region/weather emitter; nine cues play only in the isolated probe.',
                      'Distribution permissions and final release validation remain #466-469.']}
    (DEST/'SUMMARY.json').write_bytes((json.dumps(report,indent=2)+'\n').encode())
    print('Audio evidence retained; source identity proof passed')

if __name__=='__main__':main()
