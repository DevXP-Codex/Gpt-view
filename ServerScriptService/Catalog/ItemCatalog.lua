-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- ITEM CATALOG
--------------------------------------------------

local CatalogsFolder =
script.Parent


--------------------------------------------------
-- LOAD CATALOGS
--------------------------------------------------

local EquipmentCatalog =
require(
CatalogsFolder:WaitForChild(
"EquipmentCatalog"
)
)

local CosmeticCatalog =
require(
CatalogsFolder:WaitForChild(
"CosmeticCatalog"
)
)

local GeneralItemCatalog =
require(
CatalogsFolder:WaitForChild(
"GeneralItemCatalog"
)
)


--------------------------------------------------
-- FIND IN CATALOG
--------------------------------------------------

-- Searches all categories inside a catalog.

local function FindInCatalog(
    catalog,
    itemId
    )
    
    
    if not itemId then
        
        return nil
        
    end
    
    
    for _, category
        in pairs(catalog) do
        
        if type(category) == "table" then
            
            local item =
            category[itemId]
            
            
            if item then
                
                return item
                
            end
            
        end
        
    end
    
    
    return nil
    
end


--------------------------------------------------
-- FIND EQUIPMENT
--------------------------------------------------

local function FindEquipment(
    itemId
    )
    
    
    return FindInCatalog(
    EquipmentCatalog,
    itemId
    )
    
    
end


--------------------------------------------------
-- FIND COSMETIC
--------------------------------------------------

local function FindCosmetic(
    itemId
    )
    
    
    return FindInCatalog(
    CosmeticCatalog,
    itemId
    )
    
    
end


--------------------------------------------------
-- FIND GENERAL ITEM
--------------------------------------------------

local function FindGeneral(
    itemId
    )
    
    
    return FindInCatalog(
    GeneralItemCatalog,
    itemId
    )
    
    
end


--------------------------------------------------
-- GET ITEM
--------------------------------------------------

-- Searches:
--
-- Equipment
-- Cosmetic
-- General
-----------------

local function GetItem(
    itemId
    )
    
    
    if not itemId then
        
        return nil
        
    end
    
    
    --------------------------------------------------
    -- EQUIPMENT
    --------------------------------------------------
    
    local equipment =
    FindEquipment(
    itemId
    )
    
    
    if equipment then
        
        return equipment
        
    end
    
    
    --------------------------------------------------
    -- COSMETIC
    --------------------------------------------------
    
    local cosmetic =
    FindCosmetic(
    itemId
    )
    
    
    if cosmetic then
        
        return cosmetic
        
    end
    
    
    --------------------------------------------------
    -- GENERAL
    --------------------------------------------------
    
    local general =
    FindGeneral(
    itemId
    )
    
    
    if general then
        
        return general
        
    end
    
    
    --------------------------------------------------
    -- NOT FOUND
    --------------------------------------------------
    
    warn(
    "Item not found in catalogs: "
    .. tostring(itemId)
    )
    
    
    return nil
    
end


--------------------------------------------------
-- GET ITEM CATEGORY
--------------------------------------------------

-- Returns:
--
-- "Equipment"
-- "Cosmetic"
-- "General"
-- nil
-----------------

local function GetItemCategory(
    itemId
    )
    
    
    if not itemId then
        
        return nil
        
    end
    
    
    if FindEquipment(itemId) then
        
        return "Equipment"
        
    end
    
    
    if FindCosmetic(itemId) then
        
        return "Cosmetic"
        
    end
    
    
    if FindGeneral(itemId) then
        
        return "General"
        
    end
    
    
    return nil
    
end


--------------------------------------------------
-- IS EQUIPMENT
--------------------------------------------------

local function IsEquipment(
    itemId
    )
    
    
    return FindEquipment(itemId) ~= nil
    
    
end


--------------------------------------------------
-- IS COSMETIC
--------------------------------------------------

local function IsCosmetic(
    itemId
    )
    
    
    return FindCosmetic(itemId) ~= nil
    
    
end


--------------------------------------------------
-- IS GENERAL
--------------------------------------------------

local function IsGeneral(
    itemId
    )
    
    
    return FindGeneral(itemId) ~= nil
    
    
end


--------------------------------------------------
-- GET ITEM SLOTS
--------------------------------------------------

-- Returns all equipment slots occupied
-- by the item.
--
-- General items and cosmetics normally
-- do not occupy equipment slots.
---------------

local function GetItemSlots(
    itemId
    )
    
    
    local itemData =
    GetItem(itemId)
    
    
    if not itemData then
        
        return nil
        
    end
    
    
    --------------------------------------------------
    -- NEW SLOT STRUCTURE
    --------------------------------------------------
    -- Occupies defines every equipment slot
    -- occupied by the item.
    
    if type(itemData.Occupies) == "table"
        and #itemData.Occupies > 0 then
        
        return itemData.Occupies
        
    end
    
    
    --------------------------------------------------
    -- BACKWARD COMPATIBILITY
    --
    -- Allows older catalog entries that still
    -- use EquipSlots to continue working temporarily.
    --------------------------------------------------
    
    if type(itemData.EquipSlots) == "table"
        and #itemData.EquipSlots > 0 then
        
        return itemData.EquipSlots
        
    end
    
    
    --------------------------------------------------
    -- BACKWARD COMPATIBILITY
    --
    -- Allows older catalog entries that still
    -- use Slot to continue working temporarily.
    --------------------------------------------------
    
    if type(itemData.Slot) == "string" then
        
        return {
        itemData.Slot
        }
        
    end
    
    
    return nil
    
end


--------------------------------------------------
-- GET ITEM SLOT
--------------------------------------------------

-- Compatibility helper.
--
-- Returns the first occupied slot.
--
-- For items occupying multiple slots,
-- use GetItemSlots() instead.
------------------------------

local function GetItemSlot(
    itemId
    )
    
    
    local slots =
    GetItemSlots(
    itemId
    )
    
    
    if not slots then
        
        return nil
        
    end
    
    
    return slots[1]
    
end


--------------------------------------------------
-- HAS EQUIPMENT SLOTS
--------------------------------------------------

local function HasEquipmentSlots(
    itemId
    )
    
    
    local slots =
    GetItemSlots(
    itemId
    )
    
    
    return slots ~= nil
    and #slots > 0
    
end


--------------------------------------------------
-- GET EQUIPMENT SLOT COUNT
--------------------------------------------------

local function GetEquipmentSlotCount(
    itemId
    )
    
    
    local slots =
    GetItemSlots(
    itemId
    )
    
    
    if not slots then
        
        return 0
        
    end
    
    
    return #slots
    
end


--------------------------------------------------
-- PUBLIC API
--------------------------------------------------

local ItemCatalog = {


--------------------------------------------------
-- GENERAL
--------------------------------------------------

GetItem =
GetItem,

GetItemCategory =
GetItemCategory,


--------------------------------------------------
-- SLOTS
--------------------------------------------------

GetItemSlot =
GetItemSlot,

GetItemSlots =
GetItemSlots,

HasEquipmentSlots =
HasEquipmentSlots,

GetEquipmentSlotCount =
GetEquipmentSlotCount,


--------------------------------------------------
-- TYPE CHECKS
--------------------------------------------------

IsEquipment =
IsEquipment,

IsCosmetic =
IsCosmetic,

IsGeneral =
IsGeneral,


--------------------------------------------------
-- DIRECT SEARCH
--------------------------------------------------

FindEquipment =
FindEquipment,

FindCosmetic =
FindCosmetic,

FindGeneral =
FindGeneral,


}

return ItemCatalog
