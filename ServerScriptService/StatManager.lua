-- MODULE SCRIPT -- 

local StatManager = {}

local StatConfig = require(script.Parent.StatConfig)

--------------------------------------------------
-- INTERNAL HELPERS
--------------------------------------------------

local function round(value)
    return math.floor(value + 0.5)
end

local function getNumber(value, default)
    if typeof(value) ~= "number" then
        return default
    end
    
    return value
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

--------------------------------------------------
-- CREATE DEFAULT ATTRIBUTES
--------------------------------------------------

function StatManager.CreateDefaultAttributes()
    
    return {
    Strength = StatConfig.STARTING_ATTRIBUTES.Strength,
    Dexterity = StatConfig.STARTING_ATTRIBUTES.Dexterity,
    Intelligence = StatConfig.STARTING_ATTRIBUTES.Intelligence,
    Vitality = StatConfig.STARTING_ATTRIBUTES.Vitality,
    Luck = StatConfig.STARTING_ATTRIBUTES.Luck
    }
    
end

--------------------------------------------------
-- NORMALIZE ATTRIBUTES
--------------------------------------------------

function StatManager.NormalizeAttributes(attributes)
    
    if typeof(attributes) ~= "table" then
        attributes = {}
    end
    
    local defaults = StatConfig.STARTING_ATTRIBUTES
    
    for _, attributeName in ipairs(StatConfig.ATTRIBUTE_NAMES) do
        
        local value = tonumber(attributes[attributeName])
        
        if not value then
            value = defaults[attributeName]
        end
        
        value = math.floor(value)
        
        if value < 0 then
            value = 0
        end
        
        attributes[attributeName] = value
        
    end
    
    return attributes
    
end

--------------------------------------------------
-- GET ATTRIBUTE
--------------------------------------------------

function StatManager.GetAttribute(character, attributeName)
    
    if not character then
        return 0
    end
    
    if typeof(attributeName) ~= "string" then
        return 0
    end
    
    character.Attributes =
    StatManager.NormalizeAttributes(
    character.Attributes
    )
    
    return character.Attributes[attributeName] or 0
    
end

--------------------------------------------------
-- GET ALL ATTRIBUTES
--------------------------------------------------

function StatManager.GetAttributes(character)
    
    if not character then
        return StatManager.CreateDefaultAttributes()
    end
    
    character.Attributes =
    StatManager.NormalizeAttributes(
    character.Attributes
    )
    
    return character.Attributes
    
end

--------------------------------------------------
-- ATTRIBUTE COST
--------------------------------------------------

function StatManager.GetAttributeCost(currentValue)
    
    currentValue = tonumber(currentValue) or 0
    currentValue = math.floor(currentValue)
    
    if currentValue < 0 then
        currentValue = 0
    end
    
    for _, tier in ipairs(
        StatConfig.ATTRIBUTE_COST_TIERS
        ) do
        
        if currentValue >= tier.Min
            and currentValue <= tier.Max then
            
            return tier.Cost
            
        end
        
    end
    
    return 10
end

--------------------------------------------------
-- ATTRIBUTE POINTS EARNED AT LEVEL
--------------------------------------------------

function StatManager.GetPointsEarnedAtLevel(level)
    
    level = tonumber(level) or 1
    level = math.max(1, math.floor(level))
    
    local points =
    (level - 1)
    * StatConfig.NORMAL_POINTS_PER_LEVEL
    
    for requiredLevel, bonus in pairs(
        StatConfig.BONUS_POINTS
        ) do
        
        if level >= requiredLevel then
            points += bonus
        end
        
    end
    
    return points
    
end

--------------------------------------------------
-- ATTRIBUTE POINTS FROM LEVEL
--------------------------------------------------

function StatManager.GetTotalEarnedPoints(level)
    
    return StatManager.GetPointsEarnedAtLevel(level)
    
end

--------------------------------------------------
-- INITIAL ATTRIBUTE POINTS
--------------------------------------------------

function StatManager.GetStartingAttributeTotal()
    
    local total = 0
    
    for _, attributeName in ipairs(
        StatConfig.ATTRIBUTE_NAMES
        ) do
        
        total +=
        StatConfig.STARTING_ATTRIBUTES[
        attributeName
        ]
        
    end
    
    return total
    
end

--------------------------------------------------
-- ADD ATTRIBUTE POINTS
--------------------------------------------------

function StatManager.AddAttributePoints(
    character,
    amount
    )
    
    if not character then
        return false
    end
    
    amount = tonumber(amount)
    
    if not amount then
        return false
    end
    
    amount = math.floor(amount)
    
    if amount < 1 then
        return false
    end
    
    character.AttributePoints =
    tonumber(character.AttributePoints)
    or 0
    
    character.AttributePoints += amount
    
    return true
    
end

--------------------------------------------------
-- SPEND ATTRIBUTE POINT
--------------------------------------------------

function StatManager.IncreaseAttribute(
    character,
    attributeName
    )
    
    if not character then
        return false, "INVALID_CHARACTER"
    end
    
    if typeof(attributeName) ~= "string" then
        return false, "INVALID_ATTRIBUTE"
    end
    
    if not table.find(
        StatConfig.ATTRIBUTE_NAMES,
        attributeName
        ) then
        
        return false, "INVALID_ATTRIBUTE"
        
    end
    
    character.Attributes =
    StatManager.NormalizeAttributes(
    character.Attributes
    )
    
    character.AttributePoints =
    tonumber(character.AttributePoints)
    or 0
    
    local currentValue =
    character.Attributes[attributeName]
    
    local cost =
    StatManager.GetAttributeCost(
    currentValue
    )
    
    if character.AttributePoints < cost then
        return false, "NOT_ENOUGH_POINTS"
    end
    
    character.AttributePoints -= cost
    
    character.Attributes[attributeName] =
    currentValue + 1
    
    return true, {
    Attribute = attributeName,
    OldValue = currentValue,
    NewValue = currentValue + 1,
    Cost = cost,
    RemainingPoints =
    character.AttributePoints
    }
    
end

--------------------------------------------------
-- GET NEXT ATTRIBUTE COST
--------------------------------------------------

function StatManager.GetNextAttributeCost(
    character,
    attributeName
    )
    
    local value =
    StatManager.GetAttribute(
    character,
    attributeName
    )
    
    return StatManager.GetAttributeCost(value)
    
end

--------------------------------------------------
-- MAX HP
--------------------------------------------------

function StatManager.CalculateMaxHP(
    character
    )
    
    local vit =
    StatManager.GetAttribute(
    character,
    "Vitality"
    )
    
    return math.floor(
    StatConfig.BASE_HP
    +
    vit
    * StatConfig.HP_PER_VIT
    )
    
end

--------------------------------------------------
-- MAX MANA
--------------------------------------------------

function StatManager.CalculateMaxMana(
    character
    )
    
    local int =
    StatManager.GetAttribute(
    character,
    "Intelligence"
    )
    
    return math.floor(
    StatConfig.BASE_MANA
    +
    int
    * StatConfig.MANA_PER_INT
    )
    
end

--------------------------------------------------
-- PHYSICAL ATTACK
--------------------------------------------------

function StatManager.CalculatePhysicalAttack(
    character,
    equipmentAttack
    )
    
    local str =
    StatManager.GetAttribute(
    character,
    "Strength"
    )
    
    equipmentAttack =
    tonumber(equipmentAttack)
    or 0
    
    return math.floor(
    StatConfig.BASE_PHYSICAL_ATTACK
    +
    str
    * StatConfig.PHYSICAL_ATTACK_PER_STR
    +
    equipmentAttack
    )
    
end

--------------------------------------------------
-- MAGIC ATTACK
--------------------------------------------------

function StatManager.CalculateMagicAttack(
    character,
    equipmentMagicAttack
    )
    
    local int =
    StatManager.GetAttribute(
    character,
    "Intelligence"
    )
    
    equipmentMagicAttack =
    tonumber(equipmentMagicAttack)
    or 0
    
    return math.floor(
    StatConfig.BASE_MAGIC_ATTACK
    +
    int
    * StatConfig.MAGIC_ATTACK_PER_INT
    +
    equipmentMagicAttack
    )
    
end

--------------------------------------------------
-- PHYSICAL DEFENSE
--------------------------------------------------

function StatManager.CalculatePhysicalDefense(
    character,
    equipmentDefense
    )
    
    local vit =
    StatManager.GetAttribute(
    character,
    "Vitality"
    )
    
    equipmentDefense =
    tonumber(equipmentDefense)
    or 0
    
    return
    StatConfig.BASE_PHYSICAL_DEFENSE
    +
    vit
    * StatConfig.PHYSICAL_DEFENSE_PER_VIT
    +
    equipmentDefense
    
end

--------------------------------------------------
-- MAGIC DEFENSE
--------------------------------------------------

function StatManager.CalculateMagicDefense(
    character,
    equipmentMagicDefense
    )
    
    local int =
    StatManager.GetAttribute(
    character,
    "Intelligence"
    )
    
    local vit =
    StatManager.GetAttribute(
    character,
    "Vitality"
    )
    
    equipmentMagicDefense =
    tonumber(equipmentMagicDefense)
    or 0
    
    return
    StatConfig.BASE_MAGIC_DEFENSE
    +
    int
    * StatConfig.MAGIC_DEFENSE_PER_INT
    +
    vit
    * StatConfig.MAGIC_DEFENSE_PER_VIT
    +
    equipmentMagicDefense
    
end

--------------------------------------------------
-- ACCURACY
--------------------------------------------------

function StatManager.CalculateAccuracy(
    character,
    equipmentAccuracy
    )
    
    local dex =
    StatManager.GetAttribute(
    character,
    "Dexterity"
    )
    
    equipmentAccuracy =
    tonumber(equipmentAccuracy)
    or 0
    
    return
    StatConfig.BASE_ACCURACY
    +
    dex
    * StatConfig.ACCURACY_PER_DEX
    +
    equipmentAccuracy
    
end

--------------------------------------------------
-- EVASION
--------------------------------------------------

function StatManager.CalculateEvasion(
    character,
    equipmentEvasion
    )
    
    local dex =
    StatManager.GetAttribute(
    character,
    "Dexterity"
    )
    
    equipmentEvasion =
    tonumber(equipmentEvasion)
    or 0
    
    return
    StatConfig.BASE_EVASION
    +
    dex
    * StatConfig.EVASION_PER_DEX
    +
    equipmentEvasion
    
end

--------------------------------------------------
-- ATTACK SPEED
--------------------------------------------------

function StatManager.CalculateAttackSpeed(
    character,
    equipmentAttackSpeed
    )
    
    local dex =
    StatManager.GetAttribute(
    character,
    "Dexterity"
    )
    
    equipmentAttackSpeed =
    tonumber(equipmentAttackSpeed)
    or 0
    
    return
    StatConfig.BASE_ATTACK_SPEED
    +
    dex
    * StatConfig.ATTACK_SPEED_PER_DEX
    +
    equipmentAttackSpeed
    
end

--------------------------------------------------
-- CAST SPEED
--------------------------------------------------

function StatManager.CalculateCastSpeed(
    character,
    equipmentCastSpeed
    )
    
    local int =
    StatManager.GetAttribute(
    character,
    "Intelligence"
    )
    
    local dex =
    StatManager.GetAttribute(
    character,
    "Dexterity"
    )
    
    equipmentCastSpeed =
    tonumber(equipmentCastSpeed)
    or 0
    
    return
    StatConfig.BASE_CAST_SPEED
    +
    int
    * StatConfig.CAST_SPEED_PER_INT
    +
    dex
    * StatConfig.CAST_SPEED_PER_DEX
    +
    equipmentCastSpeed
    
end

--------------------------------------------------
-- CRITICAL CHANCE
--------------------------------------------------

function StatManager.CalculateCriticalChance(
    character,
    equipmentCriticalChance
    )
    
    local luk =
    StatManager.GetAttribute(
    character,
    "Luck"
    )
    
    equipmentCriticalChance =
    tonumber(equipmentCriticalChance)
    or 0
    
    return clamp(
    StatConfig.BASE_CRITICAL_CHANCE
    +
    luk
    * StatConfig.CRITICAL_CHANCE_PER_LUK
    +
    equipmentCriticalChance,
    0,
    0.95
    )
    
end

--------------------------------------------------
-- CRITICAL DAMAGE
--------------------------------------------------

function StatManager.CalculateCriticalDamage(
    character,
    equipmentCriticalDamage
    )
    
    local luk =
    StatManager.GetAttribute(
    character,
    "Luck"
    )
    
    equipmentCriticalDamage =
    tonumber(equipmentCriticalDamage)
    or 0
    
    return
    StatConfig.BASE_CRITICAL_DAMAGE
    +
    luk
    * StatConfig.CRITICAL_DAMAGE_PER_LUK
    +
    equipmentCriticalDamage
    
end

--------------------------------------------------
-- PERFECT DODGE
--------------------------------------------------

function StatManager.CalculatePerfectDodge(
    character,
    equipmentPerfectDodge
    )
    
    local luk =
    StatManager.GetAttribute(
    character,
    "Luck"
    )
    
    equipmentPerfectDodge =
    tonumber(equipmentPerfectDodge)
    or 0
    
    return clamp(
    StatConfig.BASE_PERFECT_DODGE
    +
    luk
    * StatConfig.PERFECT_DODGE_PER_LUK
    +
    equipmentPerfectDodge,
    0,
    0.50
    )
    
end

--------------------------------------------------
-- HP RECOVERY
--------------------------------------------------

function StatManager.CalculateHPRecovery(character)
    
    local vit =
    StatManager.GetAttribute(
    character,
    "Vitality"
    )
    
    return
    StatConfig.BASE_HP_RECOVERY
    +
    vit * StatConfig.HP_RECOVERY_PER_VIT
    
end

--------------------------------------------------
-- MANA RECOVERY
--------------------------------------------------

function StatManager.CalculateManaRecovery(character)
    
    local int =
    StatManager.GetAttribute(
    character,
    "Intelligence"
    )
    
    return
    StatConfig.BASE_MANA_RECOVERY
    +
    int * StatConfig.MANA_RECOVERY_PER_INT
    
end

--------------------------------------------------
-- STATUS RESISTANCE
--------------------------------------------------

function StatManager.CalculateStatusResistance(
    character,
    equipmentStatusResistance
    )
    
    local vit =
    StatManager.GetAttribute(
    character,
    "Vitality"
    )
    
    local luk =
    StatManager.GetAttribute(
    character,
    "Luck"
    )
    
    equipmentStatusResistance =
    tonumber(equipmentStatusResistance)
    or 0
    
    return
    vit
    * StatConfig.STATUS_RESISTANCE_PER_VIT
    +
    luk
    * StatConfig.STATUS_RESISTANCE_PER_LUK
    +
    equipmentStatusResistance
    
end

--------------------------------------------------
-- MOVEMENT SPEED
--------------------------------------------------

function StatManager.CalculateMovementSpeed(
    character,
    equipmentMovementSpeed
    )
    
    local dex =
    StatManager.GetAttribute(
    character,
    "Dexterity"
    )
    
    equipmentMovementSpeed =
    tonumber(equipmentMovementSpeed)
    or 0
    
    return clamp(
    StatConfig.BASE_MOVEMENT_SPEED
    +
    dex
    * StatConfig.MOVEMENT_SPEED_PER_DEX
    +
    equipmentMovementSpeed,
    StatConfig.MIN_MOVEMENT_SPEED,
    StatConfig.MAX_MOVEMENT_SPEED
    )
    
end

--------------------------------------------------
-- GET ALL DERIVED STATS
--------------------------------------------------

function StatManager.GetDerivedStats(
    character,
    bonuses
    )
    
    bonuses = bonuses or {}
    
    local stats = {}
    
    stats.MaxHP =
    StatManager.CalculateMaxHP(character)
    
    stats.MaxMana =
    StatManager.CalculateMaxMana(character)
    
    stats.PhysicalAttack =
    StatManager.CalculatePhysicalAttack(
    character,
    bonuses.Attack
    )
    
    stats.MagicAttack =
    StatManager.CalculateMagicAttack(
    character,
    bonuses.MagicAttack
    )
    
    stats.PhysicalDefense =
    StatManager.CalculatePhysicalDefense(
    character,
    bonuses.Defense
    )
    
    stats.MagicDefense =
    StatManager.CalculateMagicDefense(
    character,
    bonuses.MagicDefense
    )
    
    stats.Accuracy =
    StatManager.CalculateAccuracy(
    character,
    bonuses.Accuracy
    )
    
    stats.Evasion =
    StatManager.CalculateEvasion(
    character,
    bonuses.Evasion
    )
    
    stats.AttackSpeed =
    StatManager.CalculateAttackSpeed(
    character,
    bonuses.AttackSpeed
    )
    
    stats.CastSpeed =
    StatManager.CalculateCastSpeed(
    character,
    bonuses.CastSpeed
    )
    
    stats.CriticalChance =
    StatManager.CalculateCriticalChance(
    character,
    bonuses.CriticalChance
    )
    
    stats.CriticalDamage =
    StatManager.CalculateCriticalDamage(
    character,
    bonuses.CriticalDamage
    )
    
    stats.PerfectDodge =
    StatManager.CalculatePerfectDodge(
    character,
    bonuses.PerfectDodge
    )
    
    stats.HPRecovery =
    StatManager.CalculateHPRecovery(
    character
    )
    
    stats.ManaRecovery =
    StatManager.CalculateManaRecovery(
    character
    )
    
    stats.StatusResistance =
    StatManager.CalculateStatusResistance(
    character,
    bonuses.StatusResistance
    )
    
    stats.MovementSpeed =
    StatManager.CalculateMovementSpeed(
    character,
    bonuses.MovementSpeed
    )
    
    return stats
    
end

--------------------------------------------------
-- PHYSICAL DAMAGE
--------------------------------------------------

function StatManager.CalculatePhysicalDamage(
    physicalAttack,
    physicalDefense
    )
    
    physicalAttack =
    tonumber(physicalAttack)
    or 0
    
    physicalDefense =
    tonumber(physicalDefense)
    or 0
    
    local multiplier =
    100 / (100 + math.max(0, physicalDefense))
    
    local damage =
    physicalAttack * multiplier
    
    return math.max(
    StatConfig.MIN_DAMAGE,
    math.floor(damage + 0.5)
    )
    
end

--------------------------------------------------
-- MAGIC DAMAGE
--------------------------------------------------

function StatManager.CalculateMagicDamage(
    magicAttack,
    skillPower,
    magicDefense
    )
    
    magicAttack =
    tonumber(magicAttack)
    or 0
    
    skillPower =
    tonumber(skillPower)
    or 1
    
    magicDefense =
    tonumber(magicDefense)
    or 0
    
    local multiplier =
    100 / (100 + math.max(0, magicDefense))
    
    local damage =
    magicAttack
    * skillPower
    * multiplier
    
    return math.max(
    StatConfig.MIN_DAMAGE,
    math.floor(damage + 0.5)
    )
    
end

--------------------------------------------------
-- HIT CHANCE
--------------------------------------------------

function StatManager.CalculateHitChance(
    accuracy,
    evasion
    )
    
    accuracy =
    math.max(
    0,
    tonumber(accuracy) or 0
    )
    
    evasion =
    math.max(
    0,
    tonumber(evasion) or 0
    )
    
    local chance
    
    if accuracy + evasion <= 0 then
        chance = 1
    else
        chance =
        accuracy
        /
        (accuracy + evasion)
    end
    
    return clamp(
    chance,
    StatConfig.MIN_HIT_CHANCE,
    StatConfig.MAX_HIT_CHANCE
    )
    
end

--------------------------------------------------
-- ROLL HIT
--------------------------------------------------

function StatManager.RollHit(
    accuracy,
    evasion
    )
    
    local chance =
    StatManager.CalculateHitChance(
    accuracy,
    evasion
    )
    
    return math.random() <= chance
    
end

--------------------------------------------------
-- ROLL PERFECT DODGE
--------------------------------------------------

function StatManager.RollPerfectDodge(
    perfectDodge
    )
    
    perfectDodge =
    clamp(
    tonumber(perfectDodge) or 0,
    0,
    0.50
    )
    
    return math.random() <= perfectDodge
    
end

return StatManager
