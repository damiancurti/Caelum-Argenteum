"""Exercise the same lab events as its keys; retain native screenshots and logs."""
from pathlib import Path
import subprocess
import sys
import argparse
import re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue428/manual'
parser=argparse.ArgumentParser()
parser.add_argument('--only',choices=('vision','noise','memory','orders'))
parser.add_argument('--label',default='manual-final')
args=parser.parse_args()
subprocess.run([sys.executable, str(HERE / 'prepare_manual.py')], cwd=ROOT, check=True)


def capture(name):
    return f'screenshot "{(OUT / (args.label + "-" + name + ".png")).as_posix()}"; wait 2'


cases = [
    ('vision', 'netevent ca510_mode 1; wait 90; netevent ca510_report; '
     'netevent ca510_turn; wait 5; netevent ca510_report; netevent ca510_return; wait 80; '
     'netevent ca510_report; netevent ca510_light; wait 10; netevent ca510_report; ' + capture('vision-dark')),
    ('noise', 'netevent ca510_mode 2; wait 2; netevent ca510_noise; wait 40; '
     'netevent ca510_hide; wait 100; netevent ca510_report; ' + capture('noise-point')),
    ('memory', 'netevent ca510_mode 3; wait 140; netevent ca510_report; netevent ca510_hide; '
     'wait 80; netevent ca510_report; netevent ca510_return; wait 12; netevent ca510_report; '
     + capture('memory-return') + '; netevent ca510_hide; wait 1090; netevent ca510_report; '
     'netevent ca510_return; wait 12; netevent ca510_report; wait 75; netevent ca510_report; ' + capture('memory-expired-return')),
    ('orders', 'netevent ca510_mode 4; wait 180; netevent ca510_report; ' + capture('orders-near') +
     '; netevent ca510_hide; wait 180; netevent ca510_report; ' + capture('orders-far') +
     '; netevent ca510_return; wait 180; netevent ca510_report; ' + capture('orders-return')),
]
for label, commands in cases:
    if args.only and args.only!=label:continue
    subprocess.run([sys.executable, str(HERE / 'run_native.py'), args.label + '-' + label,
        '--full', '--package', 'build/issue428/final/caelum_argenteum_dev.pk3',
        '--checks', str(OUT / 'manual.pk3'), '--prefix', 'CA510', '--map', 'CA510L',
        '--commands', commands], cwd=ROOT, check=True)
    log=(OUT.parent/(args.label+'-'+label+'.log')).read_text(encoding='utf-8')
    actor='receptor' if label=='orders' else 'observador'
    states=[int(x) for x in re.findall(r'CA510 '+actor+r' sospecha=[\d.]+ identificado=(\d)',log)]
    expected={'vision':[1,0,1,0],'noise':[0],'memory':[1,0,1,0,0,1],'orders':[1,0,1]}[label]
    if states!=expected:raise SystemExit(f'Lab event sequence differs: {label}: {states} != {expected}')
    print(f'Lab event sequence verified: {label}: {states}',flush=True)
print('Native lab scenarios completed; inspect reports and images separately.')
