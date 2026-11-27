"""Build a textured, closed mesh from registered views of the same pose.

The project authors own the source images. The resulting vertices and UVs are
independent of the camera. NumPy, SciPy, scikit-image, fast-simplification and
Pillow are optional authoring dependencies.
"""
import io
import math

import fast_simplification
import numpy as np
from PIL import Image
from scipy import ndimage
from skimage.measure import marching_cubes

from generate_nahuelito_model import Mesh, fixed, md3


def silhouette(image):
    image = image.convert("RGBA")
    box = image.getchannel("A").point(lambda n: 255 if n >= 90 else 0).getbbox()
    if not box:
        raise ValueError("Source view has an empty silhouette")
    return image.crop(box)


def shape_and_skin(images, height, shader, model_name, max_faces=3600):
    """Return a single-frame MD3 and its atlas; rotations are counterclockwise."""
    views = [(angle, silhouette(im)) for angle, im in sorted(images.items())]
    unit = 96
    masks, panels, directions, widths = [], [], [], []
    for angle, image in views:
        width = max(4, round(unit * image.width / image.height))
        mask = np.asarray(image.getchannel("A").resize((width, unit), Image.Resampling.LANCZOS)) >= 96
        # Signed distance and a two-cell border retain an exterior for marching cubes.
        mask = np.pad(mask, 5)
        masks.append(ndimage.distance_transform_edt(mask) - ndimage.distance_transform_edt(~mask))
        widths.append(width)
        t = math.radians(angle)
        directions.append((math.cos(t), math.sin(t)))
        panel = image.copy()
        panel.thumbnail((248, 248), Image.Resampling.LANCZOS)
        pixels = np.asarray(panel)
        nearest = ndimage.distance_transform_edt(pixels[:, :, 3] < 90, return_distances=False, return_indices=True)
        panels.append(Image.fromarray(pixels[nearest[0], nearest[1], :3]))
    half = int(max(widths) / 2) + 8
    step = max(0.9, half / 78)
    hor = np.arange(-half, half + step, step, dtype=np.float32)
    vert = np.arange(-4, unit + 5, step, dtype=np.float32)
    x, y, z = np.ogrid[:len(hor), :len(hor), :len(vert)]
    x, y, z = hor[x], hor[y], vert[z]
    distances = []
    for (cosine, sine), sdf, width in zip(directions, masks, widths):
        col = np.rint(-sine*x + cosine*y + (width-1)/2 + 5).astype(int)
        row = np.rint(unit-1-z + 5).astype(int)
        distances.append(sdf[np.clip(row, 0, sdf.shape[0]-1), np.clip(col, 0, sdf.shape[1]-1)].astype("f"))
    if len(distances) == 1:
        # Single-view death frames have no recorded reverse. Round their depth
        # from the local silhouette thickness and keep the original painted face.
        front = distances[0]
        field = np.minimum(front, 0.30*np.maximum(front,0) + np.sqrt(np.maximum(front,0))*2.9 - abs(x))
    else:
        # Small differences in a hand-painted turnaround must not sever limbs.
        # Give priority to the frontal outline and soften the side intersections.
        ordered = np.sort(np.stack(distances),axis=0)
        secondary = ordered[min(2,len(ordered)-1)]
        field = np.minimum(distances[0]+0.25, np.minimum(ordered[0]+3.2, secondary+0.4))
        if 90 in images:
            field = np.minimum(field, distances[[v[0] for v in views].index(90)]+1.3)
    for axis in range(3):
        for offset in (0,-1):
            sl = [slice(None)]*3
            sl[axis] = offset
            field[tuple(sl)] = -4
    smooth = ndimage.gaussian_filter(field,sigma=.82)
    verts, triangles, _, _ = marching_cubes(smooth,0,allow_degenerate=False)
    verts = verts.astype("d")*step + [hor[0],hor[0],vert[0]]
    if len(triangles)>max_faces:
        verts, triangles = fast_simplification.simplify(verts,triangles.copy(),target_count=max_faces)
    tri = verts[triangles]
    normals = np.cross(tri[:,1]-tri[:,0],tri[:,2]-tri[:,0])
    if np.sum(tri[:,0]*normals)<0:
        triangles=triangles[:,::-1].copy()
        normals=-normals
    facing = np.asarray(directions)
    owners = (normals[:,:2] @ facing.T).argmax(axis=1)
    cell_w=max(p.width for p in panels)+4
    cell_h=max(p.height for p in panels)+4
    columns=min(4,len(panels))
    atlas=Image.new("RGB",(columns*cell_w,math.ceil(len(panels)/columns)*cell_h))
    for j,p in enumerate(panels):
        atlas.paste(p,(cell_w*(j%columns)+2,cell_h*(j//columns)+2))
    mesh=Mesh()
    mapping={}
    for owner,tri in zip(owners,triangles):
        face=[]
        co,si=directions[owner]
        panel=panels[owner]
        for vertex in tri:
            key=(int(owner),int(vertex))
            if key not in mapping:
                xx,yy,zz=verts[vertex]
                u=np.clip((-si*xx+co*yy)/widths[owner]+0.5,0,1)
                v=np.clip(1-zz/unit,0,1)
                uv=((cell_w*(owner%columns)+2.5+u*(panel.width-1))/atlas.width,
                    (cell_h*(owner//columns)+2.5+v*(panel.height-1))/atlas.height)
                mapping[key]=mesh.vertex(verts[vertex]*height/unit,uv,"body")
            face.append(mapping[key])
        mesh.faces.append(("body",tuple(face)))
    points=np.array(mesh.vertices)
    points[:,2]-=points[:,2].min()
    binary,_,bounds=md3(mesh,[points.tolist()],{"body":shader})
    buf=io.BytesIO()
    atlas.save(buf,format="PNG")
    return binary[:8]+fixed(model_name,64)+binary[72:],buf.getvalue(),bounds[0]
