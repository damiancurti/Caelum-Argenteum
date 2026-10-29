from pathlib import Path
import zipfile,shutil
R=Path(__file__).resolve().parents[2];W=R/'build/issue417-incidents';old=R.parent/'issue417-incidents-work/build/issue417-incidents'
code='''class CAReviewManual : EventHandler {
 override void NetworkProcess(ConsoleEvent e) {
  let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
  if(e.Name=="careview_water") {
   let h=new('CA410WaterFurnitureChecks');h.Profile(u);h.Find();h.Position(u,h.Fountain);h.Fountain.SyncWater(u);
   let bottle=CaelumWaterContainer(Actor.Spawn('CaelumBottleNormal'));bottle.AttachToOwner(u);bottle.WaterLiters=0;
   let canteen=CaelumWaterContainer(Actor.Spawn('CaelumCanteenNormal'));canteen.AttachToOwner(u);canteen.WaterLiters=0;
   u.InvSel=canteen;u.OnNativeInventoryChanged();u.RefreshFormalInventorySnapshot();
   Console.Printf("CAREVIEW READY agua: Enter llena; I/R tambien; E muestra la reserva.");
  }
  else if(e.Name=="careview_large") {
   let h=new('CA410ReviewChecks');h.Profile(u);
   let item=CaelumDecorItem(Actor.Spawn('CaelumLargePaintingItem'));item.AttachToOwner(u);
   bool ok=h.LargeWall(u,item);
   Console.Printf("CAREVIEW %s cuadro grande en pared real; agacharse+E recoge.",ok?"READY":"FAIL");
  }
  else if(e.Name=="careview_filled") {
   let water=CaelumWaterContainer(u.InvSel);
   Console.Printf("CA410V %s native selected invuse fills prepared canteen",water!=null && water.WaterLiters>0?"PASS":"FAIL");
   Console.Printf("CA410V RESULT manual scenario checked");
  }
 }
}'''
with zipfile.ZipFile(W/'review410.pk3') as z:files={n:z.read(n) for n in z.namelist()}
files['ZSCRIPT']+=b'\n#include "manual.zs"\n';files['manual.zs']=code.encode();files['MAPINFO']+=b'\nGameInfo {AddEventHandlers="CAReviewManual"}\n'
with zipfile.ZipFile(W/'review410-manual.pk3','w') as z:
 for n,b in sorted(files.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
binds='bind E +use; bind I ca_inventory_open; bind Tab ca_journal_toggle; bind Y ca_time_skip; bind Enter invuse; '
for name,command in [('water','careview_water'),('beds','ca410review_gallery 0'),('art','ca410review_gallery 1'),('large','careview_large')]:
 (W/f'manual56-{name}.cfg').write_text(binds+'wait 210; netevent '+command+';\n')
for version in [5851,5852]:
 for ext in ['pk3','cfg']:shutil.copy2(old/f'author-{version}.{ext}',W/f'author-{version}.{ext}')
(W/'manual56-watercheck.cfg').write_text('wait 210; netevent careview_water; wait 10; invuse; wait 5; netevent careview_filled; wait 5; quit\n')
print('Prepared four correction scenes and reused city/travel scenarios')
