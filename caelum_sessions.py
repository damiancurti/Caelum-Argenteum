"""Coordinated native session manifests, leases and recovery (#435).

The registry uses the profile database transaction, so a running session and a
cross-campaign transfer cannot both own the same world. Native peers still use
GZDoom lockstep; this tool is not a game server or an authentication service.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import secrets
import sqlite3
import subprocess
import uuid
import zipfile
import ctypes
import time

from caelum_profiles import ProfileStore, ProfileError
from caelum_profile_graph import NativeSchema, PersonalGraph
from caelum_campaigns import Campaigns, personal_record, unpack


def digest(path: Path) -> str:
    with path.open('rb') as stream:
        return hashlib.file_digest(stream,'sha256').hexdigest()


def require_native_sync(level: dict) -> None:
    """Never publish a native checkpoint that already records desynchronization."""
    if any(player.get('inconsistant',0)!=0 for player in level['players']):
        raise ProfileError('The native save records desynchronization; retain it for diagnosis and recover the last synchronized common checkpoint.')


def manifest(engine: Path, iwad: Path, packages: list[Path]) -> dict:
    """Pin binary, engine resources, IWAD and every explicit package in order."""
    paths=[engine,engine.parent/'gzdoom.pk3',engine.parent/'game_support.pk3',
           engine.parent/'game_widescreen_gfx.pk3',iwad,*packages]
    if not packages:raise ProfileError('A complete Caelum runtime package is required.')
    return dict(revision=1,files=[dict(path=str(p.resolve(strict=True)),sha256=digest(p)) for p in paths],
                explicit_packages=len(packages))


def verify_manifest(expected: dict, engine: Path, iwad: Path, packages: list[Path]) -> None:
    actual=manifest(engine,iwad,packages)
    if (expected.get('revision')!=1 or expected.get('explicit_packages')!=len(packages)
            or [f['sha256'] for f in expected.get('files',[])]!=[f['sha256'] for f in actual['files']]):
        raise ProfileError('Engine, IWAD, package bytes or package order differ; session not started.')


def write_new(path: Path, data: bytes) -> None:
    with path.open('xb') as stream:
        stream.write(data);stream.flush();os.fsync(stream.fileno())


def process_stamp(pid: int) -> int | None:
    """Use creation time as well as PID; reused Windows PIDs are not this session."""
    kernel=ctypes.WinDLL('kernel32',use_last_error=True)
    kernel.OpenProcess.restype=ctypes.c_void_p
    kernel.GetProcessTimes.argtypes=[ctypes.c_void_p,*([ctypes.c_void_p]*4)]
    kernel.GetExitCodeProcess.argtypes=[ctypes.c_void_p,ctypes.c_void_p]
    kernel.CloseHandle.argtypes=[ctypes.c_void_p]
    handle=kernel.OpenProcess(0x1000,False,pid)
    if not handle:
        if ctypes.get_last_error() in (87,1168):return None
        raise ProfileError('Cannot establish whether the recorded native process still runs.')
    try:
        code=ctypes.c_ulong()
        if not kernel.GetExitCodeProcess(handle,ctypes.byref(code)):raise ProfileError('Cannot read process state.')
        if code.value!=259:return None
        values=[ctypes.c_ulonglong() for _ in range(4)]
        if not kernel.GetProcessTimes(handle,*[ctypes.byref(v) for v in values]):raise ProfileError('Cannot read process creation time.')
        return values[0].value
    finally:kernel.CloseHandle(handle)


class Sessions:
    def __init__(self, campaigns: Campaigns):
        self.campaigns=campaigns;self.store=campaigns.store;self.db=self.store.connection
        exists=self.db.execute("SELECT 1 FROM sqlite_master WHERE name='network_session_schema'").fetchone()
        if not exists:
            backup=self.store.path.with_name(self.store.path.name+'.sessions-backup-'+str(uuid.uuid4()))
            write_new(backup,b'');target=sqlite3.connect(backup)
            try:self.db.backup(target)
            finally:target.close()
            with self.store.transaction():
                self.db.execute('CREATE TABLE IF NOT EXISTS network_session_schema (revision INTEGER NOT NULL)')
                if not self.db.execute('SELECT revision FROM network_session_schema').fetchone():
                    self.db.execute('INSERT INTO network_session_schema VALUES (1)')
                self.db.execute('CREATE TABLE IF NOT EXISTS network_sessions (token TEXT PRIMARY KEY, request TEXT NOT NULL, result TEXT)')
                self.db.execute('CREATE TABLE IF NOT EXISTS network_session_launches (token TEXT NOT NULL, slot INTEGER NOT NULL, pid INTEGER NOT NULL, stamp INTEGER NOT NULL, finished INTEGER NOT NULL DEFAULT 0, PRIMARY KEY(token,slot))')
        rows=self.db.execute('SELECT revision FROM network_session_schema').fetchall()
        if len(rows)!=1 or rows[0][0]!=1:raise ProfileError('Unsupported session registry; original retained.')

    def get(self,token: str) -> dict:
        row=self.db.execute('SELECT * FROM network_sessions WHERE token=?',(token,)).fetchone()
        if row is None:raise ProfileError('Unknown session token.')
        return dict(token=token,request=json.loads(row['request']),result=json.loads(row['result']) if row['result'] else None)

    def lease(self,campaign: str,token: str) -> None:
        row=self.db.execute('SELECT token FROM campaign_locks WHERE campaign=?',(campaign,)).fetchone()
        if row is None or row[0]!=token:raise ProfileError('The session no longer holds campaign custody.')

    def prepare(self,campaign: str,files: dict,token: str) -> dict:
        self.store._key(token,'session token')
        with self.store.transaction():
            if self.db.execute('SELECT 1 FROM network_sessions WHERE token=?',(token,)).fetchone():
                previous=self.get(token)
                if previous['request']['campaign']!=campaign or previous['request']['manifest']!=files:
                    raise ProfileError('Session token belongs to another request.')
                if any(r['identity'].startswith('vacant:') for r in previous['request']['roster']):
                    raise ProfileError('Fill every native slot before playing this fixed-roster campaign.')
                return previous
            self.campaigns.unlocked(campaign)
            head=self.campaigns.head(campaign);data=self.store.anchor(head['snapshot'])
            level=self.campaigns.validate(campaign,data,current=True)
            require_native_sync(level)
            if not 1<=len(level['players'])<=8:raise ProfileError('Native roster must contain one to eight slots.')
            roster=[]
            for slot in range(len(level['players'])):
                record=personal_record(level,slot)
                if record.get('ExternalProfileCampaign')!=campaign:raise ProfileError('Initialize/import every native slot before managed launch.')
                if record.get('ProfileDeparted') or not record.get('ProfileCommitted') or not record.get('ExternalProfileId'):
                    raise ProfileError('Fill every native slot before playing this fixed-roster campaign.')
                roster.append(dict(slot=slot,identity=record['ExternalProfileId'],
                                   name=level['players'][slot].get('playername','Character')))
            request=dict(revision=1,campaign=campaign,head=head,manifest=files,roster=roster,nonce=secrets.randbelow(2147483646)+1)
            self.db.execute('INSERT INTO network_sessions VALUES (?,?,NULL)',(token,json.dumps(request,sort_keys=True)))
            self.db.execute('INSERT INTO campaign_locks VALUES (?,?)',(campaign,token))
            return self.get(token)

    def export(self,token: str,directory: Path) -> None:
        session=self.get(token)
        if session['result'] is not None:raise ProfileError('Closed sessions cannot be launched again.')
        directory.mkdir(parents=True,exist_ok=False)
        request=session['request'];data=self.store.anchor(request['head']['snapshot'])
        write_new(directory/'recovery.zds',data)
        write_new(directory/'session.json',(json.dumps(session,indent=2)+'\n').encode())

    def publish(self,token: str,data: bytes,expected_revision: int) -> dict:
        with self.store.transaction():
            session=self.get(token)
            if session['result'] is not None:raise ProfileError('Session is closed; late saves cannot overwrite recovery.')
            campaign=session['request']['campaign'];self.lease(campaign,token)
            head=self.campaigns.head(campaign)
            if head['revision']!=expected_revision:raise ProfileError('Checkpoint revision advanced; late write rejected.')
            level=self.campaigns.validate(campaign,data)
            require_native_sync(level)
            snapshot=self.store._snapshot(data,0)
            if snapshot!=head['snapshot']:
                self.db.execute('UPDATE campaigns SET revision=revision+1,snapshot=? WHERE identity=?',(snapshot,campaign))
                self.db.execute('UPDATE profiles SET snapshot=? WHERE campaign=?',(snapshot,campaign))
            return self.campaigns.head(campaign)

    def claim(self,token: str,slot: int) -> None:
        with self.store.transaction():
            session=self.get(token);request=session['request']
            if session['result'] is not None:raise ProfileError('Closed session cannot restart; prepare a new recovery session.')
            self.lease(request['campaign'],token)
            if self.campaigns.head(request['campaign'])!=request['head']:raise ProfileError('Session advanced; restart from its current recovery head.')
            if not 0<=slot<len(request['roster']):raise ProfileError('Invalid native slot.')
            if self.db.execute('SELECT 1 FROM network_session_launches WHERE token=? AND slot=?',(token,slot)).fetchone():
                raise ProfileError('Slot already launched; recovery requires a new common session.')
            self.db.execute('INSERT INTO network_session_launches VALUES (?,?,?,?,0)',(token,slot,os.getpid(),process_stamp(os.getpid())))

    def attach(self,token: str,slot: int,pid: int) -> None:
        with self.store.transaction():
            stamp=process_stamp(pid)
            if stamp is None:raise ProfileError('Native process ended before session registration.')
            self.db.execute('UPDATE network_session_launches SET pid=?,stamp=? WHERE token=? AND slot=?',(pid,stamp,token,slot))

    def finished(self,token: str,slot: int) -> None:
        with self.store.transaction():
            self.db.execute('UPDATE network_session_launches SET finished=1 WHERE token=? AND slot=?',(token,slot))

    def close(self,token: str) -> dict:
        """End the lease; the most recently published valid checkpoint is recovery."""
        with self.store.transaction():
            session=self.get(token)
            if session['result'] is not None:return session['result']
            for row in self.db.execute('SELECT * FROM network_session_launches WHERE token=? AND finished=0',(token,)):
                if process_stamp(row['pid'])==row['stamp']:raise ProfileError('A recorded process still runs; end it before releasing campaign custody.')
            campaign=session['request']['campaign'];self.lease(campaign,token)
            result=dict(status='closed',recovery=self.campaigns.head(campaign))
            self.db.execute('UPDATE network_sessions SET result=? WHERE token=?',(json.dumps(result),token))
            self.db.execute('DELETE FROM campaign_locks WHERE campaign=? AND token=?',(campaign,token))
            return result


def control_preset(runtime: Path) -> str:
    """Initialize a fresh session INI from the packaged authoritative preset."""
    with zipfile.ZipFile(runtime) as package:
        keyconf=package.read('KEYCONF').decode('utf-8-sig')
    prefix='alias ca_controls_defaults "'
    for line in keyconf.splitlines():
        if line.startswith(prefix) and line.endswith('"'):
            # Startup exec runs before KEYCONF aliases are installed; expand the
            # preset instead of invoking an alias that is not defined yet.
            return line[len(prefix):-1]+'\n'
    raise ProfileError('Runtime is missing its generated control preset.')


def command(bundle: Path,slot: int,engine: Path,iwad: Path,packages: list[Path],port: int,host: str,*,verification: bool=False) -> tuple[list[str],Path]:
    """Prepare one native process. Joining order is checked by the runtime gate."""
    session=json.loads((bundle/'session.json').read_text(encoding='utf-8'));request=session['request']
    if session.get('result') is not None:raise ProfileError('Closed session bundle.')
    verify_manifest(request['manifest'],engine,iwad,packages)
    roster=request['roster']
    if not verification and any(r['identity'].startswith('vacant:') for r in roster):
        raise ProfileError('Vacant peers are only supported during isolated transfer verification; fill every slot before playing.')
    if isinstance(slot,bool) or not 0<=slot<len(roster):raise ProfileError('Unknown native player slot.')
    data=(bundle/'recovery.zds').read_bytes()
    if hashlib.sha256(data).hexdigest()!=request['head']['snapshot']:raise ProfileError('Common recovery checkpoint does not match manifest.')
    peer=bundle/f'peer{slot}';peer.mkdir(exist_ok=False)
    write_new(peer/'recovery.zds',data)
    identity=roster[slot]['identity']
    if not all(c in 'abcdefghijklmnopqrstuvwxyz0123456789-:' for c in identity):raise ProfileError('Invalid stored profile identifier.')
    ini='[GlobalSettings]\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\n'
    write_new(peer/'session.ini',ini.encode())
    # Nonpersistent local CVars are inputs, validated against the synchronized native
    # slot/record before any managed character accepts gameplay mutations.
    cfg=f'ca_session_profile "{identity}"\nca_session_slot {slot}\nca_session_nonce {request["nonce"]}\n'+control_preset(packages[0])
    write_new(peer/'start.cfg',cfg.encode())
    network=[] if len(roster)==1 else ['-host',str(len(roster)),'-port',str(port),'-netmode','0'] if slot==0 else ['-join',f'{host}:{port}','-port',str(port+slot)]
    cmd=[str(engine.resolve()),'-noautoload','-iwad',str(iwad.resolve()),'-file',*[str(p.resolve()) for p in packages],
         '-config',str((peer/'session.ini').resolve()),'-savedir',str(peer.resolve()),*network,
         '+logfile',str((peer/'engine.log').resolve()),'-loadgame','recovery.zds','+exec',str((peer/'start.cfg').resolve())]
    write_new(peer/'command.json',(json.dumps(cmd,indent=2)+'\n').encode())
    return cmd,peer


def watch(process,peer: Path,sessions: Sessions | None,token: str,slot: int) -> int:
    """Publish only complete host checkpoints after the native roster agrees."""
    seen={};published={};ready=False;rejected=False;log_offset=0;log_tail=''
    session=sessions.get(token) if sessions else None
    nonce=session['request']['nonce'] if session else 0
    while True:
        ended=process.poll() is not None
        if sessions and slot==0:
            path=peer/'engine.log';log=''
            if path.exists():
                if path.stat().st_size<log_offset:log_offset=0;log_tail=''
                with path.open('rb') as stream:
                    stream.seek(log_offset);chunk=stream.read();log_offset=stream.tell()
                log=log_tail+chunk.decode('utf-8',errors='replace')
                # Retain an incomplete trailing line without rereading the log.
                split=log.rfind('\n');log_tail=log[split+1:];log=log[:split+1]
            ready=ready or f'CA_SESSION READY peer=0 nonce={nonce}' in log
            rejected=rejected or 'CA_SESSION REJECT' in log
            if ready and not rejected:
                for save in sorted(peer.glob('*.zds'),key=lambda p:p.stat().st_mtime_ns):
                    if save.name=='recovery.zds':continue
                    stat=save.stat();fingerprint=(stat.st_mtime_ns,stat.st_size)
                    stable=seen.get(save.name)==fingerprint;seen[save.name]=fingerprint
                    if published.get(save.name)==fingerprint or not (stable or ended):continue
                    try:
                        head=sessions.campaigns.head(session['request']['campaign'])
                        result=sessions.publish(token,save.read_bytes(),head['revision'])
                        with (peer/'checkpoints.jsonl').open('a',encoding='utf-8') as stream:
                            stream.write(json.dumps(dict(file=save.name,head=result))+'\n')
                        published[save.name]=fingerprint
                    except (ProfileError,zipfile.BadZipFile,OSError,KeyError) as exc:
                        # A partial write or departed roster cannot replace the
                        # last valid common checkpoint. Retain the native file.
                        if ended:
                            with (peer/'checkpoint-errors.log').open('a',encoding='utf-8') as stream:stream.write(f'{save.name}: {exc}\n')
        if ended:return process.returncode
        time.sleep(.5)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--store',type=Path)
    parser.add_argument('--engine',type=Path,required=True)
    parser.add_argument('--iwad',type=Path,required=True)
    parser.add_argument('--package',type=Path,action='append',required=True)
    sub=parser.add_subparsers(dest='action',required=True)
    p=sub.add_parser('prepare');p.add_argument('campaign');p.add_argument('directory',type=Path)
    p=sub.add_parser('start');p.add_argument('directory',type=Path);p.add_argument('--slot',type=int,required=True);p.add_argument('--port',type=int,default=5029);p.add_argument('--host',default='127.0.0.1')
    p=sub.add_parser('publish');p.add_argument('token');p.add_argument('save',type=Path);p.add_argument('--revision',type=int,required=True)
    p=sub.add_parser('close');p.add_argument('token')
    args=parser.parse_args()
    if args.action=='start':
        session=json.loads((args.directory/'session.json').read_text(encoding='utf-8'))
        if args.slot==0 and args.store is None:parser.error('The native host requires --store to hold and verify campaign custody')
        store=ProfileStore(args.store) if args.store else None
        sessions=Sessions(Campaigns(store,PersonalGraph(NativeSchema(args.engine.parent/'gzdoom.pk3',args.package[0])))) if store else None
        cmd,peer=command(args.directory.resolve(),args.slot,args.engine,args.iwad,args.package,args.port,args.host)
        if sessions:sessions.claim(session['token'],args.slot)
        # An explicitly requested interactive game window remains visible.
        process=None
        try:
            process=subprocess.Popen(cmd,cwd=peer)
            if sessions:sessions.attach(session['token'],args.slot,process.pid)
            write_new(peer/'process.json',json.dumps(dict(pid=process.pid)).encode())
            code=watch(process,peer,sessions,session['token'],args.slot)
        finally:
            if sessions and (process is None or process.poll() is not None):sessions.finished(session['token'],args.slot)
            if store:store.close()
        raise SystemExit(code)
    if args.store is None:parser.error('--store is required for coordinated campaign operations')
    store=ProfileStore(args.store)
    try:
        adapter=PersonalGraph(NativeSchema(args.engine.parent/'gzdoom.pk3',args.package[0]))
        sessions=Sessions(Campaigns(store,adapter))
        if args.action=='prepare':
            token=str(uuid.uuid4());result=sessions.prepare(args.campaign,manifest(args.engine,args.iwad,args.package),token);sessions.export(token,args.directory)
        elif args.action=='publish':
            verify_manifest(sessions.get(args.token)['request']['manifest'],args.engine,args.iwad,args.package)
            result=sessions.publish(args.token,args.save.read_bytes(),args.revision)
        else:result=sessions.close(args.token)
        print(json.dumps(result,indent=2))
    finally:store.close()


if __name__=='__main__':main()
