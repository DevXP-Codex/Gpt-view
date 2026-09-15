-- MODULE SCRIPT -- 
local StatConfig = {}

--------------------------------------------------
-- STARTING ATTRIBUTES
--------------------------------------------------

StatConfig.STARTING_ATTRIBUTES = {
Strength = 0,
Dexterity = 0,
Intelligence = 0,
Vitality = 0,
Luck = 0
}

--------------------------------------------------
-- ATTRIBUTE POINT PROGRESSION
--------------------------------------------------

StatConfig.NORMAL_POINTS_PER_LEVEL = 5

StatConfig.BONUS_POINTS = {
[25] = 5,
[50] = 5,
[100] = 10
}

--------------------------------------------------
-- ATTRIBUTE COST
--------------------------------------------------

StatConfig.ATTRIBUTE_COST_TIERS = {
{
Min = 0,
Max = 19,
Cost = 1
},
{
Min = 20,
Max = 39,
Cost = 2
},
{
Min = 40,
Max = 59,
Cost = 3
},
{
Min = 60,
Max = 79,
Cost = 4
},
{
Min = 80,
Max = 99,
Cost = 5
},
{
Min = 100,
Max = 119,
Cost = 6
},
{
Min = 120,
Max = 139,
Cost = 7
},
{
Min = 140,
Max = 159,
Cost = 8
},
{
Min = 160,
Max = 179,
Cost = 9
},
{
Min = 180,
Max = math.huge,
Cost = 10
}
}

--------------------------------------------------
-- BASE RESOURCES
--------------------------------------------------

StatConfig.BASE_HP = 100
StatConfig.HP_PER_VIT = 12

StatConfig.BASE_MANA = 50
StatConfig.MANA_PER_INT = 8

--------------------------------------------------
-- OFFENSE
--------------------------------------------------

StatConfig.BASE_PHYSICAL_ATTACK = 10
StatConfig.PHYSICAL_ATTACK_PER_STR = 2

StatConfig.BASE_MAGIC_ATTACK = 10
StatConfig.MAGIC_ATTACK_PER_INT = 2

--------------------------------------------------
-- DEFENSE
--------------------------------------------------

StatConfig.BASE_PHYSICAL_DEFENSE = 5
StatConfig.PHYSICAL_DEFENSE_PER_VIT = 0.5

StatConfig.BASE_MAGIC_DEFENSE = 3
StatConfig.MAGIC_DEFENSE_PER_INT = 0.3
StatConfig.MAGIC_DEFENSE_PER_VIT = 0.2

--------------------------------------------------
-- ACCURACY / EVASION
--------------------------------------------------

StatConfig.BASE_ACCURACY = 90
StatConfig.ACCURACY_PER_DEX = 1

StatConfig.BASE_EVASION = 5
StatConfig.EVASION_PER_DEX = 0.5

StatConfig.MIN_HIT_CHANCE = 0.05
StatConfig.MAX_HIT_CHANCE = 0.95

--------------------------------------------------
-- SPEED
--------------------------------------------------

StatConfig.BASE_ATTACK_SPEED = 100
StatConfig.ATTACK_SPEED_PER_DEX = 0.5

StatConfig.BASE_CAST_SPEED = 100
StatConfig.CAST_SPEED_PER_INT = 0.5
StatConfig.CAST_SPEED_PER_DEX = 0.25

StatConfig.BASE_MOVEMENT_SPEED = 16
StatConfig.MOVEMENT_SPEED_PER_DEX = 0.02

--------------------------------------------------
-- CRITICAL
--------------------------------------------------

StatConfig.BASE_CRITICAL_CHANCE = 0.02
StatConfig.CRITICAL_CHANCE_PER_LUK = 0.0015

StatConfig.BASE_CRITICAL_DAMAGE = 1.50
StatConfig.CRITICAL_DAMAGE_PER_LUK = 0.0025

--------------------------------------------------
-- PERFECT DODGE
--------------------------------------------------

StatConfig.BASE_PERFECT_DODGE = 0.01
StatConfig.PERFECT_DODGE_PER_LUK = 0.0005

--------------------------------------------------
-- RECOVERY
--------------------------------------------------

StatConfig.BASE_HP_RECOVERY = 1
StatConfig.HP_RECOVERY_PER_VIT = 0.1

StatConfig.BASE_MANA_RECOVERY = 1
StatConfig.MANA_RECOVERY_PER_INT = 0.15

--------------------------------------------------
-- STATUS RESISTANCE
--------------------------------------------------

StatConfig.STATUS_RESISTANCE_PER_VIT = 0.20
StatConfig.STATUS_RESISTANCE_PER_LUK = 0.05

--------------------------------------------------
-- MOVEMENT
--------------------------------------------------

StatConfig.MIN_MOVEMENT_SPEED = 8
StatConfig.MAX_MOVEMENT_SPEED = 30

--------------------------------------------------
-- DAMAGE
--------------------------------------------------

StatConfig.MIN_DAMAGE = 1

--------------------------------------------------
-- VALID ATTRIBUTES
--------------------------------------------------

StatConfig.ATTRIBUTE_NAMES = {
"Strength",
"Dexterity",
"Intelligence",
"Vitality",
"Luck"
}

return StatConfig
