// Regresion aislada: el dano puede eliminar el inventario durante su propio Tick.
class CA479Lethal : EventHandler
{
    CA479Body Bodies[4];
    CaelumSupportStatus Statuses[4];
    int Passed,Failed;
    bool Started;
    CaelumSupportStatus PlayerStatus;

    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA479 %s %s",ok?"PASS":"FAIL",label);}

    void Seed(CaelumPlayer user)
    {
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
        user.SetOrigin((-160,-160,0),false);
        for(int i=0;i<4;i++)
        {
            let body=CA479Body(Actor.Spawn("CA479Body",(80,i*64-96,0),NO_REPLACE));
            body.CombatMaximumHealth=1000;body.health=1000;body.CombatBaseSpeed=10;
            body.CombatToughness=0;body.CombatAgility=0;body.CombatPatience=0;
            body.CombatArmor=null;body.Live=true;Bodies[i]=body;
            let status=CaelumSupportStatus(body.GiveInventoryType("CaelumSupportStatus"));
            Statuses[i]=status;
            status.Apply(i==1?3:0,user,0);
            if(i==2)
            {
                status.Apply(1,user,0);status.Apply(2,user,0);status.Apply(3,user,0);
            }
            if(i==3)
            {
                let gone=Actor.Spawn("CaelumSupportAreaOrigin",(160,160,0),NO_REPLACE);
                status.Apply(0,gone,0);gone.Destroy();
            }
            Check(status.Owner==body,String.Format("lethal case %d attached",i));
        }
        Started=true;
        Console.Printf("CA479 RESULT lethal cases seeded");
    }

    void Verify()
    {
        Check(Started,"lethal state survives save/load");
        for(int i=0;i<4;i++)
        {
            Check(Bodies[i]==null || Bodies[i].health<=0,String.Format("lethal case %d kills receiver",i));
            Check(Statuses[i]==null || Statuses[i].Owner==null,String.Format("lethal case %d releases status",i));
            Check(CaelumSupportMagic.Factor(Bodies[i])==1,String.Format("lethal case %d has no residual modifier",i));
        }
        Console.Printf("CA479 RESULT lethal passed=%d failed=%d",Passed,Failed);
    }

    override void NetworkProcess(ConsoleEvent event)
    {
        if(level.MapName!="CSUP479")return;
        let user=CaelumPlayer(players[event.Player].mo);if(user==null)return;
        if(event.Name=="ca479_lethal_seed")Seed(user);
        if(event.Name=="ca479_lethal_weaken")
        {
            // PostBeginPlay debe terminar antes de fijar la salud baja del escenario.
            for(int i=0;i<4;i++)Bodies[i].health=1;
        }
        if(event.Name=="ca479_lethal_verify")Verify();
        if(event.Name=="ca479_lethal_player")
        {
            user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
            user.health=1;user.player.health=1;
            PlayerStatus=CaelumSupportStatus(user.GiveInventoryType("CaelumSupportStatus"));
            for(int i=0;i<100;i++)PlayerStatus.Apply(0,null,0);
            Check(PlayerStatus.Owner==user,"lethal player status attached");
        }
        if(event.Name=="ca479_lethal_playercheck")
        {
            Check(user.health<=0,"lethal curse kills player safely");
            Check(PlayerStatus==null || PlayerStatus.Owner==null,"player death releases status");
            Check(CaelumSupportMagic.Factor(user)==1,"player death has no residual modifier");
            Console.Printf("CA479 RESULT lethal player passed=%d failed=%d",Passed,Failed);
        }
    }
}
