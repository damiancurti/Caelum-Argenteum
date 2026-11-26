from pathlib import Path
import sys
root=Path(__file__).resolve().parents[2]
source=(root/'assets/validation_v5_16_2/prepare_barracas_profile.py').read_text(encoding='utf-8')
source=source.replace("    files = {}", """    specs.extend([
        ('caelum/actors/CaelumVisualPerception.zs','CaelumVisualPerception','static ','bool','Opponent','CaelumCombatActor observer,Actor candidate','observer,candidate','Opponent'),
        ('caelum/actors/CaelumVisualPerception.zs','CaelumVisualPerception','static ','bool','CanSee','CaelumCombatActor observer,Actor candidate','observer,candidate','CanSee'),
        ('caelum/actors/CaelumCommunication.zs','CaelumCommunication','static ','CaelumCommandCandidates','CandidatesFor','CaelumCombatActor body','body','CandidatesFor'),
        ('caelum/actors/CaelumCommunication.zs','CaelumCommandCandidates','','void','Refresh','CaelumCombatActor leader','leader','GroupRefresh'),
        ('caelum/actors/CaelumCombatActor.zs','CaelumCombatActor','override ','void','Tick','','','CombatTick'),
    ])
    files = {}""")
source=source.replace("            assert re.findall(r'^class\\s+(\\w+)', source, re.M)[-1] == cls",'')
source=source.replace("source.replace(anchor, f'{prefix}{result} Unprofiled{name}(', 1)","source.replace(anchor, f'{prefix if prefix != \'override \' else \'\'}{result} Unprofiled{name}(', 1)")
source=source.replace("            pos = source.rfind('}'); files[path]", """            start=re.search(r'^class\\s+'+cls+r'\\b',source,re.M).start()
            pos=source.index('{',start);depth=1
            while depth:
                pos+=1
                if source[pos]=='{':depth+=1
                elif source[pos]=='}':depth-=1
            files[path]""")
source=source.replace("metrics = ['Navigation', 'Candidate', 'Acquire', 'Noise', 'Communication']","metrics = [row[7] for row in specs]")
source=source.replace("'scope': __doc__.strip()", "'scope': 'Expanded inclusive perception/actor timing; unchanged runtime rules. Nested scopes and diagnostic overhead must not be summed or treated as production savings.'")
exec(compile(source,str(root/'assets/validation_v5_16_2/prepare_barracas_profile.py'),'exec'),{'__name__':'__main__','__file__':str(root/'assets/validation_v5_16_2/prepare_barracas_profile.py')})
