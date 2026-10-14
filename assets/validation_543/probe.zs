class CA254Probe : StaticEventHandler
{
 int Age,Zone,Passed,Failed,PeakAlerts,PeakNearbyAlerts; bool HeardAlert,HeardBite; CaelumGiantRat Focus; vector3 Start;
 void Check(bool ok,String label)
 {if(ok)Passed++;else Failed++;Console.Printf("CA254 %s %s",ok?"PASS":"FAIL",label);}
 override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
 override void WorldTick()
 {
  Age++;
  let user=CaelumPlayer(players[0].mo);if(user==null)return;
  if(Age==100)
  {
   user.CreationWizardOpen=false;user.CharacterCreationComplete=true;user.ApplyCharacterProfile();user.bInvulnerable=true;
   let it=ThinkerIterator.Create("CaelumGiantRat");CaelumGiantRat rat;int count=0,zero=0;
   while((rat=CaelumGiantRat(it.Next()))!=null){count++;if(rat.Speed<=0 || rat.RatMovementRevision!=CaelumGiantRat.MOVEMENT_REVISION)zero++;}
   Console.Printf("CA254 INITIAL rats=%d zeroSpeed=%d",count,zero);Check(count==192 && zero==0,"all 192 original rats have nonzero movement");
   let enemies=ThinkerIterator.Create("CaelumMandinga");Actor enemy;int mandingas=0;
   while((enemy=Actor(enemies.Next()))!=null)if(enemy.health>0)mandingas++;
   Check(mandingas==96,"all 96 original Mandingas remain");
  }
  if(Age>=100 && Age<380 && (Age-100)%70==0)
  {
   Zone=(Age-100)/70;Focus=CaelumGiantRat(ActorIterator.Create(48000+Zone*48,"CaelumGiantRat").Next());
   if(Focus==null){Console.Printf("CA254 MISSING zone=%d",Zone);return;}
   Start=Focus.Pos;vector3 position=Focus.Pos+(Cos(Focus.Angle)*96,Sin(Focus.Angle)*96,0);
   let sector=level.PointInSector(position.XY);position.Z=sector.floorplane.ZatPoint(position.XY);
   user.SetOrigin(position,false);user.Angle=user.AngleTo(Focus);user.Vel=(0,0,0);
   Console.Printf("CA254 START zone=%d id=%d speed=%.6f base=%.6f default=%.6f hp=%d sight=%d recovery=%d air=%.4f/%.4f stun=%.3f sleep=%d",
     Zone,Focus.tid,Focus.Speed,Focus.CombatBaseSpeed,GetDefaultByType("CaelumGiantRat").Speed,Focus.health,Focus.CheckSight(user),Focus.RecoveryPhase,Focus.CurrentCombatAir,Focus.MaximumCombatAir,Focus.CombatLucidityPhysicalStunRemaining,Focus.ForcedSleepTics);
  }
  if(Age>=169 && Age<380 && (Age-169)%70==0 && Focus!=null)
  {
   Console.Printf("CA254 END zone=%d displacement=%.6f targetPlayer=%d speed=%.6f base=%.6f attacks=%d look=%d chase=%d recovery=%d",
    Zone,(Focus.Pos-Start).Length(),Focus.Target==user,Focus.Speed,Focus.CombatBaseSpeed,Focus.LastCombatAttackAttempted,Focus.ImpactDiagnosticLookUpdates,Focus.ImpactDiagnosticChaseUpdates,Focus.RecoveryPhase);
  }
  if(Age>=169 && Age<380 && (Age-169)%70==0 && Focus!=null)
   Check((Focus.Pos-Start).Length()>0 && Focus.Target==user && Focus.LastCombatAttackAttempted,
    String.Format("zone %d ordinary detection, chase and bite",Zone));
  if(Age>=100 && Age<=420)
  {
   int playing=0,nearby=0;let sounds=ThinkerIterator.Create("CaelumGiantRat");CaelumGiantRat rat;
   while((rat=CaelumGiantRat(sounds.Next()))!=null)
   {
    if(rat.IsActorPlayingSound(CHAN_VOICE,"caelum/enemies/rat_alert"))
    {HeardAlert=true;playing++;if((rat.Pos-user.Pos).Length()<=256)nearby++;}
    if(rat.IsActorPlayingSound(CHAN_WEAPON,"caelum/enemies/rat_bite"))HeardBite=true;
   }
   PeakAlerts=Max(PeakAlerts,playing);
   PeakNearbyAlerts=Max(PeakNearbyAlerts,nearby);
  }
  if(Age==380)
  {
   Focus=CaelumGiantRat(ActorIterator.Create(48002,"CaelumGiantRat").Next());
   Focus.SetState(Focus.FindState("Pain"));
   Check(Focus.IsActorPlayingSound(CHAN_VOICE,"caelum/enemies/rat_pain"),"native Pain state plays rat cue");
  }
  if(Age==400)
  {
   Focus.DamageMobj(null,null,1000000,'CaelumImpact',DMG_FORCED,0);
   Check(Focus.health<=0 && Focus.IsActorPlayingSound(CHAN_VOICE,"caelum/enemies/rat_death"),"real death plays rat cue");
  }
  if(Age==420)
  {
   Check(HeardAlert,"real target acquisition plays alert");Check(HeardBite,"real bite plays own sound");
   Check(PeakNearbyAlerts>0 && PeakNearbyAlerts<=3,"nearby alert overlap stays bounded");
   Console.Printf("CA254 DONE failures=%d passes=%d peakAlerts=%d peakNearby=%d",Failed,Passed,PeakAlerts,PeakNearbyAlerts);
  }
 }
}
