// Datos cosméticos generados desde DESIGN.json; sin valores de combate.
class CaelumElementalVFXData : Object {
 const FRAME_TICS=3;
 const PARTICLE_LIFE=9;
 const TRAIL_INTERVAL=2;
 const DENSE_TRAIL_INTERVAL=8;
 const DETAIL_DISTANCE=1024;
 const DENSE_DETAIL_DISTANCE=512;
 const IMPACT_TICS=12;
 static String SpriteName(int kind) { switch(kind) {
 case 0:return "VFFR";
 case 1:return "VFLT";
 case 2:return "VFWA";
 case 3:return "VFIC";
 case 4:return "VFEA";
 case 5:return "VFPO";
 case 6:return "VFAI";
 case 7:return "VFLI";
 case 8:return "VFQU";
 } return "VFFR"; }
 static Color Tint(int kind) { switch(kind) {
 case 0:return 0xff6820;
 case 1:return 0xfff1a0;
 case 2:return 0x329fff;
 case 3:return 0x9eeaff;
 case 4:return 0xdd9b42;
 case 5:return 0x8aef36;
 case 6:return 0xd0ecff;
 case 7:return 0xbb7aff;
 case 8:return 0xf060dc;
 } return 0; }
 static int LightRadius(int kind) { switch(kind) {
 case 0:return 80;
 case 1:return 96;
 case 2:return 56;
 case 3:return 64;
 case 4:return 48;
 case 5:return 56;
 case 6:return 48;
 case 7:return 80;
 case 8:return 80;
 } return 0; }
 static String StatusSprite(int kind) { switch(kind) {
 case 0:return "VFBU";
 case 1:return "VFVE";
 case 2:return "VFFZ";
 case 3:return "VFST";
 } return "VFFR"; }
}
// Registro nativo de cada frame: GetSpriteIndex no crea sprites.
class CaelumElementalVFXFrames : Actor { States { Spawn: TNT1 A -1; Stop; Frames:
 VFFR ABCD 1 Bright;
 VFLT ABCD 1 Bright;
 VFWA ABCD 1 Bright;
 VFIC ABCD 1 Bright;
 VFEA ABCD 1 Bright;
 VFPO ABCD 1 Bright;
 VFAI ABCD 1 Bright;
 VFLI ABCD 1 Bright;
 VFQU ABCD 1 Bright;
 VFBU ABCD 1 Bright;
 VFVE ABCD 1 Bright;
 VFFZ ABCD 1 Bright;
 VFST ABCD 1 Bright;
 Stop; } }
