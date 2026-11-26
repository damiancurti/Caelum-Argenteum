"""Capture private vault views and test maximum-size collision cylinders.

The placement teleports and invulnerability belong only to the disposable
inspection player. Collision cylinders use native TryMove in four selected dry
runs, with opposing pairs where two maximum-radius bodies fit. This is bounded
geometry evidence, not player movement, escort AI or author acceptance.
If a live rat or Mandinga blocks a cylinder, its solidity is recorded, disabled
for this synchronous geometry check and restored before the event returns.
"""
from pathlib import Path
import json, sys

ROOT = Path(__file__).resolve().parents[2]
index = sys.argv.index('--cameras')
camera_path = Path(sys.argv[index+1]).resolve(strict=True)
del sys.argv[index:index+2]
camera_data = json.loads(camera_path.read_text(encoding='utf-8'))
rows = camera_data['rows']
cases = []
for number, row in enumerate(rows):
    start, end = row['start'], row['end']
    vector = lambda values: '('+','.join(map(str,values))+')'
    offsets = row['lane_offsets']+[0]
    cases.append(f'case {number}: start={vector(start)}; finish={vector(end)}; '
                 f'axis={row["axis"]}; bodies={row["bodies"]}; '
                 f'offset0={offsets[0]}; offset1={offsets[1]}; label="{row["name"]}"; break;')
collision = '''
class CA875CollisionBody : Actor
{
    Default { Radius BODYRADIUS; Height BODYHEIGHT; +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA875CollisionCheck : EventHandler
{
    Array<Actor> Cleared;
    bool Move(Actor body,vector2 goal)
    {
        while(true)
        {
            if(body.TryMove(goal,0))return true;
            let blocker=body.BlockingMobj;
            if(blocker==null || !blocker.bSolid || !(blocker is "CaelumGiantRat" || blocker is "CaelumMandinga"))return false;
            Console.Printf("CA875 CLEAR_ACTOR class=%s pos=%.3f,%.3f,%.3f",blocker.GetClassName(),blocker.Pos.X,blocker.Pos.Y,blocker.Pos.Z);
            Cleared.Push(blocker);blocker.bSolid=false;
        }
        return false;
    }
    override void NetworkProcess(ConsoleEvent event)
    {
        if(event.Name!="ca875_collision")return;
        bool all=true;int moves=0;
        for(int row=0;row<ROWCOUNT;row++)
        {
            vector3 start,finish;int axis,bodies;double offset0,offset1;String label;
            switch(row){CASES default:return;}
            Actor body0,body1;body0=null;body1=null;vector3 a=start,b=finish;
            if(axis==0){a.Y+=offset0;b.Y+=offset1;}
            else {a.X+=offset0;b.X+=offset1;}
            body0=Actor.Spawn("CA875CollisionBody",a,NO_REPLACE);
            if(bodies==2)body1=Actor.Spawn("CA875CollisionBody",b,NO_REPLACE);
            bool okay=body0!=null && (bodies==1 || body1!=null);
            int expected=int((finish-start).Length()/STEP);
            if(okay)okay=Move(body0,body0.Pos.XY);
            if(okay && body1!=null)okay=Move(body1,body1.Pos.XY);
            for(int direction=0;direction<2 && okay;direction++)
            {
                vector2 step=(finish.XY-start.XY).Unit()*STEP*(direction==0?1:-1);
                for(int n=0;n<expected && okay;n++)
                {
                    okay=Move(body0,body0.Pos.XY+step);moves++;
                    if(okay && body1!=null){okay=Move(body1,body1.Pos.XY-step);moves++;}
                    if(okay)okay=Abs(body0.Pos.Z-a.Z)<0.000001 && body0.CeilingZ-body0.Pos.Z>=BODYHEIGHT;
                    if(okay && body1!=null)okay=Abs(body1.Pos.Z-b.Z)<0.000001 && body1.CeilingZ-body1.Pos.Z>=BODYHEIGHT;
                }
            }
            if(okay)okay=(body0.Pos-a).Length()<0.000001;
            if(okay && body1!=null)okay=(body1.Pos-b).Length()<0.000001;
            Console.Printf("CA875 COLLISION %s case=%s bodies=%d length=%.3f radius=%.6f height=%.3f",okay?"PASS":"FAIL",label,bodies,(finish-start).Length(),BODYRADIUS,BODYHEIGHT);
            if(!okay && body0!=null)Console.Printf("CA875 BODY pos=%.3f,%.3f,%.3f ceiling=%.3f",body0.Pos.X,body0.Pos.Y,body0.Pos.Z,body0.CeilingZ);
            if(!okay && body0!=null && body0.BlockingMobj!=null)Console.Printf("CA875 BLOCKER body=0 class=%s",body0.BlockingMobj.GetClassName());
            if(!okay && body1!=null && body1.BlockingMobj!=null)Console.Printf("CA875 BLOCKER body=1 class=%s",body1.BlockingMobj.GetClassName());
            if(!okay && body0!=null)Console.Printf("CA875 LINEBLOCK body=0 line=%d movement=%d",body0.BlockingLine!=null,body0.MovementBlockingLine!=null);
            if(!okay && body1!=null)Console.Printf("CA875 LINEBLOCK body=1 line=%d movement=%d",body1.BlockingLine!=null,body1.MovementBlockingLine!=null);
            all=all && okay;
            if(body0!=null)body0.Destroy();if(body1!=null)body1.Destroy();
        }
        int restored=0;
        for(int i=0;i<Cleared.Size();i++)if(Cleared[i]!=null){Cleared[i].bSolid=true;restored++;}
        Console.Printf("CA875 COLLISION_COMPLETE %s cases=ROWCOUNT moves=%d cleared=%d restored=%d",all?"PASS":"FAIL",moves,Cleared.Size(),restored);
        Cleared.Clear();
    }
}
'''.replace('CASES','\n'.join(cases)).replace('ROWCOUNT',str(len(rows)))
for token,key in [('BODYRADIUS','radius'),('BODYHEIGHT','height'),('STEP','step_mu')]:
    collision=collision.replace(token,str(camera_data[key]))
previous=ROOT/'assets/validation_v5_17_102/run_material_views.py'
source=previous.read_text(encoding='utf-8')
count=5+len(rows)
changes=[
    ("'CA847 FAIL')", "'CA847 FAIL','CA875 COLLISION FAIL','CA875 COLLISION_COMPLETE FAIL')"),
    ("'''.replace('CASES',cases)", "'''.replace('CASES',cases)+CA875_COLLISION"),
    ('AddEventHandlers="CA847Views"','AddEventHandlers="CA847Views", "CA875CollisionCheck"'),
    ('View==5',f'View=={count}'),
    ('CA847 PASS views=5',f'CA847 PASS views={count}'),
    ("'screenshot walk.png','wait 5','quit'", "'screenshot walk.png','netevent ca875_collision','wait 5','quit'"),
    ("and all((folder/n).exists() for n in images)", "and 'CA875 COLLISION_COMPLETE PASS' in text and all((folder/n).exists() for n in images)"),
    ("if 'CA847 ' in s", "if 'CA847 ' in s or 'CA875 ' in s"),
    ('points=cameras();', 'points=cameras()+CA875_CAMERAS;'),
    ('report=dict(issue=847,','report=dict(issue=875,collision_parameters=CA875_PARAMETERS,'),
    ('qualification=__doc__','qualification=CA875_QUALIFICATION')]
for old,new in changes:
    assert source.count(old)==1,old
    source=source.replace(old,new,1)
exec(compile(source,str(previous),'exec'),{'__file__':str(previous),'__name__':'__main__',
    'CA875_COLLISION':collision,'CA875_CAMERAS':rows,'CA875_PARAMETERS':camera_data,
    'CA875_QUALIFICATION':__doc__})
