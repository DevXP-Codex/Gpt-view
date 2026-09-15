-- MODULE SCRIPT -- 
--------------------------------------------------
-- YAMA: LEGENDS
-- DEFAULT APPEARANCE CATALOG
--------------------------------------------------

local DefaultAppearanceCatalog = {

--------------------------------------------------
-- ADVENTURER DEFAULT CLOTHING
--------------------------------------------------
-- Set the final classic Shirt/Pants asset IDs here.
-- 0 means no clothing is applied yet.

AdventurerDefaultClothing = {
Shirt = 1971990335,
Pants = 1971997787,
},

--------------------------------------------------
-- ADVENTURER
--------------------------------------------------

Adventurer = {

Body = "Adventurer_Default",
Hair = "Pal_Hair",
Face = "Default",
Shirt = "Adventurer_Default",
Pants = "Adventurer_Default"

},

--------------------------------------------------
-- SWORDSMAN
--------------------------------------------------

Swordsman = {

Body = "Swordsman_Default",
Hair = "Pal_Hair",
Face = "Default",
Shirt = "Default",
Pants = "Default"

},

--------------------------------------------------
-- ARCHER
--------------------------------------------------

Archer = {

Body = "Archer_Default",
Hair = "Pal_Hair",
Face = "Default",
Shirt = "Default",
Pants = "Default"

},

--------------------------------------------------
-- MAGE
--------------------------------------------------

Mage = {

Body = "Mage_Default",
Hair = "Pal_Hair",
Face = "Default",
Shirt = "Default",
Pants = "Default"

},

--------------------------------------------------
-- CREATION LOOKS
--------------------------------------------------
-- These are starter looks only. They do not consume
-- inventory or cosmetic items. The player can freely
-- combine the available skin and hair options.
--------------------------------------------------

CreationLooks = {

SunlitWanderer = {
Name = "Sunlit Wanderer",
Skin = "Warm",
Hair = "Pal_Hair",
Face = "Default"
},

ForestGuardian = {
Name = "Forest Guardian",
Skin = "Olive",
Hair = "Warrior_Hair",
Face = "Default"
},

DesertNomad = {
Name = "Desert Nomad",
Skin = "Tan",
Hair = "Pal_Hair",
Face = "Default"
},

MoonlitKnight = {
Name = "Moonlit Knight",
Skin = "Fair",
Hair = "Warrior_Hair",
Face = "Default"
},

RosewoodAdventurer = {
Name = "Rosewood Adventurer",
Skin = "Porcelain",
Hair = "Pal_Hair",
Face = "Default"
},

EmberVanguard = {
Name = "Ember Vanguard",
Skin = "Deep",
Hair = "Warrior_Hair",
Face = "Default"
}

},

--------------------------------------------------
-- CREATION OPTIONS
--------------------------------------------------

CreationOptions = {

Skin = {
Porcelain = {
Name = "Porcelain",
Color = Color3.fromRGB(245, 220, 201)
},
Fair = {
Name = "Fair",
Color = Color3.fromRGB(232, 193, 166)
},
Warm = {
Name = "Warm",
Color = Color3.fromRGB(211, 157, 116)
},
Tan = {
Name = "Tan",
Color = Color3.fromRGB(181, 126, 84)
},
Olive = {
Name = "Olive",
Color = Color3.fromRGB(157, 116, 82)
},
Deep = {
Name = "Deep",
Color = Color3.fromRGB(112, 76, 55)
}
},

Hair = {
Hair01 = {Name = "Hair 01", Id = 78483505436895},
Hair02 = {Name = "Hair 02", Id = 9244021842},
Hair03 = {Name = "Hair 03", Id = 9243992729},
Hair04 = {Name = "Hair 04", Id = 9174354743},
Hair05 = {Name = "Hair 05", Id = 62234425},
Hair06 = {Name = "Hair 06", Id = 7193442167},
Hair07 = {Name = "Hair 07", Id = 6993754725},
Hair08 = {Name = "Hair 08", Id = 7193448988},
Hair09 = {Name = "Hair 09", Id = 553722174},
Hair10 = {Name = "Hair 10", Id = 9244095135},
},

Face = {
Face01 = {Name = "Face 01", Id = 1601912},
Face02 = {Name = "Face 02", Id = 945},
Face03 = {Name = "Face 03", Id = 946},
Face04 = {Name = "Face 04", Id = 2924073754063},
Face05 = {Name = "Face 05", Id = 270257809508766},
Face06 = {Name = "Face 06", Id = 948},
Face07 = {Name = "Face 07", Id = 138869154852215},
Face08 = {Name = "Face 08", Id = 858696},
Face09 = {Name = "Face 09", Id = 3102},
Face10 = {Name = "Face 10", Id = 956},
}

}

}

return DefaultAppearanceCatalog
