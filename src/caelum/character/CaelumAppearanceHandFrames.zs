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
    }
}
