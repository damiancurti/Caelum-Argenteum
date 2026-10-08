// Holds only the isolated camera player's fatigue to make each clip observable.
class CA140Audio : StaticEventHandler
{
    CaelumPlayer User;
    int Checks,Failures,LoadedAt;
    bool Reloaded;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA140 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldLoaded(WorldEvent e)
    {if(e.IsSaveGame){Reloaded=true;LoadedAt=level.time;User=CaelumPlayer(players[0].mo);}}
    override void WorldTick()
    {
        if(level.time==1)
        {User=CaelumPlayer(players[0].mo);User.InitializeDirectMapCharacter();User.PersistCharacterState();}
        if(User==null || User.DerivedStats==null)return;
        User.CreationWizardOpen=false;
        int stage=level.time<70 ? -1 : level.time<140 ? 0 : level.time<210 ? 1 : level.time<280 ? 2 : level.time<350 ? 3 : 4;
        User.CharacterProfile.Sex=stage>=2 ? CaelumConstants.SEX_FEMALE : CaelumConstants.SEX_MALE;
        User.CurrentAir=User.DerivedStats.MaximumAir*(stage<0 || stage>=4 ? 1 : stage%2==0 ? 0.49 : 0.09);
        let thermal=CaelumThermalBody.Get(User,true);thermal.Exposure=0;
        CaelumBreathing.UpdateSound(User);
        if(level.time==105 || level.time==175 || level.time==245 || level.time==315)
        {
            Sound cue=CaelumBreathing.Cue(User,CaelumBreathing.ActorFactor(User));
            Check(cue!=0 && User.IsActorPlayingSound(CHAN_BODY,cue),String.Format("native gender/intensity clip plays at stage %d",stage));
            User.A_StartSound("caelum/player/pain_male",CHAN_VOICE);
            Check(User.IsActorPlayingSound(CHAN_BODY,cue),"pain voice does not replace the breathing channel");
        }
        if(Reloaded && level.time==LoadedAt+2)
        {
            Sound cue=CaelumBreathing.Cue(User,CaelumBreathing.ActorFactor(User));
            Check(User.IsActorPlayingSound(CHAN_BODY,cue),"active breathing reconstructs after native save/load");
            Console.Printf("CA140 AUDIO_RELOAD failures=%d",Failures);
        }
        if(level.time==375)
        {
            Check(!CaelumBreathing.Playing(User),"recovered Air and safe temperature stop the loop");
            thermal.Exposure=CaelumThermalRules.Threshold(1,thermal.Toughness)+1;CaelumBreathing.UpdateSound(User);
            Check(User.IsActorPlayingSound(CHAN_BODY,"caelum/breathing/female"),"heat alone starts moderate female breathing");
            thermal.Exposure=CaelumThermalRules.Threshold(2,thermal.Toughness)+1;CaelumBreathing.UpdateSound(User);
            Check(User.IsActorPlayingSound(CHAN_BODY,"caelum/breathing/female_high"),"higher heat changes to the faster clip without stacking");
            User.health=0;CaelumBreathing.UpdateSound(User);
            Check(!CaelumBreathing.Playing(User),"dead actor has no looping panting");User.health=User.CaelumMaximumHealth;User.player.health=User.health;
            Console.Printf("CA140 AUDIO_COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
