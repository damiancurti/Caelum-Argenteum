// Native data checks: artwork and the interactive appearance editor are separate.
class CA148Profile : StaticEventHandler
{
    int Failures;
    bool Done;
    void Check(bool ok,String label)
    {
        if(!ok)Failures++;
        Console.Printf("CA148 %s %s",ok?"PASS":"FAIL",label);
    }
    override void WorldTick()
    {
        if(Done || level.time<35)return;Done=true;
        let u=CaelumPlayer(players[0].mo);
        let p=CaelumCharacterIdentity.Profile(u);
        let r=u.GetPersistentCharacterState(false);
        Check(p!=null && p==r.IdentityProfile && p==u.CharacterProfile,"one authoritative saved profile");
        if(p==null)return;
        int hp=u.health,items=r.NextEquipmentItemId,race=p.Race,sex=p.Sex;
        double air=u.CurrentAir,anima=u.CurrentAnima;
        int mass=p.GetMassTier(),size=p.GetSizeTier(),profession=p.GetProfession();
        p.AppearanceRevision=0;p.SkinTone=2;p.BeastForm=3;
        CaelumCharacterIdentity.Bind(u,r,true);
        Check(p.AppearanceRevision==1 && p.SkinTone==0 && p.BeastForm==0,"legacy appearance initializes to default tone/form");
        p.SkinTone=2;p.BeastForm=3;
        CaelumCharacterIdentity.Bind(u,r,true);
        Check(p.SkinTone==2 && p.BeastForm==3,"repeat bind preserves saved tone/form");
        let copy=new("CaelumCharacterProfile");copy.CopyFrom(p);
        Check(copy.SkinTone==p.SkinTone && copy.BeastForm==p.BeastForm && copy.AppearanceRevision==1,"profile copies include appearance");
        Check(p.Race==race && p.Sex==sex && p.GetMassTier()==mass && p.GetSizeTier()==size
            && p.GetProfession()==profession,"appearance migration preserves structural identity");
        Check(u.health==hp && u.CurrentAir==air && u.CurrentAnima==anima
            && r.NextEquipmentItemId==items,"appearance migration grants no resources or equipment");
        CVar.GetCVar('ca_newchar_skintone',u.player).SetInt(1);
        CVar.GetCVar('ca_newchar_ready',u.player).SetBool(true);
        Check(!u.ConsumeNewCharacterDraft() && p.SkinTone==2 && p.BeastForm==3,"new-character bridge cannot recolor committed identity");
        u.ClearNewCharacterDraftReady();
        Check(CaelumCharacterIdentity.VoiceSex(u)==sex,"voice remains automatic by saved sex");
        copy.InitializeDefaultTestProfile();
        Check(copy.SkinTone==0 && copy.BeastForm==0 && copy.AppearanceRevision==1,"fresh direct-map profile uses default tone/form");
        Console.Printf("CA148 DONE failures=%d",Failures);
    }
}
