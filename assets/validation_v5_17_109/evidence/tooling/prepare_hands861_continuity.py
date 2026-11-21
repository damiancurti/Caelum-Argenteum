"""Prepare a baseline-compatible save/visual fixture using actual owned gloves."""
from pathlib import Path
h=Path(__file__).resolve().parent;root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');dest=root/'assets/validation_v5_17_109';dest.mkdir(exist_ok=True)
fixture=(h/'hands861_candidate.zs').read_text(encoding='utf-8')
start=fixture.index('    void Setup()',fixture.index('class CA857WardrobeProbe'));end=fixture.index('    void Probe()',start);setup=fixture[start:end]
source='''// Baseline-compatible saved fixture fields; native gameplay remains authoritative.
class CA861HandProbe : EventHandler
{
    CaelumDomingoPilotPlayer User,DeadUser;
    int Checks,Failures,GloveId,GloveType,GloveWear;
    double GloveWeight;
    bool Seeded;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA836 EDGE %s hands861: %s",okay?"PASS":"FAIL",label);}
    void Select(CaelumEquipmentItem item)
    {User.EquipmentSelectionKind=item.EquipmentKind;User.EquipmentSelectionItemId=item.ItemId;User.RefreshEquipmentSelectionPreview();}
'''+setup+'''
    void Seed()
    {
        Setup();if(User==null)return;
        User.CharacterProfile.Sex=SEX861;User.ApplyCharacterProfile();
        let previous=CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_HANDS);
        if(previous!=null){Select(previous);User.UnequipSelectedNativeEquipment();}
        if(GLOVE861>=0)
        {
            int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
            let item=CaelumClothing.Create(User,GLOVE861,size);item.AttachToOwner(User);User.EnsureEquipmentItemId(item);
            Select(item);User.EquipSelectedNativeEquipment();
            GloveId=item.ItemId;GloveType=item.ItemType;GloveWear=item.Durability;GloveWeight=item.UnitWeight;
        }
        User.EquipmentMenuOpen=false;User.PersistCharacterState();Seeded=true;Loaded();
    }
    void Loaded()
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);
        Check(User!=null && Seeded,"actual player and saved fixture survive");if(User==null)return;
        let item=CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_HANDS);
        Check(GloveId==0?item==null:item!=null && item.Owner==User && item.ItemId==GloveId
            && item.ItemType==GloveType && item.Durability==GloveWear && item.UnitWeight==GloveWeight,"native saved glove identity and data remain intact");
        bool wanted=EXPECTED861 && GloveId>0;
        Check(CaelumAppearanceHands.HasGloves(User)==wanted,"current build selects its documented glove scope");
        int expected=wanted?(User.CharacterProfile.Sex==1?36:-1):User.CharacterProfile.Sex==1?18:0;
        Check(CaelumAppearanceHands.Variant(User)==expected,"saved sex and actual glove choose the expected existing art");
        CaelumAppearance.Apply(User);Check(User.AppearanceHasGloves==wanted,"world and preview flag share actual selection");
        // CACHE861
    }
    void Dead()
    {
        User=DeadUser!=null?DeadUser:CaelumDomingoPilotPlayer(players[0].mo);
        Check(User!=null && User.health<=0,"native player remains dead");if(User==null)return;
        Check(User.AppearanceDeathProfile!=null && User.AppearanceDeathGloves==(EXPECTED861 && GloveId>0),"death snapshot retains the actual pre-death glove selection");
        CaelumAppearance.Apply(User);Check(User.AppearanceHasGloves==User.AppearanceDeathGloves,"corpse uses saved appearance after equipment cleanup");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca861seed')Seed();
        if(e.Name=='ca861loaded')Loaded();
        if(e.Name=='ca861kill')
        {DeadUser=User;User.bInvulnerable=false;User.DamageMobj(User,User,10000000,'CaelumPhysicalTest',DMG_FORCED,0);}
        if(e.Name=='ca861dead')Dead();
        if(e.Name=='ca861done')Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
}
'''
(dest/'hand_continuity861.zs').write_text(source,encoding='utf-8',newline='\n')
print('Prepared common saved861 fixture; mode-specific runner follows.')
