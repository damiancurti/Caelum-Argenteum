# Wardrobe storage ?5.8.24 / #410

Original period wardrobe, painted128px inventory/fallback icon, native storage,
locks, ownership, cargo and food lots. Approved contents capacity25 stacks/1000kg;
delegated construction mass153.8955961kg. One empty wardrobe is installed after
the existing bedroom/bathroom furniture, at(-304,488,136),facing90.

The storage actor retains the ordinary chest implementation while separating
its display identity and physical mass from the MEDIUM capacity tier. Placement
uses approved camp/property permissions; mansion gardens are permitted, bedroom
rearrangement is not yet granted by that policy. Ordinary chests keep their
existing placement behavior. No acquisition recipe/shop stock or new rest bonus
is introduced in this stage; #410 and the wider V5.8 work remain open.

## Verification

- Static validation:zero errors. All current version markers agree at5.8.24.
- Official final24d SHA256:`78a40afd14147ffb543afe51b1ff047f0d06d0dd0d521372db1a913ab427c5bc`; all16970 archive members match current src.
- All14026 existing map/model/sprite/graphic members match official5.8.23.
-145 executed native PASS,zero FAIL in17 selected GZDoom4.14.2 runs. The report
  counts log assertions,not serialized cumulative result counters.
- Exact1000kg acceptance and overflow rejection;25-slot boundary; original food
  quantities/contamination; correct medium padlock and carried/boxed-key rules;
  insufficient carry rejection; cargo weight/name; forbidden land rejection and
  actual garden placement; preserved beds,tables,bathrooms and clear Use access.
- Current save/load and hub travel with placed/carried wardrobe; no duplicate
  installation; previous5.8.23 original chest/contents preserved on migration,
  and original-version rollback using the untouched original save.
- Closed/open/locked model captures and actual journal inventory icon inspected.
  Open doors swing outward and their latch moves with the door. The private
  visual fixture settles the player after teleport before opening/locking;
  model-only capture hides the storage overlay without closing the visual.
- Normal-control author fixture smoke-tested in Spanish; no F-key macros.
  Its2000kg carry allowance is explicitly diagnostic,not a gameplay bonus.
- Generator run twice with identical manifest/output bytes. Source image,prompt,
  physical inputs and hashes retained; no museum image pixels copied.

Some functional runs used byte-identical production code from earlier immutable
packages. Final differences are restricted to the new wardrobe open.obj visual
swing/latch correction and the corrected Spanish action language tag with its
derived localization indexes. Final-model and inventory captures use final24c-probe;
its only differences from officialfinal24d are those localized text/index files.
Two native Spanish assertions verify the corrected name and carry-action keys. The collector verifies every
run's package hash and allowed member difference instead of relabeling evidence.

Early local failures were fixture errors: querying before PostBeginPlay; expecting
diagnostic carry capacity to survive inventory recalculation; invalid probe
positions; retaining a map EventHandler pointer to a travelling actor instead
of recovering its real native cargo; and capturing immediately after teleport.
They remain local evidence and are not counted as passing runs. The installer
sets its full collision dimensions before testing placement. Original save files
and diagnostic PK3s remain local; no IWAD/engine/test map is distributed.

## Matched performance

Same peaceful northwest-bedroom viewpoint,1280?720 Vulkan,60-FPS cap,700tics,
unpaused background,5%audio. Baseline/final render-callback P95:17.6570/17.6648ms;
P99:18.4448/18.4054ms;worst:22.2927/19.7108ms. Mean:16.6650/16.6668ms;
phase:19.9535/19.9560s with?100ms polling uncertainty. One new wardrobe visual,
no new periodic global actor scan. Initialization alone uses the revision-gated
typed wardrobe lookup. This narrow comparison shows no material regression in
recorded conditions. Callback timing is not GPU/display presentation,and does
not establish whole-map,sewer,siege or displayed60-FPS acceptance.

## Author status

CA410-WARDROBE-01 is pending in the root pending_test.txt. The author is away;
the interactive helper is prepared but has not been opened for author review.
No previous pending check was removed. Manufacturing/acquisition,other furniture
and separate V5.8 issues remain open.
