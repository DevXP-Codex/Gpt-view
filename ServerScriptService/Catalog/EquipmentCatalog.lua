-- MODULE SCRIPT -- 
--------------------------------------------------
-- YAMA: LEGENDS
-- EQUIPMENT CATALOG
--------------------------------------------------
 
local EquipmentCatalog = {
 
 
--------------------------------------------------
-- WEAPONS
--------------------------------------------------
 
Weapons = {

--------------------------------------------------
-- IRON DAGGER
--------------------------------------------------
 
IronDagger = {
 
Id = "IronDagger",
 
Name = "Iron Dagger",
 
Type = "Weapon",
 
Slot = "OffHand",
 
Occupies = {
 
"OffHand"
 
},
 
Description =
"A light dagger suitable for dual wielding.",
 
Stats = {
 
Attack = 6,
 
},
 
},
 
--------------------------------------------------
-- IRON SWORD
--------------------------------------------------
 
IronSword = {
 
Id = "IronSword",
 
Name = "Iron Sword",
 
Type = "Weapon",
 
 
--------------------------------------------------
-- EQUIPMENT SLOT
--------------------------------------------------
 
Slot = "MainHand",
 
Occupies = {
 
"MainHand"
 
},
 
 
Description =
"A basic sword for beginning adventurers.",
 
 
--------------------------------------------------
-- EQUIPMENT STATS
--------------------------------------------------
 
Stats = {
 
Attack = 10,
 
},
 
},
 
 
--------------------------------------------------
-- GREAT SWORD
--------------------------------------------------
-- Two-handed weapon.
--
-- Occupies both MainHand and OffHand.
 
GreatSword = {
 
Id = "GreatSword",
 
Name = "Great Sword",
 
Type = "Weapon",
 
 
Slot = "MainHand",
 
Occupies = {
 
"MainHand",
"OffHand"
 
},
 
 
Description =
"A heavy two-handed sword.",
 
 
--------------------------------------------------
-- EQUIPMENT STATS
--------------------------------------------------
 
Stats = {
 
Attack = 20,
 
},
 
},
 
},
 
 
--------------------------------------------------
-- ARMOR
--------------------------------------------------
 
Armor = {
 
--------------------------------------------------
-- LEATHER ARMOR
--------------------------------------------------
 
LeatherArmor = {
 
Id = "LeatherArmor",
 
Name = "Leather Armor",
 
Type = "Armor",
 
 
--------------------------------------------------
-- EQUIPMENT SLOT
--------------------------------------------------
 
Slot = "Body",
 
Occupies = {
 
"Body"
 
},
 
 
Description =
"Simple leather armor.",
 
 
--------------------------------------------------
-- EQUIPMENT STATS
--------------------------------------------------
 
Stats = {
 
Defense = 5,
 
},
 
},
 
},
 
 
--------------------------------------------------
-- ACCESSORIES
--------------------------------------------------
 
Accessories = {
 
-- Future equipment goes here.
 
},
 
 
--------------------------------------------------
-- SHIELDS
--------------------------------------------------
 
Shields = {
 
--------------------------------------------------
-- WOODEN SHIELD
--------------------------------------------------
 
WoodenShield = {
 
Id = "WoodenShield",
 
Name = "Wooden Shield",
 
Type = "Shield",
 
 
Slot = "OffHand",
 
Occupies = {
 
"OffHand"
 
},
 
 
Description =
"A simple wooden shield.",
 
 
--------------------------------------------------
-- EQUIPMENT STATS
--------------------------------------------------
 
Stats = {
 
Defense = 5,
 
},
 
},
 
},
 
}
 
 
return EquipmentCatalog
