# #502 sanitary postures — 5.8.12 continuation

Author request: sit on the toilet and lie in the bathtub. The implementation
reuses the established RSDO postures and native clipped orbit-camera pattern.
No artwork, actor dimensions, water calibration or map geometry is replaced.

The toilet seats its user for the existing metabolic action and stands up on
completion/cancellation. The bathtub supports reversible reclining; this alone
neither sleeps nor washes. Soap bathing and its fractional-soap accounting remain
pending. This continuation does not complete #502 or V5.8.

Evidence is counted from executed PASS lines in report.json, not the cumulative
RESULT counters restored in saves. Native runs use GZDoom4.14.2/Windows11/Vulkan,
unpaused in the background with5% audio. Their command scripts, package hashes,
engine/driver details and raw logs are retained under native/. No runtime test
fixture or IWAD is distributed inside the game package.

Coverage: native Use, seated/lying sprites, actual player collision volume,
no rest/sleep bonuses, orbit input, completion and input/damage cancellation,
external displacement, occupied entry, blocked exits, delayed collision restoration,
zero-Life cleanup, missing fixture, another camera owner, save/load identity,
hub departure/return and pre-pose toilet-save adoption without resetting its timer.
The pre-pose save also loads in its original runtime. Existing toilet resource,
clock and forecast checks are rerun against the final package.

Failures retained: the initial NOBLOCKMAP blocker was unsuitable; a blockmap
chair then reproduced that TestMobjLocation alone accepted occupied entry.
Explicit local actor overlap checks resolve that reproduction (CA-KP-163).
The first visual capture inherited the chair's horizontal offset/facing and sat
beside the toilet; centered registration and the toilet's facing align the final
pose. Later review added missing-fixture cleanup without changing normal posture.

Reproduce from this worktree:

    python assets/validation_5812/prepare_pose.py
    powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5812/run_native.ps1 -Runtime pose-final03 -Label UNIQUE -Checks -Addon pose-checks.pk3 -Script pose-core

The author terminal is assets/validation_5812/author_pose_terminal.ps1. Option1
supplies F1 toilet/F2 tub, Use to enter/exit and movement to stand. Option2 runs
focused regression/save/hub checks. CA502-POSE-01 passed author review on2026-10-25
without qualifications. Existing CA502-TOILET-01 and CA502-TREATMENT-01 remain
pending separately. Acceptance records the author result; no engine rerun is
required for this documentation-only change.

These are isolated functional/visual checks, not a network multiplayer or frame
presentation benchmark. No global actor scan is added. Accepted rest furniture
keeps its implementation; the local occupancy guard belongs to sanitary fixtures.


Final posture validation: 74 executed native PASS, static validation clean, 16887 source-identical package members; all 169 maps and 13826 art members unchanged. Package SHA-256: `b0840fb6fe5c4ed749654a47bc0bae56162897210076f0ebc1350ab0ab5e926f`.
