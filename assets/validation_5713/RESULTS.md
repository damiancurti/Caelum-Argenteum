# #471 / 5.7.13 — Chemistry batches

Implementation is in progress. The initial state model passes 53 assertions in
three isolated GZDoom 4.14.2 runs: capacity, one occupied lot, cancellation,
partial/final withdrawals, saved object identity and native map travel. An
absolute world-clock deadline completes the model after elapsed time without
updating an absent station. See [batch_report.json](batch_report.json) and
[raw evidence](native/).

The fixture uses synthetic data, not a production recipe. Inventory transactions,
learning, station interaction, commerce and multiplayer are not covered by this
checkpoint. There is no author-acceptance claim or pending author handoff yet.
No rendering-performance claim is made.

The first travel run did not reach CABAT2 and is retained but excluded. The
corrected run calls the native level transition and requires destination evidence;
passing the initial-map checks alone cannot validate travel.

The separate 5.7.8/#479 author acceptance remains fully recorded in its own patch.
