// #444: el borrador visual nunca mueve objetos; los eventos validan dueño y revisión.
class CaelumTrucazoWagerMenu : ListMenu
{
    int Mode,Focus,Selected,Quantity,Money,Step,SentSerial;
    Array<int> Actions,Arguments;
    Array<String> Labels;
    CaelumMenuPointer Pointer;
    static String L(String key){return StringTable.Localize(key,false);}
    static CaelumPlayer User(){return CaelumCardTableMenu.User();}
    static CaelumCardDuel Duel(){return CaelumCardSeat.Session(User());}
    static String ItemDetail(Inventory item,String label)
    {
        let equipment=CaelumEquipmentItem(item);
        if(equipment!=null)label=label..String.Format(". %s: %d",L("CA_JOURNAL_INVENTORY_DURABILITY"),equipment.Durability);
        return label;
    }
    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;SentSerial=-1;Quantity=1;Pointer=new('CaelumMenuPointer');
        let d=Duel();if(d!=null && d.Wagers!=null){Money=d.Wagers.Coins[d.Side(User())];EventHandler.SendNetworkEvent("ca_tc3",CaelumTrucazoWagers.REFRESH,0,d.Serial);}
    }
    void Add(int op,int arg,String label){Actions.Push(op);Arguments.Push(arg);Labels.Push(label);}
    void Build()
    {
        Actions.Clear();Arguments.Clear();Labels.Clear();let d=Duel();let view=CaelumTrucazoWagerView.Read(User());if(d==null || d.Wagers==null)return;
        if(Mode==1 && view!=null)
        {for(int i=0;i<int(view.Rows.Size());i++)Add(-20,i,view.Labels[i]);}
        else if(Mode==2)
        {
            if(Selected>=int(d.Wagers.Offers.Size())){Mode=0;return;}
            Add(CaelumTrucazoWagers.CYCLE_RECIPIENT,Selected,L("CA_TC3_RECIPIENT_NEXT"));
            if(d.Wagers.Offers[Selected].Seat==d.Side(User()))Add(CaelumTrucazoWagers.REMOVE_ITEM,Selected,L("CA_TC3_REMOVE"));
        }
        else if(Mode==3 && view!=null)
        {
            if(Selected>=int(view.Rows.Size())){Mode=0;return;}
            Add(-21,0,L("CA_TC3_ADD"));
            if(view.Splittable[Selected]){Add(-22,1,L("CA_TC3_QUANTITY_MORE"));Add(-22,-1,L("CA_TC3_QUANTITY_LESS"));Add(-23,0,L("CA_TC3_ALL"));}
        }
        else
        {
            Add(-11,1,L("CA_TC3_MONEY_MORE"));Add(-11,-1,L("CA_TC3_MONEY_LESS"));Add(CaelumTrucazoWagers.SET_COINS,Money,L("CA_TC3_SET_MONEY"));
            Add(-12,0,L("CA_TC3_PICK_ITEM"));Add(CaelumTrucazoWagers.REFRESH,0,L("CA_TC3_REFRESH"));
            for(int i=0;i<int(d.Wagers.Offers.Size());i++)Add(-30,i,String.Format("%d: %s",i+1,d.Wagers.Offers[i].Label));
        }
        Add(-1,0,L(Mode==0?"CA_TC_RETURN":"CA_TC3_BACK"));Focus=Clamp(Focus,0,Max(0,int(Actions.Size())-1));
    }
    void Choose()
    {
        Build();if(Actions.Size()==0)return;int op=Actions[Focus],arg=Arguments[Focus];let d=Duel();let view=CaelumTrucazoWagerView.Read(User());
        if(op==-1){if(Mode==0){Close();return;}Mode=0;}
        else if(op==-11)Money=int(Clamp(double(Money)+arg*double(CaelumEconomyRules.GetCurrencyFaceValue(Step)),0.0,Min(double(CaelumTrucazoData.MAX_COPPER_OPERATION),view==null?0:view.Money)));
        else if(op==-12)Mode=1;
        else if(op==-20){Selected=arg;Quantity=view.Splittable[arg]?1:view.Amounts[arg];Mode=3;}
        else if(op==-22)Quantity=int(Clamp(double(Quantity)+arg*double(CaelumEconomyRules.GetCurrencyFaceValue(Step)),1.0,double(view.Amounts[Selected])));
        else if(op==-23)Quantity=view.Amounts[Selected];
        else if(op==-30){Selected=arg;Mode=2;}
        else if(SentSerial!=d.Serial)
        {
            SentSerial=d.Serial;
            if(op==-21)EventHandler.SendNetworkEvent("ca_tc3_offer",Selected,Quantity,d.Serial);
            else EventHandler.SendNetworkEvent("ca_tc3",op,arg,d.Serial);
            Mode=0;
        }
        Focus=0;
    }
    override void Ticker()
    {let d=Duel();if(d==null || d.Started || !d.Consequences || d.Suspended){Close();return;}Build();}
    override bool MenuEvent(int key,bool controller)
    {
        Build();int n=Max(1,int(Actions.Size()));
        if(key==MKEY_Up)Focus=(Focus+n-1)%n;else if(key==MKEY_Down)Focus=(Focus+1)%n;
        else if(key==MKEY_Enter)Choose();else if(key==MKEY_Back){if(Mode==0)Close();else{Mode=0;Focus=0;}}
        else if(key==MKEY_Left || key==MKEY_Right)Step=(Step+CaelumConstants.CURRENCY_TYPE_COUNT+(key==MKEY_Left?-1:1))%CaelumConstants.CURRENCY_TYPE_COUNT;
        return true;
    }
    override bool MouseEvent(int type,int x,int y)
    {
        let d=Duel();if(d==null)return true;Build();Pointer.Clear();
        Pointer.Move(((x-CaelumTrucazoMenu.UILeft())/CaelumTrucazoMenu.UIScale(),(y-CaelumTrucazoMenu.UITop())/CaelumTrucazoMenu.UIScale()));
        int first=(Focus/12)*12;
        for(int i=first;i<Min(first+12,int(Actions.Size()));i++)Pointer.Add(100+i,540,136+(i-first)*27,238,27);
        if(Actions.Size()>12){Pointer.Add(5000,540,456,100,30);Pointer.Add(5001,670,456,100,30);}
        int hit=Pointer.Hit();if(hit>=100 && hit<5000)Focus=hit-100;
        if(type==MOUSE_Click)Pointer.Press(d.Serial);
        else if(type==MOUSE_Release){int chosen=Pointer.Release(d.Serial);if(chosen>=5000)Focus=Clamp(first+(chosen==5000?-12:12),0,int(Actions.Size())-1);else if(chosen>=100){Focus=chosen-100;Choose();}}
        return true;
    }
    override void Drawer()
    {
        let d=Duel();let view=CaelumTrucazoWagerView.Read(User());if(d==null || d.Wagers==null)return;Build();
        Screen.Dim(0x080E12,1,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucazoMenu.Text(22,22,L("CA_TC3_REVIEW"),Font.CR_GOLD);
        CaelumTrucazoMenu.Wrap(22,50,750,L("CA_TC3_CONTRACT"));
        CaelumTrucazoMenu.Text(22,140,String.Format(L("CA_TC3_DRAFT"),Money,CaelumEconomyRules.GetCurrencyFaceValue(Step)),Font.CR_YELLOW);
        for(int i=0;i<d.Count();i++)CaelumTrucazoMenu.Text(22,174+i*20,String.Format(L("CA_TC3_COINS"),i+1,d.Wagers.Coins[i]));
        String detail="";
        if(Mode==2 && Selected<int(d.Wagers.Offers.Size()))
        {let offer=d.Wagers.Offers[Selected];detail=String.Format(L("CA_TC3_OFFER"),offer.Seat+1,ItemDetail(offer.Item,offer.Label),offer.Quantity,offer.Recipient+1);}
        else if(Mode==3 && view!=null && Selected<int(view.Labels.Size()))detail=String.Format(L("CA_TC3_ITEM_QUANTITY"),ItemDetail(view.Rows[Selected],view.Labels[Selected]),Quantity);
        else if(Mode==1 && view!=null && Focus<int(view.Labels.Size()))detail=ItemDetail(view.Rows[Focus],view.Labels[Focus]);
        else if(Actions.Size()>0 && Actions[Focus]==-30)
        {let offer=d.Wagers.Offers[Arguments[Focus]];detail=String.Format(L("CA_TC3_OFFER"),offer.Seat+1,ItemDetail(offer.Item,offer.Label),offer.Quantity,offer.Recipient+1);}
        CaelumTrucazoMenu.Wrap(22,350,490,detail,Font.CR_GOLD);
        if(view!=null && view.Status!="")CaelumTrucazoMenu.Wrap(22,435,490,L(view.Status),Font.CR_RED);
        CaelumTrucazoMenu.Wrap(22,515,750,L("CA_TC3_CONTROLS"),Font.CR_GRAY);
        int first=(Focus/12)*12;
        for(int i=first;i<Min(first+12,int(Actions.Size()));i++)
        {String label=Labels[i];if(label.Length()>28)label=label.Left(25).."...";CaelumTrucazoMenu.Text(544,140+(i-first)*27,(Focus==i?"> ":"  ")..label,Focus==i?Font.CR_GOLD:Font.CR_WHITE);}
        if(Actions.Size()>12){CaelumTrucazoMenu.Text(544,460,"<",Font.CR_GOLD);CaelumTrucazoMenu.Text(674,460,">",Font.CR_GOLD);}
    }
}
class CaelumTrucazoAccountMenu : ListMenu
{
    int SentSerial,First;
    CaelumMenuPointer Pointer;
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);DontDim=true;DontBlur=true;SentSerial=-1;Pointer=new('CaelumMenuPointer');}
    override bool MenuEvent(int key,bool controller)
    {
        if(key==MKEY_Back){Close();return true;}
        let claim=CaelumTrucazoClaims.Read(CaelumCardTableMenu.User());
        if(claim!=null && (key==MKEY_Up || key==MKEY_Down))First=Clamp(First+(key==MKEY_Up?-1:1),0,Max(0,claim.Pending()-8));
        if(key==MKEY_Enter && claim!=null && SentSerial!=claim.Serial)
        {SentSerial=claim.Serial;EventHandler.SendNetworkEvent("ca_tc_claim",claim.Serial);}
        return true;
    }
    override bool MouseEvent(int type,int x,int y)
    {
        let claim=CaelumTrucazoClaims.Read(CaelumCardTableMenu.User());if(claim==null)return true;
        Pointer.Clear();Pointer.Move(((x-CaelumTrucazoMenu.UILeft())/CaelumTrucazoMenu.UIScale(),(y-CaelumTrucazoMenu.UITop())/CaelumTrucazoMenu.UIScale()));
        Pointer.Add(1,22,520,450,32);Pointer.Add(2,600,520,60,32);Pointer.Add(3,700,520,60,32);
        if(type==MOUSE_Click)Pointer.Press(claim.Serial);
        else if(type==MOUSE_Release){int hit=Pointer.Release(claim.Serial);if(hit==1)MenuEvent(MKEY_Enter,false);else if(hit==2 || hit==3)MenuEvent(hit==2?MKEY_Up:MKEY_Down,false);}
        return true;
    }
    override void Drawer()
    {
        Screen.Dim(0x080E12,1,0,0,Screen.GetWidth(),Screen.GetHeight());
        let user=CaelumCardTableMenu.User();let claim=CaelumTrucazoClaims.Read(user);
        let record=user==null?null:CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
        CaelumTrucazoMenu.Text(22,24,CaelumCardTableMenu.L("CA_TC3_ACCOUNT"),Font.CR_GOLD);
        CaelumTrucazoMenu.Wrap(22,90,730,String.Format(CaelumCardTableMenu.L("CA_TC3_BALANCE"),record==null?0:record.TrucazoReputation,claim==null?0:claim.Copper,claim==null?0:claim.Pending()));
        CaelumTrucazoMenu.Wrap(22,170,730,CaelumCardTableMenu.L(user==null?"CA_TC3_LOAD":"CA_TC3_CLAIM_HELP"));
        if(claim!=null && claim.Status!="")CaelumTrucazoMenu.Wrap(22,260,730,CaelumCardTableMenu.L(claim.Status),Font.CR_YELLOW);
        if(claim!=null)
        {
            int row=0;for(int i=0;i<int(claim.Entries.Size());i++)if(claim.Entries[i].Ready)
            {if(row>=First && row<First+8){String label=claim.Entries[i].Label;if(label.Length()>80)label=label.Left(77).."...";CaelumTrucazoMenu.Text(22,310+(row-First)*23,label);}row++;}
            CaelumTrucazoMenu.Text(22,524,CaelumCardTableMenu.L("CA_TC3_CLAIM"),Font.CR_GOLD);
            if(row>8){CaelumTrucazoMenu.Text(600,524,"<",Font.CR_GOLD);CaelumTrucazoMenu.Text(700,524,">",Font.CR_GOLD);}
        }
    }
}
