"""Fit the inventory helmet shell, visor and plume around the current player sculpts."""
from functools import lru_cache
import json

import numpy as np
from scipy.spatial import ConvexHull
from scipy.ndimage import gaussian_filter, maximum_filter

from character_mesh_frames import ROOT, read_model


PLAYERS = ROOT / "src/models/caelum/players"
SOURCE = ROOT / "assets/source/art/inventory_models_647/armor_helmets"


def vertices(path):
    return np.vstack([surface.positions[0] for surface in read_model(path.read_bytes())])


@lru_cache(maxsize=7)
def profile(family):
    # Use the same shell for the two sexes. Loose hair below the brow hangs out
    # of the helmet; only the scalp and the upper hair belong inside the bowl.
    heads = [vertices(path) for i in (2*family, 2*family+1)
             for path in sorted(PLAYERS.glob(f"head{i}_*.md3"))]
    points = np.vstack(heads)
    brow = (points[:, 2].min() + 0.68 * (np.quantile(points[:, 2], 0.99) - points[:, 2].min()))
    hair = [vertices(path) for i in (2*family, 2*family+1)
            for path in sorted(PLAYERS.glob(f"hair{i}_*.md3"))]
    if hair:
        cap = np.vstack(hair)
        points = np.vstack((points, cap[cap[:, 2] >= brow]))
    top = points[:, 2].max() + 4
    return brow, top, ConvexHull(np.unique(points, axis=0)).equations


@lru_cache(maxsize=28)
def shell(family, material):
    design = json.loads((SOURCE/"DESIGN.json").read_bytes())
    export = json.loads((SOURCE/"EXPORT.json").read_bytes())
    parts = {part["part"]: part for part in design["families"][material]["parts"]}
    crown = parts["hollow_crown"]
    crown_top = crown["offset"][2]
    brim = max(row[0] for row in parts["brow"]["rows"])
    # The return side of the crown loft is its inner wall, from rim to tip.
    rows = np.array(crown["rows"])
    inside = rows[len(rows)//2:]
    inner_z = crown_top - inside[:, 0]
    brow, top, planes = profile(family)
    levels = np.linspace(5, crown_top, 72)
    height = np.interp(levels, [levels[0], brim, crown_top], [brow-15, brow, top])
    radial = np.interp(levels, inner_z, inside[:, 3]) * abs(crown["rotation"][0][0])
    # Horizontal rays from the skull axis intersect the convex envelope of
    # every supported face. Fit the visor as well, particularly on muzzles.
    theta = np.arange(96)*2*np.pi/96
    directions = np.stack((np.cos(theta), np.sin(theta)))
    facing = planes[:, :2] @ directions
    scales = []
    for z, radius in zip(height, radial):
        distance = np.full(facing.shape, np.inf)
        np.divide(-(planes[:, 2:3]*z + planes[:, 3:4]), facing, out=distance, where=facing>1e-7)
        reach = np.min(distance, axis=0)
        # A slight shell clearance also accounts for the polygonal visor and
        # angular interpolation between rays. The apex and ornament stay round.
        scale = np.maximum(0.42, (np.maximum(reach, 0)+1.8)/max(radius, 4))
        scales.append(scale)
    source = export["variants"][material]["source_to_native"]
    # A sheet-metal bowl bridges local features. Dilating before smoothing
    # retains clearance between the sparse rings of the original inventory loft.
    raw = np.asarray(scales)
    wide = maximum_filter(raw, size=(11, 11), mode=("nearest", "wrap"))
    smooth = gaussian_filter(wide, sigma=(2.0, 2.5), mode=("nearest", "wrap"))
    plume_skins = {design["materials"][part["material"]]["texture"] for part in parts.values()
                   if part["part"].startswith("plume_") and part["part"] != "plume_mount"}
    return source, brim, crown_top, brow, top, levels, np.maximum(raw, smooth), plume_skins


def fit_helmet(points, family, material, shader):
    source, brim, peak, brow, top, levels, scales, plume_skins = shell(family, material)
    original = points / source["factor"]
    z = original[:, 2] + source["floor"]
    forward, left = -original[:, 1], original[:, 0]
    if shader in plume_skins:
        # Feathers hang outside the bowl and keep their original sweep.
        rise = (top-brow)/(peak-brim)
        return np.column_stack((forward*rise, left*rise, top+(z-peak)*rise))
    direction = (np.arctan2(left, forward) % (2*np.pi)) * scales.shape[1]/(2*np.pi)
    level = np.interp(z, levels, np.arange(len(levels)))
    lo = level.astype(int)
    hi = np.minimum(lo+1, len(scales)-1)
    angle = direction.astype(int) % scales.shape[1]
    next_angle = (angle+1) % scales.shape[1]
    u, t = direction-np.floor(direction), level-lo
    scale = (1-t)*((1-u)*scales[lo, angle]+u*scales[lo, next_angle])
    scale += t*((1-u)*scales[hi, angle]+u*scales[hi, next_angle])
    fitted_z = np.interp(z, [levels[0], brim, peak], [brow-15, brow, top])
    fitted_z += np.maximum(0, z-peak)*(top-brow)/(peak-brim)
    return np.column_stack((forward*scale, left*scale, fitted_z))
