--- MODULE SCRIPT --
---
 
-- YAMA: LEGENDS
-- COSMETIC CATALOG
-------------------
 
local CosmeticCatalog = {
 

--------------------------------------------------
-- HAIR
--------------------------------------------------
 
Hair = {
 
Warrior_Hair = {
 
Id = "Warrior_Hair",
 
Name = "Warrior Hair",
 
Type = "Hair",
 
Slot = "Hair",
 
Cosmetic = true,
 
 
--------------------------------------------------
-- APPEARANCE
--------------------------------------------------
-- Visual properties used by
-- HumanoidDescription.
--
-- Slot = "Hair" is the logical YAMA slot.
-- HairAccessory is the Roblox visual property.
 
Appearance = {
 
HairAccessory =
"102535903158992"
 
},
 
},
 
},
 
 
--------------------------------------------------
-- WEAPON SKINS
--------------------------------------------------
 
WeaponSkins = {
 
-- Future cosmetic weapon skins go here.
--
-- Example:
--
-- FireSword = {
--
--     Id = "FireSword",
--
--     Name = "Flaming Sword",
--
--     Type = "WeaponSkin",
--
--     Slot = "Weapon",
--
--     Cosmetic = true,
--
--     Appearance = {
--
--         Model = "FireSword_Model"
--     }
--
-- },
 
},
 
 
--------------------------------------------------
-- ARMOR SKINS
--------------------------------------------------
 
ArmorSkins = {
 
-- Future cosmetic armor skins go here.
 
},
 
 
--------------------------------------------------
-- VISUAL EFFECTS
--------------------------------------------------
 
Effects = {
 
-- Future visual effects go here.
 
},

 
}
 
return CosmeticCatalog
