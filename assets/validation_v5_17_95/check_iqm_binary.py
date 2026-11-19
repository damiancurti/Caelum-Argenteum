"""Independently inspect serialized IQM and reconstruct every sampled position."""
from pathlib import Path
import argparse,hashlib,json,math,struct
import numpy as np
ROOT=Path(__file__).resolve().parents[2]
FIELDS=('version filesize flags num_text ofs_text num_meshes ofs_meshes num_arrays num_vertices ofs_arrays '
        'num_triangles ofs_triangles ofs_adjacency num_joints ofs_joints num_poses ofs_poses num_anims ofs_anims '
        'num_frames num_channels ofs_frames ofs_bounds num_comment ofs_comment num_extensions ofs_extensions').split()
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def affine(row):
    x,y,z,w=np.asarray(row[3:7],dtype=np.float64)/np.linalg.norm(row[3:7])
    rotation=np.array([[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],
      [2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],
      [2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]],dtype=np.float64)
    result=np.eye(4);result[:3,:3]=rotation*np.asarray(row[7:10])[None,:];result[:3,3]=row[:3];return result

def hierarchy(rows,parents):
    world=[]
    for i,row in enumerate(rows):
        m=affine(row);world.append(world[parents[i]]@m if parents[i]>=0 else m)
    return np.asarray(world)

def inspect(path,expected,baseline):
    blob=path.read_bytes();magic,*values=struct.unpack_from('<16s27I',blob)
    assert magic==b'INTERQUAKEMODEL\0';h=dict(zip(FIELDS,values))
    assert h['version']==2 and h['filesize']==len(blob) and h['flags']==0
    assert h['num_meshes']==1 and h['num_arrays']==5 and h['num_frames']==375 and h['num_joints']==h['num_poses']
    assert h['num_anims']==h['ofs_anims']==h['num_comment']==h['ofs_comment']==h['num_extensions']==h['ofs_extensions']==0
    spans=[]
    def block(offset,size,label):
        assert offset>=124 and offset%4==0 and size>0 and offset+size<=len(blob),(label,offset,size)
        spans.append((offset,offset+size,label));return memoryview(blob)[offset:offset+size]
    text=bytes(block(h['ofs_text'],h['num_text'],'text'));assert text[-1]==0
    def string(offset):
        assert 0<=offset<len(text);end=text.find(b'\0',offset);assert end>=0;return text[offset:end].decode('utf-8')
    mesh=struct.unpack('<6I',block(h['ofs_meshes'],24,'mesh'))
    assert mesh[2:]==(0,h['num_vertices'],0,h['num_triangles'])
    arrays={}
    descriptions=block(h['ofs_arrays'],h['num_arrays']*20,'array descriptors')
    formats={0:(7,3,'<f4'),1:(7,2,'<f4'),2:(7,3,'<f4'),4:(1,4,'u1'),5:(1,4,'u1')}
    for kind,flags,fmt,size,offset in struct.iter_unpack('<5I',descriptions):
        assert kind in formats and kind not in arrays and flags==0
        want_fmt,want_size,dtype=formats[kind];assert (fmt,size)==(want_fmt,want_size)
        arrays[kind]=np.frombuffer(block(offset,h['num_vertices']*size*np.dtype(dtype).itemsize,'array'+str(kind)),dtype=dtype).reshape(-1,size)
    for key in [0,1,2]:assert np.all(np.isfinite(arrays[key]))
    assert np.all(arrays[4]<h['num_joints']) and np.all(arrays[5].astype(np.int32).sum(axis=1)==255)
    triangles=np.frombuffer(block(h['ofs_triangles'],h['num_triangles']*12,'triangles'),dtype='<u4').reshape(-1,3)
    assert int(triangles.max())<h['num_vertices'] and np.all(triangles[:,0]!=triangles[:,1]) and np.all(triangles[:,1]!=triangles[:,2]) and np.all(triangles[:,2]!=triangles[:,0])
    adjacency=np.frombuffer(block(h['ofs_adjacency'],h['num_triangles']*12,'adjacency'),dtype='<u4').reshape(-1,3)
    assert np.all((adjacency==0xffffffff)|(adjacency<h['num_triangles']))
    for i,row in enumerate(adjacency):
        for neighbor in row:
            if neighbor!=0xffffffff:assert i in adjacency[int(neighbor)]
    joints=list(struct.iter_unpack('<Ii10f',block(h['ofs_joints'],h['num_joints']*48,'joints')))
    names=[string(row[0]) for row in joints];parents=[row[1] for row in joints];rest=np.asarray([row[2:] for row in joints])
    assert len(set(names))==len(names) and all(-1<=parent<i for i,parent in enumerate(parents))
    assert np.all(np.isfinite(rest)) and np.all(np.linalg.norm(rest[:,3:7],axis=1)>0) and np.all(rest[:,7:10]!=0)
    poses=list(struct.iter_unpack('<iI20f',block(h['ofs_poses'],h['num_poses']*88,'poses')))
    assert [row[0] for row in poses]==parents and all(row[1]&~1023==0 for row in poses)
    assert sum(row[1].bit_count() for row in poses)==h['num_channels']
    frames=np.frombuffer(block(h['ofs_frames'],h['num_frames']*h['num_channels']*2,'frames'),dtype='<u2').reshape(h['num_frames'],h['num_channels'])
    decoded=np.empty((h['num_frames'],h['num_poses'],10),dtype=np.float64);cursor=0
    for joint,row in enumerate(poses):
        for channel in range(10):
            offset,scale=row[2+channel],row[12+channel];assert math.isfinite(offset) and math.isfinite(scale) and scale>=0
            decoded[:,joint,channel]=offset
            if row[1]&(1<<channel):decoded[:,joint,channel]+=frames[:,cursor]*float(scale);cursor+=1
    assert cursor==h['num_channels'] and np.all(np.linalg.norm(decoded[:,:,3:7],axis=2)>0)
    bounds=np.frombuffer(block(h['ofs_bounds'],h['num_frames']*32,'bounds'),dtype='<f4').reshape(-1,8)
    assert np.all(np.isfinite(bounds)) and np.all(bounds[:,:3]<=bounds[:,3:6]) and np.all(bounds[:,6:]>=0)
    ordered=sorted(spans)
    assert all(a[1]<=b[0] for a,b in zip(ordered,ordered[1:])),ordered
    md3=baseline.read_bytes();header=struct.unpack_from('<4sI64s9I',md3);surface=struct.unpack_from('<4s64s10I',md3,header[10])
    assert (header[4],surface[5],surface[6])==(h['num_frames'],h['num_vertices'],h['num_triangles'])
    assert triangles.tobytes()==md3[header[10]+surface[7]:header[10]+surface[7]+h['num_triangles']*12]
    assert arrays[1].tobytes()==md3[header[10]+surface[9]:header[10]+surface[9]+h['num_vertices']*8]
    legacy=np.frombuffer(md3,dtype='<i2',count=h['num_frames']*h['num_vertices']*4,offset=header[10]+surface[10]).reshape(h['num_frames'],-1,4)[:,:,:3].astype(np.float64)/64
    invrest=np.linalg.inv(hierarchy(rest,parents));positions=arrays[0].astype(np.float64);weights=arrays[5].astype(np.float64)/255
    depth=[]
    for parent in parents:depth.append(1+depth[parent] if parent>=0 else 1)
    numeric_bound=float(np.finfo(np.float32).eps*max(1,float(np.abs(positions).max()),float(np.abs(rest[:,:3]).max()))*64*(1+max(depth)))
    maximum=0;squared=0;bound_escape=0;worst=None
    for number in range(h['num_frames']):
        transforms=np.matmul(hierarchy(decoded[number],parents),invrest);points=np.zeros_like(positions)
        for influence in range(4):
            selected=transforms[arrays[4][:,influence]]
            transformed=np.einsum('nij,nj->ni',selected[:,:3,:3],positions)+selected[:,:3,3]
            points+=transformed*weights[:,influence,None]
        errors=np.linalg.norm(points-legacy[number],axis=1);index=int(np.argmax(errors))
        if float(errors[index])>maximum:maximum=float(errors[index]);worst={'frame':number,'vertex':index}
        squared+=float(np.sum(errors**2));bound_escape=max(bound_escape,float((bounds[number,:3]-points.min(axis=0)).max()),float((points.max(axis=0)-bounds[number,3:6]).max()))
    assert bound_escape<=numeric_bound,(path.name,bound_escape,numeric_bound)
    assert abs(maximum-expected['max_md3_distance'])<=numeric_bound,(path.name,maximum,expected['max_md3_distance'],numeric_bound)
    return {'vertices':h['num_vertices'],'triangles':h['num_triangles'],'bones':names,'parents':parents,'frames':h['num_frames'],'frame_channels':h['num_channels'],
      'mesh':string(mesh[0]),'material':string(mesh[1]),'max_rest_normal_length_error':float(np.max(np.abs(np.linalg.norm(arrays[2],axis=1)-1))),
      'independent_max_md3_distance':maximum,'independent_rms_md3_distance':math.sqrt(squared/(h['num_frames']*h['num_vertices'])),
      'worst_md3':worst,'max_bound_escape':bound_escape,'float32_arithmetic_comparison_bound':numeric_bound,'sampled_vertex_checks':h['num_frames']*h['num_vertices']}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate',type=Path,required=True);parser.add_argument('--repeat',type=Path);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();candidate=args.candidate.resolve(strict=True)
    cfg=json.loads((ROOT/'assets/source/art/iqm_assessment_834/DESIGN.json').read_text(encoding='utf-8'))
    manifest=json.loads((candidate/'manifest.json').read_text(encoding='utf-8'))
    assert manifest['source_sha256']==digest(ROOT/cfg['source_blend'])==cfg['source_sha256']
    assert manifest['config_sha256']==digest(ROOT/'assets/source/art/iqm_assessment_834/DESIGN.json')
    assert manifest['generator_sha256']==digest(ROOT/'assets/generators/export_modular_iqm.py')
    groups=json.loads((ROOT/cfg['module_config']).read_text(encoding='utf-8'));report={'issue':834,'errors':[],'modules':{},'repeat_files':{}}
    for name,h in manifest['sha256'].items():assert digest(candidate/name)==h,name
    for key,expected in manifest['modules'].items():
        baseline=ROOT/'src'/groups['module_path']/(key+'.md3');assert digest(baseline)==expected['md3_sha256']
        result=inspect(candidate/cfg['model_path']/(key+'.iqm'),expected,baseline)
        assert result['mesh']==key and result['material']==cfg['skin'] and result['bones']==manifest['bones'] and result['parents']==manifest['parents']
        report['modules'][key]=result
    if args.repeat:
        paths=[p for p in candidate.rglob('*') if p.is_file()]
        assert {p.relative_to(candidate).as_posix() for p in paths}=={p.relative_to(args.repeat).as_posix() for p in args.repeat.rglob('*') if p.is_file()}
        for path in paths:
            name=path.relative_to(candidate).as_posix();assert path.read_bytes()==(args.repeat/name).read_bytes();report['repeat_files'][name]=digest(path)
    report['sampled_vertex_checks']=sum(r['sampled_vertex_checks'] for r in report['modules'].values())
    report['qualification']='Independent float64 reconstruction checks serialized geometry, hierarchy, weights and frames. The reported float32 comparison bound is 64 operations per hierarchy level times machine epsilon and coordinate magnitude; it addresses arithmetic reconstruction differences only, not visual acceptance or a permitted deformation change. Source-pipeline and encoding differences remain in the Blender export report. Native rendering/interpolation and author review are separate.'
    args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'errors':[],'modules':len(report['modules']),'sampled_vertex_checks':report['sampled_vertex_checks'],'repeated_files':len(report['repeat_files'])}))

if __name__=='__main__':main()
