// Generado por generate_appearance_hands.py.
class CaelumAppearanceHandFrames : Actor
{
    States (Weapon, Overlay)
    {
    V0_Hand_0:
        H000 A -1; Stop;
    V0_Hand_3:
        H001 A -1; Stop;
    V0_Hand_4:
        H002 A -1; Stop;
    V0_Hand_5:
        H003 A -1; Stop;
    V0_Hand_6:
        H004 A -1; Stop;
    V0_Hand_7:
        H005 A -1; Stop;
    V0_Hand_9:
        H006 A -1; Stop;
    V0_Hand_10:
        H007 A -1; Stop;
    V0_Hand_12:
        H008 A -1; Stop;
    V0_ShieldFrame_A:
        H009 A -1; Stop;
    V0_ShieldFrame_B:
        H009 B -1; Stop;
    V0_ShieldFrame_C:
        H009 C -1; Stop;
    V0_ShieldFrame_D:
        H009 D -1; Stop;
    V0_ShieldFrame_H:
        H009 H -1; Stop;
    V0_ShieldFrame_I:
        H009 I -1; Stop;
    V0_Shield_Idle:
        H009 AB 8; Loop;
    V0_Shield_Raise:
        H009 CD 3; Goto V0_Shield_Idle;
    V0_Shield_Lower:
        H009 D 3; H009 C -1; Stop;
    V0_Shield_Attack:
        H009 A 8; Goto V0_Shield_Idle;
    V0_Shield_Block:
        H009 H 3; Goto V0_Shield_Hold;
    V0_Shield_Hold:
        H009 I -1; Stop;
    V0_Bolas:
        H00A A -1; Stop;
    V0_Shotgun_0:
        H00B A -1; Stop;
    V0_Shotgun_1:
        H00C A -1; Stop;
    V0_Shotgun_2:
        H00D A -1; Stop;
    V0_Shotgun_3:
        H00E A -1; Stop;
    V0_Shotgun_4:
        H00F A -1; Stop;
    V0_Shotgun_5:
        H00G A -1; Stop;
    V0_Shotgun_6:
        H00H A -1; Stop;
    V0_javelin_T1_A:
        H00I A -1; Stop;
    V0_javelin_T2_A:
        H00J A -1; Stop;
    V0_javelin_T3_A:
        H00K A -1; Stop;
    V0_spear_T1_A:
        H00L A -1; Stop;
    V0_spear_T2_A:
        H00M A -1; Stop;
    V0_spear_T3_A:
        H00N A -1; Stop;
    V0_staff_T1_A:
        H00O A -1; Stop;
    V0_staff_T2_A:
        H00P A -1; Stop;
    V0_staff_T3_A:
        H00Q A -1; Stop;
    V0_statuette_T1_A:
        H00R A -1; Stop;
    V0_statuette_T2_A:
        H00S A -1; Stop;
    V0_statuette_T3_A:
        H00T A -1; Stop;
    V0_bell_T1_A:
        H00U A -1; Stop;
    V0_bell_T2_A:
        H00V A -1; Stop;
    V0_bell_T3_A:
        H00W A -1; Stop;
    V0_book_T1_A:
        H00X A -1; Stop;
    V0_book_T2_A:
        H00Y A -1; Stop;
    V0_book_T3_A:
        H00Z A -1; Stop;
    V0_book_T1_B:
        H010 A -1; Stop;
    V0_book_T2_B:
        H011 A -1; Stop;
    V0_book_T3_B:
        H012 A -1; Stop;
    V1_Hand_0:
        H013 A -1; Stop;
    V1_Hand_3:
        H014 A -1; Stop;
    V1_Hand_4:
        H015 A -1; Stop;
    V1_Hand_5:
        H016 A -1; Stop;
    V1_Hand_6:
        H017 A -1; Stop;
    V1_Hand_7:
        H018 A -1; Stop;
    V1_Hand_9:
        H019 A -1; Stop;
    V1_Hand_10:
        H01A A -1; Stop;
    V1_Hand_12:
        H01B A -1; Stop;
    V1_ShieldFrame_A:
        H01C A -1; Stop;
    V1_ShieldFrame_B:
        H01C B -1; Stop;
    V1_ShieldFrame_C:
        H01C C -1; Stop;
    V1_ShieldFrame_D:
        H01C D -1; Stop;
    V1_ShieldFrame_H:
        H01C H -1; Stop;
    V1_ShieldFrame_I:
        H01C I -1; Stop;
    V1_Shield_Idle:
        H01C AB 8; Loop;
    V1_Shield_Raise:
        H01C CD 3; Goto V1_Shield_Idle;
    V1_Shield_Lower:
        H01C D 3; H01C C -1; Stop;
    V1_Shield_Attack:
        H01C A 8; Goto V1_Shield_Idle;
    V1_Shield_Block:
        H01C H 3; Goto V1_Shield_Hold;
    V1_Shield_Hold:
        H01C I -1; Stop;
    V1_Bolas:
        H01D A -1; Stop;
    V1_Shotgun_0:
        H01E A -1; Stop;
    V1_Shotgun_1:
        H01F A -1; Stop;
    V1_Shotgun_2:
        H01G A -1; Stop;
    V1_Shotgun_3:
        H01H A -1; Stop;
    V1_Shotgun_4:
        H01I A -1; Stop;
    V1_Shotgun_5:
        H01J A -1; Stop;
    V1_Shotgun_6:
        H01K A -1; Stop;
    V1_javelin_T1_A:
        H01L A -1; Stop;
    V1_javelin_T2_A:
        H01M A -1; Stop;
    V1_javelin_T3_A:
        H01N A -1; Stop;
    V1_spear_T1_A:
        H01O A -1; Stop;
    V1_spear_T2_A:
        H01P A -1; Stop;
    V1_spear_T3_A:
        H01Q A -1; Stop;
    V1_staff_T1_A:
        H01R A -1; Stop;
    V1_staff_T2_A:
        H01S A -1; Stop;
    V1_staff_T3_A:
        H01T A -1; Stop;
    V1_statuette_T1_A:
        H01U A -1; Stop;
    V1_statuette_T2_A:
        H01V A -1; Stop;
    V1_statuette_T3_A:
        H01W A -1; Stop;
    V1_bell_T1_A:
        H01X A -1; Stop;
    V1_bell_T2_A:
        H01Y A -1; Stop;
    V1_bell_T3_A:
        H01Z A -1; Stop;
    V1_book_T1_A:
        H020 A -1; Stop;
    V1_book_T2_A:
        H021 A -1; Stop;
    V1_book_T3_A:
        H022 A -1; Stop;
    V1_book_T1_B:
        H023 A -1; Stop;
    V1_book_T2_B:
        H024 A -1; Stop;
    V1_book_T3_B:
        H025 A -1; Stop;
    V2_Hand_0:
        H026 A -1; Stop;
    V2_Hand_3:
        H027 A -1; Stop;
    V2_Hand_4:
        H028 A -1; Stop;
    V2_Hand_5:
        H029 A -1; Stop;
    V2_Hand_6:
        H02A A -1; Stop;
    V2_Hand_7:
        H02B A -1; Stop;
    V2_Hand_9:
        H02C A -1; Stop;
    V2_Hand_10:
        H02D A -1; Stop;
    V2_Hand_12:
        H02E A -1; Stop;
    V2_ShieldFrame_A:
        H02F A -1; Stop;
    V2_ShieldFrame_B:
        H02F B -1; Stop;
    V2_ShieldFrame_C:
        H02F C -1; Stop;
    V2_ShieldFrame_D:
        H02F D -1; Stop;
    V2_ShieldFrame_H:
        H02F H -1; Stop;
    V2_ShieldFrame_I:
        H02F I -1; Stop;
    V2_Shield_Idle:
        H02F AB 8; Loop;
    V2_Shield_Raise:
        H02F CD 3; Goto V2_Shield_Idle;
    V2_Shield_Lower:
        H02F D 3; H02F C -1; Stop;
    V2_Shield_Attack:
        H02F A 8; Goto V2_Shield_Idle;
    V2_Shield_Block:
        H02F H 3; Goto V2_Shield_Hold;
    V2_Shield_Hold:
        H02F I -1; Stop;
    V2_Bolas:
        H02G A -1; Stop;
    V2_Shotgun_0:
        H02H A -1; Stop;
    V2_Shotgun_1:
        H02I A -1; Stop;
    V2_Shotgun_2:
        H02J A -1; Stop;
    V2_Shotgun_3:
        H02K A -1; Stop;
    V2_Shotgun_4:
        H02L A -1; Stop;
    V2_Shotgun_5:
        H02M A -1; Stop;
    V2_Shotgun_6:
        H02N A -1; Stop;
    V2_javelin_T1_A:
        H02O A -1; Stop;
    V2_javelin_T2_A:
        H02P A -1; Stop;
    V2_javelin_T3_A:
        H02Q A -1; Stop;
    V2_spear_T1_A:
        H02R A -1; Stop;
    V2_spear_T2_A:
        H02S A -1; Stop;
    V2_spear_T3_A:
        H02T A -1; Stop;
    V2_staff_T1_A:
        H02U A -1; Stop;
    V2_staff_T2_A:
        H02V A -1; Stop;
    V2_staff_T3_A:
        H02W A -1; Stop;
    V2_statuette_T1_A:
        H02X A -1; Stop;
    V2_statuette_T2_A:
        H02Y A -1; Stop;
    V2_statuette_T3_A:
        H02Z A -1; Stop;
    V2_bell_T1_A:
        H030 A -1; Stop;
    V2_bell_T2_A:
        H031 A -1; Stop;
    V2_bell_T3_A:
        H032 A -1; Stop;
    V2_book_T1_A:
        H033 A -1; Stop;
    V2_book_T2_A:
        H034 A -1; Stop;
    V2_book_T3_A:
        H035 A -1; Stop;
    V2_book_T1_B:
        H036 A -1; Stop;
    V2_book_T2_B:
        H037 A -1; Stop;
    V2_book_T3_B:
        H038 A -1; Stop;
    V3_Hand_0:
        H039 A -1; Stop;
    V3_Hand_3:
        H03A A -1; Stop;
    V3_Hand_4:
        H03B A -1; Stop;
    V3_Hand_5:
        H03C A -1; Stop;
    V3_Hand_6:
        H03D A -1; Stop;
    V3_Hand_7:
        H03E A -1; Stop;
    V3_Hand_9:
        H03F A -1; Stop;
    V3_Hand_10:
        H03G A -1; Stop;
    V3_Hand_12:
        H03H A -1; Stop;
    V3_ShieldFrame_A:
        H03I A -1; Stop;
    V3_ShieldFrame_B:
        H03I B -1; Stop;
    V3_ShieldFrame_C:
        H03I C -1; Stop;
    V3_ShieldFrame_D:
        H03I D -1; Stop;
    V3_ShieldFrame_H:
        H03I H -1; Stop;
    V3_ShieldFrame_I:
        H03I I -1; Stop;
    V3_Shield_Idle:
        H03I AB 8; Loop;
    V3_Shield_Raise:
        H03I CD 3; Goto V3_Shield_Idle;
    V3_Shield_Lower:
        H03I D 3; H03I C -1; Stop;
    V3_Shield_Attack:
        H03I A 8; Goto V3_Shield_Idle;
    V3_Shield_Block:
        H03I H 3; Goto V3_Shield_Hold;
    V3_Shield_Hold:
        H03I I -1; Stop;
    V3_Bolas:
        H03J A -1; Stop;
    V3_Shotgun_0:
        H03K A -1; Stop;
    V3_Shotgun_1:
        H03L A -1; Stop;
    V3_Shotgun_2:
        H03M A -1; Stop;
    V3_Shotgun_3:
        H03N A -1; Stop;
    V3_Shotgun_4:
        H03O A -1; Stop;
    V3_Shotgun_5:
        H03P A -1; Stop;
    V3_Shotgun_6:
        H03Q A -1; Stop;
    V3_javelin_T1_A:
        H03R A -1; Stop;
    V3_javelin_T2_A:
        H03S A -1; Stop;
    V3_javelin_T3_A:
        H03T A -1; Stop;
    V3_spear_T1_A:
        H03U A -1; Stop;
    V3_spear_T2_A:
        H03V A -1; Stop;
    V3_spear_T3_A:
        H03W A -1; Stop;
    V3_staff_T1_A:
        H03X A -1; Stop;
    V3_staff_T2_A:
        H03Y A -1; Stop;
    V3_staff_T3_A:
        H03Z A -1; Stop;
    V3_statuette_T1_A:
        H040 A -1; Stop;
    V3_statuette_T2_A:
        H041 A -1; Stop;
    V3_statuette_T3_A:
        H042 A -1; Stop;
    V3_bell_T1_A:
        H043 A -1; Stop;
    V3_bell_T2_A:
        H044 A -1; Stop;
    V3_bell_T3_A:
        H045 A -1; Stop;
    V3_book_T1_A:
        H046 A -1; Stop;
    V3_book_T2_A:
        H047 A -1; Stop;
    V3_book_T3_A:
        H048 A -1; Stop;
    V3_book_T1_B:
        H049 A -1; Stop;
    V3_book_T2_B:
        H04A A -1; Stop;
    V3_book_T3_B:
        H04B A -1; Stop;
    V4_Hand_0:
        H04C A -1; Stop;
    V4_Hand_3:
        H04D A -1; Stop;
    V4_Hand_4:
        H04E A -1; Stop;
    V4_Hand_5:
        H04F A -1; Stop;
    V4_Hand_6:
        H04G A -1; Stop;
    V4_Hand_7:
        H04H A -1; Stop;
    V4_Hand_9:
        H04I A -1; Stop;
    V4_Hand_10:
        H04J A -1; Stop;
    V4_Hand_12:
        H04K A -1; Stop;
    V4_ShieldFrame_A:
        H04L A -1; Stop;
    V4_ShieldFrame_B:
        H04L B -1; Stop;
    V4_ShieldFrame_C:
        H04L C -1; Stop;
    V4_ShieldFrame_D:
        H04L D -1; Stop;
    V4_ShieldFrame_H:
        H04L H -1; Stop;
    V4_ShieldFrame_I:
        H04L I -1; Stop;
    V4_Shield_Idle:
        H04L AB 8; Loop;
    V4_Shield_Raise:
        H04L CD 3; Goto V4_Shield_Idle;
    V4_Shield_Lower:
        H04L D 3; H04L C -1; Stop;
    V4_Shield_Attack:
        H04L A 8; Goto V4_Shield_Idle;
    V4_Shield_Block:
        H04L H 3; Goto V4_Shield_Hold;
    V4_Shield_Hold:
        H04L I -1; Stop;
    V4_Bolas:
        H04M A -1; Stop;
    V4_Shotgun_0:
        H04N A -1; Stop;
    V4_Shotgun_1:
        H04O A -1; Stop;
    V4_Shotgun_2:
        H04P A -1; Stop;
    V4_Shotgun_3:
        H04Q A -1; Stop;
    V4_Shotgun_4:
        H04R A -1; Stop;
    V4_Shotgun_5:
        H04S A -1; Stop;
    V4_Shotgun_6:
        H04T A -1; Stop;
    V4_javelin_T1_A:
        H04U A -1; Stop;
    V4_javelin_T2_A:
        H04V A -1; Stop;
    V4_javelin_T3_A:
        H04W A -1; Stop;
    V4_spear_T1_A:
        H04X A -1; Stop;
    V4_spear_T2_A:
        H04Y A -1; Stop;
    V4_spear_T3_A:
        H04Z A -1; Stop;
    V4_staff_T1_A:
        H050 A -1; Stop;
    V4_staff_T2_A:
        H051 A -1; Stop;
    V4_staff_T3_A:
        H052 A -1; Stop;
    V4_statuette_T1_A:
        H053 A -1; Stop;
    V4_statuette_T2_A:
        H054 A -1; Stop;
    V4_statuette_T3_A:
        H055 A -1; Stop;
    V4_bell_T1_A:
        H056 A -1; Stop;
    V4_bell_T2_A:
        H057 A -1; Stop;
    V4_bell_T3_A:
        H058 A -1; Stop;
    V4_book_T1_A:
        H059 A -1; Stop;
    V4_book_T2_A:
        H05A A -1; Stop;
    V4_book_T3_A:
        H05B A -1; Stop;
    V4_book_T1_B:
        H05C A -1; Stop;
    V4_book_T2_B:
        H05D A -1; Stop;
    V4_book_T3_B:
        H05E A -1; Stop;
    V5_Hand_0:
        H05F A -1; Stop;
    V5_Hand_3:
        H05G A -1; Stop;
    V5_Hand_4:
        H05H A -1; Stop;
    V5_Hand_5:
        H05I A -1; Stop;
    V5_Hand_6:
        H05J A -1; Stop;
    V5_Hand_7:
        H05K A -1; Stop;
    V5_Hand_9:
        H05L A -1; Stop;
    V5_Hand_10:
        H05M A -1; Stop;
    V5_Hand_12:
        H05N A -1; Stop;
    V5_ShieldFrame_A:
        H05O A -1; Stop;
    V5_ShieldFrame_B:
        H05O B -1; Stop;
    V5_ShieldFrame_C:
        H05O C -1; Stop;
    V5_ShieldFrame_D:
        H05O D -1; Stop;
    V5_ShieldFrame_H:
        H05O H -1; Stop;
    V5_ShieldFrame_I:
        H05O I -1; Stop;
    V5_Shield_Idle:
        H05O AB 8; Loop;
    V5_Shield_Raise:
        H05O CD 3; Goto V5_Shield_Idle;
    V5_Shield_Lower:
        H05O D 3; H05O C -1; Stop;
    V5_Shield_Attack:
        H05O A 8; Goto V5_Shield_Idle;
    V5_Shield_Block:
        H05O H 3; Goto V5_Shield_Hold;
    V5_Shield_Hold:
        H05O I -1; Stop;
    V5_Bolas:
        H05P A -1; Stop;
    V5_Shotgun_0:
        H05Q A -1; Stop;
    V5_Shotgun_1:
        H05R A -1; Stop;
    V5_Shotgun_2:
        H05S A -1; Stop;
    V5_Shotgun_3:
        H05T A -1; Stop;
    V5_Shotgun_4:
        H05U A -1; Stop;
    V5_Shotgun_5:
        H05V A -1; Stop;
    V5_Shotgun_6:
        H05W A -1; Stop;
    V5_javelin_T1_A:
        H05X A -1; Stop;
    V5_javelin_T2_A:
        H05Y A -1; Stop;
    V5_javelin_T3_A:
        H05Z A -1; Stop;
    V5_spear_T1_A:
        H060 A -1; Stop;
    V5_spear_T2_A:
        H061 A -1; Stop;
    V5_spear_T3_A:
        H062 A -1; Stop;
    V5_staff_T1_A:
        H063 A -1; Stop;
    V5_staff_T2_A:
        H064 A -1; Stop;
    V5_staff_T3_A:
        H065 A -1; Stop;
    V5_statuette_T1_A:
        H066 A -1; Stop;
    V5_statuette_T2_A:
        H067 A -1; Stop;
    V5_statuette_T3_A:
        H068 A -1; Stop;
    V5_bell_T1_A:
        H069 A -1; Stop;
    V5_bell_T2_A:
        H06A A -1; Stop;
    V5_bell_T3_A:
        H06B A -1; Stop;
    V5_book_T1_A:
        H06C A -1; Stop;
    V5_book_T2_A:
        H06D A -1; Stop;
    V5_book_T3_A:
        H06E A -1; Stop;
    V5_book_T1_B:
        H06F A -1; Stop;
    V5_book_T2_B:
        H06G A -1; Stop;
    V5_book_T3_B:
        H06H A -1; Stop;
    V6_Hand_0:
        H06I A -1; Stop;
    V6_Hand_3:
        H06J A -1; Stop;
    V6_Hand_4:
        H06K A -1; Stop;
    V6_Hand_5:
        H06L A -1; Stop;
    V6_Hand_6:
        H06M A -1; Stop;
    V6_Hand_7:
        H06N A -1; Stop;
    V6_Hand_9:
        H06O A -1; Stop;
    V6_Hand_10:
        H06P A -1; Stop;
    V6_Hand_12:
        H06Q A -1; Stop;
    V6_ShieldFrame_A:
        H06R A -1; Stop;
    V6_ShieldFrame_B:
        H06R B -1; Stop;
    V6_ShieldFrame_C:
        H06R C -1; Stop;
    V6_ShieldFrame_D:
        H06R D -1; Stop;
    V6_ShieldFrame_H:
        H06R H -1; Stop;
    V6_ShieldFrame_I:
        H06R I -1; Stop;
    V6_Shield_Idle:
        H06R AB 8; Loop;
    V6_Shield_Raise:
        H06R CD 3; Goto V6_Shield_Idle;
    V6_Shield_Lower:
        H06R D 3; H06R C -1; Stop;
    V6_Shield_Attack:
        H06R A 8; Goto V6_Shield_Idle;
    V6_Shield_Block:
        H06R H 3; Goto V6_Shield_Hold;
    V6_Shield_Hold:
        H06R I -1; Stop;
    V6_Bolas:
        H06S A -1; Stop;
    V6_Shotgun_0:
        H06T A -1; Stop;
    V6_Shotgun_1:
        H06U A -1; Stop;
    V6_Shotgun_2:
        H06V A -1; Stop;
    V6_Shotgun_3:
        H06W A -1; Stop;
    V6_Shotgun_4:
        H06X A -1; Stop;
    V6_Shotgun_5:
        H06Y A -1; Stop;
    V6_Shotgun_6:
        H06Z A -1; Stop;
    V6_javelin_T1_A:
        H070 A -1; Stop;
    V6_javelin_T2_A:
        H071 A -1; Stop;
    V6_javelin_T3_A:
        H072 A -1; Stop;
    V6_spear_T1_A:
        H073 A -1; Stop;
    V6_spear_T2_A:
        H074 A -1; Stop;
    V6_spear_T3_A:
        H075 A -1; Stop;
    V6_staff_T1_A:
        H076 A -1; Stop;
    V6_staff_T2_A:
        H077 A -1; Stop;
    V6_staff_T3_A:
        H078 A -1; Stop;
    V6_statuette_T1_A:
        H079 A -1; Stop;
    V6_statuette_T2_A:
        H07A A -1; Stop;
    V6_statuette_T3_A:
        H07B A -1; Stop;
    V6_bell_T1_A:
        H07C A -1; Stop;
    V6_bell_T2_A:
        H07D A -1; Stop;
    V6_bell_T3_A:
        H07E A -1; Stop;
    V6_book_T1_A:
        H07F A -1; Stop;
    V6_book_T2_A:
        H07G A -1; Stop;
    V6_book_T3_A:
        H07H A -1; Stop;
    V6_book_T1_B:
        H07I A -1; Stop;
    V6_book_T2_B:
        H07J A -1; Stop;
    V6_book_T3_B:
        H07K A -1; Stop;
    V7_Hand_0:
        H07L A -1; Stop;
    V7_Hand_3:
        H07M A -1; Stop;
    V7_Hand_4:
        H07N A -1; Stop;
    V7_Hand_5:
        H07O A -1; Stop;
    V7_Hand_6:
        H07P A -1; Stop;
    V7_Hand_7:
        H07Q A -1; Stop;
    V7_Hand_9:
        H07R A -1; Stop;
    V7_Hand_10:
        H07S A -1; Stop;
    V7_Hand_12:
        H07T A -1; Stop;
    V7_ShieldFrame_A:
        H07U A -1; Stop;
    V7_ShieldFrame_B:
        H07U B -1; Stop;
    V7_ShieldFrame_C:
        H07U C -1; Stop;
    V7_ShieldFrame_D:
        H07U D -1; Stop;
    V7_ShieldFrame_H:
        H07U H -1; Stop;
    V7_ShieldFrame_I:
        H07U I -1; Stop;
    V7_Shield_Idle:
        H07U AB 8; Loop;
    V7_Shield_Raise:
        H07U CD 3; Goto V7_Shield_Idle;
    V7_Shield_Lower:
        H07U D 3; H07U C -1; Stop;
    V7_Shield_Attack:
        H07U A 8; Goto V7_Shield_Idle;
    V7_Shield_Block:
        H07U H 3; Goto V7_Shield_Hold;
    V7_Shield_Hold:
        H07U I -1; Stop;
    V7_Bolas:
        H07V A -1; Stop;
    V7_Shotgun_0:
        H07W A -1; Stop;
    V7_Shotgun_1:
        H07X A -1; Stop;
    V7_Shotgun_2:
        H07Y A -1; Stop;
    V7_Shotgun_3:
        H07Z A -1; Stop;
    V7_Shotgun_4:
        H080 A -1; Stop;
    V7_Shotgun_5:
        H081 A -1; Stop;
    V7_Shotgun_6:
        H082 A -1; Stop;
    V7_javelin_T1_A:
        H083 A -1; Stop;
    V7_javelin_T2_A:
        H084 A -1; Stop;
    V7_javelin_T3_A:
        H085 A -1; Stop;
    V7_spear_T1_A:
        H086 A -1; Stop;
    V7_spear_T2_A:
        H087 A -1; Stop;
    V7_spear_T3_A:
        H088 A -1; Stop;
    V7_staff_T1_A:
        H089 A -1; Stop;
    V7_staff_T2_A:
        H08A A -1; Stop;
    V7_staff_T3_A:
        H08B A -1; Stop;
    V7_statuette_T1_A:
        H08C A -1; Stop;
    V7_statuette_T2_A:
        H08D A -1; Stop;
    V7_statuette_T3_A:
        H08E A -1; Stop;
    V7_bell_T1_A:
        H08F A -1; Stop;
    V7_bell_T2_A:
        H08G A -1; Stop;
    V7_bell_T3_A:
        H08H A -1; Stop;
    V7_book_T1_A:
        H08I A -1; Stop;
    V7_book_T2_A:
        H08J A -1; Stop;
    V7_book_T3_A:
        H08K A -1; Stop;
    V7_book_T1_B:
        H08L A -1; Stop;
    V7_book_T2_B:
        H08M A -1; Stop;
    V7_book_T3_B:
        H08N A -1; Stop;
    V8_Hand_0:
        H08O A -1; Stop;
    V8_Hand_3:
        H08P A -1; Stop;
    V8_Hand_4:
        H08Q A -1; Stop;
    V8_Hand_5:
        H08R A -1; Stop;
    V8_Hand_6:
        H08S A -1; Stop;
    V8_Hand_7:
        H08T A -1; Stop;
    V8_Hand_9:
        H08U A -1; Stop;
    V8_Hand_10:
        H08V A -1; Stop;
    V8_Hand_12:
        H08W A -1; Stop;
    V8_ShieldFrame_A:
        H08X A -1; Stop;
    V8_ShieldFrame_B:
        H08X B -1; Stop;
    V8_ShieldFrame_C:
        H08X C -1; Stop;
    V8_ShieldFrame_D:
        H08X D -1; Stop;
    V8_ShieldFrame_H:
        H08X H -1; Stop;
    V8_ShieldFrame_I:
        H08X I -1; Stop;
    V8_Shield_Idle:
        H08X AB 8; Loop;
    V8_Shield_Raise:
        H08X CD 3; Goto V8_Shield_Idle;
    V8_Shield_Lower:
        H08X D 3; H08X C -1; Stop;
    V8_Shield_Attack:
        H08X A 8; Goto V8_Shield_Idle;
    V8_Shield_Block:
        H08X H 3; Goto V8_Shield_Hold;
    V8_Shield_Hold:
        H08X I -1; Stop;
    V8_Bolas:
        H08Y A -1; Stop;
    V8_Shotgun_0:
        H08Z A -1; Stop;
    V8_Shotgun_1:
        H090 A -1; Stop;
    V8_Shotgun_2:
        H091 A -1; Stop;
    V8_Shotgun_3:
        H092 A -1; Stop;
    V8_Shotgun_4:
        H093 A -1; Stop;
    V8_Shotgun_5:
        H094 A -1; Stop;
    V8_Shotgun_6:
        H095 A -1; Stop;
    V8_javelin_T1_A:
        H096 A -1; Stop;
    V8_javelin_T2_A:
        H097 A -1; Stop;
    V8_javelin_T3_A:
        H098 A -1; Stop;
    V8_spear_T1_A:
        H099 A -1; Stop;
    V8_spear_T2_A:
        H09A A -1; Stop;
    V8_spear_T3_A:
        H09B A -1; Stop;
    V8_staff_T1_A:
        H09C A -1; Stop;
    V8_staff_T2_A:
        H09D A -1; Stop;
    V8_staff_T3_A:
        H09E A -1; Stop;
    V8_statuette_T1_A:
        H09F A -1; Stop;
    V8_statuette_T2_A:
        H09G A -1; Stop;
    V8_statuette_T3_A:
        H09H A -1; Stop;
    V8_bell_T1_A:
        H09I A -1; Stop;
    V8_bell_T2_A:
        H09J A -1; Stop;
    V8_bell_T3_A:
        H09K A -1; Stop;
    V8_book_T1_A:
        H09L A -1; Stop;
    V8_book_T2_A:
        H09M A -1; Stop;
    V8_book_T3_A:
        H09N A -1; Stop;
    V8_book_T1_B:
        H09O A -1; Stop;
    V8_book_T2_B:
        H09P A -1; Stop;
    V8_book_T3_B:
        H09Q A -1; Stop;
    V9_Hand_0:
        H09R A -1; Stop;
    V9_Hand_3:
        H09S A -1; Stop;
    V9_Hand_4:
        H09T A -1; Stop;
    V9_Hand_5:
        H09U A -1; Stop;
    V9_Hand_6:
        H09V A -1; Stop;
    V9_Hand_7:
        H09W A -1; Stop;
    V9_Hand_9:
        H09X A -1; Stop;
    V9_Hand_10:
        H09Y A -1; Stop;
    V9_Hand_12:
        H09Z A -1; Stop;
    V9_ShieldFrame_A:
        H0A0 A -1; Stop;
    V9_ShieldFrame_B:
        H0A0 B -1; Stop;
    V9_ShieldFrame_C:
        H0A0 C -1; Stop;
    V9_ShieldFrame_D:
        H0A0 D -1; Stop;
    V9_ShieldFrame_H:
        H0A0 H -1; Stop;
    V9_ShieldFrame_I:
        H0A0 I -1; Stop;
    V9_Shield_Idle:
        H0A0 AB 8; Loop;
    V9_Shield_Raise:
        H0A0 CD 3; Goto V9_Shield_Idle;
    V9_Shield_Lower:
        H0A0 D 3; H0A0 C -1; Stop;
    V9_Shield_Attack:
        H0A0 A 8; Goto V9_Shield_Idle;
    V9_Shield_Block:
        H0A0 H 3; Goto V9_Shield_Hold;
    V9_Shield_Hold:
        H0A0 I -1; Stop;
    V9_Bolas:
        H0A1 A -1; Stop;
    V9_Shotgun_0:
        H0A2 A -1; Stop;
    V9_Shotgun_1:
        H0A3 A -1; Stop;
    V9_Shotgun_2:
        H0A4 A -1; Stop;
    V9_Shotgun_3:
        H0A5 A -1; Stop;
    V9_Shotgun_4:
        H0A6 A -1; Stop;
    V9_Shotgun_5:
        H0A7 A -1; Stop;
    V9_Shotgun_6:
        H0A8 A -1; Stop;
    V9_javelin_T1_A:
        H0A9 A -1; Stop;
    V9_javelin_T2_A:
        H0AA A -1; Stop;
    V9_javelin_T3_A:
        H0AB A -1; Stop;
    V9_spear_T1_A:
        H0AC A -1; Stop;
    V9_spear_T2_A:
        H0AD A -1; Stop;
    V9_spear_T3_A:
        H0AE A -1; Stop;
    V9_staff_T1_A:
        H0AF A -1; Stop;
    V9_staff_T2_A:
        H0AG A -1; Stop;
    V9_staff_T3_A:
        H0AH A -1; Stop;
    V9_statuette_T1_A:
        H0AI A -1; Stop;
    V9_statuette_T2_A:
        H0AJ A -1; Stop;
    V9_statuette_T3_A:
        H0AK A -1; Stop;
    V9_bell_T1_A:
        H0AL A -1; Stop;
    V9_bell_T2_A:
        H0AM A -1; Stop;
    V9_bell_T3_A:
        H0AN A -1; Stop;
    V9_book_T1_A:
        H0AO A -1; Stop;
    V9_book_T2_A:
        H0AP A -1; Stop;
    V9_book_T3_A:
        H0AQ A -1; Stop;
    V9_book_T1_B:
        H0AR A -1; Stop;
    V9_book_T2_B:
        H0AS A -1; Stop;
    V9_book_T3_B:
        H0AT A -1; Stop;
    V10_Hand_0:
        H0AU A -1; Stop;
    V10_Hand_3:
        H0AV A -1; Stop;
    V10_Hand_4:
        H0AW A -1; Stop;
    V10_Hand_5:
        H0AX A -1; Stop;
    V10_Hand_6:
        H0AY A -1; Stop;
    V10_Hand_7:
        H0AZ A -1; Stop;
    V10_Hand_9:
        H0B0 A -1; Stop;
    V10_Hand_10:
        H0B1 A -1; Stop;
    V10_Hand_12:
        H0B2 A -1; Stop;
    V10_ShieldFrame_A:
        H0B3 A -1; Stop;
    V10_ShieldFrame_B:
        H0B3 B -1; Stop;
    V10_ShieldFrame_C:
        H0B3 C -1; Stop;
    V10_ShieldFrame_D:
        H0B3 D -1; Stop;
    V10_ShieldFrame_H:
        H0B3 H -1; Stop;
    V10_ShieldFrame_I:
        H0B3 I -1; Stop;
    V10_Shield_Idle:
        H0B3 AB 8; Loop;
    V10_Shield_Raise:
        H0B3 CD 3; Goto V10_Shield_Idle;
    V10_Shield_Lower:
        H0B3 D 3; H0B3 C -1; Stop;
    V10_Shield_Attack:
        H0B3 A 8; Goto V10_Shield_Idle;
    V10_Shield_Block:
        H0B3 H 3; Goto V10_Shield_Hold;
    V10_Shield_Hold:
        H0B3 I -1; Stop;
    V10_Bolas:
        H0B4 A -1; Stop;
    V10_Shotgun_0:
        H0B5 A -1; Stop;
    V10_Shotgun_1:
        H0B6 A -1; Stop;
    V10_Shotgun_2:
        H0B7 A -1; Stop;
    V10_Shotgun_3:
        H0B8 A -1; Stop;
    V10_Shotgun_4:
        H0B9 A -1; Stop;
    V10_Shotgun_5:
        H0BA A -1; Stop;
    V10_Shotgun_6:
        H0BB A -1; Stop;
    V10_javelin_T1_A:
        H0BC A -1; Stop;
    V10_javelin_T2_A:
        H0BD A -1; Stop;
    V10_javelin_T3_A:
        H0BE A -1; Stop;
    V10_spear_T1_A:
        H0BF A -1; Stop;
    V10_spear_T2_A:
        H0BG A -1; Stop;
    V10_spear_T3_A:
        H0BH A -1; Stop;
    V10_staff_T1_A:
        H0BI A -1; Stop;
    V10_staff_T2_A:
        H0BJ A -1; Stop;
    V10_staff_T3_A:
        H0BK A -1; Stop;
    V10_statuette_T1_A:
        H0BL A -1; Stop;
    V10_statuette_T2_A:
        H0BM A -1; Stop;
    V10_statuette_T3_A:
        H0BN A -1; Stop;
    V10_bell_T1_A:
        H0BO A -1; Stop;
    V10_bell_T2_A:
        H0BP A -1; Stop;
    V10_bell_T3_A:
        H0BQ A -1; Stop;
    V10_book_T1_A:
        H0BR A -1; Stop;
    V10_book_T2_A:
        H0BS A -1; Stop;
    V10_book_T3_A:
        H0BT A -1; Stop;
    V10_book_T1_B:
        H0BU A -1; Stop;
    V10_book_T2_B:
        H0BV A -1; Stop;
    V10_book_T3_B:
        H0BW A -1; Stop;
    V11_Hand_0:
        H0BX A -1; Stop;
    V11_Hand_3:
        H0BY A -1; Stop;
    V11_Hand_4:
        H0BZ A -1; Stop;
    V11_Hand_5:
        H0C0 A -1; Stop;
    V11_Hand_6:
        H0C1 A -1; Stop;
    V11_Hand_7:
        H0C2 A -1; Stop;
    V11_Hand_9:
        H0C3 A -1; Stop;
    V11_Hand_10:
        H0C4 A -1; Stop;
    V11_Hand_12:
        H0C5 A -1; Stop;
    V11_ShieldFrame_A:
        H0C6 A -1; Stop;
    V11_ShieldFrame_B:
        H0C6 B -1; Stop;
    V11_ShieldFrame_C:
        H0C6 C -1; Stop;
    V11_ShieldFrame_D:
        H0C6 D -1; Stop;
    V11_ShieldFrame_H:
        H0C6 H -1; Stop;
    V11_ShieldFrame_I:
        H0C6 I -1; Stop;
    V11_Shield_Idle:
        H0C6 AB 8; Loop;
    V11_Shield_Raise:
        H0C6 CD 3; Goto V11_Shield_Idle;
    V11_Shield_Lower:
        H0C6 D 3; H0C6 C -1; Stop;
    V11_Shield_Attack:
        H0C6 A 8; Goto V11_Shield_Idle;
    V11_Shield_Block:
        H0C6 H 3; Goto V11_Shield_Hold;
    V11_Shield_Hold:
        H0C6 I -1; Stop;
    V11_Bolas:
        H0C7 A -1; Stop;
    V11_Shotgun_0:
        H0C8 A -1; Stop;
    V11_Shotgun_1:
        H0C9 A -1; Stop;
    V11_Shotgun_2:
        H0CA A -1; Stop;
    V11_Shotgun_3:
        H0CB A -1; Stop;
    V11_Shotgun_4:
        H0CC A -1; Stop;
    V11_Shotgun_5:
        H0CD A -1; Stop;
    V11_Shotgun_6:
        H0CE A -1; Stop;
    V11_javelin_T1_A:
        H0CF A -1; Stop;
    V11_javelin_T2_A:
        H0CG A -1; Stop;
    V11_javelin_T3_A:
        H0CH A -1; Stop;
    V11_spear_T1_A:
        H0CI A -1; Stop;
    V11_spear_T2_A:
        H0CJ A -1; Stop;
    V11_spear_T3_A:
        H0CK A -1; Stop;
    V11_staff_T1_A:
        H0CL A -1; Stop;
    V11_staff_T2_A:
        H0CM A -1; Stop;
    V11_staff_T3_A:
        H0CN A -1; Stop;
    V11_statuette_T1_A:
        H0CO A -1; Stop;
    V11_statuette_T2_A:
        H0CP A -1; Stop;
    V11_statuette_T3_A:
        H0CQ A -1; Stop;
    V11_bell_T1_A:
        H0CR A -1; Stop;
    V11_bell_T2_A:
        H0CS A -1; Stop;
    V11_bell_T3_A:
        H0CT A -1; Stop;
    V11_book_T1_A:
        H0CU A -1; Stop;
    V11_book_T2_A:
        H0CV A -1; Stop;
    V11_book_T3_A:
        H0CW A -1; Stop;
    V11_book_T1_B:
        H0CX A -1; Stop;
    V11_book_T2_B:
        H0CY A -1; Stop;
    V11_book_T3_B:
        H0CZ A -1; Stop;
    V12_Hand_0:
        H0D0 A -1; Stop;
    V12_Hand_3:
        H0D1 A -1; Stop;
    V12_Hand_4:
        H0D2 A -1; Stop;
    V12_Hand_5:
        H0D3 A -1; Stop;
    V12_Hand_6:
        H0D4 A -1; Stop;
    V12_Hand_7:
        H0D5 A -1; Stop;
    V12_Hand_9:
        H0D6 A -1; Stop;
    V12_Hand_10:
        H0D7 A -1; Stop;
    V12_Hand_12:
        H0D8 A -1; Stop;
    V12_ShieldFrame_A:
        H0D9 A -1; Stop;
    V12_ShieldFrame_B:
        H0D9 B -1; Stop;
    V12_ShieldFrame_C:
        H0D9 C -1; Stop;
    V12_ShieldFrame_D:
        H0D9 D -1; Stop;
    V12_ShieldFrame_H:
        H0D9 H -1; Stop;
    V12_ShieldFrame_I:
        H0D9 I -1; Stop;
    V12_Shield_Idle:
        H0D9 AB 8; Loop;
    V12_Shield_Raise:
        H0D9 CD 3; Goto V12_Shield_Idle;
    V12_Shield_Lower:
        H0D9 D 3; H0D9 C -1; Stop;
    V12_Shield_Attack:
        H0D9 A 8; Goto V12_Shield_Idle;
    V12_Shield_Block:
        H0D9 H 3; Goto V12_Shield_Hold;
    V12_Shield_Hold:
        H0D9 I -1; Stop;
    V12_Bolas:
        H0DA A -1; Stop;
    V12_Shotgun_0:
        H0DB A -1; Stop;
    V12_Shotgun_1:
        H0DC A -1; Stop;
    V12_Shotgun_2:
        H0DD A -1; Stop;
    V12_Shotgun_3:
        H0DE A -1; Stop;
    V12_Shotgun_4:
        H0DF A -1; Stop;
    V12_Shotgun_5:
        H0DG A -1; Stop;
    V12_Shotgun_6:
        H0DH A -1; Stop;
    V12_javelin_T1_A:
        H0DI A -1; Stop;
    V12_javelin_T2_A:
        H0DJ A -1; Stop;
    V12_javelin_T3_A:
        H0DK A -1; Stop;
    V12_spear_T1_A:
        H0DL A -1; Stop;
    V12_spear_T2_A:
        H0DM A -1; Stop;
    V12_spear_T3_A:
        H0DN A -1; Stop;
    V12_staff_T1_A:
        H0DO A -1; Stop;
    V12_staff_T2_A:
        H0DP A -1; Stop;
    V12_staff_T3_A:
        H0DQ A -1; Stop;
    V12_statuette_T1_A:
        H0DR A -1; Stop;
    V12_statuette_T2_A:
        H0DS A -1; Stop;
    V12_statuette_T3_A:
        H0DT A -1; Stop;
    V12_bell_T1_A:
        H0DU A -1; Stop;
    V12_bell_T2_A:
        H0DV A -1; Stop;
    V12_bell_T3_A:
        H0DW A -1; Stop;
    V12_book_T1_A:
        H0DX A -1; Stop;
    V12_book_T2_A:
        H0DY A -1; Stop;
    V12_book_T3_A:
        H0DZ A -1; Stop;
    V12_book_T1_B:
        H0E0 A -1; Stop;
    V12_book_T2_B:
        H0E1 A -1; Stop;
    V12_book_T3_B:
        H0E2 A -1; Stop;
    V13_Hand_0:
        H0E3 A -1; Stop;
    V13_Hand_3:
        H0E4 A -1; Stop;
    V13_Hand_4:
        H0E5 A -1; Stop;
    V13_Hand_5:
        H0E6 A -1; Stop;
    V13_Hand_6:
        H0E7 A -1; Stop;
    V13_Hand_7:
        H0E8 A -1; Stop;
    V13_Hand_9:
        H0E9 A -1; Stop;
    V13_Hand_10:
        H0EA A -1; Stop;
    V13_Hand_12:
        H0EB A -1; Stop;
    V13_ShieldFrame_A:
        H0EC A -1; Stop;
    V13_ShieldFrame_B:
        H0EC B -1; Stop;
    V13_ShieldFrame_C:
        H0EC C -1; Stop;
    V13_ShieldFrame_D:
        H0EC D -1; Stop;
    V13_ShieldFrame_H:
        H0EC H -1; Stop;
    V13_ShieldFrame_I:
        H0EC I -1; Stop;
    V13_Shield_Idle:
        H0EC AB 8; Loop;
    V13_Shield_Raise:
        H0EC CD 3; Goto V13_Shield_Idle;
    V13_Shield_Lower:
        H0EC D 3; H0EC C -1; Stop;
    V13_Shield_Attack:
        H0EC A 8; Goto V13_Shield_Idle;
    V13_Shield_Block:
        H0EC H 3; Goto V13_Shield_Hold;
    V13_Shield_Hold:
        H0EC I -1; Stop;
    V13_Bolas:
        H0ED A -1; Stop;
    V13_Shotgun_0:
        H0EE A -1; Stop;
    V13_Shotgun_1:
        H0EF A -1; Stop;
    V13_Shotgun_2:
        H0EG A -1; Stop;
    V13_Shotgun_3:
        H0EH A -1; Stop;
    V13_Shotgun_4:
        H0EI A -1; Stop;
    V13_Shotgun_5:
        H0EJ A -1; Stop;
    V13_Shotgun_6:
        H0EK A -1; Stop;
    V13_javelin_T1_A:
        H0EL A -1; Stop;
    V13_javelin_T2_A:
        H0EM A -1; Stop;
    V13_javelin_T3_A:
        H0EN A -1; Stop;
    V13_spear_T1_A:
        H0EO A -1; Stop;
    V13_spear_T2_A:
        H0EP A -1; Stop;
    V13_spear_T3_A:
        H0EQ A -1; Stop;
    V13_staff_T1_A:
        H0ER A -1; Stop;
    V13_staff_T2_A:
        H0ES A -1; Stop;
    V13_staff_T3_A:
        H0ET A -1; Stop;
    V13_statuette_T1_A:
        H0EU A -1; Stop;
    V13_statuette_T2_A:
        H0EV A -1; Stop;
    V13_statuette_T3_A:
        H0EW A -1; Stop;
    V13_bell_T1_A:
        H0EX A -1; Stop;
    V13_bell_T2_A:
        H0EY A -1; Stop;
    V13_bell_T3_A:
        H0EZ A -1; Stop;
    V13_book_T1_A:
        H0F0 A -1; Stop;
    V13_book_T2_A:
        H0F1 A -1; Stop;
    V13_book_T3_A:
        H0F2 A -1; Stop;
    V13_book_T1_B:
        H0F3 A -1; Stop;
    V13_book_T2_B:
        H0F4 A -1; Stop;
    V13_book_T3_B:
        H0F5 A -1; Stop;
    V14_Hand_0:
        H0F6 A -1; Stop;
    V14_Hand_3:
        H0F7 A -1; Stop;
    V14_Hand_4:
        H0F8 A -1; Stop;
    V14_Hand_5:
        H0F9 A -1; Stop;
    V14_Hand_6:
        H0FA A -1; Stop;
    V14_Hand_7:
        H0FB A -1; Stop;
    V14_Hand_9:
        H0FC A -1; Stop;
    V14_Hand_10:
        H0FD A -1; Stop;
    V14_Hand_12:
        H0FE A -1; Stop;
    V14_ShieldFrame_A:
        H0FF A -1; Stop;
    V14_ShieldFrame_B:
        H0FF B -1; Stop;
    V14_ShieldFrame_C:
        H0FF C -1; Stop;
    V14_ShieldFrame_D:
        H0FF D -1; Stop;
    V14_ShieldFrame_H:
        H0FF H -1; Stop;
    V14_ShieldFrame_I:
        H0FF I -1; Stop;
    V14_Shield_Idle:
        H0FF AB 8; Loop;
    V14_Shield_Raise:
        H0FF CD 3; Goto V14_Shield_Idle;
    V14_Shield_Lower:
        H0FF D 3; H0FF C -1; Stop;
    V14_Shield_Attack:
        H0FF A 8; Goto V14_Shield_Idle;
    V14_Shield_Block:
        H0FF H 3; Goto V14_Shield_Hold;
    V14_Shield_Hold:
        H0FF I -1; Stop;
    V14_Bolas:
        H0FG A -1; Stop;
    V14_Shotgun_0:
        H0FH A -1; Stop;
    V14_Shotgun_1:
        H0FI A -1; Stop;
    V14_Shotgun_2:
        H0FJ A -1; Stop;
    V14_Shotgun_3:
        H0FK A -1; Stop;
    V14_Shotgun_4:
        H0FL A -1; Stop;
    V14_Shotgun_5:
        H0FM A -1; Stop;
    V14_Shotgun_6:
        H0FN A -1; Stop;
    V14_javelin_T1_A:
        H0FO A -1; Stop;
    V14_javelin_T2_A:
        H0FP A -1; Stop;
    V14_javelin_T3_A:
        H0FQ A -1; Stop;
    V14_spear_T1_A:
        H0FR A -1; Stop;
    V14_spear_T2_A:
        H0FS A -1; Stop;
    V14_spear_T3_A:
        H0FT A -1; Stop;
    V14_staff_T1_A:
        H0FU A -1; Stop;
    V14_staff_T2_A:
        H0FV A -1; Stop;
    V14_staff_T3_A:
        H0FW A -1; Stop;
    V14_statuette_T1_A:
        H0FX A -1; Stop;
    V14_statuette_T2_A:
        H0FY A -1; Stop;
    V14_statuette_T3_A:
        H0FZ A -1; Stop;
    V14_bell_T1_A:
        H0G0 A -1; Stop;
    V14_bell_T2_A:
        H0G1 A -1; Stop;
    V14_bell_T3_A:
        H0G2 A -1; Stop;
    V14_book_T1_A:
        H0G3 A -1; Stop;
    V14_book_T2_A:
        H0G4 A -1; Stop;
    V14_book_T3_A:
        H0G5 A -1; Stop;
    V14_book_T1_B:
        H0G6 A -1; Stop;
    V14_book_T2_B:
        H0G7 A -1; Stop;
    V14_book_T3_B:
        H0G8 A -1; Stop;
    V15_Hand_0:
        H0G9 A -1; Stop;
    V15_Hand_3:
        H0GA A -1; Stop;
    V15_Hand_4:
        H0GB A -1; Stop;
    V15_Hand_5:
        H0GC A -1; Stop;
    V15_Hand_6:
        H0GD A -1; Stop;
    V15_Hand_7:
        H0GE A -1; Stop;
    V15_Hand_9:
        H0GF A -1; Stop;
    V15_Hand_10:
        H0GG A -1; Stop;
    V15_Hand_12:
        H0GH A -1; Stop;
    V15_ShieldFrame_A:
        H0GI A -1; Stop;
    V15_ShieldFrame_B:
        H0GI B -1; Stop;
    V15_ShieldFrame_C:
        H0GI C -1; Stop;
    V15_ShieldFrame_D:
        H0GI D -1; Stop;
    V15_ShieldFrame_H:
        H0GI H -1; Stop;
    V15_ShieldFrame_I:
        H0GI I -1; Stop;
    V15_Shield_Idle:
        H0GI AB 8; Loop;
    V15_Shield_Raise:
        H0GI CD 3; Goto V15_Shield_Idle;
    V15_Shield_Lower:
        H0GI D 3; H0GI C -1; Stop;
    V15_Shield_Attack:
        H0GI A 8; Goto V15_Shield_Idle;
    V15_Shield_Block:
        H0GI H 3; Goto V15_Shield_Hold;
    V15_Shield_Hold:
        H0GI I -1; Stop;
    V15_Bolas:
        H0GJ A -1; Stop;
    V15_Shotgun_0:
        H0GK A -1; Stop;
    V15_Shotgun_1:
        H0GL A -1; Stop;
    V15_Shotgun_2:
        H0GM A -1; Stop;
    V15_Shotgun_3:
        H0GN A -1; Stop;
    V15_Shotgun_4:
        H0GO A -1; Stop;
    V15_Shotgun_5:
        H0GP A -1; Stop;
    V15_Shotgun_6:
        H0GQ A -1; Stop;
    V15_javelin_T1_A:
        H0GR A -1; Stop;
    V15_javelin_T2_A:
        H0GS A -1; Stop;
    V15_javelin_T3_A:
        H0GT A -1; Stop;
    V15_spear_T1_A:
        H0GU A -1; Stop;
    V15_spear_T2_A:
        H0GV A -1; Stop;
    V15_spear_T3_A:
        H0GW A -1; Stop;
    V15_staff_T1_A:
        H0GX A -1; Stop;
    V15_staff_T2_A:
        H0GY A -1; Stop;
    V15_staff_T3_A:
        H0GZ A -1; Stop;
    V15_statuette_T1_A:
        H0H0 A -1; Stop;
    V15_statuette_T2_A:
        H0H1 A -1; Stop;
    V15_statuette_T3_A:
        H0H2 A -1; Stop;
    V15_bell_T1_A:
        H0H3 A -1; Stop;
    V15_bell_T2_A:
        H0H4 A -1; Stop;
    V15_bell_T3_A:
        H0H5 A -1; Stop;
    V15_book_T1_A:
        H0H6 A -1; Stop;
    V15_book_T2_A:
        H0H7 A -1; Stop;
    V15_book_T3_A:
        H0H8 A -1; Stop;
    V15_book_T1_B:
        H0H9 A -1; Stop;
    V15_book_T2_B:
        H0HA A -1; Stop;
    V15_book_T3_B:
        H0HB A -1; Stop;
    V16_Hand_0:
        H0HC A -1; Stop;
    V16_Hand_3:
        H0HD A -1; Stop;
    V16_Hand_4:
        H0HE A -1; Stop;
    V16_Hand_5:
        H0HF A -1; Stop;
    V16_Hand_6:
        H0HG A -1; Stop;
    V16_Hand_7:
        H0HH A -1; Stop;
    V16_Hand_9:
        H0HI A -1; Stop;
    V16_Hand_10:
        H0HJ A -1; Stop;
    V16_Hand_12:
        H0HK A -1; Stop;
    V16_ShieldFrame_A:
        H0HL A -1; Stop;
    V16_ShieldFrame_B:
        H0HL B -1; Stop;
    V16_ShieldFrame_C:
        H0HL C -1; Stop;
    V16_ShieldFrame_D:
        H0HL D -1; Stop;
    V16_ShieldFrame_H:
        H0HL H -1; Stop;
    V16_ShieldFrame_I:
        H0HL I -1; Stop;
    V16_Shield_Idle:
        H0HL AB 8; Loop;
    V16_Shield_Raise:
        H0HL CD 3; Goto V16_Shield_Idle;
    V16_Shield_Lower:
        H0HL D 3; H0HL C -1; Stop;
    V16_Shield_Attack:
        H0HL A 8; Goto V16_Shield_Idle;
    V16_Shield_Block:
        H0HL H 3; Goto V16_Shield_Hold;
    V16_Shield_Hold:
        H0HL I -1; Stop;
    V16_Bolas:
        H0HM A -1; Stop;
    V16_Shotgun_0:
        H0HN A -1; Stop;
    V16_Shotgun_1:
        H0HO A -1; Stop;
    V16_Shotgun_2:
        H0HP A -1; Stop;
    V16_Shotgun_3:
        H0HQ A -1; Stop;
    V16_Shotgun_4:
        H0HR A -1; Stop;
    V16_Shotgun_5:
        H0HS A -1; Stop;
    V16_Shotgun_6:
        H0HT A -1; Stop;
    V16_javelin_T1_A:
        H0HU A -1; Stop;
    V16_javelin_T2_A:
        H0HV A -1; Stop;
    V16_javelin_T3_A:
        H0HW A -1; Stop;
    V16_spear_T1_A:
        H0HX A -1; Stop;
    V16_spear_T2_A:
        H0HY A -1; Stop;
    V16_spear_T3_A:
        H0HZ A -1; Stop;
    V16_staff_T1_A:
        H0I0 A -1; Stop;
    V16_staff_T2_A:
        H0I1 A -1; Stop;
    V16_staff_T3_A:
        H0I2 A -1; Stop;
    V16_statuette_T1_A:
        H0I3 A -1; Stop;
    V16_statuette_T2_A:
        H0I4 A -1; Stop;
    V16_statuette_T3_A:
        H0I5 A -1; Stop;
    V16_bell_T1_A:
        H0I6 A -1; Stop;
    V16_bell_T2_A:
        H0I7 A -1; Stop;
    V16_bell_T3_A:
        H0I8 A -1; Stop;
    V16_book_T1_A:
        H0I9 A -1; Stop;
    V16_book_T2_A:
        H0IA A -1; Stop;
    V16_book_T3_A:
        H0IB A -1; Stop;
    V16_book_T1_B:
        H0IC A -1; Stop;
    V16_book_T2_B:
        H0ID A -1; Stop;
    V16_book_T3_B:
        H0IE A -1; Stop;
    V17_Hand_0:
        H0IF A -1; Stop;
    V17_Hand_3:
        H0IG A -1; Stop;
    V17_Hand_4:
        H0IH A -1; Stop;
    V17_Hand_5:
        H0II A -1; Stop;
    V17_Hand_6:
        H0IJ A -1; Stop;
    V17_Hand_7:
        H0IK A -1; Stop;
    V17_Hand_9:
        H0IL A -1; Stop;
    V17_Hand_10:
        H0IM A -1; Stop;
    V17_Hand_12:
        H0IN A -1; Stop;
    V17_ShieldFrame_A:
        H0IO A -1; Stop;
    V17_ShieldFrame_B:
        H0IO B -1; Stop;
    V17_ShieldFrame_C:
        H0IO C -1; Stop;
    V17_ShieldFrame_D:
        H0IO D -1; Stop;
    V17_ShieldFrame_H:
        H0IO H -1; Stop;
    V17_ShieldFrame_I:
        H0IO I -1; Stop;
    V17_Shield_Idle:
        H0IO AB 8; Loop;
    V17_Shield_Raise:
        H0IO CD 3; Goto V17_Shield_Idle;
    V17_Shield_Lower:
        H0IO D 3; H0IO C -1; Stop;
    V17_Shield_Attack:
        H0IO A 8; Goto V17_Shield_Idle;
    V17_Shield_Block:
        H0IO H 3; Goto V17_Shield_Hold;
    V17_Shield_Hold:
        H0IO I -1; Stop;
    V17_Bolas:
        H0IP A -1; Stop;
    V17_Shotgun_0:
        H0IQ A -1; Stop;
    V17_Shotgun_1:
        H0IR A -1; Stop;
    V17_Shotgun_2:
        H0IS A -1; Stop;
    V17_Shotgun_3:
        H0IT A -1; Stop;
    V17_Shotgun_4:
        H0IU A -1; Stop;
    V17_Shotgun_5:
        H0IV A -1; Stop;
    V17_Shotgun_6:
        H0IW A -1; Stop;
    V17_javelin_T1_A:
        H0IX A -1; Stop;
    V17_javelin_T2_A:
        H0IY A -1; Stop;
    V17_javelin_T3_A:
        H0IZ A -1; Stop;
    V17_spear_T1_A:
        H0J0 A -1; Stop;
    V17_spear_T2_A:
        H0J1 A -1; Stop;
    V17_spear_T3_A:
        H0J2 A -1; Stop;
    V17_staff_T1_A:
        H0J3 A -1; Stop;
    V17_staff_T2_A:
        H0J4 A -1; Stop;
    V17_staff_T3_A:
        H0J5 A -1; Stop;
    V17_statuette_T1_A:
        H0J6 A -1; Stop;
    V17_statuette_T2_A:
        H0J7 A -1; Stop;
    V17_statuette_T3_A:
        H0J8 A -1; Stop;
    V17_bell_T1_A:
        H0J9 A -1; Stop;
    V17_bell_T2_A:
        H0JA A -1; Stop;
    V17_bell_T3_A:
        H0JB A -1; Stop;
    V17_book_T1_A:
        H0JC A -1; Stop;
    V17_book_T2_A:
        H0JD A -1; Stop;
    V17_book_T3_A:
        H0JE A -1; Stop;
    V17_book_T1_B:
        H0JF A -1; Stop;
    V17_book_T2_B:
        H0JG A -1; Stop;
    V17_book_T3_B:
        H0JH A -1; Stop;
    V18_Hand_0:
        H0JI A -1; Stop;
    V18_Hand_3:
        H0JJ A -1; Stop;
    V18_Hand_4:
        H0JK A -1; Stop;
    V18_Hand_5:
        H0JL A -1; Stop;
    V18_Hand_6:
        H0JM A -1; Stop;
    V18_Hand_7:
        H0JN A -1; Stop;
    V18_Hand_9:
        H0JO A -1; Stop;
    V18_Hand_10:
        H0JP A -1; Stop;
    V18_Hand_12:
        H0JQ A -1; Stop;
    V18_ShieldFrame_A:
        H0JR A -1; Stop;
    V18_ShieldFrame_B:
        H0JR B -1; Stop;
    V18_ShieldFrame_C:
        H0JR C -1; Stop;
    V18_ShieldFrame_D:
        H0JR D -1; Stop;
    V18_ShieldFrame_H:
        H0JR H -1; Stop;
    V18_ShieldFrame_I:
        H0JR I -1; Stop;
    V18_Shield_Idle:
        H0JR AB 8; Loop;
    V18_Shield_Raise:
        H0JR CD 3; Goto V18_Shield_Idle;
    V18_Shield_Lower:
        H0JR D 3; H0JR C -1; Stop;
    V18_Shield_Attack:
        H0JR A 8; Goto V18_Shield_Idle;
    V18_Shield_Block:
        H0JR H 3; Goto V18_Shield_Hold;
    V18_Shield_Hold:
        H0JR I -1; Stop;
    V18_Bolas:
        H0JS A -1; Stop;
    V18_Shotgun_0:
        H0JT A -1; Stop;
    V18_Shotgun_1:
        H0JU A -1; Stop;
    V18_Shotgun_2:
        H0JV A -1; Stop;
    V18_Shotgun_3:
        H0JW A -1; Stop;
    V18_Shotgun_4:
        H0JX A -1; Stop;
    V18_Shotgun_5:
        H0JY A -1; Stop;
    V18_Shotgun_6:
        H0JZ A -1; Stop;
    V18_javelin_T1_A:
        H0K0 A -1; Stop;
    V18_javelin_T2_A:
        H0K1 A -1; Stop;
    V18_javelin_T3_A:
        H0K2 A -1; Stop;
    V18_spear_T1_A:
        H0K3 A -1; Stop;
    V18_spear_T2_A:
        H0K4 A -1; Stop;
    V18_spear_T3_A:
        H0K5 A -1; Stop;
    V18_staff_T1_A:
        H0K6 A -1; Stop;
    V18_staff_T2_A:
        H0K7 A -1; Stop;
    V18_staff_T3_A:
        H0K8 A -1; Stop;
    V18_statuette_T1_A:
        H0K9 A -1; Stop;
    V18_statuette_T2_A:
        H0KA A -1; Stop;
    V18_statuette_T3_A:
        H0KB A -1; Stop;
    V18_bell_T1_A:
        H0KC A -1; Stop;
    V18_bell_T2_A:
        H0KD A -1; Stop;
    V18_bell_T3_A:
        H0KE A -1; Stop;
    V18_book_T1_A:
        H0KF A -1; Stop;
    V18_book_T2_A:
        H0KG A -1; Stop;
    V18_book_T3_A:
        H0KH A -1; Stop;
    V18_book_T1_B:
        H0KI A -1; Stop;
    V18_book_T2_B:
        H0KJ A -1; Stop;
    V18_book_T3_B:
        H0KK A -1; Stop;
    V19_Hand_0:
        H0KL A -1; Stop;
    V19_Hand_3:
        H0KM A -1; Stop;
    V19_Hand_4:
        H0KN A -1; Stop;
    V19_Hand_5:
        H0KO A -1; Stop;
    V19_Hand_6:
        H0KP A -1; Stop;
    V19_Hand_7:
        H0KQ A -1; Stop;
    V19_Hand_9:
        H0KR A -1; Stop;
    V19_Hand_10:
        H0KS A -1; Stop;
    V19_Hand_12:
        H0KT A -1; Stop;
    V19_ShieldFrame_A:
        H0KU A -1; Stop;
    V19_ShieldFrame_B:
        H0KU B -1; Stop;
    V19_ShieldFrame_C:
        H0KU C -1; Stop;
    V19_ShieldFrame_D:
        H0KU D -1; Stop;
    V19_ShieldFrame_H:
        H0KU H -1; Stop;
    V19_ShieldFrame_I:
        H0KU I -1; Stop;
    V19_Shield_Idle:
        H0KU AB 8; Loop;
    V19_Shield_Raise:
        H0KU CD 3; Goto V19_Shield_Idle;
    V19_Shield_Lower:
        H0KU D 3; H0KU C -1; Stop;
    V19_Shield_Attack:
        H0KU A 8; Goto V19_Shield_Idle;
    V19_Shield_Block:
        H0KU H 3; Goto V19_Shield_Hold;
    V19_Shield_Hold:
        H0KU I -1; Stop;
    V19_Bolas:
        H0KV A -1; Stop;
    V19_Shotgun_0:
        H0KW A -1; Stop;
    V19_Shotgun_1:
        H0KX A -1; Stop;
    V19_Shotgun_2:
        H0KY A -1; Stop;
    V19_Shotgun_3:
        H0KZ A -1; Stop;
    V19_Shotgun_4:
        H0L0 A -1; Stop;
    V19_Shotgun_5:
        H0L1 A -1; Stop;
    V19_Shotgun_6:
        H0L2 A -1; Stop;
    V19_javelin_T1_A:
        H0L3 A -1; Stop;
    V19_javelin_T2_A:
        H0L4 A -1; Stop;
    V19_javelin_T3_A:
        H0L5 A -1; Stop;
    V19_spear_T1_A:
        H0L6 A -1; Stop;
    V19_spear_T2_A:
        H0L7 A -1; Stop;
    V19_spear_T3_A:
        H0L8 A -1; Stop;
    V19_staff_T1_A:
        H0L9 A -1; Stop;
    V19_staff_T2_A:
        H0LA A -1; Stop;
    V19_staff_T3_A:
        H0LB A -1; Stop;
    V19_statuette_T1_A:
        H0LC A -1; Stop;
    V19_statuette_T2_A:
        H0LD A -1; Stop;
    V19_statuette_T3_A:
        H0LE A -1; Stop;
    V19_bell_T1_A:
        H0LF A -1; Stop;
    V19_bell_T2_A:
        H0LG A -1; Stop;
    V19_bell_T3_A:
        H0LH A -1; Stop;
    V19_book_T1_A:
        H0LI A -1; Stop;
    V19_book_T2_A:
        H0LJ A -1; Stop;
    V19_book_T3_A:
        H0LK A -1; Stop;
    V19_book_T1_B:
        H0LL A -1; Stop;
    V19_book_T2_B:
        H0LM A -1; Stop;
    V19_book_T3_B:
        H0LN A -1; Stop;
    V20_Hand_0:
        H0LO A -1; Stop;
    V20_Hand_3:
        H0LP A -1; Stop;
    V20_Hand_4:
        H0LQ A -1; Stop;
    V20_Hand_5:
        H0LR A -1; Stop;
    V20_Hand_6:
        H0LS A -1; Stop;
    V20_Hand_7:
        H0LT A -1; Stop;
    V20_Hand_9:
        H0LU A -1; Stop;
    V20_Hand_10:
        H0LV A -1; Stop;
    V20_Hand_12:
        H0LW A -1; Stop;
    V20_ShieldFrame_A:
        H0LX A -1; Stop;
    V20_ShieldFrame_B:
        H0LX B -1; Stop;
    V20_ShieldFrame_C:
        H0LX C -1; Stop;
    V20_ShieldFrame_D:
        H0LX D -1; Stop;
    V20_ShieldFrame_H:
        H0LX H -1; Stop;
    V20_ShieldFrame_I:
        H0LX I -1; Stop;
    V20_Shield_Idle:
        H0LX AB 8; Loop;
    V20_Shield_Raise:
        H0LX CD 3; Goto V20_Shield_Idle;
    V20_Shield_Lower:
        H0LX D 3; H0LX C -1; Stop;
    V20_Shield_Attack:
        H0LX A 8; Goto V20_Shield_Idle;
    V20_Shield_Block:
        H0LX H 3; Goto V20_Shield_Hold;
    V20_Shield_Hold:
        H0LX I -1; Stop;
    V20_Bolas:
        H0LY A -1; Stop;
    V20_Shotgun_0:
        H0LZ A -1; Stop;
    V20_Shotgun_1:
        H0M0 A -1; Stop;
    V20_Shotgun_2:
        H0M1 A -1; Stop;
    V20_Shotgun_3:
        H0M2 A -1; Stop;
    V20_Shotgun_4:
        H0M3 A -1; Stop;
    V20_Shotgun_5:
        H0M4 A -1; Stop;
    V20_Shotgun_6:
        H0M5 A -1; Stop;
    V20_javelin_T1_A:
        H0M6 A -1; Stop;
    V20_javelin_T2_A:
        H0M7 A -1; Stop;
    V20_javelin_T3_A:
        H0M8 A -1; Stop;
    V20_spear_T1_A:
        H0M9 A -1; Stop;
    V20_spear_T2_A:
        H0MA A -1; Stop;
    V20_spear_T3_A:
        H0MB A -1; Stop;
    V20_staff_T1_A:
        H0MC A -1; Stop;
    V20_staff_T2_A:
        H0MD A -1; Stop;
    V20_staff_T3_A:
        H0ME A -1; Stop;
    V20_statuette_T1_A:
        H0MF A -1; Stop;
    V20_statuette_T2_A:
        H0MG A -1; Stop;
    V20_statuette_T3_A:
        H0MH A -1; Stop;
    V20_bell_T1_A:
        H0MI A -1; Stop;
    V20_bell_T2_A:
        H0MJ A -1; Stop;
    V20_bell_T3_A:
        H0MK A -1; Stop;
    V20_book_T1_A:
        H0ML A -1; Stop;
    V20_book_T2_A:
        H0MM A -1; Stop;
    V20_book_T3_A:
        H0MN A -1; Stop;
    V20_book_T1_B:
        H0MO A -1; Stop;
    V20_book_T2_B:
        H0MP A -1; Stop;
    V20_book_T3_B:
        H0MQ A -1; Stop;
    V21_Hand_0:
        H0MR A -1; Stop;
    V21_Hand_3:
        H0MS A -1; Stop;
    V21_Hand_4:
        H0MT A -1; Stop;
    V21_Hand_5:
        H0MU A -1; Stop;
    V21_Hand_6:
        H0MV A -1; Stop;
    V21_Hand_7:
        H0MW A -1; Stop;
    V21_Hand_9:
        H0MX A -1; Stop;
    V21_Hand_10:
        H0MY A -1; Stop;
    V21_Hand_12:
        H0MZ A -1; Stop;
    V21_ShieldFrame_A:
        H0N0 A -1; Stop;
    V21_ShieldFrame_B:
        H0N0 B -1; Stop;
    V21_ShieldFrame_C:
        H0N0 C -1; Stop;
    V21_ShieldFrame_D:
        H0N0 D -1; Stop;
    V21_ShieldFrame_H:
        H0N0 H -1; Stop;
    V21_ShieldFrame_I:
        H0N0 I -1; Stop;
    V21_Shield_Idle:
        H0N0 AB 8; Loop;
    V21_Shield_Raise:
        H0N0 CD 3; Goto V21_Shield_Idle;
    V21_Shield_Lower:
        H0N0 D 3; H0N0 C -1; Stop;
    V21_Shield_Attack:
        H0N0 A 8; Goto V21_Shield_Idle;
    V21_Shield_Block:
        H0N0 H 3; Goto V21_Shield_Hold;
    V21_Shield_Hold:
        H0N0 I -1; Stop;
    V21_Bolas:
        H0N1 A -1; Stop;
    V21_Shotgun_0:
        H0N2 A -1; Stop;
    V21_Shotgun_1:
        H0N3 A -1; Stop;
    V21_Shotgun_2:
        H0N4 A -1; Stop;
    V21_Shotgun_3:
        H0N5 A -1; Stop;
    V21_Shotgun_4:
        H0N6 A -1; Stop;
    V21_Shotgun_5:
        H0N7 A -1; Stop;
    V21_Shotgun_6:
        H0N8 A -1; Stop;
    V21_javelin_T1_A:
        H0N9 A -1; Stop;
    V21_javelin_T2_A:
        H0NA A -1; Stop;
    V21_javelin_T3_A:
        H0NB A -1; Stop;
    V21_spear_T1_A:
        H0NC A -1; Stop;
    V21_spear_T2_A:
        H0ND A -1; Stop;
    V21_spear_T3_A:
        H0NE A -1; Stop;
    V21_staff_T1_A:
        H0NF A -1; Stop;
    V21_staff_T2_A:
        H0NG A -1; Stop;
    V21_staff_T3_A:
        H0NH A -1; Stop;
    V21_statuette_T1_A:
        H0NI A -1; Stop;
    V21_statuette_T2_A:
        H0NJ A -1; Stop;
    V21_statuette_T3_A:
        H0NK A -1; Stop;
    V21_bell_T1_A:
        H0NL A -1; Stop;
    V21_bell_T2_A:
        H0NM A -1; Stop;
    V21_bell_T3_A:
        H0NN A -1; Stop;
    V21_book_T1_A:
        H0NO A -1; Stop;
    V21_book_T2_A:
        H0NP A -1; Stop;
    V21_book_T3_A:
        H0NQ A -1; Stop;
    V21_book_T1_B:
        H0NR A -1; Stop;
    V21_book_T2_B:
        H0NS A -1; Stop;
    V21_book_T3_B:
        H0NT A -1; Stop;
    V22_Hand_0:
        H0NU A -1; Stop;
    V22_Hand_3:
        H0NV A -1; Stop;
    V22_Hand_4:
        H0NW A -1; Stop;
    V22_Hand_5:
        H0NX A -1; Stop;
    V22_Hand_6:
        H0NY A -1; Stop;
    V22_Hand_7:
        H0NZ A -1; Stop;
    V22_Hand_9:
        H0O0 A -1; Stop;
    V22_Hand_10:
        H0O1 A -1; Stop;
    V22_Hand_12:
        H0O2 A -1; Stop;
    V22_ShieldFrame_A:
        H0O3 A -1; Stop;
    V22_ShieldFrame_B:
        H0O3 B -1; Stop;
    V22_ShieldFrame_C:
        H0O3 C -1; Stop;
    V22_ShieldFrame_D:
        H0O3 D -1; Stop;
    V22_ShieldFrame_H:
        H0O3 H -1; Stop;
    V22_ShieldFrame_I:
        H0O3 I -1; Stop;
    V22_Shield_Idle:
        H0O3 AB 8; Loop;
    V22_Shield_Raise:
        H0O3 CD 3; Goto V22_Shield_Idle;
    V22_Shield_Lower:
        H0O3 D 3; H0O3 C -1; Stop;
    V22_Shield_Attack:
        H0O3 A 8; Goto V22_Shield_Idle;
    V22_Shield_Block:
        H0O3 H 3; Goto V22_Shield_Hold;
    V22_Shield_Hold:
        H0O3 I -1; Stop;
    V22_Bolas:
        H0O4 A -1; Stop;
    V22_Shotgun_0:
        H0O5 A -1; Stop;
    V22_Shotgun_1:
        H0O6 A -1; Stop;
    V22_Shotgun_2:
        H0O7 A -1; Stop;
    V22_Shotgun_3:
        H0O8 A -1; Stop;
    V22_Shotgun_4:
        H0O9 A -1; Stop;
    V22_Shotgun_5:
        H0OA A -1; Stop;
    V22_Shotgun_6:
        H0OB A -1; Stop;
    V22_javelin_T1_A:
        H0OC A -1; Stop;
    V22_javelin_T2_A:
        H0OD A -1; Stop;
    V22_javelin_T3_A:
        H0OE A -1; Stop;
    V22_spear_T1_A:
        H0OF A -1; Stop;
    V22_spear_T2_A:
        H0OG A -1; Stop;
    V22_spear_T3_A:
        H0OH A -1; Stop;
    V22_staff_T1_A:
        H0OI A -1; Stop;
    V22_staff_T2_A:
        H0OJ A -1; Stop;
    V22_staff_T3_A:
        H0OK A -1; Stop;
    V22_statuette_T1_A:
        H0OL A -1; Stop;
    V22_statuette_T2_A:
        H0OM A -1; Stop;
    V22_statuette_T3_A:
        H0ON A -1; Stop;
    V22_bell_T1_A:
        H0OO A -1; Stop;
    V22_bell_T2_A:
        H0OP A -1; Stop;
    V22_bell_T3_A:
        H0OQ A -1; Stop;
    V22_book_T1_A:
        H0OR A -1; Stop;
    V22_book_T2_A:
        H0OS A -1; Stop;
    V22_book_T3_A:
        H0OT A -1; Stop;
    V22_book_T1_B:
        H0OU A -1; Stop;
    V22_book_T2_B:
        H0OV A -1; Stop;
    V22_book_T3_B:
        H0OW A -1; Stop;
    V23_Hand_0:
        H0OX A -1; Stop;
    V23_Hand_3:
        H0OY A -1; Stop;
    V23_Hand_4:
        H0OZ A -1; Stop;
    V23_Hand_5:
        H0P0 A -1; Stop;
    V23_Hand_6:
        H0P1 A -1; Stop;
    V23_Hand_7:
        H0P2 A -1; Stop;
    V23_Hand_9:
        H0P3 A -1; Stop;
    V23_Hand_10:
        H0P4 A -1; Stop;
    V23_Hand_12:
        H0P5 A -1; Stop;
    V23_ShieldFrame_A:
        H0P6 A -1; Stop;
    V23_ShieldFrame_B:
        H0P6 B -1; Stop;
    V23_ShieldFrame_C:
        H0P6 C -1; Stop;
    V23_ShieldFrame_D:
        H0P6 D -1; Stop;
    V23_ShieldFrame_H:
        H0P6 H -1; Stop;
    V23_ShieldFrame_I:
        H0P6 I -1; Stop;
    V23_Shield_Idle:
        H0P6 AB 8; Loop;
    V23_Shield_Raise:
        H0P6 CD 3; Goto V23_Shield_Idle;
    V23_Shield_Lower:
        H0P6 D 3; H0P6 C -1; Stop;
    V23_Shield_Attack:
        H0P6 A 8; Goto V23_Shield_Idle;
    V23_Shield_Block:
        H0P6 H 3; Goto V23_Shield_Hold;
    V23_Shield_Hold:
        H0P6 I -1; Stop;
    V23_Bolas:
        H0P7 A -1; Stop;
    V23_Shotgun_0:
        H0P8 A -1; Stop;
    V23_Shotgun_1:
        H0P9 A -1; Stop;
    V23_Shotgun_2:
        H0PA A -1; Stop;
    V23_Shotgun_3:
        H0PB A -1; Stop;
    V23_Shotgun_4:
        H0PC A -1; Stop;
    V23_Shotgun_5:
        H0PD A -1; Stop;
    V23_Shotgun_6:
        H0PE A -1; Stop;
    V23_javelin_T1_A:
        H0PF A -1; Stop;
    V23_javelin_T2_A:
        H0PG A -1; Stop;
    V23_javelin_T3_A:
        H0PH A -1; Stop;
    V23_spear_T1_A:
        H0PI A -1; Stop;
    V23_spear_T2_A:
        H0PJ A -1; Stop;
    V23_spear_T3_A:
        H0PK A -1; Stop;
    V23_staff_T1_A:
        H0PL A -1; Stop;
    V23_staff_T2_A:
        H0PM A -1; Stop;
    V23_staff_T3_A:
        H0PN A -1; Stop;
    V23_statuette_T1_A:
        H0PO A -1; Stop;
    V23_statuette_T2_A:
        H0PP A -1; Stop;
    V23_statuette_T3_A:
        H0PQ A -1; Stop;
    V23_bell_T1_A:
        H0PR A -1; Stop;
    V23_bell_T2_A:
        H0PS A -1; Stop;
    V23_bell_T3_A:
        H0PT A -1; Stop;
    V23_book_T1_A:
        H0PU A -1; Stop;
    V23_book_T2_A:
        H0PV A -1; Stop;
    V23_book_T3_A:
        H0PW A -1; Stop;
    V23_book_T1_B:
        H0PX A -1; Stop;
    V23_book_T2_B:
        H0PY A -1; Stop;
    V23_book_T3_B:
        H0PZ A -1; Stop;
    V24_Hand_0:
        H0Q0 A -1; Stop;
    V24_Hand_3:
        H0Q1 A -1; Stop;
    V24_Hand_4:
        H0Q2 A -1; Stop;
    V24_Hand_5:
        H0Q3 A -1; Stop;
    V24_Hand_6:
        H0Q4 A -1; Stop;
    V24_Hand_7:
        H0Q5 A -1; Stop;
    V24_Hand_9:
        H0Q6 A -1; Stop;
    V24_Hand_10:
        H0Q7 A -1; Stop;
    V24_Hand_12:
        H0Q8 A -1; Stop;
    V24_ShieldFrame_A:
        H0Q9 A -1; Stop;
    V24_ShieldFrame_B:
        H0Q9 B -1; Stop;
    V24_ShieldFrame_C:
        H0Q9 C -1; Stop;
    V24_ShieldFrame_D:
        H0Q9 D -1; Stop;
    V24_ShieldFrame_H:
        H0Q9 H -1; Stop;
    V24_ShieldFrame_I:
        H0Q9 I -1; Stop;
    V24_Shield_Idle:
        H0Q9 AB 8; Loop;
    V24_Shield_Raise:
        H0Q9 CD 3; Goto V24_Shield_Idle;
    V24_Shield_Lower:
        H0Q9 D 3; H0Q9 C -1; Stop;
    V24_Shield_Attack:
        H0Q9 A 8; Goto V24_Shield_Idle;
    V24_Shield_Block:
        H0Q9 H 3; Goto V24_Shield_Hold;
    V24_Shield_Hold:
        H0Q9 I -1; Stop;
    V24_Bolas:
        H0QA A -1; Stop;
    V24_Shotgun_0:
        H0QB A -1; Stop;
    V24_Shotgun_1:
        H0QC A -1; Stop;
    V24_Shotgun_2:
        H0QD A -1; Stop;
    V24_Shotgun_3:
        H0QE A -1; Stop;
    V24_Shotgun_4:
        H0QF A -1; Stop;
    V24_Shotgun_5:
        H0QG A -1; Stop;
    V24_Shotgun_6:
        H0QH A -1; Stop;
    V24_javelin_T1_A:
        H0QI A -1; Stop;
    V24_javelin_T2_A:
        H0QJ A -1; Stop;
    V24_javelin_T3_A:
        H0QK A -1; Stop;
    V24_spear_T1_A:
        H0QL A -1; Stop;
    V24_spear_T2_A:
        H0QM A -1; Stop;
    V24_spear_T3_A:
        H0QN A -1; Stop;
    V24_staff_T1_A:
        H0QO A -1; Stop;
    V24_staff_T2_A:
        H0QP A -1; Stop;
    V24_staff_T3_A:
        H0QQ A -1; Stop;
    V24_statuette_T1_A:
        H0QR A -1; Stop;
    V24_statuette_T2_A:
        H0QS A -1; Stop;
    V24_statuette_T3_A:
        H0QT A -1; Stop;
    V24_bell_T1_A:
        H0QU A -1; Stop;
    V24_bell_T2_A:
        H0QV A -1; Stop;
    V24_bell_T3_A:
        H0QW A -1; Stop;
    V24_book_T1_A:
        H0QX A -1; Stop;
    V24_book_T2_A:
        H0QY A -1; Stop;
    V24_book_T3_A:
        H0QZ A -1; Stop;
    V24_book_T1_B:
        H0R0 A -1; Stop;
    V24_book_T2_B:
        H0R1 A -1; Stop;
    V24_book_T3_B:
        H0R2 A -1; Stop;
    V25_Hand_0:
        H0R3 A -1; Stop;
    V25_Hand_3:
        H0R4 A -1; Stop;
    V25_Hand_4:
        H0R5 A -1; Stop;
    V25_Hand_5:
        H0R6 A -1; Stop;
    V25_Hand_6:
        H0R7 A -1; Stop;
    V25_Hand_7:
        H0R8 A -1; Stop;
    V25_Hand_9:
        H0R9 A -1; Stop;
    V25_Hand_10:
        H0RA A -1; Stop;
    V25_Hand_12:
        H0RB A -1; Stop;
    V25_ShieldFrame_A:
        H0RC A -1; Stop;
    V25_ShieldFrame_B:
        H0RC B -1; Stop;
    V25_ShieldFrame_C:
        H0RC C -1; Stop;
    V25_ShieldFrame_D:
        H0RC D -1; Stop;
    V25_ShieldFrame_H:
        H0RC H -1; Stop;
    V25_ShieldFrame_I:
        H0RC I -1; Stop;
    V25_Shield_Idle:
        H0RC AB 8; Loop;
    V25_Shield_Raise:
        H0RC CD 3; Goto V25_Shield_Idle;
    V25_Shield_Lower:
        H0RC D 3; H0RC C -1; Stop;
    V25_Shield_Attack:
        H0RC A 8; Goto V25_Shield_Idle;
    V25_Shield_Block:
        H0RC H 3; Goto V25_Shield_Hold;
    V25_Shield_Hold:
        H0RC I -1; Stop;
    V25_Bolas:
        H0RD A -1; Stop;
    V25_Shotgun_0:
        H0RE A -1; Stop;
    V25_Shotgun_1:
        H0RF A -1; Stop;
    V25_Shotgun_2:
        H0RG A -1; Stop;
    V25_Shotgun_3:
        H0RH A -1; Stop;
    V25_Shotgun_4:
        H0RI A -1; Stop;
    V25_Shotgun_5:
        H0RJ A -1; Stop;
    V25_Shotgun_6:
        H0RK A -1; Stop;
    V25_javelin_T1_A:
        H0RL A -1; Stop;
    V25_javelin_T2_A:
        H0RM A -1; Stop;
    V25_javelin_T3_A:
        H0RN A -1; Stop;
    V25_spear_T1_A:
        H0RO A -1; Stop;
    V25_spear_T2_A:
        H0RP A -1; Stop;
    V25_spear_T3_A:
        H0RQ A -1; Stop;
    V25_staff_T1_A:
        H0RR A -1; Stop;
    V25_staff_T2_A:
        H0RS A -1; Stop;
    V25_staff_T3_A:
        H0RT A -1; Stop;
    V25_statuette_T1_A:
        H0RU A -1; Stop;
    V25_statuette_T2_A:
        H0RV A -1; Stop;
    V25_statuette_T3_A:
        H0RW A -1; Stop;
    V25_bell_T1_A:
        H0RX A -1; Stop;
    V25_bell_T2_A:
        H0RY A -1; Stop;
    V25_bell_T3_A:
        H0RZ A -1; Stop;
    V25_book_T1_A:
        H0S0 A -1; Stop;
    V25_book_T2_A:
        H0S1 A -1; Stop;
    V25_book_T3_A:
        H0S2 A -1; Stop;
    V25_book_T1_B:
        H0S3 A -1; Stop;
    V25_book_T2_B:
        H0S4 A -1; Stop;
    V25_book_T3_B:
        H0S5 A -1; Stop;
    V26_Hand_0:
        H0S6 A -1; Stop;
    V26_Hand_3:
        H0S7 A -1; Stop;
    V26_Hand_4:
        H0S8 A -1; Stop;
    V26_Hand_5:
        H0S9 A -1; Stop;
    V26_Hand_6:
        H0SA A -1; Stop;
    V26_Hand_7:
        H0SB A -1; Stop;
    V26_Hand_9:
        H0SC A -1; Stop;
    V26_Hand_10:
        H0SD A -1; Stop;
    V26_Hand_12:
        H0SE A -1; Stop;
    V26_ShieldFrame_A:
        H0SF A -1; Stop;
    V26_ShieldFrame_B:
        H0SF B -1; Stop;
    V26_ShieldFrame_C:
        H0SF C -1; Stop;
    V26_ShieldFrame_D:
        H0SF D -1; Stop;
    V26_ShieldFrame_H:
        H0SF H -1; Stop;
    V26_ShieldFrame_I:
        H0SF I -1; Stop;
    V26_Shield_Idle:
        H0SF AB 8; Loop;
    V26_Shield_Raise:
        H0SF CD 3; Goto V26_Shield_Idle;
    V26_Shield_Lower:
        H0SF D 3; H0SF C -1; Stop;
    V26_Shield_Attack:
        H0SF A 8; Goto V26_Shield_Idle;
    V26_Shield_Block:
        H0SF H 3; Goto V26_Shield_Hold;
    V26_Shield_Hold:
        H0SF I -1; Stop;
    V26_Bolas:
        H0SG A -1; Stop;
    V26_Shotgun_0:
        H0SH A -1; Stop;
    V26_Shotgun_1:
        H0SI A -1; Stop;
    V26_Shotgun_2:
        H0SJ A -1; Stop;
    V26_Shotgun_3:
        H0SK A -1; Stop;
    V26_Shotgun_4:
        H0SL A -1; Stop;
    V26_Shotgun_5:
        H0SM A -1; Stop;
    V26_Shotgun_6:
        H0SN A -1; Stop;
    V26_javelin_T1_A:
        H0SO A -1; Stop;
    V26_javelin_T2_A:
        H0SP A -1; Stop;
    V26_javelin_T3_A:
        H0SQ A -1; Stop;
    V26_spear_T1_A:
        H0SR A -1; Stop;
    V26_spear_T2_A:
        H0SS A -1; Stop;
    V26_spear_T3_A:
        H0ST A -1; Stop;
    V26_staff_T1_A:
        H0SU A -1; Stop;
    V26_staff_T2_A:
        H0SV A -1; Stop;
    V26_staff_T3_A:
        H0SW A -1; Stop;
    V26_statuette_T1_A:
        H0SX A -1; Stop;
    V26_statuette_T2_A:
        H0SY A -1; Stop;
    V26_statuette_T3_A:
        H0SZ A -1; Stop;
    V26_bell_T1_A:
        H0T0 A -1; Stop;
    V26_bell_T2_A:
        H0T1 A -1; Stop;
    V26_bell_T3_A:
        H0T2 A -1; Stop;
    V26_book_T1_A:
        H0T3 A -1; Stop;
    V26_book_T2_A:
        H0T4 A -1; Stop;
    V26_book_T3_A:
        H0T5 A -1; Stop;
    V26_book_T1_B:
        H0T6 A -1; Stop;
    V26_book_T2_B:
        H0T7 A -1; Stop;
    V26_book_T3_B:
        H0T8 A -1; Stop;
    V27_Hand_0:
        H0T9 A -1; Stop;
    V27_Hand_3:
        H0TA A -1; Stop;
    V27_Hand_4:
        H0TB A -1; Stop;
    V27_Hand_5:
        H0TC A -1; Stop;
    V27_Hand_6:
        H0TD A -1; Stop;
    V27_Hand_7:
        H0TE A -1; Stop;
    V27_Hand_9:
        H0TF A -1; Stop;
    V27_Hand_10:
        H0TG A -1; Stop;
    V27_Hand_12:
        H0TH A -1; Stop;
    V27_ShieldFrame_A:
        H0TI A -1; Stop;
    V27_ShieldFrame_B:
        H0TI B -1; Stop;
    V27_ShieldFrame_C:
        H0TI C -1; Stop;
    V27_ShieldFrame_D:
        H0TI D -1; Stop;
    V27_ShieldFrame_H:
        H0TI H -1; Stop;
    V27_ShieldFrame_I:
        H0TI I -1; Stop;
    V27_Shield_Idle:
        H0TI AB 8; Loop;
    V27_Shield_Raise:
        H0TI CD 3; Goto V27_Shield_Idle;
    V27_Shield_Lower:
        H0TI D 3; H0TI C -1; Stop;
    V27_Shield_Attack:
        H0TI A 8; Goto V27_Shield_Idle;
    V27_Shield_Block:
        H0TI H 3; Goto V27_Shield_Hold;
    V27_Shield_Hold:
        H0TI I -1; Stop;
    V27_Bolas:
        H0TJ A -1; Stop;
    V27_Shotgun_0:
        H0TK A -1; Stop;
    V27_Shotgun_1:
        H0TL A -1; Stop;
    V27_Shotgun_2:
        H0TM A -1; Stop;
    V27_Shotgun_3:
        H0TN A -1; Stop;
    V27_Shotgun_4:
        H0TO A -1; Stop;
    V27_Shotgun_5:
        H0TP A -1; Stop;
    V27_Shotgun_6:
        H0TQ A -1; Stop;
    V27_javelin_T1_A:
        H0TR A -1; Stop;
    V27_javelin_T2_A:
        H0TS A -1; Stop;
    V27_javelin_T3_A:
        H0TT A -1; Stop;
    V27_spear_T1_A:
        H0TU A -1; Stop;
    V27_spear_T2_A:
        H0TV A -1; Stop;
    V27_spear_T3_A:
        H0TW A -1; Stop;
    V27_staff_T1_A:
        H0TX A -1; Stop;
    V27_staff_T2_A:
        H0TY A -1; Stop;
    V27_staff_T3_A:
        H0TZ A -1; Stop;
    V27_statuette_T1_A:
        H0U0 A -1; Stop;
    V27_statuette_T2_A:
        H0U1 A -1; Stop;
    V27_statuette_T3_A:
        H0U2 A -1; Stop;
    V27_bell_T1_A:
        H0U3 A -1; Stop;
    V27_bell_T2_A:
        H0U4 A -1; Stop;
    V27_bell_T3_A:
        H0U5 A -1; Stop;
    V27_book_T1_A:
        H0U6 A -1; Stop;
    V27_book_T2_A:
        H0U7 A -1; Stop;
    V27_book_T3_A:
        H0U8 A -1; Stop;
    V27_book_T1_B:
        H0U9 A -1; Stop;
    V27_book_T2_B:
        H0UA A -1; Stop;
    V27_book_T3_B:
        H0UB A -1; Stop;
    V28_Hand_0:
        H0UC A -1; Stop;
    V28_Hand_3:
        H0UD A -1; Stop;
    V28_Hand_4:
        H0UE A -1; Stop;
    V28_Hand_5:
        H0UF A -1; Stop;
    V28_Hand_6:
        H0UG A -1; Stop;
    V28_Hand_7:
        H0UH A -1; Stop;
    V28_Hand_9:
        H0UI A -1; Stop;
    V28_Hand_10:
        H0UJ A -1; Stop;
    V28_Hand_12:
        H0UK A -1; Stop;
    V28_ShieldFrame_A:
        H0UL A -1; Stop;
    V28_ShieldFrame_B:
        H0UL B -1; Stop;
    V28_ShieldFrame_C:
        H0UL C -1; Stop;
    V28_ShieldFrame_D:
        H0UL D -1; Stop;
    V28_ShieldFrame_H:
        H0UL H -1; Stop;
    V28_ShieldFrame_I:
        H0UL I -1; Stop;
    V28_Shield_Idle:
        H0UL AB 8; Loop;
    V28_Shield_Raise:
        H0UL CD 3; Goto V28_Shield_Idle;
    V28_Shield_Lower:
        H0UL D 3; H0UL C -1; Stop;
    V28_Shield_Attack:
        H0UL A 8; Goto V28_Shield_Idle;
    V28_Shield_Block:
        H0UL H 3; Goto V28_Shield_Hold;
    V28_Shield_Hold:
        H0UL I -1; Stop;
    V28_Bolas:
        H0UM A -1; Stop;
    V28_Shotgun_0:
        H0UN A -1; Stop;
    V28_Shotgun_1:
        H0UO A -1; Stop;
    V28_Shotgun_2:
        H0UP A -1; Stop;
    V28_Shotgun_3:
        H0UQ A -1; Stop;
    V28_Shotgun_4:
        H0UR A -1; Stop;
    V28_Shotgun_5:
        H0US A -1; Stop;
    V28_Shotgun_6:
        H0UT A -1; Stop;
    V28_javelin_T1_A:
        H0UU A -1; Stop;
    V28_javelin_T2_A:
        H0UV A -1; Stop;
    V28_javelin_T3_A:
        H0UW A -1; Stop;
    V28_spear_T1_A:
        H0UX A -1; Stop;
    V28_spear_T2_A:
        H0UY A -1; Stop;
    V28_spear_T3_A:
        H0UZ A -1; Stop;
    V28_staff_T1_A:
        H0V0 A -1; Stop;
    V28_staff_T2_A:
        H0V1 A -1; Stop;
    V28_staff_T3_A:
        H0V2 A -1; Stop;
    V28_statuette_T1_A:
        H0V3 A -1; Stop;
    V28_statuette_T2_A:
        H0V4 A -1; Stop;
    V28_statuette_T3_A:
        H0V5 A -1; Stop;
    V28_bell_T1_A:
        H0V6 A -1; Stop;
    V28_bell_T2_A:
        H0V7 A -1; Stop;
    V28_bell_T3_A:
        H0V8 A -1; Stop;
    V28_book_T1_A:
        H0V9 A -1; Stop;
    V28_book_T2_A:
        H0VA A -1; Stop;
    V28_book_T3_A:
        H0VB A -1; Stop;
    V28_book_T1_B:
        H0VC A -1; Stop;
    V28_book_T2_B:
        H0VD A -1; Stop;
    V28_book_T3_B:
        H0VE A -1; Stop;
    V29_Hand_0:
        H0VF A -1; Stop;
    V29_Hand_3:
        H0VG A -1; Stop;
    V29_Hand_4:
        H0VH A -1; Stop;
    V29_Hand_5:
        H0VI A -1; Stop;
    V29_Hand_6:
        H0VJ A -1; Stop;
    V29_Hand_7:
        H0VK A -1; Stop;
    V29_Hand_9:
        H0VL A -1; Stop;
    V29_Hand_10:
        H0VM A -1; Stop;
    V29_Hand_12:
        H0VN A -1; Stop;
    V29_ShieldFrame_A:
        H0VO A -1; Stop;
    V29_ShieldFrame_B:
        H0VO B -1; Stop;
    V29_ShieldFrame_C:
        H0VO C -1; Stop;
    V29_ShieldFrame_D:
        H0VO D -1; Stop;
    V29_ShieldFrame_H:
        H0VO H -1; Stop;
    V29_ShieldFrame_I:
        H0VO I -1; Stop;
    V29_Shield_Idle:
        H0VO AB 8; Loop;
    V29_Shield_Raise:
        H0VO CD 3; Goto V29_Shield_Idle;
    V29_Shield_Lower:
        H0VO D 3; H0VO C -1; Stop;
    V29_Shield_Attack:
        H0VO A 8; Goto V29_Shield_Idle;
    V29_Shield_Block:
        H0VO H 3; Goto V29_Shield_Hold;
    V29_Shield_Hold:
        H0VO I -1; Stop;
    V29_Bolas:
        H0VP A -1; Stop;
    V29_Shotgun_0:
        H0VQ A -1; Stop;
    V29_Shotgun_1:
        H0VR A -1; Stop;
    V29_Shotgun_2:
        H0VS A -1; Stop;
    V29_Shotgun_3:
        H0VT A -1; Stop;
    V29_Shotgun_4:
        H0VU A -1; Stop;
    V29_Shotgun_5:
        H0VV A -1; Stop;
    V29_Shotgun_6:
        H0VW A -1; Stop;
    V29_javelin_T1_A:
        H0VX A -1; Stop;
    V29_javelin_T2_A:
        H0VY A -1; Stop;
    V29_javelin_T3_A:
        H0VZ A -1; Stop;
    V29_spear_T1_A:
        H0W0 A -1; Stop;
    V29_spear_T2_A:
        H0W1 A -1; Stop;
    V29_spear_T3_A:
        H0W2 A -1; Stop;
    V29_staff_T1_A:
        H0W3 A -1; Stop;
    V29_staff_T2_A:
        H0W4 A -1; Stop;
    V29_staff_T3_A:
        H0W5 A -1; Stop;
    V29_statuette_T1_A:
        H0W6 A -1; Stop;
    V29_statuette_T2_A:
        H0W7 A -1; Stop;
    V29_statuette_T3_A:
        H0W8 A -1; Stop;
    V29_bell_T1_A:
        H0W9 A -1; Stop;
    V29_bell_T2_A:
        H0WA A -1; Stop;
    V29_bell_T3_A:
        H0WB A -1; Stop;
    V29_book_T1_A:
        H0WC A -1; Stop;
    V29_book_T2_A:
        H0WD A -1; Stop;
    V29_book_T3_A:
        H0WE A -1; Stop;
    V29_book_T1_B:
        H0WF A -1; Stop;
    V29_book_T2_B:
        H0WG A -1; Stop;
    V29_book_T3_B:
        H0WH A -1; Stop;
    V30_Hand_0:
        H0WI A -1; Stop;
    V30_Hand_3:
        H0WJ A -1; Stop;
    V30_Hand_4:
        H0WK A -1; Stop;
    V30_Hand_5:
        H0WL A -1; Stop;
    V30_Hand_6:
        H0WM A -1; Stop;
    V30_Hand_7:
        H0WN A -1; Stop;
    V30_Hand_9:
        H0WO A -1; Stop;
    V30_Hand_10:
        H0WP A -1; Stop;
    V30_Hand_12:
        H0WQ A -1; Stop;
    V30_ShieldFrame_A:
        H0WR A -1; Stop;
    V30_ShieldFrame_B:
        H0WR B -1; Stop;
    V30_ShieldFrame_C:
        H0WR C -1; Stop;
    V30_ShieldFrame_D:
        H0WR D -1; Stop;
    V30_ShieldFrame_H:
        H0WR H -1; Stop;
    V30_ShieldFrame_I:
        H0WR I -1; Stop;
    V30_Shield_Idle:
        H0WR AB 8; Loop;
    V30_Shield_Raise:
        H0WR CD 3; Goto V30_Shield_Idle;
    V30_Shield_Lower:
        H0WR D 3; H0WR C -1; Stop;
    V30_Shield_Attack:
        H0WR A 8; Goto V30_Shield_Idle;
    V30_Shield_Block:
        H0WR H 3; Goto V30_Shield_Hold;
    V30_Shield_Hold:
        H0WR I -1; Stop;
    V30_Bolas:
        H0WS A -1; Stop;
    V30_Shotgun_0:
        H0WT A -1; Stop;
    V30_Shotgun_1:
        H0WU A -1; Stop;
    V30_Shotgun_2:
        H0WV A -1; Stop;
    V30_Shotgun_3:
        H0WW A -1; Stop;
    V30_Shotgun_4:
        H0WX A -1; Stop;
    V30_Shotgun_5:
        H0WY A -1; Stop;
    V30_Shotgun_6:
        H0WZ A -1; Stop;
    V30_javelin_T1_A:
        H0X0 A -1; Stop;
    V30_javelin_T2_A:
        H0X1 A -1; Stop;
    V30_javelin_T3_A:
        H0X2 A -1; Stop;
    V30_spear_T1_A:
        H0X3 A -1; Stop;
    V30_spear_T2_A:
        H0X4 A -1; Stop;
    V30_spear_T3_A:
        H0X5 A -1; Stop;
    V30_staff_T1_A:
        H0X6 A -1; Stop;
    V30_staff_T2_A:
        H0X7 A -1; Stop;
    V30_staff_T3_A:
        H0X8 A -1; Stop;
    V30_statuette_T1_A:
        H0X9 A -1; Stop;
    V30_statuette_T2_A:
        H0XA A -1; Stop;
    V30_statuette_T3_A:
        H0XB A -1; Stop;
    V30_bell_T1_A:
        H0XC A -1; Stop;
    V30_bell_T2_A:
        H0XD A -1; Stop;
    V30_bell_T3_A:
        H0XE A -1; Stop;
    V30_book_T1_A:
        H0XF A -1; Stop;
    V30_book_T2_A:
        H0XG A -1; Stop;
    V30_book_T3_A:
        H0XH A -1; Stop;
    V30_book_T1_B:
        H0XI A -1; Stop;
    V30_book_T2_B:
        H0XJ A -1; Stop;
    V30_book_T3_B:
        H0XK A -1; Stop;
    V31_Hand_0:
        H0XL A -1; Stop;
    V31_Hand_3:
        H0XM A -1; Stop;
    V31_Hand_4:
        H0XN A -1; Stop;
    V31_Hand_5:
        H0XO A -1; Stop;
    V31_Hand_6:
        H0XP A -1; Stop;
    V31_Hand_7:
        H0XQ A -1; Stop;
    V31_Hand_9:
        H0XR A -1; Stop;
    V31_Hand_10:
        H0XS A -1; Stop;
    V31_Hand_12:
        H0XT A -1; Stop;
    V31_ShieldFrame_A:
        H0XU A -1; Stop;
    V31_ShieldFrame_B:
        H0XU B -1; Stop;
    V31_ShieldFrame_C:
        H0XU C -1; Stop;
    V31_ShieldFrame_D:
        H0XU D -1; Stop;
    V31_ShieldFrame_H:
        H0XU H -1; Stop;
    V31_ShieldFrame_I:
        H0XU I -1; Stop;
    V31_Shield_Idle:
        H0XU AB 8; Loop;
    V31_Shield_Raise:
        H0XU CD 3; Goto V31_Shield_Idle;
    V31_Shield_Lower:
        H0XU D 3; H0XU C -1; Stop;
    V31_Shield_Attack:
        H0XU A 8; Goto V31_Shield_Idle;
    V31_Shield_Block:
        H0XU H 3; Goto V31_Shield_Hold;
    V31_Shield_Hold:
        H0XU I -1; Stop;
    V31_Bolas:
        H0XV A -1; Stop;
    V31_Shotgun_0:
        H0XW A -1; Stop;
    V31_Shotgun_1:
        H0XX A -1; Stop;
    V31_Shotgun_2:
        H0XY A -1; Stop;
    V31_Shotgun_3:
        H0XZ A -1; Stop;
    V31_Shotgun_4:
        H0Y0 A -1; Stop;
    V31_Shotgun_5:
        H0Y1 A -1; Stop;
    V31_Shotgun_6:
        H0Y2 A -1; Stop;
    V31_javelin_T1_A:
        H0Y3 A -1; Stop;
    V31_javelin_T2_A:
        H0Y4 A -1; Stop;
    V31_javelin_T3_A:
        H0Y5 A -1; Stop;
    V31_spear_T1_A:
        H0Y6 A -1; Stop;
    V31_spear_T2_A:
        H0Y7 A -1; Stop;
    V31_spear_T3_A:
        H0Y8 A -1; Stop;
    V31_staff_T1_A:
        H0Y9 A -1; Stop;
    V31_staff_T2_A:
        H0YA A -1; Stop;
    V31_staff_T3_A:
        H0YB A -1; Stop;
    V31_statuette_T1_A:
        H0YC A -1; Stop;
    V31_statuette_T2_A:
        H0YD A -1; Stop;
    V31_statuette_T3_A:
        H0YE A -1; Stop;
    V31_bell_T1_A:
        H0YF A -1; Stop;
    V31_bell_T2_A:
        H0YG A -1; Stop;
    V31_bell_T3_A:
        H0YH A -1; Stop;
    V31_book_T1_A:
        H0YI A -1; Stop;
    V31_book_T2_A:
        H0YJ A -1; Stop;
    V31_book_T3_A:
        H0YK A -1; Stop;
    V31_book_T1_B:
        H0YL A -1; Stop;
    V31_book_T2_B:
        H0YM A -1; Stop;
    V31_book_T3_B:
        H0YN A -1; Stop;
    V32_Hand_0:
        H0YO A -1; Stop;
    V32_Hand_3:
        H0YP A -1; Stop;
    V32_Hand_4:
        H0YQ A -1; Stop;
    V32_Hand_5:
        H0YR A -1; Stop;
    V32_Hand_6:
        H0YS A -1; Stop;
    V32_Hand_7:
        H0YT A -1; Stop;
    V32_Hand_9:
        H0YU A -1; Stop;
    V32_Hand_10:
        H0YV A -1; Stop;
    V32_Hand_12:
        H0YW A -1; Stop;
    V32_ShieldFrame_A:
        H0YX A -1; Stop;
    V32_ShieldFrame_B:
        H0YX B -1; Stop;
    V32_ShieldFrame_C:
        H0YX C -1; Stop;
    V32_ShieldFrame_D:
        H0YX D -1; Stop;
    V32_ShieldFrame_H:
        H0YX H -1; Stop;
    V32_ShieldFrame_I:
        H0YX I -1; Stop;
    V32_Shield_Idle:
        H0YX AB 8; Loop;
    V32_Shield_Raise:
        H0YX CD 3; Goto V32_Shield_Idle;
    V32_Shield_Lower:
        H0YX D 3; H0YX C -1; Stop;
    V32_Shield_Attack:
        H0YX A 8; Goto V32_Shield_Idle;
    V32_Shield_Block:
        H0YX H 3; Goto V32_Shield_Hold;
    V32_Shield_Hold:
        H0YX I -1; Stop;
    V32_Bolas:
        H0YY A -1; Stop;
    V32_Shotgun_0:
        H0YZ A -1; Stop;
    V32_Shotgun_1:
        H0Z0 A -1; Stop;
    V32_Shotgun_2:
        H0Z1 A -1; Stop;
    V32_Shotgun_3:
        H0Z2 A -1; Stop;
    V32_Shotgun_4:
        H0Z3 A -1; Stop;
    V32_Shotgun_5:
        H0Z4 A -1; Stop;
    V32_Shotgun_6:
        H0Z5 A -1; Stop;
    V32_javelin_T1_A:
        H0Z6 A -1; Stop;
    V32_javelin_T2_A:
        H0Z7 A -1; Stop;
    V32_javelin_T3_A:
        H0Z8 A -1; Stop;
    V32_spear_T1_A:
        H0Z9 A -1; Stop;
    V32_spear_T2_A:
        H0ZA A -1; Stop;
    V32_spear_T3_A:
        H0ZB A -1; Stop;
    V32_staff_T1_A:
        H0ZC A -1; Stop;
    V32_staff_T2_A:
        H0ZD A -1; Stop;
    V32_staff_T3_A:
        H0ZE A -1; Stop;
    V32_statuette_T1_A:
        H0ZF A -1; Stop;
    V32_statuette_T2_A:
        H0ZG A -1; Stop;
    V32_statuette_T3_A:
        H0ZH A -1; Stop;
    V32_bell_T1_A:
        H0ZI A -1; Stop;
    V32_bell_T2_A:
        H0ZJ A -1; Stop;
    V32_bell_T3_A:
        H0ZK A -1; Stop;
    V32_book_T1_A:
        H0ZL A -1; Stop;
    V32_book_T2_A:
        H0ZM A -1; Stop;
    V32_book_T3_A:
        H0ZN A -1; Stop;
    V32_book_T1_B:
        H0ZO A -1; Stop;
    V32_book_T2_B:
        H0ZP A -1; Stop;
    V32_book_T3_B:
        H0ZQ A -1; Stop;
    V33_Hand_0:
        H0ZR A -1; Stop;
    V33_Hand_3:
        H0ZS A -1; Stop;
    V33_Hand_4:
        H0ZT A -1; Stop;
    V33_Hand_5:
        H0ZU A -1; Stop;
    V33_Hand_6:
        H0ZV A -1; Stop;
    V33_Hand_7:
        H0ZW A -1; Stop;
    V33_Hand_9:
        H0ZX A -1; Stop;
    V33_Hand_10:
        H0ZY A -1; Stop;
    V33_Hand_12:
        H0ZZ A -1; Stop;
    V33_ShieldFrame_A:
        H100 A -1; Stop;
    V33_ShieldFrame_B:
        H100 B -1; Stop;
    V33_ShieldFrame_C:
        H100 C -1; Stop;
    V33_ShieldFrame_D:
        H100 D -1; Stop;
    V33_ShieldFrame_H:
        H100 H -1; Stop;
    V33_ShieldFrame_I:
        H100 I -1; Stop;
    V33_Shield_Idle:
        H100 AB 8; Loop;
    V33_Shield_Raise:
        H100 CD 3; Goto V33_Shield_Idle;
    V33_Shield_Lower:
        H100 D 3; H100 C -1; Stop;
    V33_Shield_Attack:
        H100 A 8; Goto V33_Shield_Idle;
    V33_Shield_Block:
        H100 H 3; Goto V33_Shield_Hold;
    V33_Shield_Hold:
        H100 I -1; Stop;
    V33_Bolas:
        H101 A -1; Stop;
    V33_Shotgun_0:
        H102 A -1; Stop;
    V33_Shotgun_1:
        H103 A -1; Stop;
    V33_Shotgun_2:
        H104 A -1; Stop;
    V33_Shotgun_3:
        H105 A -1; Stop;
    V33_Shotgun_4:
        H106 A -1; Stop;
    V33_Shotgun_5:
        H107 A -1; Stop;
    V33_Shotgun_6:
        H108 A -1; Stop;
    V33_javelin_T1_A:
        H109 A -1; Stop;
    V33_javelin_T2_A:
        H10A A -1; Stop;
    V33_javelin_T3_A:
        H10B A -1; Stop;
    V33_spear_T1_A:
        H10C A -1; Stop;
    V33_spear_T2_A:
        H10D A -1; Stop;
    V33_spear_T3_A:
        H10E A -1; Stop;
    V33_staff_T1_A:
        H10F A -1; Stop;
    V33_staff_T2_A:
        H10G A -1; Stop;
    V33_staff_T3_A:
        H10H A -1; Stop;
    V33_statuette_T1_A:
        H10I A -1; Stop;
    V33_statuette_T2_A:
        H10J A -1; Stop;
    V33_statuette_T3_A:
        H10K A -1; Stop;
    V33_bell_T1_A:
        H10L A -1; Stop;
    V33_bell_T2_A:
        H10M A -1; Stop;
    V33_bell_T3_A:
        H10N A -1; Stop;
    V33_book_T1_A:
        H10O A -1; Stop;
    V33_book_T2_A:
        H10P A -1; Stop;
    V33_book_T3_A:
        H10Q A -1; Stop;
    V33_book_T1_B:
        H10R A -1; Stop;
    V33_book_T2_B:
        H10S A -1; Stop;
    V33_book_T3_B:
        H10T A -1; Stop;
    V34_Hand_0:
        H10U A -1; Stop;
    V34_Hand_3:
        H10V A -1; Stop;
    V34_Hand_4:
        H10W A -1; Stop;
    V34_Hand_5:
        H10X A -1; Stop;
    V34_Hand_6:
        H10Y A -1; Stop;
    V34_Hand_7:
        H10Z A -1; Stop;
    V34_Hand_9:
        H110 A -1; Stop;
    V34_Hand_10:
        H111 A -1; Stop;
    V34_Hand_12:
        H112 A -1; Stop;
    V34_ShieldFrame_A:
        H113 A -1; Stop;
    V34_ShieldFrame_B:
        H113 B -1; Stop;
    V34_ShieldFrame_C:
        H113 C -1; Stop;
    V34_ShieldFrame_D:
        H113 D -1; Stop;
    V34_ShieldFrame_H:
        H113 H -1; Stop;
    V34_ShieldFrame_I:
        H113 I -1; Stop;
    V34_Shield_Idle:
        H113 AB 8; Loop;
    V34_Shield_Raise:
        H113 CD 3; Goto V34_Shield_Idle;
    V34_Shield_Lower:
        H113 D 3; H113 C -1; Stop;
    V34_Shield_Attack:
        H113 A 8; Goto V34_Shield_Idle;
    V34_Shield_Block:
        H113 H 3; Goto V34_Shield_Hold;
    V34_Shield_Hold:
        H113 I -1; Stop;
    V34_Bolas:
        H114 A -1; Stop;
    V34_Shotgun_0:
        H115 A -1; Stop;
    V34_Shotgun_1:
        H116 A -1; Stop;
    V34_Shotgun_2:
        H117 A -1; Stop;
    V34_Shotgun_3:
        H118 A -1; Stop;
    V34_Shotgun_4:
        H119 A -1; Stop;
    V34_Shotgun_5:
        H11A A -1; Stop;
    V34_Shotgun_6:
        H11B A -1; Stop;
    V34_javelin_T1_A:
        H11C A -1; Stop;
    V34_javelin_T2_A:
        H11D A -1; Stop;
    V34_javelin_T3_A:
        H11E A -1; Stop;
    V34_spear_T1_A:
        H11F A -1; Stop;
    V34_spear_T2_A:
        H11G A -1; Stop;
    V34_spear_T3_A:
        H11H A -1; Stop;
    V34_staff_T1_A:
        H11I A -1; Stop;
    V34_staff_T2_A:
        H11J A -1; Stop;
    V34_staff_T3_A:
        H11K A -1; Stop;
    V34_statuette_T1_A:
        H11L A -1; Stop;
    V34_statuette_T2_A:
        H11M A -1; Stop;
    V34_statuette_T3_A:
        H11N A -1; Stop;
    V34_bell_T1_A:
        H11O A -1; Stop;
    V34_bell_T2_A:
        H11P A -1; Stop;
    V34_bell_T3_A:
        H11Q A -1; Stop;
    V34_book_T1_A:
        H11R A -1; Stop;
    V34_book_T2_A:
        H11S A -1; Stop;
    V34_book_T3_A:
        H11T A -1; Stop;
    V34_book_T1_B:
        H11U A -1; Stop;
    V34_book_T2_B:
        H11V A -1; Stop;
    V34_book_T3_B:
        H11W A -1; Stop;
    V35_Hand_0:
        H11X A -1; Stop;
    V35_Hand_3:
        H11Y A -1; Stop;
    V35_Hand_4:
        H11Z A -1; Stop;
    V35_Hand_5:
        H120 A -1; Stop;
    V35_Hand_6:
        H121 A -1; Stop;
    V35_Hand_7:
        H122 A -1; Stop;
    V35_Hand_9:
        H123 A -1; Stop;
    V35_Hand_10:
        H124 A -1; Stop;
    V35_Hand_12:
        H125 A -1; Stop;
    V35_ShieldFrame_A:
        H126 A -1; Stop;
    V35_ShieldFrame_B:
        H126 B -1; Stop;
    V35_ShieldFrame_C:
        H126 C -1; Stop;
    V35_ShieldFrame_D:
        H126 D -1; Stop;
    V35_ShieldFrame_H:
        H126 H -1; Stop;
    V35_ShieldFrame_I:
        H126 I -1; Stop;
    V35_Shield_Idle:
        H126 AB 8; Loop;
    V35_Shield_Raise:
        H126 CD 3; Goto V35_Shield_Idle;
    V35_Shield_Lower:
        H126 D 3; H126 C -1; Stop;
    V35_Shield_Attack:
        H126 A 8; Goto V35_Shield_Idle;
    V35_Shield_Block:
        H126 H 3; Goto V35_Shield_Hold;
    V35_Shield_Hold:
        H126 I -1; Stop;
    V35_Bolas:
        H127 A -1; Stop;
    V35_Shotgun_0:
        H128 A -1; Stop;
    V35_Shotgun_1:
        H129 A -1; Stop;
    V35_Shotgun_2:
        H12A A -1; Stop;
    V35_Shotgun_3:
        H12B A -1; Stop;
    V35_Shotgun_4:
        H12C A -1; Stop;
    V35_Shotgun_5:
        H12D A -1; Stop;
    V35_Shotgun_6:
        H12E A -1; Stop;
    V35_javelin_T1_A:
        H12F A -1; Stop;
    V35_javelin_T2_A:
        H12G A -1; Stop;
    V35_javelin_T3_A:
        H12H A -1; Stop;
    V35_spear_T1_A:
        H12I A -1; Stop;
    V35_spear_T2_A:
        H12J A -1; Stop;
    V35_spear_T3_A:
        H12K A -1; Stop;
    V35_staff_T1_A:
        H12L A -1; Stop;
    V35_staff_T2_A:
        H12M A -1; Stop;
    V35_staff_T3_A:
        H12N A -1; Stop;
    V35_statuette_T1_A:
        H12O A -1; Stop;
    V35_statuette_T2_A:
        H12P A -1; Stop;
    V35_statuette_T3_A:
        H12Q A -1; Stop;
    V35_bell_T1_A:
        H12R A -1; Stop;
    V35_bell_T2_A:
        H12S A -1; Stop;
    V35_bell_T3_A:
        H12T A -1; Stop;
    V35_book_T1_A:
        H12U A -1; Stop;
    V35_book_T2_A:
        H12V A -1; Stop;
    V35_book_T3_A:
        H12W A -1; Stop;
    V35_book_T1_B:
        H12X A -1; Stop;
    V35_book_T2_B:
        H12Y A -1; Stop;
    V35_book_T3_B:
        H12Z A -1; Stop;
    V36_Hand_0:
        H130 A -1; Stop;
    V36_Hand_3:
        H131 A -1; Stop;
    V36_Hand_4:
        H132 A -1; Stop;
    V36_Hand_5:
        H133 A -1; Stop;
    V36_Hand_6:
        H134 A -1; Stop;
    V36_Hand_7:
        H135 A -1; Stop;
    V36_Hand_9:
        H136 A -1; Stop;
    V36_Hand_10:
        H137 A -1; Stop;
    V36_Hand_12:
        H138 A -1; Stop;
    V36_ShieldFrame_A:
        H139 A -1; Stop;
    V36_ShieldFrame_B:
        H139 B -1; Stop;
    V36_ShieldFrame_C:
        H139 C -1; Stop;
    V36_ShieldFrame_D:
        H139 D -1; Stop;
    V36_ShieldFrame_H:
        H139 H -1; Stop;
    V36_ShieldFrame_I:
        H139 I -1; Stop;
    V36_Shield_Idle:
        H139 AB 8; Loop;
    V36_Shield_Raise:
        H139 CD 3; Goto V36_Shield_Idle;
    V36_Shield_Lower:
        H139 D 3; H139 C -1; Stop;
    V36_Shield_Attack:
        H139 A 8; Goto V36_Shield_Idle;
    V36_Shield_Block:
        H139 H 3; Goto V36_Shield_Hold;
    V36_Shield_Hold:
        H139 I -1; Stop;
    V36_Bolas:
        H13A A -1; Stop;
    V36_Shotgun_0:
        H13B A -1; Stop;
    V36_Shotgun_1:
        H13C A -1; Stop;
    V36_Shotgun_2:
        H13D A -1; Stop;
    V36_Shotgun_3:
        H13E A -1; Stop;
    V36_Shotgun_4:
        H13F A -1; Stop;
    V36_Shotgun_5:
        H13G A -1; Stop;
    V36_Shotgun_6:
        H13H A -1; Stop;
    V36_javelin_T1_A:
        H13I A -1; Stop;
    V36_javelin_T2_A:
        H13J A -1; Stop;
    V36_javelin_T3_A:
        H13K A -1; Stop;
    V36_spear_T1_A:
        H13L A -1; Stop;
    V36_spear_T2_A:
        H13M A -1; Stop;
    V36_spear_T3_A:
        H13N A -1; Stop;
    V36_staff_T1_A:
        H13O A -1; Stop;
    V36_staff_T2_A:
        H13P A -1; Stop;
    V36_staff_T3_A:
        H13Q A -1; Stop;
    V36_statuette_T1_A:
        H13R A -1; Stop;
    V36_statuette_T2_A:
        H13S A -1; Stop;
    V36_statuette_T3_A:
        H13T A -1; Stop;
    V36_bell_T1_A:
        H13U A -1; Stop;
    V36_bell_T2_A:
        H13V A -1; Stop;
    V36_bell_T3_A:
        H13W A -1; Stop;
    V36_book_T1_A:
        H13X A -1; Stop;
    V36_book_T2_A:
        H13Y A -1; Stop;
    V36_book_T3_A:
        H13Z A -1; Stop;
    V36_book_T1_B:
        H140 A -1; Stop;
    V36_book_T2_B:
        H141 A -1; Stop;
    V36_book_T3_B:
        H142 A -1; Stop;
    }
}
