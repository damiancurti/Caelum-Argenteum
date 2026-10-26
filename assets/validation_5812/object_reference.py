"""Independent fixed-step RK4 reference for the object's simultaneous rain ODE.

Optional regeneration tool, not required for launching the native laboratory.
The reference uses differential rates only, not the production integral/root.
"""
from pathlib import Path
import json

cases=[(0,4,10,.04,1800),(12,20,10,.04,1800),
       (12,20,10,.01,1800),(0,.2,10,.16,60),
       (.5,4,2,.16,30),(80,20,10,.04,6500)]

def integrate(value,ambient,rain,area,seconds,dt):
    wash=(rain*5 if rain<=2 else min(20,10+(rain-2)*1.25))/1800
    def slope(c):
        gain=.1*area*ambient/max(c,1)
        if c>ambient:return -wash
        if c==ambient:return min(0,gain-wash)
        return gain-wash
    steps=round(seconds/dt)
    for _ in range(steps):
        old=value
        a=slope(value);b=slope(value+dt*a/2);c=slope(value+dt*b/2);d=slope(value+dt*c)
        value=max(0,value+dt*(a+2*b+2*c+d)/6)
        if old<=ambient:value=min(ambient,value)
    return value

rows=[];lines=[]
for i,args in enumerate(cases):
    coarse=integrate(*args,.02);fine=integrate(*args,.01)
    assert abs(coarse-fine)<.00001,(args,coarse,fine)
    rows.append({'inputs':args,'step_002':coarse,'step_001':fine})
    values=','.join(str(v) for v in args[:3]+(args[3],args[4]))
    lines.append(f'Check(Abs(CaelumContaminationObjectBalance.Evolve({values})-{fine:.12f})<0.00002,"independent RK4 reference case {i+1}");')
here=Path(__file__).resolve().parent
(here/'object_numeric.zs').write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
out=here/'objects';out.mkdir(exist_ok=True)
(out/'ode-reference.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Generated six converged independent ODE references.')
