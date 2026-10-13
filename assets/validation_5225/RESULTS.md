# 5.2.25 / #222 - Staff dispersion matches statuette

Author decision: staff uses the statuette's precision; retain book homing.
This reduces staff per-axis base dispersion from 4-40 to 2-20 degrees and
therefore improves accuracy. Baseline: f0cd88b4. GZDoom 4.14.2 on Windows 11,
Vulkan, 2026-10-13. Separate INI, background simulation and 5% master audio.

The production patch adds STAFF to the existing STATUETTE category in
CaelumWeaponModel. No other balance value, damage, cost, modifier or saved
field changes. Utility staff uses a separate physical catalogue path. No
homing implementation changes.

`baseline` runs the same contract against parent code to demonstrate the
staff/statuette mismatch. `magic-final` checks T1/T2/T3 and actual native
staff casts at Insight 0 and 100: correct Type-3 accuracy, per-axis launch
offsets inside 2-20 / 0.25-2.5 degrees and one projectile per cast. Book/bell
categories remain unchanged. These controlled launches exercise the production
release method, not physical mouse input. CA222-01 remains the author check.

Reproduce with prepare.py followed by run_native.ps1 -Fixture magic
-Script magic.cfg -Map MAP02 and a unique -Label. The baseline adds -Baseline
-ExpectRegression. All generated packages, INIs and development saves stay
under build/issue222 and outside the production package. No new artwork.

Final result: all 26 corrected native assertions passed; the old runtime has
10 expected mismatch failures. Static validation and normal build passed, with
all 16,053 package members byte-identical to the tested runtime. Independent
read-only review found no blocker and confirmed the utility staff and book
seeking paths are untouched. The temporary keep-awake request was released
with the power plan unchanged. Author acceptance CA222-01 remains pending.
