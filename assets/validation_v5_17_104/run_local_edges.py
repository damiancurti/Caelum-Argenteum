"""Extend retained reach/relationship tests with local query equivalence."""
from pathlib import Path
import sys,zipfile

ROOT=Path(__file__).resolve().parents[2]
index=sys.argv.index('--baseline');baseline=Path(sys.argv[index+1]);del sys.argv[index:index+2]
with zipfile.ZipFile(baseline) as z:reference=z.read('caelum/actors/CaelumVisualPerception.zs').decode('utf-8').replace('\r\n','\n')
reference=reference.replace('class CaelumVisualPerception : Object play','class CA851BaselinePerception : Object play',1)
relation=(ROOT/'assets/validation_v5_17_97/relation_edges838.zs').read_text(encoding='utf-8').replace('CA838BaselinePerception','CA851BaselinePerception')
anchor='        Assert(original==expected && current==expected,label);'
addition='''
        let population=CaelumPopulationState.Get();bool dense=population.HighDensity;
        double height=population.PerceptionMaximumHeight;population.PerceptionMaximumHeight=256;
        let group=body.SiegeCombatant.GroupCandidates;body.SiegeCombatant.GroupCandidates=null;
        for(int mode=0;mode<2;mode++)
        {
            population.HighDensity=mode==1;
            Assert(CA851LocalParity.Same(body),String.Format("%s local target/ally dense=%d",label,mode));
        }
        body.SiegeCombatant.GroupCandidates=group;population.HighDensity=dense;
        population.PerceptionMaximumHeight=height;
'''
assert relation.count(anchor)==1;relation=relation.replace(anchor,anchor+addition)
anchor='        near.bFriendly=false;\n        user.SetOrigin((256,0,0),false);'
addition='''        let allyEncounter=near.SiegeCombatant.Encounter;
        near.SiegeCombatant.Encounter=body.SiegeCombatant.Encounter;near.SiegeCombatant.CommandLeader=body.SiegeCombatant;
        Assert(CaelumCommunication.Eligible(body,near) && !CaelumVisualPerception.Opponent(body,near),"local ally prerequisite");
        Same(body,near,far,null,"eligible nearby ally evidence");
        near.SetOrigin((32,0,0),false);Same(body,near,far,null,"contact ally identification");
        near.SetOrigin((1800,0,0),false);Same(body,near,far,null,"remote ally evidence rejected");
        near.SetOrigin((256,0,0),false);near.SiegeCombatant.Encounter=allyEncounter;near.SiegeCombatant.CommandLeader=near.SiegeCombatant;
'''
assert relation.count(anchor)==1;relation=relation.replace(anchor,addition+anchor)
anchor='        Retire(machine);Retire(resident);Retire(body);Retire(near);Retire(far);'
addition='''        double height=population.PerceptionMaximumHeight;population.PerceptionMaximumHeight=256;
        resident.SetOrigin((0,0,0),false);resident.SiegeCombatant.GroupCandidates=null;
        record.LandMaterialSchemaRevision=0;ClearCache(resident);
        ignored=CaelumVisualPerception.Candidate(resident);
        Assert(record.LandMaterialSchemaRevision==CaelumLandResourceData.REVISION,"remote LOCAL resident preserves material migration");
        resident.SetOrigin((1800,0,0),false);machine.SiegeCombatant.GroupCandidates=null;
        record.LandMaterialSchemaRevision=0;ClearCache(machine);
        ignored=CaelumVisualPerception.Candidate(machine);
        Assert(record.LandMaterialSchemaRevision==CaelumLandResourceData.REVISION,"remote LOCAL automaton delegation preserves migration");
        population.PerceptionMaximumHeight=height;
'''
assert relation.count(anchor)==1;relation=relation.replace(anchor,addition+anchor)
original=ROOT/'assets/validation_v5_17_96/run_reach_edges.py';source=original.read_text(encoding='utf-8')
anchor='''        population.HighDensity=originalDense;
        return found==subject;'''
replacement='''        Observer.SiegeCombatant.GroupCandidates=null;
        double maximumHeight=population.PerceptionMaximumHeight;
        population.PerceptionMaximumHeight=Max(256.0,subject.Height);
        bool same=true;
        for(int mode=0;mode<2;mode++)
        {
            population.HighDensity=mode==1;
            bool okay=CA851LocalParity.Same(Observer);Checks++;if(!okay){Failures++;same=false;}
            Console.Printf("CA836 EDGE %s local parity dense=%d",okay?"PASS":"FAIL",mode);
        }
        Observer.SiegeCombatant.GroupCandidates=group;
        population.PerceptionMaximumHeight=maximumHeight;population.HighDensity=originalDense;
        return found==subject && same;'''
assert source.count(anchor)==1;source=source.replace(anchor,replacement)
anchor="    files={'ZSCRIPT':";assert source.count(anchor)==1
parity=(Path(__file__).resolve().parent/'local_parity851.zs').read_text(encoding='utf-8')
source=source.replace(anchor,'    source += '+repr('\n'+reference+'\n'+parity+'\n'+relation)+'\n'+anchor)
source=source.replace('AddEventHandlers="CA836VisionEdges"','AddEventHandlers="CA836VisionEdges", "CA838RelationEdges"')
source=source.replace("'issue':836","'issue':851")
source=source.replace('Frozen fixture bodies; force high-density query only during each synchronous check, restore population flag immediately. Original CanSee predicate is the independent reference for actual Candidate selection. Not campaign acceptance.', 'Frozen fixture bodies; retain group edge expectations and compare baseline/current local Candidate in sparse/dense modes with caches cleared, plus local migration side effects. A fixture-only enlarged census height ensures remote bodies are iterated. Restore census state immediately. Includes linked portals and saved probes; not campaign acceptance.')
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
