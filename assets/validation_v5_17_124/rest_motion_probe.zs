// Prueba aislada: reutiliza equipo, muebles y jugador real del #283.
class CA460Probe : CA283Probe
{
    CaelumConsumableItem Meal;
    vector3 LockedPosition;
    int WeaponId,ShieldId;
    bool Measure;
    ui double LastSample;
    ui Array<double> Samples;
    override void RenderOverlay(RenderEvent e)
    {
        Super.RenderOverlay(e);
        if(Measure)
        {
            double now=MSTimeF();if(LastSample>0)Samples.Push(now-LastSample);LastSample=now;
        }
        else if(Samples.Size()>0)
        {
            String line="CA460 FRAMES";
            for(int i=0;i<Samples.Size();i++)line.AppendFormat(" %.4f",Samples[i]);
            Console.Printf("%s",line);Samples.Clear();LastSample=0;
        }
    }
    void Resolve()
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);
        if(User!=null)
        {
            Ready=true;
            let rest=CaelumRestState.Get(User);
            if(rest!=null)Furniture=rest.Furniture;
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca460_setup')
        {Setup();User.CurrentHunger=User.CurrentThirst=100;return;}
        Resolve();if(User==null)return;
        if(e.Name=='ca460_perf'){Measure=e.Args[0]!=0;return;}
        if(e.Name=='ca460_begin')
        {
            CaelumRestState.Interrupt(User,"");
            Rest(e.Args[0]!=0,e.Args[1]!=0);
            Camera.SetOrigin(User.Pos+(-100,-65,64),false);Camera.Angle=Camera.AngleTo(User);
            Camera.CameraFOV=45;Camera.Pitch=15;
            if(e.Args[0]!=0)
            {Camera.SetOrigin(User.Pos+(0,-115,60),false);Camera.Angle=Camera.AngleTo(User);Camera.CameraFOV=55;Camera.Pitch=16;}
            players[0].camera=Camera;
            LockedPosition=User.Pos;
            return;
        }
        if(e.Name=='ca460_meal')
        {
            let rest=CaelumRestState.Get(User);rest.AutoEating=rest.AutoDrinking=false;
            User.CurrentHunger=User.CurrentThirst=75;
            Meal=CaelumConsumableItem(User.GiveInventoryType(e.Args[0]==0?'CaelumFoodRation':'CaelumWaterRation'));
            Meal.Amount=2;Meal.InMagicBox=false;
            Check(CaelumDiningSession.ConsumeItem(User,Meal),"native provision consumption accepted");
            Check(Meal.Amount==1,"provision charged once before animation");
            WeaponId=User.EquipmentSelectionItemId;ShieldId=User.ShieldModel.ShieldType;
            return;
        }
        if(e.Name=='ca460_meal_check')
        {
            Check(Meal!=null && Meal.Amount==1,"visual cycle does not charge a second provision");
            Check(User.EquipmentSelectionItemId==WeaponId && User.ShieldModel.ShieldType==ShieldId
                && User.ShieldModel.Equipped,"meal preserves selected equipment and shield");
            Audit();
            Check(User.PilotBody.MealVisualPhase==e.Args[0],"meal model binding follows native phase");
            let worn=CaelumWardrobePilotBody(User.PilotBody);
            if(worn!=null && e.Args[0]!=0)
            {Check((worn.HiddenMask&(1<<15))!=0,"weapon visual hidden");Check((worn.HiddenMask&(1<<16))==0,"shield visual retained");}
            return;
        }
        if(e.Name=='ca460_input_check')
        {
            let rest=CaelumRestState.Get(User);
            Check(rest.MotionExitQueued,"actual input queues voluntary exit");
            Check(User.Pos==LockedPosition && User.Vel.XY.Length()==0,"input cannot move during transition");
            Check(!AttackSeen && !User.CombatBlockModeActive,"input cannot attack or block during transition");
            return;
        }
        if(e.Name=='ca460_check')
        {
            let rest=CaelumRestState.Get(User);
            Check(rest!=null,"rest owner exists");if(rest==null)return;
            Check(rest.MotionRevision==1,"motion migration revision initialized");
            Check(rest.MotionPhase==e.Args[0],"expected current animation phase");
            Check(CaelumRestState.IsActive(User)==(e.Args[1]!=0),"expected native rest activity");
            Check(CaelumRestState.MotionLocked(User)==(e.Args[0]!=0),"control lock follows animation");
            if(e.Args[0]!=0)Check(!User.CanEnterCombatBlockMode(),"shield blocking unavailable during motion");
            if(rest.MotionPhase>=1 && rest.MotionPhase<=6 && User.PilotBody!=null)
            {
                User.PilotBody.UpdateVisual();
                int index=CaelumRestMotionData.StateIndex(rest.MotionPhase,level.time-rest.MotionStarted,rest.Mode==CaelumRestRules.MODE_SLEEP);
                Check(User.PilotBody.CurState==User.PilotBody.FindStateByString(String.Format('RM%d',index)),"native model uses the timed transition state");
            }
            Console.Printf("CA460 PHASE time=%d phase=%d elapsed=%d active=%d queued=%d occupant=%d",
                level.time,rest.MotionPhase,level.time-rest.MotionStarted,CaelumRestState.IsActive(User),
                rest.MotionExitQueued,rest.Furniture!=null && rest.Furniture.Occupant==User);
            return;
        }
        if(e.Name=='ca460_cancel'){CaelumRestState.Cancel(User);return;}
        if(e.Name=='ca460_exhaustion')
        {User.CurrentSleep=0;CaelumExhaustion.Sync(User);Check(CaelumExhaustion.Locked(User),"existing exhaustion lock retained");return;}
        if(e.Name=='ca460_recovered')
        {User.CurrentSleep=100;CaelumExhaustion.Sync(User);CaelumRestState.Cancel(User);return;}
        if(e.Name=='ca460_damage')
        {
            User.bInvulnerable=false;
            int before=User.health;
            User.DamageMobj(null,null,10,'None',DMG_FORCED|DMG_NO_ARMOR);
            Check(User.health<before,"actual native damage reaches the player");
            Check(!CaelumRestState.MotionLocked(User),"damage immediately clears animation lock");
            return;
        }
        if(e.Name=='ca460_remove')
        {let rest=CaelumRestState.Get(User);if(rest!=null && rest.Furniture!=null)rest.Furniture.Destroy();return;}
        if(e.Name=='ca460_done')
        {Console.Printf("CA460 RESULT passed=%d failed=%d",Passed,Failed);return;}
        Super.NetworkProcess(e);
    }
}
