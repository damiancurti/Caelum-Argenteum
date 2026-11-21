#875 / 5.17.116 — private native sewer vault proposal

Current scope, decisions and full results are in docs/ASSETS.md, HISTORY.md,
SYSTEMS.md, MAP01.txt and TASKS.md. This folder is reproducible evidence, not a
second status authority. The candidate is not author accepted or the default map.

From the repository root, use fresh build folders for every invocation:

python assets/generators/build_sewer_structure_review.py --runtime build/caelum_argenteum_dev.pk3 --output build/vault-review-new --brick
python assets/validation_v5_17_116/prepare_cameras.py --planes build/vault-review-new/planes.json --output build/vault-cameras-new.json
python assets/validation_v5_17_116/run_native.py --runtime build/caelum_argenteum_dev.pk3 --overlay build/vault-review-new/candidate.pk3 --output build/vault-native-new --hub
python assets/validation_v5_17_116/run_vault_views.py --cameras build/vault-cameras-new.json --runtime build/caelum_argenteum_dev.pk3 --overlay build/vault-review-new/candidate.pk3 --output build/vault-views-new

run_scene.py runs one performance viewpoint at a time. Supply --label (unique),
--runtime, --map MAP02 and --presentation-layer pointing to the separately built
Vulkan diagnostic layer. Add --overlay for the candidate and --camera
main_horizontal or service with --cameras for an interior view. Omitting --camera
uses the retained entrance observer. Do not overlap engine runs or heavy builds,
hashing and validation with a performance window. Queue presents are not scanout.

Only at the requested final consolidated author session:
python assets/validation_v5_17_116/run_review.py --runtime build/caelum_argenteum_dev.pk3 --overlay build/vault-review-new/candidate.pk3 --output build/vault-author-new --interactive

F1 cycles the nine diagnostic viewpoints. Move normally between them and use
native save/load in this disposable directory. Do not load a campaign save into
the raised-roof proposal. Close the candidate and launch the default runtime in
its own session to compare unchanged revision6. This is not save migration.

Evidence layout:
- builds: original/superseded, final and repeated candidate inventories/indexes.
- native: preliminary and final candidate fresh/reload/hub runs, plus a separate
  restored-default fresh/reload pair. Native checkpoint/hub files remain local.
- views: final paired logs, exact fixture, commands and twenty inspected PNGs.
- fixture-failures: original EventHandler Spawn compile error and diagnostic
  collision failures. They are retained and excluded from passing totals.
- performance: eight sequential native windows and original presentation traces;
  the first candidate entrance is explicitly the superseded global-alias build.
- determinism, observed-state comparison and runtime comparison: exact checks.

The view fixture temporarily disables only an actual blocking rat/Mandinga's
solidity during its synchronous proxy-cylinder geometry check, records it and
restores it before returning. Both final runs clear/restore one rat. These steps
are not ordinary player movement or escort-AI acceptance. Initial local body1
reuse and the missing Actor qualifier were fixture defects, not production bugs.

The immutable measured runtime is 5.17.115; final 5.17.116 differs only in two
release diagnostic labels. Final candidate native/save checks and restored-default
checks use the actual 5.17.116 package. build_review_gallery.py regenerates the
source-folder gallery without modifying any images.

Engine, IWAD, PK3/WAD and save binaries are intentionally absent. Keep all earlier
pending author checks. No merge, issue closure, author acceptance or completed
batch is implied by this evidence.
