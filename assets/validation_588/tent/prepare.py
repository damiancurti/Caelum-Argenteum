"""Build a private native gallery of the new model without enabling deployment."""
from pathlib import Path
import importlib.util
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
WORK=ROOT/'build/issue411-tent'


def main():
    WORK.mkdir(parents=True,exist_ok=True)
    spec=importlib.util.spec_from_file_location('room580',ROOT/'assets/validation_580/prepare.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    text='''namespace="ZDoom";
vertex {x=-512;y=-512;} vertex {x=-512;y=512;}
vertex {x=512;y=512;} vertex {x=512;y=-512;}
sidedef {sector=0;texturemiddle="CMST01";}
sidedef {sector=0;texturemiddle="CMST01";}
sidedef {sector=0;texturemiddle="CMST01";}
sidedef {sector=0;texturemiddle="CMST01";}
linedef {v1=0;v2=1;sidefront=0;blocking=true;}
linedef {v1=1;v2=2;sidefront=1;blocking=true;}
linedef {v1=2;v2=3;sidefront=2;blocking=true;}
linedef {v1=3;v2=0;sidefront=3;blocking=true;}
sector {heightfloor=0;heightceiling=256;texturefloor="CMST02";textureceiling="CMST02";lightlevel=224;}
thing {x=112;y=-100;angle=138;type=1;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;dm=true;}
'''
    members={'ZSCRIPT':b'version "4.14"\n#include "gallery.zs"\n',
        'gallery.zs':(HERE/'gallery.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA411TentGallery" }\nmap CTG411 "Tent gallery" {}\n',
        'MODELDEF':b'Model CA411TentGalleryModel { Path "models/caelum/world/camp" Model 0 "tent.obj" Scale 1 1 1 AngleOffset 90 CorrectPixelStretch DontCullBackFaces FrameIndex CPTN A 0 0 }\n',
        'models/caelum/world/camp/tent.obj':(ROOT/'src/models/caelum/world/camp/tent.obj').read_bytes(),
        'maps/CTG411.wad':module.wad(text,'CTG411')}
    with zipfile.ZipFile(WORK/'gallery.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    (WORK/'views.cfg').write_text('''wait 35; netevent ca411t_setup; wait 20; screenshot "tent-three-quarter.png"; netevent ca411t_view 0; wait 10; screenshot "tent-front.png"; netevent ca411t_view 1; wait 10; screenshot "tent-side.png"; netevent ca411t_view 2; wait 10; screenshot "tent-back.png"; wait 5; quit
''',encoding='utf-8')


if __name__=='__main__':main()
