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
    // La campana compensa su abanico de siete proyectiles con menor dano
    // individual y un coste de lanzamiento duplicado.
    const WEAPON_BELL_BASE_DAMAGE = 50.0;
    const WEAPON_BELL_ANIMA_COST = 1000.0;
    const WEAPON_BELL_PROJECTILE_COUNT = 7;
    // Provisional trace distance until final magical-weapon ranges are authored.
    const DEBUG_STAFF_TRACE_RANGE = 1024.0;
    const DEBUG_STAFF_BASE_CRITICAL_CHANCE_PERCENT = 8.0;
    const ESSENCE_BASE_RANGE_MAP_UNITS = 3200.0;
    // La velocidad normal toma como referencia el cohete de Doom/Cyberdemon.
    const PROJECTILE_SPEED_VERY_SLOW = 10.0;
    const PROJECTILE_SPEED_SLOW = 15.0;
    const PROJECTILE_SPEED_NORMAL = 20.0;
    const PROJECTILE_SPEED_FAST = 40.0;
    const PROJECTILE_SPEED_VERY_FAST = 60.0;

    // Las cinco esencias comparten objeto base; este valor determina el
    // elemento primario de Fire y el secundario de AltFire.
    const ESSENCE_FIRE = 0;
    const ESSENCE_WATER = 1;
    const ESSENCE_EARTH = 2;
    const ESSENCE_WIND = 3;
    const ESSENCE_QUINTESSENCE = 4;
    const ESSENCE_TYPE_COUNT = 5;
    const ELEMENTAL_BASE_DURATION_SECONDS = 3.0;
    const ELEMENTAL_DOT_DAMAGE_RATIO = 0.10;
    const ELEMENTAL_BASE_CONTROL_POWER_PERCENT = 50.0;
    const ELEMENTAL_LIGHTNING_STUN_SECONDS = 0.30;
    const ELEMENTAL_MODERATE_PUSH_MULTIPLIER = 1.60;
    const ELEMENTAL_EXTREME_PUSH_MULTIPLIER = 2.50;
    const QUINTESSENCE_PRIMARY_DAMAGE_MULTIPLIER = 2.0;
    const QUINTESSENCE_EFFECT_CHANCE_PERCENT = 10.0;

    const ELEMENTAL_EFFECT_BURN = 0;
    const ELEMENTAL_EFFECT_CUT = 1;
    const ELEMENTAL_EFFECT_POISON = 2;
    const ELEMENTAL_EFFECT_FREEZE = 3;
    const ELEMENTAL_EFFECT_DAZZLE = 4;
    const ELEMENTAL_EFFECT_LIGHTNING_STUN = 5;
    const ESSENCE_EXPLOSION_BASE_RADIUS = 128;
    const ESSENCE_EXPLOSIVE_DIRECT_DAMAGE_RATIO = 0.10;
    // Ficha tier 1 de la carabina, reemplazo del arco corto.
    const CARBINE_TIER_ONE_BASE_WEIGHT = 12.0;
    const CARBINE_TIER_ONE_DAMAGE = 360.0;
    const CARBINE_TIER_ONE_FIRE_TICS = 48;
    const CARBINE_TIER_ONE_RANGE_METERS = 60.0;
    // Dispersión muy alta: el mínimo siempre equivale al 10% del máximo.
    const CARBINE_MINIMUM_SPREAD_DEGREES = 11.0;
    const CARBINE_MAXIMUM_SPREAD_DEGREES = 110.0;
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
    const EQUIPMENT_KIND_CONSUMABLE = 4;
    const EQUIPMENT_KIND_MATERIAL = 5;
    const EQUIPMENT_KIND_KEY = 6;
    const EQUIPMENT_KIND_KEY_ITEM = 7;
    const EQUIPMENT_KIND_COUNT = 8;
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
    const EQUIPMENT_ACTION_USED = 14;
    const EQUIPMENT_ACTION_FAILED_KEY_STORAGE = 15;
    const EQUIPMENT_ACTION_DISMANTLED = 16;
    const EQUIPMENT_ACTION_FAILED_EQUIPPED = 17;
    const EQUIPMENT_ACTION_FAILED_STORAGE = 18;
    const EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED = 19;

    // Las estaciones reales reutilizan la transacción de crafteo ya probada.
    // El índice de receta ahora es local a la estación activa.
    const CRAFTING_PLAYABLE_RECIPE_COUNT = 16;
    const CRAFTING_STATION_NONE = -1;
    const CRAFTING_STATION_FORGE = 0;
    const CRAFTING_STATION_BOW_WORKSHOP = 1;
    const CRAFTING_STATION_ARMOR_WORKSHOP = 2;
    const CRAFTING_STATION_ESSENCE_ALTAR = 3;
    const CRAFTING_STATION_WORKBENCH = 4;
    const CRAFTING_STATION_COUNT = 5;
    const CRAFTING_FORGE_RECIPE_COUNT = 12;
    const CRAFTING_BOW_WORKSHOP_RECIPE_COUNT = 3;
    const CRAFTING_ACTION_NONE = 0;
    const CRAFTING_ACTION_CREATED = 1;
    const CRAFTING_ACTION_FAILED_MATERIALS = 2;
    const CRAFTING_ACTION_FAILED_BOX_FULL = 3;
    const CRAFTING_ACTION_FAILED_DUPLICATE = 4;
    const CRAFTING_ACTION_MATERIALS_SPAWNED = 5;
    const CRAFTING_ACTION_FAILED_STATION = 6;

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
    // Los índices históricos anteriores no cambian para conservar partidas.
    const WEAPON_TYPE_DAGGER = 3;
    const WEAPON_TYPE_HATCHET = 4;
    const WEAPON_TYPE_MACHETE = 5;
    const WEAPON_TYPE_JAVELIN = 6;
    const WEAPON_TYPE_AXE = 7;
    const WEAPON_TYPE_FLAIL = 8;
    const WEAPON_TYPE_SPEAR = 9;
    const WEAPON_TYPE_GREATSWORD = 10;
    const WEAPON_TYPE_WAR_AXE = 11;
    const WEAPON_TYPE_HALBERD = 12;
    const WEAPON_TYPE_GIANT_GAUNTLETS = 13;
    const WEAPON_TYPE_STANDARD_BOW = 14;
    const WEAPON_TYPE_LONGBOW = 15;
    const WEAPON_TYPE_CROSSBOW = 16;
    const WEAPON_TYPE_BELL = 17;
    const WEAPON_TYPE_BOOK = 18;
    const WEAPON_TYPE_STATUETTE = 19;
    const WEAPON_TYPE_COUNT = 20;
    // El aviso temporal acompana al indicador permanente al cambiar de arma.
    const ACTIVE_WEAPON_NOTICE_SECONDS = 1.5;
    const WEAPON_OWNERSHIP_COUNT = 300;
    const WEAPON_SWORD_TIER_ONE_WEIGHT = 6.0;
    const WEAPON_STAFF_TIER_ONE_WEIGHT = 4.0;
    const WEAPON_CARBINE_TIER_ONE_WEIGHT = 12.0;
    const WEAPON_DAGGER_TIER_ONE_WEIGHT = 2.0;
    const WEAPON_HATCHET_TIER_ONE_WEIGHT = 3.0;
    const WEAPON_MACHETE_TIER_ONE_WEIGHT = 3.0;
    const WEAPON_JAVELIN_TIER_ONE_WEIGHT = 4.0;
    const WEAPON_AXE_TIER_ONE_WEIGHT = 8.0;
    const WEAPON_FLAIL_TIER_ONE_WEIGHT = 8.0;
    const WEAPON_SPEAR_TIER_ONE_WEIGHT = 7.0;
    const WEAPON_GREATSWORD_TIER_ONE_WEIGHT = 18.0;
    const WEAPON_WAR_AXE_TIER_ONE_WEIGHT = 20.0;
    const WEAPON_HALBERD_TIER_ONE_WEIGHT = 16.0;
    const WEAPON_GIANT_GAUNTLETS_TIER_ONE_WEIGHT = 20.0;
    const WEAPON_STANDARD_BOW_TIER_ONE_WEIGHT = 6.0;
    const WEAPON_LONGBOW_TIER_ONE_WEIGHT = 10.0;
    const WEAPON_CROSSBOW_TIER_ONE_WEIGHT = 8.0;
    const WEAPON_BELL_TIER_ONE_WEIGHT = 5.0;
    const WEAPON_BOOK_TIER_ONE_WEIGHT = 6.0;
    const WEAPON_STATUETTE_TIER_ONE_WEIGHT = 8.0;
    const WEAPON_SWORD_BASE_DURABILITY = 1000;
    const WEAPON_STAFF_BASE_DURABILITY = 800;
    const WEAPON_CARBINE_BASE_DURABILITY = 1200;
    const WEAPON_PHYSICAL_BASE_DURABILITY = 1000;
    const WEAPON_ESSENCE_BASE_DURABILITY = 800;
    const WEAPON_SWORD_ATTACK_TICS = 14;
    const WEAPON_CARBINE_STARTING_AMMO = 100;
    const AMMUNITION_CARBINE = 0;
    const AMMUNITION_ARROW = 1;
    const AMMUNITION_BOLT = 2;
    const AMMUNITION_JAVELIN_TIER_ONE = 3;
    const AMMUNITION_JAVELIN_TIER_TWO = 4;
    const AMMUNITION_JAVELIN_TIER_THREE = 5;
    // Las jabalinas ya no usan munición. Las IDs antiguas se conservan sólo
    // para compatibilidad con partidas de desarrollo anteriores, pero quedan
    // fuera del selector y de todas las rutas normales de juego.
    const AMMUNITION_TYPE_COUNT = 3;
    const CARBINE_AMMO_UNIT_WEIGHT = 0.003;
    const ARROW_AMMO_UNIT_WEIGHT = 0.05;
    const BOLT_AMMO_UNIT_WEIGHT = 0.05;
    // Valores heredados de la prueba de munición de jabalinas. Se conservan
    // sólo para compatibilidad con partidas de desarrollo anteriores.
    const JAVELIN_TIER_ONE_AMMO_UNIT_WEIGHT = 4.0;
    const JAVELIN_TIER_TWO_AMMO_UNIT_WEIGHT = 6.0;
    const JAVELIN_TIER_THREE_AMMO_UNIT_WEIGHT = 8.0;
    const WEAPON_CARBINE_PROJECTILE_SPEED = 80.0;

    // Catálogo físico 4.12. Estos identificadores describen las dieciséis
    // armas definitivas de las familias 2 a 5; el modelo jugable reducido de
    // arriba conserva sus índices para no romper partidas anteriores.
    const CATALOGUE_WEAPON_DAGGER = 0;
    const CATALOGUE_WEAPON_HATCHET = 1;
    const CATALOGUE_WEAPON_MACHETE = 2;
    const CATALOGUE_WEAPON_JAVELIN = 3;
    const CATALOGUE_WEAPON_SWORD = 4;
    const CATALOGUE_WEAPON_AXE = 5;
    const CATALOGUE_WEAPON_FLAIL = 6;
    const CATALOGUE_WEAPON_SPEAR = 7;
    const CATALOGUE_WEAPON_GREATSWORD = 8;
    const CATALOGUE_WEAPON_WAR_AXE = 9;
    const CATALOGUE_WEAPON_HALBERD = 10;
    const CATALOGUE_WEAPON_GIANT_GAUNTLETS = 11;
    const CATALOGUE_WEAPON_STANDARD_BOW = 12;
    const CATALOGUE_WEAPON_CARBINE = 13;
    const CATALOGUE_WEAPON_LONGBOW = 14;
    const CATALOGUE_WEAPON_CROSSBOW = 15;
    const CATALOGUE_PHYSICAL_WEAPON_COUNT = 16;
    const CATALOGUE_FAMILY_SMALL = 2;
    const CATALOGUE_FAMILY_ONE_HANDED = 3;
    const CATALOGUE_FAMILY_LARGE = 4;
    const CATALOGUE_FAMILY_RANGED = 5;
    const CATALOGUE_DAMAGE_NONE = 0;
    const CATALOGUE_DAMAGE_PIERCING = 1;
    const CATALOGUE_DAMAGE_SLASHING = 2;
    const CATALOGUE_DAMAGE_BLUNT = 3;
    const CATALOGUE_ACTION_THROW = 4;
    const CATALOGUE_ACTION_BLOCK = 5;

    // Consumibles 4.9. Las pilas conservan peso en el inventario personal y
    // ocupan un solo slot, con peso cero, dentro de la Caja Magica.
    const CONSUMABLE_LIFE_POTION = 0;
    const CONSUMABLE_ANIMA_POTION = 1;
    const CONSUMABLE_ENERGY_DRINK = 2;
    const CONSUMABLE_FOOD_RATION = 3;
    const CONSUMABLE_WATER_RATION = 4;
    const CONSUMABLE_TYPE_COUNT = 5;
    const CONSUMABLE_POTION_WEIGHT = 0.25;
    const CONSUMABLE_RATION_WEIGHT = 0.10;
    const CONSUMABLE_REGENERATION_SECONDS = 10;
    const CONSUMABLE_REGENERATION_PERCENT_PER_SECOND = 0.01;

    // Objetos especiales 4.10. Los materiales son pilas; las llaves y los
    // objetos clave son instancias unicas. El peso base puede sobrescribirse
    // en futuras subclases sin alterar la suma autoritativa de Actor.Inv.
    const SPECIAL_ITEM_DEFAULT_WEIGHT = 0.10;
    const MATERIAL_UNIT_WEIGHT = 0.001;
    const CRAFTING_DEFAULT_TIER_WEIGHT_RATIO = 0.70;
    const CRAFTING_ESSENCE_TIER_WEIGHT_RATIO = 0.10;
    const CRAFTING_POLEARM_TIER_WEIGHT_RATIO = 0.20;
    const CRAFTING_AXE_TIER_WEIGHT_RATIO = 0.30;
    const CRAFTING_RANGED_TIER_WEIGHT_RATIO = 0.40;
    const CRAFTING_DISMANTLE_RECOVERY_RATIO = 0.50;
    // El indice cero conserva el lingote de prueba 4.10 para no invalidar
    // partidas existentes, pero queda fuera del catálogo activo desde 4.12.
    const MATERIAL_IRON_INGOT = 0;
    const MATERIAL_FIRST_ACTIVE = 1;
    const MATERIAL_BLADE = 1;
    const MATERIAL_SMALL_BLADE = 2;
    const MATERIAL_CURVED_BLADE = 3;
    const MATERIAL_LONG_BLADE = 4;
    const MATERIAL_BROAD_BLADE = 5;
    const MATERIAL_SHAFT = 6;
    const MATERIAL_FRAME = 7;
    const MATERIAL_LONG_FRAME = 8;
    const MATERIAL_WEAPON_HEAD = 9;
    const MATERIAL_ROUND_HEAD = 10;
    const MATERIAL_PLATE = 11;
    const MATERIAL_ROUND_PLATE = 12;
    const MATERIAL_KITE_PLATE = 13;
    const MATERIAL_TOWER_PLATE = 14;
    const MATERIAL_MAGIC_PLATE = 15;
    const MATERIAL_LARGE_PLATE = 16;
    const MATERIAL_CHAINMAIL = 17;
    const MATERIAL_FABRIC = 18;
    const MATERIAL_LEATHER = 19;
    const MATERIAL_FIRE_ESSENCE = 20;
    const MATERIAL_WATER_ESSENCE = 21;
    const MATERIAL_EARTH_ESSENCE = 22;
    const MATERIAL_WIND_ESSENCE = 23;
    const MATERIAL_QUINTESSENCE = 24;
    const MATERIAL_HILT = 25;
    const MATERIAL_LONG_HILT = 26;
    const MATERIAL_POINT = 27;
    const MATERIAL_HANDLE = 28;
    const MATERIAL_LONG_HANDLE = 29;
    const MATERIAL_BOWSTRING = 30;
    const MATERIAL_REINFORCED_BOWSTRING = 31;
    const MATERIAL_STRAP = 32;
    const MATERIAL_REINFORCED_STRAP = 33;
    const MATERIAL_BARREL = 34;
    const MATERIAL_MECHANISM = 35;
    const MATERIAL_STAFF_BASE = 36;
    const MATERIAL_BELL_BASE = 37;
    const MATERIAL_BOOK_BASE = 38;
    const MATERIAL_STATUETTE_BASE = 39;
    const MATERIAL_SMALL_WEAPON_HEAD = 40;
    const MATERIAL_CHAIN = 41;
    const MATERIAL_TYPE_COUNT = 42;
    const MATERIAL_FAMILY_NONE = 0;
    const MATERIAL_FAMILY_METAL = 1;
    const MATERIAL_FAMILY_WOOD = 2;
    const MATERIAL_FAMILY_ESSENCE = 3;
    const MATERIAL_FAMILY_LEATHER = 4;
    const MATERIAL_FAMILY_FABRIC = 5;
    const KEY_SILVER = 0;
    const KEY_TYPE_COUNT = 1;
    const KEY_ITEM_SEALED_LETTER = 0;
    const KEY_ITEM_TYPE_COUNT = 1;
    const LOCK_CAELUM_SILVER = 200;

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
