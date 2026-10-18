"""Run the focused door-lifecycle and existing vehicle controls sequentially."""
from pathlib import Path
import argparse,subprocess
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--suffix',default='02');parser.add_argument('--start',default='controls')
    options=parser.parse_args()
    cases=[('controls',['--lifecycle','controls']),('pending',['--lifecycle','pending','--hold']),
        ('arrival',['--lifecycle','arrival']),('interrupt',['--lifecycle','interrupt']),
        ('newgame',['--lifecycle','newgame']),('ship',['--vehicle','4']),('cart',['--vehicle','3']),
        ('ship-house',['--vehicle','4','--early']),('cart-house',['--vehicle','3','--early'])]
    cases=cases[[x[0] for x in cases].index(options.start):]
    for label,args in cases:
        folder='issue334-final-'+label+options.suffix
        subprocess.run(['python',str(HERE/'prepare.py'),'--directory',folder,*args],cwd=ROOT,check=True)
        command=['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(ROOT/'assets/validation_5422/run_native.ps1'),
            '-Directory',folder,'-Label',label,'-Runtime','baseline.pk3','-Fixture','city.pk3','-Script','probe.cfg']
        command+=['-Map','TCOAST'] if '--vehicle' in args else ['-LoadGame','author.zds','-Map','CAH008']
        subprocess.run(command,cwd=ROOT,check=True)
        print('PASSED',label,flush=True)
if __name__=='__main__':main()
