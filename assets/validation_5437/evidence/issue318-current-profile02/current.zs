class CA318Current : CA318Observer
{
 bool Reported;
 override void WorldTick()
 {
  Super.WorldTick();
  if(Finished && !Reported)
  {
   Reported=true;
   if(Phase>0 && (Port==null || !Port.SiegeStarted))Console.Printf("CA282 FAIL normal siege did not start");
   else Console.Printf("CA282 DONE passes=1 failures=0");
  }
 }
}
