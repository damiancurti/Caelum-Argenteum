// Native texture inspection only; no production actor changes.
class CA137Animals : EventHandler
{
    override void OnRegister(){SetOrder(1000);}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;}
        if(level.time==650)Console.Printf("CA137 ANIMAL AUDIT COMPLETE");
    }
    override void RenderOverlay(RenderEvent e)
    {
        String names[]={"BUIDA1","BUIDA2","BUIDA3","BUIDA4","BUIDA5","BUIDA6","BUIDA7","BUIDA8","BUIDB1","BUIDB2","BUIDB3","BUIDB4","BUIDB5","BUIDB6","BUIDB7","BUIDB8","BULLA1","BULLA2","BULLA3","BULLA4","BULLA5","BULLA6","BULLA7","BULLA8","BULLB1","BULLB2","BULLB3","BULLB4","BULLB5","BULLB6","BULLB7","BULLB8","BULLC1","BULLC2","BULLC3","BULLC4","BULLC5","BULLC6","BULLC7","BULLC8","BULLD1","BULLD2","BULLD3","BULLD4","BULLD5","BULLD6","BULLD7","BULLD8","BULLE1","BULLE2","BULLE3","BULLE4","BULLE5","BULLE6","BULLE7","BULLE8","BULLF1","BULLF2","BULLF3","BULLF4","BULLF5","BULLF6","BULLF7","BULLF8","BULLG1","BULLG2","BULLG3","BULLG4","BULLG5","BULLG6","BULLG7","BULLG8","BULLH1","BULLH2","BULLH3","BULLH4","BULLH5","BULLH6","BULLH7","BULLH8","BULLI0","BULLJ0","BULLK0","BULLL0","BULLM0","BULLN0","BURNA1","BURNA2","BURNA3","BURNA4","BURNA5","BURNA6","BURNA7","BURNA8","BURNB1","BURNB2","BURNB3","BURNB4","BURNB5","BURNB6","BURNB7","BURNB8","BURNC1","BURNC2","BURNC3","BURNC4","BURNC5","BURNC6","BURNC7","BURNC8","BURND1","BURND2","BURND3","BURND4","BURND5","BURND6","BURND7","BURND8","RATGA1","RATGA2","RATGA3","RATGA4","RATGA5","RATGA6","RATGA7","RATGA8","RATGB1","RATGB2","RATGB3","RATGB4","RATGB5","RATGB6","RATGB7","RATGB8","RATGC1","RATGC2","RATGC3","RATGC4","RATGC5","RATGC6","RATGC7","RATGC8","RATGD1","RATGD2","RATGD3","RATGD4","RATGD5","RATGD6","RATGD7","RATGD8","RATGE1","RATGE2","RATGE3","RATGE4","RATGE5","RATGE6","RATGE7","RATGE8","RATGF0","RATGG0","RATGH0","RATGI0","RATGJ0","RATGK0","RATGL0","RATGM0"};
        int page=CVar.GetCVar("ca137_view").GetInt();
        int mode=CVar.GetCVar("ca137_mode").GetInt();
        Screen.Dim(0x647178,1,0,0,Screen.GetWidth(),Screen.GetHeight());
        let font=Font.GetFont("SmallFont");
        for(int cell=0;cell<18;cell++)
        {
            int i=page*18+cell;if(i>=names.Size())break;
            String name=names[i];
            String path=String.Format("sprites/caelum/actors/%s/%s.png",i<118?"bull":"giant_rat",name);
            let texture=TexMan.CheckForTexture(mode==0?path:name,mode==0?TexMan.Type_MiscPatch:TexMan.Type_Sprite);
            if(!texture.IsValid())continue;
            let size=TexMan.GetScaledSize(texture);
            double scale=Min(194./size.X,185./size.Y);
            double x=10+(cell%6)*213,y=15+(cell/6)*233;
            Screen.DrawText(font,Font.CR_WHITE,x,y,name,DTA_VirtualWidth,1280,DTA_VirtualHeight,720);
            Screen.DrawTexture(texture,false,x+(194-size.X*scale)/2,y+24+(185-size.Y*scale)/2,
                DTA_DestWidthF,size.X*scale,DTA_DestHeightF,size.Y*scale,
                DTA_LeftOffset,0,DTA_TopOffset,0,DTA_VirtualWidth,1280,DTA_VirtualHeight,720);
        }
    }
}
