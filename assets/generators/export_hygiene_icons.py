"""Export approved-style painted sources without repainting their artwork."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]


def main():
    folder = ROOT / 'assets/art_source/hygiene'
    manifest = json.loads((folder / 'PROMPTS.json').read_text(encoding='utf-8'))
    previews = folder / 'icons'
    previews.mkdir(exist_ok=True)
    records = []
    for asset in manifest['assets']:
        source = folder / asset['source']
        image = Image.open(source).convert('RGBA')
        alpha = image.getchannel('A')
        assert alpha.getextrema()[0] == 0 and alpha.getbbox(), source
        image = image.crop(alpha.getbbox())
        image.thumbnail((120, 120), Image.Resampling.LANCZOS)
        output = Image.new('RGBA', (128, 128))
        output.alpha_composite(image, ((128-image.width)//2, (128-image.height)//2))
        target = previews / (asset['name']+'.png')
        output.save(target, optimize=False)
        records.append({'source':source.relative_to(ROOT).as_posix(),
                        'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
                        'preview':target.relative_to(ROOT).as_posix(),
                        'preview_sha256':hashlib.sha256(target.read_bytes()).hexdigest()})
    (folder/'EXPORT.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
    print('Exported four 128px painted previews; runtime item registration remains separate.')


if __name__ == '__main__':
    main()
