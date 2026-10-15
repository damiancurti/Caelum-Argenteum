"""Deterministic native command sequences for the approved #260 impulse."""
def generate(out):
    steps=['cl_run false','wait 100']
    def setup(mass=100,mode=0):
        steps.extend(['-forward','-back','-moveleft','-moveright','-speed','-crouch',
                      f'netevent c260_setup {mass} 0 {mode}','wait 16'])
    def gesture(key='forward',gap=3,hold=2):
        steps.extend([f'+{key}',f'wait {hold}',f'-{key}',f'wait {gap}',f'+{key}','wait 4'])
    def check(count):steps.extend([f'netevent c260i_check {count}','wait 2'])
    for mass in (50,100,200):
        setup(mass);gesture();check(1)
    for key in ('back','moveleft','moveright'):
        setup();gesture(key);check(1)
    setup();steps.extend(['+speed','wait 2']);gesture();check(1)
    setup();steps.extend(['+crouch','wait 35']);gesture();check(1)
    # Current diagonal, already moving sideways before the first forward tap.
    setup();steps.extend(['+moveright','wait 40']);gesture();check(1)
    # Both directions pressed twice: one debit, not one per axis.
    setup();steps.extend(['+forward','+moveright','wait 2','-forward','-moveright','wait 3',
                         '+forward','+moveright','wait 4']);check(1)
    # First tap and long hold do not activate; each new pair activates once.
    setup();steps.extend(['+forward','wait 35']);check(0)
    steps.extend(['-forward','wait 3']);gesture();check(1)
    steps.extend(['-forward','wait 3']);gesture();check(2)
    setup();gesture(gap=13);check(0)  # 15 tics between presses exceeds 0.4 seconds.
    setup();gesture(gap=12);check(1)  # Exactly 14 tics is allowed.
    setup();steps.extend(['netevent c260i_air 0','wait 3']);gesture();check(0)
    setup();steps.extend(['netevent c260i_air 5','wait 3']);gesture();check(0)
    setup();steps.extend(['netevent c260i_air 6','wait 3']);gesture();check(1)
    for block in ('menu','stun'):
        setup();steps.extend(['+forward','wait 2','-forward',f'netevent c260i_{block} 1',
                              'wait 2',f'netevent c260i_{block} 0','wait 2','+forward','wait 4']);check(0)
    setup();steps.extend(['netevent c260i_fall','wait 2']);gesture();check(0)
    setup(mode=1);gesture();check(1)
    steps.extend(['-forward','wait 2','netevent c260_done','wait 35','quit'])
    # Native console command lines have a bounded buffer: chain short scripts.
    chunks=[steps[i:i+45] for i in range(0,len(steps),45)]
    for i,chunk in enumerate(chunks):
        if i+1<len(chunks):chunk.append(f'exec impulse-part-{i+1}.cfg')
        name='impulse-contract.cfg' if i==0 else f'impulse-part-{i}.cfg'
        (out/name).write_bytes(('; '.join(chunk)+'\n').encode())
    (out/'impulse-water.cfg').write_bytes(b'cl_run false; wait 100; netevent c260_setup 100 0 2; wait 16; +forward; wait 2; -forward; wait 3; +forward; wait 4; netevent c260i_check 1; -forward; wait 2; netevent c260_done; wait 35; quit\n')
    (out/'impulse-manual.cfg').write_bytes(b'language es; cl_run false; con_notifytime 0; use_mouse true; bind f6 "netevent c260_setup 50"; bind f7 "netevent c260_setup 100"; bind f8 "netevent c260_setup 200"; bind f9 "netevent c260i_air 0"; wait 100; netevent c260_setup 100; wait 5; netevent c260_done;\n')
    (out/'impulse-edges.cfg').write_bytes(b'cl_run false; wait 100; netevent c260_setup 100; wait 16; netevent c260i_breathing; wait 3; +forward; wait 2; -forward; wait 3; +forward; wait 4; netevent c260i_check 1; netevent c260i_breathing_check; -forward; wait 5; netevent c260i_prediction; wait 2; netevent c260_setup 100; wait 16; +forward; wait 2; -forward; wait 2; netevent ca_movement_clear_taps; wait 2; +forward; wait 4; netevent c260i_check 0; -forward; wait 2; netevent c260i_external; wait 2; netevent c260_done; wait 35; quit\n')
    (out/'impulse-save.cfg').write_bytes(b'cl_run false; wait 100; netevent c260_setup 100; wait 16; +forward; wait 2; netevent c260i_snapshot; save half-tap.zds; wait 35; -forward; netevent c260_done; wait 35; quit\n')
    (out/'impulse-load.cfg').write_bytes(b'wait 10; +forward; wait 2; netevent c260i_check 0; -forward; wait 3; +forward; wait 4; netevent c260i_check 1; -forward; wait 2; netevent c260_done; wait 35; quit\n')
    (out/'impulse-world.cfg').write_bytes(b'cl_run false; wait 100; netevent c260_setup 100; wait 16; netevent c260i_turn 90; wait 2; +forward; wait 2; -forward; wait 3; +forward; wait 4; netevent c260i_check 1; netevent c260i_turn_check; -forward; wait 2; netevent c260_setup 100; wait 16; netevent c260i_wall; wait 2; +forward; wait 2; -forward; wait 3; +forward; wait 10; netevent c260i_wall_check; -forward; wait 2; netevent c260_done; wait 35; quit\n')
    (out/'impulse-input.cfg').write_bytes(b'cl_run false; wait 100; netevent c260_setup 100; wait 16; +forward; wait 2; +back; wait 2; -back; wait 3; netevent c260i_check 0; -forward; wait 2; netevent c260_setup 100; wait 16; +forward; wait 2; -forward; wait 3; +jump; +forward; wait 4; netevent c260i_jump_check; -jump; -forward; wait 2; netevent c260_done; wait 35; quit\n')
