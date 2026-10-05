// Respaldo nativo propio. Conserva alcance, daño y cadencia de los puños
// anteriores; no importa imágenes, puffs visibles ni sonidos de Doom.
class CaelumUnarmedWeapon : Weapon
{
    int PunchFrame;
    bool Punching;
    bool LeftPunch;
    transient CaelumFirstPersonShield ShieldView;

    Default
    {
        Weapon.SelectionOrder 3700;
        Weapon.SlotNumber 1;
        Weapon.KickBack 100;
        Tag "$CA_UNARMED_NAME";
        +WEAPON.WIMPY_WEAPON +WEAPON.MELEEWEAPON +WEAPON.NOAUTOSWITCHTO
        +INVENTORY.UNDROPPABLE +WEAPON.NOALERT
    }

    action void A_CaelumFistStart()
    {
        let user=CaelumPlayer(invoker.Owner);
        if(user==null || !user.CharacterCreationComplete || user.CreationWizardOpen
            || user.EquipmentMenuOpen || user.CraftingMenuOpen || user.IsPhysicallyImmobilized())return;
        invoker.Punching=false;
        if (user.DerivedStats==null) return;
        double cost=CaelumAttackRules.NaturalAir()*user.DerivedStats.AirConsumptionMultiplier;
        if (user.CurrentAir<cost) return;
        user.CurrentAir-=cost;
        user.UpdateAirStateEffects();
        invoker.Punching=true; invoker.PunchFrame=0;
        invoker.LeftPunch=!invoker.LeftPunch;
    }

    action void A_CaelumFistImpact()
    {
        if(!invoker.Punching)return;
        let user=CaelumPlayer(invoker.Owner);
        if(user==null || user.health<=0 || user.IsPhysicallyImmobilized())return;
        int damage=Random[Punch](1,10)*2;
        if(user.FindInventory("PowerStrength")!=null)damage*=10;
        double direction=user.Angle+Random2[Punch]()*(5.625/256);
        double distance=user.MeleeRange+MELEEDELTA;
        double aim=user.AimLineAttack(direction,distance,null,0,ALF_CHECK3D);
        FTranslatedLineTarget hit;
        user.LineAttack(direction,distance,aim,damage,'Melee',"CaelumSilentDetectionPuff",LAF_ISMELEEATTACK,hit);
        if(hit.linetarget!=null)
        {
            user.Angle=hit.angleFromSource;
        }
    }

    override void PSpriteTick(PSprite baseView)
    {
        Super.PSpriteTick(baseView);
        if(baseView.ID!=PSP_WEAPON)return;
        let user=CaelumPlayer(Owner);
        if(user==null || user.player==null)return;
        if(user.player.ReadyWeapon!=self || user.health<=0 || !user.CharacterCreationComplete
            || user.CreationWizardOpen || user.EquipmentMenuOpen || user.CraftingMenuOpen
            || CaelumRestState.IsActive(user) || user.ForcedSleepTics>0)
        {CaelumFirstPersonLayers.Clear(user);CaelumFirstPersonShield.Clear(user);ShieldView=null;return;}
        user.A_ClearOverlays(10,40);
        user.A_ClearOverlays(46,50);
        user.A_ClearOverlays(53,53);
        if(ShieldView==null)ShieldView=new("CaelumFirstPersonShield");
        bool outgoing=user.player.PendingWeapon!=null && user.player.PendingWeapon!=WP_NOCHANGE
            && user.player.PendingWeapon!=self;
        bool shieldBlocking=ShieldView.Update(user,baseView,outgoing,Punching);
        if(shieldBlocking)
        {
            CaelumFirstPersonLayers.Clear(user);
            if(Punching && ++PunchFrame>=22)Punching=false;
            return;
        }
        double lower=Max(0.0,baseView.y-WEAPONTOP);
        vector2 root=(baseView.x-lower*0.85,lower);
        double pulse=Punching?Sin(Clamp(PunchFrame,0,21)*180.0/22):0;
        // Antebrazos del mismo conjunto que las armas, unidos al borde inferior.
        vector2 left=(108,163),right=(212,163);
        if(LeftPunch)left+=(pulse*38,-pulse*25);
        else right+=(-pulse*38,-pulse*25);
        // La mano que ya sujeta el escudo sustituye al puño izquierdo libre.
        if(user.player.FindPSprite(CaelumFirstPersonShield.BODY_LAYER)!=null)
            user.A_ClearOverlays(51,51);
        else CaelumFirstPersonLayers.Hand(user,51,9,left+root,(0,0),0.90,0);
        CaelumFirstPersonLayers.Hand(user,52,10,right+root,(0,0),0.90,0);
        if(Punching && ++PunchFrame>=22)Punching=false;
    }

    action void A_CaelumTarotInput()
    {
        let user = CaelumPlayer(invoker.Owner);
        if (user != null) user.ReserveTarotInput();
    }

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady(WRF_ALLOWUSER3);
        Loop;
    Select:
        TNT1 A 1 A_Raise;
        Loop;
    Deselect:
        TNT1 A 1 A_Lower;
        Loop;
    Fire:
        TNT1 A 0 A_CaelumFistStart;
        TNT1 A 4;
        TNT1 A 4 A_CaelumFistImpact;
        TNT1 A 5;
        TNT1 A 4;
        TNT1 A 5 A_ReFire;
        Goto Ready;
    User3:
        TNT1 A 0 A_CaelumTarotInput;
        TNT1 A 1;
        Goto Ready;
    Spawn:
        TNT1 A -1;
        Stop;
    }
}
