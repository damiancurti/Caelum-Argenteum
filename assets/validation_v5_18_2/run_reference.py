"""Run the retained real-map observer with a final native scene capture.

The shared runner owns its approved population/window, native sync and explicit
Vulkan presentation layer. --current-view keeps the authored player start and
closes a greeting through native input before measurement. Legacy views remain
the default; no map, population, weather or observation-window value changes.
"""
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[2]
previous=ROOT/'assets/validation_v5_12_7/run_campaign_profile.py'
source=previous.read_text(encoding='utf8')
old='event ca510_frames; wait 3; quit'
assert source.count(old)==1
source=source.replace(old,'event ca510_frames; screenshot scene.png; wait 3; quit',1)
if '--current-view' in sys.argv:
    sys.argv.remove('--current-view')
    marker='    # Two bounded typed-registry observations'
    assert source.count(marker)==1
    setup='''
class CA468ReferenceSetup : StaticEventHandler
{
    bool Active;
    override void WorldTick()
    {
        let user=CaelumPlayer(players[consoleplayer].mo);
        Active=user!=null && user.HasActiveConversation();
    }
    override void UiTick()
    {
        if(Active)ConversationMenu.SendConversationReply(-1,0);
        if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
}
'''
    change='    source=source.replace(\'if(level.MapName=="MAP03")\',\'if(level.MapName=="MAP03" && SIEGE)\')\n'
    change+='    source+='+repr(setup)+'\n'
    source=source.replace(marker,change+marker,1)
    source=source.replace('AddEventHandlers="CA510Performance"','AddEventHandlers="CA510Performance","CA468ReferenceSetup"')
sys.path.insert(0,str(previous.parent))
exec(compile(source,str(previous),'exec'),{'__file__':str(previous),'__name__':'__main__'})
