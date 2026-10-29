# V5.8.29 / #410 - Sofa seating evidence

The mansion reading room has two original sofas with two and three usable seats.
Ordinary Use chooses the nearest reachable free seat; rest, posture, comfort,
standing, saved occupancy and contamination use the existing systems. No new
resource bonus, player collision shrink or inventory grant is introduced.

The final evidence records **113 executed native PASS / zero FAIL** and zero
static validation errors. `report.json` records package/fixture hashes and literal
executed assertions, not cumulative counters restored from saved handlers.
The 101-assertion main suite ran against `final29b`. `final29c` differs by exactly
one production file: one sofa-seat normalization in `CaelumTargetInfo`. Eight additional assertions verify native Use and English target titles/actions.
`final29d` fixes only Spanish text encoding and its generated localization indexes;
four final-package assertions plus a native screenshot verify the Spanish name
and action. Unchanged earlier evidence is reused explicitly.

Coverage includes all five individual seats, original full player dimensions,
blocked and cleared destinations, existing chairs/beds, owner destruction, shared
contamination/cleaning surface, accepted library access, occupied-seat save/load,
hub travel and original5.8.26 partial-reading save migration. The untouched old
save's previous original-runtime rollback is retained as reused evidence, not
counted as a new run. Both current and old map geometry remain unchanged.

## Found and resolved

- Invisible seat proxies cannot reliably use ordinary visibility against
  themselves. Their visible parent supplies the sight target.
- Native Use encountered auxiliary seats in engine iteration order. Proxy Use
  forwards to the owner, which chooses the nearest free seat.
- Visual inspection caught a question mark replacing the Spanish accented vowel;
  the UTF-8 source and generated localization indexes were corrected and recaptured.
- A two-console-frame synthetic Use pulse could be missed before a game tic;
  the input fixture now waits across actual tics. Native interaction passes.
- Moving a player and then calling `TestMobjLocation` admits overlapping actors
  through GZDoom's same-position unblocking exception. `lifecycle4` reproduces
  three failures. The production seating path now uses a non-player probe of
  the same full dimensions before moving the user; only that user is ignored.
  `lifecycle7` and the final full-package lifecycle checks pass. See CA-KP-180.

## Art and reproduction

`assets/art_source/sofas/DATA.json` records delegated physical calculations and
the two Metropolitan Museum dimensional references. The deterministic generator
builds original wood-frame meshes with thin cotton covers and existing owned
textures. It does not import museum photographs or meshes. Five occupied native
views were inspected; visual author corroboration remains pending. The separate
target capture verifies the furniture label/action.

From the repository root, run `python assets/validation_5829/prepare.py`, build
the complete runtime using `build_dev.ps1`, and use `run_suite.ps1 -Runtime NAME`
with a new prefix to preserve prior logs. The migration fixture requires the
unchanged `reading-progress.zds` from the recorded5.8.26 test, copied into the
local work directory; it is not shipped as a game resource. The private away map
is assembled only into the diagnostic addon. `--overlay` is for development
iteration and was not used for the final full-package suite.

`collect.py` checks every production member against source, byte-preserves prior
map/art members, repeats the generator for exact output equality, verifies old
save identity and fails if an expected assertion/event never executed.

## Limits and status

Two visual owners and five seat proxies add no recurring map-wide actor scan.
Initialization uses the typed sofa census once/second until both installations
fit; steady seating examines at most three references and allocates one temporary
probe on demand. No display/frame-presentation performance or multiplayer
acceptance is claimed. Multiplayer author review remains deferred to V5.12.

CA410-SOFAS-01 is outstanding. Manual delivery stays deferred until the whole
V5.8 implementation is ready. The remaining catalogue and acquisition integration
are still open; this patch does not complete #410 or V5.8.
