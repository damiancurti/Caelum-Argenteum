class CA581Legacy : EventHandler
{
 override void NetworkProcess(ConsoleEvent e)
 {
  if(e.Name!='ca581_legacy' && e.Name!='ca581_rollback')return;
  int found=0;
  for(int i=0;i<4;i++)
  {
   vector3 point=i==0?(-768,1472,0):i==1?(-656,1472,0):i==2?(-584,1472,0):(-768,1664,0);
   Name kind=i==0?'CaelumWorkbenchStation':i==1?'CaelumAlchemyStation':i==2?'CaelumFermentationStation':'CaelumRestBed';
   let it=BlockThingsIterator.CreateFromPos(point.X,point.Y,point.Z,128,1,false);
   while(it.Next())if(it.thing.GetClassName()==kind && (it.thing.Pos-point).Length()<1)
   {
    found++;let dirt=CaelumContaminationStorage.Get(it.thing,true);
    let barrel=CaelumFermentationStation(it.thing);
    if(e.Name=='ca581_legacy')
    {dirt.Concentration=42;if(barrel!=null){CaelumFermentationService.Bind(CaelumPlayer(players[0].mo),barrel);barrel.Batch.WorkingLiters=3;}}
    if(dirt.Concentration>0 && (barrel==null || barrel.Batch.WorkingLiters==3))Console.Printf("CA581 PASS legacy object %d retains its state",i);
    else Console.Printf("CA581 FAIL legacy object %d state",i);
   }
  }
  Console.Printf("CA581 %s four original street actors",found==4?"PASS":"FAIL");
  Console.Printf("CA581 RESULT legacy fixture");
 }
}
