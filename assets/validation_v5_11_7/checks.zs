class CA581Checks : EventHandler
{
 int Failures;
 void Check(bool ok,String label)
 {if(ok)Console.Printf("CA581 PASS %s",label);else{Failures++;Console.Printf("CA581 FAIL %s",label);}}
 override void NetworkProcess(ConsoleEvent e)
 {
  let store=CaelumArrivalHousehold.Get();
  if(e.Name=='ca581_view')
  {
   let user=CaelumPlayer(players[0].mo);
   user.SetOrigin(CaelumCityData.HouseOrigin(69)+(656,1000,0),false);user.Angle=90;user.Pitch=0;
   Console.Printf("CA581 RESULT view ready");
  }
  if(e.Name=='ca581_upgrade')
  {
   Check(store!=null && store.Revision==1 && store.Entries.Size()==4,"legacy save migrates exactly four actors");
   if(store!=null)for(int i=0;i<store.Entries.Size();i++)
   {
    let row=store.Entries[i];Check(row.Parked && CaelumContaminationStorage.Get(row.Body).Concentration>0,String.Format("migrated actor %d retains concentration",i));
    let barrel=CaelumFermentationStation(row.Body);if(barrel!=null)Check(barrel.Batch.WorkingLiters==3,"legacy barrel batch migrates");
   }
   Console.Printf("CA581 RESULT upgrade failures=%d",Failures);
  }
  if(e.Name=='ca581_source')
  {
   Check(store!=null && store.Revision==1 && store.Entries.Size()==4,"four original outdoor actors captured once");
   if(store!=null)for(int i=0;i<store.Entries.Size();i++)
   {
    let row=store.Entries[i];Check(row.Parked && CaelumArrivalHousehold.Original(row.Index)==null,String.Format("object %d is absent from the street",row.Index));
    CaelumContaminationStorage.Get(row.Body,true).Concentration=42;
    let barrel=CaelumFermentationStation(row.Body);if(barrel!=null)barrel.Batch.WorkingLiters=3;
   }
   Console.Printf("CA581 RESULT source failures=%d",Failures);
  }
  if(e.Name=='ca581_home')
  {
   Check(store!=null && store.Entries.Size()==4,"same relocation registry reaches the central house");
   if(store!=null)for(int i=0;i<store.Entries.Size();i++)
   {
    let row=store.Entries[i];Check(!row.Parked && row.Body.TestMobjLocation() && (row.Body.Pos-row.Position).Length()<1,String.Format("object %d fits inside the house",row.Index));
    Check(CaelumContaminationStorage.Get(row.Body).Concentration>0,String.Format("object %d retains its own contamination",row.Index));
    let barrel=CaelumFermentationStation(row.Body);if(barrel!=null)Check(barrel.Batch.WorkingLiters==3,"barrel retains the same batch");
   }
   Console.Printf("CA581 RESULT house failures=%d",Failures);
  }
  if(e.Name=='ca581_return')
  {
   Check(store!=null && store.Entries.Size()==4,"return preserves four original actors");
   for(int i=0;i<4;i++)Check(CaelumArrivalHousehold.Original(i)==null,String.Format("street object %d does not respawn",i));
   Console.Printf("CA581 RESULT return failures=%d",Failures);
  }
 }
}
