# 5.4.36 / #334 - House-door presentation isolation

The author requested no full-screen fade or wipe for house-door travel, while
retaining the loading icon and arrival autosave. GZDoom 4.14.2 already suppresses
ordinary same-hub wipes. The actual door's NOINTERMISSION flag and hub434 remain.

## Reproduction and scope

Ordinary baseline Use from MAP03 to CAH000 and back, with wipetype1, emits no
explicit wipe and produces two native autosaves. This alone does not establish
the absence of every screen effect: screenshots are final frames, not video.

A second baseline boards the real ship in TCOAST and confirms its actual route
11 to MAP03. The original world clock, provision forecast and native arrival
transaction execute. The probe then positions the player at house158 immediately
and calls its real aimed Used entry. Only that final approach is injected: the
nearest door is 1,085.888 MU from the normal arrival point. This is not a claim
that the author normally traverses that distance before the vehicle effect ends.

Before the door, the journey is ARRIVED with no pending connection; UI still
reports VehicleArrival=true, frame1 and wipe1. At the first CAH158 frame the
old vehicle snapshot remains active at frame4, despite TravelWipe already being0.
Thus the observed defect is stale overlay ownership. It does not independently
prove a native fade: setTransition(0) does nothing in this engine.

HousePortal now sends a one-use explicit presentation intent. PreTravelled does
not replace it with an old vehicle mode. The UI clears the unfinished snapshot,
normalizes to zero and continues ordinary arrival processing. No negative value
reaches setTransition, where it would select Melt. Global wipetype and
sv_alwaystally, actual vehicle presentation and native save handling are unchanged.
The existing serialized PendingTravelWipe is reused; there is no new save schema.

## Native verification

The final gate passes8 native runs/64 assertions. Both ordinary house round trips
save on entry and exit; those exact two autosaves load on their original maps.
Early ship/cart entries render the first house frame with VehicleArrival=false,
frame0 and wipe0. Ordinary vehicles complete their respective1/3 presentation,
while the configured wipetype2 and sv_alwaystally0 remain unchanged. Build and
validation pass; all16,375 normal/tested/source members agree. Candidate sources
and each immutable fixture carry
separate SHA256 values. Normal doors use actual +use input; vehicle tests use
native Board/Confirm, followed by the documented injected approach when requested.
All engines run sequentially at 1280x720 Vulkan, unpaused in the background,
audio5%. The vehicle probe caps presentation at35FPS to preserve enough frames
for UI/network acknowledgements. These are behavior checks, not FPS benchmarks.

The initial cart diagnostic carried200 water rations, while its real forecast
required258. Its death and failed transition checks are retained as a fixture
failure. The corrected diagnostic adds the58 rations demanded by that forecast
and recomputes through normal Board; production needs, speed and survival are
not changed. Ship cases need no additional stock.

Reproduce a fresh matrix with `prepare.py --directory issue334-fresh --vehicle
--fixed`, then `run_matrix.py --directory issue334-fresh`. Do not reuse a completed
label. Private saves, generated packages, engine and development IWAD are not
distributed. archive.py retains raw compressed logs, frozen fixture sources,
launch metadata and save identities and checks normal/tested/source equivalence.

CA334-01 author acceptance remains pending, especially the ordinary entry that
originally showed a fade. A passing early-entry diagnostic is not that acceptance.
