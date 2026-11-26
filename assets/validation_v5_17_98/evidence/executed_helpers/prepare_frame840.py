"""Extend exact nested scopes to PlayerThink and the native HUD boundaries."""
from pathlib import Path
base=Path(__file__).with_name('prepare_bursts838.py')
source=base.read_text(encoding='utf-8').replace('838','840')
def replace(old,new):
    global source
    assert source.count(old)==1,(old,source.count(old))
    source=source.replace(old,new,1)
replace("if cls in actor_classes and 'override void Tick()' in body:specs.append((path,cls,'Tick'))", "if cls in actor_classes and 'override void Tick()' in body:specs.append((path,cls,'Tick'))\n                if cls=='CaelumPlayer':specs.append((path,cls,'PlayerThink'))")
replace("        wrapper=f'''", "        start_tic=\"if(level.time>=3599 && level.time<=4299 && PlayerNumber()==0){let clock=CA840BurstProfile(StaticEventHandler.Find('CA840BurstProfile'));if(clock!=null)clock.StartTic();}\" if method=='PlayerThink' else ''\n        wrapper=f'''")
replace('''        CA840BurstProfile probe=null;''','''        {start_tic}
        CA840BurstProfile probe=null;''')
replace('''    restored=dict(files)''','''    ui_specs=[
        ('caelum/debug/CaelumDebugOverlay.zs','CaelumDebugOverlay','RenderOverlay','RenderEvent event','event'),
        ('caelum/hud/CaelumJournalOverlay.zs','CaelumJournalOverlay','RenderOverlay','RenderEvent event','event'),
        ('caelum/hud/CaelumHUDOverlay.zs','CaelumHUDOverlay','RenderOverlay','RenderEvent event','event'),
        ('caelum/ui/CaelumMenuAudio.zs','CaelumMenuAudio','RenderOverlay','RenderEvent e','e'),
        ('caelum/hud/CaelumStatusBar.zs','CaelumStatusBar','Draw','int state, double ticFraction','state,ticFraction')]
    with zipfile.ZipFile(args.runtime) as z:
        for key,(path,cls,method,parameters,arguments) in enumerate(ui_specs):
            if path not in files:files[path]=z.read(path).decode('utf-8');originals[path]=files[path]
            current=files[path];_,a,b=next(row for row in classes(current) if row[0]==cls);prior=current[a:b]
            anchor='override void '+method+'(';assert prior.count(anchor)==1
            name='CA840UIBody_'+cls
            updated=prior.replace(anchor,'ui void '+name+'(',1)
            wrapper=f"\\n    override void {method}({parameters})\\n    {{\\n        CA840BurstProfile probe=null;\\n        if(level.time>=3600 && level.time<4300)probe=CA840BurstProfile(StaticEventHandler.Find('CA840BurstProfile'));\\n        if(probe!=null)probe.BeginUI({key});\\n        {name}({arguments});\\n        if(probe!=null)probe.EndUI();\\n    }}\\n"
            updated=updated[:-1]+wrapper+updated[-1:];files[path]=current[:a]+updated+current[b:];edits.append((path,prior,updated))
    restored=dict(files)''')
replace('''    restored=dict(files)''','''    path='caelum/hud/CaelumStatusBar.zs';current=files[path]
    _,a,b=next(row for row in classes(current) if row[0]=='CaelumStatusBar');prior=current[a:b]
    assert 'override void Tick(' not in prior
    wrapper="\\n    override void Tick() { Super.Tick(); let probe=CA840BurstProfile(StaticEventHandler.Find('CA840BurstProfile')); if(probe!=null)probe.MarkTicEnd(); }\\n"
    updated=prior[:-1]+wrapper+prior[-1:];files[path]=current[:a]+updated+current[b:];edits.append((path,prior,updated))
    restored=dict(files)''')
replace('''    Array<double> StackStart,StackChildren;''','''    Array<double> StackStart,StackChildren,TicStart;
    ui Array<double> UIInclusive,UIStackStart,UnderlayStart,OverlayEnd,TicEnd;
    ui Array<int> UICalls,UIStackMetric,UIStackTic,UIFrames;
    ui bool UIReady;''')
replace('''        Wall.Resize(WINDOW);Ready=true;PreviousTic=-1;''','''        Wall.Resize(WINDOW);TicStart.Resize(WINDOW+1);Ready=true;PreviousTic=-1;''')
replace('''    override void WorldTick()
    {
        if(!Ready)return;
        double now=MSTimeF();
        if(level.time>=3600 && level.time<=4299 && PreviousTic==level.time-1)Wall[level.time-3600]=now-Previous;
        Previous=now;PreviousTic=level.time;
        if(level.time==4350 && !Printed)''','''    void StartTic()
    {
        if(!Ready)return;
        double now=MSTimeF();TicStart[level.time-3599]=now;
        if(level.time>=3600 && PreviousTic==level.time-1)Wall[level.time-3600]=now-Previous;
        Previous=now;PreviousTic=level.time;
    }
    ui void EnsureUI()
    {
        if(UIReady)return;
        UIInclusive.Resize(WINDOW*5);UICalls.Resize(WINDOW*5);
        UnderlayStart.Resize(WINDOW);OverlayEnd.Resize(WINDOW);TicEnd.Resize(WINDOW);UIFrames.Resize(WINDOW);UIReady=true;
    }
    ui void BeginUI(int metric)
    {EnsureUI();UIStackMetric.Push(metric);UIStackTic.Push(level.time-3600);UIStackStart.Push(MSTimeF());}
    ui void EndUI()
    {
        int last=UIStackMetric.Size()-1;
        int cell=UIStackMetric[last]*WINDOW+UIStackTic[last];
        UIInclusive[cell]+=MSTimeF()-UIStackStart[last];UICalls[cell]++;
        UIStackMetric.Pop();UIStackTic.Pop();UIStackStart.Pop();
    }
    override void RenderUnderlay(RenderEvent e)
    {
        EnsureUI();if(level.time<3600 || level.time>=4300)return;
        int row=level.time-3600;UnderlayStart[row]=MSTimeF();UIFrames[row]++;
    }
    ui void LastOverlay()
    {if(UIReady && level.time>=3600 && level.time<4300)OverlayEnd[level.time-3600]=MSTimeF();}
    ui void MarkTicEnd()
    {EnsureUI();if(level.time>=3600 && level.time<4300)TicEnd[level.time-3600]=MSTimeF();}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="ca510_frames" || !UIReady)return;
        for(int tic=0;tic<WINDOW;tic++)
        {
            Console.Printf("CA840 TIC_END tic=%d ms=%.6f",tic+3599,TicEnd[tic]);
            if(UIFrames[tic]>0)Console.Printf("CA840 FRAME tic=%d count=%d begin=%.6f underlay=%.6f overlay=%.6f next=%.6f",tic+3599,UIFrames[tic],TicStart[tic],UnderlayStart[tic],OverlayEnd[tic],TicStart[tic+1]);
            for(int metric=0;metric<5;metric++)
            {int cell=metric*WINDOW+tic;if(UICalls[cell]>0)Console.Printf("CA840 UI tic=%d metric=%d ms=%.6f calls=%d",tic+3599,metric,UIInclusive[cell],UICalls[cell]);}
        }
        Console.Printf("CA840 UI_COMPLETE depth=%d",UIStackMetric.Size());
    }
    override void WorldTick()
    {
        if(!Ready)return;
        if(level.time==4350 && !Printed)''')
replace("    first=specs[0][0];files[first]+=handler", "    handler+='\\nclass CA840FrameEnd : EventHandler { override void OnRegister(){SetOrder(2147483647);} override void RenderOverlay(RenderEvent e){let probe=CA840BurstProfile(StaticEventHandler.Find(\"CA840BurstProfile\"));if(probe!=null)probe.LastOverlay();} }\\n'\n    first=specs[0][0];files[first]+=handler")
replace('AddEventHandlers="CA840BurstProfile"','AddEventHandlers="CA840BurstProfile", "CA840FrameEnd"')
replace("'metrics':[{'id':i,'path':p,'class':c,'method':m} for i,(p,c,m) in enumerate(specs)]", "'metrics':[{'id':i,'path':p,'class':c,'method':m} for i,(p,c,m) in enumerate(specs)],'ui_metrics':[{'id':i,'path':p,'class':c,'method':m} for i,(p,c,m,_,_) in enumerate(ui_specs)]")
replace('Static first-order boundary precedes ordinary WorldTick callbacks; player-think/native engine work outside scopes remains residual.', 'PlayerThink entry of player0 defines each interval before WorldTick and Thinkers; HUD samples are assigned to the preceding simulation tic because native level.time increments before drawing. Inherited status-bar Tick is preserved and then timestamped at the end of P_Ticker. RenderUnderlay is after3D rendering; last RenderOverlay bounds the HUD callback phase. Remaining native/frame work is residual, not GPU time.')
exec(compile(source,str(base),'exec'),{'__name__':'__main__','__file__':str(base)})
