class CA173View : StaticEventHandler
{
    int Age;
    CaelumHingedDoorLeaf Door;
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        int opening=CVar.FindCVar('ca173_stage').GetInt();
        if(Age==100)
        {
            vector3 center=CaelumCityData.InteriorDoorCenter(0,opening);
            u.SetOrigin(center+(opening==0?80:0,opening==1?-80:0,0),false);
            u.Vel=(0,0,0);u.Angle=opening==0?180:90;u.Pitch=0;
            let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
            while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
                if(leaf.args[0]==CaelumCityData.InteriorDoorGroup(0,opening)){Door=leaf;break;}
        }
        if(Age==180 && Door!=null)Door.Used(u);
        if(Age==210)Console.Printf("CA173 %s visual door opens with clear passage",Door!=null && Door.SlideProgress==64?"PASS":"FAIL");
    }
}
