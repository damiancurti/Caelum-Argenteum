"""Apply the one-time 5.7.8 foundation status update to existing canonical docs."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
headers = ['AGENTS.md', 'README.md', 'docs/ASSETS.md', 'docs/CONTEXT.md',
           'docs/HISTORY.md', 'docs/MAP01.txt', 'docs/PROJECT.md',
           'docs/SPRITE_ART_DIRECTION.md', 'docs/SYSTEMS.md', 'docs/TASKS.md']
for name in headers:
    path = ROOT / name
    text = path.read_text(encoding='utf-8')
    marker = 'Current release: 5.7.7' if name == 'README.md' else 'Documentation version: **5.7.7**'
    text = text.replace(marker, marker.replace('5.7.7', '5.7.8'), 1)
    path.write_text(text, encoding='utf-8', newline='\n')

sections = {
    'docs/PROJECT.md': '''## 5.7.8 - Support calculation foundation (#479, incomplete delivery)

The author approved four support roles, M2 potency/duration, shared uncapped
stacks with refresh, independent benefits/curses, current-max-health integration,
secondary factor F, costs/preparation and offensive-item migration. This patch
implements only the shared data and serializable effect calculation state.
It does not yet change playable weapons, selectors, recipes, damage or movement.
Native model/save tests are recorded in assets/validation_578/RESULTS.md.
The complete #479 implementation remains open; see TASKS for unresolved data.
The author requested deferring questions and manual tests until returning.

''',
    'docs/SYSTEMS.md': '''## #479 approved support contract and 5.7.8 implementation boundary

The following author-approved target design supersedes the old Book/Statuette
roles when #479 is fully integrated. Current playable behavior is still the
offensive matrix below; 5.7.8 adds calculation/data classes without wiring them
into actors or selectors. This is an incomplete implementation, not a balance
change to existing weapons.

| Support role | Polarity / scope | T1 Anima | Secondary speed/damage modifiers |
| --- | --- | --- | --- |
| Book | Curse / area | 70 | No |
| Censer | Benefit / same area | 70 | No |
| Statuette | Benefit / single target | 100 | Yes |
| Ritual effigy | Curse / single target | 100 | Yes |

All use Quintessence; base area references ESSENCE_EXPLOSION_BASE_RADIUS (128),
and preparation references the current 14-tic cycle. T2/T3 costs multiply by
1.6/2.5; existing Eloquence modifiers remain required at the future integration
boundary. Support is instantaneous at the visible target, beneficial secondary
attack permits self-targeting, and initial support has no charged attack.
Benefits target self/allies and curses target enemies.

Each application contributes 1% times current M2 per second and resets duration
to 1 second times M2. Charisma supplies curse M2; Empathy supplies benefit M2.
M2 is 1 at level 0 and 4 at level 100; existing effective levels remain uncapped.
Casters share stacks of the same effect class, with no cap; opposite polarities
coexist. Each integration interval samples current maximum health. For intensity
p, F=1+p/100: enhancement multiplies movement and outgoing damage and divides
incoming damage; weakening does the inverse. Independent action timers are not
changed. The calculation state never mutates base attributes, so expiry returns
its factor to one without cumulative drift. It retains fractional seconds and
returns fractional HP before recipient mitigation/rounding. Revision 1 is
idempotent; unknown future revisions are preserved without execution.

Approved migration maps old offensive Books to Scepters and Statuettes to Orbs,
preserving item IDs, element, tier, wear and learned recipes. Offensive attack,
charge and cost behavior follows the old implements. New support entries remain
separate. No migration has run in this foundation patch.

Source audit: native slot 0 currently holds offensive Quintessence variants,
whereas the internal magical family is 6. Reserving slot 0 exclusively for
support therefore also needs the destination of those offensive selectors.
New support masses, fabrication and economy are not supplied. Existing seal
resistance to Quintessence is 0.85; how support mitigation and the requested rare
distribution interact remains to be decided. These are deferred decisions,
not authorization to invent values or bypass current resistances.

''',
    'docs/TASKS.md': '''## #479 / 5.7.8 - Partial foundation; integration remains open

Implemented: approved support data, uncapped M2 rate/duration, serializable
same-class accumulation, duration reset, dynamic-maximum fractional integration
and stateless secondary factor. Native model/save evidence belongs exclusively
to assets/validation_578. There is no author acceptance claim or new manual test
for this unexposed calculation layer.

Deferred author decisions (questions postponed at the author's request):
- Destination of offensive Quintessence selectors when native slot 0 is reserved
  for support; internal magical family 6 is a different identifier.
- New support implement masses, material recipes, prices, acquisition and stock.
- Exact support mitigation/resistance rules and rare Quintessence distribution;
  current seals already retain 85% of Quintessence health damage.
- Effect-class identity when area and single-target implements overlap, so health
  and secondary stacks cannot accidentally double or share unintended modifiers.

Remaining implementation: playable selectors/catalogue and bilingual views,
approved save/learned-recipe migration, cast targeting/local area queries,
authoritative health/damage/movement integration, owned art, profession/NPC/tutorial
audit and native end-to-end tests. Do not close #479 on the foundation alone.

''',
    'docs/HISTORY.md': '''## 5.7.8 - Support calculation foundation (#479, partial)

2026-10-22: recorded the author's approved M2, F, stacking, targeting, migration
and casting parameters. Added shared support data and a serializable calculation
state with fractional integration and expiry; existing gameplay is unchanged.
Source audit found native slot 0 is occupied by offensive Quintessence selectors,
new support economy/fabrication lacks values, and current seals already mitigate
Quintessence. Questions and manual tests are deferred until the author returns.
Evidence: assets/validation_578/RESULTS.md. Full integration, migration and author
acceptance remain outstanding. #481 retains its separate CA481-01 pending entry.

''',
    'docs/ASSETS.md': '''## 5.7.8 - #479 foundation asset boundary

This partial patch adds no runtime art and does not repurpose accepted #471
assets. assets/validation_578 contains only an isolated deterministic fixture,
source audit and native evidence. No engine, IWAD, PK3 or save is distributed.
New implement artwork belongs to the remaining #479 integration scope.

''',
}
for name, section in sections.items():
    path = ROOT / name
    text = path.read_text(encoding='utf-8')
    if section.splitlines()[0] not in text:
        position = text.index('\n\n', text.index('Documentation version:')) + 2
        text = text[:position] + section + text[position:]
    path.write_text(text, encoding='utf-8', newline='\n')
path = ROOT / 'docs/CONTEXT.md'
text = path.read_text(encoding='utf-8')
line = '**5.7.8/#479:** support-state;validation_578;integration/decisions-pending.\n'
if line not in text:
    text = text.replace('**5.7.7/#481:**', line + '**5.7.7/#481:**', 1)
path.write_text(text, encoding='utf-8', newline='\n')
path = ROOT / 'README.md'
text = path.read_text(encoding='utf-8')
paragraph = ('V5.7.8 adds the support-effect calculation foundation (#479), with native\n'
             'model/save checks in `assets/validation_578/RESULTS.md`. Playable integration,\n'
             'migration and pending design values remain unfinished. Manual tests and\n'
             'questions are deferred until the author returns.\n\n')
if paragraph not in text:
    text = text.replace('V5.7.7 adds', paragraph + 'V5.7.7 adds', 1)
path.write_text(text, encoding='utf-8', newline='\n')
for name in ['src/caelum/world/CaelumPhysicalHazards.zs', 'src/caelum/world/CaelumSewerMaze.zs']:
    path = ROOT / name
    path.write_text(path.read_text(encoding='utf-8').replace('5.7.7', '5.7.8'), encoding='utf-8', newline='\n')
