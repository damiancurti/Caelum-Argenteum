"""Reuse the current campaign census and native presentation observer for #447."""
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]

if __name__=='__main__':
    if len(sys.argv)<2:raise SystemExit('Provide a new run label followed by the shared observer arguments.')
    label=sys.argv.pop(1)
    if Path(label).name!=label:raise SystemExit('Use a simple run label.')
    active=subprocess.check_output(['powershell','-NoProfile','-Command',
        "Get-Process | Where-Object ProcessName -eq 'gzdoom' | Select-Object -ExpandProperty Id"],text=True)
    if active.strip():raise SystemExit('Preserve the current native process before another observation.')
    previous=ROOT/'assets/validation_v5_12_7/run_campaign_profile.py'
    source=previous.read_text(encoding='utf-8')
    old="out=ROOT/'build/issue435'/datetime.datetime.now().strftime('campaign-profile-%Y%m%d-%H%M%S-%f')"
    assert old in source
    source=source.replace(old,"out=ROOT/'build/v515/issue447/performance'/RUN_LABEL",1)
    source=source.replace('report=dict(issue=435,','report=dict(issue=447,',1)
    sys.path.insert(0,str(previous.parent))
    namespace=dict(__file__=str(previous),__name__='ca447_shared_profile',RUN_LABEL=label)
    exec(compile(source,str(previous),'exec'),namespace)
    namespace['main']()
