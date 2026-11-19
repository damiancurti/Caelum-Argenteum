"""Build the private CPU-call timing layer; never replace an installed engine/layer."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiler',type=Path,required=True)
    parser.add_argument('--headers',type=Path,required=True,help='Pinned GZDoom4.14.2 libraries/ZVulkan/include')
    parser.add_argument('--output',type=Path,required=True,help='New private build directory')
    args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
    source=Path(__file__).with_name('presentation_layer.cpp').resolve();compiler=args.compiler.resolve(strict=True)
    library=out/'ca_presentation.dll'
    command=[str(compiler),'-std=c++17','-O2','-shared','-static','-static-libgcc','-static-libstdc++','-Wl,--no-insert-timestamp','-I'+str(args.headers.resolve(strict=True)),str(source),'-o',str(library)]
    environment=os.environ.copy();environment['PATH']=str(compiler.parent)+os.pathsep+environment.get('PATH','')
    subprocess.run(command,env=environment,check=True)
    manifest={'file_format_version':'1.1.2','layer':{'name':'VK_LAYER_CA_presentation','type':'GLOBAL','library_path':'.\\ca_presentation.dll','api_version':'1.3.0','implementation_version':'1','description':'Private Caelum CPU API/presentation trace; no GPU-time or scanout claim'}}
    (out/'ca_presentation.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    (out/'build.json').write_text(json.dumps({'command':command,'source_sha256':digest(source),'compiler_sha256':digest(compiler),'binary_sha256':digest(library),'qualification':'Enable only in explicit diagnostic child processes. Selected API durations >=1ms plus all intercepted creation/allocation calls. Original queue trace retained. No installed file/configuration changed.'},indent=2)+'\n',encoding='utf-8')
    print(out)

if __name__=='__main__':main()
