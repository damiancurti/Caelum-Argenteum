// La vista sólo conserva texto derivado; el cofre es la autoridad del botín.
class CaelumChestPreviewState : Inventory
{
    CaelumMazeChest Chest;
    String Lines[5];
    int Count;

    static CaelumChestPreviewState Get(CaelumPlayer user,bool create=false)
    {
        if(user==null)return null;
        let preview=CaelumChestPreviewState(user.FindInventory("CaelumChestPreviewState"));
        if(preview==null && create)
        {
            preview=CaelumChestPreviewState(Actor.Spawn("CaelumChestPreviewState",user.Pos,NO_REPLACE));
            if(preview!=null)preview.AttachToOwner(user);
        }
        return preview;
    }

    void Refresh()
    {
        Count=0;
        let user=CaelumPlayer(Owner);
        if(Chest==null)return;
        if(!Chest.CanInspect(user)){Chest=null;return;}
        for(int i=0;i<5;i++)
        {
            let item=Chest.Loot[i];
            if(item!=null && item.Owner==Chest)
            {
                String description=CaelumNotifications.Describe(user,item,item.Amount,true);
                let equipment=CaelumEquipmentItem(item);
                if(equipment!=null)
                {
                    int kind=equipment.PreviewEquipmentKind();
                    if(kind==CaelumConstants.EQUIPMENT_KIND_WEAPON
                        || kind==CaelumConstants.EQUIPMENT_KIND_ARMOR
                        || kind==CaelumConstants.EQUIPMENT_KIND_SHIELD)
                        description=description.."\n"..String.Format(
                            StringTable.Localize("CA_CHEST_PREVIEW_PROPERTIES",false),
                            equipment.PreviewUnitWeight(user),equipment.PreviewDurability(user),
                            equipment.PreviewMaximumDurability(user),equipment.PreviewBaseValue(user));
                    else description=description.."\n"..String.Format(
                        StringTable.Localize("CA_CHEST_PREVIEW_ACCESSORY_PROPERTIES",false),
                        equipment.PreviewUnitWeight(user),equipment.PreviewBaseValue(user));
                }
                Lines[Count++]=description;
            }
        }
    }

    override void Tick(){Super.Tick();Refresh();}

    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
}

// El controlador no se serializa: debe existir al cargar partidas anteriores
// a esta interfaz. El estado del cofre permanece en el inventario del jugador.
class CaelumChestPreview : StaticEventHandler
{
    override void OnRegister(){SetOrder(110);}

    override bool InputProcess(InputEvent e)
    {
        if(consoleplayer<0 || menuactive!=0)return false;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let preview=user==null?null:CaelumChestPreviewState(user.FindInventory("CaelumChestPreviewState"));
        if(preview==null || preview.Chest==null)return false;
        // Las liberaciones llegan al motor y no dejan Use o marcha retenidos.
        if(e.Type!=InputEvent.Type_KeyDown || e.KeyScan==InputEvent.Key_Grave)return false;
        if(e.KeyScan==InputEvent.Key_Enter || e.KeyScan==InputEvent.Key_Pad_A)
            EventHandler.SendNetworkEvent("ca_chest_collect");
        else if(e.KeyScan==InputEvent.Key_Escape || e.KeyScan==InputEvent.Key_Tab
            || e.KeyScan==InputEvent.Key_Pad_B || e.KeyString~=="q")
            EventHandler.SendNetworkEvent("ca_chest_cancel");
        return true;
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_chest_collect" && e.Name!="ca_chest_cancel")return;
        if(e.Player<0 || e.Player>=MAXPLAYERS || !playeringame[e.Player])return;
        let user=CaelumPlayer(players[e.Player].mo);
        let preview=CaelumChestPreviewState.Get(user);
        if(preview==null)return;
        if(e.Name=="ca_chest_cancel"){preview.Chest=null;return;}
        if(preview.Chest!=null)preview.Chest.Collect(user);
        preview.Refresh();
        // Vuelve al HUD para que los recibos y rechazos sean legibles durante
        // toda su vida. Usar otra vez consulta los contenidos restantes reales.
        preview.Chest=null;
    }

    static ui void DrawLine(Font font,int color,double y,String text)
    {
        Screen.DrawText(font,color,42,y,text,DTA_VIRTUALWIDTHF,640.0,
            DTA_VIRTUALHEIGHTF,360.0,DTA_KEEPRATIO,true,DTA_SHADOW,true);
    }

    // El HUD llama al dibujo al final: los handlers estáticos se renderizan
    // antes de los handlers de mapa, aunque tengan un orden numérico mayor.
    static ui void Draw()
    {
        if(consoleplayer<0 || menuactive!=0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let preview=user==null?null:CaelumChestPreviewState(user.FindInventory("CaelumChestPreviewState"));
        if(preview==null || preview.Chest==null)return;
        let font=Font.GetFont("CaelumSmall");
        Screen.Dim(0x05070A,0.94,0,0,Screen.GetWidth(),Screen.GetHeight());
        DrawLine(Font.GetFont("CaelumDisplay"),Font.CR_GOLD,28,StringTable.Localize("CA_CHEST_PREVIEW_TITLE",false));
        DrawLine(font,Font.CR_GRAY,60,StringTable.Localize("CA_CHEST_PREVIEW_UNCLAIMED",false));
        double y=88;
        if(preview.Count==0)DrawLine(font,Font.CR_WHITE,y,StringTable.Localize("CA_CHEST_PREVIEW_EMPTY",false));
        for(int i=0;i<preview.Count;i++)
        {
            let lines=font.BreakLines(preview.Lines[i],550);
            for(int row=0;row<lines.Count();row++)
            {DrawLine(font,Font.CR_WHITE,y,lines.StringAt(row));y+=Max(12,font.GetHeight()+2);}
            lines.Destroy();y+=6;
        }
        DrawLine(font,Font.CR_GOLD,304,StringTable.Localize("CA_CHEST_PREVIEW_COLLECT",false));
        DrawLine(font,Font.CR_GRAY,322,StringTable.Localize("CA_CHEST_PREVIEW_CANCEL",false));
    }
}
