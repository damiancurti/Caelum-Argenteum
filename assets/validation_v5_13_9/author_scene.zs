// Preparación aislada para revisión del autor; no se empaqueta en el juego.
class CA513ManualState : Inventory
{
    int Place;
    CaelumTravelBandit TargetBody;
    CaelumPalomo Deity;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

// Blanco de inmunidad: conserva defensas/daño real de Palomo sin deambular.
class CA513DeityTarget : CaelumPalomo
{
    override void Tick(){Vel=(0,0,0);}
    Default {+DORMANT}
}

class CA513ManualScene : StaticEventHandler
{
    const SCENE=0;
    int Announced;
    override void WorldLoaded(WorldEvent e){Announced=0;}
    void Move(CaelumPlayer p,vector3 point,double facing=90)
    {p.Vel=(0,0,0);p.SetOrigin(point,false);p.Angle=facing;p.Pitch=0;p.ClearInterpolation();}
    bool MoveFree(CaelumPlayer p,vector3 point,double facing=90)
    {
        if(CaelumTarotJustice.Fits(p,point)){Move(p,point,facing);return true;}
        for(int ring=1;ring<=2;ring++)for(int side=0;side<8;side++)
        {
            vector3 nearby=point+(ring*32*Cos(side*45),ring*32*Sin(side*45),0);
            if(CaelumTarotJustice.Fits(p,nearby)){Move(p,nearby,facing);return true;}
        }
        Console.Printf("CA513 preparation position occupied; move the other player and retry");return false;
    }
    void Status(CaelumPlayer p)
    {
        let r=p.GetPersistentCharacterState(false);let m=CaelumStandaloneMatch.View();
        Console.Printf("CA513 player=%d map=%s life=%d anima=%.2f owned=%d selected=%d cooldown=%.2fs",
            p.PlayerNumber(),level.MapName,p.health,p.CurrentAnima,CaelumTarotService.CountTarotCards(r),
            CaelumTarotService.SelectedCount(r),r!=null?r.TarotCooldownTics/double(TICRATE):0);
        Console.Printf("CA513 hunger=%.2f thirst=%.2f sleep=%.2f",p.CurrentHunger,p.CurrentThirst,p.CurrentSleep);
        if(SCENE==2 || SCENE==10 || SCENE==11)for(Inventory cursor=p.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);if(item==null || !item.Equipped)continue;
            Console.Printf("CA513 equipped tier=%d durability=%.2f awakened=%d",item.Tier,item.Durability,CaelumLabyrinthPowerups.Awakened(item));
            if(SCENE==2)Console.Printf("CA513 DESPERTAR id=%d arcano=%d dano/defensa=x%.2f desgaste=x%.2f durabilidad=%.2f",
                item.ItemId,CaelumAwakening.Card(item),CaelumAwakening.Factor(item),
                CaelumAwakening.Factor(item)>1?1.0/CaelumAwakeningData.WEAR_DIVISOR:1.0,item.Durability);
        }
        if(m!=null)Console.Printf("CA513 mode=%d score=%d team=%d finished=%d winner=%d captive=%d collected=%d",
            m.Mode,m.Score[p.PlayerNumber()],m.Team[p.PlayerNumber()],m.Finished,m.Winner,
            m.Hunt!=null && m.Hunt.Captive(p.PlayerNumber()),m.Hunt!=null?m.Hunt.Collected:0);
        if(r!=null)for(int i=0;i<r.TarotOrderCount;i++)Console.Printf("CA513 sequence[%d]=%s",i,CaelumTarotArt.DisplayName(r.TarotOrder[i]));
    }
    void Powerup(CaelumPlayer p,CA513ManualState ledger,CaelumStandaloneMatch match)
    {
        if(match.Powerups==null || match.Powerups.Points.Size()==0)return;
        let point=match.Powerups.Points[0];int kind=ledger.Place%6;ledger.Place++;
        point.Refill();point.Kind=kind;point.frame=kind>=4?1:0;point.Emblem.frame=kind;
        point.SetTag(String.Format("$CA_POWERUP_%s",CaelumPowerupData.Key(kind)));
        // Preparar un acceso transitable, sin colocar la cámara en una pared.
        for(int direction=0;direction<8;direction++)
        {
            double facing=direction*45;
            vector3 approach=point.Pos+(-96*Cos(facing),-96*Sin(facing),0);
            if(!CaelumTarotJustice.Fits(p,approach) || !CaelumTarotJustice.ClearSegment(p,point.Pos,approach))continue;
            Move(p,approach,facing);
            Console.Printf("CA513 power-up: %s; walk into it",CaelumPowerupData.Key(kind));return;
        }
        Console.Printf("CA513 power-up access occupied; move the other player and retry");
    }
    void PrepareResources(CaelumPlayer p)
    {
        p.health=Max(1,p.CaelumMaximumHealth/2);p.player.health=p.health;
        p.CurrentAnima=p.DerivedStats.MaximumAnima/4;p.CurrentHunger=50;p.CurrentThirst=50;p.CurrentSleep=50;
        p.GetPersistentCharacterState(false).TarotCooldownTics=600*TICRATE;
        if(p.WeaponModel!=null)p.SetRangedMagazineCount(p.WeaponModel.WeaponType,0);
        for(Inventory cursor=p.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);if(item==null || !item.Equipped)continue;
            item.Durability=p.GetEquipmentTaskMaximumDurability(item)/2;
            if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR)p.ArmorModel.Durability[item.ArmorSlot]=item.Durability;
            else if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD)p.ShieldModel.Durability=item.Durability;
            else if(p.ActiveWeaponItemId==item.ItemId)p.WeaponModel.Durability=item.Durability;
        }
        p.OnNativeInventoryChanged();p.RefreshFormalInventorySnapshot();
    }
    void PrepareCampaignPreset(CaelumPlayer p)
    {
        let body=CaelumStandalonePlayer(p);
        if(body==null || body.StandaloneRevision>0 || !CaelumPlayerAuthority.CanMutate(body))return;
        // Contexto exclusivo del preparador: materializar el residente con el
        // servicio real sin dejar una partida competitiva dentro de la campaña.
        let events=CaelumStandaloneMatchEvents(StaticEventHandler.Find('CaelumStandaloneMatchEvents'));
        if(events==null)return;
        let prior=events.Store;
        let temporary=CaelumStandaloneMatchStore(Actor.Spawn('CaelumStandaloneMatchStore',(0,0,0),NO_REPLACE));
        temporary.Match=new('CaelumStandaloneMatch');events.Store=temporary;
        bool ready=CaelumStandalonePresets.Initialize(body,true);
        events.Store=prior;temporary.Destroy();
        if(!ready)return;
        body.CaelumMaximumHealth=Max(1,int(body.DerivedStats.MaximumHealth));
        body.health=body.CaelumMaximumHealth;body.player.health=body.health;
        body.RefillAir();body.RefillAnima();body.RefillSurvivalResources();
        body.UpdateWorldCarbineVisual();body.RefreshEquipmentSelectionPreview();
        body.RefreshFormalInventorySnapshot();body.PersistCharacterState();
    }
    override void WorldTick()
    {
        // La voz del prólogo no forma parte de estos escenarios aislados.
        if(SCENE<4 || SCENE==9)for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let p=CaelumPlayer(players[i].mo);if(p==null)continue;
            PrepareCampaignPreset(p);
            let r=p.GetPersistentCharacterState(false);if(r==null)continue;
            r.EnsureQuestStateInitialized();r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD]=true;
        }
        if(level.time<105)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let p=CaelumStandalonePlayer(players[i].mo);
            if(p==null || p.StandaloneRevision<1 || !CaelumWorldClockTicker.Ready(p))continue;
            let ledger=CA513ManualState(p.FindInventory('CA513ManualState'));
            if(ledger==null)
            {
                ledger=CA513ManualState(p.GiveInventoryType('CA513ManualState'));
                if(SCENE==11 || SCENE==12)
                {
                    let match=CaelumStandaloneMatch.View();
                    if(match!=null && match.Hunt!=null && match.Hunt.Hunter!=null)match.Hunt.Hunter.bDormant=true;
                    if(SCENE==12 && match!=null && match.Hunt!=null)
                    {
                        if(i==0)for(int card=0;card<22;card++)
                        {Move(p,match.Hunt.Essences[card].Pos);match.Hunt.Collect(p,card);}
                        Move(p,CaelumHuntArcanaData.Center(0)+(-64+(i%2)*64,-96+(i/2)*64,0));
                        ledger.Place=-1;
                    }
                }
                if(SCENE<4 || SCENE==9)
                {
                    let r=p.GetPersistentCharacterState(false);r.EnsureQuestStateInitialized();
                    r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD]=true;
                    r.QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL]=CaelumConstants.MAIN_M00_STATE_MET_PALOMO;
                    for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)
                    {r.TarotOwned[card]=SCENE!=1 || card!=77;r.TarotSelected[card]=false;r.TarotActive[card]=false;r.TarotRemaining[card]=0;}
                    r.TarotOrderCount=0;r.TarotLoadoutRevision=1;r.TarotPowerRevision=2;r.TarotCooldownTics=r.TarotEffectTics=0;
                    CaelumInventoryService.GrantMagicBoxFromPalomo(p,false);CaelumTarotDeckRules.Grant(p,false);
                    CaelumTarotDeckRules.Owned(p).InMagicBox=true;
                    p.ApplyCharacterProfile();p.RefillAir();p.RefillAnima();p.RefillSurvivalResources();
                    p.health=p.CaelumMaximumHealth;p.player.health=p.health;
                    if(SCENE==0 || SCENE==3)Move(p,CaelumTarotExampleData.Arrival(0)+(i*64,0,0));
                    else Move(p,CaelumArenaData.Start(0,i),CaelumArenaData.Facing(0,i));
                    if(SCENE==1)
                    {
                        // Dentro del ring real, a ambos lados de la misma esencia.
                        Move(p,(128+i*128,144,0),i==0?0:180);
                        CaelumArcanaSources.PlaceReward(p,77,(192,144,0));
                        if(i==0)ledger.Deity=CaelumPalomo(Actor.Spawn('CA513DeityTarget',(192,300,0),NO_REPLACE));
                    }
                    if(SCENE==9)CaelumTarotService.Select(p,0);
                    p.RefreshSocialJournalSnapshot();p.RefreshFormalInventorySnapshot();p.PersistCharacterState();
                }
            }
            if(!(Announced&(1<<i))){Announced|=1<<i;Console.Printf("CA513 READY scene=%d player=%d",SCENE,i);Status(p);}
            if(ledger.Deity!=null)
            {ledger.Deity.NarrativeRevealInitialized=true;ledger.Deity.NarrativeRevealRequired=false;ledger.Deity.bInvisible=false;ledger.Deity.bInvulnerable=false;ledger.Deity.bDormant=true;}
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let p=CaelumPlayer(players[e.Player].mo);if(p==null)return;
        let ledger=CA513ManualState(p.FindInventory('CA513ManualState'));if(ledger==null)return;
        let r=p.GetPersistentCharacterState(false);let m=CaelumStandaloneMatch.View();
        if(e.Name=='ca513_status'){Status(p);return;}
        if(e.Name=='ca513_capture' && m!=null && m.Hunt!=null){m.Hunt.CapturePlayer(p);return;}
        if(e.Name=='ca513_reset' && (SCENE==10 || SCENE==11))
        {if(!CaelumTarotHunt.Held(p))PrepareResources(p);Status(p);return;}
        if(e.Name=='ca513_reset' && SCENE==12)
        {
            if(!CaelumTarotHunt.Held(p))
            {p.RefillAir();p.RefillAnima();p.RefillSurvivalResources();p.health=p.CaelumMaximumHealth;p.player.health=p.health;
             if(r.TarotEffectTics==0 && r.UnifiedTarotTics==0)r.TarotCooldownTics=0;}
            Status(p);return;
        }
        if(e.Name=='ca513_place' && (SCENE==10 || SCENE==11))
        {if(!CaelumTarotHunt.Held(p))Powerup(p,ledger,m);return;}
        if(e.Name=='ca513_place' && SCENE==12)
        {
            if(CaelumTarotHunt.Held(p))return;
            ledger.Place=(ledger.Place+1)%22;int card=ledger.Place;
            vector3 point=CaelumHuntArcanaData.Center(card)+(card==2 || card==5 || card==21?-32:0,card==10?0:-100,0);
            if(MoveFree(p,point,90))Console.Printf("CA513 Arcana location %d: %s",card,CaelumTarotArt.DisplayName(card));return;
        }
        if(e.Name=='ca513_target' && (SCENE==11 || SCENE==12))
        {
            if(m.Hunt.Hunter!=null){m.Hunt.Hunter.bDormant=!m.Hunt.Hunter.bDormant;
                Console.Printf("CA513 Palomo pursuit: %d",!m.Hunt.Hunter.bDormant);}
            return;
        }
        if(e.Name=='ca513_target' && SCENE==13 && m.Hunt!=null)
        {
            for(int i=0;i<MAXPLAYERS;i++)if(m.Seeker(i) && !m.Hunt.Captive(i))
            {Move(CaelumPlayer(players[m.PlayerPalomo-1].mo),players[i].mo.Pos+(-48,0,0),0);break;}
            return;
        }

        if(e.Name=='ca513_finish_setup' && p.health>0)
        {
            if(m==null)p.DamageMobj(p,p,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            else if(!m.Finished && m.Hunt!=null)
            {
                if(!m.Seeker(e.Player))return;
                for(int card=0;card<77;card++)if(!m.Hunt.Found[card])
                {Move(p,m.Hunt.Essences[card].Pos);m.Hunt.Collect(p,card);}
                Move(p,m.Hunt.Essences[77].Pos+(0,64,0),270);
            }
            else if(!m.Finished)
                m.Score[e.Player]=m.Capture!=null?CaelumStandaloneData.CAPTURE_LIMIT-1:CaelumStandaloneData.FRAG_LIMIT-1;
            return;
        }
        if(e.Name=='ca513_reset')
        {
            if(m!=null)
            {
                if(m.Hunt!=null)m.Hunt.CapturePlayer(p);
                else p.DamageMobj(p,p,10000000,'None',DMG_FORCED|DMG_NO_ARMOR,0);
            }
            else if(p.health>0)
            {
                p.RefillAir();p.RefillAnima();p.RefillSurvivalResources();p.health=p.CaelumMaximumHealth;p.player.health=p.health;
                if(r.TarotEffectTics==0 && r.UnifiedTarotTics==0)r.TarotCooldownTics=0;
                Console.Printf("CA513 setup: resources restored; cooldown clears only after active powers expire.");
            }
            Status(p);return;
        }
        if(e.Name=='ca513_place')
        {
            if(m!=null && m.Hunt!=null)
            {
                for(int i=0;i<MAXPLAYERS;i++)if(m.Hunt.Captive(i))
                {Move(p,players[i].mo.Pos+(48,0,0),180);return;}
                Move(p,CaelumHuntData.Start(e.Player));
            }
            else if(m!=null && m.Capture!=null)
            {
                int other=1-m.Team[e.Player];Move(p,m.Capture.Bases[other].Pos);
            }
            else if(CaelumTarotExampleData.Present())
            {
                ledger.Place=(ledger.Place+1)%7;
                if(ledger.Place>=5)
                {
                    let room=CaelumTarotExamples.Get();
                    let rock=room==null?null:ledger.Place==5?CaelumTarotRock(room.HotRock):CaelumTarotRock(room.DirtyRock);
                    if(rock==null || rock.Contained)return;
                    if(!MoveFree(p,rock.Pos-(0,96,0)))return;
                    vector3 delta=rock.Pos+(0,0,rock.Height/2)-CaelumTelekinesisRules.Eye(p);
                    p.Angle=VectorAngle(delta.X,delta.Y);
                    p.Pitch=-atan2(delta.Z,Max(1.0,delta.XY.Length()));
                    Console.Printf("CA513 roca: activa Estrella+Sol con Tarot; pulsa Tarot otra vez mirando la roca para guardarla.");
                    return;
                }
                vector3 point=ledger.Place==0?CaelumTarotExampleData.Arrival(0):ledger.Place==1?CaelumTarotExampleData.Door(0)-(0,96,0)
                    :ledger.Place==2?CaelumTarotExampleData.Door(1)-(0,96,0):ledger.Place==3?CaelumTarotExampleData.Controller()-(0,96,0)
                    :CaelumTarotExampleData.Automaton()-(0,128,0);
                Move(p,point+(e.Player*64,0,0));
            }
            return;
        }
        if(e.Name=='ca513_target')
        {
            if(m!=null && m.Hunt!=null)
            {Move(p,CaelumHuntData.TrapPoint(ledger.Place%24)-(0,0,0.5));ledger.Place++;return;}
            if(m!=null && m.Capture!=null)
            {Move(p,m.Capture.Bases[m.Team[e.Player]].Pos);return;}
            if(m!=null)return;
            if(ledger.TargetBody==null || ledger.TargetBody.health<=0)
            {
                vector2 direction=(Cos(p.Angle),Sin(p.Angle));
                ledger.TargetBody=CaelumTravelBandit(Actor.Spawn('CaelumTravelBandit',p.Pos+(direction*192,0),NO_REPLACE));
                if(ledger.TargetBody!=null)ledger.TargetBody.bDormant=true;
            }
            else ledger.TargetBody.bDormant=!ledger.TargetBody.bDormant;
        }
    }
}
