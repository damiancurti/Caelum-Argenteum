"""Check rejection of incomplete/foreign/failed real-presentation evidence."""
from pathlib import Path
import argparse,csv,datetime,io,json
from analyze_vulkan_presents import inspect


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    a.output.mkdir(parents=True,exist_ok=False);reports=[]
    rows=[dict(PID=42,Swapchain='one',EntryQPCms=2100+i*15,ReturnQPCms=2101+i*15,Result=0) for i in range(4)]
    for label in ('valid','foreign-pid','missing-footer','wrong-count','failed-present','mixed-swapchain','reversed-call'):
        data=[dict(x) for x in rows]
        if label=='foreign-pid':data[0]['PID']=43
        if label=='failed-present':data[0]['Result']=-4
        if label=='mixed-swapchain':data[0]['Swapchain']='other'
        if label=='reversed-call':data[0]['ReturnQPCms']=2000
        text=io.StringIO(newline='');writer=csv.DictWriter(text,fieldnames=list(data[0]));writer.writeheader();writer.writerows(data)
        if label!='missing-footer':text.write('# complete rows='+('5' if label=='wrong-count' else '4')+'\n')
        path=a.output/(label+'.csv');path.write_text(text.getvalue(),encoding='ascii')
        try:
            result=inspect(path,42,0,4000);passed=label=='valid' and result['present_intervals']['mean_ms']==15
        except ValueError as exc:passed=label!='valid';result=str(exc)
        reports.append(dict(case=label,passed=passed,result=result))
    (a.output/'results.json').write_text(json.dumps(reports,indent=2)+'\n')
    print(json.dumps(reports,indent=2));raise SystemExit(not all(r['passed'] for r in reports))


if __name__=='__main__':main()
