"""Bound reused functional evidence by exact package and per-frame MD3 bytes."""
from pathlib import Path
import hashlib,json,struct,zipfile

ROOT=Path(__file__).resolve().parents[2]


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def md3_parts(blob):
    header=struct.unpack_from('<4sI64s9I',blob);static=[blob[:108]]
    frames=[blob[header[8]+56*i:header[8]+56*(i+1)] for i in range(header[4])]
    offset=header[10]
    for _ in range(header[6]):
        h=struct.unpack_from('<4s64s10I',blob,offset);static.append(blob[offset:offset+h[10]])
        for i in range(h[3]):
            start=offset+h[10]+i*h[5]*8;frames[i]+=blob[start:start+h[5]*8]
        offset+=h[-1]
    assert offset==len(blob)
    return static,frames


def main():
    final=ROOT/'build/issue811-period05.pk3';changes={}
    expected=['models/caelum/folklore/periodapparitions/'+kind+'.md3' for kind in ['llorona','viuda']]
    with zipfile.ZipFile(final) as current:
        for version in ['02','03','04']:
            original=ROOT/f'build/issue811-period{version}.pk3'
            with zipfile.ZipFile(original) as old:
                assert old.namelist()==current.namelist()
                different=sorted(n for n in old.namelist() if old.read(n)!=current.read(n))
                assert different==expected
                frames={}
                if version!='02':
                    for name in different:
                        a,b=md3_parts(old.read(name)),md3_parts(current.read(name));assert a[0]==b[0]
                        changed=[i for i,(before,after) in enumerate(zip(a[1],b[1])) if before!=after]
                        assert changed==[2,3,4,5,6,7],changed
                        normals_only={}
                        for index in [2,4]:
                            before,after=a[1][index],b[1][index]
                            assert before[:56]==after[:56]
                            assert len(before)==len(after)
                            count=0
                            for offset in range(56,len(before),8):
                                assert before[offset:offset+6]==after[offset:offset+6]
                                count+=before[offset+6:offset+8]!=after[offset+6:offset+8]
                            normals_only[index]=count
                        frames[name]=dict(changed_frames=changed,position_changes=[3,5,6,7],normals_only_counts=normals_only)
                changes[version]=dict(runtime_sha256=sha(original),changed_resources=different,changed_native_frames=frames,
                    all_other_runtime_bytes_identical=True,all_bindings_and_futre_exact=True)
    evidence={}
    for label,path,version in [
        ('viuda-continuity','issue811-viuda-native02','03'),('llorona-continuity','issue811-llorona-native02','03'),
        ('futre-continuity','issue811-futre-native01','02'),('actions-loot','issue811-actions01','04'),
        ('futre-final-camera','issue811-futre-visual02','03')]:
        report=json.loads((ROOT/'build'/path/'RESULTS.json').read_text())
        assert report['runtime_sha256']==changes[version]['runtime_sha256']
        assert all(row['passed'] for row in report['runs'])
        evidence[label]=dict(path='build/'+path+'/RESULTS.json',assertions=sum(row['assertions'] for row in report['runs']),runtime_version=version)
    result=dict(issue=811,final_runtime_sha256=sha(final),comparisons=changes,reused_evidence=evidence,
        qualification='Final art changes from period03/04 are only female MD3 walk/run frames2..7: positions change in3/5/6/7;2/4 retain exact positions/bounds and differ only in a few encoded normals after floating-point gait transforms. Native states, timings, classes, collision, save fields, loot, all bindings, all textures, all topology/UVs and the other17 animation frames are exact. Futre is byte-identical even to period02. Final-package female visual checks and final presentation cohorts complement this bounded functional reuse; no campaign or author acceptance.')
    (ROOT/'build/issue811-gait-reuse-proof.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(passed=True,reused_assertions=sum(v['assertions'] for v in evidence.values()),changed_frames=[2,3,4,5,6,7],position_changes=[3,5,6,7])))


if __name__=='__main__':main()
