// Same native gameplay trace on baseline and current packages, seed 116.
class CA137Invariance : StaticEventHandler
{
    int Checks,Failures;
    void Check(bool passed,String label)
    {Checks++;if(!passed){Failures++;Console.Printf("CA137 FAIL %s",label);}}
    void ClearShots()
    {
        let it=ThinkerIterator.Create("CaelumActorProjectile");Actor a;
        while((a=Actor(it.Next()))!=null)a.Destroy();
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;}
        int age=level.time-70;if(age<0)return;
        int index=age/3;
        if(index>262)return;
        if(age%3==0)
        {
            ClearShots();u.Vel=(0,0,0);u.SetOrigin((2048,4096,0),false);u.Angle=0;u.Pitch=0;
            if(index<240)
            {
                int weapons[]={CaelumConstants.WEAPON_TYPE_STAFF,CaelumConstants.WEAPON_TYPE_BELL,CaelumConstants.WEAPON_TYPE_BOOK,CaelumConstants.WEAPON_TYPE_STATUETTE};
                int w=index/60,essence=(index/12)%5,tier=(index/4)%3+1;
                bool secondary=index%4>=2,charged=index%2==1;
                u.WeaponModel.WeaponType=weapons[w];u.WeaponModel.Tier=tier;u.WeaponModel.EssenceType=essence;
                u.ReleasePendingStaffAttack(secondary,weapons[w],essence,charged);
            }
            else if(index<258)
            {
                int kind=(index-240)%9;
                let p=CaelumActorProjectile(Actor.Spawn(index<249 ? "CaelumActorSimpleElementalProjectile" : "CaelumActorExplosiveElementalProjectile",(2100,4096,60)));
                p.target=u;p.StoreCaelumElementalPayload(kind==8 ? 4 : kind/2,kind!=8 && kind%2==1,100,100);
                p.StoreCaelumAttackResult(73,true,false,true,1);p.ConfigureCaelumTravelDistance(320);p.Vel=(20,0,0);
            }
            else
            {
                Class<Actor> types[]={"CaelumArrowProjectile","CaelumBoltProjectile","CaelumCarbineProjectile","CaelumShotgunPellet","CaelumJavelinProjectile"};
                let p=CaelumActorProjectile(Actor.Spawn(types[index-258],(2100,4096,60)));
                p.target=u;p.Vel=(p.Speed,0,3);p.StoreCaelumAttackResult(79,true,false,false,1);
            }
        }
        if(age%3==1)
        {
            int count=0;let it=ThinkerIterator.Create("CaelumActorProjectile");CaelumActorProjectile p;
            while((p=CaelumActorProjectile(it.Next()))!=null)
            {
                Console.Printf("CA137 TRACE case=%d shot=%d type=%s hp=%d critical=%d essence=%d secondary=%d radius=%.7f height=%.7f scale=%.7f range=%.7f position=(%.7f,%.7f,%.7f) velocity=(%.7f,%.7f,%.7f)",index,count,p.GetClassName(),p.CaelumPreparedDamage,p.CaelumCriticalHit,p.CaelumEssenceType,p.CaelumSecondaryElement,p.Radius,p.Height,p.Scale.X,p.CaelumMaximumTravelDistance,p.Pos.X,p.Pos.Y,p.Pos.Z,p.Vel.X,p.Vel.Y,p.Vel.Z);
                if(CVar.GetCVar("ca137_mode").GetInt()==1 && index<258)
                {
                    int kind=p.CaelumEssenceType==4 ? 8 : p.CaelumEssenceType*2+int(p.CaelumSecondaryElement);
                    String sprites[]={"VFFR","VFLT","VFWA","VFIC","VFEA","VFPO","VFAI","VFLI","VFQU"};
                    Check(p.sprite==Actor.GetSpriteIndex(sprites[kind]),String.Format("element sprite case %d",index));
                    Check(p.frame>=0 && p.frame<4,"animated frame bounds");
                }
                count++;
            }
            Check(count==(index>=60 && index<120 ? 7 : 1),String.Format("projectile count case %d",index));
        }
        if(index==262 && age%3==2){ClearShots();Console.Printf("CA137 COMPLETE checks=%d failures=%d",Checks,Failures);}
    }
}
