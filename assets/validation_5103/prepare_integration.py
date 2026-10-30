"""Retain old fixtures and adapt the pre-memory visual assertion explicitly."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build/issue428/integration'
OUT.mkdir(parents=True, exist_ok=True)
source = ROOT / 'build/issue425/current/checks.pk3'
with zipfile.ZipFile(source) as archive:
    members = {name: archive.read(name) for name in archive.namelist()}
text = members['checks.zs'].decode('utf-8')
old = '''                Subject.SetOrigin((256,0,0),false);
                Check(!CaelumVisualPerception.Identify(Observer,Subject) && Observer.VisualEvidence.Suspicion==100,"full alert does not identify a newly visible body");'''
new = '''                Subject.SetOrigin((256,0,0),false);
                Check(CaelumVisualPerception.Identify(Observer,Subject),"remembered body reacquired within thirty seconds");
                Subject.SetOrigin((-256,0,0),false);
                Subject=CA425Probe(Actor.Spawn("CA425Probe",(256,0,0)));
                Subject.CombatAgility=0;Subject.bFriendly=false;
                Check(!CaelumVisualPerception.Identify(Observer,Subject) && Observer.VisualEvidence.Suspicion==100,"full alert does not identify a newly visible body");'''
text = text.replace('\r\n', '\n')
if text.count(old) != 1:
    raise SystemExit('The historical visual fixture changed; review the adaptation.')
members['checks.zs'] = text.replace(old, new).encode('utf-8')
with zipfile.ZipFile(OUT / 'checks425.pk3', 'w', zipfile.ZIP_STORED) as archive:
    for name, data in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
print('Prepared #425 integration fixture without altering historical evidence.')
