#!/usr/bin/env python3
"""Modelos originales 4.36.0b: roca esférica centrada y columna de palanca.

Reutiliza texturas propias. No modifica mapas ni los modelos ambientales.
"""
import math
from pathlib import Path
from generate_environment_models import Mesh


def generate():
    folder = Path(__file__).resolve().parents[2] / 'src/models/caelum/world/hazards'
    folder.mkdir(parents=True, exist_ok=True)
    rock = Mesh('ca_hazard_boulder')
    # Pivote en el centro, sin base recortada. El actor visual añade la altura.
    rock.add_ellipsoid('models/caelum/world/environment/rock_granite.png',
                       (0, 0, 0), (48, 48, 48), 436, rings=12, segments=24,
                       irregularity=0.035)
    # UV esféricas continuas: evitar repetir el granito completo en cada cara.
    rock.uvs = [(0.5 + math.atan2(z,x)/math.tau,
                 0.5 + math.asin(max(-1,min(1,y/48)))/math.pi)
                for x,y,z in rock.vertices]
    for _, indices in rock.faces:
        values=[rock.uvs[i-1][0] for i in indices]
        if max(values)-min(values)>0.5:
            for i in indices:
                u,v=rock.uvs[i-1]
                if u<0.5: rock.uvs[i-1]=(u+1,v)
    rock.write(folder / 'ca_hazard_boulder.obj')
    column = Mesh('ca_lever_column')
    stone = 'graphics/caelum/textures/sewer/CASWRWAL.png'
    # Sección cuadrada: una cara plana permite superponer el sprite de palanca.
    for y0, y1, half in [(0, 8, 18), (8, 88, 16), (88, 96, 18)]:
        a=(-half,y0,-half);b=(half,y0,-half);c=(half,y0,half);d=(-half,y0,half)
        e=(-half,y1,-half);f=(half,y1,-half);g=(half,y1,half);h=(-half,y1,half)
        for face in [(a,b,f,e),(b,c,g,f),(c,d,h,g),(d,a,e,h),(e,f,g,h),(d,c,b,a)]:
            column.add_quad(stone, face)
    column.write(folder / 'ca_lever_column.obj')


if __name__ == '__main__':
    generate()
