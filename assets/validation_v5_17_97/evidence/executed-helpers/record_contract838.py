"""Record the bounded source audit supporting the relationship-order guard."""
from pathlib import Path
import hashlib,json
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
native=Path(__file__).resolve().parents[2]/'build/v515/tools/gzdoom-g4.14.2'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
paths=['src/caelum/actors/CaelumVisualPerception.zs','src/caelum/actors/CaelumCommunication.zs','src/caelum/actors/CaelumAnchoredResident.zs','src/caelum/core/CaelumMajorTargets.zs','src/caelum/core/CaelumTarotEmperor.zs','src/caelum/player/CaelumPlayer.zs','src/caelum/player/CaelumPlayerAuthority.zs','src/caelum/equipment/CaelumPersistentCharacterState.zs']
engines=['src/playsim/p_mobj.cpp','src/scripting/vmthunks_actors.cpp','src/common/objects/dobjgc.cpp','src/common/rendering/hwrenderer/data/hw_clock.cpp','src/events.cpp']
report={'issue':838,'project_source_sha256':{p:sha(root/p) for p in paths},'native_source_tag':'g4.14.2','native_source_repository':'https://github.com/ZDoom/gzdoom/tree/g4.14.2','native_source_sha256':{p:sha(native/p) for p in engines},'proof':[
'CandidatesFor requires a living command leader and a nonnull observer SiegeCombatant; no added scan, cache, field, schema or timing state.',
'Opponent first checks Living and the clearscope Emperor Blocks helper. Ordinary observers are outside resident, summoned-Zupay, automaton and clone class families.',
'For those ordinary observers, candidate automaton/clone routing still calls RelatedOpponent on the same observer. Its resident branch cannot execute. Remaining paths only read theft, siege, player/native faction data. The shared-query siege branch already applies in this scope.',
'All excluded observers retain Opponent before OutsideGroupReach. In particular, CanBeFactionTarget calls GetPersistentCharacterState(false), which can run four material schema migrations even though it does not create a missing record.',
'MajorTargets.Enemy can call RelatedOpponent(candidateCombat,user), making a candidate resident trigger the same migration through an automaton/clone/summoned observer. Conservatively preserve the entire delegated families, even when no commander is assigned.',
'The unchanged strict horizontal bound uses current height, Insight and radii; when portal group count differs from one the guard is disabled. Every surviving candidate retains original distance/visibility/nearest-order semantics.',
'The final package inverse transformation restores parent visual source. Native fixtures verify the actual remote resident and delegated-automaton material migration, plus ordinary/fallback ordered selection and portal behavior.'
], 'diagnostic_findings':[
'Static first-order WorldTick boundary precedes ordinary event handlers; nested inclusive/exclusive scopes do not cover all engine/frame work. Complete700tic profile balanced28scopes with zero stack errors.',
'GC stop changes only the isolated diagnostic process threshold. Both paired processes force GC full at tic3200; maximum simulation interval remains above200ms with cycles stopped. No production GC setting is changed.',
'Native bench waits five wall seconds before writing benchmarks.txt when it activates FPS statistics. Initial requests exited before that wait. Final/control capture unchanged window and screenshot before bench, then allow350 extra tics; bench is a later CPU snapshot, not GPU/window-wide timing.'
]}
p=root/'assets/validation_v5_17_97/NATIVE_CONTRACT.json';p.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Recorded source hashes and scoped relationship/diagnostic contracts.')
