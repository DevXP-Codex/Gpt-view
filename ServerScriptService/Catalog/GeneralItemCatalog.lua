-- MODULE SCRIPT -- 
--------------------------------------------------
-- YAMA: LEGENDS
-- GENERAL ITEM CATALOG
--------------------------------------------------

local GeneralItemCatalog = {

--------------------------------------------------
-- CONSUMABLES
--------------------------------------------------

Consumables = {

HealthPotion = {

Id = "HealthPotion",
Name = "Health Potion",
Type = "Consumable",

Description =
"Restores a small amount of health.",

IconAssetId = 119065972172003,
WorldAssetId = 119065972172003,

},

ManaPotion = {

Id = "ManaPotion",
Name = "Mana Potion",
Type = "Consumable",

Description =
"Restores a small amount of mana.",

},
},


--------------------------------------------------
-- MATERIALS
--------------------------------------------------

Materials = {

IronOre = {

Id = "IronOre",
Name = "Iron Ore",
Type = "Material",

Description =
"Raw iron ore used for crafting.",

IconAssetId = 16684208160,
WorldAssetId = 16684208160,

},

Wood = {

Id = "Wood",
Name = "Wood",
Type = "Material",

Description =
"Basic material used for crafting.",

},
},


--------------------------------------------------
-- QUEST ITEMS
--------------------------------------------------

QuestItems = {

GoblinTooth = {

Id = "GoblinTooth",
Name = "Goblin Tooth",
Type = "QuestItem",

Description =
"A tooth taken from a defeated goblin.",

},
},


--------------------------------------------------
-- MISC
--------------------------------------------------

Misc = {

TreasureMap = {

Id = "TreasureMap",
Name = "Treasure Map",
Type = "Misc",

Description =
"A mysterious map pointing to hidden treasure.",

},

GoldCoin = {

Id = "GoldCoin",
Name = "Gold Coin",
Type = "Currency",

Description =
"A gold coin used as currency.",

IconAssetId = 7893798103,
WorldAssetId = 7893798103,

},
},
}

return GeneralItemCatalog
