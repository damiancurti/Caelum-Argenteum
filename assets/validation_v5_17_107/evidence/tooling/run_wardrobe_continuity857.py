"""Native wardrobe continuity using baseline-compatible diagnostic classes."""
from pathlib import Path
import argparse,sys,re
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');helper=Path(__file__).resolve().parent
parser=argparse.ArgumentParser(description=__doc__,epilog='Shared required arguments: --runtime PATH --output PATH. Optional shared arguments: --candidate PATH --load PATH. All outputs use a fresh build/ directory.')
parser.add_argument('--mode',required=True,choices=['seed','fresh','load','hub','disable','rollback','death','dead-load','motion','bench'])
parser.add_argument('--baseline-fixture',action='store_true')
parser.add_argument('--presentation-layer',type=Path)
parser.add_argument('--scene',default='CA836A',choices=['CA836A','MAP01','MAP02','MAP03'])
opt,rest=parser.parse_known_args();sys.argv=[sys.argv[0]]+rest
equipment=(helper/'wardrobe_equipment857.zs').read_text(encoding='utf-8')
setup=equipment[equipment.index('    void Setup()'):equipment.index('    void Catalogue()')]
setup=setup[:setup.index('        Check(CaelumWardrobeVisual.Enabled()')]+ '    }\n'
setup=setup.replace('if(armor!=null){Select(armor);','if(armor!=null){Armor=armor;Select(armor);')
fixture=(helper/'wardrobe_continuity857.zs').read_text(encoding='utf-8').replace('    // SETUP',setup)
if not opt.baseline_fixture:
    fixture=fixture.replace('// CANDIDATE_CHECKS','''if(expectedCandidate)
        {
            let body=CaelumWardrobePilotBody(User.PilotBody);
            Check(body!=null && body.WardrobeRevision==1 && body.CacheReady && body.BindingsReady,"revision and transient cache reconstructed");
            Check(body!=null && body.HeadKind==4 && body.BodyKind==0 && body.HandKind==3 && body.FootKind==4,"equipped four-region appearance reconstructed");
            if(body!=null)for(int region=0;region<4;region++)Check(body.CachedPieces[region]==CaelumClothing.Equipped(User,region),"cache references actual restored inventory object");
        }''')
    fixture=fixture.replace('// DEATH_CHECKS','''let body=CaelumWardrobePilotBody(User.PilotBody);
        Check(body!=null && body.FrozenDeath && body.SnapshotReady && body.BindingsReady,"saved death snapshot restored and rebound");
        Check(body!=null && body.HeadKind==4 && body.BodyKind==0 && body.HandKind==3 && body.FootKind==4,"death outfit unchanged after native equipment cleanup");''')
fixture=(ROOT/'assets/validation_541/session.zs').read_text(encoding='utf-8')+'\n'+fixture
on='set ca_wardrobe_candidate true; '
done='netevent ca857done; wait 35; quit\n'
plans={
 'bench':('' if opt.baseline_fixture else on)+'con_notifytime 0; wait 100; netevent ca857seed; wait 175; netevent ca857loaded '+('0' if opt.baseline_fixture else '1')+'; netevent ca857benchstart; wait 700; netevent ca857benchend; screenshot scene.png; '+done,
 'motion':on+'con_notifytime 0; wait 100; netevent ca857seed; wait 10; screenshot idle.png; cl_run false; +forward; wait 8; netevent ca857pose; screenshot walk.png; +speed; wait 8; netevent ca857pose; screenshot run.png; -forward; -speed; wait 20; +attack; wait 7; netevent ca857pose; screenshot attack.png; -attack; wait 70; +zoom; wait 2; -zoom; wait 10; netevent ca857pose; screenshot guard.png; +zoom; wait 2; -zoom; wait 15; netevent ca857view 1; +jump; wait 2; -jump; screenshot jump-preparation.png; wait 10; netevent ca857pose; screenshot jump-air.png; wait 100; netevent ca857view 2; screenshot back.png; netevent ca857motion; '+done,
 'seed':'wait 100; netevent ca857seed; wait 10; netevent ca857loaded 0; save reach.zds; wait 5; '+done,
 'fresh':on+'wait 100; netevent ca857seed; wait 10; netevent ca857loaded 1; netevent ca857fallback; screenshot idle.png; save reach.zds; wait 5; '+done,
 'load':on+'wait 1; netevent ca857loaded 1; screenshot loaded.png; save reach.zds; wait 5; '+done,
 'hub':on+'wait 1; netevent ca857loaded 1; changemap CA857B; wait 5; netevent ca857loaded 1; changemap CA836A; wait 5; netevent ca857loaded 1; save reach.zds; wait 5; '+done,
 'disable':on+'wait 1; netevent ca857loaded 1; set ca_wardrobe_candidate false; wait 3; netevent ca857loaded 0; save reach.zds; wait 5; '+done,
 'rollback':'wait 1; netevent ca857loaded 0; save reach.zds; wait 5; '+done,
 'death':on+'wait 100; netevent ca857seed; wait 10; netevent ca857loaded 1; netevent ca857kill; wait 70; netevent ca857dead; screenshot dead.png; save reach.zds; wait 5; '+done,
 'dead-load':on+'wait 1; netevent ca857dead; screenshot dead-loaded.png; save reach.zds; wait 5; '+done,
}
original=ROOT/'assets/validation_v5_17_96/run_reach_edges.py';source=original.read_text(encoding='utf-8')
start=source.index("    source=(ROOT/'assets/validation_v5_16_2/vision_edge_checks.zs')");end=source.index("    files={'ZSCRIPT':",start)
source=source[:start]+'    source='+repr(fixture)+'\n'+source[end:]
source=source.replace("'maps/CA836A.wad':wad,","'maps/CA836A.wad':wad,'maps/CA857B.wad':wad,")
source=source.replace('AddEventHandlers="CA836VisionEdges"','PlayerClasses="CaelumDomingoPilotPlayer" AddEventHandlers="CA857WardrobeProbe"')
source=source.replace('map CA836A "Candidate reach checks" {}','cluster 98 { hub } map CA836A "Wardrobe continuity" { cluster=98 } map CA857B "Wardrobe hub" { cluster=98 }')
start=source.index("    commands=out/'commands.cfg';");end=source.index('\n',start)
plan=plans[opt.mode].replace('wait 1;','wait 35;').replace('wait 5;','wait 35;')
plan=re.sub(r'(netevent [^;]+;)',r'\1 wait 3;',plan)
source=source[:start]+"    commands=out/'commands.cfg';commands.write_text("+repr(plan)+",encoding='utf-8')"+source[end:]
source=source.replace("'issue':836","'issue':857").replace("'Script error','VM execution aborted'","'Script error','Bad type for constant','already exists','VM execution aborted'")
source=source.replace("['+map','CA836A']","['+map',"+repr(opt.scene)+"]")
if opt.presentation_layer:
    source=source.replace('import argparse,','import os\nimport argparse,')
    source=source.replace('vid_maxfps=60','vid_maxfps=0\\nvid_vsync=false\\ncl_capfps=false')
    source=source.replace('    stopped=None',"    env=os.environ.copy();env.update(VK_LAYER_PATH="+repr(str(opt.presentation_layer.resolve()))+",VK_INSTANCE_LAYERS='VK_LAYER_CA_presentation',CA_PRESENT_TRACE=str(out/'presents.csv'))\n    markers={};stopped=None")
    source=source.replace('stderr=log,startupinfo=startup)','stderr=log,startupinfo=startup,env=env)')
    source=source.replace("            if any(s in sample", "            for marker in ('BEGIN','END'):\n                if marker not in markers and 'CA857 '+marker in sample:markers[marker]=time.perf_counter()*1000\n            if any(s in sample")
    source=source.replace("    (out/'RESULTS.json').write_text", "    sys_path=str(ROOT/'assets/validation_v5_12_7');import sys,re;sys.path.insert(0,sys_path)\n    from analyze_vulkan_presents import inspect,summarize\n    samples=[float(value) for value in re.findall(r'CA857 TIC ([\\d.]+)',text)]\n    report['presentation_markers']=markers;report['simulation']=summarize(samples) if samples else None\n    report['presentation']=inspect(out/'presents.csv',proc.pid,markers['BEGIN'],markers['END']) if len(markers)==2 else None\n    report['presentation_layer_sha256']=hashlib.sha256(Path("+repr(str(opt.presentation_layer.resolve()/'ca_presentation.dll'))+").read_bytes()).hexdigest()\n    (out/'RESULTS.json').write_text")
if opt.mode in ('death','dead-load'):
    source=source.replace("    command+=['+exec',str(commands)]","    command+=['-host','1','+exec',str(commands)]")
source=source.replace('Frozen fixture bodies; force high-density query only during each synchronous check, restore population flag immediately. Original CanSee predicate is the independent reference for actual Candidate selection. Not campaign acceptance.','Native wardrobe continuity phase '+opt.mode+'. Same diagnostic saved class names and base-compatible fields on both builds; checks actual clothing identity and visual selection. Not author acceptance.')
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
