// #434: reconciliar solamente las identidades importadas al cargar; sin barrido del mapa.
class CaelumProfileEvents : StaticEventHandler
{
    bool Inspect;
    override void WorldLoaded(WorldEvent e){Inspect=e.IsSaveGame;}
    override void WorldTick()
    {
        if(!Inspect)return;
        bool pending=false;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);
            if(!CaelumPlayerAuthority.CanRead(user)){pending=true;continue;}
            let record=user.GetPersistentCharacterState(false);
            if(record!=null && record.ProfileDeparted)
            {
                user.ProfileDeparted=true;user.Vel=(0,0,0);
                user.bSolid=false;user.bShootable=false;user.bInvisible=true;
                continue;
            }
            if(record==null || record.ProfileImportSerial<=record.ProfileImportApplied)continue;
            user.ProfileDeparted=false;user.bInvisible=false;user.bSolid=true;
            user.bShootable=user.health>0;
            int originalHealth=user.health;
            user.CraftingMenuOpen=false;user.EquipmentMenuOpen=false;user.PalomoMerchantMenuOpen=false;
            user.ActivePalomoMerchant=null;user.ActiveCraftingStationActor=null;
            if(!user.RestorePersistentCharacterState()){pending=true;continue;}
            // RestorePersistentCharacterState es también usado para cuerpos vivos:
            // la importación nunca convierte un fallecido en una resurrección.
            user.health=originalHealth;user.player.health=originalHealth;
            if(originalHealth<=0)
            {
                user.player.playerstate=PST_DEAD;
                user.bCorpse=true;user.bShootable=false;
                let death=user.FindState('Death');if(death!=null)user.SetState(death);
            }
            else
            {
                user.bCorpse=false;
                user.player.playerstate=PST_LIVE;
                user.player.PendingWeapon=user.player.ReadyWeapon;
                user.BringUpWeapon();
            }
            user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();
            record.ProfileImportApplied=record.ProfileImportSerial;
        }
        Inspect=pending;
    }
}
