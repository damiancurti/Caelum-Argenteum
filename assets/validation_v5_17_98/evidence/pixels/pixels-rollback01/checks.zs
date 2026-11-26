class CA840PixelView : EventHandler
{
    transient ui bool Checked;
    transient ui int Background;
    transient bool SavedChecked;
    override void OnRegister(){SetOrder(2147483647);}
    override void WorldLoaded(WorldEvent e)
    {
        String current[]={"VFFRA0","VFFRB0","VFFRC0","VFFRD0","VFLTA0","VFLTB0","VFLTC0","VFLTD0","VFWAA0","VFWAB0","VFWAC0","VFWAD0","VFICA0","VFICB0","VFICC0","VFICD0","VFEAA0","VFEAB0","VFEAC0","VFEAD0","VFPOA0","VFPOB0","VFPOC0","VFPOD0","VFAIA0","VFAIB0","VFAIC0","VFAID0","VFLIA0","VFLIB0","VFLIC0","VFLID0","VFQUA0","VFQUB0","VFQUC0","VFQUD0"};
        if(!e.IsSaveGame)for(int i=0;i<36;i++)
        {
            let holder=CA840SavedFrame(Actor.Spawn("CA840SavedFrame",(0,0,64),NO_REPLACE));
            holder.Index=i;holder.SelectFrame(i);
        }
    }
    override void WorldTick()
    {
        if(SavedChecked)return;SavedChecked=true;
        String current[]={"VFFRA0","VFFRB0","VFFRC0","VFFRD0","VFLTA0","VFLTB0","VFLTC0","VFLTD0","VFWAA0","VFWAB0","VFWAC0","VFWAD0","VFICA0","VFICB0","VFICC0","VFICD0","VFEAA0","VFEAB0","VFEAC0","VFEAD0","VFPOA0","VFPOB0","VFPOC0","VFPOD0","VFAIA0","VFAIB0","VFAIC0","VFAID0","VFLIA0","VFLIB0","VFLIC0","VFLID0","VFQUA0","VFQUB0","VFQUC0","VFQUD0"};
        int count=0,failures=0;bool seen[36];
        let it=ThinkerIterator.Create("CA840SavedFrame");CA840SavedFrame holder;
        while((holder=CA840SavedFrame(it.Next()))!=null)
        {
            int i=holder.Index;bool valid=i>=0 && i<36;
            if(valid){valid=!seen[i] && holder.sprite==holder.GetSpriteIndex(current[i].Left(4)) && holder.frame==i%4;seen[i]=true;}
            if(!valid)failures++;count++;
            Console.Printf("CA840 SAVED_FRAME %s index=%d",valid?"PASS":"FAIL",i);
        }
        if(count!=36)failures++;
        Console.Printf("CA840 SAVED_FRAME_RESULT count=%d failures=%d",count,failures);
    }
    override void ConsoleProcess(ConsoleEvent e)
    {if(e.Name=="ca840white")Background=2;else if(e.Name=="ca840gray")Background=1;}
    override void RenderOverlay(RenderEvent e)
    {
        String current[]={"VFFRA0","VFFRB0","VFFRC0","VFFRD0","VFLTA0","VFLTB0","VFLTC0","VFLTD0","VFWAA0","VFWAB0","VFWAC0","VFWAD0","VFICA0","VFICB0","VFICC0","VFICD0","VFEAA0","VFEAB0","VFEAC0","VFEAD0","VFPOA0","VFPOB0","VFPOC0","VFPOD0","VFAIA0","VFAIB0","VFAIC0","VFAID0","VFLIA0","VFLIB0","VFLIC0","VFLID0","VFQUA0","VFQUB0","VFQUC0","VFQUD0"};String reference[]={"Q800A0","Q800B0","Q800C0","Q800D0","Q801A0","Q801B0","Q801C0","Q801D0","Q802A0","Q802B0","Q802C0","Q802D0","Q803A0","Q803B0","Q803C0","Q803D0","Q804A0","Q804B0","Q804C0","Q804D0","Q805A0","Q805B0","Q805C0","Q805D0","Q806A0","Q806B0","Q806C0","Q806D0","Q807A0","Q807B0","Q807C0","Q807D0","Q808A0","Q808B0","Q808C0","Q808D0"};
        int color=Background==2?0xFFFFFF:Background==1?0x606060:0;
        Screen.Clear(0,0,Screen.GetWidth(),Screen.GetHeight(),color);
        int failures=0;
        for(int i=0;i<36;i++)
        {
            let c=TexMan.CheckForTexture(current[i],TexMan.Type_Sprite);
            let r=TexMan.CheckForTexture(reference[i],TexMan.Type_Sprite);
            bool valid=c.IsValid() && r.IsValid();
            if(valid)
            {
                int cw,ch,rw,rh;[cw,ch]=TexMan.GetSize(c);[rw,rh]=TexMan.GetSize(r);
                valid=cw==rw && ch==rh && TexMan.GetScaledSize(c)==TexMan.GetScaledSize(r) && TexMan.GetScaledOffset(c)==TexMan.GetScaledOffset(r);
                double x=55+(i%6)*100;double y=65+(i/6)*100;
                Screen.DrawTexture(r,true,x,y);
                Screen.DrawTexture(c,true,x+640,y);
            }
            if(!valid)failures++;
            if(!Checked)Console.Printf("CA840 PIXEL_META %s frame=%s",valid?"PASS":"FAIL",current[i]);
        }
        if(!Checked){Checked=true;Console.Printf("CA840 PIXEL_META_RESULT checks=36 failures=%d",failures);}
    }
}

class CA840SavedFrame : Actor { int Index; void SelectFrame(int index) { switch(index) { case 0: SetStateLabel("Frame0"); return; case 1: SetStateLabel("Frame1"); return; case 2: SetStateLabel("Frame2"); return; case 3: SetStateLabel("Frame3"); return; case 4: SetStateLabel("Frame4"); return; case 5: SetStateLabel("Frame5"); return; case 6: SetStateLabel("Frame6"); return; case 7: SetStateLabel("Frame7"); return; case 8: SetStateLabel("Frame8"); return; case 9: SetStateLabel("Frame9"); return; case 10: SetStateLabel("Frame10"); return; case 11: SetStateLabel("Frame11"); return; case 12: SetStateLabel("Frame12"); return; case 13: SetStateLabel("Frame13"); return; case 14: SetStateLabel("Frame14"); return; case 15: SetStateLabel("Frame15"); return; case 16: SetStateLabel("Frame16"); return; case 17: SetStateLabel("Frame17"); return; case 18: SetStateLabel("Frame18"); return; case 19: SetStateLabel("Frame19"); return; case 20: SetStateLabel("Frame20"); return; case 21: SetStateLabel("Frame21"); return; case 22: SetStateLabel("Frame22"); return; case 23: SetStateLabel("Frame23"); return; case 24: SetStateLabel("Frame24"); return; case 25: SetStateLabel("Frame25"); return; case 26: SetStateLabel("Frame26"); return; case 27: SetStateLabel("Frame27"); return; case 28: SetStateLabel("Frame28"); return; case 29: SetStateLabel("Frame29"); return; case 30: SetStateLabel("Frame30"); return; case 31: SetStateLabel("Frame31"); return; case 32: SetStateLabel("Frame32"); return; case 33: SetStateLabel("Frame33"); return; case 34: SetStateLabel("Frame34"); return; case 35: SetStateLabel("Frame35"); return; } } Default { +NOGRAVITY +NOINTERACTION } States { Spawn: TNT1 A -1; Stop;
Frame0: VFFR A -1; Stop;
Frame1: VFFR B -1; Stop;
Frame2: VFFR C -1; Stop;
Frame3: VFFR D -1; Stop;
Frame4: VFLT A -1; Stop;
Frame5: VFLT B -1; Stop;
Frame6: VFLT C -1; Stop;
Frame7: VFLT D -1; Stop;
Frame8: VFWA A -1; Stop;
Frame9: VFWA B -1; Stop;
Frame10: VFWA C -1; Stop;
Frame11: VFWA D -1; Stop;
Frame12: VFIC A -1; Stop;
Frame13: VFIC B -1; Stop;
Frame14: VFIC C -1; Stop;
Frame15: VFIC D -1; Stop;
Frame16: VFEA A -1; Stop;
Frame17: VFEA B -1; Stop;
Frame18: VFEA C -1; Stop;
Frame19: VFEA D -1; Stop;
Frame20: VFPO A -1; Stop;
Frame21: VFPO B -1; Stop;
Frame22: VFPO C -1; Stop;
Frame23: VFPO D -1; Stop;
Frame24: VFAI A -1; Stop;
Frame25: VFAI B -1; Stop;
Frame26: VFAI C -1; Stop;
Frame27: VFAI D -1; Stop;
Frame28: VFLI A -1; Stop;
Frame29: VFLI B -1; Stop;
Frame30: VFLI C -1; Stop;
Frame31: VFLI D -1; Stop;
Frame32: VFQU A -1; Stop;
Frame33: VFQU B -1; Stop;
Frame34: VFQU C -1; Stop;
Frame35: VFQU D -1; Stop;
} }
