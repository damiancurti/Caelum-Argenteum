"""Record the unfinished #430 checkpoint without claiming author acceptance."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]

def read(name):
    return (ROOT / name).read_text(encoding='utf-8')

def write(name, content):
    (ROOT / name).write_bytes(content.encode('utf-8'))

def insert(name, content):
    source = read(name)
    marker = re.search(r'Documentation version:.*\n', source)
    assert marker
    write(name, source[:marker.end()] + '\n' + content.rstrip() + '\n' + source[marker.end():])

if '## 5.11.4 - Companion implementation checkpoint' in read('docs/HISTORY.md'):
    raise SystemExit('Checkpoint already recorded; no files changed.')

versioned = ['AGENTS.md'] + ['docs/' + name for name in (
    'PROJECT.md', 'SYSTEMS.md', 'ASSETS.md', 'HISTORY.md', 'CONTEXT.md',
    'TASKS.md', 'SPRITE_ART_DIRECTION.md', 'MAP01.txt')]
for name in versioned:
    write(name, read(name).replace('Documentation version: **5.11.3**', 'Documentation version: **5.11.4**', 1))

source = read('README.md').replace('Current release: 5.11.3.', 'Current release: 5.11.4.', 1)
start = source.index('**V5.11 implementation is in progress.**')
end = source.index('\n**V5.10 is complete', start)
source = source[:start] + '''**V5.11 implementation is in progress.** Patch 5.11.4/#430 is an unfinished
companion checkpoint: dialogue administration, native item transfers, trust,
orders, cross-map bodies and persistent death/revival have focused native tests.
Armor, shields and selected melee weapons use the same owned inventory.
Full roster, ranged/magic equipment, campaign integration, legacy/full-package
verification and the final manual handoff remain pending. Separate PRs cover
#429 formations, #431 profiling, #432 derived caches and the #433 evaluation
(no measured gain, no production adoption). No V5.11 acceptance or merge is claimed.
''' + source[end:]
write('README.md', source)

source = read('docs/CONTEXT.md')
start = source.index('**V5.11 active')
end = source.index('**V5.10 accepted', start)
source = source[:start] + '''**V5.11 active (5.11.4/#430):** companion checkpoint, unfinished.
#431/PR575; #429/PR576; #432/PR577; #433/PR578 (no candidate adoption).
#430: native roster/bonds, dialogue UI, trust/consent, orders, travel, death,
armor/shields/melee. validation_v5_11_4; remaining work in TASKS.
Manual handoff after completion; unaccepted/unmerged.
Keep-awake PID42276; stop build/issue429/keep-awake-511-20261030.stop
in issue429 worktree. Release on return.
''' + source[end:]
write('docs/CONTEXT.md', source)

source = read('docs/PROJECT.md')
start = source.index('## V5.11 implementation')
end = source.index('\n## V5.10 complete', start)
source = source[:start] + '''## V5.11 implementation - 5.11.4 (#430, 2026-10-30)

#429 formations, #431 profiling and #432 derived caches have PRs576/575/577.
#433/PR578 records the conditional distant-search evaluation without adoption.
#430 now has a tested companion foundation: persistent native bodies/items,
dialogue administration, private trust, social consent, orders, map travel,
death/revival and initial equipment administration. It is not complete: TASKS
lists the remaining inventory/combat/roster/campaign and verification work.
The combined manual handoff waits for completion. No author acceptance or merge.
''' + source[end:]
write('docs/PROJECT.md', source)

source = read('docs/TASKS.md').replace('## V5.11 active - 5.11.3', '## V5.11 active - 5.11.4', 1)
start = source.index('- #430:')
end = source.index('- #432:', start)
source = source[:start] + '''- #430: unfinished companion implementation on its focused branch. Dialogue
  administration, native transfers, private trust/consent, following/waiting,
  cross-map bodies, persistent death and the existing revival service have
  focused native coverage. Subcaptain uses Domingo and 20 per attribute.
  Armor/shields are native pieces; selected melee uses the resident catalogue.
  Remaining: ranged/magic/clothing administration; size compatibility and
  gift provenance through other split/merge paths; seven-companion capacity,
  full-party revival, all nine authored recruits, campaign subcaptain spawn,
  prison extraction/rewards, actual selected-weapon combat, UI visual review,
  full package and accepted-save/rollback regression. Recheck equipped item
  state after combat/death and old model-only loadouts before claiming completion.
''' + source[end:]
write('docs/TASKS.md', source)

insert('docs/SYSTEMS.md', '''## Companion contract and implementation checkpoint (5.11.4, #430)

The authored roster is the four mansion residents, four freed sewer prisoners
and the siege subcaptain (Domingo appearance, every attribute20). Recruitment
is free through dialogue: residents in the mansion, prisoners after release,
subcaptain after siege start. The party holds eight members including its player.
Follow/wait/dismiss preserve native bodies and items. Unfinished prisoner escort
objectives survive dismissal; other dismissed companions wait at their location.
Mansion narrative protection stays local; campaign death is persistent.

A dead member retains the slot through exactly3 world days, releases it only
after that deadline, and is never automatically revived/deleted. The existing
resurrection ability and its requirements remain authoritative. A revived member
whose slot was released waits if the party is full, until invited with room.

Trust begins at0, caps at100, and gifts add base copper value/1000, retaining
fractions. Returning and gifting the same item cannot award trust again.
Companion-owned retrieval uses Charisma and the current social formula with
difficulty120, reputation and (1+trust/100), capped at100percent. Lent player
items return without a roll. A refusal persists for that item until trust or
narrative stage changes. Companions never choose the player's dialogue.

Implemented checkpoint: revisioned party/bond inventory; whole-instance item
transfers and private records; dialogue order/inventory UI; native travel and
parking of waiting/dead bodies; armor/shield materialization without changing
weight or ownership; selected melee via shared resident attack rules. The
inventory list's E action equips/removes supported pieces; Enter requests or
gifts, L lends. Consented retrieval removes equipped defense before transfer.
Ranged/magic/clothing equipment and remaining integration checks are unfinished,
not silently replaced by invented gear restrictions. Full status: TASKS.

Queries use the bounded nine-identity roster and local placement/visibility.
Mansion residents register at birth/return. Legacy saves may rebuild the four
resident references once per map revision; this is not a routine per-NPC scan.
The previous repeated post-trial Rulo lookup now uses that registry.
''')

insert('docs/HISTORY.md', '''## 5.11.4 - Companion implementation checkpoint (#430, 2026-10-30)

Unfinished and not author-accepted. Approved roster, free recruitment, party
capacity, three-day death-slot boundary, native resurrection, trust and consent
are recorded in SYSTEMS and issue430. No new balance or story was invented.

The checkpoint adds native companion identities, shared formation orders,
dialogue administration, gifts/loans/social retrieval and saved private trust.
Actual bodies and inventory travel; waiting/dead bodies park against their
source map. Armor and subcaptain shield/sidearm models become native pieces
once, preserving wear/contamination and avoiding duplicate carried weight.
Selected melee reuses resident tools; other equipment paths remain unfinished.
Old player saves gain no automatic recruits and remain archived for rollback.

Focused overlay evidence: equipment-a26 PASS; death-a29 PASS; revival-a5 PASS.
Earlier inventory reload2 PASS and travel-a19 PASS preceded equipment binding.
Waiting-return-e4 PASS verifies a parked save and return after500 active tics;
the body settles1.35 map units from its anchor and remains in its collision
footprint, with no further drift between100 and500tics. The initial <1-unit
assertion was overstrict for native settling. A separate failed fixture queued
save/changemap in one tic; separate runs now verify both transitions. Failed
iterations remain local and are not counted as passing evidence.

The native death test uses actual DamageMobj and the approved shared resurrection
service, preserving seven diagnostic token units through death, hub travel and
revival. It does not replace ability-level cost/eligibility or full-campaign QA.
Remaining work is explicit in TASKS. No manual handoff or acceptance is claimed.
''')

insert('docs/ASSETS.md', '''### Companion checkpoint (5.11.4, #430)

The subcaptain reuses the owned Domingo body/frames and the existing guard
equipment catalogue; the four residents and prisoner appearances are unchanged.
The party panel reuses the shared journal/menu presentation and bilingual text.
No new raster art, external assets or attribution changes are introduced.
''')

for name in ['src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs']:
    write(name, read(name).replace('[Caelum 5.11.3]', '[Caelum 5.11.4]'))

evidence = {'issue': 430, 'release': '5.11.4', 'status': 'unfinished checkpoint',
            'author_acceptance': False, 'runs': {}}
for name in ['equipment-a', 'death-a', 'revival-a', 'waiting-return-e']:
    evidence['runs'][name] = json.loads(read('build/issue430/' + name + '.json'))
write('assets/validation_v5_11_4/summary.json', json.dumps(evidence, indent=2) + '\n')
print('Recorded unfinished companion checkpoint; remaining work stays explicit.')
