"""Check durable custody, crash rollback and exact native anchor preservation."""
from concurrent.futures import ThreadPoolExecutor
import datetime
import hashlib
import json
from pathlib import Path
import sqlite3
import sys
import threading
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from caelum_profiles import APPLICATION_ID, ProfileError, ProfileStore, validate_anchor

ANCHOR = Path(sys.argv[1]).resolve()
DATA = ANCHOR.read_bytes()
ORIGINAL_DIGEST = hashlib.sha256(DATA).hexdigest()
RUN = ROOT / "build/issue434" / datetime.datetime.now().strftime("store-%Y%m%d-%H%M%S")
RUN.mkdir(parents=True)
sys.argv[1:] = []


class StoreTests(unittest.TestCase):
    def setUp(self):
        self.directory = RUN / self._testMethodName
        self.directory.mkdir()
        self.path = self.directory / "profiles.sqlite3"
        self.store = ProfileStore(self.path, create=True)
        self.profile = self.store.enroll(DATA, 0, "campaign-a", "Native fixture")

    def tearDown(self):
        self.store.close()

    def commit(self, **overrides):
        params = dict(expected_revision=0, source_campaign="campaign-a", destination_campaign="campaign-b",
                      data=DATA, player=0, token="transfer-1")
        params.update(overrides)
        return self.store.commit(self.profile.identity, **params)

    def test_native_bytes_and_duplicate_enrollment(self):
        self.assertEqual(validate_anchor(DATA, 0), ORIGINAL_DIGEST)
        self.assertEqual(self.store.anchor(self.profile.snapshot), DATA)
        self.assertEqual(self.store.enroll(DATA, 0, "campaign-a", "Another label"), self.profile)
        self.assertEqual(self.store.connection.execute("SELECT COUNT(*) FROM profiles").fetchone()[0], 1)

    def test_transfer_idempotence_and_stale_owner(self):
        changed = self.commit()
        self.assertEqual((changed.campaign, changed.revision), ("campaign-b", 1))
        self.assertEqual(self.commit(), changed)
        with self.assertRaises(ProfileError):
            self.commit(token="duplicate-transfer")
        self.assertEqual(self.store.get(self.profile.identity), changed)
        self.assertEqual(self.store.anchor(self.profile.snapshot), DATA)

    def test_token_cannot_authorize_another_destination(self):
        changed = self.commit()
        with self.assertRaises(ProfileError):
            self.commit(destination_campaign="campaign-c")
        self.assertEqual(self.store.get(self.profile.identity), changed)

    def test_two_connections_cannot_both_transfer_one_revision(self):
        barrier = threading.Barrier(2)
        identity = self.profile.identity

        def transfer(destination):
            local = ProfileStore(self.path)
            try:
                before = local.get(identity)
                barrier.wait(timeout=10)
                try:
                    local.commit(identity, expected_revision=before.revision, source_campaign=before.campaign,
                                 destination_campaign=destination, data=DATA, player=0, token=destination)
                    return "committed"
                except ProfileError:
                    return "rejected"
            finally:
                local.close()

        with ThreadPoolExecutor(max_workers=2) as pool:
            results = list(pool.map(transfer, ["campaign-b", "campaign-c"]))
        self.assertCountEqual(results, ["committed", "rejected"])
        self.assertEqual(self.store.get(identity).revision, 1)

    def test_transaction_interruption_preserves_owner(self):
        with self.assertRaises(RuntimeError):
            with self.store.transaction():
                self.store.connection.execute("UPDATE profiles SET campaign='uncommitted'")
                raise RuntimeError("Simulated interruption before commit")
        self.assertEqual(self.store.get(self.profile.identity), self.profile)

    def test_corrupt_anchor_does_not_advance_revision(self):
        with self.assertRaises(ProfileError):
            self.commit(data=b"broken save")
        with self.assertRaises(ProfileError):
            self.commit(player=7)
        self.assertEqual(self.store.get(self.profile.identity), self.profile)
        self.assertEqual(self.store.connection.execute("SELECT COUNT(*) FROM operations").fetchone()[0], 0)

    def test_reopen_and_restore_leave_original_untouched(self):
        changed = self.commit()
        other = ProfileStore(self.path)
        try:
            self.assertEqual(other.get(self.profile.identity), changed)
            target = self.directory / "recovered.zds"
            other.export_anchor(self.profile.snapshot, target)
            self.assertEqual(target.read_bytes(), DATA)
            with self.assertRaises(FileExistsError):
                other.export_anchor(self.profile.snapshot, target)
        finally:
            other.close()
        self.assertEqual(hashlib.sha256(ANCHOR.read_bytes()).hexdigest(), ORIGINAL_DIGEST)

    def test_missing_corrupt_and_future_stores_fail_without_reset(self):
        missing = self.directory / "missing.sqlite3"
        with self.assertRaises(ProfileError):
            ProfileStore(missing)
        self.assertFalse(missing.exists())
        corrupt = self.directory / "corrupt.sqlite3"
        corrupt.write_bytes(b"preserve this corrupt evidence")
        with self.assertRaises(ProfileError):
            ProfileStore(corrupt)
        self.assertEqual(corrupt.read_bytes(), b"preserve this corrupt evidence")
        future = self.directory / "future.sqlite3"
        db = sqlite3.connect(future)
        db.execute(f"PRAGMA application_id={APPLICATION_ID}")
        db.execute("PRAGMA user_version=999")
        db.close()
        before = future.read_bytes()
        with self.assertRaises(ProfileError):
            ProfileStore(future)
        self.assertEqual(future.read_bytes(), before)


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(StoreTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    (RUN / "results.json").write_text(json.dumps({
        "issue": 434, "scope": "external custody store only; no native transfer claim",
        "native_anchor": str(ANCHOR), "anchor_sha256": ORIGINAL_DIGEST,
        "tests": result.testsRun, "failures": len(result.failures), "errors": len(result.errors),
        "source_unchanged": hashlib.sha256(ANCHOR.read_bytes()).hexdigest() == ORIGINAL_DIGEST,
    }, indent=2) + "\n", encoding="utf-8", newline="\n")
    raise SystemExit(not result.wasSuccessful())
