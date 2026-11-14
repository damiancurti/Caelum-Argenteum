"""Build the isolated native regional gallery with unchanged native production models."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,math,zipfile

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/regional_gallery_709'
COMMON=ROOT/'assets/validation_v5_17_4'
spec=importlib.util.spec_from_file_location('regional_gallery_geometry',COMMON/'build_gallery.py')
common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
wad=common.wad
def digest(blob):return hashlib.sha256(blob).hexdigest()


def build(output,baseline_materials=False):
    output.mkdir(parents=True,exist_ok=True)
    config=json.loads((SOURCE/'GALLERY.json').read_text())
    if baseline_materials:
        for plot in config['plots']:plot['floor']=config['walkway_flat']
    regions=json.loads((ROOT/'assets/bestiary/REGION_PROPOSAL.json').read_text())
    allowed={row['id']:row['proposed_campaign_regions'] for row in regions['entries']}
    exports=[ROOT/name for name in config['model_exports']]
    inputs=[SOURCE/'GALLERY.json',ROOT/'assets/bestiary/REGION_PROPOSAL.json',Path(__file__),COMMON/'build_gallery.py',COMMON/'gallery.zs',ROOT/'src/MODELDEF',*exports]
    sources={p.relative_to(ROOT).as_posix():digest(p.read_bytes()) for p in inputs}
    for export in exports:
        original=json.loads(export.read_text())
        for name,checksum in original['sha256'].items():
            if not name.startswith(('models/','caelum/')):continue
            path=ROOT/'src'/name
            if digest(path.read_bytes())!=checksum:raise ValueError('Changed native model source: '+name)
            sources['src/'+name]=checksum
    template=(COMMON/'gallery.zs').read_text(encoding='utf-8').replace('CA463','CA709').replace('ca463','ca709').replace('#463','#709')
    template=template.replace('CaelumPlayer(players[0].mo).CreationWizardOpen = false;',
        'CaelumPlayer(players[0].mo).CreationWizardOpen = false;\n            players[0].mo.bNOTARGET=true;players[0].mo.bInvulnerable=true;')
    if config.get('silent_observer_steps'):
        template=template.replace('    int Failures;', '    int Failures;\n    int ObserverNoiseSerial;')
        template=template.replace('            SPAWN_CASES', '            ObserverNoiseSerial=CaelumPlayer(players[0].mo).MovementNoiseEventSerial;\n            SPAWN_CASES')
        template=template.replace('        VERIFY_CASES', '        Check(CaelumPlayer(players[0].mo).MovementNoiseEventSerial==ObserverNoiseSerial,"inspection observer footsteps remain silent");\n        VERIFY_CASES')
        template=template.replace('    void Verify()', '''    // #692: silenciar sólo los pasos del observador en esta sala aislada.
    // La búsqueda por sonido es independiente de Friendly y NOTARGET.
    override void WorldTick()
    {
        if(level.MapName!="CA709G" || Subjects.Size()==0)return;
        let user=CaelumPlayer(players[0].mo);
        if(user!=null)user.MovementNoiseTimer=-CaelumConstants.MOVEMENT_NOISE_INTERVAL_SECONDS;
    }

    void Verify()''')
    boundary_count=len(config['plots'])-1
    template=template.replace('las dos uniones',f'las {boundary_count} uniones').replace('crosses both regional boundaries',f'crosses all {boundary_count} regional boundaries')
    template=template.replace('    void Verify()', "    bool IsIdleState(Actor body, State value)\n    {\n        return value==body.SpawnState || body.InStateSequence(value,body.FindState('IdleBreathing'));\n    }\n\n    void Verify()")
    template=template.replace('Subjects[index].CurState != MotionSnapshot[index]',
        'Subjects[index].CurState != MotionSnapshot[index] && IsIdleState(Subjects[index],MotionSnapshot[index]) && IsIdleState(Subjects[index],Subjects[index].CurState)')
    spawn=[];verify=[];views=[]
    for index,item in enumerate(config['subjects']):
        if item['region'] not in allowed[item['catalogue_id']]:raise ValueError('Unapproved region assignment')
        xyz=','.join(map(str,item['position']));actor=item['class'];ref=item['catalogue_id']
        spawn.append('{let item=CaelumBestiaryCombatActor(Actor.Spawn(\''+actor+'\',('+xyz+'),NO_REPLACE));'
                     'if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle='+str(item['angle'])+';}Subjects.Push(item);}')
        verify.append(f'Check(Subjects[{index}]!=null && Subjects[{index}].GetClass()==\'{actor}\',"subject {index} native class");')
        verify.append(f'if(Subjects[{index}]!=null){{Console.Printf("CA709 POSITION {index} xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[{index}].Pos.X,Subjects[{index}].Pos.Y,Subjects[{index}].Pos.Z,Subjects[{index}].Vel.X,Subjects[{index}].Vel.Y,Subjects[{index}].Vel.Z);Check((Subjects[{index}].Pos-({xyz})).Length()<0.01,"subject {index} saved position");'
                      f'let body=CaelumBestiaryCombatActor(Subjects[{index}]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="{ref}","subject {index} initialized inspection catalogue identity");}}')
    player_view=None
    for index,item in enumerate(config['views']):
        if item.get('control'):player_view=index;continue
        p=item['position'];delta=[b-a for a,b in zip(p,item['target'])]
        angle=math.degrees(math.atan2(delta[1],delta[0]));pitch=-math.degrees(math.atan2(delta[2],math.hypot(*delta[:2])))
        xyz=','.join(map(str,p))
        views.append(f'if(index=={index}){{View.SetOrigin(({xyz}),false);View.Angle={angle:.8f};View.Pitch={pitch:.8f};}}')
    assert player_view is not None
    crossing=config['crossing_test'];boundary=next(p['x'][0] for p in config['plots'] if p['region']==crossing['destination_plot'])
    replacements=dict(SPAWN_CASES='\n'.join(spawn),VERIFY_CASES='\n'.join(verify),VIEW_CASES='\n'.join(views),SUBJECT_COUNT=str(len(config['subjects'])),PLAYER_VIEW=str(player_view),
        CROSS_START='('+','.join(map(str,crossing['start']))+')',CROSS_ANGLE=str(crossing['angle']),CROSS_BOUNDARY=str(boundary))
    for key,value in replacements.items():template=template.replace(key,value)
    binary,textmap,stats=wad(config)
    files={'ZSCRIPT':('version "4.14.2"\n'+template).encode(),
        'MAPINFO':(f'map {config["map"]} "{config["title"]}" {{ sky1="CABASKY",0 nointermission }}\ngameinfo {{ AddEventHandlers="CA709GalleryEvents" }}\n').encode(),
        'maps/'+config['map']+'.wad':binary}
    fixture=output/'gallery.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,blob in sorted(files.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    (output/'gallery.zs').write_bytes(template.encode());(output/'TEXTMAP.txt').write_bytes(textmap)
    report=dict(issue=config['issue'],scope=config['status'],baseline_materials=baseline_materials,geometry=stats,subjects=config['subjects'],views=config['views'],
        source_sha256=sources,fixture_sha256=digest(fixture.read_bytes()),sha256={name:digest(blob) for name,blob in files.items()})
    (output/'GALLERY_MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    return fixture,report


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();fixture,report=build(args.output)
    print(json.dumps({'fixture':str(fixture),'geometry':report['geometry'],'subjects':len(report['subjects'])}))
