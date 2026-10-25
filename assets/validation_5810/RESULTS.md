# Tent occupancy guard — #412 / 5.8.10

30 native GZDoom 4.14.2 assertions in three selected runs. The new guard
passes 18 checks, including normal/accelerated rest, other-map stale records,
outside occupants, atomic rejection, a late occupancy race, paused work, resumption
and returning the same original tent item. The race fixture explicitly injects
rest records into the existing native player; it does not establish two-player
rest admission or sleeping-bag placement. Those remain separate integration work.

Existing enlarged-tent save loading and original-package rollback both pass.
No new saved fields or geometry are added. The final runtime contains
16,862 source-identical members, SHA-256
8004894abc22391cd6da09d6284909d861c6ca3ec99989e16abb6c8373983b0a.
The original save and test addon came from #411's retained private evidence in
build/issue411-placement/ca411d-wide-ready.zds and deploy.pk3. The original
binding-final package is retained unchanged; no user save was overwritten.

The guard examines only MAXPLAYERS slots when packing starts/advances/completes;
it performs no map-wide actor scan and changes no recovery/cost/shelter values.
This is bounded native functional evidence, not rendering/FPS acceptance. No
author acceptance is inferred or extra author test requested during the absence.

Remaining: actual sleeping-bag geometry inside the tent and normal/accelerated
rest integration. Existing CaelumRestBag.HasRoom uses a radius-46 clearance;
the model source has a 40-by-88-unit base plus a small zipper edge. Do not silently
resize accepted art, change body collision or invent new recovery bonuses to make
it fit. CaelumRestSafety currently rejects rest with another player present;
resolve the intended second occupant and shared-clock scope with the author upon
return before removing that existing restriction. #410 furniture is also pending.

The final package repeats the 18 guard assertions after updating two required
diagnostic version labels. Comparison identifies only those strings and CRLF/LF
normalization of the two files versus guard01 used for save/rollback. Every
other member is byte-identical; no gameplay logic differs.
