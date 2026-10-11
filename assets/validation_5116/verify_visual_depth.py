"""Measure rear-arc occlusion from unchanged native captures, without editing them."""
import argparse
import json
from pathlib import Path
from PIL import Image


def measure(folder):
    images = {}
    for key, name in [('body', 'ropes-body'), ('rear', 'ropes-rear-only'),
                      ('combined', 'ropes-rear-body'), ('background', 'ropes-background')]:
        with Image.open(folder / (name + '.png')) as image:
            images[key] = image.convert('RGB')
    assert all(image.size == (1280, 720) for image in images.values())
    # Exclude the HUD and weapon. All four captures keep camera/body fixed.
    overlap = hidden = visible_rear = 0
    maximum_difference = 0
    for y in range(200, 640):
        for x in range(500, 780):
            pixels = {key: image.getpixel((x, y)) for key, image in images.items()}
            difference = lambda a, b: max(abs(c-d) for c, d in zip(pixels[a], pixels[b]))
            if difference('rear', 'background') <= 12:
                continue
            visible_rear += 1
            if difference('body', 'background') <= 16:
                continue
            overlap += 1
            delta = difference('combined', 'body')
            maximum_difference = max(maximum_difference, delta)
            if delta <= 3:
                hidden += 1
    result = {'roi': [500, 200, 780, 640], 'rear_pixels': visible_rear,
              'rear_body_overlap_pixels': overlap, 'occluded_overlap_pixels': hidden,
              'occluded_fraction': hidden / overlap if overlap else 0,
              'maximum_overlap_difference': maximum_difference}
    # Anti-aliased boundaries can blend; opaque body pixels must dominate.
    result['passed'] = overlap > 100 and result['occluded_fraction'] > 0.95
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('folder', type=Path)
    args = parser.parse_args()
    result = measure(args.folder)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['passed'] else 1)
