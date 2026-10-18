"""Reject truncated multi-map evidence even when an early native DONE passed."""
from pathlib import Path
import argparse
import re
from archive import completed_case

ROOT=Path(__file__).resolve().parents[2]

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',required=True)
    parser.add_argument('--port-directory',help='Optional separately retained port retry using the identical runtime/save.')
    args=parser.parse_args()
    for name in (args.directory,args.port_directory or args.directory):
        if not re.fullmatch(r'issue322-[a-z0-9_-]+',name):parser.error('Expected issue322 directory')
    folder=ROOT/'build'/args.directory
    for label in ('campaign','port-roundtrip'):
        source=ROOT/'build'/args.port_directory if label=='port-roundtrip' and args.port_directory else folder
        log=(source/(label+'.txt')).read_text(encoding='utf-8')
        count=len(re.findall(r'^CA282 PASS ',log,re.M))
        assert completed_case(label,log,count),(label,'complete native log rejected')
        first=re.search(r'^CA282 DONE[^\n]*',log,re.M)
        assert first is not None
        truncated=log[:first.end()]
        early_count=len(re.findall(r'^CA282 PASS ',truncated,re.M))
        assert not completed_case(label,truncated,early_count),(label,'early DONE accepted')
        assert not completed_case(label,log,count-1),(label,'wrong assertion count accepted')
    print('Evidence gate: 2 complete multi-map logs accepted; 4 truncation/count controls rejected.')

if __name__=='__main__':main()
