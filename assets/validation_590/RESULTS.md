# #418 / 5.9.0 coordination checkpoint

Implemented: composite read-only requirements, compared authoritative quest
writes, and the map-owned encounter registry. Production port narration and
the shared port getter use the registry; side trials retain opt-in activation.
The ten existing entries plus the two requested #422 quests fit 32 saved slots
with eight objectives each. New authored quests/reward types are not delivered
by this checkpoint; #418 remains open.

## Verification

- Static: project validation reports zero errors, dialogue/localization indexes
  are current, generated document index is fresh, and git diff checks pass.
- Native: GZDoom 4.14.2, Windows 11, Ryzen 9 5950X / RTX 3070 Ti, Vulkan,
  background execution unpaused and master volume 5%. The engine reported
  1520x825 rendering despite the requested 1280x720 window (desktop scaling).
- The preserved 5.8.56 package generated `ca418-legacy-02.zds` through actual
  side-quest start/progress/completion and a native reward grant: 9 assertions.
- `final-migration-hub`: 45 PASS / zero FAIL. Loads that old save, verifies
  reward/progress/hidden-objective preservation; tests ALL/ANY and invalid/cyclic
  conditions, failure/abandonment, compared port observations, actor lifecycle,
  registry migration and CA418A -> CA418B -> CA418A travel. The saved encounter
  retains its identity. The runtime contains the final shared port getter.
- `final-city`: 2 PASS / zero FAIL on actual peaceful MAP03. The unsealed port
  controller remains available. Registry has one encounter; the existing
  population owner reported one living combatant in this peaceful arrival.
  The 20 diagnostic repetitions of revision-zero reconstruction cost at most
  **0.2943 ms**. Ten thousand normal registry reads cost **0.0588 ms**; zero
  sealed story encounters were eligible in that peaceful scene.
- Render callbacks in that city sample: 718 observations, mean **16.8255 ms**,
  p95 **20.0451 ms**, p99 **22.3951 ms**, maximum **139.4954 ms**, including
  startup. These are callback gaps, not ETW/display-present measurements; they
  neither establish 60 displayed FPS nor isolate this patch's frame-time gain.
- Author acceptance: pending the complete V5.9 manual suite. No acceptance or
  new story completion is inferred from these diagnostic passes.

The migration census is a narrow exception: once per map/revision when an old
save has no registry, owned by CaelumSiegeEvents, rebuilt from native encounter
actors. Subsequent spawn/destruction callbacks maintain it. The measured bound
is one campaign encounter on MAP03; no repeated whole-population query is used
by normal narration or the shared port lookup. This does not authorize a new
per-tic census or replace the >=500 combatant policy.

## Reproduction and retained evidence

Build normally to `build/issue418/current/caelum_argenteum_dev.pk3`, then run
`python assets/validation_590/prepare.py`. Its baseline path expects the root
checkout's accepted 5.8.56 build; it preserves an existing local baseline.
Run `run_native.py` with a unique label and the commands recorded in each JSON
record. It rejects overlapping engine processes and missing input saves; native
`-loadgame` receives the basename relative to `-savedir`.

`evidence.json` and the retained final logs/configs provide package hashes and
exact invocations. Fixtures/PK3s/saves and earlier failed diagnostics stay under
the issue's ignored build directory. They are not packaged or redistributed.
Fixture WADs use development IWAD textures only; they never enter src.

Initial failures were a missing play annotation, checks expecting deferred
Spawn/Destroy callbacks within the same console event, and a duplicated absolute
save path in the launcher. All were corrected and final runs completed. Existing
quest save arrays and scene geometry were not changed; keep original saves and
the baseline package for rollback.
