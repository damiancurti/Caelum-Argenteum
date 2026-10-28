"""Build deterministic aim fixtures; compare analytic estimates with quadrature."""
from pathlib import Path
import argparse,importlib.util,math,random,subprocess,sys,zipfile
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue415-aim';WORK.mkdir(parents=True,exist_ok=True)
p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');args=p.parse_args()
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
room=module('room',ROOT/'assets/validation_588/prepare.py').room()
wad=module('wad',ROOT/'assets/validation_580/prepare.py').wad
def package(path,items):
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for n,d in sorted(items.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),d)
# Independent midpoint quadrature over actual conditional rectangular overlap.
def numeric(bounds,lo,hi):
    def probability(s):
        if not s:return float(bounds[0]<=0<=bounds[1] and bounds[2]<=0<=bounds[3])
        x=max(0,min(bounds[1],s)-max(bounds[0],-s))
        y=max(0,min(bounds[3],s)-max(bounds[2],-s))
        return x*y/(4*s*s)
    if hi==lo:return probability(lo)
    n=50000
    return sum(probability(lo+(i+.5)*(hi-lo)/n) for i in range(n))/n
rng=random.Random(415)
cases=[((-1,1,-1,1),0,10),((-1,1,-1,1),1,10),((-2,4,-3,7),1,9),((-10,10,-10,10),1,10),((1,2,3,4),0,10)]
for _ in range(45):
    x=sorted((rng.uniform(-15,15),rng.uniform(-15,15)))
    y=sorted((rng.uniform(-15,15),rng.uniform(-15,15)))
    lo=rng.choice((0,1,3,5));hi=rng.choice((lo,10,20))
    cases.append(((*x,*y),lo,hi))
lines=[]
for i,(bounds,lo,hi) in enumerate(cases):
    values=','.join(format(v,'.17g') for v in (*bounds,lo,hi))
    lines.append(f'Check(Near(CaelumMeanAim.CarbineRectangle({values}),{numeric(bounds,lo,hi):.17g},0.000002),"independent quadrature {i}");')
math_source=(HERE/'math.zs').read_text(encoding='utf-8').replace('// QUADRATURE', '\n'.join(lines))
base={'ZSCRIPT':b'version "4.14"\n#include "common.zs"\n', 'common.zs':(HERE/'common.zs').read_bytes(),
      'MAPINFO':b'GameInfo {AddEventHandlers="CA415AimChecks"}\ncluster 8539 {hub}\nmap AIM415 "Mean aim" {cluster=8539}\nmap AIM415B "Away" {cluster=8539}\n',
      'maps/AIM415.wad':wad(room,'AIM415'),'maps/AIM415B.wad':wad(room,'AIM415B')}
package(WORK/'prior-checks.pk3',base)
current=dict(base);current['ZSCRIPT']+=b'#include "math.zs"\n';current['math.zs']=math_source.encode()
current['MAPINFO']=current['MAPINFO'].replace(b'CA415AimChecks',b'CA415MeanChecks')
package(WORK/'checks.pk3',current)
(WORK/'bridge').mkdir(exist_ok=True)
# Original handler remains registered when an original save is reopened.
package(WORK/'bridge/prior-checks.pk3',current)
commands={'math':'netevent ca415a_math','native':'netevent ca415a_prepare; wait 3; netevent ca415a_native',
 'mixed':'netevent ca415a_prepare; wait 3; netevent ca415a_math; netevent ca415a_native',
 'seed':'netevent ca415a_prepare; wait 3; netevent ca415a_native; save aim-current39',
 'load':'netevent ca415a_saved','legacy':'netevent ca415a_saved','oldseed':'netevent ca415a_prepare; wait 3; netevent ca415a_native; save aim-prior38',
 'hub':'netevent ca415a_prepare; wait 3; netevent ca415a_native; changemap AIM415B; wait 70; changemap AIM415; wait 3; netevent ca415a_saved'}
for name,text in commands.items():(WORK/(name+'.cfg')).write_text('wait 105; '+text+'; wait 3; quit\n',encoding='utf-8')
if args.probe:
    prior=ROOT.parent/'issue502-npc-illness-work/build/issue502-npc-illness/final38a/caelum_argenteum_dev.pk3'
    changed=set(subprocess.check_output(['git','diff','--name-only','47fa8dc3','--','src'],cwd=ROOT,text=True).splitlines())
    changed.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).splitlines())
    changed={n[4:] for n in changed if (ROOT/n).is_file()};(WORK/'probe').mkdir(exist_ok=True)
    with zipfile.ZipFile(prior) as old,zipfile.ZipFile(WORK/'probe/caelum_argenteum_dev.pk3','w',zipfile.ZIP_STORED) as z:
        for n in sorted(set(old.namelist())|changed):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),(ROOT/'src'/n).read_bytes() if n in changed else old.read(n))
print('Prepared 50 independent quadrature cases and native shot/persistence fixtures.')
