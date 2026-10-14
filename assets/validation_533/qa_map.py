"""Small deterministic native physics map; generated WAD stays outside src."""
import struct


def wad():
    blocks = ['namespace = "ZDoom";']

    def block(kind, **fields):
        def value(v):
            if isinstance(v, str):
                return '"' + v + '"'
            if isinstance(v, bool):
                return str(v).lower()
            return str(v)
        blocks.append(kind + ' { ' + ' '.join(f'{k} = {value(v)};' for k, v in fields.items()) + ' }')

    for room, center in enumerate((0, 1024, 2048, 4096)):
        control = room == 3
        block('sector', heightfloor=0, heightceiling=128 if control else 256,
              texturefloor='CMTB04', textureceiling='CMTB04', lightlevel=192, id=room+1)
        corners = [(center-256, -256), (center-256, 256), (center+256, 256), (center+256, -256)]
        for i, (x, y) in enumerate(corners):
            block('vertex', x=x, y=y)
            block('sidedef', sector=room, texturemiddle='CVCI04')
            args = dict(special=160, arg0=2, arg1=2, arg2=0, arg3=160) if control and i == 0 else {}
            block('linedef', v1=room*4+i, v2=room*4+(i+1)%4, sidefront=room*4+i, blocking=True, **args)
    block('thing', x=0, y=0, angle=0, type=1, skill1=True, skill2=True, skill3=True, skill4=True, skill5=True,
          single=True, coop=True, dm=True)
    lumps = [('TST258', b''), ('TEXTMAP', ('\n'.join(blocks)+'\n').encode()), ('ENDMAP', b'')]
    data = bytearray(b'PWAD' + struct.pack('<ii', len(lumps), 0))
    directory = bytearray()
    for name, payload in lumps:
        directory += struct.pack('<ii8s', len(data), len(payload), name.encode().ljust(8, b'\0'))
        data += payload
    struct.pack_into('<i', data, 8, len(data))
    return bytes(data + directory)
