-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- INVENTORY SERVICE
--------------------------------------------------

local InventoryService = {}

local CharacterManager =
require(script.Parent.CharacterManager)

local ItemCatalog =
require(script.Parent.Catalog.ItemCatalog)

local ItemDropService =
require(script.Parent.ItemDropService)

local MAX_GROUND_PICKUP_DISTANCE = 14

-- These are fallbacks only. If GameConfig exposes matching
-- slot settings, those values are used automatically.
local DEFAULT_INVENTORY_MAX_SLOTS = 60
local DEFAULT_STORAGE_MAX_SLOTS = 120

local GameConfig = nil
pcall(function()
    GameConfig = require(script.Parent.GameConfig)
end)

local function readConfigNumber(names, fallback)
    if not GameConfig then
        return fallback
    end
    
    for _, name in ipairs(names) do
        local value = tonumber(GameConfig[name])
        if value then
            return math.max(1, math.floor(value))
        end
    end
    
    return fallback
end

local function getInventoryMaxSlots(player)
    return readConfigNumber({
    "MAX_INVENTORY_SLOTS",
    "INVENTORY_MAX_SLOTS",
    "INVENTORY_SLOTS",
    }, DEFAULT_INVENTORY_MAX_SLOTS)
end

local function getStorageMaxSlots(player)
    return readConfigNumber({
    "MAX_STORAGE_SLOTS",
    "STORAGE_MAX_SLOTS",
    "STORAGE_SLOTS",
    "MAX_BANK_SLOTS",
    }, DEFAULT_STORAGE_MAX_SLOTS)
end

local function normalizeQuantity(quantity)
    quantity = tonumber(quantity) or 1
    quantity = math.floor(quantity)
    
    if quantity < 1 then
        return nil
    end
    
    return quantity
end

local function validItem(itemId)
    return typeof(itemId) == "string"
    and itemId ~= ""
    and ItemCatalog.GetItem(itemId) ~= nil
end

local function getRoot(player)
    local character = player and player.Character
    
    if not character then
        return nil
    end
    
    return character:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
-- STORAGE
--
-- CharacterManager already loads account-wide
-- SharedStorage into player data. The current
-- CharacterManager does not expose storage helper
-- methods, so InventoryService accesses that existing
-- structure directly instead of calling nonexistent
-- functions.
--------------------------------------------------

local function getSharedStorage(player)
    local data = CharacterManager.GetPlayerData(player)
    
    if not data then
        return nil
    end
    
    data.SharedStorage = data.SharedStorage or {}
    
    return data.SharedStorage
end

local function normalizeStorage(player)
    local storage = getSharedStorage(player)
    
    if not storage then
        return {}
    end
    
    local normalized = {}
    
    for _, entry in ipairs(storage) do
        if typeof(entry) == "string" then
            table.insert(normalized, {
            ItemId = entry,
            Quantity = 1,
            })
            
        elseif typeof(entry) == "table" then
            local itemId = entry.ItemId
            
            if itemId then
                local quantity =
                math.floor(
                tonumber(entry.Quantity) or 1
                )
                
                if quantity < 1 then
                    quantity = 1
                end
                
                table.insert(normalized, {
                ItemId = itemId,
                Quantity = quantity,
                })
            end
        end
    end
    
    -- Keep the same normalized representation in the
    -- player's persistent data.
    for i = #storage, 1, -1 do
        table.remove(storage, i)
    end
    
    for _, entry in ipairs(normalized) do
        table.insert(storage, entry)
    end
    
    return storage
end

local function findStorageEntry(player, itemId)
    local storage = normalizeStorage(player)
    
    for _, entry in ipairs(storage) do
        if entry.ItemId == itemId then
            return entry
        end
    end
    
    return nil
end

local function getStorageItemQuantity(player, itemId)
    local entry = findStorageEntry(player, itemId)
    
    if not entry then
        return 0
    end
    
    return tonumber(entry.Quantity) or 0
end

local function getStorageSlotCount(player)
    return #normalizeStorage(player)
end

local function addStorageItem(player, itemId, quantity)
    local storage = normalizeStorage(player)
    
    if not validItem(itemId) then
        return false
    end
    
    quantity = normalizeQuantity(quantity)
    
    if not quantity then
        return false
    end
    
    local existing = findStorageEntry(player, itemId)
    
    if existing then
        existing.Quantity =
        (tonumber(existing.Quantity) or 0)
        + quantity
    else
        if #storage >= getStorageMaxSlots(player) then
            return false
        end
        
        table.insert(storage, {
        ItemId = itemId,
        Quantity = quantity,
        })
    end
    
    CharacterManager.MarkDirty(player)
    
    return true
end

local function removeStorageItem(player, itemId, quantity)
    local storage = normalizeStorage(player)
    
    if not itemId then
        return false
    end
    
    quantity = normalizeQuantity(quantity)
    
    if not quantity then
        return false
    end
    
    for index, entry in ipairs(storage) do
        if entry.ItemId == itemId then
            local current =
            tonumber(entry.Quantity) or 1
            
            if current < quantity then
                return false
            end
            
            current = current - quantity
            
            if current <= 0 then
                table.remove(storage, index)
            else
                entry.Quantity = current
            end
            
            CharacterManager.MarkDirty(player)
            
            return true
        end
    end
    
    return false
end

--------------------------------------------------
-- INVENTORY SLOT HELPERS
--------------------------------------------------

local function getInventorySlotCount(player)
    return #CharacterManager.GetInventory(player)
end

--------------------------------------------------
-- GET INVENTORY STATE
--------------------------------------------------

local function enrichEntries(entries)
    local result = {}
    
    for _, entry in ipairs(entries or {}) do
        local itemId = entry.ItemId
        local itemData =
        itemId and ItemCatalog.GetItem(itemId)
        or nil
        
        table.insert(result, {
        ItemId = itemId,
        Quantity = tonumber(entry.Quantity) or 1,
        Data = itemData or {},
        })
    end
    
    return result
end

function InventoryService.GetState(player)
    if not player then
        return {
        Inventory = {},
        Storage = {},
        Equipment = {},
        Cosmetics = {},
        InventorySlots = 0,
        InventoryMaxSlots = DEFAULT_INVENTORY_MAX_SLOTS,
        StorageSlots = 0,
        StorageMaxSlots = DEFAULT_STORAGE_MAX_SLOTS,
        }
    end
    
    local inventory =
    CharacterManager.GetInventory(player)
    
    local storage =
    normalizeStorage(player)
    
    return {
    Inventory = enrichEntries(inventory),
    Storage = enrichEntries(storage),
    
    Equipment =
    CharacterManager.GetEquipment(player)
    or {},
    
    Cosmetics =
    CharacterManager.GetCosmetics(player)
    or {},
    
    InventorySlots =
    getInventorySlotCount(player),
    
    InventoryMaxSlots =
    getInventoryMaxSlots(player),
    
    StorageSlots =
    #storage,
    
    StorageMaxSlots =
    getStorageMaxSlots(player),
    }
end

--------------------------------------------------
-- MOVE INVENTORY -> STORAGE
--------------------------------------------------

function InventoryService.MoveToStorage(player, itemId, quantity)
    if not validItem(itemId) then
        return false, "INVALID_ITEM"
    end
    
    quantity = normalizeQuantity(quantity)
    if not quantity then
        return false, "INVALID_QUANTITY"
    end
    
    local existingStorage =
    getStorageItemQuantity(player, itemId)
    
    if existingStorage <= 0
        and getStorageSlotCount(player)
        >= getStorageMaxSlots(player) then
        return false, "STORAGE_FULL"
    end
    
    if not CharacterManager.RemoveItem(player, itemId, quantity) then
        return false, "NOT_ENOUGH_ITEMS"
    end
    
    if not addStorageItem(player, itemId, quantity) then
        -- Roll back the inventory change if storage insertion fails.
        CharacterManager.AddItem(player, itemId, quantity)
        return false, "STORAGE_ADD_FAILED"
    end
    
    return true, "OK"
end

--------------------------------------------------
-- MOVE STORAGE -> INVENTORY
--------------------------------------------------

function InventoryService.MoveFromStorage(player, itemId, quantity)
    if not validItem(itemId) then
        return false, "INVALID_ITEM"
    end
    
    quantity = normalizeQuantity(quantity)
    if not quantity then
        return false, "INVALID_QUANTITY"
    end
    
    local inventoryQuantity =
    CharacterManager.GetItemQuantity(player, itemId)
    
    if inventoryQuantity <= 0
        and getInventorySlotCount(player)
        >= getInventoryMaxSlots(player) then
        return false, "INVENTORY_FULL"
    end
    
    if not removeStorageItem(player, itemId, quantity) then
        return false, "NOT_ENOUGH_STORAGE_ITEMS"
    end
    
    if not CharacterManager.AddItem(player, itemId, quantity) then
        -- Roll back the storage change if inventory insertion fails.
        addStorageItem(player, itemId, quantity)
        return false, "INVENTORY_ADD_FAILED"
    end
    
    return true, "OK"
end

--------------------------------------------------
-- DROP FROM INVENTORY
--------------------------------------------------
--
-- ItemDropService only creates/manages a world drop.
-- It does not assume that the source owns an inventory.
--------------------------------------------------

function InventoryService.DropFromInventory(player, itemId, quantity)
    if not player or not validItem(itemId) then
        return false, "INVALID_ITEM"
    end
    
    quantity = normalizeQuantity(quantity)
    if not quantity then
        return false, "INVALID_QUANTITY"
    end
    
    local root = getRoot(player)
    if not root then
        return false, "NO_CHARACTER_POSITION"
    end
    
    local position =
    root.Position + root.CFrame.LookVector * 4
    
    if not CharacterManager.RemoveItem(player, itemId, quantity) then
        return false, "NOT_ENOUGH_ITEMS"
    end
    
    local drop = ItemDropService.CreateDrop(
    itemId,
    quantity,
    position
    )
    
    if not drop then
        CharacterManager.AddItem(player, itemId, quantity)
        return false, "DROP_CREATE_FAILED"
    end
    
    return true, drop
end

--------------------------------------------------
-- PICKUP WORLD DROP
--------------------------------------------------

function InventoryService.PickupDrop(player, dropId, quantity)
    if not player or typeof(dropId) ~= "string" then
        return false, "INVALID_DROP"
    end
    
    local drop = ItemDropService.GetDrop(dropId)
    if not drop then
        return false, "DROP_NOT_FOUND"
    end
    
    local root = getRoot(player)
    if not root then
        return false, "NO_CHARACTER"
    end
    
    if (root.Position - drop.Position).Magnitude
        > MAX_GROUND_PICKUP_DISTANCE then
        return false, "TOO_FAR"
    end
    
    quantity = normalizeQuantity(quantity or drop.Quantity)
    if not quantity then
        return false, "INVALID_QUANTITY"
    end
    
    if quantity > drop.Quantity then
        return false, "NOT_ENOUGH_DROP_ITEMS"
    end
    
    if not CharacterManager.AddItem(
        player,
        drop.ItemId,
        quantity
        ) then
        return false, "INVENTORY_ADD_FAILED"
    end
    
    if not ItemDropService.ReduceDrop(
        dropId,
        quantity
        ) then
        -- Roll back if the ground state could not be updated.
        CharacterManager.RemoveItem(
        player,
        drop.ItemId,
        quantity
        )
        return false, "DROP_UPDATE_FAILED"
    end
    
    return true, {
    ItemId = drop.ItemId,
    Quantity = quantity,
    Remaining = drop.Quantity - quantity,
    }
end

return InventoryService
