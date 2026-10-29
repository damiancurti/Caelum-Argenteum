class CA502AbsentPose : Actor {States {Spawn:TNT1 A -1;Stop;}}
class CA502AbsentChecks : CA502NPCChecks {
 double ProductionStamp;
 override void NetworkProcess(ConsoleEvent e){
 let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
 if(e.Name=='ca502u_prepare'){Prepare(u);return;}
 if(e.Name=='ca502u_legacyseed'){
 Prepare(u);Soldier.ChangeTid(905046);Soldier.health=Soldier.CombatMaximumHealth=1000;
 CaelumContaminationStorage.Set(Soldier,67);let body=CaelumContaminationStorage.Get(Soldier);body.EnsurePhysiology();body.DiseaseFraction=17.0/TICRATE;
 Check(Soldier.health==1000 && body.Concentration==67,"original45 seeds health and contamination");
 }else if(e.Name=='ca502u_legacyload'){
 Soldier=CA502NPCSoldier(ActorIterator.Create(905046).Next());Check(Soldier!=null && Soldier.health==1000,"original45 body rolls back unchanged");
 Check(Soldier!=null && Near(CaelumContaminationStorage.Value(Soldier),67),"original45 contamination rolls back unchanged");
 Check(Soldier!=null && Near(CaelumContaminationStorage.Get(Soldier).DiseaseFraction,17.0/TICRATE),"original45 fractional disease preserved");
 }else return;
 Console.Printf("CA502N RESULT passed=%d failures=%d",Passed,Failed);
 }}
