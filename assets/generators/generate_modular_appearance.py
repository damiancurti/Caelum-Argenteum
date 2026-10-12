"""Prepare authored modular sprites; requires Pillow 11.3.0 (author-approved).

Only source art is raster artwork. This deterministic technical pipeline cuts
modules, makes finite masked tones, poses a shared paper-doll rig and registers
native TEXTURES compositions. No complete identity/pose PNG product is stored.
"""
from pathlib import Path
from functools import lru_cache
import colorsys
import hashlib
import json
import math
from PIL import Image, ImageChops, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/appearance_5213'
OUT = ROOT / 'src/graphics/caelum/appearance'
SPEC = json.loads(Path(__file__).with_name('appearance_catalog.json').read_text())
SIZE = tuple(SPEC['canvas'])
PIVOT = tuple(SPEC['pivot'])
NECK = tuple(SPEC['neck'])
RESAMPLE = Image.Resampling.BICUBIC
RECORDS = {}


def tight(im):
    bounds = im.getchannel('A').point(lambda a: 255 if a >= 32 else 0).getbbox()
    assert bounds, 'Empty module'
    return im.crop(bounds)


@lru_cache(None)
def sheet(name):
    im = Image.open(SOURCE / name).convert('RGBA')
    w, h = im.size
    return [tight(im.crop((i % 4*w//4, i//4*h//2, (i % 4+1)*w//4, (i//4+1)*h//2))) for i in range(8)]


def save(im, name):
    path = OUT / (name + '.png')
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path, compress_level=9)
    RECORDS[path.relative_to(ROOT).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    return 'graphics/caelum/appearance/' + name + '.png'


def isolated(im, polygon):
    mask = Image.new('L', im.size)
    ImageDraw.Draw(mask).polygon(polygon, fill=255)
    result = im.copy()
    result.putalpha(ImageChops.multiply(im.getchannel('A'), mask))
    return result


def head_source(spec, view):
    if 'native' in spec:
        im = Image.open(ROOT / spec['native'].format(view=view+1)).convert('RGBA')
        bounds = im.getbbox()
        # Exclude the NPC's staff, axe and shoulder equipment from the head.
        center = im.width//2
        im = tight(im.crop((center-32, bounds[1], center+32,
                           bounds[1]+round((bounds[3]-bounds[1])*spec['height_fraction']))))
    else:
        im = sheet(spec['source'])[view]
        if 'height_fraction' in spec:
            im = tight(im.crop((0, 0, im.width, round(im.height*spec['height_fraction']))))
    height = spec['head_height']
    return im.resize((round(im.width*height/im.height), height), Image.Resampling.LANCZOS)


def skin_mask(im, kind, view):
    mask = Image.new('L', im.size)
    envelope=Image.new('L',im.size)
    draw=ImageDraw.Draw(envelope);w,h=im.size
    # Explicit facial envelopes protect hair beyond the skin-color classifier.
    if view in (0,1,7):
        draw.polygon([(w*.40,h*.32),(w*.61,h*.32),(w*.66,h*.62),(w*.58,h*.79),(w*.42,h*.79),(w*.33,h*.62)],fill=255)
        draw.rectangle((w*.10,h*.46,w*.26,h*.55),fill=255)
        draw.rectangle((w*.75,h*.46,w*.90,h*.55),fill=255)
        draw.rectangle((w*.44,h*.79,w*.58,h*.94),fill=255)
    elif view in (2,6):
        side=[(0,.29),(.58,.29),(.72,.62),(.64,.96),(.10,.96),(0,.64)]
        if view==6:side=[(1-x,y) for x,y in side]
        draw.polygon([(round(x*w),round(y*h)) for x,y in side],fill=255)
    elif view in (3,5):
        draw.rectangle((0 if view==3 else w*.67,h*.4,w*.33 if view==3 else w,h*.69),fill=255)
    else:
        draw.rectangle((0,h*.4,w*.16,h*.64),fill=255)
        draw.rectangle((w*.84,h*.4,w,h*.64),fill=255)
    pixels = []
    for (r, g, b, a), allowed in zip(im.getdata(),envelope.getdata()):
        h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
        # The head is isolated before masking. Protect dark hair, eye pupils,
        # silver hair and animal markings; masks are exported for inspection.
        selected = (0.015 < h < 0.13 and s > .18 and v > .28) if kind == 'skin' else (
            (g > r*1.10 and g > b*1.10 and s > .13 and v > .06) if kind == 'caelith'
            else v > .22 and a > 0)
        pixels.append(255 if selected and a > 0 and (kind in ('fur','caelith') or allowed) else 0)
    mask.putdata(pixels)
    return mask


def tone_image(im, mask, kind, tone):
    result = im.copy()
    data = []
    for pixel, active in zip(im.getdata(), mask.getdata()):
        r, g, b, a = pixel
        if not active or (tone == 0 and kind != 'caelith'):
            data.append(pixel)
            continue
        if kind == 'fur':
            factors = SPEC['fur_multipliers'][tone]
            rgb = [min(255, round(c*f)) for c, f in zip((r,g,b), factors)]
        else:
            palette = SPEC['caelith_tones'] if kind == 'caelith' else SPEC['skin_tones']
            source = max(1, .299*r+.587*g+.114*b)
            base = 105 if kind == 'caelith' else 138
            rgb = [min(255, round(c*source/base)) for c in palette[tone]]
        data.append((*rgb, a))
    result.putdata(data)
    assert result.getchannel('A').tobytes() == im.getchannel('A').tobytes()
    assert all(before == after for before, after, active in zip(im.getdata(), result.getdata(), mask.getdata()) if not active)
    return result


def rotate_at(im, angle, pivot):
    return im.rotate(angle, RESAMPLE, center=pivot)


def body_pose(original, view, pose):
    h = SPEC['body_height']
    body = original.resize((round(original.width*h/original.height), h), Image.Resampling.LANCZOS)
    w = body.width
    left = isolated(body, [(0,0),(.31*w,0),(.31*w,.32*h),(.25*w,.55*h),(0,.55*h)])
    right = isolated(body, [(.69*w,0),(w,0),(w,.55*h),(.75*w,.55*h),(.69*w,.32*h)])
    torso = body.copy()
    # Remove each sleeve/hand from every other piece before articulation.
    arm_mask=ImageChops.lighter(left.getchannel('A'),right.getchannel('A'))
    ta = ImageChops.subtract(torso.getchannel('A'),arm_mask)
    # Keep the shoulder cap under the articulated sleeve. It is covered at
    # rest and prevents a transparent joint during walking/attack rotation.
    cap=torso.getchannel('A').crop((0,0,w,round(h*.23)))
    ta.paste(cap,(0,0))
    td = ImageDraw.Draw(ta)
    td.rectangle((0,.43*h,w,h),fill=0)
    torso.putalpha(ta)
    legs = [isolated(body, [(0,.37*h),(.51*w,.37*h),(.51*w,h),(0,h)]),
            isolated(body, [(.49*w,.37*h),(w,.37*h),(w,h),(.49*w,h)])]
    for leg in legs:leg.putalpha(ImageChops.subtract(leg.getchannel('A'),arm_mask))
    scale = pose.get('leg_scale',1)
    dy = round(h*.6*(1-scale)) + pose.get('dy',0)
    nx, ny = NECK[0], NECK[1]+dy
    x, y = nx-w//2, NECK[1]-3
    result = Image.new('RGBA', SIZE)
    stride = pose.get('stride',0)*(0.08+abs(math.sin(view*math.pi/4))*.92)
    for n, limb in enumerate(legs):
        layer = Image.new('RGBA', SIZE)
        if scale != 1:
            limb = limb.resize((w,round(h*scale)),RESAMPLE)
        ly = y+dy+round(.37*h*(1-scale))
        layer.alpha_composite(limb,(x,ly))
        layer = rotate_at(layer, stride*(1 if n == 0 else -1), (nx+(n*2-1)*w*.12,y+dy+.4*h))
        result.alpha_composite(layer)
    result.alpha_composite(torso,(x,y+dy))
    for n, limb in enumerate((left,right)):
        layer = Image.new('RGBA',SIZE)
        layer.alpha_composite(limb,(x,y+dy))
        angle = (pose['arm'] if n==1 else 0) if 'arm' in pose else -stride*(-1 if n==0 else 1)
        layer = rotate_at(layer, angle, (nx+(n*2-1)*w*.25,y+dy+.09*h))
        result.alpha_composite(layer)
    lean = pose.get('lean',0)
    if lean:
        result = rotate_at(result, lean, (nx,ny+h*.35))
        theta=math.radians(lean)
        nx += round(-h*.35*math.sin(theta)); ny += round(h*.35*(1-math.cos(theta)))
    roll = pose.get('roll',0)
    if roll:
        old_center=(result.width/2,result.height/2)
        result = result.rotate(roll,RESAMPLE,expand=True)
        radians=math.radians(roll)
        vx,vy=nx-old_center[0],ny-old_center[1]
        nx=round(result.width/2+vx*math.cos(radians)+vy*math.sin(radians))
        ny=round(result.height/2-vx*math.sin(radians)+vy*math.cos(radians))
        box=result.getbbox()
        delta=(PIVOT[0]-(box[0]+box[2])//2,PIVOT[1]-box[3])
        moved=Image.new('RGBA',SIZE);moved.alpha_composite(result,delta);result=moved
        nx+=delta[0];ny+=delta[1]
    return result,(nx,ny),lean+roll


def authored_pose(view,pose,sex,bare=False):
    """Common crouch / held-weapon modules retain authored anatomy and grips."""
    weapon=pose.get('weapon')
    walking=pose['id'].startswith(('walk_','run_'))
    if not weapon and not walking and pose['id'] not in ('crouch','crouch_a','crouch_b','sit','fall_knee'):
        return None
    source=f'body_{weapon}_module_v1.png' if weapon else 'body_crouch_module_v1.png'
    if bare:source=f'body_bare_{weapon}_v1.png' if weapon else 'body_bare_crouch_v1.png'
    if walking:source='body_walk_bare_v1.png'
    mirrored=walking and pose['id'].endswith('_b')
    raw=sheet(source)[(-view)%8 if mirrored else view]
    if mirrored:raw=raw.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    h=SPEC['body_height'] if weapon or walking else 90
    im=raw.resize((round(raw.width*h/raw.height),h),Image.Resampling.LANCZOS)
    # Locate the collar rather than the overall silhouette (guns project sideways).
    top=im.getchannel('A').crop((0,0,im.width,max(1,round(h*.055))))
    bounds=top.point(lambda a:255 if a>=128 else 0).getbbox()
    collar=(bounds[0]+bounds[2])//2 if bounds else im.width//2
    x=NECK[0]-collar;y=PIVOT[1]-h
    result=Image.new('RGBA',SIZE)
    if weapon and pose.get('leg_scale',1)<1:
        # Replace the legs with the authored bent-knee module; keep the complete
        # original grip and weapon above the belt.
        bent=authored_pose(view,{'id':'crouch'},sex,bare)
        result=bent[0]
        upper=im.crop((0,0,im.width,round(h*.45)))
        y=bent[1][1]-3
        result.alpha_composite(upper,(x,y))
    else:
        result.alpha_composite(im,(x,y))
    # Visible recoil / reload displacement is cosmetic, without new action timing.
    dy=-2 if pose['id'].endswith('fire') else 2 if pose['id'].endswith('reload') else 0
    if dy:
        moved=Image.new('RGBA',SIZE);moved.alpha_composite(result,(0,dy));result=moved;y+=dy
    return result,(NECK[0],y+3),0


def main():
    (ROOT/'build/issue148').mkdir(parents=True,exist_ok=True)
    OUT.mkdir(parents=True,exist_ok=True)
    heads={}; body_modules={}; anchors={}; images={}; hand_modules={}
    for spec in SPEC['heads']:
        for view in range(8):
            raw=head_source(spec,view);mask=skin_mask(raw,spec['color_kind'],view)
            save(mask, f'masks/{spec["id"]}_{view}')
            for tone in range(3):
                im=tone_image(raw,mask,spec['color_kind'],tone)
                # Tilted head modules are shared by every compatible pose/body.
                for angle in (0,-9,-12,-18,50,90):
                    posed=im.rotate(angle,RESAMPLE,expand=True)
                    name=f'heads/{spec["id"]}_{tone}_{view}_{angle}'
                    heads[spec['id'],tone,view,angle]=(save(posed,name),posed)
    for bare in (False,True):
        for sex,source in enumerate(SPEC['bare_body_sources' if bare else 'body_sources']):
            for view,raw in enumerate(sheet(source)):
                for index,pose in enumerate(SPEC['poses']):
                    override=authored_pose(view,pose,sex,bare)
                    im,neck,angle=override if override else body_pose(raw,view,pose)
                    has_hands=bare or pose['id'].startswith(('walk_','run_'))
                    if has_hands:
                        pixels=[];hands=[]
                        for r,g,b,a in im.getdata():
                            selected=a>0 and g>r*1.05 and g>b*1.05
                            gray=min(255,round((.299*r+.587*g+.114*b)*255/120))
                            hands.append((gray,gray,gray,a if selected else 0))
                            pixels.append((r,g,b,0 if selected else a))
                        hand=Image.new('RGBA',SIZE);hand.putdata(hands)
                        im.putdata(pixels)
                        hand_modules[bare,sex,index,view]=save(hand,f'world_hands/{sex}_{index}_{view}' if bare else f'world_gloves/{sex}_{index}_{view}')
                    body_modules[bare,sex,index,view]=save(im,f'body_bare/{sex}_{index}_{view}' if bare else f'body/{sex}_{index}_{view}')
                    anchors[bare,sex,index,view]=(neck,angle)
                    images[bare,sex,index,view]=im
    lines=['// Generated by generate_modular_appearance.py; modules remain separate.']
    registry=[]; names=set(); board=Image.new('RGB',(14*112,208),(35,40,44)); standing={}
    head_ids=[h['id'] for h in SPEC['heads']]
    # Stable identities: human M/F, Caelith M/F, goblin M/F, then four beast M/F.
    for identity in range(14):
        sex=identity%2;head_id=head_ids[identity if identity<6 else 6+(identity-6)//2]
        for tone in range(3):
            for index,pose in enumerate(SPEC['poses']):
                for bare in (True,False):
                    prefix=f'{"P" if bare else "Q"}{identity*6+tone*2+index//26:03d}'
                    frame=chr(65+index%26)
                    if prefix not in registry:registry.append(prefix)
                    for view in range(8):
                        name=f'{prefix}{frame}{view+1}';assert name not in names;names.add(name)
                        (nx,ny),angle=anchors[bare,sex,index,view]
                        path,head=heads[head_id,tone,view,angle]
                        hx=nx-head.width//2;hy=ny-head.height+3
                        if angle==90:hx=nx-head.width+3;hy=ny-head.height//2
                        body=body_modules[bare,sex,index,view]
                        lines += [f'Sprite "{name}", {SIZE[0]}, {SIZE[1]}', '{',f'    Offset {PIVOT[0]}, {PIVOT[1]}',f'    Patch "{body}", 0, 0']
                        if (bare,sex,index,view) in hand_modules:
                            color=SPEC['caelith_tones' if identity in (2,3) else 'skin_tones'][tone]
                            if identity>=6:
                                color=[min(255,round(c*f)) for c,f in zip(SPEC['world_fur_hand_tones'][(identity-6)//2],SPEC['fur_multipliers'][tone])]
                            if not bare:color=[110,65,33]
                            hand=hand_modules[bare,sex,index,view]
                            lines.append(f'    Patch "{hand}", 0, 0 {{ Blend {color[0]}, {color[1]}, {color[2]} }}')
                        if identity>=6:
                            lines.append(f'    Patch "{path}", {hx}, {hy}')
                        lines.append('}')
                        if tone==0 and index==0 and view==0:
                            sample=images[bare,sex,index,view].copy();sample.alpha_composite(head,(hx,hy))
                            bounds=sample.getchannel('A').point(lambda a:255 if a>=32 else 0).getbbox()
                            standing[identity,not bare]=bounds[3]-bounds[1]
                        if bare and tone==0 and index==0 and view==0:
                            sample=images[bare,sex,index,view].copy();sample.alpha_composite(head,(hx,hy))
                            h=Image.open(ROOT/'src'/hand).convert('RGBA')
                            h.putdata([(r*color[0]//255,g*color[1]//255,b*color[2]//255,a) for r,g,b,a in h.getdata()])
                            sample.alpha_composite(h)
                            sample=sample.crop((56,0,168,208));board.paste(sample,(identity*112,0),sample)
    (ROOT/'src/graphics/caelum/appearance.textures').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    heights=', '.join(str(standing[i,g]) for i in range(14) for g in (False,True))
    states='// Registro de prefijos dinámicos; esta clase nunca se instancia.\nclass CaelumAppearanceRegistry : Actor\n{\n'
    states+='    static clearscope double StandingHeight(int identity,bool gloved)\n    {\n'
    states+=f'        static const double heights[] = {{{heights}}};\n'
    states+='        return heights[Clamp(identity,0,13)*2+int(gloved)];\n    }\n    States\n    {\n    Spawn:\n'
    states+=''.join(f'    {prefix}:\n        {prefix} A 1;\n' for prefix in registry)
    states+=''.join(f'    Source{prefix}:\n        {prefix} A 1;\n' for prefix in ('DOID','DOWK','DORN','RSDO','DOMI','CAGN','CAGC','SHGW'))
    states+='        Stop;\n    }\n}\n'
    (ROOT/'src/caelum/character/CaelumAppearanceRegistry.zs').write_text(states,encoding='utf-8')
    board.save(ROOT/'build/issue148/modular-identities.png')
    manifest={'issue':148,'generator':'assets/generators/generate_modular_appearance.py','identities':14,'tones_per_identity':3,'poses':len(SPEC['poses']),'views':8,'sprite_compositions':len(names),'registered_prefixes':registry,'module_sha256':RECORDS}
    (SOURCE/'REGISTRATION.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(f'{len(names)} native compositions; {len(RECORDS)} shared module files; {len(registry)} registered banks.')


if __name__=='__main__':main()
