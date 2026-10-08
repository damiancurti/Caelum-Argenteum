// Diagnostic-only observer. Scripted deaths are labelled, use native damage,
// retain corpses, and never form part of the playable encounter.
class CA132Observer : EventHandler
{
    Actor View;
    int ScriptedDeaths, LastTotal;
    void Kill(CaelumPortSiege p,int count)
    {
        for(int i=0;i<p.Attackers.Size() && count>0;i++)
        {
            let b=p.Attackers[i].Body;
            if(b==null || !(b is "CaelumMandinga") || b.health<=0)continue;
            b.DamageMobj(null,null,1000000000,'None',DMG_FORCED);
            if(b.health<=0){count--;ScriptedDeaths++;}
        }
    }
    override void WorldTick()
    {
        let p=CaelumPortSiege.Get();if(p==null || !p.RosterSealed)return;
        bool diagnostic=CVar.GetCVar("ca132_diagnostic").GetBool();
        if(diagnostic && p.Boss!=null && p.Boss.Body!=null)p.Boss.Body.bInvulnerable=true;
        if(players[0].mo!=null)
        {
            players[0].mo.bInvulnerable=true;
            if(View==null)View=Actor.Spawn("CaelumSiegeRouteNode",(0,0,0));
            players[0].camera=View;
            int phase=(level.time/1750)%4;
            vector3 point=phase==0 ? (-14464,-14000,512) : phase==1 ? (-12000,-15000,384)
                : phase==2 ? (-14464,-20000,256) : (-14464,-13000,384);
            View.SetOrigin(point,false);View.Angle=phase==0 ? 270 : phase==1 ? 225 : phase==2 ? 90 : 270;
        }
        if(diagnostic && level.time>=6999 && level.time<=20649 && level.time%350==349)Kill(p,100);
        if(diagnostic && level.time>=22749 && level.time<=24499 && level.time%350==349)Kill(p,500);
        if(level.time%35!=0)return;
        int alive=0,defenders=0,corpses=0,projectiles=0;
        for(int i=0;i<p.Attackers.Size();i++)
            if(p.Attackers[i].Body!=null && p.Attackers[i].Body is "CaelumMandinga" && p.Attackers[i].Body.health>0)alive++;
        for(int i=0;i<p.Defenders.Size();i++)if(p.Defenders[i]!=null && p.Defenders[i].health>0)defenders++;
        let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null){if(body.bCorpse)corpses++;if(body.bMissile)projectiles++;}
        int total=p.Attackers.Size()-1,remaining=0,pending=0,failures=0;
        // CURRENT_COUNTERS
        let r=p.Reinforcements;
        if(r!=null){total=r.Successful;remaining=r.Remaining;pending=r.Pending;failures=r.PlacementFailures;}
        // END_CURRENT_COUNTERS
        Console.Printf("CA132 SIM tic=%d ms=%.6f alive=%d total=%d remaining=%d pending=%d combatants=%d defenders=%d corpses=%d projectiles=%d groups=%d failed=%d scriptedDeaths=%d victory=%d view=%d",level.time,MSTimeF(),alive,total,remaining,pending,CaelumPopulationState.Get().LivingCombatants,defenders,corpses,projectiles,p.Groups,failures,ScriptedDeaths,p.Victory,(level.time/1750)%4);
        if(total!=LastTotal){Console.Printf("CA132 SPAWN tic=%d total=%d",level.time,total);LastTotal=total;}
        if(level.time==35)Console.Printf("CA132 SETTINGS pause=%d lower=%d render=%d sound=%d volume=%.6f diagnostic=%d",CVar.GetCVar("i_pauseinbackground").GetInt(),CVar.GetCVar("vid_lowerinbackground").GetInt(),CVar.GetCVar("vid_activeinbackground").GetInt(),CVar.GetCVar("i_soundinbackground").GetInt(),CVar.GetCVar("snd_mastervolume").GetFloat(),diagnostic);
        if(level.time==CVar.GetCVar("ca132_stop_tic").GetInt())Console.Printf("CA132 PERFORMANCE COMPLETE tic=%d total=%d remaining=%d",level.time,total,remaining);
    }
    ui double LastFrame;
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(LastFrame>0)Console.Printf("CA132 FRAME tic=%d ms=%.6f interval=%.6f epoch=%d",level.time,now,now-LastFrame,SystemTime.Now());
        LastFrame=now;
    }
}
