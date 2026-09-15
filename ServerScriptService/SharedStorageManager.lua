-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- SHARED STORAGE MANAGER
--------------------------------------------------
 
local SharedStorageManager = {}
 
 
--------------------------------------------------
-- SERVICES / MODULES
--------------------------------------------------
 
local CharacterManager =
require(script.Parent.CharacterManager)
 
local ItemCatalog =
require(script.Parent.Catalog.ItemCatalog)
 
 
--------------------------------------------------
-- INTERNAL
--------------------------------------------------
 
local function getPlayerData(player)
    
    if not player then
        return nil
    end
    
    return CharacterManager.GetPlayerData(player)
    
end
 
 
--------------------------------------------------
-- ENSURE STORAGE
--------------------------------------------------
 
local function ensureStorage(player)
    
    local data = getPlayerData(player)
    
    if not data then
        return nil
    end
    
    if not data.SharedStorage then
        
        data.SharedStorage = {}
        
    end
    
    return data.SharedStorage
    
end
 
 
--------------------------------------------------
-- FIND ITEM
--------------------------------------------------
 
local function findItem(storage, itemId)
    
    for index, entry in ipairs(storage) do
        
        if type(entry) == "table"
            and entry.ItemId == itemId then
            
            return entry, index
            
        end
        
    end
    
    return nil, nil
    
end
 
 
--------------------------------------------------
-- NORMALIZE STORAGE
--------------------------------------------------
 
local function normalizeStorage(storage)
    
    if type(storage) ~= "table" then
        
        return {}
        
    end
    
    
    for index = #storage, 1, -1 do
        
        local entry = storage[index]
        
        
        --------------------------------------------------
        -- OLD FORMAT
        --------------------------------------------------
        
        if type(entry) == "string" then
            
            storage[index] = {
            
            ItemId = entry,
            
            Quantity = 1,
            
            }
            
            
            --------------------------------------------------
            -- TABLE FORMAT
            --------------------------------------------------
            
        elseif type(entry) == "table" then
            
            local itemId = entry.ItemId
            local quantity = tonumber(entry.Quantity)
            
            
            if not itemId then
                
                table.remove(storage, index)
                
            else
                
                if not quantity or quantity < 1 then
                    
                    quantity = 1
                    
                end
                
                entry.ItemId = itemId
                entry.Quantity = math.floor(quantity)
                
            end
            
            
            --------------------------------------------------
            -- INVALID ENTRY
            --------------------------------------------------
            
        else
            
            table.remove(storage, index)
            
        end
        
    end
    
    
    return storage
    
end
 
 
--------------------------------------------------
-- INITIALIZE
--------------------------------------------------
 
function SharedStorageManager.Initialize(player)
    
    local storage = ensureStorage(player)
    
    if not storage then
        
        return false
        
    end
    
    normalizeStorage(storage)
    
    return true
    
end
 
 
--------------------------------------------------
-- GET STORAGE
--------------------------------------------------
 
function SharedStorageManager.GetStorage(player)
    
    local storage = ensureStorage(player)
    
    if not storage then
        
        return nil
        
    end
    
    normalizeStorage(storage)
    
    return storage
    
end
 
 
--------------------------------------------------
-- ADD ITEM
--------------------------------------------------
 
function SharedStorageManager.AddItem(player, itemId, quantity)
    
    local storage = ensureStorage(player)
    
    if not storage then
        
        return false, "PlayerData not loaded"
        
    end
    
    
    --------------------------------------------------
    -- VALIDATE ITEM
    --------------------------------------------------
    
    local item = ItemCatalog.GetItem(itemId)
    
    if not item then
        
        return false, "Item not found"
        
    end
    
    
    --------------------------------------------------
    -- NORMALIZE QUANTITY
    --------------------------------------------------
    
    quantity = tonumber(quantity) or 1
    quantity = math.floor(quantity)
    
    
    if quantity < 1 then
        
        return false, "Invalid quantity"
        
    end
    
    
    --------------------------------------------------
    -- EQUIPMENT
    --------------------------------------------------
    
    if ItemCatalog.IsEquipment(itemId) then
        
        local existing = findItem(storage, itemId)
        
        if existing then
            
            return false, "Equipment already stored"
            
        end
        
        table.insert(storage, {
        
        ItemId = itemId,
        
        Quantity = 1,
        
        })
        
        CharacterManager.MarkDirty(player)
        
        return true
        
    end
    
    
    --------------------------------------------------
    -- COSMETIC
    --------------------------------------------------
    
    if ItemCatalog.IsCosmetic(itemId) then
        
        local existing = findItem(storage, itemId)
        
        if existing then
            
            return false, "Cosmetic already stored"
            
        end
        
        table.insert(storage, {
        
        ItemId = itemId,
        
        Quantity = 1,
        
        })
        
        CharacterManager.MarkDirty(player)
        
        return true
        
    end
    
    
    --------------------------------------------------
    -- GENERAL ITEM
    --------------------------------------------------
    
    local existing = findItem(storage, itemId)
    
    if existing then
        
        existing.Quantity =
        existing.Quantity + quantity
        
    else
        
        table.insert(storage, {
        
        ItemId = itemId,
        
        Quantity = quantity,
        
        })
        
    end
    
    
    CharacterManager.MarkDirty(player)
    
    return true
    
end
 
 
--------------------------------------------------
-- REMOVE ITEM FROM SHARED STORAGE
--------------------------------------------------
 
function SharedStorageManager.RemoveItem(player, itemId, quantity)
    
    if not player then
        return false, 0
    end
    
    if not itemId then
        return false, 0
    end
    
    if not quantity or quantity <= 0 then
        return false, 0
    end
    
    local storage = SharedStorageManager.GetStorage(player)
    
    if not storage then
        return false, 0
    end
    
    --------------------------------------------------
    -- SEARCH FOR ITEM
    --------------------------------------------------
    
    for index, entry in ipairs(storage) do
        
        local currentItemId
        local currentQuantity
        
        --------------------------------------------------
        -- OLD FORMAT
        --------------------------------------------------
        
        if type(entry) == "string" then
            
            currentItemId = entry
            currentQuantity = 1
            
            --------------------------------------------------
            -- NEW FORMAT
            --------------------------------------------------
            
        elseif type(entry) == "table" then
            
            currentItemId = entry.ItemId
            currentQuantity = entry.Quantity or 1
            
        end
        
        --------------------------------------------------
        -- FOUND ITEM
        --------------------------------------------------
        
        if currentItemId == itemId then
            
            currentQuantity = math.max(0, currentQuantity)
            
            --------------------------------------------------
            -- REMOVE ONLY WHAT ACTUALLY EXISTS
            --------------------------------------------------
            
            local removedQuantity =
            math.min(currentQuantity, quantity)
            
            local newQuantity =
            currentQuantity - removedQuantity
            
            --------------------------------------------------
            -- REMOVE ENTRY COMPLETELY
            -- WHEN NOTHING REMAINS
            --------------------------------------------------
            
            if newQuantity <= 0 then
                
                table.remove(storage, index)
                
                --------------------------------------------------
                -- OTHERWISE UPDATE QUANTITY
                --------------------------------------------------
                
            else
                
                if type(entry) == "string" then
                    
                    storage[index] = {
                    ItemId = itemId,
                    Quantity = newQuantity
                    }
                    
                else
                    
                    entry.Quantity = newQuantity
                    
                end
                
            end
            
            --------------------------------------------------
            -- MARK PLAYER DATA AS DIRTY
            --------------------------------------------------
            
            CharacterManager.MarkDirty(player)
            
            return true, removedQuantity
            
        end
        
    end
    
    --------------------------------------------------
    -- ITEM NOT FOUND
    --------------------------------------------------
    
    return false, 0
    
end
 
--------------------------------------------------
-- GET ITEM QUANTITY
--------------------------------------------------
 
function SharedStorageManager.GetItemQuantity(player, itemId)
    
    local storage = ensureStorage(player)
    
    if not storage then
        
        return 0
        
    end
    
    
    local entry =
    findItem(storage, itemId)
    
    if not entry then
        
        return 0
        
    end
    
    
    return entry.Quantity or 0
    
end
 
 
--------------------------------------------------
-- OWNS ITEM
--------------------------------------------------
 
function SharedStorageManager.OwnsItem(player, itemId)
    
    return SharedStorageManager.GetItemQuantity(
    player,
    itemId
    ) > 0
    
end
 
 
--------------------------------------------------
-- CLEAR STORAGE
--------------------------------------------------
 
function SharedStorageManager.ClearStorage(player)
    
    local storage = ensureStorage(player)
    
    if not storage then
        
        return false
        
    end
    
    
    table.clear(storage)
    
    CharacterManager.MarkDirty(player)
    
    return true
    
end
 
 
--------------------------------------------------
-- RETURN MODULE
--------------------------------------------------
 
return SharedStorageManager
