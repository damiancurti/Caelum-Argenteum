"""Extend the established CA-KP-251 lesson instead of duplicating it."""
from pathlib import Path
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=root/'docs/KNOWN_PITFALLS.md';s=p.read_text(encoding='utf-8')
start=s.index('## CA-KP-265 -');end=s.index('## CA-KP-264 -',start)
s=s[:start]+s[end:]
at=s.index('## CA-KP-250 -')
addition='''### 5.17.107 / #857 - Equipment integration recurrence

The same engine rule recurred when adding sword/shield slots15/16 to the15-slot
wardrobe definition. The append-only prototype overwrote5,610 body-slot entries
in374 states with body frame374. Real equipped-item and native pose assertions
passed while direct motion01 captures showed separated accessories. This was
a binding defect, not a reason to reshape an otherwise unchanged rig.

The final deterministic generator emits all17 slots together for each of375
states and simulates the native current-array snapshots. Corrected motion02
captures restore body/accessory pose agreement. Exact package/source proof and
the final native equipment/save/hub/reversal suite are retained in
assets/validation_v5_17_107. Rejected captures and performance windows remain
explicit evidence. Native engine source: src/r_data/models.cpp, FrameIndex
parsing, SpriteModelFrames hash construction and FindModelFrameRaw.

Relaxed construction fingers remain separate item-specific grip work under
#859/#462. Neither a corrected binding nor native ownership tests confer author
acceptance or full equipment coverage. Apply this existing lesson whenever
adding a model slot, including data generators that reuse validated definitions.

'''
s=s[:at]+addition+s[at:];p.write_text(s,encoding='utf-8',newline='\n')
print('Extended CA-KP-251 with the new857 evidence; removed only the uncommitted duplicate section.')
