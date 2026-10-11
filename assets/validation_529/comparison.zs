// Comparacion reproducible: mismas fichas, asignacion recomendada, sin joyeria.
class CA192Comparison : CA192Native
{
    override void WorldTick()
    {
        Age++;if(Age!=40)return;User=CaelumPlayer(players[0].mo);
        Receiver=CaelumCombatActor(Actor.Spawn("CA192Target",User.Pos+(256,0,0)));
        Attacker=Actor.Spawn("CA192Target",User.Pos+(128,0,32));
        for(Inventory item=User.Inv;item!=null;item=item.Inv)
        {let equipment=CaelumEquipmentItem(item);if(equipment!=null)equipment.Equipped=false;}
        for(int build=0;build<2;build++)for(int tier=1;tier<=3;tier++)for(int offense=0;offense<3;offense++)
        {
            Reset();Choices(build*2,build*2,build*2,offense);
            let profile=User.CharacterProfile;profile.Race=CaelumConstants.RACE_HUMAN;
            profile.FirstClass=profile.SecondClass=build==0?CaelumConstants.CLASS_WARRIOR:CaelumConstants.CLASS_MAGE;
            profile.Sex=CaelumConstants.SEX_MALE;profile.HeightChoice=CaelumConstants.HEIGHT_NORMAL;
            User.CharacterAllocation.Recommend(profile);
            User.ArmorModel.InitializeUniformLoadout(build==0?CaelumConstants.ARMOR_TYPE_HEAVY:CaelumConstants.ARMOR_TYPE_MAGIC,tier);
            let record=User.GetPersistentCharacterState(true);record.TarotEffectTics=0;
            for(int card=0;card<78;card++)
            {
                int rank=(card-22)%14;
                record.TarotOwned[card]=tier==3 || (tier==2 && (card<11 || (card>=22
                    && (rank==0 || rank==1 || rank==2 || rank==4 || rank==5 || rank==7 || rank==8))));
            }
            User.DebugAttributesAt100=false;User.DebugAttributesAt75=false;User.ApplyCharacterProfile();
            Check("comparison Tarot percent",record.GetTarotAttributeBonusPercent(),tier==1?0:tier==2?50:100);
            User.WeaponModel.WeaponType=build==0?CaelumConstants.WEAPON_TYPE_SWORD:CaelumConstants.WEAPON_TYPE_BELL;
            User.WeaponModel.Tier=tier;User.WeaponModel.Equipped=true;
            double raw=build==0?User.DerivedStats.DebugSwordDamage*User.WeaponModel.GetDamage()/CaelumConstants.DEBUG_SWORD_BASE_DAMAGE
                :User.DerivedStats.DebugStaffDamage*User.WeaponModel.GetDamage()/CaelumConstants.DEBUG_STAFF_BASE_DAMAGE;
            double strength=User.Attributes.Strength,intelligence=User.Attributes.Intelligence;
            let shot=Shot(offense,User.WeaponModel.WeaponType,tier);
            for(int defense=0;defense<3;defense++)for(int blocked=0;blocked<2;blocked++)
            {
                Reset();Choices(0,0,0,defense);
                User.ArmorModel.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,tier);
                double afterShield=int(raw+0.5);CaelumEquipmentItem shield=null;
                if(blocked){shield=EquipShield(tier);afterShield=User.ResolveRealShieldDamage(shot,Attacker,afterShield,build==0?'Hitscan':'CaelumMagicTest');}
                User.PrepareRealArmorDamage(afterShield,false,CaelumConstants.ARMOR_SLOT_BODY,build==1,shot);
                double expected=Max(0,User.LastArmorPostDefenseDamage-(build==0?120.32:60.16));
                Check("comparison retains independent flat R",User.LastArmorHealthDamage,int(expected+0.5));
                Console.Printf("CA192 COMPARE build=%d tier=%d offense=%d defense=%d block=%d strength=%.4f intelligence=%.4f raw=%.4f afterShield=%.4f postArmor=%.4f final=%d volley=%d",
                    build,tier,offense,defense,blocked,strength,intelligence,raw,afterShield,User.LastArmorPostDefenseDamage,User.LastArmorHealthDamage,User.LastArmorHealthDamage*(build==0?1:12));
                if(shield!=null)shield.Destroy();
            }
            shot.Destroy();
        }
        Console.Printf("CA192 DONE failures=%d passes=%d",Failures,Passes);
    }
}
