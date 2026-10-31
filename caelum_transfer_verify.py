"""Reconcile reserved profile transfers with the real native session identity gate.

Both copied worlds must load, acknowledge their exact roster and produce a native
checkpoint before the existing atomic custody transaction can publish anything.
No diagnostic character setup, test map or gameplay grants are loaded.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import secrets
import subprocess
import sys
import time
import zipfile

from caelum_profiles import ProfileStore, ProfileError, validate_anchor
from caelum_profile_graph import NativeSchema, PersonalGraph
from caelum_campaigns import Campaigns, unpack, personal_record
from caelum_sessions import manifest, command, write_new


def verification_overlay(path: Path) -> None:
    source=Path(__file__).parent/'assets/profiles/verification.zs'
    entries={'MAPINFO':b'gameinfo { AddEventHandlers="CaelumTransferVerification" }\n',
             'ZSCRIPT':b'version "4.14.2"\n#include "verification.zs"\n',
             'verification.zs':source.read_bytes()}
    with zipfile.ZipFile(path,'x',compression=zipfile.ZIP_DEFLATED) as archive:
        for name,data in entries.items():
            item=zipfile.ZipInfo(name,(1980,1,1,0,0,0));item.compress_type=zipfile.ZIP_DEFLATED
            archive.writestr(item,data)


def native_checkpoint(data: bytes, campaign: str, directory: Path, engine: Path,
                      iwad: Path, packages: list[Path], port: int) -> tuple[bytes,dict]:
    """Run only this isolated roster, retain every input/log, never edit originals."""
    _,_,level=unpack(data)
    if not 1<=len(level['players'])<=8:raise ProfileError('Unsupported native transfer roster.')
    roster=[]
    for slot in range(len(level['players'])):
        record=personal_record(level,slot)
        if record.get('ExternalProfileCampaign')!=campaign:
            raise ProfileError('Every verification slot must have a registered or departed identity.')
        roster.append(dict(slot=slot,identity=f'vacant:{slot}' if record.get('ProfileDeparted') else record['ExternalProfileId']))
    directory.mkdir(parents=True,exist_ok=False)
    overlay=directory/'verification.pk3';verification_overlay(overlay)
    files=[*packages,overlay];nonce=secrets.randbelow(2147483646)+1
    request=dict(campaign=campaign,manifest=manifest(engine,iwad,files),roster=roster,
                 nonce=nonce,head=dict(snapshot=hashlib.sha256(data).hexdigest()))
    write_new(directory/'recovery.zds',data)
    write_new(directory/'session.json',(json.dumps(dict(request=request,result=None),indent=2)+'\n').encode())
    processes=[];streams=[];peers=[];commands=[];result=None
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    try:
        for slot in range(len(roster)):
            cmd,peer=command(directory,slot,engine,iwad,files,port,'127.0.0.1',verification=True)
            # The command-line window hint alone can still start fullscreen.
            # Only this isolated verifier pins its private window configuration.
            with (peer/'session.ini').open('a') as config:
                config.write('vid_fullscreen=false\nvid_defwidth=640\nvid_defheight=480\nwin_w=656\nwin_h=519\n')
            cmd+=['-window','-width','640','-height','480']
            streams.append((peer/'process.log').open('wb'));peers.append(peer);commands.append(cmd)
            processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=streams[-1],stderr=streams[-1]))
            time.sleep(.4)
        deadline=time.monotonic()+120;last=None
        while time.monotonic()<deadline:
            logs=[(p/'engine.log').read_text(errors='replace') if (p/'engine.log').exists() else '' for p in peers]
            if any(any(mark in log for mark in ('CA_SESSION REJECT','Execution could not continue','VM execution aborted','Script error','out of sync','desync','This savegame needs these files','Savegame is from a different level')) for log in logs):
                raise ProfileError(f'Native verification failed; retained evidence: {directory}')
            if any(p.poll() is not None for p in processes):raise ProfileError(f'A verification peer exited early: {directory}')
            ready=all(f'CA_SESSION READY peer={i} nonce={nonce}' in log and f'CA_PROFILE VERIFIED peer={i}' in log for i,log in enumerate(logs))
            saves=list(peers[0].glob('save*.zds'))
            if ready and len(saves)==1:
                stat=saves[0].stat();fingerprint=(stat.st_size,stat.st_mtime_ns)
                if fingerprint==last:
                    output=saves[0].read_bytes();validate_anchor(output,0)
                    result=dict(campaign=campaign,players=len(roster),commands=commands,
                                output=str(saves[0]),snapshot=hashlib.sha256(output).hexdigest(),passed=True)
                    write_new(directory/'verified.json',(json.dumps(result,indent=2)+'\n').encode())
                    return output,result
                last=fingerprint
            time.sleep(.25)
        raise ProfileError(f'Native verification timed out; original campaign heads remain intact: {directory}')
    finally:
        # These are only the child processes created above, never an author's game.
        failure=sys.exc_info()[1]
        observed=[dict(slot=i,pid=p.pid,exit_code=p.poll()) for i,p in enumerate(processes)]
        for process in processes:
            if process.poll() is None:process.terminate()
        for process in processes:process.wait(timeout=15)
        for stream in streams:stream.close()
        if result is None:
            write_new(directory/'failure.json',(json.dumps(dict(campaign=campaign,commands=commands,
                observed_before_cleanup=observed,error=str(failure) if failure else None,
                passed=False),indent=2)+'\n').encode())


def verify_transfer(campaigns: Campaigns, token: str, directory: Path,
                    engine: Path, iwad: Path, packages: list[Path], port: int=30635) -> dict:
    row=campaigns.db.execute('SELECT * FROM transfers WHERE token=?',(token,)).fetchone()
    if row is None or row['result'] is not None:raise ProfileError('Only a pending transfer can be verified.')
    request=json.loads(row['request'])
    if request['packages']!=campaigns.adapter.schema.packages:raise ProfileError('Transfer runtime differs from its staged package.')
    for side in ('source','destination'):
        campaigns.unlocked(request[side],token)
        if campaigns.head(request[side])!=request[side+'_head']:raise ProfileError('A reserved campaign head changed.')
    directory.mkdir(parents=True,exist_ok=False);outputs={};reports=[]
    for side in ('source','destination'):
        outputs[side],report=native_checkpoint(campaigns.store.anchor(row[side+'_draft']),request[side],
                                               directory/side,engine,iwad,packages,port)
        reports.append(report)
    # finish rechecks both reservations and revisions inside its SQLite transaction.
    published=campaigns.finish(token,outputs['source'],outputs['destination'])
    result=dict(token=token,native=reports,published=published)
    write_new(directory/'result.json',(json.dumps(result,indent=2)+'\n').encode())
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--store',type=Path,required=True)
    parser.add_argument('--engine',type=Path,required=True)
    parser.add_argument('--iwad',type=Path,required=True)
    parser.add_argument('--package',type=Path,action='append',required=True)
    parser.add_argument('--port',type=int,default=30635)
    parser.add_argument('token');parser.add_argument('directory',type=Path)
    args=parser.parse_args();store=ProfileStore(args.store)
    try:
        adapter=PersonalGraph(NativeSchema(args.engine.parent/'gzdoom.pk3',args.package[0]))
        result=verify_transfer(Campaigns(store,adapter),args.token,args.directory.resolve(),
                               args.engine.resolve(),args.iwad.resolve(),[p.resolve() for p in args.package],args.port)
        print(json.dumps(result,indent=2))
    finally:store.close()


if __name__=='__main__':main()
