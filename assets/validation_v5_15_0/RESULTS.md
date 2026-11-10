# Issue #447 - Dynamic battle director

The author approved the scenario and defeat rule on 2026-11-09. Manual
acceptance CA447-01 remains pending. Tests here belong only to #447.

Native environment: Windows, installed GZDoom 4.14.2, Vulkan, the local
development Doom II IWAD; no engine/IWAD/generated fixture is distributed.
Runners use isolated configuration/saves, unpaused background execution and
5% audio. Package/engine/fixture hashes, exact commands and frame-time tails
are retained in [results.json](results.json); [native-logs.txt.gz](native-logs.txt.gz)
preserves native logs. Private saves, maps and full presentation traces remain
under build/v515/issue447. Scoped awake requests were released after testing.

Observed during implementation:

- compile-01: eight initial-state checks passed; clean engine exit.
- restore-01: fixture error, missing exit-node roster; retained native abort.
  Only the fixture was corrected to supply all six entry/exit identities.
- checkpoint-02 and restore-02: two actual lockstep peers passed 21 checks
  each across the saved checkpoint, without native sync errors. The final
  finite arrival, terminal defeat with a surviving player, eleven-machine
  non-victory and twelve-machine/confirmed living Zupay retreat were checked.
- catchup-01: elapsed-world scheduling consumed the last reserve once and
  resumed native ownership; repeating the same boundary did not replay it.
- legacy-source-01 / legacy-migration-01: a save made with the original
  V5.14 package loaded with the new implementation under the saved basename;
  all five migration checks passed. Original package and save are retained.

Reviewed package: issue447-reviewed.pk3, SHA256
`d7d0620bd6e5703aef471d500933bac24adc034d96dc636b4a095b4136ff96dc`.

- reviewed-checkpoint / reviewed-restored: 21 passing checks per actual peer
  across a common native save; synchronization clean on both peers.
- reviewed-catchup: 11 checks passed, including the final finite arrival and
  repeated calendar boundary. reviewed-legacy: five old-save migration checks
  passed. original-rollback: two checks passed with original V5.14 bytes/save.
- reviewed-travel-isolated: both actual peers passed the twelve checks across
  a native hub departure/return. Exact defender identities, prior casualty,
  finite budget and deadline persist. The earlier unprotected travel fixtures
  lost their final defender to actual offscreen combat and correctly recorded
  defeat. Diagnostic state is retained; protecting the witness isolates the
  intended persistence assertion. The first travel runner also quit its guest
  before verification; its lifetime was corrected without runtime changes.

Presentation uses actual vkQueuePresentKHR calls on this shared Windows GPU,
not callback counts or monitor scanout. Peaceful front/ground city, mansion,
sewers and the normal staged siege are retained separately. The first director
implementation reduced ground-facing requests to61.17/61.97 per second versus
baseline76.66/74.22. A controlled peaceful-call omission measured71.88; the
production early revision guard recovered74.77 (p95/p99 17.86/19.19ms;
worst39.09ms). CA-KP-214 records the evidence and limits of that attribution.
The pre-guard front view measured94.78 versus89.87 baseline. The unchanged
mansion measured45.74 versus45.27 baseline; sewers168.91. The original active
siege measured1.30 requests/s, with601 defenders and797-898 attackers in the
window, counting the normal staged deployment. The reviewed siege measured1.38
requests/s with the same census (p95/p99/worst783.61/832.54/832.54ms), versus
baseline1.30 (891.45/900.78/900.78ms). Reviewed simulation mean42.55ms,
p95/p99 73.99/78.74ms also remains slower than35tics/s. Full tails are recorded
in results.json; single windows do not establish a general performance gain.

These results do not establish whole-game60FPS, Internet multiplayer or author
acceptance. The baseline mansion and siege remain below the author's target.
Only the director's measured regression was addressed in this issue; no actor,
combat, geometry or visual-feature removal was used as a production shortcut.
Static gate: python validate_project.py; generated documentation/localization
indexes and git diff --check are required for this delivery.

Reproduction entry points:

```powershell
python assets/validation_v5_15_0/run_native.py fresh --runtime build/v515/issue447-reviewed.pk3 --players 2
python assets/validation_v5_15_0/run_native.py restored --runtime build/v515/issue447-reviewed.pk3 --players 2 --load-directory build/v515/issue447/fresh
python assets/validation_v5_15_0/run_native.py catchup --runtime build/v515/issue447-reviewed.pk3 --suite catchup
python assets/validation_v5_15_0/run_native.py travel --runtime build/v515/issue447-reviewed.pk3 --suite travel --players 2
python assets/validation_v5_15_0/run_profile.py presentation --runtime build/v515/issue447-reviewed.pk3 --players 1 --map MAP03 --ground --presentation-layer build/v515/tools/presentation
```

Use a new label for every run; evidence is never overwritten. Saves and
private maps stay in build/. Shared fixture source and sync instrumentation
retain their original ownership; the new assertions do not replace native
sync diagnostics.


## Author acceptance ? 2026-11-10

CA447-01 (origin5.15.0, #447) passed by explicit author confirmation of
all V5.15 tests. The author requested merge/closure; PR635 is merged and
#447 is closed. HISTORY records the acceptance separately from the original
native evidence above. Earlier pending labels describe the delivery state.
This documentation-only acceptance update adds no native/performance measurement;
recorded limitations and the shared laboratory contamination follow-up remain.
