#878 / 5.17.117 — Optional house joinery review

This package contains sources and evidence, not the engine, development IWAD,
runtime PK3, candidate PK3 or save files. Only the final consolidated author
terminal should launch the interactive review. Author acceptance is pending.

From the repository root, using a new output directory for every run:

python assets/generators/build_house_joinery_review.py --runtime build/caelum_argenteum_dev.pk3 --output build/joinery-review
python assets/validation_v5_17_117/check_geometry.py --candidate build/joinery-review/candidate.pk3 --output build/joinery-geometry.json
python assets/validation_v5_17_117/run_facade_views.py --runtime build/caelum_argenteum_dev.pk3 --overlay build/joinery-review/candidate.pk3 --output build/joinery-views --render-radius-preview
python assets/validation_v5_16_2/run_barracas_house_use.py --runtime build/caelum_argenteum_dev.pk3 --candidate build/joinery-review/candidate.pk3 --output build/joinery-use
python assets/validation_v5_17_117/run_model_removal.py --runtime build/caelum_argenteum_dev.pk3 --saved-session build/joinery-use --output build/joinery-removal

The optional --render-radius-preview applies the same private #879 subclass to
both view runs. The model-only candidate itself contains no actor or map changes.
Omit the option to reproduce the original large-facade visibility defect. The
completed #879 production fix must precede the final interactive author terminal.

For performance, run one scene at a time with the existing local presentation
layer, no competing build/hash/validator, and unique --label values:

python assets/validation_v5_17_117/run_scene.py --runtime build/caelum_argenteum_dev.pk3 --label street-control-new --presentation-layer PATH_TO_LOCAL_LAYER
python assets/validation_v5_17_117/run_scene.py --runtime build/caelum_argenteum_dev.pk3 --label street-candidate-new --overlay build/joinery-review/candidate.pk3 --presentation-layer PATH_TO_LOCAL_LAYER

Add --siege for the approved normal siege scenario. These measurements retain
native actors, weather, clock, combat and the original observer's intervals.
They do not use the gallery's diagnostic radius subclass. Queue-present intervals
are not monitor scanout; report frame/tic tails and retain all qualifications.

Native house-use tests teleport an invulnerable user and replace city setup with
the existing diagnostic house/resident setup. The actual Used/capture/render-ACK,
map travel and return positions remain native. This is not an ordinary approach,
purchase, siege or multiplayer test. Model01 evidence is superseded by model02;
source/prototype corrections and the pre-engine camera failure remain recorded.
