// #434: una campaña nueva puede reservar plazas sin crear personajes ni bienes.
class CaelumProfileVacancy : Object play
{
    const REVISION=1;
    static bool Prepare(CaelumPlayer user)
    {
        let mode=CVar.GetCVar("ca_profile_bootstrap");
        if(mode==null || !mode.GetBool() || level.MapName!="MAP01"
            || !CaelumPlayerAuthority.CanMutate(user))return false;
        let record=user.GetPersistentCharacterState(true);
        // Nunca sustituir una identidad existente, ni siquiera en este modo.
        if(record==null || record.ProfileCommitted || record.ExternalProfileId.Length()>0)return false;
        record.ProfileVacancyRevision=REVISION;record.ProfileDeparted=true;
        user.CharacterCreationComplete=false;user.CreationWizardOpen=false;
        user.ProfileDeparted=true;user.bSolid=false;user.bShootable=false;user.bInvisible=true;
        return true;
    }
}

class CaelumProfileVacancyEvents : StaticEventHandler
{
    bool Enabled,Done;
    ui bool Saved;
    override void WorldLoaded(WorldEvent e)
    {
        let mode=CVar.GetCVar("ca_profile_bootstrap");
        Enabled=!e.IsSaveGame && level.MapName=="MAP01" && mode!=null && mode.GetBool();
        Done=false;
    }
    override void WorldTick()
    {
        if(!Enabled || Done)return;
        int count=0;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);if(!CaelumPlayerAuthority.CanRead(user))return;
            let record=user.GetPersistentCharacterState(false);if(record==null)return;
            if(record.ProfileVacancyRevision!=CaelumProfileVacancy.REVISION || record.ProfileCommitted)
            {Enabled=false;Console.Printf("CA_PROFILE VACANCY REJECT existing character");return;}
            count++;
        }
        if(count==0)return;
        // Inicializar el mismo registro del mundo que usa una campaña ordinaria.
        // Los indicadores temporales sólo rodean esta llamada síncrona: no se
        // aplica un perfil, no se entrega equipo inicial y no transcurre un tic.
        CaelumPlayer first;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);let record=user.GetPersistentCharacterState(false);
            user.ProfileDeparted=false;user.CharacterCreationComplete=true;record.ProfileCommitted=true;
            if(first==null)first=user;
        }
        let world=CaelumCooperativeQuests.Get(first);
        let clock=CaelumWorldClock.Get(first,true);
        CaelumCalendarState.Get(first,true).EnsureCampaign(clock);
        CaelumWorldClockTicker.Mirror(first);
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);let record=user.GetPersistentCharacterState(false);
            // Sólo los marcadores iniciales obligatorios del motor, nunca equipo
            // de un perfil: Prepare rechazó cualquier personaje ya confirmado.
            let unarmed=user.FindInventory('CaelumUnarmedWeapon');if(unarmed!=null)unarmed.Destroy();
            let armor=user.FindInventory('BasicArmor');if(armor!=null)armor.Destroy();
            armor=user.FindInventory('HexenArmor');if(armor!=null)armor.Destroy();
            user.player.ReadyWeapon=null;user.player.PendingWeapon=null;
            record.ProfileCommitted=false;record.ProfileDeparted=true;
            user.CharacterCreationComplete=false;user.ProfileDeparted=true;
        }
        if(world==null || world.Revision<2)
        {Enabled=false;Console.Printf("CA_PROFILE VACANCY REJECT world initialization");return;}
        Done=true;Console.Printf("CA_PROFILE VACANCY READY peer=%d players=%d",consoleplayer,count);
    }
    override void UiTick()
    {
        if(!Done || Saved || consoleplayer!=0)return;
        Saved=true;let manager=SavegameManager.GetManager();manager.ReadSaveStrings();
        manager.InsertNewSaveNode();manager.DoSave(0,"Caelum vacant campaign");manager.RemoveNewSaveNode();
    }
}
