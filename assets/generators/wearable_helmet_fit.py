"""Wearable helmet geometry and the covered head that fits inside its metal shell."""
from functools import lru_cache
import json
import re

import numpy as np

from character_mesh_frames import ROOT

SOURCE = ROOT / "assets/source/art/inventory_models_647/armor_helmets"
REGISTRY = ROOT / "src/caelum/character/CaelumAppearanceRegistry.zs"
# Player-model units measured on the neutral human skull. The shell is a
# continuous ellipse. Accessories and uncovered ears never size the metal.
INNER_DEPTH = 13.65
INNER_WIDTH = 11.7
BRIM = 159.25
RISE = 0.47


@lru_cache(maxsize=1)
def stature():
    values = re.search(r"heights\[\] = \{([^}]+)", REGISTRY.read_text("utf8"))[1]
    heights = np.array([float(n) for n in values.split(",")])
    return heights[::4] / heights[0]


@lru_cache(maxsize=4)
def crown(material):
    design = json.loads((SOURCE/"DESIGN.json").read_bytes())
    export = json.loads((SOURCE/"EXPORT.json").read_bytes())
    bowl = next(p for p in design["families"][material]["parts"] if p["part"]=="hollow_crown")
    rows = np.array(bowl["rows"])
    inside = rows[len(rows)//2:]
    z = bowl["offset"][2] - inside[:,0]
    return (export["variants"][material]["source_to_native"], abs(bowl["rotation"][0][0]),
            z, inside[:,3])


def fit_helmet(points, family, material):
    source, width_factor, z, radii = crown(material)
    local = points / source["factor"]
    scale = width_factor * radii[0]
    return np.column_stack((-local[:,1]*INNER_DEPTH/scale, local[:,0]*INNER_WIDTH/scale,
                            BRIM + (local[:,2]+source["floor"]-z[0])*RISE)) * stature()[family]


def tuck(points, family):
    # Compress free tips smoothly in height, leaving the lower face and neck
    # intact. Nest the crown, ears and upper hair inside the actual inner loft.
    size = stature()[family]
    local = points.copy()/size
    z = local[:,2].copy()
    above = np.maximum(z-163,0)
    local[:,2] = np.minimum(z,163) + 8*(1-np.exp(-above/8))
    _,_,levels,radii = crown("heavy")
    heights = BRIM + (levels-levels[0])*RISE
    clearance = np.interp(local[:,2]+.55,heights,radii)/radii[0]
    ellipse = np.hypot(local[:,0]/INNER_DEPTH,local[:,1]/INNER_WIDTH)
    factor = np.minimum(1, .94*clearance/np.maximum(ellipse,1e-6))
    # The lower skirt of the visor is open at the throat. Blend into the
    # cheek and the nape, keeping points below it in their original position.
    covered = np.clip((z-141)/7,0,1)
    local[:,:2] *= (1+covered*(factor-1))[:,None]
    return local*size
