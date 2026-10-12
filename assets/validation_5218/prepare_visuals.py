"""Build deterministic console capture sequences; wait requires one command chain."""
from pathlib import Path
here=Path(__file__).resolve().parent
def write(name,commands):
    (here/name).write_text('; '.join(['wait 70','netevent c209_prepare','wait 5']+commands+['netevent c209_done','wait 3','quit'])+'\n')
commands=[]
for sex in range(2):
    commands+= [f'netevent c209_race 2 {sex} 1','wait 5','netevent c209_rest 1','wait 5']
    for view in range(8):
        commands += [f'netevent c209_pose 17 {view}','wait 4',f'screenshot bed-{sex}-{view}.png']
write('bed_visual.cfg',commands)
commands=[]
for race,sex,gloves,variant in [(2,0,0,0),(2,1,0,18),(1,1,0,21),(0,1,0,24),(2,1,1,36)]:
    commands+=[f'netevent c209_race {race} {sex} 0',f'netevent c209_gloves {gloves}','netevent c209_live','wait 12',f'netevent c209_hand_check {variant}',f'screenshot actual-hands-{variant}.png']
write('hand_visual.cfg',commands)
write('native_motion.cfg',['netevent c209_live','netevent c209_trace','+forward','+speed','wait 140','-forward','-speed','wait 10','netevent c209_attack','wait 35','netevent c209_death','wait 80'])
write('weapons_visual.cfg',['netevent c209_race 2 1 0','netevent c209_live','netevent c209_weapon 0','wait 45','screenshot female-sword.png','+attack','wait 8','screenshot female-sword-attack.png','-attack','wait 30','netevent c209_shield','wait 35','+zoom','wait 12','screenshot female-shield.png','-zoom','wait 35','netevent c209_weapon 14','wait 45','screenshot female-shotgun.png','netevent c209_gloves 1','wait 12','screenshot female-shotgun-gloves.png'])
commands=[]
for race in range(4):
    for sex in range(2):
        for height in [0,2]:
            commands+=[f'netevent c209_race {race} {sex} 1',f'netevent c209_height {height}','wait 3','netevent c209_rest 0','wait 5','netevent c209_support']
            if race in (2,3) and height==0:
                commands += ['netevent c209_pose 16 2','wait 3',f'screenshot seat-{race}-{sex}.png']
commands+=['netevent c209_rest 2','wait 5','netevent c209_support','netevent c209_pose 17 2','wait 3','screenshot bag-side.png']
write('support.cfg',commands)
commands=['netevent c209_contract']
for race in [1,2,3]:
    for sex in range(2):
        commands += [f'netevent c209_race {race} {sex} 1','wait 3','netevent c209_pose 14 4','wait 5',f'screenshot corpse-{race}-{sex}.png','netevent c209_pose 0 0','wait 5',f'screenshot face-{race}-{sex}.png']
write('final_capture.cfg',commands)
