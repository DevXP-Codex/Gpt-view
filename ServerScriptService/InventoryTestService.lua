-- SCRIPT -
--------------------------------------------------
-- YAMA: LEGENDS
-- INVENTORY / STORAGE TEST SERVICE
-- TEMPORARY QA TOOL
--
-- This service exists only to force slot-limit states
-- while the catalog is still small.
-- Test entries use a reserved prefix and are never
-- intended to become real game items.
--------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterManager = require(
script.Parent:WaitForChild("CharacterManager")
)

local InventoryService = require(
script.Parent:WaitForChild("InventoryService")
)

local CharacterRemote = ReplicatedStorage:WaitForChild("CharacterRemote")

local REMOTE_NAME = "InventoryTestRemote"
local TEST_PREFIX = "__YAMA_TEST_SLOT_"

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)

if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

local function isTestEntry(entry)
    return typeof(entry) == "table"
    and typeof(entry.ItemId) == "string"
    and string.sub(entry.ItemId, 1, #TEST_PREFIX) == TEST_PREFIX
end

local function removeTestEntries(list)
    for index = #list, 1, -1 do
        if isTestEntry(list[index]) then
            table.remove(list, index)
        end
    end
end

local function countTestEntries(list)
    local count = 0
    
    for _, entry in ipairs(list) do
        if isTestEntry(entry) then
            count += 1
        end
    end
    
    return count
end

local function fillList(list, target)
    removeTestEntries(list)
    
    local current = #list
    
    for index = current + 1, target do
        table.insert(list, {
        ItemId = TEST_PREFIX .. string.format("%03d", index),
        Quantity = 1,
        })
    end
end

local function getState(player)
    return InventoryService.GetState(player)
end

local function sendState(player, message, success)
    local state = getState(player)
    
    remote:FireClient(
    player,
    "State",
    state,
    message,
    success ~= false
    )
    
    -- Refresh the normal Inventory/Storage UIs without adding
    -- any new inventory architecture.
    CharacterRemote:FireClient(
    player,
    "InventoryActionResult",
    state
    )
end

local function getCharacter(player)
    return CharacterManager.GetActiveCharacter(player)
end

local function fillInventory(player, target)
    local character = getCharacter(player)
    
    if not character then
        return false, "No active character."
    end
    
    character.Inventory = character.Inventory or {}
    
    if target < 0 then
        target = 0
    end
    
    if target > CharacterManager.GetInventoryMaxSlots() then
        target = CharacterManager.GetInventoryMaxSlots()
    end
    
    fillList(character.Inventory, target)
    
    return true,
    "Inventory forced to "
    .. tostring(#character.Inventory)
    .. "/"
    .. tostring(CharacterManager.GetInventoryMaxSlots())
end

local function fillStorage(player, target)
    local data = CharacterManager.GetPlayerData(player)
    
    if not data then
        return false, "Player data is not loaded."
    end
    
    data.SharedStorage = data.SharedStorage or {}
    
    if target < 0 then
        target = 0
    end
    
    if target > CharacterManager.GetStorageMaxSlots() then
        target = CharacterManager.GetStorageMaxSlots()
    end
    
    fillList(data.SharedStorage, target)
    
    return true,
    "Shared Storage forced to "
    .. tostring(#data.SharedStorage)
    .. "/"
    .. tostring(CharacterManager.GetStorageMaxSlots())
end

local function clearInventory(player)
    local character = getCharacter(player)
    
    if not character then
        return false, "No active character."
    end
    
    character.Inventory = character.Inventory or {}
    removeTestEntries(character.Inventory)
    
    return true, "Temporary Inventory test slots cleared."
end

local function clearStorage(player)
    local data = CharacterManager.GetPlayerData(player)
    
    if not data then
        return false, "Player data is not loaded."
    end
    
    data.SharedStorage = data.SharedStorage or {}
    removeTestEntries(data.SharedStorage)
    
    return true, "Temporary Storage test slots cleared."
end


local function addRealItem(player, itemId)
    local success = CharacterManager.AddItem(player, itemId, 1)
    
    if success then
        return true, "Added " .. itemId .. " x1."
    end
    
    return false, "Could not add " .. itemId .. "."
end

local function handle(player, action)
    local success
    local message
    
    if action == "Inventory59" then
        success, message = fillInventory(player, 59)
        
    elseif action == "Inventory60" then
        success, message = fillInventory(player, 60)
        
    elseif action == "Storage599" then
        success, message = fillStorage(player, 599)
        
    elseif action == "Storage600" then
        success, message = fillStorage(player, 600)
        
    elseif action == "ClearInventory" then
        success, message = clearInventory(player)
        
    elseif action == "ClearStorage" then
        success, message = clearStorage(player)
        
    elseif action == "AddHealthPotion" then
        success, message = addRealItem(player, "HealthPotion")
        
    elseif action == "AddIronOre" then
        success, message = addRealItem(player, "IronOre")
        
    elseif action == "AddGoldCoin" then
        success, message = addRealItem(player, "GoldCoin")
        
    else
        success = false
        message = "Unknown test action."
    end
    
    print(
    "[YAMA TEST] "
    .. player.Name
    .. " -> "
    .. tostring(action)
    .. " -> "
    .. tostring(message)
    )
    
    sendState(player, message, success)
end

remote.OnServerEvent:Connect(function(player, action)
    if typeof(action) ~= "string" then
        return
    end
    
    handle(player, action)
end)

print("[YAMA TEST] InventoryTestService loaded.")
