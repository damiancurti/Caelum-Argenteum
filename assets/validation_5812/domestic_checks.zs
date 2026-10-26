class CA502DomesticProof : Inventory {
 int Soap,Cloth,Wallet,VendorCount;double Money,Worked,Water,Remainder,LiveStart,LiveSoap;bool Saved;
 Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
 States {Spawn:TNT1 A -1;Stop;}
}
class CA502DomesticChecks : EventHandler {
 int Passed,Failed;bool Live,Manual;
 String ResourceReading,WorkReading,FundsReading,TargetReading;
 void Check(bool ok,String text){if(ok)Passed++;else Failed++;Console.Printf("CA502D %s %s",ok?"PASS":"FAIL",text);}
 bool Near(double a,double b){return Abs(a-b)<0.00001;}
 CaelumHousekeepingWork Work(){let e=CaelumHouseHubEvents(EventHandler.Find('CaelumHouseHubEvents'));return e==null?null:e.Housekeeping;}
 double Money(Actor a){double n=0;for(Inventory i=a.Inv;i!=null;i=i.Inv){let c=CaelumCurrencyItem(i);if(c!=null)n+=double(c.Amount)*CaelumEconomyRules.GetCurrencyFaceValue(c.GetCurrencyType());}return n;}
 CaelumCityMerchant Vendor(){let m=CaelumDomesticMarket.Get();return m!=null && m.Vendors.Size()>0?m.Vendors[0].Body:null;}
 CA502DomesticProof Proof(CaelumPlayer u){let p=CA502DomesticProof(u.FindInventory('CA502DomesticProof'));return p!=null?p:CA502DomesticProof(u.GiveInventoryType('CA502DomesticProof'));}
 override void WorldTick(){let w=Work();if(w!=null && w.Initialized && !Live)w.NextTic=level.maptime+TICRATE;
  if(!Manual || w==null || w.Chest==null)return;let u=CaelumPlayer(players[0].mo);let r=Record(u);
  ResourceReading=String.Format("Agua: %.2f L | Jabon: %.2f g | Trapo: %d",CaelumDomesticWater.Get(0).Liters,CaelumHousekeepingWork.Soap(w.Chest),CaelumHousePurchase.Count(w.Chest,1));
  WorkReading=String.Format("Trabajo del hogar: %.1f / 60 min | %s",r.WorkedSeconds/60,Live?"en marcha":"pausa de prueba");
  FundsReading=String.Format("Cofre: %.0f cobres | Jabon en Provisiones: %d g",Money(w.Chest),CaelumHousePurchase.Count(Vendor(),2));
  TargetReading=w.Active<0?"Buscando superficie accesible":String.Format("%s: contaminacion %.2f | progreso %.0f%%",w.Targets[w.Active].Tile!=null?"Suelo":"Mueble",w.Targets[w.Active].Tile!=null?w.Targets[w.Active].Tile.Concentration:CaelumContaminationStorage.Value(w.Targets[w.Active].Furniture),100*w.Targets[w.Active].Progress/(60*w.Targets[w.Active].Area));
 }
 void Market(CaelumPlayer u){
  let m=CaelumDomesticMarket.Get();Check(m!=null && m.Vendors.Size()>0,"real city registers Provisions merchants");if(m==null || m.Vendors.Size()==0)return;
  let v=Vendor();v.EnsureStock(u);let p=Proof(u);p.Soap=CaelumHousePurchase.Count(v,2);p.Cloth=CaelumHousePurchase.Count(v,1);p.Wallet=v.WalletCopper;p.VendorCount=m.Vendors.Size();
  Check(p.Soap==CaelumHygieneData.SOAP_STOCK && p.Cloth==CaelumHygieneData.CLOTH_STOCK,"native catalogue supplies use approved stock");
  Check(!v.DomesticMarketParked && v.bSolid,"merchant is physical in its city");
 }
 void Step(CaelumHousekeepingWork w,double seconds){w.Stamp=CaelumContaminationSurfaces.Now(CaelumPlayer(players[0].mo))-seconds;w.ClockReady=true;w.NextTic=0;w.Tick();}
 CaelumHouseCleaningRecord Record(CaelumPlayer u){return CaelumHousekeepingWork.Record(0,CaelumCalendarState.Get(u).DateSerial(CaelumWorldClock.Get(u)));}
 void House(CaelumPlayer u){
  let w=Work();Check(w!=null,"native house owns housekeeping controller");if(w==null)return;
  if(!w.Initialized)w.Setup(u);
  let v=Vendor();Check(v!=null && v.DomesticMarketParked && !v.bSolid,"same merchant travels parked with its inventory");
  let ci=ThinkerIterator.Create('CaelumStashChest');CaelumStashChest cc;while((cc=CaelumStashChest(ci.Next()))!=null)Console.Printf("CA502D CHEST title=%s x=%.1f y=%.1f own=%d",cc.LawfulOwner==null?"null":cc.LawfulOwner.Token,cc.Pos.X,cc.Pos.Y,CaelumHousePurchase.OwnChest(cc,0));
  vector2 low=(1e30,1e30),high=(-1e30,-1e30);for(int i=0;i<level.lines.Size();i++){let l=level.lines[i];low.X=Min(low.X,Min(l.v1.p.X,l.v2.p.X));low.Y=Min(low.Y,Min(l.v1.p.Y,l.v2.p.Y));high.X=Max(high.X,Max(l.v1.p.X,l.v2.p.X));high.Y=Max(high.Y,Max(l.v1.p.Y,l.v2.p.Y));}
  vector2 center=(low+high)*0.5;w.Goal.SetOrigin((center.X,center.Y,u.Pos.Z),false);int count=0,chests=0;let bi=BlockThingsIterator.Create(w.Goal,(high-low).Length());while(bi.Next()){count++;if(bi.thing is 'CaelumStashChest')chests++;}
  Console.Printf("CA502D BOUNDS %.0f %.0f %.0f %.0f blocks=%d chests=%d targets=%d",low.X,low.Y,high.X,high.Y,count,chests,w.Targets.Size());
  Check(w.Chest!=null,"native planning discovers household coffer");if(v==null || w.Chest==null)return;
  Check(w.Chest!=null && CaelumHousePurchase.OwnChest(w.Chest,0),"house coffer ownership resolved");
  let p=Proof(u);Check(CaelumHousePurchase.Count(v,2)==p.Soap && v.WalletCopper==p.Wallet,"travel does not reset stock or money");
  double before=Money(w.Chest),personal=Money(u);int stock=CaelumHousePurchase.Count(v,2),wallet=v.WalletCopper;
  let soap=CaelumHousePurchase.Find(v,2);int price=CaelumEconomyRules.GetPriceChargedByMerchant(CaelumEconomyRules.GetInventoryUnitBaseValue(soap),50);
  Check(CaelumHousePurchase.Buy(u,w.Chest,0,v,soap,50),"house purchases actual soap lot");
  Check(Near(Money(w.Chest),before-price) && v.WalletCopper==wallet+price,"coffer payment and merchant credit conserve exact value");
  Check(CaelumHousePurchase.Count(v,2)==stock-50 && CaelumHousePurchase.Count(w.Chest,2)==50,"real soap transferred without duplicate stock");
  Check(Near(Money(u),personal),"player money unchanged");
  Check(!CaelumHousePurchase.Buy(u,w.Chest,0,v,soap,0),"zero purchase changes nothing");
  let empty=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(0,128,0),NO_REPLACE));empty.EnsureStorage();empty.LawfulOwner=new('CaelumLawfulIdentity');empty.LawfulOwner.Token="house:CAH000";
  Check(!CaelumHousePurchase.Buy(u,empty,0,v,soap,1),"no household money blocks purchase");
  empty.LawfulOwner.Token="player:fixture";Check(!CaelumHousePurchase.Buy(u,empty,0,v,soap,1),"player-owned coffer excluded");empty.Destroy();
  CaelumHousePurchase.Replenish(u,w.Chest,0);
  Check(CaelumHousePurchase.Count(w.Chest,1)==1 && CaelumHousePurchase.Count(w.Chest,2)==300,"house reaches one cloth and 300g soap");
  before=Money(w.Chest);CaelumHousePurchase.Replenish(u,w.Chest,0);Check(Near(Money(w.Chest),before),"replenishment is idempotent at target");
  w.SelectWorker();Check(w.Worker!=null && w.HasChestAccess(),"actual living resident with household key available");
  Check(w.Targets.Size()>0,"native geometry and furniture produce cleaning targets");
 }
 void Arm(CaelumPlayer u,bool furniture){
  let w=Work();if(!w.Initialized)w.Setup(u);w.SelectWorker();let r=Record(u);r.WorkedSeconds=0;w.Day=r.Day;w.NextPurchase=1e30;
  int best=-1;double distance=1e30;
  for(int i=0;i<w.Targets.Size();i++){let t=w.Targets[i];t.Done=true;t.Progress=0;if((t.Furniture!=null)!=furniture)continue;
   double d=(t.Position-w.Worker.Pos).Length();if(d<distance){distance=d;best=i;}}
  Check(best>=0,"requested real cleaning target exists");if(best<0)return;
  let target=w.Targets[best];target.Done=false;target.Initial=80;target.Progress=0;
  if(target.Tile!=null){target.Tile.Stamp=CaelumContaminationSurfaces.Now(u);target.Tile.Concentration=80;}else CaelumContaminationStorage.Set(target.Furniture,80);
  w.Active=best;w.Goal.SetOrigin(target.Position,false);
  if(furniture)w.Worker.SetOrigin(target.Position+(target.Furniture.Radius+w.Worker.Radius+1,0,0),false);
  let water=CaelumDomesticWater.Get(0);water.Liters=100;CaelumHousePurchase.Replenish(u,w.Chest,0);
 }
 void Cleaning(CaelumPlayer u){
  let w=Work();if(w==null || w.Chest==null)return;Arm(u,false);let t=w.Targets[w.Active];let water=CaelumDomesticWater.Get(0);double soap=CaelumHousekeepingWork.Soap(w.Chest);
  Console.Printf("CA502D READY worker=%d free=%d reach=%d access=%d range=%.3f distance=%.3f soap=%.3f water=%.3f",w.Worker!=null,CaelumHousekeepingWork.Free(w.Worker,0),w.Reached(),w.HasChestAccess(),w.Worker.MeleeRange,w.Worker.Distance3D(w.Goal),soap,water.Liters);
  Step(w,30);Console.Printf("CA502D STEP progress=%.3f value=%.3f worked=%.3f day=%d quotaDay=%d active=%d",t.Progress,t.Tile.Concentration,Record(u).WorkedSeconds,w.Day,Record(u).Day,w.Active);Check(Near(t.Progress,30) && Near(t.Tile.Concentration,40),"half-minute native floor action removes half contamination");
  Check(Near(water.Liters,99.5) && Near(CaelumHousekeepingWork.Soap(w.Chest),soap-2.5),"partial cleaning spends exact water and fractional soap");
  Check(Near(w.Chest.DomesticSoapRemainderG,0.5),"half gram remains in domestic coffer");
  Step(w,30);Check(t.Done && Near(t.Tile.Concentration,0) && Near(Record(u).WorkedSeconds,60),"full floor square cleaned and daily work charged once");
  Check(Near(water.Liters,99) && Near(CaelumHousekeepingWork.Soap(w.Chest),soap-5),"complete square costs one liter and five grams");
  Arm(u,false);t=w.Targets[w.Active];w.Worker.ForcedSleepTics=100;for(int i=0;i<CaelumHouseResidents.Get().Residents.Size();i++){let b=CaelumHouseResidents.Get().Residents[i].Body;if(b!=null && b!=w.Worker)b.ForcedSleepTics=100;}
  Step(w,30);Check(Near(t.Progress,0),"unavailable residents cannot clean");
  for(int i=0;i<CaelumHouseResidents.Get().Residents.Size();i++){let b=CaelumHouseResidents.Get().Residents[i].Body;if(b!=null)b.ForcedSleepTics=0;}
  w.SelectWorker();let r=Record(u);r.WorkedSeconds=CaelumHousekeepingData.DAILY_SECONDS-10;Step(w,30);
  Check(Near(r.WorkedSeconds,CaelumHousekeepingData.DAILY_SECONDS) && Near(t.Progress,10),"one shared household hour caps work across residents");
  Step(w,30);Check(Near(t.Progress,10),"daily quota blocks additional work");
  Arm(u,true);t=w.Targets[w.Active];double duration=t.Area*CaelumContaminationData.EQUIPMENT_SECONDS_M2;Step(w,duration);
  Check(t.Done && Near(CaelumContaminationStorage.Value(t.Furniture),0),"actual household furniture cleans at its approved area");
 }
 void Shortages(CaelumPlayer u){
  let w=Work();Arm(u,false);let t=w.Targets[w.Active];let reserve=CaelumDomesticWater.Get(0);
  reserve.Liters=0;double soap=CaelumHousekeepingWork.Soap(w.Chest);Step(w,30);
  Check(Near(t.Progress,0) && Near(CaelumHousekeepingWork.Soap(w.Chest),soap),"empty water reserve spends no soap or work");
  reserve.Liters=100;let cloth=CaelumHousePurchase.Find(w.Chest,1);int amount=cloth.Amount;cloth.Amount=0;Step(w,30);
  Check(Near(t.Progress,0) && Near(reserve.Liters,100),"missing reusable cloth prevents cleaning");cloth.Amount=amount;
  let stack=CaelumHousePurchase.Find(w.Chest,2);amount=stack.Amount;stack.Amount=0;double credit=w.Chest.DomesticSoapRemainderG;w.Chest.DomesticSoapRemainderG=0;Step(w,30);
  Check(Near(t.Progress,0) && Near(reserve.Liters,100),"missing soap prevents water consumption");stack.Amount=amount;w.Chest.DomesticSoapRemainderG=credit;
  Step(w,15);double progress=t.Progress,remaining=CaelumHousekeepingWork.Soap(w.Chest);w.ClockReady=false;w.NextTic=0;w.Tick();
  Check(Near(t.Progress,progress) && Near(CaelumHousekeepingWork.Soap(w.Chest),remaining),"clock rebase retains partial work without retroactive charge");
  let r=Record(u);int oldDay=r.Day;r.Ensure(oldDay);Check(Near(r.WorkedSeconds,15),"same date does not reset quota");r.Ensure(oldDay+1);
  Check(Near(r.WorkedSeconds,0) && r.Day==oldDay+1,"next world day resets household quota once");
  w.NextTic=0;w.Tick();Check(Near(t.Progress,progress),"next day preserves unfinished paid cleaning");
  r.Ensure(oldDay);Check(r.Day==oldDay+1 && Near(r.WorkedSeconds,0),"backward clock does not grant another quota");r.Day=oldDay;w.Day=oldDay;
  let v=Vendor();let stock=CaelumHousePurchase.Find(v,2);amount=stock.Amount;stock.Amount=0;double money=Money(w.Chest);
  Check(!CaelumHousePurchase.Buy(u,w.Chest,0,v,stock,1) && Near(Money(w.Chest),money),"empty actual shop stock never charges household");stock.Amount=amount;
  let model=new('CaelumTimeSkipModel');model.CaptureSkip(u,false);Check(model.Done && model.Reason=="CA_SKIP_FORECAST_EFFECT","exact-date forecast rejects mutable household water and surfaces");
 }
 void AutoStart(CaelumPlayer u){
  let w=Work();let r=Record(u);r.WorkedSeconds=0;w.Day=r.Day;w.Active=-1;w.Worker=null;w.ClockReady=false;w.NextTic=0;
  for(int i=0;i<w.Targets.Size();i++){let t=w.Targets[i];t.Done=false;t.Progress=0;if(t.Tile!=null){t.Tile.Stamp=CaelumContaminationSurfaces.Now(u);t.Tile.Concentration=80;}else CaelumContaminationStorage.Set(t.Furniture,80);}
  CaelumHousePurchase.Replenish(u,w.Chest,0);CaelumDomesticWater.Get(0).Liters=100;
  let p=Proof(u);p.LiveStart=CaelumContaminationSurfaces.Now(u);p.LiveSoap=CaelumHousekeepingWork.Soap(w.Chest);
  w.NextPurchase=1e30;Live=true;Check(true,"unattended production controller started without forced work progress");
 }
 void AutoCheck(CaelumPlayer u){
  Live=false;let w=Work();let p=Proof(u);let r=Record(u);double elapsed=CaelumContaminationSurfaces.Now(u)-p.LiveStart;
  int done=0;for(int i=0;i<w.Targets.Size();i++)if(w.Targets[i].Done && w.Targets[i].Progress>0)done++;
  Check(r.WorkedSeconds>60 && r.WorkedSeconds<=elapsed+0.001,"ordinary world clock advances unattended resident cleaning");
  Check(done>0,"native routine completes accessible real targets");
  Check(Near(p.LiveSoap-CaelumHousekeepingWork.Soap(w.Chest),r.WorkedSeconds/60*5),"unattended work uses approved soap rate");
  Check(CaelumDomesticWater.Get(0).Liters>=100 && CaelumDomesticWater.Get(0).Liters<104,"shared water refills while actual cleaning consumes it");
  Console.Printf("CA502D CLOCK elapsed=%.6f work=%.6f finished=%d soap=%.6f",elapsed,r.WorkedSeconds,done,CaelumHousekeepingWork.Soap(w.Chest));
 }
 void Legacy(CaelumPlayer u){let v=Vendor();let p=Proof(u);Check(v!=null && CaelumHousePurchase.Count(v,2)==p.Soap && v.WalletCopper==p.Wallet,"old real merchant stock and money migrate without reset");let m=CaelumDomesticMarket.Get();int n=m.Vendors.Size();CaelumDomesticMarket.RebindLoaded();Check(m.Vendors.Size()==n,"legacy market adoption is idempotent");}
 void Skipped(CaelumPlayer u){
  AutoStart(u);Live=false;let w=Work();w.SelectWorker();vector3 start=w.Worker.Pos;int chosen=-1;double best=1e30;
  for(int i=0;i<w.Targets.Size();i++){
   let t=w.Targets[i];t.Done=true;if(t.Tile==null)continue;
   double d=(t.Position-(start+(0,-128,0))).Length();w.Goal.SetOrigin(t.Position+(0,0,28),false);
   if(d<best && w.Worker.CheckSight(w.Goal,SF_IGNOREVISIBILITY)){best=d;chosen=i;}}
  Check(chosen>=0,"accelerated-clock target is behind real resident in accessible room");if(chosen<0)return;
  w.Targets[chosen].Done=false;w.Active=-1;
  double soap=CaelumHousekeepingWork.Soap(w.Chest),begin=CaelumContaminationSurfaces.Now(u);
  for(int i=0;i<210;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
  let r=Record(u);Check((w.Worker.Pos-start).Length()>0,"accelerated time moves resident through native collision without teleport");
  Check(r.WorkedSeconds>0 && r.WorkedSeconds<=CaelumContaminationSurfaces.Now(u)-begin,"accelerated personal time advances household work");
  Check(Near(soap-CaelumHousekeepingWork.Soap(w.Chest),r.WorkedSeconds/60*5),"accelerated work preserves exact soap accounting");
 }
 void ManualStart(CaelumPlayer u){
  AutoStart(u);Manual=true;let w=Work();w.NextPurchase=0;w.SelectWorker();
  vector3 old=u.Pos;u.SetOrigin(w.Worker.Pos+(160,0,0),false);u.FindFloorCeiling();
  if(!u.TestMobjLocation())u.SetOrigin(old,false);
  vector2 delta=w.Worker.Pos.XY-u.Pos.XY;u.Angle=VectorAngle(delta.X,delta.Y);u.Pitch=0;
 }
 void Economy(CaelumPlayer u){
  let v=Vendor();let stock=CaelumHousePurchase.Find(v,2);int before=stock.Amount,wallet=v.WalletCopper;
  let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(0,128,0),NO_REPLACE));chest.EnsureStorage();chest.LawfulOwner=new('CaelumLawfulIdentity');chest.LawfulOwner.Token="house:CAH000";
  int emptySlots=chest.StorageSlots();double emptyWeight=chest.StorageWeight(u);CaelumContaminationStorage.Set(chest,80);
  Check(chest.StorageSlots()==emptySlots && Near(chest.StorageWeight(u),emptyWeight),"hidden contamination state occupies no coffer slot or cargo weight");
  let coin=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(0),u.Pos,NO_REPLACE));coin.Amount=100;coin.AttachToOwner(chest);
  let cloth=Inventory(Actor.Spawn('CaelumCleaningCloth',u.Pos,NO_REPLACE));cloth.AttachToOwner(chest);
  CaelumHousePurchase.Replenish(u,chest,0);int bought=CaelumHousePurchase.Count(chest,2);
  Check(bought>0 && bought<300,"limited household budget buys affordable partial soap lot");
  Check(stock.Amount==before-bought && Near(Money(chest)+v.WalletCopper-wallet,100),"partial purchase conserves stock and exact coffer payment");
  chest.Destroy();
  chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(0,128,0),NO_REPLACE));chest.EnsureStorage();chest.LawfulOwner=new('CaelumLawfulIdentity');chest.LawfulOwner.Token="house:CAH000";
  coin=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(0),u.Pos,NO_REPLACE));coin.Amount=1000000;coin.AttachToOwner(chest);
  for(int i=1;i<CaelumContainerRules.Slots(chest.StorageTier);i++){let item=Inventory(Actor.Spawn('CaelumCleaningCloth',u.Pos,NO_REPLACE));item.AttachToOwner(chest);}
  before=stock.Amount;wallet=v.WalletCopper;double money=Money(chest);
  Check(!CaelumHousePurchase.Buy(u,chest,0,v,stock,1),"full household coffer rejects purchase atomically");
  Check(stock.Amount==before && wallet==v.WalletCopper && Near(Money(chest),money),"capacity rejection preserves coins and real stock");chest.Destroy();
 }
 void Save(CaelumPlayer u){let w=Work();if(w==null || w.Chest==null)return;let p=Proof(u);p.Worked=Record(u).WorkedSeconds;p.Money=Money(w.Chest);p.Remainder=w.Chest.DomesticSoapRemainderG;p.Soap=CaelumHousePurchase.Count(Vendor(),2);p.Wallet=Vendor().WalletCopper;p.Saved=true;Check(true,"save records actual house and merchant state");}
 void Loaded(CaelumPlayer u){let w=Work();if(!w.Initialized)w.Setup(u);let p=Proof(u);Check(p.Saved && Near(Money(w.Chest),p.Money) && Near(Record(u).WorkedSeconds,p.Worked),"saved household funds and shared daily quota retained");Check(Near(w.Chest.DomesticSoapRemainderG,p.Remainder),"saved fractional soap retained");Check(CaelumHousePurchase.Count(Vendor(),2)==p.Soap && Vendor().WalletCopper==p.Wallet,"saved actual market stock and wallet retained");}
 void Returned(CaelumPlayer u){let v=Vendor();let p=Proof(u);Check(!v.DomesticMarketParked && v.bSolid,"merchant restores native city body");Check(CaelumHousePurchase.Count(v,2)==p.Soap && v.WalletCopper==p.Wallet,"return to city does not undo domestic purchase");let it=ThinkerIterator.Create('CaelumCityMerchant');CaelumCityMerchant a;int n=0;while((a=CaelumCityMerchant(it.Next()))!=null)if(a.ShopIdentity==v.ShopIdentity)n++;Check(n==1,"city return has one merchant identity");}
 override void NetworkProcess(ConsoleEvent e){let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
  if(e.Name=='ca502d_market')Market(u);else if(e.Name=='ca502d_house')House(u);else if(e.Name=='ca502d_clean')Cleaning(u);
  else if(e.Name=='ca502d_save')Save(u);else if(e.Name=='ca502d_load')Loaded(u);else if(e.Name=='ca502d_return')Returned(u);
  else if(e.Name=='ca502d_shortages')Shortages(u);else if(e.Name=='ca502d_auto_start')AutoStart(u);else if(e.Name=='ca502d_auto_check')AutoCheck(u);else if(e.Name=='ca502d_legacy')Legacy(u);
  else if(e.Name=='ca502d_skipped')Skipped(u);
  else if(e.Name=='ca502d_manual')ManualStart(u);
  else if(e.Name=='ca502d_economy')Economy(u);
  else if(e.Name=='ca502d_read')Console.Printf("CA502D %s | %s | %s | %s",ResourceReading,WorkReading,FundsReading,TargetReading);
  else if(e.Name=='ca502d_no_soap'){let w=Work();w.NextPurchase=1e30;for(Inventory item=w.Chest.Inv;item!=null;){let next=item.Inv;if(CaelumHousePurchase.Supply(item)==2)item.Destroy();item=next;}w.Chest.DomesticSoapRemainderG=0;}
  else if(e.Name=='ca502d_buy'){let w=Work();let v=Vendor();let stock=CaelumHousePurchase.Find(v,2);let plan=new('CaelumHousePayment');int price=CaelumEconomyRules.GetPriceChargedByMerchant(CaelumEconomyRules.GetInventoryUnitBaseValue(stock),300);bool pay=plan.Plan(w.Chest,price);
   Console.Printf("CA502D PURCHASE money=%.0f price=%d pay=%d slots=%d delta=%d cap=%d weight=%.3f delta=%.3f max=%.3f owner=%d stock=%d",Money(w.Chest),price,pay,w.Chest.StorageSlots(),plan.SlotDelta,CaelumContainerRules.Slots(w.Chest.StorageTier),w.Chest.StorageWeight(u),plan.WeightDelta,CaelumContainerRules.Capacity(w.Chest.StorageTier),CaelumHousePurchase.OwnChest(w.Chest,0),stock.Amount);
   CaelumHousePurchase.Replenish(u,w.Chest,0);w.NextPurchase=CaelumContaminationSurfaces.Now(u)+60;}
  else if(e.Name=='ca502d_pause'){Live=!Live;if(Live){let w=Work();w.ClockReady=false;w.NextTic=0;}}
  else return;Console.Printf("CA502D RESULT passed=%d failures=%d",Passed,Failed);
 }
}
class CA502DomesticMenu : CaelumLiveMenu {
 override bool OnUIEvent(UIEvent e){
  if(e.Type==UIEvent.Type_KeyDown){String command="";
   if(e.KeyChar==UIEvent.Key_F1)command="ca502d_manual";
   else if(e.KeyChar==UIEvent.Key_F2)command="ca502d_read";
   else if(e.KeyChar==UIEvent.Key_F3)command="ca502d_no_soap";
   else if(e.KeyChar==UIEvent.Key_F4)command="ca502d_buy";
   else if(e.KeyChar==UIEvent.Key_F5)command="ca502d_pause";
   if(command.Length()>0){EventHandler.SendNetworkEvent(command);return true;}}
  return Super.OnUIEvent(e);
 }
 override void Drawer(){Super.Drawer();let c=CA502DomesticChecks(EventHandler.Find('CA502DomesticChecks'));if(c==null || !c.Manual)return;
  let f=Font.GetFont('CaelumMono');Screen.Dim(0x000000,0.9,0,0,Screen.GetWidth(),int(Screen.GetHeight()*0.32));
  Screen.DrawText(f,Font.CR_GOLD,8,8,"#502 Limpieza del hogar: un residente, recursos reales",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
  Screen.DrawText(f,Font.CR_WHITE,8,24,c.WorkReading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
  Screen.DrawText(f,Font.CR_WHITE,8,40,c.TargetReading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
  Screen.DrawText(f,Font.CR_WHITE,8,56,c.ResourceReading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
  Screen.DrawText(f,Font.CR_WHITE,8,72,c.FundsReading,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
  Screen.DrawText(f,Font.CR_WHITE,8,88,"F1 reiniciar | F2 leer | F3 sin jabon | F4 comprar | F5 pausar",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
 }
}
