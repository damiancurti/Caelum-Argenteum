"""Copy a #460 save for the prior runtime, resetting only new visual state.

The source is never modified. Use its matching pre-patch map/package options.
Restore the original save and current package to reverse this operation.
"""
import argparse
import hashlib
import json
import re
import zipfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]

def migrate(source,destination):
    if destination.exists():raise ValueError('Destination already exists; preserve both saves')
    original=source.read_bytes();sha=hashlib.sha256(original).hexdigest()
    actions=json.loads((ROOT/'assets/source/art/domingo_3d_pilot/DESIGN.json').read_text())['export_actions']
    starts={};total=0
    for name,row in actions.items():starts[name]=total;total+=len(row['frames'])
    transition=[starts[name]+i for name in ['SitDown','StandUp','LieDown','GetUp'] for i in range(len(actions[name]['frames']))]
    states=transition+[starts[name]+i for name in ['Seated','Sleeping'] for i in range(len(actions[name]['frames']))]
    report={'issue':460,'migration_revision':1,'source_sha256':sha,'body_states':0,'model_bindings':0,'rest_owners':0}
    entries=[]
    with zipfile.ZipFile(source) as archive:
        for info in archive.infolist():
            blob=archive.read(info.filename)
            if info.filename.endswith('.map.json'):
                data=json.loads(blob);objects=data.get('objects',[])
                for obj in objects:
                    kind=obj.get('classtype','')
                    if kind in ['CaelumDomingoPilotBody','CaelumWardrobePilotBody']:
                        state=obj.get('state',[])
                        if len(state)==2 and state[0]=='CaelumDomingoPilotFrames' and state[1]>=total:
                            offset=state[1]-total
                            if offset>=len(states):raise ValueError('Unknown newer state; refuse unrelated migration')
                            frame=states[offset];obj['state']=[state[0],frame]
                            obj['sprite']=f'D3{frame//26:02X}';obj['frame']=frame%26
                            obj['tics']=1;obj['class:CaelumDomingoPilotBody']['ModelFrame']=frame
                            report['body_states']+=1
                        model_index=obj.get('modelData')
                        if isinstance(model_index,int):
                            model=objects[model_index]
                            if model.get('classtype')!='ActorModelData':raise ValueError('Unexpected model owner')
                            if 'rest_motion/' in json.dumps(model):
                                for binding in model.get('models',[]):
                                    path=binding.get('model',{}).get('second','')
                                    if path:binding['model']['second']=re.sub(r'rest_motion/(eat|drink)/','',path)
                                wardrobe=kind=='CaelumWardrobePilotBody'
                                slot=15 if wardrobe else 5
                                directory='grips' if wardrobe else 'domingo'
                                model['models'][slot]={'model':{'first':'','second':f'models/caelum/characters/{directory}/weapon.md3'}}
                                report['model_bindings']+=1
                                if wardrobe:
                                    fields=obj.get('class:CaelumWardrobePilotBody',{})
                                    fields['HiddenMask']=fields.get('HiddenMask',0)&~(1<<slot)
                        obj.get('class:CaelumDomingoPilotBody',{}).pop('MealVisualPhase',None)
                    if kind=='CaelumRestState':
                        fields=obj.get('class:CaelumRestState',{})
                        removed=[key for key in fields if key.startswith('Motion')]
                        for key in removed:fields.pop(key)
                        report['rest_owners']+=bool(removed)
                blob=json.dumps(data,separators=(',',':'),ensure_ascii=False).encode()
            entries.append((info,blob))
    destination.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(destination,'x',zipfile.ZIP_DEFLATED) as archive:
        for info,blob in entries:archive.writestr(info,blob)
    assert source.read_bytes()==original
    report['destination_sha256']=hashlib.sha256(destination.read_bytes()).hexdigest()
    destination.with_suffix('.migration.json').write_text(json.dumps(report,indent=2)+'\n')
    return report

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source',type=Path);parser.add_argument('destination',type=Path)
    args=parser.parse_args();print(json.dumps(migrate(args.source,args.destination)))
