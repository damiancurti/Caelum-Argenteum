"""Build the bounded presentation layer and reproduce the upstream timer defect.

Requires an already extracted official g4.14.2 source tree and MinGW compiler.
No downloads, installation, registry edits, or changes to installed GZDoom.
"""
from pathlib import Path
import argparse,hashlib,json,os,subprocess


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,required=True)
    p.add_argument('--compiler',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();source=a.source.resolve(strict=True);compiler=a.compiler.resolve(strict=True)
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    env=os.environ.copy();env['PATH']=str(compiler.parent)+os.pathsep+env.get('PATH','')
    layer=Path(__file__).with_name('presentation_layer.cpp')
    command=[str(compiler),'-std=c++17','-O2','-shared','-static','-static-libgcc','-static-libstdc++','-Wl,--no-insert-timestamp',
        '-I'+str(source/'libraries/ZVulkan/include'),str(layer),'-o',str(out/'ca_presentation.dll')]
    subprocess.run(command,env=env,check=True)
    (out/'ca_presentation.json').write_text(json.dumps(dict(file_format_version='1.1.2',layer=dict(
        name='VK_LAYER_CA_presentation',type='GLOBAL',library_path='.\\ca_presentation.dll',api_version='1.3.0',
        implementation_version='1',description='Caelum diagnostic QueuePresent timing; no scanout claim')),indent=2)+'\n')
    unit=out/'timer';(unit/'core').mkdir(parents=True);(unit/'window').mkdir()
    timer=(source/'libraries/ZWidget/src/core/timer.cpp').read_text()
    # Accept the pinned release before or after the single documented upstream fix.
    original=timer.replace('Timer::~Timer()\n{\n\tStop();\n\n','Timer::~Timer()\n{\n',1)
    fixed=original.replace('Timer::~Timer()\n{','Timer::~Timer()\n{\n\tStop();',1)
    if original==fixed:raise RuntimeError('Unexpected source: timer destructor not found')
    (unit/'core/timer.h').write_bytes((source/'libraries/ZWidget/include/zwidget/core/timer.h').read_bytes())
    (unit/'core/widget.h').write_text('#pragma once\nclass Timer; class Widget { public: Timer* FirstTimerObj=nullptr; };\n')
    (unit/'window/window.h').write_text('#pragma once\n#include <functional>\n#include <map>\n#include <cstdint>\n'
        'class DisplayWindow { public: static inline std::map<void*,std::function<void()>> Pending; '
        'static inline uintptr_t Next=1; static void* StartTimer(int,std::function<void()> f) '
        '{auto id=(void*)Next++;Pending[id]=f;return id;} static void StopTimer(void* id){Pending.erase(id);} };\n')
    (unit/'main.cpp').write_text('#include "core/timer.h"\n#include "core/widget.h"\n#include "window/window.h"\n#include <cstdio>\n'
        'int main(){Widget owner; auto timer=new Timer(&owner);timer->Start(500);auto before=DisplayWindow::Pending.size();'
        'delete timer;auto after=DisplayWindow::Pending.size();'
        'printf("registered_before=%zu registered_after=%zu owner_empty=%d\\n",before,after,owner.FirstTimerObj==nullptr);'
        'return before==1 && after==0 && owner.FirstTimerObj==nullptr ? 0 : 1;}\n')
    reports=[]
    for label,text,expected in [('original',original,1),('fixed',fixed,0)]:
        cpp=unit/(label+'.cpp');cpp.write_text(text)
        exe=unit/(label+'.exe')
        subprocess.run([str(compiler),'-std=c++17','-static','-Wl,--no-insert-timestamp','-I'+str(unit),str(cpp),str(unit/'main.cpp'),'-o',str(exe)],env=env,check=True)
        result=subprocess.run([str(exe)],capture_output=True,text=True)
        reports.append(dict(variant=label,exit=result.returncode,expected=expected,output=result.stdout,passed=result.returncode==expected))
    files=[compiler,layer,source/'libraries/ZVulkan/include/vulkan/vk_layer.h',out/'ca_presentation.dll']
    result=dict(command=command,files=[dict(path=str(x),sha256=hashlib.sha256(x.read_bytes()).hexdigest()) for x in files],
        timer=reports,qualification='Counts registered callbacks without executing deleted objects. Source lifetime bug only; not proof of every native crash cause.')
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2));raise SystemExit(not all(r['passed'] for r in reports))


if __name__=='__main__':main()
