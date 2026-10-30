"""Reuse #431 presentation-window observer with separate #433 evidence."""
from pathlib import Path
import importlib.util
import sys
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('profile',ROOT/'assets/validation_v5_11_0/run_profile.py')
profile=importlib.util.module_from_spec(spec);spec.loader.exec_module(profile)
profile.OUT=ROOT/'build/issue433/performance'
if __name__=='__main__':
    if '--overlay' in sys.argv:
        destination=ROOT/'build/issue433/observer';destination.mkdir(parents=True,exist_ok=True)
        source=(ROOT/'assets/validation_5103/performance.zs').read_text()
        old='while((body=CaelumCombatActor(it.Next()))!=null)if(body.health>0)alive++;'
        new='int skipped=0;\n        while((body=CaelumCombatActor(it.Next()))!=null)\n        {if(body.health>0)alive++;if(body.VisualEvidence!=null)skipped+=body.VisualEvidence.EmptySearchSkipped;}\n        Console.Printf("CA433 SKIPS %s total=%d",label,skipped);'
        assert source.count(old)==1
        (destination/'performance.zs').write_bytes(source.replace(old,new).encode())
        profile.HERE=destination
    profile.main()
