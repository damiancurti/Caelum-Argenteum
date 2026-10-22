# Issue #404 - Resource contract, 5.7.1

This patch records author-approved data and audits the existing resource
authorities. It introduces no gameplay, map, material ID or save-schema change.
The only src changes are the two required current-release diagnostic labels.

`audit.py` checks existing material IDs, the current gram/recovery constants,
all eleven mineral families against the canonical table, seven approved source
profiles, source/consumer keys and unchanged gameplay bytes relative to #408.
Its deterministic report records authority hashes. New rows are not a claim
that harvesting, imports or recipes have been implemented.

Run `python assets/validation_571/audit.py`, then regenerate the document index
and run `python validate_project.py`. Native #408 evidence remains attached to
that separate issue; it is not counted as a new native resource test. No native
run is needed for this data/documentation scope. #405/#406/#407 and later recipe
issues must test their actual runtime integrations and provide author scenes.

The author approved the decisions recorded in SYSTEMS during the 2026-10-21
session. Unresolved placements, species/forms, consumers, recipe/economy and
thermal values remain explicit issue gates. No manual runtime test is added
to pending_test.txt for unimplemented data.
