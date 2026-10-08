// La ventilación usa el mayor estímulo, nunca suma calor y cansancio.
class CaelumBreathing : Object play
{
    static clearscope double Factor(double airRatio,double exposure,double toughness,bool canBreathe=true)
    {
        if(!canBreathe)return 1;
        int heat=exposure>0 ? CaelumThermalRules.Severity(exposure,toughness) : 0;
        if(airRatio<CaelumConstants.AIR_BREATHLESS_THRESHOLD || heat>=2)return CaelumThermalData.BREATHING_HIGH;
        if(airRatio<CaelumConstants.AIR_TIRED_THRESHOLD || heat>=1)return CaelumThermalData.BREATHING_MODERATE;
        return 1;
    }

    static double ActorFactor(Actor body)
    {
        if(body==null || body.health<=0 || body.WaterLevel>=3 || !CaelumThermalBody.Supported(body))return 1;
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        double maximum=user!=null && user.DerivedStats!=null ? user.DerivedStats.MaximumAir
            : npc!=null ? npc.MaximumCombatAir : 0;
        double air=user!=null ? user.CurrentAir : npc!=null ? npc.CurrentCombatAir : 0;
        let thermal=CaelumThermalBody.Get(body);
        return Factor(maximum>0 ? air/maximum : 1,thermal!=null ? thermal.Exposure : 0,thermal!=null ? thermal.Toughness : 0);
    }

    static Sound Cue(Actor body,double factor)
    {
        if(factor<=1 || CaelumThermalBody.FurryAnimal(body))return 0;
        let user=CaelumPlayer(body);
        bool female=user!=null && user.CharacterProfile!=null
            ? user.CharacterProfile.Sex==CaelumConstants.SEX_FEMALE : body is 'CaelumCaella';
        if(female)return factor>=CaelumThermalData.BREATHING_HIGH ? "caelum/breathing/female_high" : "caelum/breathing/female";
        return factor>=CaelumThermalData.BREATHING_HIGH ? "caelum/breathing/male_high" : "caelum/breathing/male";
    }

    static bool Playing(Actor body)
    {
        return body.IsActorPlayingSound(CHAN_BODY,"caelum/breathing/male")
            || body.IsActorPlayingSound(CHAN_BODY,"caelum/breathing/female")
            || body.IsActorPlayingSound(CHAN_BODY,"caelum/breathing/male_high")
            || body.IsActorPlayingSound(CHAN_BODY,"caelum/breathing/female_high");
    }

    static void StopAudio(Actor body)
    {
        if(body==null)return;
        if(Playing(body))body.A_StopSound(CHAN_BODY);
        let thermal=CaelumThermalBody.Get(body);
        if(thermal!=null){thermal.BreathAudioKnown=true;thermal.BreathAudioActive=false;thermal.BreathAudioCue=0;}
    }

    static void UpdateSound(Actor body)
    {
        if(body==null)return;
        let thermal=CaelumThermalBody.Get(body);
        if(thermal==null)return;
        let user=CaelumPlayer(body);
        double factor=ActorFactor(body);
        if(user!=null && (!CaelumPlayerAuthority.CanRead(user) || !user.CharacterCreationComplete || user.CreationWizardOpen))factor=1;
        Sound cue=Cue(body,factor);
        if(!thermal.BreathAudioKnown)
        {thermal.BreathAudioActive=Playing(body);thermal.BreathAudioKnown=true;}
        if(cue==0)
        {
            if(thermal.BreathAudioActive)StopAudio(body);
            return;
        }
        if(thermal.BreathAudioCue==cue && thermal.BreathAudioActive
            && level.maptime<thermal.NextBreathSoundTic)return;
        thermal.NextBreathSoundTic=level.maptime+TICRATE;
        bool playing=Playing(body);
        // Voz, armas y latido usan otros canales. Respetar también un efecto
        // corporal breve: el jadeo se reanuda cuando ese canal vuelve a estar libre.
        if(!body.IsActorPlayingSound(CHAN_BODY,cue) && (playing || !body.IsActorPlayingSound(CHAN_BODY)))
            body.A_StartSound(cue,CHAN_BODY,CHANF_LOOP);
        thermal.BreathAudioCue=cue;thermal.BreathAudioActive=true;
    }
}
