"""Reproduce the historical armor-only hand selector without changing runtime."""
from pathlib import Path
h=Path(__file__).resolve().parent;root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');previous=root/'assets/validation_v5_17_107'
equipment=(previous/'wardrobe_equipment857.zs').read_text(encoding='utf-8')
setup=equipment[equipment.index('    void Setup()'):equipment.index('    void Catalogue()')]
setup=setup[:setup.index('        Check(CaelumWardrobeVisual.Enabled()')]+'    }\n'
fixture='''class CA857WardrobeProbe : EventHandler
{
    CaelumDomingoPilotPlayer User;
    int Checks,Failures;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA836 EDGE %s hands861: %s",okay?"PASS":"FAIL",label);}
    void Select(CaelumEquipmentItem item)
    {User.EquipmentSelectionKind=item.EquipmentKind;User.EquipmentSelectionItemId=item.ItemId;User.RefreshEquipmentSelectionPreview();}
'''+setup+'''
    void Probe()
    {
        Setup();if(User==null)return;
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        int kinds[]={CaelumClothingData.GF,CaelumClothingData.GC,CaelumClothingData.GW,CaelumClothingData.GP};
        for(int i=0;i<4;i++)
        {
            let glove=CaelumClothing.Create(User,kinds[i],size);glove.AttachToOwner(User);User.EnsureEquipmentItemId(glove);
            Select(glove);User.EquipSelectedNativeEquipment();
            Check(CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_HANDS)==glove,"native clothing glove is actually equipped");
            Check(!CaelumAppearanceHands.HasGloves(User),"baseline retains documented armor-only selector");
            User.CharacterProfile.Sex=CaelumConstants.SEX_MALE;
            Check(CaelumAppearanceHands.Variant(User)==0,"baseline clothing glove leaves male bare-hand variant");
            User.CharacterProfile.Sex=CaelumConstants.SEX_FEMALE;
            Check(CaelumAppearanceHands.Variant(User)==18,"baseline clothing glove leaves female bare-hand variant");
            User.CharacterProfile.Sex=CaelumConstants.SEX_MALE;
            Select(glove);User.UnequipSelectedNativeEquipment();
            Check(!CaelumAppearanceHands.HasGloves(User),"native clothing removal remains bare");
        }
        let armor=CaelumEquipmentItem(Actor.Spawn('CaelumArmorPickup',User.Pos,NO_REPLACE));
        armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;
        armor.ArmorSlot=CaelumConstants.ARMOR_SLOT_HANDS;armor.Tier=1;armor.EquipmentSize=size;
        armor.Durability=User.ArmorModel.GetMaximumDurabilityFor(armor.ItemType,armor.Tier,size);
        armor.UnitWeight=User.ArmorModel.GetWeightFor(armor.ArmorSlot,armor.ItemType,armor.Tier,size);
        armor.PickupDataInitialized=true;armor.AcquisitionResolved=true;armor.AttachToOwner(User);User.EnsureEquipmentItemId(armor);
        Select(armor);User.EquipSelectedNativeEquipment();
        Check(armor.Equipped && CaelumAppearanceHands.HasGloves(User),"actual hand armor selects accepted glove art");
        Check(CaelumAppearanceHands.Variant(User)==-1,"male armor keeps accepted original glove resources");
        User.CharacterProfile.Sex=CaelumConstants.SEX_FEMALE;
        Check(CaelumAppearanceHands.Variant(User)==36,"female armor selects accepted distinct glove variant");
        User.CharacterProfile.Sex=CaelumConstants.SEX_MALE;
        Select(armor);User.UnequipSelectedNativeEquipment();
        Check(!CaelumAppearanceHands.HasGloves(User),"native armor removal returns to bare hands");
        User.EquipmentMenuOpen=false;User.PersistCharacterState();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca857check')return;Probe();
        Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
}
'''
fixture=(root/'assets/validation_541/session.zs').read_text(encoding='utf-8')+'\n'+fixture
(h/'hands861_baseline.zs').write_text(fixture,encoding='utf-8')
runner='''from pathlib import Path
h=Path(__file__).resolve().parent
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
original=root/'assets/validation_v5_17_107/run_wardrobe857.py'
s=original.read_text(encoding='utf-8');fixture=(h/'hands861_baseline.zs').read_text(encoding='utf-8')
s=s.replace("fixture=(helper/'wardrobe_probe857.zs').read_text(encoding='utf-8')",'fixture='+repr(fixture))
s=s.replace("'issue':857", "'issue':861")
s=s.replace('Initial native compilation and JIT smoke only: instantiate the existing opt-in player, candidate body and native model-binding path. This does not establish actual equip behavior, save compatibility, performance or visual acceptance.','Historical armor-only hand selector reproduction using actual native clothing and armor equipment; expected old behavior, not a claim that clothing presentation is implemented.')
exec(compile(s,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
'''
(h/'run_hands861_baseline.py').write_text(runner,encoding='utf-8');print('Prepared baseline861 fixture and runner.')
