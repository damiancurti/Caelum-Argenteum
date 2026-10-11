// #192: elecciones independientes; los factores se derivan, nunca se acumulan.
class CaelumPersonalityRules : Object
{
    const REVISION=1;
    const LAYERS=4;
    const OPTIONS=3;
    const FIRST_PAGE=8;
    const LAST_PAGE=11;
    const PRIMARY_FACTOR=1.5;
    const BALANCED_FACTOR=1.25;
    const LIBERAL_PENETRATION=0.25;
    const CENTER_PENETRATION=0.125;
    const CENTER_ABSORPTION=1.125;
    const CONSERVATIVE_ABSORPTION=1.25;

    static clearscope bool Valid(CaelumCharacterProfile profile)
    {
        if(profile==null || profile.PersonalityRevision<REVISION)return false;
        for(int i=0;i<LAYERS;i++)if(profile.Personality[i]<0 || profile.Personality[i]>=OPTIONS)return false;
        return true;
    }
    static clearscope double MagicPower(CaelumCharacterProfile profile)
    {
        if(!Valid(profile))return 1;
        double factor=1;
        for(int i=0;i<3;i++)factor*=profile.Personality[i]==2?PRIMARY_FACTOR:profile.Personality[i]==1?BALANCED_FACTOR:1;
        return factor;
    }
    static clearscope double Alternative(CaelumCharacterProfile profile,int layer)
    {
        if(!Valid(profile))return 1;
        return profile.Personality[layer]==0?PRIMARY_FACTOR:profile.Personality[layer]==1?BALANCED_FACTOR:1;
    }
    static clearscope CaelumCharacterProfile Profile(Actor actor)
    {
        let user=CaelumPlayer(actor);
        return user!=null ? CaelumCharacterIdentity.Profile(user) : null;
    }
    static clearscope double Critical(Actor actor){return Alternative(Profile(actor),1);}
    static clearscope double Adrenaline(Actor actor){return Alternative(Profile(actor),0);}
    static clearscope double Evasion(Actor actor){return Alternative(Profile(actor),2);}
    static clearscope double Penetration(CaelumCharacterProfile profile)
    {
        if(!Valid(profile))return 0;
        return profile.Personality[3]==0?LIBERAL_PENETRATION:profile.Personality[3]==1?CENTER_PENETRATION:0;
    }
    static clearscope double Absorption(Actor actor,bool magical)
    {
        let profile=Profile(actor);
        if(!magical || !Valid(profile))return 1;
        return profile.Personality[3]==1?CENTER_ABSORPTION:profile.Personality[3]==2?CONSERVATIVE_ABSORPTION:1;
    }
    static clearscope Actor Attacker(Actor inflictor,Actor source=null)
    {
        if(source!=null)return source;
        let projectile=CaelumActorProjectile(inflictor);
        if(projectile!=null)return projectile.target;
        let channel=CaelumChannelEffect(inflictor);
        if(channel!=null)return channel.ChannelOwner;
        return inflictor;
    }
    static clearscope bool ExcludedRangedWeapon(Actor inflictor,Actor source=null)
    {
        int type=-1;
        let projectile=CaelumActorProjectile(inflictor);
        if(projectile!=null && projectile.CaelumWeaponWearPrepared)type=projectile.CaelumWearWeaponType;
        else
        {
            let user=CaelumPlayer(inflictor);
            if(user!=null && user.WeaponModel!=null && user.WeaponModel.Equipped)type=user.WeaponModel.WeaponType;
        }
        return type==CaelumConstants.WEAPON_TYPE_LONGBOW || type==CaelumConstants.WEAPON_TYPE_CROSSBOW
            || type==CaelumConstants.WEAPON_TYPE_CARBINE || type==CaelumConstants.WEAPON_TYPE_SHOTGUN;
    }
    static clearscope double AttackPenetration(Actor inflictor,Actor source=null)
    {
        if(ExcludedRangedWeapon(inflictor,source))return 0;
        let projectile=CaelumActorProjectile(inflictor);
        if(projectile!=null && projectile.CaelumPersonalityRevision>=REVISION)return projectile.CaelumIdeologyPenetration;
        return Penetration(Profile(Attacker(inflictor,source)));
    }
    static clearscope String LayerKey(int layer){return String.Format("CA_PERSONALITY_LAYER_%d",layer);}
    static clearscope String ChoiceKey(int layer,int choice){return String.Format("CA_PERSONALITY_%d_%d",layer,choice);}
    static clearscope int Pack(CaelumCharacterProfile profile)
    {
        if(!Valid(profile))return -1;
        int packed=0;for(int i=LAYERS-1;i>=0;i--)packed=packed*OPTIONS+profile.Personality[i];
        return packed;
    }
    static bool Unpack(CaelumCharacterProfile profile,int packed)
    {
        if(profile==null || packed<0 || packed>=81)return false;
        for(int i=0;i<LAYERS;i++){profile.Personality[i]=packed%OPTIONS;packed/=OPTIONS;}
        profile.PersonalityRevision=REVISION;return true;
    }
}
