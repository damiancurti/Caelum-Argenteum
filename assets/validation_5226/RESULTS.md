# Rest serving and feedback - 5.2.26 / #227

GZDoom 4.14.2, Windows 11; baseline 66029634. Author acceptance is pending CA227-01.

## Findings and final behavior

The authored MAP02 arrival chair has no dining table. Previous F/G logic required
one even to consume owned reserves. The author explicitly approved serving from
both chairs and sleeping bags. Shared reserve transactions now use carried items
then the owned Box, preserving table priority, finite portions, container identity,
existing recovery cadence and toggle/stop behavior. No save fields were added.

Ordinary notifications were hidden whenever a native menu was active, including
T/F/G rejection reasons. The rest menu now shows its latest live inbox result.
Large messages temporarily use the upper information panel instead of covering
buttons or resource bars. The existing x105 speed replaces stale x60 captions.
The original author's T blocker has not been captured; safety rules are unchanged.

## Native evidence

`evidence.json` records **120 passed assertions**, zero final-suite failures:
- key dispatch and press/release pointer routing; actual simulated fast-forward;
- the authored MAP02 chair, sleeping bag, carried supplies and Box supplies;
- finite next portions, last ration, empty container retention, exhaustion and stop;
- the genuine stocked MAP01 dining table/chair;
- hazard rejection and empty-supply rejection reaching the visible inbox;
- saved active bag/meal sessions resume, consume and exhaust correctly;
- English and Spanish, 1280x720 and 960x720; large view uses UIScale 2 and
  con_scaletext 3. Inspected final large Spanish notice: complete, controls/HUD clear.

Final-package Windows computer-use test `live-final`: real clicks enabled Eat and
Drink from the bag, physical F/G stopped both with visible confirmation, and T
activated x105 with a visible notice. Sleep reached 100 and the session ended.
This is agent verification, separate from author acceptance.

The earlier diagnostic probes also dispatched correctly on a new profile and a
prepared copy of save08. Those reset position/profile and cannot establish the
original author's scene. Draft fixture errors (read-only UIEvent fields,
case-insensitive local/member shadowing, and setup collisions) were corrected;
all listed delivery runs completed successfully. No production workaround was
made for a fixture error.

## Reproduction and scope

Run `python assets/validation_5226/prepare.py`, then use `run_native.ps1` with
`-Fixture probe`, a fresh `-Label`, and `-Script probe.cfg`, `chair.cfg`, `bag.cfg`,
`box.cfg`, `deplete.cfg`, `authored.cfg` (MAP01), or `large.cfg` (960x720).
`save.cfg` followed by `load.cfg -LoadGame c227-portable.zds` covers persistence.
Configs isolate saves/audio/video and run unpaused in the background at 5% audio.
Generated PK3s, engine, IWAD, logs, saves and captures remain local in build/issue227.
The final package differs from the earlier suite only by required diagnostic
release labels/line endings; final load and probe runs use the final package.

Temporary keep-awake request released after testing; the active Windows power plan remained unchanged.

Static validation and normal build passed; all 16,053 packaged members match the final native-tested package exactly.
