"""Read native save checkpoints without changing gameplay or saved data."""
from pathlib import Path
import collections
import hashlib
import json
import sys
import zipfile

path=Path(sys.argv[1])
with zipfile.ZipFile(path) as archive:
    data=json.loads(archive.read('map06.map.json'))
objects=data['objects'];rows=[]
for obj in objects:
    state=obj.get('class:CaelumPortDefender')
    if not state:continue
    pos=obj['pos'];post=state['station'];nav=objects[state['CityNavigation']].get('class:CaelumCityNavigation',{}) if state.get('CityNavigation') else {}
    distance=sum((pos[i]-post[axis])**2 for i,axis in enumerate(('X','Y','Z')))**.5
    rows.append({'id':state.get('HomeIdentity',0),'pos':pos,'post':post,'distance':round(distance,2),
        'step':state.get('DeploymentStep',0),'complete':state.get('DeploymentComplete',False),
        'yield':state.get('ReturningFromYield',False),'yieldFor':state.get('YieldFor'),
        'crew':state.get('FollowingCrewRoute',False),'nav':nav})
print(json.dumps({'save':str(path),'save_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
    'roster':len(rows),'complete':sum(r['complete'] for r in rows),
    'formed32':sum(r['distance']<=32 for r in rows),'yielding':sum(r['yield'] for r in rows),
    'following_crew_routes':sum(r['crew'] for r in rows),
    'pending':[r for r in sorted(rows,key=lambda x:x['id']) if not r['complete'] or r['distance']>32 or r['yield'] or r['crew']]},indent=2))
