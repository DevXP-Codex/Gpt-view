-- MODULE SCRIPT -- 
-- YAMA: LEGENDS
-- EQUIPMENT CATALOG - PHASE 1

local EquipmentCatalog = {
    Weapons = {},
    Armor = {},
    Shields = {},
    Accessories = {},
}

local function weapon(id, name, weaponType, slots, appearanceId, stats)
    return {
        Id = id,
        Name = name,
        Type = "Weapon",
        WeaponType = weaponType,
        Slot = slots[1],
        Occupies = slots,
        AppearanceId = appearanceId,
        Stats = stats or {},
    }
end

local function armor(id, name, armorType, slot, appearanceId, stats)
    return {
        Id = id,
        Name = name,
        Type = "Armor",
        ArmorType = armorType,
        Slot = slot,
        Occupies = {slot},
        AppearanceId = appearanceId,
        Stats = stats or {},
    }
end

local function shield(id, name, appearanceId, stats)
    return {
        Id = id,
        Name = name,
        Type = "Shield",
        Slot = "OffHand",
        Occupies = {"OffHand"},
        AppearanceId = appearanceId,
        Stats = stats or {},
    }
end

-- Compatibility names already present in the project.
EquipmentCatalog.Weapons.IronDagger = weapon(
    "IronDagger", "Iron Dagger", "Dagger", {"MainHand"}, "Dagger_Common_01", {Attack = 6}
)

EquipmentCatalog.Weapons.IronSword = weapon(
    "IronSword", "Iron Sword", "Sword", {"MainHand"}, "Sword_Common_01", {Attack = 10}
)

EquipmentCatalog.Weapons.GreatSword = weapon(
    "GreatSword", "Great Sword", "Greatsword", {"MainHand", "OffHand"}, "Greatsword_Common_01", {Attack = 20}
)

-- Testable library entries.
EquipmentCatalog.Weapons.Knife_C = weapon("Knife_C", "Common Knife", "Knife", {"MainHand"}, "Knife_Common_01", {Attack = 5})
EquipmentCatalog.Weapons.Knife_U = weapon("Knife_U", "Uncommon Knife", "Knife", {"MainHand"}, "Knife_Uncommon_01", {Attack = 8, AttackSpeed = 2})
EquipmentCatalog.Weapons.Knife_R = weapon("Knife_R", "Rare Knife", "Knife", {"MainHand"}, "Knife_Rare_01", {Attack = 12, AttackSpeed = 4})

EquipmentCatalog.Weapons.Sword_C = weapon("Sword_C", "Common Sword", "Sword", {"MainHand"}, "Sword_Common_01", {Attack = 10})
EquipmentCatalog.Weapons.Sword_U = weapon("Sword_U", "Uncommon Sword", "Sword", {"MainHand"}, "Sword_Uncommon_01", {Attack = 16, AttackSpeed = 2})
EquipmentCatalog.Weapons.Sword_R = weapon("Sword_R", "Rare Sword", "Sword", {"MainHand"}, "Sword_Rare_01", {Attack = 24, AttackSpeed = 4})

EquipmentCatalog.Weapons.TwoHandSword_C = weapon("TwoHandSword_C", "Common Greatsword", "Greatsword", {"MainHand", "OffHand"}, "Greatsword_Common_01", {Attack = 20})
EquipmentCatalog.Weapons.TwoHandSword_U = weapon("TwoHandSword_U", "Uncommon Greatsword", "Greatsword", {"MainHand", "OffHand"}, "Greatsword_Uncommon_01", {Attack = 30, AttackSpeed = 1})
EquipmentCatalog.Weapons.TwoHandSword_R = weapon("TwoHandSword_R", "Rare Greatsword", "Greatsword", {"MainHand", "OffHand"}, "Greatsword_Rare_01", {Attack = 45})

EquipmentCatalog.Weapons.Axe_C = weapon("Axe_C", "Common Axe", "Axe", {"MainHand"}, "Axe_Common_01", {Attack = 12})
EquipmentCatalog.Weapons.Axe_U = weapon("Axe_U", "Uncommon Axe", "Axe", {"MainHand"}, "Axe_Uncommon_01", {Attack = 20})
EquipmentCatalog.Weapons.Axe_R = weapon("Axe_R", "Rare Axe", "Axe", {"MainHand"}, "Axe_Rare_01", {Attack = 30})

EquipmentCatalog.Weapons.TwoHandAxe_C = weapon("TwoHandAxe_C", "Common Greataxe", "Greataxe", {"MainHand", "OffHand"}, "Greataxe_Common_01", {Attack = 25})
EquipmentCatalog.Weapons.TwoHandAxe_U = weapon("TwoHandAxe_U", "Uncommon Greataxe", "Greataxe", {"MainHand", "OffHand"}, "Greataxe_Uncommon_01", {Attack = 38})
EquipmentCatalog.Weapons.TwoHandAxe_R = weapon("TwoHandAxe_R", "Rare Greataxe", "Greataxe", {"MainHand", "OffHand"}, "Greataxe_Rare_01", {Attack = 55})

EquipmentCatalog.Weapons.Dagger_C = weapon("Dagger_C", "Common Dagger", "Dagger", {"MainHand"}, "Dagger_Common_01", {Attack = 7})
EquipmentCatalog.Weapons.Dagger_U = weapon("Dagger_U", "Uncommon Dagger", "Dagger", {"MainHand"}, "Dagger_Uncommon_01", {Attack = 11, AttackSpeed = 3})
EquipmentCatalog.Weapons.Dagger_R = weapon("Dagger_R", "Rare Dagger", "Dagger", {"MainHand"}, "Dagger_Rare_01", {Attack = 16, AttackSpeed = 5})

EquipmentCatalog.Weapons.Bow_C = weapon("Bow_C", "Common Bow", "Bow", {"MainHand", "OffHand"}, "Bow_Common_01", {Attack = 10})
EquipmentCatalog.Weapons.Bow_U = weapon("Bow_U", "Uncommon Bow", "Bow", {"MainHand", "OffHand"}, "Bow_Uncommon_01", {Attack = 17})
EquipmentCatalog.Weapons.Bow_R = weapon("Bow_R", "Rare Bow", "Bow", {"MainHand", "OffHand"}, "Bow_Rare_01", {Attack = 25})

EquipmentCatalog.Weapons.Crossbow_C = weapon("Crossbow_C", "Common Crossbow", "Crossbow", {"MainHand", "OffHand"}, "Crossbow_Common_01", {Attack = 14})
EquipmentCatalog.Weapons.Crossbow_U = weapon("Crossbow_U", "Uncommon Crossbow", "Crossbow", {"MainHand", "OffHand"}, "Crossbow_Uncommon_01", {Attack = 22})
EquipmentCatalog.Weapons.Crossbow_R = weapon("Crossbow_R", "Rare Crossbow", "Crossbow", {"MainHand", "OffHand"}, "Crossbow_Rare_01", {Attack = 32})

EquipmentCatalog.Weapons.Mace_C = weapon("Mace_C", "Common Mace", "Mace", {"MainHand"}, "Mace_Common_01", {Attack = 13})
EquipmentCatalog.Weapons.Mace_U = weapon("Mace_U", "Uncommon Mace", "Mace", {"MainHand"}, "Mace_Uncommon_01", {Attack = 21})
EquipmentCatalog.Weapons.Mace_R = weapon("Mace_R", "Rare Mace", "Mace", {"MainHand"}, "Mace_Rare_01", {Attack = 31})

EquipmentCatalog.Weapons.Staff_C = weapon("Staff_C", "Common Staff", "Staff", {"MainHand"}, "Staff_Common_01", {Attack = 10})
EquipmentCatalog.Weapons.Staff_U = weapon("Staff_U", "Uncommon Staff", "Staff", {"MainHand"}, "Staff_Uncommon_01", {Attack = 18})
EquipmentCatalog.Weapons.Staff_R = weapon("Staff_R", "Rare Staff", "Staff", {"MainHand"}, "Staff_Rare_01", {Attack = 28})

EquipmentCatalog.Weapons.Wand_C = weapon("Wand_C", "Common Wand", "Wand", {"MainHand"}, "Wand_Common_01", {Attack = 8})
EquipmentCatalog.Weapons.Wand_U = weapon("Wand_U", "Uncommon Wand", "Wand", {"MainHand"}, "Wand_Uncommon_01", {Attack = 14, AttackSpeed = 2})
EquipmentCatalog.Weapons.Wand_R = weapon("Wand_R", "Rare Wand", "Wand", {"MainHand"}, "Wand_Rare_01", {Attack = 22, AttackSpeed = 4})

EquipmentCatalog.Armor.LeatherArmor_C = armor("LeatherArmor_C", "Common Leather Armor", "Leather", "Body", "Leather_Common_01", {Defense = 5})
EquipmentCatalog.Armor.LeatherArmor_U = armor("LeatherArmor_U", "Uncommon Leather Armor", "Leather", "Body", "Leather_Uncommon_01", {Defense = 8})
EquipmentCatalog.Armor.LeatherArmor_R = armor("LeatherArmor_R", "Rare Leather Armor", "Leather", "Body", "Leather_Rare_01", {Defense = 12})

EquipmentCatalog.Armor.Armor_C = armor("Armor_C", "Common Armor", "Medium", "Body", "Armor_Common_01", {Defense = 8})
EquipmentCatalog.Armor.Armor_U = armor("Armor_U", "Uncommon Armor", "Medium", "Body", "Armor_Uncommon_01", {Defense = 13})
EquipmentCatalog.Armor.Armor_R = armor("Armor_R", "Rare Armor", "Medium", "Body", "Armor_Rare_01", {Defense = 20})

EquipmentCatalog.Armor.HeavyArmor_C = armor("HeavyArmor_C", "Common Heavy Armor", "Heavy", "Body", "Heavy_Common_01", {Defense = 14})
EquipmentCatalog.Armor.HeavyArmor_U = armor("HeavyArmor_U", "Uncommon Heavy Armor", "Heavy", "Body", "Heavy_Uncommon_01", {Defense = 22})
EquipmentCatalog.Armor.HeavyArmor_R = armor("HeavyArmor_R", "Rare Heavy Armor", "Heavy", "Body", "Heavy_Rare_01", {Defense = 32})

EquipmentCatalog.Armor.Robe_C = armor("Robe_C", "Common Robe", "Robe", "Body", "Robe_Common_01", {Defense = 4})
EquipmentCatalog.Armor.Robe_U = armor("Robe_U", "Uncommon Robe", "Robe", "Body", "Robe_Uncommon_01", {Defense = 7})
EquipmentCatalog.Armor.Robe_R = armor("Robe_R", "Rare Robe", "Robe", "Body", "Robe_Rare_01", {Defense = 11})

EquipmentCatalog.Armor.Pants_C = armor("Pants_C", "Common Pants", "Pants", "Legs", "Pants_Common_01", {Defense = 2})
EquipmentCatalog.Armor.Pants_U = armor("Pants_U", "Uncommon Pants", "Pants", "Legs", "Pants_Uncommon_01", {Defense = 4})
EquipmentCatalog.Armor.Pants_R = armor("Pants_R", "Rare Pants", "Pants", "Legs", "Pants_Rare_01", {Defense = 7})

EquipmentCatalog.Armor.ArmorLegs_C = armor("ArmorLegs_C", "Common Armor Legs", "ArmorLegs", "Legs", "ArmorLegs_Common_01", {Defense = 6})
EquipmentCatalog.Armor.ArmorLegs_U = armor("ArmorLegs_U", "Uncommon Armor Legs", "ArmorLegs", "Legs", "ArmorLegs_Uncommon_01", {Defense = 10})
EquipmentCatalog.Armor.ArmorLegs_R = armor("ArmorLegs_R", "Rare Armor Legs", "ArmorLegs", "Legs", "ArmorLegs_Rare_01", {Defense = 15})

EquipmentCatalog.Shields.WoodenShield = shield("WoodenShield", "Wooden Shield", "WoodShield_Common_01", {Defense = 5})
EquipmentCatalog.Shields.WoodShield_C = shield("WoodShield_C", "Common Wooden Shield", "WoodShield_Common_01", {Defense = 5})
EquipmentCatalog.Shields.WoodShield_U = shield("WoodShield_U", "Uncommon Wooden Shield", "WoodShield_Uncommon_01", {Defense = 8})
EquipmentCatalog.Shields.WoodShield_R = shield("WoodShield_R", "Rare Wooden Shield", "WoodShield_Rare_01", {Defense = 12})
EquipmentCatalog.Shields.IronShield_C = shield("IronShield_C", "Common Iron Shield", "IronShield_Common_01", {Defense = 10})
EquipmentCatalog.Shields.IronShield_U = shield("IronShield_U", "Uncommon Iron Shield", "IronShield_Uncommon_01", {Defense = 16})
EquipmentCatalog.Shields.IronShield_R = shield("IronShield_R", "Rare Iron Shield", "IronShield_Rare_01", {Defense = 24})

return EquipmentCatalog
