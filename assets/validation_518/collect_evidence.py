"""Preserve selected untouched native PNGs and compare the recorded flight data."""
from pathlib import Path
import hashlib, html, json, re, shutil

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue137'


def main():
    captures = HERE / 'captures'
    captures.mkdir(exist_ok=True)
    groups = []

    def pair(title, before, after):
        groups.append((title, [before, after]))

    families = ['Fire', 'Light', 'Water', 'Ice', 'Earth', 'Poison', 'Air', 'Lightning', 'Quintessence']
    for view, view_name in enumerate(['Side', 'Outgoing', 'Incoming']):
        for kind, family in enumerate(families):
            stage = view * 9 + kind
            pair(f'{family}: {view_name}',
                 f'gallery-before-final-c-flight-{stage}-early.png',
                 f'gallery-cells-final-flight-{stage}-early.png')
    for suffix in ['statuses-dark', 'statuses-motion', 'statuses-bright']:
        pair(suffix, f'gallery-before-final-c-{suffix}.png', f'gallery-cells-final-{suffix}.png')
    pair('Rat / bull / Zupay / Mandinga', 'sizes-before-final-varied-sizes.png',
         'gallery-cells-final-varied-sizes.png')
    for stage, title in [(0, 'Arrow'), (1, 'Bolt'), (2, 'Carbine bullet'),
                         (3, 'Shotgun pellet'), (4, 'Javelin'), (5, 'Mandinga breath'),
                         (6, 'Zupay breath'), (12, '25% Health hit'), (14, '9% Health'),
                         (16, '9% Lucidity'), (17, 'Combined Health and Lucidity')]:
        pair(title, f'showcase-before-final-showcase-{stage}-b.png',
             f'showcase-cells-final-showcase-{stage}-b.png')
    groups.append(('Real immersion, all nine elements', ['water-cells-final-submerged.png']))
    groups.append(('Native ballistic javelin', [f'showcase-cells-final-javelin-{p}.png'
                                               for p in ['up', 'apex', 'down']]))
    pair('500 living combatants, native attacks', 'battle-before-final-dense-battle.png',
         'battle-cells-final-dense-battle.png')
    for stage in [0, 3, 7, 8, 11, 15]:
        pair(f'Death frame {stage}: initial reconstruction (superseded)',
             f'deathframes-before-death-frame-{stage}.png',
             f'deathframes-after-death-frame-{stage}.png')
    for stage in range(16):
        pair(f'Death frame {stage}: recovered original art',
             f'deathframes-before-death-frame-{stage}.png',
             f'deathframes-original-final-death-frame-{stage}.png')
    for stage in range(10):
        groups.append((f'All animal sprites: native inspection page {stage+1}',
                       [f'animals-original-final-animals-{stage}.png']))
    groups.append(('Production death sequences: original art, actual corpse scale',
                   ['deathframes-original-final-domingo-corpse.png',
                    'deathframes-original-final-rat-corpse.png']))

    records = []
    run_names = sorted((p.name[:-9] for p in HERE.glob('*-run.json')), key=len, reverse=True)
    sections = []
    for title, names in groups:
        figures = []
        for name in names:
            source = WORK / name
            assert source.is_file(), source
            shutil.copyfile(source, captures / name)
            label = next(label for label in run_names if name.startswith(label + '-'))
            run = json.loads((HERE / (label + '-run.json')).read_text(encoding='utf-8-sig'))
            records.append({'file': 'captures/' + name, 'run': label,
                            'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                            'package_sha256': run['package_sha256'],
                            'addon_sha256': run['addon_sha256']})
            figures.append(f'<figure><a href="captures/{name}"><img loading="lazy" src="captures/{name}"></a>'
                           f'<figcaption>{html.escape(label)}</figcaption></figure>')
        sections.append(f'<section><h2>{html.escape(title)}</h2><div>{"".join(figures)}</div></section>')
    (HERE / 'CAPTURES.json').write_text(json.dumps(records, indent=2) + '\n', encoding='utf-8')
    (HERE / 'GALLERY.html').write_text('''<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>CA137 native comparison</title>
<style>body{background:#16161b;color:#eee;font:16px system-ui;margin:2rem}section{margin:2rem 0}
section div{display:flex;flex-wrap:wrap;gap:1rem}figure{margin:0;flex:1;min-width:340px}
img{width:100%}figcaption{font-size:13px;color:#bbb}h2{font-size:19px}p{max-width:85ch}</style>
<h1>Issue #137: native before / after</h1><p>Original unedited GZDoom screenshots.
Paired scenes show baseline on the left and the final measured-cell atlas on the right.
Click to inspect full resolution. The physical model showcase uses slowed inspection shots;
full-speed trajectory assertions are separate. See RESULTS.md for settings, limitations and
pending author acceptance.</p><section><h2>Flight through open space: nine families, three viewpoints</h2>
<p>Sampled native frames every two game tics, encoded at 17.5 FPS without audio.
These clips show motion, not a presented-FPS measurement.</p><div>
<figure><video controls preload="metadata" style="width:100%" src="flight-video-before.mp4"></video><figcaption>Before</figcaption></figure>
<figure><video controls preload="metadata" style="width:100%" src="flight-video-after.mp4"></video><figcaption>After</figcaption></figure>
</div></section>''' + '\n'.join(sections) + '</html>\n', encoding='utf-8')

    def trace(label):
        return [s for s in (HERE / (label + '.txt')).read_text(encoding='utf-8-sig').splitlines()
                if s.startswith('CA137 TRACE')]
    before, after = trace('invariance-before-a'), trace('invariance-cells-final')
    assert len(before) == len(after) == 623 and before == after
    (HERE / 'INVARIANCE.json').write_text(json.dumps({
        'baseline': 'invariance-before-a', 'current': 'invariance-cells-final',
        'identical_trace_records': len(before),
        'trace_sha256': hashlib.sha256('\n'.join(before).encode()).hexdigest()}, indent=2) + '\n')
    print(f'Preserved {len(records)} unedited native PNGs; 623 identical gameplay traces.')


if __name__ == '__main__':
    main()
