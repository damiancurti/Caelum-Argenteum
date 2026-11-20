// #859: agarres derivados del catalogo y del ajuste de vestuario #857/#829.
class CaelumWornClothingModelData : Object
{
    const MODEL_SLOTS=17;
    static clearscope int Kind(int type,int region)
    {
        if(type<0 || type>=CaelumClothingData.COUNT || CaelumClothingData.Region(type)!=region)return -1;
        static const int values[]={0,1,2,3,4,5,6,7,8,9,10,0,1,2,3,4,0,1,2,3,0,1,2,3,4};
        return values[type];
    }
    static clearscope int Hidden(int body,int head,int hands,int feet)
    {
        static const int bodies[]={8216,8216,24,8216,8216,24,8216,8216,24,8216,8216};
        int hidden=body<0?16896:bodies[Clamp(body,0,10)];
        hidden|=head<0?1028:2;
        hidden|=hands<0?2048:384;
        hidden|=feet<0?4096:64;
        return hidden;
    }
    static clearscope name PantsFile(int body,int feet)
    {
        static const name files[]={'pants_F_bare.md3','pants_F_low.md3','pants_F_formal.md3','pants_F_ankle.md3','pants_F_tall.md3','pants_FW_bare.md3','pants_FW_low.md3','pants_FW_formal.md3','pants_FW_ankle.md3','pants_FW_tall.md3','pants_CS_bare.md3','pants_CS_low.md3','pants_CS_formal.md3','pants_CS_ankle.md3','pants_CS_tall.md3','pants_CE_bare.md3','pants_CE_low.md3','pants_CE_formal.md3','pants_CE_ankle.md3','pants_CE_tall.md3','pants_CW_bare.md3','pants_CW_low.md3','pants_CW_formal.md3','pants_CW_ankle.md3','pants_CW_tall.md3','pants_RS_bare.md3','pants_RS_low.md3','pants_RS_formal.md3','pants_RS_ankle.md3','pants_RS_tall.md3','pants_RE_bare.md3','pants_RE_low.md3','pants_RE_formal.md3','pants_RE_ankle.md3','pants_RE_tall.md3','pants_RW_bare.md3','pants_RW_low.md3','pants_RW_formal.md3','pants_RW_ankle.md3','pants_RW_tall.md3','pants_PS_bare.md3','pants_PS_low.md3','pants_PS_formal.md3','pants_PS_ankle.md3','pants_PS_tall.md3','pants_PE_bare.md3','pants_PE_low.md3','pants_PE_formal.md3','pants_PE_ankle.md3','pants_PE_tall.md3','pants_PW_bare.md3','pants_PW_low.md3','pants_PW_formal.md3','pants_PW_ankle.md3','pants_PW_tall.md3'};
        static const int foot[]={2,3,4,1,1};
        int variant=feet<0?0:foot[Clamp(feet,0,4)];
        return files[Clamp(body,0,10)*5+variant];
    }
    static clearscope name File(int slot,int body,int head,int hands,int feet)
    {
        static const name headFiles[]={'HF.md3','HC.md3','HR.md3','HW.md3','HP.md3'};
        static const name bodyFiles[]={'F.md3','FW.md3','CS.md3','CE.md3','CW.md3','RS.md3','RE.md3','RW.md3','PS.md3','PE.md3','PW.md3'};
        static const name handsFiles[]={'GF.md3','GC.md3','GW.md3','GP.md3'};
        static const name feetFiles[]={'BF.md3','BC.md3','BR.md3','BS.md3','BP.md3'};
        if(slot==9)return bodyFiles[Clamp(body,0,10)];
        if(slot==10)return headFiles[Clamp(head,0,4)];
        if(slot==11)return handsFiles[Clamp(hands,0,3)];
        if(slot==12)return feetFiles[Clamp(feet,0,4)];
        if(slot==14)return PantsFile(body,feet);
        static const name fixedFiles[]={'face.md3','hair.md3','hair_lower.md3','base_core.md3','base_arms.md3','base_neck.md3','base_feet.md3','left_hand.md3','right_hand.md3','None','None','None','None','base_forearms.md3','None','weapon.md3','shield.md3'};
        return fixedFiles[Clamp(slot,0,MODEL_SLOTS-1)];
    }
    static clearscope name Skin(int slot,int body,int head,int hands,int feet)
    {
        static const name headFiles[]={'hf.png','hc.png','hr.png','hw.png','hp.png'};
        static const name bodyFiles[]={'f.png','fw.png','cs.png','ce.png','cw.png','rs.png','re.png','rw.png','ps.png','pe.png','pw.png'};
        static const name handsFiles[]={'gf.png','gc.png','gw.png','gp.png'};
        static const name feetFiles[]={'bf.png','bc.png','br.png','bs.png','bp.png'};
        if(slot==9)return bodyFiles[Clamp(body,0,10)];
        if(slot==10)return headFiles[Clamp(head,0,4)];
        if(slot==11)return handsFiles[Clamp(hands,0,3)];
        if(slot==12)return feetFiles[Clamp(feet,0,4)];
        if(slot==14)return bodyFiles[Clamp(body,0,10)];
        return 'domingo_skin.png';
    }
    static clearscope String ModelPath(int slot)
    {
        switch(slot)
        {
            case 0:return "models/caelum/characters/domingo";
            case 1:return "models/caelum/characters/domingo";
            case 2:return "models/caelum/characters/worn";
            case 3:return "models/caelum/characters/worn";
            case 4:return "models/caelum/characters/worn";
            case 5:return "models/caelum/characters/worn";
            case 6:return "models/caelum/characters/worn";
            case 7:return "models/caelum/characters/grips";
            case 8:return "models/caelum/characters/grips";
            case 9:return "models/caelum/characters/worn";
            case 10:return "models/caelum/characters/worn";
            case 11:return "models/caelum/characters/grips";
            case 12:return "models/caelum/characters/worn";
            case 13:return "models/caelum/characters/worn";
            case 14:return "models/caelum/characters/worn";
            case 15:return "models/caelum/characters/grips";
            case 16:return "models/caelum/characters/grips";
        }
        return "";
    }
    static clearscope String SkinPath(int slot)
    {
        switch(slot)
        {
            case 0:return "models/caelum/characters/domingo";
            case 1:return "models/caelum/characters/domingo";
            case 2:return "models/caelum/characters/domingo";
            case 3:return "models/caelum/characters/domingo";
            case 4:return "models/caelum/characters/domingo";
            case 5:return "models/caelum/characters/domingo";
            case 6:return "models/caelum/characters/domingo";
            case 7:return "models/caelum/characters/domingo";
            case 8:return "models/caelum/characters/domingo";
            case 9:return "models/caelum/inventory/clothing";
            case 10:return "models/caelum/inventory/headwear";
            case 11:return "models/caelum/inventory/gloves";
            case 12:return "models/caelum/inventory/footwear";
            case 13:return "models/caelum/characters/domingo";
            case 14:return "models/caelum/inventory/clothing";
            case 15:return "models/caelum/characters/domingo";
            case 16:return "models/caelum/characters/domingo";
        }
        return "";
    }
}
