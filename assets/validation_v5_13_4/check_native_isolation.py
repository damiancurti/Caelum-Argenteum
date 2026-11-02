"""Prove both campaign import paths reject each participant in a native match save."""
import argparse,json,sys,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_profiles import validate_anchor,ProfileError
from caelum_sessions import digest

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for key in ('save','runtime','engine','output'):p.add_argument('--'+key,type=Path,required=True)
    a=p.parse_args();schema=NativeSchema(a.engine,a.runtime)
    with zipfile.ZipFile(a.save) as archive:
        info=json.loads(archive.read('info.json'))
        level=json.loads(archive.read(info['Current Map'].lower()+'.map.json'))
    rows=[]
    for slot in range(len(level['players'])):
        for boundary,call in [('personal_graph',lambda:PersonalGraph(schema).capture(level,slot)),
                              ('profile_registry',lambda:validate_anchor(a.save.read_bytes(),slot))]:
            try:call();rows.append(dict(slot=slot,boundary=boundary,rejected=False))
            except ProfileError as error:rows.append(dict(slot=slot,boundary=boundary,rejected=True,reason=str(error)))
    report=dict(save_sha256=digest(a.save),runtime_sha256=digest(a.runtime),checks=rows,
                passed=bool(rows) and all(row['rejected'] for row in rows))
    a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,indent=2));return not report['passed']

if __name__=='__main__':raise SystemExit(main())
