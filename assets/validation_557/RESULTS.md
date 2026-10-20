# #315 / 5.5.7 future melee design

The author explicitly chose on 2026-10-19 to document the design, defer
conversion and retain current damage. SYSTEMS contains the field/source/unit
inventory, current/candidate pipelines, T1-T3 comparisons, integration boundary
and required author decisions. No candidate speed, effective mass, penetration,
energy-to-HP rule or production conversion is approved.

Static project validation and normal packaging pass. verify.py compares every
packaged member against the accepted #314 runtime: only the two required release
diagnostic strings differ. Gameplay and save-schema bytes are unchanged. Its
report.json records the nine current raw-damage calculations from #309's matrix,
Rulo's 200 kg / Strength 20 profile and existing growth equation. Independent
read-only review checked the values, sources and deferred authorization boundary.

One isolated final-package GZDoom 4.14.2 MAP01 smoke compiled and advanced
normally, unpaused in the background at 5% audio; the log records one PASS.
This is a compilation/startup gate, not an implemented-energy-model test or
performance measurement. Existing #314 native evidence applies to unchanged
gameplay; no new save or balance claim is made. The #195 War Axe evidence is
explicitly historical and discloses its forced-Dexterity hit setup.

The first comparison helper required identical ZIP member ordering. The normal
builder and frozen fixture order members differently; comparing identical name
sets and member bytes resolves that tooling assumption without hiding content
changes. No native failure occurred.

Reproduce: normal build_dev.ps1, verify.py, prepare.py, then smoke.ps1. The fixed
private directory must be fresh so prior native evidence is retained. Runtime
PK3, fixture package, IWAD, executable and saves stay outside distribution.
No author gameplay test is queued for the deferred design. #316 remains deferred
until a suitable authored map/encounter exists; #369 is a separate visual issue.
