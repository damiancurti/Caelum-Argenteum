# 5.4.29 - Adopted MAP03 and bounded normal siege (#327)

Author decision: preserve MAP01/MAP02, promote the tested low-sky city to MAP03,
retain other standalone content as named test maps. Normal reinforcements use
1,000 living before admission, 6,600 cumulative reserve, plus existing Zupay and
600 defenders. Resurrection is explicitly unchanged and can exceed the cap.
Existing victory stops unused reserves.

## Static evidence

336 checks in STATIC.json: exact map inventory/markers, stable location IDs,
no obsolete runtime map selectors, unchanged test TEXTMAPs, preserved original
WAD hashes and current export inventory. A second normal city generation is
byte-identical; its TEXTMAP MD5 is bfbf3d4ac39f36e7d61a450dbb47b1a2, exactly the
author-selected #318 diagnostic. Four renamed sewer generators also reproduce
their shipped WADs byte-for-byte. MAP01, MAP02 and CAH interiors are unchanged.
Native numbered-special inspection found no Teleport_NewMap transitions to the
renumbered maps. Legacy MAP06 flags reject the new catalogue without changing
the existing package (LEGACY_GUARD.json).

## Native evidence

GZDoom 4.14.2, isolated config/saves, hidden unpaused process, 5% master audio,
one engine at a time. Twelve passing runs, **1,072 PASS assertions**, no FAIL in
those runs, all using runtime SHA-256
479f91fa0dc2564cb3d161cc69212fb1311a8b2d4acab0a180af0e8cdb176847.

| Run | Assertions | Scope |
| --- | ---: | --- |
| geometry-01 | 831 | Every doorstep/shop, walls/towers, low-sky flight, normal city selector and peaceful roster |
| portals-01 | 45 | Actual Use/return for houses 0,119,120,158,159 |
| maps-01 | 27 | Campaign and named-map launches; TACTORS identity only |
| siege-01 | 27 | Automatic first group/crew, cap 1,000, 99/100 vacancies, blocked/partial groups and save |
| siege-reload-03 | 9 | Reload/hub counters, bitmap and deadline; retry; victory stops reserves |
| budget-01 | 74 | 6,600 cumulative native arrivals plus Zupay, exhausted budget and bounded formation cursor |
| policy-02 | 26 | Native resurrection reaches 1,001 then blocks refills; revision 1 -> 2 and idempotence |
| save-01 / reload-01 / return-01 | 16 | Injured resident, finite inventory/ammunition/equipment and sleep survive saves/hub |
| deploy-01 | 3 | 600 unique resident identities deploy; cannon reassignment survives hub |
| route-01 | 14 | Actual MAP02 travel plan/commit -> MAP03 -> house -> original doorstep, quest card retained |

After the documentation/tooling-only final rebuild, final-geometry-01 passes
another 832 assertions: **13 successful runs / 1,904 total**. The normal builder
uses current ZIP entry timestamps, so the rebuilt archive hash is
8d57e7d2242ac283cf76a5ea910e40f072d65398e3070639dbdd6d70cacd3b9e.
FINAL_PACKAGE.json verifies all 16,371 members against current src and records
the source tree hash. The final smoke used that rebuilt artifact. The runner now
retains an immutable local runtime link before launch, as well as fixture/CFG.

The budget fixture accelerates opportunities and removes its dead test bodies,
retaining encounter records. It peaks at **100 living**, finishes with 6,601
records and never creates 6,000 simultaneous actors. Separate cap tests reach
1,000; the resurrection check reaches 1,001 by the authorized exception.
This is neither natural-combat performance nor production corpse-retention evidence.
TACTORS has 16,508 historical placed things and was not launched. Its byte-preserved
content, WAD marker, MAPINFO registration and selectors were checked instead.

Three failed fixture attempts remain archived and excluded from the passing count:

- siege-reload-01 supplied an absolute forward-slash save path, which GZDoom
  prefixed with savedir again; using its relative filename fixed the invocation.
- siege-reload-02 waited only 10 tics through hub transition and reached its
  city-only assertion while still inside CAH158. The retained 70-tic hub waits
  passed; no production runtime change was required.
- policy-01 tried restoring a just-spawned Mandinga before native initialization
  established maximum health. Waiting two tics after deployment passed the same
  native restoration/cap check; production resurrection code is unchanged.

The first portal record initially hashed a newer prepared fixture at run end.
The exact loaded v1 was reconstructed and matches geometry-01's original hash;
the initial metadata is retained beside its qualified correction. Later runs
snapshot/hash their fixture and command file before launch. Evidence fixtures
are stored as text sources by original package hash, without engine/IWAD/save files.

## Limits and reproduction

No new presentation-FPS benchmark was requested for this integration. The exact
adopted geometry retains #318's qualified performance evidence; it does not
establish 60 FPS or explain the previous session variance. Several production
consumers still traverse historical attacker records (CA-KP-123); profile the
late battle separately. CA318-01..05 and CA327-01 remain manual checks.

Run `python assets/validation_5429/verify.py --regenerate` in a fresh checkout
with no existing build/issue327-regenerated output. Then build normally and run
`python assets/validation_5429/native.py --prepare`. Each --label is unique;
--script selects geometry, maps, portals, deploy, siege, siege-reload, budget,
policy, route, save, reload or return. Use --map MAP02 for route; --load
siege-state.zds, house-state.zds or city-state.zds for corresponding reloads.
The test code is excluded from the normal PK3. `archive.py` records results and
qualified failed attempts; EVIDENCE_SHA256.json verifies archived artifacts.

Final project validation/build status is recorded in HISTORY with this patch.
