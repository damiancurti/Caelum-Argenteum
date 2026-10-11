class CA195ResidentBull : CaelumM00Bull {override void Tick(){}}
class CA195Residents : StaticEventHandler
{
    int Age,Passes,Failures;
    CaelumAnchoredResident Residents[4];
    CaelumM00Bull Bulls[4];
    void Check(String label,bool ok){if(ok)Passes++;else Failures++;Console.Printf("CA195 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        Age++;
        if(Age==5)
        {
            Class<CaelumAnchoredResident> types[]={"CaelumRulo","CaelumRonnie","CaelumArgento","CaelumCaella"};
            for(int i=0;i<4;i++)
            {
                Residents[i]=CaelumAnchoredResident(Actor.Spawn(types[i],(0,i*256,0)));
                Bulls[i]=CaelumM00Bull(Actor.Spawn("CA195ResidentBull",(60,i*256,0)));
            }
        }
        if(Age==6)
        {
            for(int i=0;i<4;i++)
            {
                let npc=Residents[i];let bull=Bulls[i];
                npc.StoryAnchored=true;npc.EnsureResidentTools();npc.RuloPartyMode=2;npc.RuloPartyBull=bull;npc.target=bull;
                bull.TrialReleased=true;bull.bShootable=true;bull.bInvulnerable=false;
                let kit=npc.ResidentTools;kit.Equip(kit.Bolas);
                let flight=CaelumBolas.ThrowItem(npc,kit.Bolas,35);
                Check("each resident throws its own finite bolas",flight!=null && flight.SourceItem==kit.Bolas && kit.Bolas.Owner==flight);
                flight.AttachVictim(bull);kit.Cancel();npc.SetStateLabel("ResidentToolUse");
                double before=npc.CurrentCombatAnima;int health=bull.health;
                kit.BeginIce();kit.Tick();Check("each resident uses paid ice",kit.IcePaidTics==1 && npc.CurrentCombatAnima<before);
                Check("each resident ice controls without direct HP or broken bolas",bull.ElementalStatus.FreezeRemaining>0 && bull.health==health && CaelumBolas.Restrained(bull));
                kit.Cancel();npc.SetStateLabel("ResidentToolUse");kit.BeginMelee(false,i<2);
                Check("each resident selects actual combat item",kit.ActiveItem==kit.Melee && kit.Melee.Owner==npc);
                if(i>=2)Check("pickaxe normal cycle selected",kit.Phase==kit.MELEE_CYCLE);
                else Check("war axe/sword preparation selected",kit.Phase==kit.CHARGE_PREPARATION && kit.Charged);
                kit.Cancel();npc.SetStateLabel("ResidentToolUse");
                // A ready charge expires without spending Air, and lost/broken items cannot attack.
                bull.SetOrigin((500,i*256,0),false);
                kit.Equip(kit.Melee);kit.Charged=true;kit.Phase=kit.PREPARED;kit.PreparedRemaining=0.01;
                before=npc.CurrentCombatAir;kit.Tick();Check("prepared window expires without payment",kit.Phase==kit.IDLE && npc.CurrentCombatAir==before);
                npc.SetStateLabel("ResidentToolUse");kit.Melee.Durability=0;
                Check("broken native melee cannot start",!kit.BeginMelee(false,false));
                double original=npc.Speed;vector3 position=npc.Pos;
                bull.SetOrigin((500,i*256,0),false);CaelumBolas.Binding(bull).Resolve(false);
                for(int n=0;n<12;n++){npc.target=bull;npc.A_CaelumBudgetedChase();}
                Console.Printf("CA195 TRACE chase npc=%d speed=%.4f movement=%.4f target=%d",i,original,(npc.Pos-position).Length(),npc.target==bull);
                Check("legacy melee blocked with broken native weapon",!npc.InStateSequence(npc.CurState,npc.FindState("Melee")));
                npc.SetStateLabel("ResidentToolUse");
            }
            let argento=Residents[2];argento.target=Bulls[2];argento.NextRangedSecondaryElement=false;
            argento.A_CaelumSpawnSimpleElementalProjectile("CaelumActorSimpleElementalProjectile",40,325,CaelumConstants.ESSENCE_FIRE);
            let it=ThinkerIterator.Create("CaelumActorProjectile");CaelumActorProjectile shot;bool light=false;
            while((shot=CaelumActorProjectile(it.Next()))!=null)if(shot.target==argento)
            {Check("Argento projectile is not fire",shot.CaelumSecondaryElement);light|=shot.CaelumSecondaryElement;}
            Check("Argento actually launched Light",light);
            Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
