// This file contains values shared by several gameplay systems.
// Centralizing them prevents the same unexplained number from appearing in
// many different source files.
class CaelumConstants : Object
{
    const DEBUG_ALL_ATTRIBUTES_LEVEL_75 = 75;
    const DEBUG_ALL_ATTRIBUTES_LEVEL_100 = 100;
    // The design document defines twelve primary character attributes.
    const PRIMARY_ATTRIBUTE_COUNT = 12;
    const ATTRIBUTE_LAYER_COUNT = 4;

    // Character creation allocation limits from the design document.
    const FREE_LAYER_POINTS = 4;
    const MAX_LAYER_BASE = 15;
    const INDIVIDUAL_ATTRIBUTE_POINTS = 30;
    const MAX_INDIVIDUAL_BONUS = 5;

    // Temporary equipment-weight controls use five-unit steps.
    const DEBUG_WEIGHT_STEP = 5;

    // The confirmed overload state and accelerated air use both begin after
    // the player exceeds 75% of carry capacity.
    const OVERLOAD_THRESHOLD = 0.75;

    // Provisional air-resource tests spend ten base units per key press.
    const DEBUG_AIR_ACTION_COST = 10;

    // Until real spells exist, the Anima test action spends ten units so the
    // resource, saving, clamping, and regeneration can be verified safely.
    const DEBUG_ANIMA_ACTION_COST = 100;

    // Health, Anima, weapon damage, and Anima costs use a ten-times larger
    // integer scale. Percentages and unrelated resources remain unchanged.
    const HEALTH_ANIMA_DAMAGE_SCALE = 10.0;

    // Adrenaline capacity keeps its ten-times scale. Gameplay gains use their
    // original values again; post-combat decay deliberately remains 10/s.
    const ADRENALINE_CAPACITY_SCALE = 10.0;
    const ADRENALINE_GAIN_ON_DAMAGE = 10.0;
    const ADRENALINE_GAIN_ON_PAIN = 20.0;
    const DEBUG_ADRENALINE_GAIN = 10.0;

    // Combat ends thirty seconds after the latest confirmed event. Adrenaline
    // then decays by ten points per second until it reaches zero.
    const COMBAT_TIMEOUT_SECONDS = 30.0;
    const ADRENALINE_DECAY_PER_SECOND = 10.0;
    const DEBUG_PAIN_HEALTH_LOSS_RATIO = 0.05;
    const DEBUG_EVASION_DAMAGE_RATIO = 0.01;

    // Isolated combat test: standard sword damage plus humanoid regions.
    const DEBUG_SWORD_BASE_DAMAGE = 120.0;
    const DEBUG_SWORD_RANGE = 64.0;
    const DEBUG_SWORD_PRIMARY_AIR_COST = 5.0;
    // Fuerza horizontal independiente del dano para los impactos fisicos.
    const BASE_ATTACK_PUSH_FORCE = 8.0;
    const DEBUG_STAFF_BASE_DAMAGE = 120.0;
    const DEBUG_STAFF_ANIMA_COST = 500.0;
    const DEBUG_STAFF_CAST_TICS = 18;
    // Provisional trace distance until final magical-weapon ranges are authored.
    const DEBUG_STAFF_TRACE_RANGE = 1024.0;
    const DEBUG_STAFF_BASE_CRITICAL_CHANCE_PERCENT = 8.0;
    // Ficha tier 1 de la carabina, reemplazo del arco corto.
    const CARBINE_TIER_ONE_BASE_WEIGHT = 12.0;
    const CARBINE_TIER_ONE_DAMAGE = 360.0;
    const CARBINE_TIER_ONE_FIRE_TICS = 48;
    const CARBINE_TIER_ONE_RANGE_METERS = 60.0;
    const CARBINE_MINIMUM_SPREAD_DEGREES = 30.0;
    const CARBINE_MAXIMUM_SPREAD_DEGREES = 200.0;
    const CARBINE_BASE_CRITICAL_CHANCE_PERCENT = 0.0;
    const CARBINE_AIR_CHANGE = -20.0;
    const TEST_ACTOR_RANGED_DAMAGE = 138;
    const TEST_RULO_RANGED_DAMAGE = 372;
    const TEST_RONNIE_MAGIC_DAMAGE = 372;
    const BASE_CRITICAL_CHANCE_PERCENT = 5.0;
    const ADRENALINE_GAIN_ON_MELEE_DAMAGE = 3.0;
    const ADRENALINE_GAIN_ON_EVASION = 8.0;
    const ADRENALINE_GAIN_ON_ENEMY_KILL = 5.0;
    const ADRENALINE_GAIN_ON_NEARBY_ALLY_DEATH = 10.0;
    // Development scale: 32 map units represent one meter.
    const ALLY_DEATH_ADRENALINE_RANGE = 320.0;
    const ADRENALINE_EVENT_OTHER = 0;
    const ADRENALINE_EVENT_DAMAGE = 1;
    const ADRENALINE_EVENT_PAIN = 2;
    const ADRENALINE_EVENT_MELEE = 3;
    const ADRENALINE_EVENT_EVASION = 4;
    const ADRENALINE_EVENT_ENEMY_KILL = 5;
    const ADRENALINE_EVENT_ALLY_DEATH = 6;
    const ADRENALINE_EVENT_SHIELD_BLOCK = 7;
    const ADRENALINE_EVENT_MAGIC_DAMAGE = 8;
    const ADRENALINE_GAIN_ON_SHIELD_BLOCK = 5.0;
    const ADRENALINE_GAIN_ON_MAGIC_DAMAGE = 2.0;
    const HEALTH_WOUNDED_THRESHOLD = 0.50;
    const HEALTH_BADLY_WOUNDED_THRESHOLD = 0.10;
    const HEALTH_STATE_NORMAL = 0;
    const HEALTH_STATE_WOUNDED = 1;
    const HEALTH_STATE_BADLY_WOUNDED = 2;
    const HEALTH_WOUNDED_PERFORMANCE_MULTIPLIER = 0.75;
    const HEALTH_BADLY_WOUNDED_PERFORMANCE_MULTIPLIER = 0.25;
    const HEALTH_WOUNDED_INTENSITY_MULTIPLIER = 2.0;
    const HEALTH_BADLY_WOUNDED_INTENSITY_MULTIPLIER = 4.0;
    const HIT_LOCATION_NONE = 0;
    const HIT_LOCATION_HEAD = 1;
    const HIT_LOCATION_TORSO = 2;
    const HIT_LOCATION_ARMS = 3;
    const HIT_LOCATION_LEGS = 4;
    const HIT_HEAD_MINIMUM_RATIO = 0.80;
    const HIT_TORSO_MINIMUM_RATIO = 0.40;
    const HIT_ARMS_MINIMUM_RATIO = 0.30;
    const HIT_ARMS_MAXIMUM_RATIO = 0.50;
    const HIT_ARMS_LATERAL_RATIO = 0.50;
    const VULNERABILITY_CRITICAL_POINT = 0;
    const VULNERABILITY_SENSITIVE_POINT = 1;
    const VULNERABILITY_WEAK_POINT = 2;
    const VULNERABILITY_NEUTRAL_POINT = 3;
    const VULNERABILITY_STRONG_POINT = 4;
    const VULNERABILITY_HARD_POINT = 5;
    const VULNERABILITY_ARMORED_POINT = 6;
    const VULNERABILITY_GRADE_COUNT = 7;
    const VULNERABILITY_CRITICAL_MULTIPLIER = 2.0;
    const VULNERABILITY_SENSITIVE_MULTIPLIER = 1.6;
    const VULNERABILITY_WEAK_MULTIPLIER = 1.3;
    const VULNERABILITY_NEUTRAL_MULTIPLIER = 1.0;
    const VULNERABILITY_STRONG_MULTIPLIER = 0.8;
    const VULNERABILITY_HARD_MULTIPLIER = 0.6;
    const VULNERABILITY_ARMORED_MULTIPLIER = 0.4;

    const ARMOR_SLOT_HEAD = 0;
    const ARMOR_SLOT_BODY = 1;
    const ARMOR_SLOT_HANDS = 2;
    const ARMOR_SLOT_FEET = 3;
    const ARMOR_SLOT_COUNT = 4;
    const ARMOR_TYPE_MAGIC = 0;
    // Alias de compatibilidad para archivos incrementales y partidas 4.6 que
    // aun referencien el identificador anterior. En juego sigue mostrandose
    // exclusivamente como armadura magica y conserva el mismo indice cero.
    const ARMOR_TYPE_UNARMORED = ARMOR_TYPE_MAGIC;
    const ARMOR_TYPE_LIGHT = 1;
    const ARMOR_TYPE_MEDIUM = 2;
    const ARMOR_TYPE_HEAVY = 3;
    // El equipo base representa la ausencia real de armadura. No se ofrece
    // como objeto seleccionable ni ocupa espacio en la Caja Mágica.
    const ARMOR_TYPE_BASE_CLOTHING = 4;
    const ARMOR_EQUIPPABLE_TYPE_COUNT = 4;
    const ARMOR_TYPE_COUNT = 5;
    const DEBUG_ARMOR_HIT_DAMAGE = 1000.0;
    const ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT = 10.0;
    const ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY = 1000.0;
    const EQUIPMENT_KIND_ARMOR = 0;
    const EQUIPMENT_KIND_SHIELD = 1;
    const EQUIPMENT_KIND_WEAPON = 2;
    const EQUIPMENT_KIND_AMMUNITION = 3;
    const EQUIPMENT_KIND_COUNT = 4;
    const EQUIPMENT_ACTION_NONE = 0;
    const EQUIPMENT_ACTION_CREATED = 1;
    const EQUIPMENT_ACTION_EQUIPPED = 2;
    const EQUIPMENT_ACTION_UNEQUIPPED = 3;
    const EQUIPMENT_ACTION_BROKEN = 4;
    const EQUIPMENT_ACTION_DROPPED = 5;
    const EQUIPMENT_ACTION_FAILED_NOT_OWNED = 6;
    const EQUIPMENT_ACTION_FAILED_SIZE = 7;
    const EQUIPMENT_ACTION_FAILED_BOX_FULL = 8;
    const EQUIPMENT_ACTION_CREATED_IN_MAGIC_BOX = 9;
    const EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY = 10;
    const EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX = 11;
    const EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX = 12;
    const EQUIPMENT_ACTION_SPAWNED_ON_FLOOR = 13;

    const EQUIPMENT_SIZE_XS = 0;
    const EQUIPMENT_SIZE_S = 1;
    const EQUIPMENT_SIZE_M = 2;
    const EQUIPMENT_SIZE_L = 3;
    const EQUIPMENT_SIZE_XL = 4;
    const EQUIPMENT_SIZE_COUNT = 5;

    const SHIELD_TYPE_BUCKLER = 0;
    const SHIELD_TYPE_KITE = 1;
    const SHIELD_TYPE_TOWER = 2;
    const SHIELD_TYPE_MAGIC = 3;
    const SHIELD_TYPE_COUNT = 4;
    const SHIELD_DAMAGE_PHYSICAL = 0;
    const SHIELD_DAMAGE_MAGICAL = 1;
    const DEBUG_SHIELD_HIT_DAMAGE = 1000.0;
    const SHIELD_AIR_WEIGHT_RATIO_PER_SECOND = 0.10;

    // Primer catalogo jugable de armas. Los indices son persistentes: no deben
    // reordenarse cuando se agreguen nuevas familias en versiones posteriores.
    const WEAPON_TYPE_SWORD = 0;
    const WEAPON_TYPE_STAFF = 1;
    const WEAPON_TYPE_CARBINE = 2;
    const WEAPON_TYPE_COUNT = 3;
    const WEAPON_SWORD_TIER_ONE_WEIGHT = 6.0;
    const WEAPON_STAFF_TIER_ONE_WEIGHT = 4.0;
    const WEAPON_CARBINE_TIER_ONE_WEIGHT = 12.0;
    const WEAPON_SWORD_BASE_DURABILITY = 100;
    const WEAPON_STAFF_BASE_DURABILITY = 80;
    const WEAPON_CARBINE_BASE_DURABILITY = 120;
    const WEAPON_SWORD_ATTACK_TICS = 14;
    const WEAPON_CARBINE_STARTING_AMMO = 100;
    const CARBINE_AMMO_UNIT_WEIGHT = 0.003;
    const WEAPON_CARBINE_PROJECTILE_SPEED = 80.0;

    // Lucidity is a fixed 100-point resource that refills in one minute.
    const MAXIMUM_LUCIDITY = 100.0;
    const LUCIDITY_FULL_RECOVERY_SECONDS = 60.0;
    const DEBUG_LUCIDITY_LOSS = 10.0;
    const CRITICAL_POINT_BASE_LUCIDITY_LOSS = 25.0;
    const LUCIDITY_SLEEP_LOW_INTENSITY_MULTIPLIER = 2.0;
    const LUCIDITY_SLEEP_CRITICAL_INTENSITY_MULTIPLIER = 4.0;
    const LUCIDITY_DIZZY_THRESHOLD = 0.50;
    const LUCIDITY_STUNNED_THRESHOLD = 0.10;
    // Dizzy and stunned characters retain half of their effective accuracy.
    // The provisional sword uses a small angular error so this shared factor
    // already affects a real attack before final weapon cones exist.
    const LUCIDITY_DIZZY_ACCURACY_MULTIPLIER = 0.50;
    // Running retains one quarter of the accuracy available after attributes
    // and lucidity. Walking and standing retain the complete value.
    const RUNNING_ACCURACY_MULTIPLIER = 0.25;
    const CROUCH_ACCURACY_MULTIPLIER = 2.0;
    const CROUCH_CRITICAL_CHANCE_MULTIPLIER = 2.0;
    const CROUCH_STEALTH_MULTIPLIER = 2.0;
    const DEBUG_SWORD_BASE_INACCURACY_DEGREES = 6.0;
    const LUCIDITY_PHYSICAL_STUN_SECONDS = 2.0;
    const LUCIDITY_STATE_NORMAL = 0;
    const LUCIDITY_STATE_DIZZY = 1;
    const LUCIDITY_STATE_STUNNED = 2;

    // Definitive world clock: one game hour equals three real minutes.
    const REAL_SECONDS_PER_GAME_HOUR = 180.0;
    const HUNGER_EMPTY_GAME_HOURS = 24.0;
    const THIRST_EMPTY_GAME_HOURS = 12.0;
    const SLEEP_EMPTY_GAME_HOURS = 16.0;
    const SURVIVAL_MAXIMUM = 100.0;
    const DEBUG_SURVIVAL_LOSS = 10.0;
    const SURVIVAL_LOW_THRESHOLD = 0.50;
    const SURVIVAL_CRITICAL_THRESHOLD = 0.10;
    const SURVIVAL_STATE_NORMAL = 0;
    const SURVIVAL_STATE_LOW = 1;
    const SURVIVAL_STATE_CRITICAL = 2;
    const SURVIVAL_LOW_PERFORMANCE_MULTIPLIER = 0.75;
    const SURVIVAL_CRITICAL_PERFORMANCE_MULTIPLIER = 0.50;

    // Natural health recovery fills the current maximum in one real hour.
    // Critical hunger, thirst, and sleep each invert this unmodified base rate.
    const HEALTH_BASE_RECOVERY_REAL_SECONDS = 3600.0;

    // Every successful physical jump spends five base air units. Equipment
    // load modifies this value through the shared air-consumption multiplier.
    const JUMP_AIR_COST = 5;

    // Running spends two base air units per second. Walking remains free.
    // Equipment load modifies this rate through the shared multiplier.
    const RUN_AIR_COST_PER_SECOND = 2.0;

    // GZDoom PlayerPawn defaults use movement x1 and JumpZ 8. Fixed baselines
    // prevent the effective percentages from accumulating every game tic.
    const GZDOOM_BASE_MOVEMENT = 1.0;
    const GZDOOM_BASE_JUMP_Z = 8.0;

    // El aire parte de 1000 y Resilience aplica el crecimiento existente.
    // Type 4 percentage without changing its curve or reference levels.
    const BASE_AIR_CAPACITY = 1000.0;

    // The design defines a complete air recovery time of eight minutes.
    const AIR_FULL_RECOVERY_SECONDS = 480;
    // A complete air refill consumes 10% hunger and 20% thirst. Expressing
    // these as full-refill costs keeps the rule independent of maximum air.
    const AIR_FULL_RECOVERY_HUNGER_COST = 10.0;
    const AIR_FULL_RECOVERY_THIRST_COST = 20.0;

    // Anima also takes eight minutes to refill at its base regeneration speed.
    const ANIMA_FULL_RECOVERY_SECONDS = 480;
    const AIR_TIRED_THRESHOLD = 0.5;
    const AIR_BREATHLESS_THRESHOLD = 0.1;

    // Stable state indices let gameplay and UI share a stored result without
    // making cross-context function calls.
    const AIR_STATE_NORMAL = 0;
    const AIR_STATE_TIRED = 1;
    const AIR_STATE_BREATHLESS = 2;

    // Movement, jump height, and evasion retain the same share in each
    // documented low-air state.
    const TIRED_PERFORMANCE_MULTIPLIER = 0.75;
    const BREATHLESS_PERFORMANCE_MULTIPLIER = 0.25;

    // Las cuatro capas de atributos usadas por razas y clases.
    const LAYER_PHYSICAL = 0;
    const LAYER_TECHNICAL = 1;
    const LAYER_SOCIAL = 2;
    const LAYER_MENTAL = 3;

    // Razas jugables de la creacion 4.0.
    const RACE_BEAST_MAN = 0;
    const RACE_CAELITH = 1;
    const RACE_HUMAN = 2;
    const RACE_GOBLIN = 3;

    // Playable classes.
    const CLASS_WARRIOR = 0;
    const CLASS_EXPLORER = 1;
    const CLASS_PRIEST = 2;
    const CLASS_MAGE = 3;

    // Profesiones resultantes de combinar las dos clases sin importar orden.
    const PROFESSION_WARRIOR = 0;
    const PROFESSION_EXPLORER = 1;
    const PROFESSION_PRIEST = 2;
    const PROFESSION_MAGE = 3;
    const PROFESSION_MERCENARY = 4;
    const PROFESSION_CLERIC = 5;
    const PROFESSION_BATTLE_MAGE = 6;
    const PROFESSION_PILGRIM = 7;
    const PROFESSION_INVESTIGATOR = 8;
    const PROFESSION_ARCANIST = 9;

    const SEX_MALE = 0;
    const SEX_FEMALE = 1;
    const HEIGHT_SHORT = 0;
    const HEIGHT_NORMAL = 1;
    const HEIGHT_TALL = 2;

    const BASE_MASS_TIER = 5;
    const BASE_SIZE_TIER = 4;
    const MIN_MASS_TIER = 1;
    const MAX_MASS_TIER = 10;
    const MIN_SIZE_TIER = 1;
    const MAX_SIZE_TIER = 7;

    // Stable indices for the twelve primary attributes. These let the creation
    // system select an attribute without duplicating twelve separate functions.
    const ATTRIBUTE_STRENGTH = 0;
    const ATTRIBUTE_TOUGHNESS = 1;
    const ATTRIBUTE_CONSTITUTION = 2;
    const ATTRIBUTE_AGILITY = 3;
    const ATTRIBUTE_DEXTERITY = 4;
    const ATTRIBUTE_RESILIENCE = 5;
    const ATTRIBUTE_CHARISMA = 6;
    const ATTRIBUTE_EMPATHY = 7;
    const ATTRIBUTE_ELOQUENCE = 8;
    const ATTRIBUTE_INTELLIGENCE = 9;
    const ATTRIBUTE_PATIENCE = 10;
    const ATTRIBUTE_INSIGHT = 11;

    // Paginas del creador 4.0.
    const CREATION_PAGE_RACE = 0;
    const CREATION_PAGE_FIRST_CLASS = 1;
    const CREATION_PAGE_SECOND_CLASS = 2;
    const CREATION_PAGE_SEX = 3;
    const CREATION_PAGE_HEIGHT = 4;
    const CREATION_PAGE_LAYERS = 5;
    const CREATION_PAGE_ATTRIBUTES = 6;
    const CREATION_PAGE_SUMMARY = 7;
}
