class CA163HandlingDemon : CaelumMandinga { override void Tick() {} }
class CA163Handling : CA163Inputs
{
    int HitAt, BeforeHealth;
    double PaidAnima;
    CaelumBolasBurnVisual Flash;
    bool SeenPose[4];
    override void WorldTick()
    {
        Super.WorldTick();
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let weapon=u.player.FindPSprite(50);let hand=u.player.FindPSprite(52);
        if(weapon!=null && hand!=null)
            for(int pose=0;pose<4;pose++)
                if(!SeenPose[pose] && weapon.CurState==CaelumFirstPersonView.Pose(22,1,pose))
                {
                    SeenPose[pose]=true;
                    Check(String.Format("extended hand selected in native pose %d",pose),
                        hand.CurState==GetDefaultByType("CaelumBolasFrames").FindStateByString("Hand"));
                }
        if(Stage==40 && Age==1)
        {
            u.Pitch=0;
            TargetBody=CaelumCombatActor(Actor.Spawn("CA163HandlingDemon",u.Pos+(112,0,0),NO_REPLACE));
            TargetBody.Angle=180;TargetBody.CurrentCombatAnima=100;
            TargetBody.target=null;TargetBody.RecoveryPhase=0;
        }
        if(Stage!=40)return;
        if(Age==10){BeforeHealth=TargetBody.health;TargetBody.CurrentCombatAnima=100;}
        if(HitAt==0 && CaelumBolas.Restrained(TargetBody))
        {
            HitAt=level.time;
            Console.Printf("CA163 HIT health=%d before=%d anima=%.6f",TargetBody.health,BeforeHealth,TargetBody.CurrentCombatAnima);
            Check("actual Mandinga collision restrains without direct damage",TargetBody.health==BeforeHealth);
            PaidAnima=100-TargetBody.GetMagicAnimaCost(CaelumDemonBreathRules.ANIMA_PER_SECOND)/TICRATE;
            CaelumDemonService.UpdateBreath(TargetBody);
            Check("Mandinga immediate escape pays exactly one breath tic",!CaelumBolas.Restrained(TargetBody)
                && Abs(TargetBody.CurrentCombatAnima-PaidAnima)<0.000001);
            Check("burned thrown piece is destroyed",Tool==null || Tool.bDestroyed);
            CaelumDemonService.StopBreath(TargetBody);
            Flash=CaelumBolasBurnVisual(ThinkerIterator.Create("CaelumBolasBurnVisual").Next());
            Check("paid escape creates a separate flame",Flash!=null && Flash.master==TargetBody);
            CaelumBolas.FireContact(TargetBody);
            int count=0;let it=ThinkerIterator.Create("CaelumBolasBurnVisual");while(it.Next()!=null)count++;
            Check("repeat fire contact cannot duplicate the flash",count==1);
        }
        if(HitAt>0 && level.time==HitAt+5)
        {
            Check("flame remains visible after breath stops",TargetBody.DemonBreath==null && Flash!=null
                && Flash.VisualAge>=4 && Flash.sprite==Actor.GetSpriteIndex("VFBU"));
            Check("flash causes no health or Anima change",TargetBody.health==BeforeHealth
                && Abs(TargetBody.CurrentCombatAnima-PaidAnima)<0.000001);
        }
        if(HitAt>0 && level.time==HitAt+15)
        {
            Check("flash expires after the existing impact lifetime",Flash==null || Flash.bDestroyed);
            Check("expired cosmetic never adds a burn status",TargetBody.ElementalStatus==null || TargetBody.ElementalStatus.BurnRemaining==0);
            Console.Printf("CA163 RESULT passed=%d failed=%d",Passed,Failed);
        }
        if(Age==150 && HitAt==0)Check("native flight must actually hit the Mandinga",false);
        if(Age==150)Check("native input visits all four bolas poses",SeenPose[0] && SeenPose[1] && SeenPose[2] && SeenPose[3]);
    }
}
