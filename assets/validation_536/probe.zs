// Fixture aislado: las escrituras UI pasan por el comando de red de producción.
class CA233Probe : StaticEventHandler
{
    int Failures;
    ui int UIFailures;
    void Check(bool value,String label)
    {if(!value)Failures++;Console.Printf("CA233 %s %s",value?"PASS":"FAIL",label);}
    ui void UICheck(bool value,String label)
    {if(!value)UIFailures++;Console.Printf("CA233 %s %s",value?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(user==null)return;
        let record=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
        let menu=CaelumMapNoteMenu(Menu.GetCurrentMenu());
        if(e.Name=="c233_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        if(e.Name=="c233_open")
        {
            Menu.SetMenu("CaelumMapNoteMenu");menu=CaelumMapNoteMenu(Menu.GetCurrentMenu());
            UICheck(menu!=null && menu.CanPlace,"native-menu-captures-map-center");
            UICheck(menu.Center.XY==level.GetAutomapPosition(),"captured-center-exact");
            UICheck(menu.Rows.Size()==0,"empty-personal-list");
        }
        if(e.Name=="c233_pointer_guard")
        {
            menu.MouseEvent(Menu.MOUSE_Release,0,0);
            UICheck(menu.Mode==0 && record.ManualNotes.Size()==0,"opening-release-does-nothing");
            menu.Pointer.Add(1,0,0,100,100);menu.Pointer.Move((1,1));menu.Pointer.Press(menu.LayoutRevision);
            UICheck(menu.Pointer.Release(menu.LayoutRevision+1)==0,"stale-layout-rejects-click");
            Vector2 origin,size;[origin,size]=CaelumPresentation.MenuRect((36,304),(136,18));
            int x=int(origin.X+size.X/2),y=int(origin.Y+size.Y/2);
            menu.MouseEvent(Menu.MOUSE_Click,x,y);menu.MouseEvent(Menu.MOUSE_Release,x,y);
            UICheck(menu.Mode==1,"matching-native-pointer-click-opens-draft");menu.CancelEdit();
        }
        if(e.Name=="c233_cancel")
        {
            menu.BeginEdit(true);menu.Draft="Borrador español: ñ á ¿?";menu.BeginText(true);
            UICheck(TextEnterMenu(Menu.GetCurrentMenu())!=null,"native-text-menu-opens");
            Menu.GetCurrentMenu().MenuEvent(Menu.MKEY_Back,true);
            UICheck(Menu.GetCurrentMenu()==menu && menu.Entry==null,"native-text-cancel-returns-to-draft");
            UICheck(menu.Draft=="Borrador español: ñ á ¿?","text-cancel-keeps-previous-draft");
            menu.MenuEvent(Menu.MKEY_Back,false);
            UICheck(menu.Mode==0 && record.ManualNotes.Size()==0,"draft-cancel-does-not-create");
        }
        if(e.Name=="c233_create")
        {
            menu.BeginEdit(true);menu.Draft="Nota española: cama posible; verificar mañana.";
            menu.Category=CaelumPoiData.BED;menu.Send(CaelumMapNoteData.CREATE);
            menu.Send(CaelumMapNoteData.CREATE);
            UICheck(menu.Pending,"save-command-pending-once");
        }
        if(e.Name=="c233_created")
        {
            menu.Refresh();
            UICheck(record.ManualNotes.Size()==1 && record.ManualNotes[0].Id==1,"repeated-save-creates-one-stable-ID");
            UICheck(menu.Mode==0 && !menu.Pending,"save-acknowledged-in-menu");
            UICheck(record.ManualNotes[0].Position==menu.Center,"saved-native-center-exact");
            UICheck(record.KnownPois.Size()==0,"manual-bed-is-not-discovered-bed");
        }
        if(e.Name=="c233_edit_cancel")
        {
            menu.BeginEdit(false);menu.Draft="Cancel this edit";menu.Category=5;menu.CancelEdit();
            UICheck(record.ManualNotes[0].Category==1 && record.ManualNotes[0].Text.IndexOf("Nota española")==0,"cancel-preserves-text-and-category");
        }
        if(e.Name=="c233_edit_save")
        {
            menu.BeginEdit(false);menu.Draft="Transport? A personal guess, not a discovered route.";
            menu.Category=5;menu.Send(CaelumMapNoteData.EDIT);
        }
        if(e.Name=="c233_edited")
        {
            menu.Refresh();
            UICheck(record.ManualNotes.Size()==1 && record.ManualNotes[0].Id==1 && record.ManualNotes[0].Category==5,"edit-keeps-ID-and-updates-category");
            UICheck(record.KnownPois.Size()==0,"edit-does-not-grant-knowledge");
        }
        if(e.Name=="c233_delete_cancel")
        {
            menu.Activate(3);UICheck(menu.Mode==2 && menu.SelectedAction==1,"delete-default-is-cancel");
            menu.MenuEvent(Menu.MKEY_Back,false);
            UICheck(record.ManualNotes.Size()==1,"delete-cancel-keeps-note");
        }
        if(e.Name=="c233_delete")
        {menu.Activate(3);menu.Activate(1);menu.Activate(1);}
        if(e.Name=="c233_deleted")
        {
            menu.Refresh();UICheck(record.ManualNotes.Size()==0 && menu.Rows.Size()==0,"confirmed-delete-removes-exact-note");
            UICheck(record.ManualNoteNextId==2,"delete-does-not-reuse-identity");
        }
        if(e.Name=="c233_long")
        {
            menu.BeginEdit(true);menu.Draft="";
            for(int i=0;i<40;i++)menu.Draft=menu.Draft.."Long English / español: áéíóú ñ. ";
            menu.Category=0;menu.Send(CaelumMapNoteData.CREATE);
        }
        if(e.Name=="c233_native_editor")
        {menu.BeginEdit(false);menu.BeginText(true);}
        if(e.Name=="c233_reopen")
        {Menu.SetMenu("CaelumMapNoteMenu");}
        if(e.Name=="c233_boundaries")
        {
            menu.BeginEdit(true);menu.Send(1);
            UICheck(!menu.Pending && menu.Feedback=="CA_NOTE_EMPTY_TEXT","empty-draft-has-feedback");
            menu.Draft="a";for(int i=0;i<16;i++)menu.Draft=menu.Draft..menu.Draft;
            menu.Send(1);
            UICheck(!menu.Pending && menu.Feedback=="CA_NOTE_TOO_LONG","oversize-native-command-rejected-before-send");
            menu.CancelEdit();
        }
        if(e.Name=="c233_outside_map")
        {
            Menu.SetMenu("CaelumMapNoteMenu");menu=CaelumMapNoteMenu(Menu.GetCurrentMenu());
            UICheck(!menu.CanPlace,"outside-map-does-not-invent-placement");
            int mode=menu.Mode;menu.BeginEdit(true);UICheck(menu.Mode==mode,"outside-map-new-disabled");
        }
        if(e.Name=="c233_overlay")
            UICheck(automapactive && viewactive,"native-overlay-is-actually-active");
        if(e.Name=="c233_ui_done")Console.Printf("CA233 UI DONE failures=%d",UIFailures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        let record=user.GetPersistentCharacterState(false);if(record==null)return;
        if(e.Name=="c233_core")
        {
            Check(record.ManualNotesRevision==1 && record.ManualNotes.Size()==0,"empty-revision-one-migration");
            CaelumMapNotes.Ensure(record);CaelumMapNotes.Ensure(record);
            Check(record.ManualNoteNextId==1 && record.ManualNotes.Size()==0,"migration-idempotent");
            Check(!CaelumMapNotes.Apply(user,1,0,"MAP01",0,0,user.Pos,"Other map"),"wrong-map-rejected");
            Check(!CaelumMapNotes.Apply(user,1,0,level.MapName,0,99,user.Pos,"Invalid"),"invalid-category-rejected");
            Check(!CaelumMapNotes.Apply(user,1,0,level.MapName,0,0,user.Pos,""),"empty-text-rejected");
            Check(!CaelumMapNotes.Apply(user,2,0,level.MapName,99,0,user.Pos,"Missing"),"missing-ID-edit-rejected");
            Check(record.ManualNotes.Size()==0 && record.ManualNotesSerial==0,"rejected-edits-do-not-mutate");
        }
        if(e.Name=="c233_markers")
        {
            int count=0;let it=ThinkerIterator.Create("CaelumMapNoteMarker");CaelumMapNoteMarker marker;
            while((marker=CaelumMapNoteMarker(it.Next()))!=null)if(!marker.bDormant)count++;
            Check(count==e.Args[0],"native-manual-markers-count");
        }
        if(e.Name=="c233_stale")
        {
            int serial=record.ManualNotesSerial;
            Check(!CaelumMapNotes.Apply(user,2,serial-1,level.MapName,1,1,user.Pos,"Old request"),"stale-revision-rejected");
            Check(record.ManualNotesSerial==serial,"stale-rejection-keeps-serial");
        }
        if(e.Name=="c233_saved")
        {
            Check(record.ManualNotes.Size()==1 && record.ManualNotes[0].Id==2,"saved-long-note-identity");
            Check(record.ManualNotes[0].Text.Length()>1000,"long-text-not-truncated");
            Check(record.KnownPois.Size()==0,"notes-grant-no-POIs");
        }
        if(e.Name=="c233_populate")
        {
            for(int category=0;category<=5;category++)
                Check(CaelumMapNotes.Apply(user,1,record.ManualNotesSerial,level.MapName,0,category,
                    user.Pos+(category*120,100,0),String.Format("Manual category %d / categoría %d",category,category)),"all-six-manual-categories");
        }
        if(e.Name=="c233_other_record")
        {
            let other=CaelumPersistentCharacterState(Actor.Spawn("CaelumPersistentCharacterState",user.Pos,NO_REPLACE));
            CaelumMapNotes.Ensure(other);
            Check(other.ManualNotes.Size()==0 && CaelumMapNotes.Find(other,level.MapName,2)==null,"separate-character-record-has-no-notes");
            other.Destroy();
        }
        if(e.Name=="c233_hub")
        {
            int map4=0,map5=0;
            for(int i=0;i<record.ManualNotes.Size();i++)
            {if(record.ManualNotes[i].MapId=="MAP04")map4++;if(record.ManualNotes[i].MapId=="MAP05")map5++;}
            Check(map4==1 && map5==(e.Args[0]==1?1:0),"hub-map-notes-remain-separate");
            if(e.Args[0]==0)
                Check(CaelumMapNotes.Apply(user,1,record.ManualNotesSerial,"MAP05",0,0,record.ManualNotes[0].Position,"Same coordinate, other map"),"same-coordinate-other-map-note");
        }
        if(e.Name=="c233_migration")
        {
            Check(record.ManualNotesRevision==1 && record.ManualNotes.Size()==0 && record.ManualNoteNextId==1,"old-save-empty-notes-migration");
            CaelumMapNotes.Ensure(record);Check(record.ManualNotes.Size()==0,"old-save-migration-idempotent");
        }
        if(e.Name=="c233_privacy")
        {
            int count=0;CaelumPlayer other;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {count++;if(players[i].mo!=user)other=CaelumPlayer(players[i].mo);}
            Check(count>1 && other!=null,"native-second-character-present");
            Check(CaelumPoiKnowledge.MarkerUser()==null,"native-private-marker-owner-suppressed");
            if(other!=null)
            {
                other.CreationWizardOpen=false;other.CharacterCreationComplete=true;other.ApplyCharacterProfile();
                let second=other.GetPersistentCharacterState(true);second.ProfileCommitted=true;
                Check(second!=record && second.ManualNotes.Size()==0,"native-second-character-empty-notes");
                Check(CaelumMapNotes.Apply(other,1,second.ManualNotesSerial,level.MapName,0,0,record.ManualNotes[0].Position,"Other character only"),"native-second-character-own-note");
                Check(second.ManualNotes.Size()==1 && record.ManualNotes.Size()==1
                    && second.ManualNotes[0].Text!=record.ManualNotes[0].Text,"native-notes-do-not-cross-owners");
            }
        }
        if(e.Name=="c233_done")Console.Printf("CA233 DONE failures=%d",Failures);
    }
}
