class CA840PixelView : EventHandler
{
    transient ui bool Checked;
    transient ui int Background;
    override void OnRegister(){SetOrder(2147483647);}
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
