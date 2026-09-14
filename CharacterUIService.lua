--------------------------------------------------
-- YAMA: LEGENDS
-- CHARACTER UI SERVICE V1
--
-- Additive UI data bridge.
-- Does not replace CharacterManager, GameServer,
-- AppearanceManager or any existing system.
--------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterManager = require(
script.Parent:WaitForChild("CharacterManager")
)

local remote = ReplicatedStorage:FindFirstChild("CharacterUIRemote")

if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "CharacterUIRemote"
    remote.Parent = ReplicatedStorage
end

--------------------------------------------------
-- OPTIONAL STAT MANAGER
--------------------------------------------------

local StatManager = nil

local statModule = script.Parent:FindFirstChild("StatManager")

if statModule and statModule:IsA("ModuleScript") then
    local success, result = pcall(require, statModule)
    
    if success then
        StatManager = result
    end
end

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function copyAttributes(character)
    local attributes = {}
    
    if StatManager and StatManager.GetAttributes then
        local success, result = pcall(
        StatManager.GetAttributes,
        character
        )
        
        if success and typeof(result) == "table" then
            for key, value in pairs(result) do
                attributes[key] = tonumber(value) or 0
            end
        end
    elseif typeof(character.Attributes) == "table" then
        for key, value in pairs(character.Attributes) do
            attributes[key] = tonumber(value) or 0
        end
    end
    
    return attributes
end

local function getDerivedStats(character)
    if not StatManager
        or not StatManager.GetDerivedStats then
        return {}
    end
    
    local success, result = pcall(
    StatManager.GetDerivedStats,
    character,
    {}
    )
    
    if success and typeof(result) == "table" then
        return result
    end
    
    return {}
end

local function buildPayload(player)
    local character =
    CharacterManager.GetActiveCharacter(player)
    
    if not character then
        return nil
    end
    
    local equipment =
    CharacterManager.GetEquipment(player)
    
    local cosmetics =
    CharacterManager.GetCosmetics(player)
    
    local customization =
    CharacterManager.GetCustomization(player)
    
    local attributes = copyAttributes(character)
    local derivedStats = getDerivedStats(character)
    
    return {
    Name = character.Name or "Character",
    Level = tonumber(character.Level) or 1,
    XP = tonumber(character.XP) or 0,
    Gold = tonumber(character.Gold) or 0,
    
    -- YAMA no longer presents a fixed regular class.
    -- Until specialization data exists, the initial identity
    -- is shown as Adventurer.
    Specialization =
    character.Specialization
    or character.Title
    or "Adventurer",
    
    Attributes = attributes,
    AttributePoints =
    tonumber(character.AttributePoints) or 0,
    
    DerivedStats = derivedStats,
    
    Equipment = equipment,
    Cosmetics = cosmetics,
    Customization = customization,
    
    -- Current resource values are not yet persisted by the
    -- character system. These are UI-safe defaults for V1.
    HP = derivedStats.MaxHP or 100,
    MaxHP = derivedStats.MaxHP or 100,
    SP = derivedStats.MaxMana or 50,
    MaxSP = derivedStats.MaxMana or 50,
    }
end

--------------------------------------------------
-- REMOTE
--------------------------------------------------

remote.OnServerEvent:Connect(function(player, action)
    if action ~= "GetData" then
        return
    end
    
    local payload = buildPayload(player)
    
    if payload then
        remote:FireClient(
        player,
        "Data",
        payload
        )
    else
        remote:FireClient(
        player,
        "Unavailable"
        )
    end
end)
