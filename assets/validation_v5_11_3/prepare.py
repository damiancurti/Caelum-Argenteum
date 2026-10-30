"""Evaluate the approved five-tic empty-query candidate without adopting it."""
from pathlib import Path
import hashlib
import json
import zipfile
import argparse
p=argparse.ArgumentParser();p.add_argument("--source-root",type=Path);args=p.parse_args()
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue433'
OUT.mkdir(parents=True,exist_ok=True)
files={};hashes={}
def read(name):
    raw=((args.source_root or ROOT)/'src/caelum'/name).read_bytes();hashes[name]=hashlib.sha256(raw).hexdigest()
    return raw.decode('utf-8').replace('\r\n','\n')
def replace(text,old,new):
    assert text.count(old)==1,old
    return text.replace(old,new,1)
name='data/CaelumPerceptionData.zs';s=read(name)
files[name]=replace(s,'    const VISUAL_REVISION = 1;','    const VISUAL_REVISION = 1;\n    const EMPTY_SEARCH_TICS = 5;')
name='actors/CaelumVisualEvidence.zs';s=read(name)
s=replace(s,'    int LastVisualTic;','''    transient int EmptySearchUntil,EmptySearchSkipped;
    transient vector3 EmptySearchOrigin;
    transient double EmptySearchAngle;
    void WakeEmptySearch(){EmptySearchUntil=0;CandidateCacheReady=false;}
    int LastVisualTic;''')
s=replace(s,'    void Damaged(CaelumCombatActor observer,Actor source)\n    {','''    void Damaged(CaelumCombatActor observer,Actor source)
    {
        WakeEmptySearch();''')
files[name]=s
name='actors/CaelumVisualPerception.zs';s=read(name)
s=replace(s,'    static Actor Candidate(CaelumCombatActor observer)','''    static bool ReuseEmptySearch(CaelumCombatActor observer,CaelumVisualEvidence evidence)
    {
        // Solo se omite la consulta vacia; memoria y sospecha siguen vivas.
        if(level.time>=evidence.EmptySearchUntil || observer.target!=null
            || observer.PendingTheftTarget!=null || evidence.GetMemory().Records.Size()>0
            || evidence.Suspicion>0 || evidence.VisibleNow
            || observer.Pos!=evidence.EmptySearchOrigin || observer.Angle!=evidence.EmptySearchAngle)return false;
        evidence.EmptySearchSkipped++;return true;
    }

    static void ContactWake(CaelumCombatActor observer,Actor other)
    {
        if(observer==null || !Touching(observer,other))return;
        let evidence=Evidence(observer);evidence.WakeEmptySearch();evidence.Observe(observer,other);
    }

    static Actor Candidate(CaelumCombatActor observer)''')
s=replace(s,'        let evidence=Evidence(observer);\n        if(observer.PendingTheftTarget','''        let evidence=Evidence(observer);
        if(ReuseEmptySearch(observer,evidence))return null;
        if(observer.PendingTheftTarget''')
s=replace(s,'        CaelumCombatActor ally;double allyDistance=1e30;','''        CaelumCombatActor ally;double allyDistance=1e30;
        bool perceptible=false;''')
s=replace(s,'        if(group!=null)\n        {','''        if(group!=null)
        {
            // La lista compartida omite neutrales externos. No deducir de
            // esa ausencia que el grupo este aislado: conserva su frecuencia.
            evidence.EmptySearchUntil=0;''')
s=replace(s,'            let candidate=local.thing;\n            if(!Opponent(observer,candidate))','''            let candidate=local.thing;
            if(!perceptible && Living(candidate) && candidate!=observer
                && !Opponent(observer,candidate) && CanSee(observer,candidate))perceptible=true;
            if(!Opponent(observer,candidate))''')
s=replace(s,'            let candidate=entry!=null ? entry.Body : null;\n            if(!Opponent(observer,candidate))continue;','''            let candidate=entry!=null ? entry.Body : null;
            if(!perceptible && Living(candidate) && candidate!=observer
                && !Opponent(observer,candidate) && CanSee(observer,candidate))perceptible=true;
            if(!Opponent(observer,candidate))continue;''')
s=replace(s,'        if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);\n        evidence.CandidateCache=nearest;','''        if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);
        evidence.EmptySearchUntil=nearest==null && ally==null && !perceptible
            && observer.target==null && evidence.GetMemory().Records.Size()==0 && evidence.Suspicion<=0
            ? level.time+CaelumPerceptionData.EMPTY_SEARCH_TICS : 0;
        evidence.EmptySearchOrigin=observer.Pos;evidence.EmptySearchAngle=observer.Angle;
        evidence.CandidateCache=nearest;''')
files[name]=s
name='actors/CaelumNoise.zs';s=read(name)
s=replace(s,'        let evidence=CaelumVisualPerception.Evidence(listener);','''        let evidence=CaelumVisualPerception.Evidence(listener);evidence.WakeEmptySearch();''');files[name]=s
name='actors/CaelumCommunication.zs';s=read(name)
s=replace(s,'        memory.Remember(packet.Subject,packet.Position,packet.ObservedTic,packet.OriginalWitness,sender);','''        CaelumVisualPerception.Evidence(receiver).WakeEmptySearch();
        memory.Remember(packet.Subject,packet.Position,packet.ObservedTic,packet.OriginalWitness,sender);''');files[name]=s
name='actors/CaelumCombatActor.zs';s=read(name)
s=replace(s,'        CaelumContaminationContacts.Collision(self,other);','''        CaelumContaminationContacts.Collision(self,other);
        CaelumVisualPerception.ContactWake(self,other);''');files[name]=s
with zipfile.ZipFile(OUT/'candidate.pk3','w',zipfile.ZIP_STORED) as z:
    for name,text in sorted(files.items()):z.writestr(zipfile.ZipInfo('caelum/'+name,(2000,1,1,0,0,0)),text.encode())
(OUT/'candidate-sources.json').write_bytes((json.dumps(hashes,indent=2)+'\n').encode())
print('Prepared diagnostic candidate only. No production adoption.')
