#879 / 5.17.118 - Large facade visibility

Production change: CA454Facade31800 native RenderRadius781, derived from the
unchanged original OBJ's horizontal radius780.2563681252464. Collision20/height16,
models, maps, placements and state layouts remain unchanged. The generator emits
the same derived property. The narrow installation manifest refresh is supported
by a full map recompilation audit; the installer was not rerun.

Reproduce from repository root, with the local official GZDoom4.14.2 and licensed
development IWAD configured in the retained harnesses. Never run another engine,
build, full hash audit or validator concurrently with performance measurements.
Use new output folders; the scripts preserve old evidence.

python assets/generators/generate_barracas_map.py --output build/issue879-recompiled02
python assets/validation_v5_17_118/check_recompiled.py --compiled build/issue879-recompiled02 --baseline-manifest assets/validation_v5_17_118/evidence/baseline-installation.json --output build/issue879-recompiled02-audit.json
python assets/validation_v5_17_118/run_persistence.py --old-runtime build/issue878-review01.pk3 --new-runtime build/issue879-visibility01.pk3 --output build/issue879-persistence02

Use --help on run_views.py and run_profile.py for their explicit runtime/overlay
and output arguments. Native evidence distinguishes production facade classes from
the house-use harness's diagnostic city setup, invulnerable portal placement and
view controls. No author acceptance is implied. Seven persistence phases verify
old saves, reload, rollback, reupgrade and a city retained in an interior hub save.
All160 facade transforms/colliders remain correct in eight samples;13 USE requests
and7 exact returns follow real rendered capture/ACK travel.

review.html contains original/fixed/fixed+joinery captures. The separate #878 art
option remains unapproved and is not installed into src. Its final review launcher
in validation_v5_17_117/run_review.py can use this corrected runtime. Launch it only
as part of the final consolidated author terminal requested by the author.

evidence/performance.json retains six matched native windows: street, ground-facing
and the approved normal1000/600 siege scenario. The observed siege census is601
defenders/988 attackers, population1590. Queue presents are not monitor scanout.
The siege remains around2 presents/s and is not a playable-performance acceptance.
No retired6000-attacker test was run. Saves, packages, IWADs and binaries stay local.
