// Exercise retained real defender references and its normal door request.
class CA318NativeDoorNPC : EventHandler
{
    int Checks,Failures;
    CaelumHingedDoorLeaf Door;
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA318 %s %s",ok?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="npcdoor_begin")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            user.ApplyCharacterProfile();user.bInvulnerable=true;
            let port=CaelumPortSiege.Get();int bad=0;
            for(int i=0;i<port.Defenders.Size();i++)
            {
                let npc=port.Defenders[i];int house=npc.HomeIdentity%CaelumCityData.HOUSE_COUNT;
                if(npc.HomeDoor==null || !npc.HomeDoor.NativeDoorCollision()
                    || npc.HomeDoor.args[0]!=CaelumCityData.DoorGroup(house))bad++;
            }
            Check(port.Defenders.Size()==600 && bad==0,"All 600 defenders retain the correct native home door");
            let npc=port.Defenders[0];vector3 old=npc.Pos;
            npc.SetOrigin(CaelumCityData.DoorInside(npc.HomeIdentity%CaelumCityData.HOUSE_COUNT),false);
            Check(npc.TestMobjLocation(),"Authored NPC door approach is traversable");
            Door=npc.HomeDoor;Check(Door.RequestDoorGroup(npc),"Real defender requests its native home pair");
            npc.SetOrigin(old,false);
        }
        if(e.Name=="npcdoor_done")
        {
            Check(Door!=null && Door.SlideProgress==64,"Defender request opens the pair");
            Console.Printf("CA318 DONE failures=%d checks=%d",Failures,Checks);
        }
    }
}
