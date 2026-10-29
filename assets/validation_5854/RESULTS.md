# 5.8.54 / #410 review corrections

GZDoom 4.14.2, Windows 11, Vulkan/RTX 3070 Ti, 1280x720, unpaused,
5% audio. 53 native assertions passed in four final runs. Exact source
package: review54d, SHA256 ed523fd9ef42e30477e5a9c373eb7ea2df722d13ba88b96aab5c4fc489ce2a5c.

Tests cover selected Use for all six empty bottles/canteens, exact finite-reserve
deduction, unchanged R refill, full-container refusal and drinking away from
sources. Large painting placement/packing on actual MAP01 walls, migrated recipe
knowledge, normal Provisions stock and repeated catalogue access passed. Existing
overlap/obstruction checks passed. Visible engine captures show both beds, their
bedding/canopy, the accepted small picture, large landscape and original statue.

Earlier failed diagnostic runs remain under build: the legacy wall finder searched
only one-sided segments; the mansion uses closed two-sided walls. Production
placement now proves contiguous local wall coverage and rejects openings. A fresh
merchant test initially bypassed normal stock initialization; the final test uses
EnsureStock. No production inventory was reset to make the test pass.

The deterministic generators reuse owned textures/art. Padding uses explicit
30 kg/m3 cotton-fill design reference; build bills and current bed masses are in
the DATA/GENERATED records. Sleeping surfaces/collision/recovery are retained.
Author corroboration of these corrections remains pending. Other issue acceptances
are recorded in their own patches.
