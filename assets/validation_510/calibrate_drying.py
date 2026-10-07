"""Fit water capacities to the approved coupled reference drying times.

Independent scalar reference: 80 kg, 1.75 m, 22 C, RH 50%, wind 1 m/s,
initial E=0, saturated uniform outfit, no rain/activity/acclimation. The native
solver must separately reproduce these times. Capacities are game calibration,
not measured textile properties. No runtime code is generated or changed.
"""
import json
import math
from pathlib import Path

AREA = .202 * 80**.425 * 1.75**.725
GREF = AREA / (.155 * .5 + 1 / (8.6 * .137**.53 + 4.7))
INERTIA = 1200 * GREF
REST = AREA * 58.2
OFFSET = REST / GREF
FILM = 8.6 + 4.7
LATENT = 2450000
LEWIS = 16.5013576
MATERIALS = [("light_cloth", .5, .9, 3600),
             ("thick_cloth", 1, .75, 7200),
             ("leather", 1.2, .45, 10800),
             ("thick_leather", 1.8, .3, 18000)]


def vapor(celsius):
    return .611 * 10 ** (7.5 * celsius / (237.3 + celsius))


def remaining(capacity_per_area, clo, permeability, seconds, step=1):
    capacity = capacity_per_area * AREA
    water, exposure = capacity, 0.0
    for elapsed in range(0, seconds, step):
        dt = min(step, seconds - elapsed)
        surface = 22 + (OFFSET + exposure) / (1 + .155 * clo * FILM)
        loss = min(water, dt * AREA * permeability * LEWIS * 8.6
                   * max(0, vapor(surface) - .5 * vapor(22)) / LATENT)
        before = water / capacity
        water -= loss
        after = water / capacity
        conductance = AREA / (.155 * clo + 1/FILM) * (1 + before + after)
        imbalance = REST - conductance * OFFSET - loss * LATENT / dt
        equilibrium = imbalance / conductance
        exposure = equilibrium + (exposure-equilibrium) * math.exp(-conductance*dt/INERTIA)
    return water / capacity


def main():
    results = []
    for name, clo, permeability, duration in MATERIALS:
        low, high = 1e-9, 10.0
        for _ in range(38):
            middle = (low+high)/2
            if remaining(middle, clo, permeability, duration) <= 1e-6:
                low = middle
            else:
                high = middle
        results.append(dict(material=name, target_world_seconds=duration,
                            water_capacity_kg_per_m2=low,
                            practically_dry_percent=0.0001,
                            reference_step_seconds=1))
    path = Path(__file__).with_name('DRYING_CALIBRATION.json')
    path.write_text(json.dumps(results, indent=2)+'\n', encoding='utf-8')
    print(path.read_text(encoding='utf-8'))


if __name__ == '__main__':
    main()
