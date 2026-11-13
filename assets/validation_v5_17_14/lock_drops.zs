// #672: instancias de candados, llaves y herramientas con su identidad nativa.
class CA672LockCamera : Actor
{Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA672LockEvents : EventHandler
{
    Array<CaelumLockItem> Drops,Recovered;
    CA672LockCamera Camera;
    int Failures,DetailIndex,DetailAngle;
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA672 %s %s",okay?"PASS":"FAIL",label);}
    String PairToken(int index)
    {return String.Format("CA672-group%d-tier%d",index/8,index%3);}
    CaelumLockItem ExactOwned(Actor user,int index)
    {
        for(Inventory entry=user.Inv;entry!=null;entry=entry.Inv)
        {
            let item=CaelumLockItem(entry);if(item==null || item.CompanionHistory==null || item.CompanionHistory.Records.Size()!=1)continue;
            if(item.CompanionHistory.Records[0].RefusedStage==index+10)return item;
        }
        return null;
    }
    void Metadata(CaelumLockItem item,int index,String label)
    {
        let h=item.CompanionHistory;
        Check(h!=null && h.Records.Size()==1 && h.Records[0].Loan && h.Records[0].RefusedStage==index+10,label.." copied provenance");
        Check(CaelumContaminationStack.Value(item)>0,label.." retained contamination");
    }
    void Verify()
    {
        Check(Drops.Size()==16,"sixteen independent native lock items retained");
        for(int i=0;i<Drops.Size();i++)
        {
            let item=Drops[i];String label=String.Format("lock item %d",i);int type=i%8;
            Check(item!=null,label.." saved reference");if(item==null)continue;
            Check(item.Owner==null && item.Amount==1,label.." separate world instance");
            Check(item.LockItemType==type,label.." saved native type");
            Check(item.GetSpecialType()==CaelumLockRules.FIRST_ITEM+type && item.GetSpecialTier()==(type<6?type%3+1:1),label.." original catalogue identity");
            Check(type<6?(item.PairIdentity!=null && item.PairIdentity.Token==PairToken((i/8)*8+type%3)):item.PairIdentity==null,label.." saved pairing token");
            Check(item.GetUnitWeight()==CaelumLockRules.Weight(type),label.." original type weight");
            let defaults=GetDefaultByType(item.GetClass());
            Check(item.Radius==defaults.Radius && item.Height==defaults.Height && item.Scale==defaults.Scale,label.." original collision and scale");
            Check(item.Icon==defaults.Icon && item.sprite==defaults.SpawnState.sprite && item.frame==defaults.SpawnState.frame,label.." original shared key icon and spawn");
            Check(abs(item.Pos.Z-item.floorz)<.01,label.." native floor contact");
            Check(!item.InMagicBox && item.LimboQuestUnits==0,label.." normal carried-state flags");
            Metadata(item,i,label);
        }
        for(int group=0;group<2;group++)for(int tier=0;tier<3;tier++)
        {
            int index=group*8+tier,other=(1-group)*8+tier;
            Check(CaelumLockRules.SamePair(Drops[index].PairIdentity,Drops[index+3].PairIdentity),"matched pair token retained");
            Check(!CaelumLockRules.SamePair(Drops[index].PairIdentity,Drops[other+3].PairIdentity),"independent same-tier pair remains distinct");
        }
        Console.Printf("CA672 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca672_prepare")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int i=0;i<16;i++)
            {
                int type=i%8;String label=String.Format("lock item %d",i);CaelumLockIdentity pair=null;
                if(type<6){pair=new('CaelumLockIdentity');pair.Token=PairToken((i/8)*8+type%3);}
                let item=CaelumLockRules.Create(type,(0,0,0),pair);
                let history=new('CaelumCompanionHistory');history.Revision=1;let record=new('CaelumCompanionItemRecord');record.Loan=true;record.RefusedStage=i+10;history.Records.Push(record);item.CompanionHistory=history;
                CaelumContaminationStack.Set(item,25+i);
                Check(item.CallTryPickup(user),label.." native pickup");let owned=ExactOwned(user,i);
                Check(owned!=null && owned.Amount==1,label.." exact unique owned item");if(owned==null)continue;Metadata(owned,i,label.." pickup");
                owned.LimboQuestUnits=1;Check(owned.CreateTossable(1)==null,label.." temporary quest guard");owned.LimboQuestUnits=0;
                double mass=owned.GetCarriedWeight();owned.InMagicBox=true;Check(owned.GetCarriedWeight()==0,label.." Box excludes carried mass");
                owned.InMagicBox=false;Check(owned.GetCarriedWeight()==mass,label.." restored carried mass");
                let drop=CaelumLockItem(owned.CreateTossable(1));Check(drop!=null,label.." native toss");if(drop==null)continue;
                Check(ExactOwned(user,i)==null,label.." unique item leaves inventory");
                drop.SetOrigin(((i%4-1.5)*40,(i/4-1.5)*40,0),false);Drops.Push(drop);
            }
            Camera=CA672LockCamera(Actor.Spawn('CA672LockCamera',(0,-180,180),NO_REPLACE));Camera.Angle=90;Camera.Pitch=43;players[0].camera=Camera;user.bInvisible=true;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca672_view")
        {
            for(int i=0;i<Drops.Size();i++)if(Drops[i]!=null)Drops[i].bInvisible=false;
            if(e.Args[0]==4)players[0].camera=players[0].mo;else players[0].camera=Camera;players[0].mo.bInvisible=e.Args[0]!=4;
            let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null){if(e.Args[0]==4)hud.HUDFont=Font.GetFont("CaelumMono");else hud.HUDFont=null;}
            if(e.Args[0]==0){Camera.SetOrigin((0,-180,180),false);Camera.Angle=90;Camera.Pitch=43;}
            if(e.Args[0]==1){Camera.SetOrigin((0,-180,50),false);Camera.Angle=90;Camera.Pitch=10;}
            if(e.Args[0]==2){Camera.SetOrigin((180,0,60),false);Camera.Angle=180;Camera.Pitch=14;}
            if(e.Args[0]==3){Camera.SetOrigin((0,-108,35),false);Camera.Angle=90;Camera.Pitch=25;}
            if(e.Args[0]==5){Camera.SetOrigin((0,-53,35),false);Camera.Angle=90;Camera.Pitch=22;}
            if(e.Args[0]==6){Camera.SetOrigin((-55,38,35),false);Camera.Angle=270;Camera.Pitch=22;}
            if(e.Args[0]==7){Camera.SetOrigin((0,180,60),false);Camera.Angle=270;Camera.Pitch=14;}Camera.ClearInterpolation();
        }
        if(e.Name=="ca672_detail" || e.Name=="ca672_next" || e.Name=="ca672_rotate")
        {
            if(Drops.Size()==0)return;
            if(e.Name=="ca672_detail"){DetailIndex=e.Args[0];DetailAngle=e.Args[1];}
            if(e.Name=="ca672_next")DetailIndex=(DetailIndex+1)%Drops.Size();
            if(e.Name=="ca672_rotate")DetailAngle=DetailAngle==0?90:DetailAngle==90?160:DetailAngle==160?270:0;
            if(DetailIndex<0 || DetailIndex>=Drops.Size())return;
            for(int i=0;i<Drops.Size();i++)if(Drops[i]!=null)Drops[i].bInvisible=i!=DetailIndex;
            static const double extents[]={DETAIL_EXTENTS};static const double heights[]={DETAIL_HEIGHTS};
            let item=Drops[DetailIndex];double distance=max(9.,extents[0]*item.Scale.X*1.4);double angle=DetailAngle;
            vector3 center=item.Pos+(0,0,heights[0]*item.Scale.Y);
            Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*.5),false);Camera.Angle=angle;Camera.Pitch=26.565051;
            players[0].camera=Camera;Camera.ClearInterpolation();
        }



        if(e.Name=="ca672_verify")Verify();
        if(e.Name=="ca672_pickup")
        {
            let user=CaelumPlayer(players[0].mo);
            for(int i=0;i<Drops.Size();i++)
            {
                String label=String.Format("lock item %d",i);Check(Drops[i].CallTryPickup(user),label.." native repickup");let owned=ExactOwned(user,i);
                Check(owned!=null && owned.Amount==1 && owned.LockItemType==i%8,label.." exact recovered instance");if(owned==null)continue;
                Metadata(owned,i,label.." recovered");Recovered.Push(owned);
            }
            Check(Recovered.Size()==16,"all sixteen same-class objects coexist without merging");
            // La recogida normaliza la Caja no poseída; preparar los flags después.
            for(int i=0;i<Recovered.Size();i++)Recovered[i].InMagicBox=true;
            for(int group=0;group<2;group++)for(int tier=0;tier<3;tier++)
            {
                int index=group*8+tier;let padlock=Recovered[index];let key=Recovered[index+3];let wrong=Recovered[(1-group)*8+tier+3];
                Check(!CaelumLockRules.HasAccess(user,padlock),"Box excludes every opening tool");
                let clone=new('CaelumLockIdentity');clone.Token=padlock.PairIdentity.Token;
                let probe=CaelumLockRules.Create(tier,(0,0,0),clone);key.InMagicBox=false;
                Check(clone!=key.PairIdentity && CaelumLockRules.HasAccess(user,probe),"matching serialized value opens independently reconstructed pair");
                key.InMagicBox=true;wrong.InMagicBox=false;Check(!CaelumLockRules.HasAccess(user,probe),"same-tier wrong pair cannot open");wrong.InMagicBox=true;
                Recovered[6].InMagicBox=false;Check(CaelumLockRules.HasAccess(user,probe),"native picks retain access");Recovered[6].InMagicBox=true;
                Recovered[7].InMagicBox=false;Check(CaelumLockRules.HasAccess(user,probe),"native master key retains access");Recovered[7].InMagicBox=true;probe.Destroy();
            }
            for(int i=0;i<Recovered.Size();i++)
            {
                let owned=Recovered[i];owned.InMagicBox=false;let drop=CaelumLockItem(owned.CreateTossable(1));
                Check(drop!=null && drop.LockItemType==i%8,"second native toss retains type");Drops[i]=drop;
            }
            Console.Printf("CA672 COMPLETE failures=%d",Failures);
        }
    }
}
