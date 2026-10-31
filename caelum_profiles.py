"""Transactional profile custody and immutable native recovery anchors (#434).

This module owns external records, not native character serialization. A saved
anchor is retained byte-for-byte; assigning custody does not transplant a body
into another campaign. The game/session adapter must perform and validate that
transfer before committing the new assignment.
"""
from __future__ import annotations

from contextlib import contextmanager
from dataclasses import dataclass
import hashlib
import io
import json
from pathlib import Path
import sqlite3
import uuid
import zipfile

SCHEMA_VERSION = 2
APPLICATION_ID = 0x43415052


class ProfileError(ValueError):
    """Invalid, incompatible, corrupt, or stale profile operation."""


@dataclass(frozen=True)
class Profile:
    identity: str
    name: str
    campaign: str
    revision: int
    snapshot: str
    player: int


def validate_anchor(data: bytes, player: int) -> str:
    """Read the selected native owner without rewriting any save member."""
    if isinstance(player, bool) or not isinstance(player, int) or not 0 <= player < 8:
        raise ProfileError("The native player slot must be between 0 and 7.")
    try:
        with zipfile.ZipFile(io.BytesIO(data)) as archive:
            names = archive.namelist()
            if len(names) != len(set(names)):
                raise ProfileError("The native save contains duplicate members.")
            bad = archive.testzip()
            if bad is not None:
                raise ProfileError(f"Native save checksum failure: {bad}")
            info = json.loads(archive.read("info.json"))
            current = info["Current Map"].lower() + ".map.json"
            level = json.loads(archive.read(current))
            players = level["players"]
            if player >= len(players) or players[player]["class"] != "CaelumPlayer":
                raise ProfileError("The selected slot has no Caelum character.")
            body = players[player]["mo"]
            objects = level["objects"]
            if isinstance(body, bool) or not isinstance(body, int) or not 0 <= body < len(objects):
                raise ProfileError("The selected native body reference is invalid.")
            if objects[body].get("classtype") != "CaelumPlayer":
                raise ProfileError("The selected native body is not a Caelum character.")
    except (KeyError, IndexError, TypeError, json.JSONDecodeError, UnicodeError,
            zipfile.BadZipFile, RuntimeError) as exc:
        raise ProfileError(f"Cannot read the native recovery anchor: {exc}") from exc
    return hashlib.sha256(data).hexdigest()


class ProfileStore:
    """Atomic single-campaign custody with retained snapshot/operation history."""

    def __init__(self, path: Path, *, create: bool = False):
        self.path = Path(path).resolve()
        if not self.path.exists() and not create:
            raise ProfileError("Profile store is missing; no empty replacement was created.")
        if create and self.path.exists():
            raise ProfileError("The requested new profile store already exists.")
        if create:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            # Reserve the pathname exclusively; a competing creator must not
            # initialize a database that another process has already installed.
            with self.path.open("xb"):
                pass
        self.connection = sqlite3.connect(self.path.as_uri() + "?mode=rw", uri=True,
                                          isolation_level=None, timeout=10)
        self.connection.row_factory = sqlite3.Row
        try:
            self.connection.execute("PRAGMA foreign_keys=ON")
            self.connection.execute("PRAGMA synchronous=FULL")
            if create:
                with self.transaction():
                    self.connection.execute(f"PRAGMA application_id={APPLICATION_ID}")
                    self.connection.execute("PRAGMA user_version=1")
                    self.connection.execute("CREATE TABLE snapshots (digest TEXT PRIMARY KEY, native BLOB NOT NULL)")
                    self.connection.execute("""CREATE TABLE profiles (
                        identity TEXT PRIMARY KEY, name TEXT NOT NULL, campaign TEXT NOT NULL,
                        revision INTEGER NOT NULL CHECK(revision >= 0),
                        snapshot TEXT NOT NULL REFERENCES snapshots(digest), player INTEGER NOT NULL,
                        origin TEXT NOT NULL UNIQUE)""")
                    self.connection.execute("""CREATE TABLE operations (
                        token TEXT PRIMARY KEY, request TEXT NOT NULL, result TEXT NOT NULL)""")
            self._upgrade()
            self._check_schema()
        except sqlite3.DatabaseError as exc:
            self.connection.close()
            raise ProfileError("Cannot open the profile store; its contents were not reset.") from exc
        except Exception:
            self.connection.close()
            raise

    def close(self) -> None:
        self.connection.close()

    def backup(self, path: Path) -> None:
        """Export one consistent closed coordinator; never replace a file."""
        # BEGIN IMMEDIATE blocks concurrent custody writers while the readonly
        # connection takes its SQLite snapshot. No gameplay polling is added.
        with self.transaction():
            if self.connection.execute('SELECT 1 FROM campaign_locks LIMIT 1').fetchone():
                raise ProfileError('Close sessions and finish/cancel transfers before backup.')
            recover_backup(self.path, path)

    def _upgrade(self) -> None:
        """Copy the original store before the additive, idempotent v2 upgrade."""
        app = self.connection.execute("PRAGMA application_id").fetchone()[0]
        version = self.connection.execute("PRAGMA user_version").fetchone()[0]
        if app != APPLICATION_ID or version != 1:
            return
        backup = self.path.with_name(self.path.name + ".v1-backup-" + str(uuid.uuid4()))
        with backup.open("xb"):
            pass
        target = sqlite3.connect(backup)
        try:
            self.connection.backup(target)
        finally:
            target.close()
        with self.transaction():
            # Another process may have completed migration while backup ran.
            if self.connection.execute("PRAGMA user_version").fetchone()[0] != 1:
                return
            self.connection.execute("""CREATE TABLE campaigns (
                identity TEXT PRIMARY KEY, revision INTEGER NOT NULL,
                snapshot TEXT NOT NULL REFERENCES snapshots(digest))""")
            self.connection.execute("""CREATE TABLE campaign_slots (
                campaign TEXT NOT NULL REFERENCES campaigns(identity), player INTEGER NOT NULL,
                identity TEXT NOT NULL REFERENCES profiles(identity),
                PRIMARY KEY(campaign,player))""")
            self.connection.execute("""CREATE TABLE transfers (
                token TEXT PRIMARY KEY, request TEXT NOT NULL,
                source_draft TEXT NOT NULL REFERENCES snapshots(digest),
                destination_draft TEXT NOT NULL REFERENCES snapshots(digest),
                result TEXT)""")
            self.connection.execute("""CREATE TABLE campaign_locks (
                campaign TEXT PRIMARY KEY REFERENCES campaigns(identity), token TEXT NOT NULL)""")
            self.connection.execute(f"PRAGMA user_version={SCHEMA_VERSION}")

    def _check_schema(self) -> None:
        try:
            app = self.connection.execute("PRAGMA application_id").fetchone()[0]
            version = self.connection.execute("PRAGMA user_version").fetchone()[0]
            integrity = self.connection.execute("PRAGMA quick_check").fetchone()[0]
            if app != APPLICATION_ID or version != SCHEMA_VERSION or integrity != "ok":
                raise ProfileError("Unsupported or corrupt profile store; preserve it for recovery.")
        except sqlite3.DatabaseError as exc:
            raise ProfileError("Cannot read the profile store; its contents were not reset.") from exc

    @contextmanager
    def transaction(self):
        self.connection.execute("BEGIN IMMEDIATE")
        try:
            yield
            self.connection.execute("COMMIT")
        except BaseException:
            self.connection.execute("ROLLBACK")
            raise

    @staticmethod
    def _key(value: str, label: str) -> str:
        if not isinstance(value, str) or not value.strip() or "\x00" in value:
            raise ProfileError(f"A nonempty {label} is required.")
        return value

    def _snapshot(self, data: bytes, player: int) -> str:
        digest = validate_anchor(data, player)
        row = self.connection.execute("SELECT native FROM snapshots WHERE digest=?", (digest,)).fetchone()
        if row is not None and bytes(row[0]) != data:
            raise ProfileError("The recorded anchor does not match its digest.")
        self.connection.execute("INSERT OR IGNORE INTO snapshots VALUES (?, ?)", (digest, data))
        return digest

    def get(self, identity: str) -> Profile:
        row = self.connection.execute("SELECT identity,name,campaign,revision,snapshot,player FROM profiles WHERE identity=?",
                                      (identity,)).fetchone()
        if row is None:
            raise ProfileError("Unknown character identity.")
        return Profile(**dict(row))

    def enroll(self, data: bytes, player: int, campaign: str, name: str) -> Profile:
        """Enroll one original slot; repeated enrollment returns its same identity."""
        self._key(campaign, "campaign identity")
        self._key(name, "character name")
        with self.transaction():
            digest = self._snapshot(data, player)
            # A newer checkpoint is not a new character. Bind the original slot
            # independently of file bytes; departed slots cannot be re-enrolled.
            origin = json.dumps([campaign, player], separators=(",", ":"))
            old = self.connection.execute("SELECT identity FROM profiles WHERE origin=?", (origin,)).fetchone()
            if old is None:
                legacy = [r for r in self.connection.execute("SELECT identity,origin FROM profiles")
                          if json.loads(r["origin"])[0] == campaign
                          and json.loads(r["origin"])[-1] == player]
                if len(legacy) > 1:
                    raise ProfileError("Legacy slot has multiple identities; recovery must resolve its history.")
                if legacy:
                    old = legacy[0]
            if old is not None:
                return self.get(old[0])
            identity = str(uuid.uuid4())
            self.connection.execute("INSERT INTO profiles VALUES (?, ?, ?, 0, ?, ?, ?)",
                                    (identity, name, campaign, digest, player, origin))
            return self.get(identity)

    def commit(self, identity: str, *, expected_revision: int, source_campaign: str,
               destination_campaign: str, data: bytes, player: int, token: str) -> Profile:
        """Commit a validated native result once; stale owners cannot spend it again."""
        self._key(token, "operation token")
        self._key(destination_campaign, "destination campaign")
        digest = validate_anchor(data, player)
        request = json.dumps([identity, expected_revision, source_campaign,
                              destination_campaign, digest, player], separators=(",", ":"))
        with self.transaction():
            old = self.connection.execute("SELECT request,result FROM operations WHERE token=?", (token,)).fetchone()
            if old is not None:
                if old[0] != request:
                    raise ProfileError("The operation token belongs to a different request.")
                return Profile(**json.loads(old[1]))
            profile = self.get(identity)
            if profile.revision != expected_revision or profile.campaign != source_campaign:
                raise ProfileError("Stale profile revision or campaign owner; transfer rejected.")
            self._snapshot(data, player)
            self.connection.execute("UPDATE profiles SET campaign=?,revision=revision+1,snapshot=?,player=? WHERE identity=?",
                                    (destination_campaign, digest, player, identity))
            result = self.get(identity)
            self.connection.execute("INSERT INTO operations VALUES (?, ?, ?)",
                                    (token, request, json.dumps(result.__dict__, sort_keys=True)))
            return result

    def anchor(self, digest: str) -> bytes:
        row = self.connection.execute("SELECT native FROM snapshots WHERE digest=?", (digest,)).fetchone()
        if row is None:
            raise ProfileError("The recovery anchor is missing.")
        data = bytes(row[0])
        if hashlib.sha256(data).hexdigest() != digest:
            raise ProfileError("The recovery anchor is corrupt.")
        return data

    def export_anchor(self, digest: str, path: Path) -> None:
        """Recover to a new file; never overwrite the user's original save."""
        data = self.anchor(digest)
        with Path(path).open("xb") as stream:
            stream.write(data)
            stream.flush()
            import os
            os.fsync(stream.fileno())


def recover_backup(source: Path, destination: Path) -> None:
    """Recover a whole coordinator to a new path, retaining the original backup.

    Use the restored coordinator in place of the lost one, never alongside an
    older writable copy. All campaign heads roll back together, not one profile.
    """
    source=Path(source).resolve(strict=True);destination=Path(destination).resolve()
    connection=sqlite3.connect(source.as_uri()+'?mode=ro',uri=True,isolation_level=None,timeout=10)
    try:
        connection.execute('BEGIN')
        if (connection.execute('PRAGMA application_id').fetchone()[0]!=APPLICATION_ID
                or connection.execute('PRAGMA user_version').fetchone()[0] not in (1,SCHEMA_VERSION)
                or connection.execute('PRAGMA quick_check').fetchone()[0]!='ok'
                or connection.execute('PRAGMA foreign_key_check').fetchone() is not None):
            raise ProfileError('Unsupported or corrupt backup; original retained.')
        tables={r[0] for r in connection.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        if 'campaign_locks' in tables and connection.execute('SELECT 1 FROM campaign_locks LIMIT 1').fetchone():
            raise ProfileError('Backup has unfinished session/transfer reservations; recover its original workflow first.')
        for digest,data in connection.execute('SELECT digest,native FROM snapshots'):
            if hashlib.sha256(data).hexdigest()!=digest:
                raise ProfileError('Corrupt recovery anchor in backup; nothing was replaced.')
            validate_anchor(data,0)
        with destination.open('xb'):
            pass
        target=sqlite3.connect(destination)
        try:connection.backup(target)
        finally:target.close()
    except sqlite3.DatabaseError as exc:
        raise ProfileError('Cannot read the backup; original retained.') from exc
    finally:
        connection.close()
