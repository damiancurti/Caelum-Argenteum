"""Durable campaign checkpoints and staged personal transfers (#434).

Only registered current checkpoints may be launched by the session adapter.
Drafts are verification inputs, never published campaign heads. Both native
results must be verified before one SQLite transaction changes profile custody.
"""
from __future__ import annotations

import argparse
import copy
import io
import json
from pathlib import Path
import uuid
import zipfile

from caelum_profiles import ProfileError, ProfileStore, validate_anchor, recover_backup
from caelum_profile_graph import NativeSchema, PersonalGraph
from migrate_arena_save import migrate as migrate_arena_rules


def unpack(data: bytes) -> tuple[dict[str, bytes], str, dict]:
    validate_anchor(data, 0)
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        members = {name: archive.read(name) for name in archive.namelist()}
    info = json.loads(members['info.json'])
    if info.get('Save Version') != 4560:
        raise ProfileError('Unsupported native save version; original retained.')
    name = info['Current Map'].lower() + '.map.json'
    return members, name, json.loads(members[name])


def pack(members: dict[str, bytes], name: str, level: dict) -> bytes:
    result = io.BytesIO()
    with zipfile.ZipFile(result, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
        for member, data in members.items():
            entry = zipfile.ZipInfo(member, (1980, 1, 1, 0, 0, 0))
            entry.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(entry, json.dumps(level, separators=(',', ':')).encode()
                             if member == name else data)
    return result.getvalue()


def personal_record(level: dict, slot: int) -> dict:
    if not 0 <= slot < len(level['players']):
        raise ProfileError('Character slot is not present in this checkpoint.')
    owner = level['players'][slot]['mo']
    cursor = level['objects'][owner].get('inventory')
    records, seen = [], set()
    while cursor is not None:
        if isinstance(cursor, bool) or not isinstance(cursor, int) or not 0 <= cursor < len(level['objects']) or cursor in seen:
            raise ProfileError('Invalid native inventory chain.')
        seen.add(cursor)
        obj = level['objects'][cursor]
        if obj.get('class:Inventory', {}).get('Owner') != owner:
            raise ProfileError('Inventory belongs to another native body.')
        if obj['classtype'] == 'CaelumPersistentCharacterState':
            records.append(obj['class:CaelumPersistentCharacterState'])
        cursor = obj.get('inventory')
    if len(records) != 1:
        raise ProfileError('Character requires exactly one initialized personal record.')
    return records[0]


class Campaigns:
    def __init__(self, store: ProfileStore, adapter: PersonalGraph):
        self.store, self.adapter = store, adapter
        self.db = store.connection

    def head(self, campaign: str) -> dict:
        row = self.db.execute('SELECT * FROM campaigns WHERE identity=?', (campaign,)).fetchone()
        if row is None:
            raise ProfileError('Unknown campaign; no replacement world was created.')
        return dict(row)

    def unlocked(self, campaign: str, token: str | None = None) -> None:
        row = self.db.execute('SELECT token FROM campaign_locks WHERE campaign=?', (campaign,)).fetchone()
        if row is not None and row[0] != token:
            raise ProfileError('Campaign is reserved by another session or transfer.')

    def register(self, campaign: str, data: bytes) -> dict:
        """Register an existing world once, stamping stable IDs on its records."""
        self.store._key(campaign, 'campaign identity')
        original_data = data
        try:
            data = migrate_arena_rules(data)
        except (ValueError, KeyError, zipfile.BadZipFile) as exc:
            raise ProfileError(f'Cannot migrate the native checkpoint: {exc}') from exc
        members, name, level = unpack(data)
        with self.store.transaction():
            if self.db.execute('SELECT 1 FROM campaigns WHERE identity=?', (campaign,)).fetchone():
                raise ProfileError('Campaign already registered; use its current checkpoint.')
            original = self.store._snapshot(original_data, 0)
            self.db.execute('INSERT INTO campaigns VALUES (?,0,?)', (campaign, original))
            enrolled = []
            for slot, player in enumerate(level['players']):
                if player.get('class') != 'CaelumPlayer':
                    raise ProfileError('Every native session slot must have a Caelum character.')
                record = personal_record(level, slot)
                if record.get('ExternalProfileId') or record.get('ProfileDeparted'):
                    raise ProfileError('Already managed characters cannot be enrolled into a second world.')
                if not record.get('ProfileCommitted'):
                    continue
                self.adapter.capture(level, slot)
                identity = str(uuid.uuid4())
                origin = json.dumps([campaign, slot], separators=(',', ':'))
                self.db.execute('INSERT INTO profiles VALUES (?,?,?,0,?,?,?)',
                                (identity, player.get('playername') or 'Character', campaign, original, slot, origin))
                record.update(ExternalProfileId=identity, ExternalProfileRevision=0,
                              ExternalProfileCampaign=campaign, ProfileDeparted=0)
                self.db.execute('INSERT INTO campaign_slots VALUES (?,?,?)', (campaign, slot, identity))
                enrolled.append(identity)
            stamped = self.store._snapshot(pack(members, name, level), 0)
            self.db.execute('UPDATE campaigns SET snapshot=? WHERE identity=?', (stamped, campaign))
            for identity in enrolled:
                self.db.execute('UPDATE profiles SET snapshot=? WHERE identity=?', (stamped, identity))
            return self.head(campaign)

    def validate(self, campaign: str, data: bytes, *, current: bool = False) -> dict:
        """Check native identities against custody, never player display names."""
        head = self.head(campaign)
        if current and validate_anchor(data, 0) != head['snapshot']:
            raise ProfileError('Stale campaign checkpoint; recover through the registered current head.')
        _, _, level = unpack(data)
        expected = {r['player']: r['identity'] for r in self.db.execute(
            'SELECT player,identity FROM campaign_slots WHERE campaign=?', (campaign,))}
        seen = set()
        for slot in range(len(level['players'])):
            record = personal_record(level, slot)
            if slot not in expected:
                if record.get('ProfileCommitted') and not record.get('ProfileDeparted'):
                    raise ProfileError('Checkpoint contains an unregistered character.')
                continue
            identity = expected[slot]
            profile = self.store.get(identity)
            if identity in seen or profile.campaign != campaign or profile.player != slot:
                raise ProfileError('Character is assigned to another active campaign/slot.')
            if (record.get('ExternalProfileId') != identity or record.get('ExternalProfileCampaign') != campaign
                    or record.get('ExternalProfileRevision') != profile.revision or record.get('ProfileDeparted')):
                raise ProfileError('Native profile identity/revision does not match current custody.')
            self.adapter.capture(level, slot)
            seen.add(identity)
        if len(seen) != len(expected):
            raise ProfileError('Checkpoint is missing an assigned character.')
        return level

    def checkpoint(self, campaign: str, data: bytes, expected_revision: int, *, lease: str | None = None) -> dict:
        with self.store.transaction():
            self.unlocked(campaign, lease)
            if self.head(campaign)['revision'] != expected_revision:
                raise ProfileError('The campaign advanced; old sessions cannot overwrite its checkpoint.')
            self.validate(campaign, data)
            digest = self.store._snapshot(data, 0)
            self.db.execute('UPDATE campaigns SET revision=revision+1,snapshot=? WHERE identity=?', (digest, campaign))
            self.db.execute('UPDATE profiles SET snapshot=? WHERE campaign=?', (digest, campaign))
            return self.head(campaign)

    def stage(self, identity: str, destination: str, slot: int, token: str) -> dict:
        self.store._key(token, 'transfer token')
        with self.store.transaction():
            old = self.db.execute('SELECT * FROM transfers WHERE token=?', (token,)).fetchone()
            if old is not None:
                request = json.loads(old['request'])
                if (request['identity'], request['destination'], request['slot']) != (identity, destination, slot):
                    raise ProfileError('Transfer token belongs to another request.')
                return dict(old)
            profile = self.store.get(identity)
            if profile.campaign == destination:
                raise ProfileError('Transfer requires two distinct campaigns.')
            source_head, target_head = self.head(profile.campaign), self.head(destination)
            self.unlocked(profile.campaign); self.unlocked(destination)
            source_data = self.store.anchor(source_head['snapshot'])
            target_data = self.store.anchor(target_head['snapshot'])
            source_level = self.validate(profile.campaign, source_data, current=True)
            target_level = self.validate(destination, target_data, current=True)
            target_record = personal_record(target_level, slot)
            if target_record.get('ProfileCommitted') and not target_record.get('ProfileDeparted'):
                raise ProfileError('Destination slot is occupied; move its character first.')
            self.adapter.transfer_ready(source_level, profile.player)
            graph = self.adapter.capture(source_level, profile.player)
            retired = self.adapter.retire(source_level, profile.player, identity)
            # A departed native slot is empty, even if another identity used it.
            target_record['ProfileCommitted'] = 0
            installed = self.adapter.install(target_level, graph, slot, identity, profile.revision + 1)
            personal_record(installed, slot)['ExternalProfileCampaign'] = destination
            source_members, source_name, _ = unpack(source_data)
            target_members, target_name, _ = unpack(target_data)
            source_digest = self.store._snapshot(pack(source_members, source_name, retired), 0)
            target_digest = self.store._snapshot(pack(target_members, target_name, installed), 0)
            request = dict(identity=identity, source=profile.campaign, destination=destination,
                           source_slot=profile.player, slot=slot, profile_revision=profile.revision,
                           source_head=source_head, destination_head=target_head,
                           packages=self.adapter.schema.packages)
            self.db.execute('INSERT INTO transfers VALUES (?,?,?,?,NULL)',
                            (token, json.dumps(request, sort_keys=True), source_digest, target_digest))
            for campaign in (profile.campaign, destination):
                self.db.execute('INSERT INTO campaign_locks VALUES (?,?)', (campaign, token))
            return dict(self.db.execute('SELECT * FROM transfers WHERE token=?', (token,)).fetchone())

    def finish(self, token: str, source_data: bytes, destination_data: bytes) -> dict:
        """Atomically publish both engine-verified results and the single owner."""
        source_digest, target_digest = validate_anchor(source_data, 0), validate_anchor(destination_data, 0)
        with self.store.transaction():
            row = self.db.execute('SELECT * FROM transfers WHERE token=?', (token,)).fetchone()
            if row is None:
                raise ProfileError('Unknown pending transfer.')
            if row['result'] is not None:
                result = json.loads(row['result'])
                if result.get('cancelled'):
                    raise ProfileError('Cancelled transfers cannot be published.')
                if result['source_snapshot'] != source_digest or result['destination_snapshot'] != target_digest:
                    raise ProfileError('Completed transfer cannot publish different checkpoints.')
                return result
            request = json.loads(row['request'])
            if request['packages'] != self.adapter.schema.packages:
                raise ProfileError('Transfer requires the exact verification packages.')
            for key in ('source', 'destination'):
                self.unlocked(request[key], token)
                if self.head(request[key]) != request[key + '_head']:
                    raise ProfileError('Campaign changed during transfer; originals remain available.')
            profile = self.store.get(request['identity'])
            if profile.revision != request['profile_revision'] or profile.campaign != request['source']:
                raise ProfileError('Profile custody changed during transfer.')
            _, _, source = unpack(source_data)
            _, _, destination = unpack(destination_data)
            departed = personal_record(source, request['source_slot'])
            imported = personal_record(destination, request['slot'])
            if not departed.get('ProfileDeparted') or departed.get('ExternalProfileId') != profile.identity:
                raise ProfileError('Source character has not departed.')
            source_body = source['players'][request['source_slot']]['mo']
            cursor = source['objects'][source_body].get('inventory')
            while cursor is not None:
                obj = source['objects'][cursor]
                if self.adapter.personal_item(obj) and obj['classtype'] != 'CaelumPersistentCharacterState':
                    raise ProfileError('Source still owns transferred material inventory.')
                cursor = obj.get('inventory')
            serial = profile.revision + 2
            if (imported.get('ExternalProfileId') != profile.identity
                    or imported.get('ExternalProfileCampaign') != request['destination']
                    or imported.get('ExternalProfileRevision') != profile.revision + 1
                    or imported.get('ProfileImportApplied') != serial
                    or imported.get('ProfileImportSerial') != serial or imported.get('ProfileDeparted')):
                raise ProfileError('Destination has not completed native import reconciliation.')
            self.adapter.capture(destination, request['slot'])
            self.store._snapshot(source_data, 0); self.store._snapshot(destination_data, 0)
            self.db.execute('DELETE FROM campaign_slots WHERE campaign=? AND player=?', (profile.campaign, profile.player))
            self.db.execute('INSERT INTO campaign_slots VALUES (?,?,?)',
                            (request['destination'], request['slot'], profile.identity))
            self.db.execute('UPDATE profiles SET campaign=?,revision=revision+1,snapshot=?,player=? WHERE identity=?',
                            (request['destination'], target_digest, request['slot'], profile.identity))
            for campaign, digest in ((request['source'], source_digest), (request['destination'], target_digest)):
                self.db.execute('UPDATE campaigns SET revision=revision+1,snapshot=? WHERE identity=?', (digest, campaign))
                self.db.execute('UPDATE profiles SET snapshot=? WHERE campaign=?', (digest, campaign))
                self.db.execute('DELETE FROM campaign_locks WHERE campaign=? AND token=?', (campaign, token))
            # Validate every other participant too, inside the same rollback boundary.
            self.validate(request['source'], source_data)
            self.validate(request['destination'], destination_data)
            result = dict(identity=profile.identity, campaign=request['destination'], revision=profile.revision + 1,
                          source_snapshot=source_digest, destination_snapshot=target_digest)
            self.db.execute('UPDATE transfers SET result=? WHERE token=?', (json.dumps(result, sort_keys=True), token))
            return result

    def cancel(self, token: str) -> None:
        """Release a draft without changing any original campaign/profile head."""
        with self.store.transaction():
            row = self.db.execute('SELECT result FROM transfers WHERE token=?', (token,)).fetchone()
            if row is None or row['result'] is not None:
                raise ProfileError('Only an unfinished transfer may be cancelled.')
            self.db.execute('DELETE FROM campaign_locks WHERE token=?', (token,))
            self.db.execute('UPDATE transfers SET result=? WHERE token=?', ('{"cancelled":true}', token))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--store', type=Path, required=True)
    parser.add_argument('--engine-package', type=Path, required=True)
    parser.add_argument('--runtime', type=Path, required=True)
    sub = parser.add_subparsers(dest='command', required=True)
    sub.add_parser('create')
    backup = sub.add_parser('backup'); backup.add_argument('output', type=Path)
    recover = sub.add_parser('recover'); recover.add_argument('backup', type=Path)
    register = sub.add_parser('register'); register.add_argument('campaign'); register.add_argument('save', type=Path)
    sub.add_parser('list')
    export = sub.add_parser('export'); export.add_argument('campaign'); export.add_argument('output', type=Path)
    stage = sub.add_parser('stage'); stage.add_argument('identity'); stage.add_argument('destination'); stage.add_argument('slot', type=int); stage.add_argument('token')
    drafts = sub.add_parser('drafts'); drafts.add_argument('token'); drafts.add_argument('directory', type=Path)
    finish = sub.add_parser('finish'); finish.add_argument('token'); finish.add_argument('source', type=Path); finish.add_argument('destination', type=Path)
    cancel = sub.add_parser('cancel'); cancel.add_argument('token')
    check = sub.add_parser('checkpoint'); check.add_argument('campaign'); check.add_argument('revision', type=int); check.add_argument('save', type=Path)
    args = parser.parse_args()
    if args.command == 'recover':
        recover_backup(args.backup,args.store)
        print(json.dumps({'recovered':str(args.store),'source_retained':str(args.backup)},indent=2))
        return
    store = ProfileStore(args.store, create=args.command == 'create')
    try:
        campaigns = Campaigns(store, PersonalGraph(NativeSchema(args.engine_package, args.runtime)))
        if args.command == 'create': result = {'created': str(store.path)}
        elif args.command == 'backup': store.backup(args.output); result = {'backup':str(args.output)}
        elif args.command == 'register': result = campaigns.register(args.campaign, args.save.read_bytes())
        elif args.command == 'list': result = {'campaigns': [dict(r) for r in store.connection.execute('SELECT * FROM campaigns')],
                                               'profiles': [dict(r) for r in store.connection.execute('SELECT identity,name,campaign,revision,player FROM profiles')]}
        elif args.command == 'export':
            campaigns.unlocked(args.campaign); head = campaigns.head(args.campaign)
            campaigns.validate(args.campaign, store.anchor(head['snapshot']), current=True)
            store.export_anchor(head['snapshot'], args.output); result = head
        elif args.command == 'stage': result = campaigns.stage(args.identity, args.destination, args.slot, args.token)
        elif args.command == 'drafts':
            row = store.connection.execute('SELECT * FROM transfers WHERE token=?', (args.token,)).fetchone()
            if row is None or row['result'] is not None: raise ProfileError('No unfinished transfer for this token.')
            args.directory.mkdir(parents=True, exist_ok=False)
            for side in ('source', 'destination'): store.export_anchor(row[side + '_draft'], args.directory / (side + '.zds'))
            result = {'verification_drafts': str(args.directory)}
        elif args.command == 'finish': result = campaigns.finish(args.token, args.source.read_bytes(), args.destination.read_bytes())
        elif args.command == 'cancel': campaigns.cancel(args.token); result = {'cancelled': args.token}
        else: result = campaigns.checkpoint(args.campaign, args.save.read_bytes(), args.revision)
        print(json.dumps(result, indent=2))
    finally:
        store.close()


if __name__ == '__main__':
    try: main()
    except (ProfileError, OSError, ValueError, zipfile.BadZipFile) as exc:
        raise SystemExit(f'Profile operation refused: {exc}')
