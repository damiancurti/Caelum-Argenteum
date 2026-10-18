# #322 preview restart and qualified author confirmation

Origin: 5.4.35/#322, follow-up 2026-10-18. The previous manual room was empty
after the player died/reloaded: a one-time startup seed did not run again.
The local preview03 seeds four original prisoners after a fresh map/restart,
restores their TID references on save load and keeps the observer alive while
waiting. It adds Spanish/English on-screen instructions and faces the companions.
This fixture does not change production gameplay or the known packed-row limit.

The actual native map restart passes 10 assertions across two seeds. The author
then explicitly answered "Funciona; ya cerr? la prueba" to the follow-up asking
whether prisoners still turned/walked while idle. This confirms observed following
and idle behavior. It does not independently confirm the unmentioned campaign
extraction/rewards or every narrow-corridor/save scenario in CA322-01; those
remain actionable there. No production code or release increment accompanies
this acceptance of the existing patch.

Frozen preview source, launch/config records, raw compressed logs and the
native restart capture remain here. Runtime/fixture hashes are in manifest.json.
The preview uses development textures from the local IWAD; none is redistributed.
