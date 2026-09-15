-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- CHARACTER MANAGER
--------------------------------------------------

local CharacterData =
require(script.Parent.CharacterData)

local GameConfig =
require(script.Parent.GameConfig)

local ItemCatalog =
require(script.Parent.Catalog.ItemCatalog)

local EquipmentSlots =
require(script.Parent.Catalog.EquipmentSlots)


--------------------------------------------------
-- MODULE
--------------------------------------------------

local CharacterManager = {}


--------------------------------------------------
-- PLAYER DATA
--------------------------------------------------

local playerData = {}

local activeCharacters = {}

local dirtyPlayers = {}


--------------------------------------------------
-- CHARACTER ID
--------------------------------------------------

local function generateCharacterId()
    
    return "char_"
    .. tostring(os.time())
    .. "_"
    .. tostring(math.random(1000, 9999))
    
end


--------------------------------------------------
-- DEFAULT CHARACTER DATA
--------------------------------------------------

local function createCharacterData(name, attributes)
    
    return {
    
    Id = generateCharacterId(),
    
    Name = name,
    
    Level = 1,
    
    XP = 0,
    
    Gold = 0,
    
    Class = "Adventurer",
    
    --------------------------------------------------
    -- APPEARANCE
    --------------------------------------------------
    
    Appearance = {
    
    Class = "Adventurer",
    
    Equipment = {},
    
    Cosmetics = {},
    
    Customization = {
    Hair = "Pal_Hair",
    Face = "Face01",
    }
    
    },
    
    Attributes = attributes or {
    STR = 0,
    DEX = 0,
    INT = 0,
    VIT = 0,
    LUK = 0,
    },
    
    --------------------------------------------------
    -- INVENTORY
    --------------------------------------------------
    
    Inventory = {},
    
    --------------------------------------------------
    -- POSITION
    --------------------------------------------------
    
    Position = nil
    
    }
    
end


--------------------------------------------------
-- ENSURE APPEARANCE STRUCTURE
--------------------------------------------------

local function ensureAppearanceStructure(
    character
    )
    
    if not character then
        
        return
        
    end
    
    
    character.Appearance =
    character.Appearance
    or {}
    
    
    --------------------------------------------------
    -- CLASS
    --------------------------------------------------
    
    character.Appearance.Class =
    character.Appearance.Class
    or character.Class
    or "Adventurer"
    
    
    --------------------------------------------------
    -- EQUIPMENT
    --------------------------------------------------
    
    character.Appearance.Equipment =
    character.Appearance.Equipment
    or {}
    
    
    --------------------------------------------------
    -- COSMETICS
    --------------------------------------------------
    
    character.Appearance.Cosmetics =
    character.Appearance.Cosmetics
    or {}
    
    
    --------------------------------------------------
    -- CUSTOMIZATION
    --------------------------------------------------
    
    character.Appearance.Customization =
    character.Appearance.Customization
    or {
    Hair = "Pal_Hair",
    Face = "Face01",
    }
    
end


--------------------------------------------------
-- INVENTORY MIGRATION
--------------------------------------------------
--
-- Converts the old inventory format:
--
-- {
--     "IronSword",
--     "HealthPotion"
-- }
--
-- into:
--
-- {
--     {
--         ItemId = "IronSword",
--         Quantity = 1
--     },
--
--     {
--         ItemId = "HealthPotion",
--         Quantity = 1
--     }
-- }
--
-- Existing saved characters are therefore
-- automatically compatible with the new system.
--------------------------------------------------

local function normalizeInventory(
    character
    )
    
    if not character then
        
        return
        
    end
    
    
    character.Inventory =
    character.Inventory
    or {}
    
    
    local normalizedInventory = {}
    
    
    for _, entry
        in ipairs(character.Inventory) do
        
        --------------------------------------------------
        -- OLD FORMAT
        --------------------------------------------------
        
        if typeof(entry) == "string" then
            
            table.insert(
            normalizedInventory,
            {
            ItemId = entry,
            Quantity = 1
            }
            )
            
            
            --------------------------------------------------
            -- NEW FORMAT
            --------------------------------------------------
            
        elseif typeof(entry) == "table" then
            
            local itemId =
            entry.ItemId
            
            
            if itemId then
                
                local quantity =
                tonumber(
                entry.Quantity
                )
                or 1
                
                
                quantity =
                math.floor(
                quantity
                )
                
                
                if quantity < 1 then
                    
                    quantity = 1
                    
                end
                
                
                table.insert(
                normalizedInventory,
                {
                ItemId = itemId,
                Quantity = quantity
                }
                )
                
            end
            
        end
        
    end
    
    
    character.Inventory =
    normalizedInventory
    
end


--------------------------------------------------
-- ENSURE CHARACTER STRUCTURE
--------------------------------------------------

local function ensureCharacterStructure(
    character
    )
    
    if not character then
        
        return
        
    end
    
    
    --------------------------------------------------
    -- INVENTORY
    --------------------------------------------------
    
    normalizeInventory(
    character
    )
    
    
    --------------------------------------------------
    -- LEVEL
    --------------------------------------------------
    
    character.Level =
    character.Level
    or 1
    
    
    --------------------------------------------------
    -- XP
    --------------------------------------------------
    
    character.XP =
    character.XP
    or 0
    
    
    --------------------------------------------------
    -- GOLD
    --------------------------------------------------
    
    character.Gold =
    character.Gold
    or 0
    
    
    --------------------------------------------------
    -- CLASS
    --------------------------------------------------
    
    character.Class =
    character.Class
    or "Adventurer"
    
    
    --------------------------------------------------
    -- APPEARANCE
    --------------------------------------------------
    
    ensureAppearanceStructure(
    character
    )
    
end


--------------------------------------------------
-- FIND INVENTORY ENTRY
--------------------------------------------------

local function findInventoryEntry(
    character,
    itemId
    )
    
    if not character
        or not itemId then
        
        return nil
        
    end
    
    
    character.Inventory =
    character.Inventory
    or {}
    
    
    for _, entry
        in ipairs(character.Inventory) do
        
        if typeof(entry) == "table"
            and entry.ItemId == itemId then
            
            return entry
            
        end
        
    end
    
    
    return nil
    
end


--------------------------------------------------
-- GET ITEM QUANTITY
--------------------------------------------------

local function getItemQuantity(
    character,
    itemId
    )
    
    local entry =
    findInventoryEntry(
    character,
    itemId
    )
    
    
    if not entry then
        
        return 0
        
    end
    
    
    return entry.Quantity
    or 0
    
end


--------------------------------------------------
-- DIRTY STATE
--------------------------------------------------

function CharacterManager.MarkDirty(
    player
    )
    
    if not player then
        
        return
        
    end
    
    
    dirtyPlayers[player.UserId] =
    true
    
end


--------------------------------------------------
-- IS DIRTY
--------------------------------------------------

function CharacterManager.IsDirty(
    player
    )
    
    if not player then
        
        return false
        
    end
    
    
    return dirtyPlayers[player.UserId]
    == true
    
end


--------------------------------------------------
-- CLEAR DIRTY
--------------------------------------------------

function CharacterManager.ClearDirty(
    player
    )
    
    if not player then
        
        return
        
    end
    
    
    dirtyPlayers[player.UserId] =
    nil
    
end


--------------------------------------------------
-- LOAD PLAYER
--------------------------------------------------

function CharacterManager.LoadPlayer(
    player
    )
    
    if not player then
        
        return nil
        
    end
    
    
    local data =
    CharacterData.Load(
    player
    )
    
    
    if not data then
        
        warn(
        "Failed to load character data for "
        .. player.Name
        )
        
        return nil
        
    end
    
    
    --------------------------------------------------
    -- ENSURE DATA STRUCTURE
    --------------------------------------------------
    
    data.Characters =
    data.Characters
    or {}
    
    data.SharedStorage =
    data.SharedStorage
    or {}
    
    -- BANKING ACCOUNT
    -- Account-wide balance shared by all characters.
    data.BankingAccount =
    data.BankingAccount
    or {}
    
    data.BankingAccount.Balance =
    tonumber(data.BankingAccount.Balance)
    or 0
    
    data.BankingAccount.Balance =
    math.max(0, math.floor(data.BankingAccount.Balance))
    
    --------------------------------------------------
    -- NORMALIZE CHARACTERS
    --------------------------------------------------
    
    for _, character
        in ipairs(data.Characters) do
        
        ensureCharacterStructure(
        character
        )
        
    end
    
    
    --------------------------------------------------
    -- STORE DATA
    --------------------------------------------------
    
    playerData[player.UserId] =
    data
    
    
    activeCharacters[player.UserId] =
    nil
    
    
    dirtyPlayers[player.UserId] =
    nil
    
    
    print("--------------------------------")
    print(
    "Characters loaded for "
    .. player.Name
    .. ": "
    .. #data.Characters
    )
    print("--------------------------------")
    
    
    return data
    
end


--------------------------------------------------
-- GET PLAYER DATA
--------------------------------------------------

function CharacterManager.GetPlayerData(
    player
    )
    
    if not player then
        
        return nil
        
    end
    
    
    return playerData[player.UserId]
    
end


--------------------------------------------------
-- GET CHARACTERS
--------------------------------------------------

function CharacterManager.GetCharacters(
    player
    )
    
    if not player then
        
        return {}
        
    end
    
    
    local data =
    playerData[player.UserId]
    
    
    if not data then
        
        return {}
        
    end
    
    
    data.Characters =
    data.Characters
    or {}
    
    
    return data.Characters
    
end


--------------------------------------------------
-- FIND CHARACTER
--------------------------------------------------

local function findCharacter(
    player,
    characterId
    )
    
    local data =
    playerData[player.UserId]
    
    
    if not data then
        
        return nil
        
    end
    
    
    for _, character
        in ipairs(data.Characters) do
        
        if character.Id == characterId then
            
            return character
            
        end
        
    end
    
    
    return nil
    
end


--------------------------------------------------
-- SELECT CHARACTER
--------------------------------------------------

function CharacterManager.SelectCharacter(
    player,
    characterId
    )
    
    if not player then
        
        return nil
        
    end
    
    
    local data =
    playerData[player.UserId]
    
    
    if not data then
        
        warn(
        "Player data is not loaded: "
        .. player.Name
        )
        
        return nil
        
    end
    
    
    local character =
    findCharacter(
    player,
    characterId
    )
    
    
    if not character then
        
        warn(
        "Character not found: "
        .. tostring(characterId)
        )
        
        return nil
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    print(
    "Character selected: "
    .. character.Name
    )
    
    
    return character
    
end


--------------------------------------------------
-- SET ACTIVE CHARACTER
--------------------------------------------------

function CharacterManager.SetActiveCharacter(
    player,
    characterId
    )
    
    if not player then
        
        return false
        
    end
    
    
    local character =
    CharacterManager.SelectCharacter(
    player,
    characterId
    )
    
    
    if not character then
        
        warn(
        "Cannot set active character. "
        .. "Character not found: "
        .. tostring(characterId)
        )
        
        return false
        
    end
    
    
    activeCharacters[player.UserId] =
    character.Id
    
    
    print("--------------------------------")
    print("ACTIVE CHARACTER SET")
    print("Player: " .. player.Name)
    print("Character: " .. character.Name)
    print("ID: " .. character.Id)
    print("--------------------------------")
    
    
    return true
    
end


--------------------------------------------------
-- GET ACTIVE CHARACTER
--------------------------------------------------

function CharacterManager.GetActiveCharacter(
    player
    )
    
    if not player then
        
        return nil
        
    end
    
    
    local characterId =
    activeCharacters[player.UserId]
    
    
    if not characterId then
        
        return nil
        
    end
    
    
    local character =
    findCharacter(
    player,
    characterId
    )
    
    
    if not character then
        
        warn(
        "Active character not found for "
        .. player.Name
        )
        
        return nil
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    return character
    
end


--------------------------------------------------
-- SAVE ACTIVE CHARACTER POSITION
--------------------------------------------------

function CharacterManager.SaveActiveCharacterPosition(
    player
    )
    
    if not player then
        
        return false
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        return false
        
    end
    
    
    if not player.Character then
        
        warn(
        "Character model does not exist for "
        .. player.Name
        )
        
        return false
        
    end
    
    
    local rootPart =
    player.Character:FindFirstChild(
    "HumanoidRootPart"
    )
    
    
    if not rootPart then
        
        warn(
        "HumanoidRootPart not found for "
        .. player.Name
        )
        
        return false
        
    end
    
    
    local position =
    rootPart.Position
    
    
    character.Position = {
    
    X = position.X,
    
    Y = position.Y,
    
    Z = position.Z
    
    }
    
    
    CharacterManager.MarkDirty(
    player
    )
    
    
    return true
    
end


--------------------------------------------------
-- SAVE CHARACTER STATE
--------------------------------------------------

function CharacterManager.SaveCharacterState(
    player
    )
    
    if not player then
        
        return false
        
    end
    
    
    local data =
    playerData[player.UserId]
    
    
    if not data then
        
        warn(
        "Cannot save character state. "
        .. "Player data is not loaded: "
        .. player.Name
        )
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- UPDATE POSITION
    --------------------------------------------------
    
    CharacterManager.SaveActiveCharacterPosition(
    player
    )
    
    
    --------------------------------------------------
    -- SAVE PLAYER DATA
    --------------------------------------------------
    
    local success =
    CharacterData.Save(
    player,
    data
    )
    
    
    if success then
        
        CharacterManager.ClearDirty(
        player
        )
        
        
        print(
        "Character state saved for "
        .. player.Name
        )
        
    end
    
    
    return success
    
end


--------------------------------------------------
-- SAVE PLAYER
--------------------------------------------------

function CharacterManager.SavePlayer(
    player
    )
    
    return CharacterManager.SaveCharacterState(
    player
    )
    
end


--------------------------------------------------
-- CREATE CHARACTER
--------------------------------------------------

function CharacterManager.CreateCharacter(
    player,
    name,
    normalizedAttributes,
    customization
    )
    
    if not player then
        
        return nil,
        false,
        "INVALID_PLAYER"
        
    end
    
    
    local data =
    playerData[player.UserId]
    
    
    if not data then
        
        warn(
        "Player data is not loaded: "
        .. player.Name
        )
        
        return nil,
        false,
        "DATA_NOT_LOADED"
        
    end
    
    
    data.Characters =
    data.Characters
    or {}
    
    
    --------------------------------------------------
    -- CHARACTER LIMIT
    --------------------------------------------------
    
    if #data.Characters
        >= GameConfig.MAX_CHARACTERS then
        
        warn(
        "Character limit reached for "
        .. player.Name
        )
        
        return nil,
        false,
        "CHARACTER_LIMIT"
        
    end
    
    
    --------------------------------------------------
    -- VALIDATE NAME TYPE
    --------------------------------------------------
    
    if typeof(name) ~= "string" then
        
        return nil,
        false,
        "INVALID_NAME"
        
    end
    
    
    --------------------------------------------------
    -- TRIM NAME
    --------------------------------------------------
    
    name =
    string.gsub(
    name,
    "^%s*(.-)%s*$",
    "%1"
    )
    
    
    --------------------------------------------------
    -- VALIDATE NAME LENGTH
    --------------------------------------------------
    
    if #name < 3 then
        
        return nil,
        false,
        "NAME_TOO_SHORT"
        
    end
    
    
    if #name > 16 then
        
        return nil,
        false,
        "NAME_TOO_LONG"
        
    end
    
    
    --------------------------------------------------
    -- CHECK DUPLICATE NAME
    --------------------------------------------------
    
    for _, character
        in ipairs(data.Characters) do
        
        if string.lower(character.Name)
            == string.lower(name) then
            
            return nil,
            false,
            "NAME_ALREADY_EXISTS"
            
        end
        
    end
    
    
    --------------------------------------------------
    -- VALIDATE ATTRIBUTES
    --------------------------------------------------
    
    local attributeInput = normalizedAttributes
    normalizedAttributes = {
    STR = 0,
    DEX = 0,
    INT = 0,
    VIT = 0,
    LUK = 0,
    }
    
    if attributeInput ~= nil then
        if typeof(attributeInput) ~= "table" then
            return nil, false, "INVALID_ATTRIBUTES"
        end
        
        local total = 0
        for key, _ in pairs(normalizedAttributes) do
            local value = math.floor(tonumber(attributeInput[key]) or 0)
            if value < 0 then value = 0 end
            normalizedAttributes[key] = value
            total += value
        end
        
        if total ~= 25 then
            return nil, false, "ATTRIBUTE_POINTS_REQUIRED"
        end
    end
    
    --------------------------------------------------
    -- VALIDATE CUSTOMIZATION
    --------------------------------------------------
    
    if customization ~= nil then
        local AppearanceManager = require(script.Parent.AppearanceManager)
        if not AppearanceManager.ValidateCustomization(customization) then
            return nil, false, "INVALID_CUSTOMIZATION"
        end
    end
    
    --------------------------------------------------
    -- CREATE CHARACTER
    --------------------------------------------------
    
    local character =
    createCharacterData(
    name,
    normalizedAttributes
    )
    
    if customization ~= nil then
        character.Appearance.Customization = customization
    end
    
    
    table.insert(
    data.Characters,
    character
    )
    
    
    CharacterManager.MarkDirty(
    player
    )
    
    
    print("--------------------------------")
    print("Character created")
    print("Name: " .. character.Name)
    print("ID: " .. character.Id)
    print("Class: " .. character.Class)
    print("Level: " .. character.Level)
    print("--------------------------------")
    
    
    --------------------------------------------------
    -- SAVE
    --------------------------------------------------
    
    CharacterManager.SaveCharacterState(
    player
    )
    
    
    return character,
    true,
    nil
    
end


--------------------------------------------------
-- DELETE CHARACTER
--------------------------------------------------

function CharacterManager.DeleteCharacter(
    player,
    characterId
    )
    
    if not player then
        
        return false
        
    end
    
    
    local data =
    playerData[player.UserId]
    
    
    if not data then
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- NEVER DELETE ACTIVE CHARACTER
    --------------------------------------------------
    
    local activeCharacter =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if activeCharacter
        and activeCharacter.Id == characterId then
        
        warn(
        "Cannot delete active character: "
        .. activeCharacter.Name
        )
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- FIND CHARACTER
    --------------------------------------------------
    
    for index, character
        in ipairs(data.Characters) do
        
        if character.Id == characterId then
            
            print("--------------------------------")
            print("Deleting character")
            print("Name: " .. character.Name)
            print("ID: " .. character.Id)
            print("--------------------------------")
            
            
            table.remove(
            data.Characters,
            index
            )
            
            
            CharacterManager.MarkDirty(
            player
            )
            
            
            CharacterManager.SaveCharacterState(
            player
            )
            
            
            return true
            
        end
        
    end
    
    
    warn(
    "Character not found: "
    .. tostring(characterId)
    )
    
    
    return false
    
end


--------------------------------------------------
-- ADD ITEM
--------------------------------------------------
--
-- Adds an item to the active character.
--
-- Equipment and Cosmetics:
--     Always unique.
--
-- Normal items:
--     Stack by ItemId.
--
-- Example:
--
-- AddItem(player, "HealthPotion", 10)
--
--------------------------------------------------

function CharacterManager.AddItem(
    player,
    itemId,
    quantity
    )
    
    if not player then
        
        return false
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        warn(
        "Cannot add item. "
        .. "No active character for "
        .. player.Name
        )
        
        return false
        
    end
    
    
    if typeof(itemId) ~= "string"
        or itemId == "" then
        
        warn(
        "Cannot add item without valid itemId."
        )
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- QUANTITY
    --------------------------------------------------
    
    quantity =
    tonumber(
    quantity
    )
    or 1
    
    
    quantity =
    math.floor(
    quantity
    )
    
    
    if quantity < 1 then
        
        warn(
        "Invalid item quantity: "
        .. tostring(quantity)
        )
        
        return false
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    --------------------------------------------------
    -- VALIDATE ITEM
    --------------------------------------------------
    
    local itemData =
    ItemCatalog.GetItem(
    itemId
    )
    
    
    if not itemData then
        
        warn(
        "Cannot add unknown item: "
        .. tostring(itemId)
        )
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- CHECK ITEM TYPE
    --------------------------------------------------
    
    local isEquipment =
    ItemCatalog.IsEquipment(
    itemId
    )
    
    
    local isCosmetic =
    ItemCatalog.IsCosmetic(
    itemId
    )
    
    
    --------------------------------------------------
    -- NON-STACKABLE ITEMS
    --------------------------------------------------
    
    if isEquipment
        or isCosmetic then
        
        local existingEntry =
        findInventoryEntry(
        character,
        itemId
        )
        
        
        if existingEntry then
            
            warn(
            "Character already owns item: "
            .. tostring(itemId)
            )
            
            return false
            
        end
        
        
        table.insert(
        character.Inventory,
        {
        ItemId = itemId,
        Quantity = 1
        }
        )
        
        
        CharacterManager.MarkDirty(
        player
        )
        
        
        print("--------------------------------")
        print("ITEM ADDED")
        print("Character: " .. character.Name)
        print("Item: " .. itemId)
        print("Quantity: 1")
        print("--------------------------------")
        
        
        return true
        
    end
    
    
    --------------------------------------------------
    -- STACKABLE ITEM
    --------------------------------------------------
    
    local existingEntry =
    findInventoryEntry(
    character,
    itemId
    )
    
    
    if existingEntry then
        
        existingEntry.Quantity =
        (existingEntry.Quantity or 0)
        + quantity
        
    else
        
        table.insert(
        character.Inventory,
        {
        ItemId = itemId,
        Quantity = quantity
        }
        )
        
    end
    
    
    CharacterManager.MarkDirty(
    player
    )
    
    
    print("--------------------------------")
    print("ITEM ADDED")
    print("Character: " .. character.Name)
    print("Item: " .. itemId)
    print("Quantity: " .. quantity)
    print("--------------------------------")
    
    
    return true
    
end


--------------------------------------------------
-- REMOVE ITEM
--------------------------------------------------
--
-- Removes a quantity from the active
-- character's inventory.
--
-- If the quantity reaches zero,
-- the inventory entry is removed.
--------------------------------------------------

--------------------------------------------------
-- REMOVE ITEM FROM ACTIVE CHARACTER INVENTORY
--------------------------------------------------

function CharacterManager.RemoveItem(player, itemId, quantity)
    
    if not player then
        return false, 0
    end
    
    if not itemId then
        return false, 0
    end
    
    if not quantity or quantity <= 0 then
        return false, 0
    end
    
    local character = CharacterManager.GetActiveCharacter(player)
    
    if not character then
        return false, 0
    end
    
    character.Inventory = character.Inventory or {}
    
    for index, entry in ipairs(character.Inventory) do
        
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
                
                table.remove(character.Inventory, index)
                
                --------------------------------------------------
                -- OTHERWISE UPDATE QUANTITY
                --------------------------------------------------
                
            else
                
                if type(entry) == "string" then
                    
                    character.Inventory[index] = {
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
-- GET INVENTORY
--------------------------------------------------

function CharacterManager.GetInventory(
    player
    )
    
    if not player then
        
        return {}
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        return {}
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    return character.Inventory
    
end


--------------------------------------------------
-- GET ITEM QUANTITY
--------------------------------------------------

function CharacterManager.GetItemQuantity(
    player,
    itemId
    )
    
    if not player
        or not itemId then
        
        return 0
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        return 0
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    return getItemQuantity(
    character,
    itemId
    )
    
end


--------------------------------------------------
-- CHECK ITEM OWNERSHIP
--------------------------------------------------

function CharacterManager.OwnsItem(
    player,
    itemId
    )
    
    return CharacterManager.GetItemQuantity(
    player,
    itemId
    ) > 0
    
end


--------------------------------------------------
-- VALIDATE EQUIPMENT SLOT
--------------------------------------------------
--
-- EquipmentSlots is the authority for
-- valid logical equipment slots.
--------------------------------------------------

local function isValidEquipmentSlot(
    slot
    )
    
    if not slot then
        
        return false
        
    end
    
    
    return EquipmentSlots[slot] ~= nil
    
end


--------------------------------------------------
-- CHECK EQUIPMENT CONFLICT
--------------------------------------------------
--
-- Checks every slot required by an item.
--
-- An equipped item is NOT automatically
-- replaced.
--------------------------------------------------

local function hasEquipmentConflict(
    character,
    slots,
    itemId
    )
    
    local equipment =
    character.Appearance.Equipment
    
    
    for _, slot
        in ipairs(slots) do
        
        local currentItem =
        equipment[slot]
        
        
        if currentItem
            and currentItem ~= itemId then
            
            return true,
            slot,
            currentItem
            
        end
        
    end
    
    
    return false,
    nil,
    nil
    
end


--------------------------------------------------
-- EQUIP COSMETIC
--------------------------------------------------

local function equipCosmetic(
    player,
    character,
    itemId
    )
    
    local visualSlot =
    ItemCatalog.GetItemSlot(
    itemId
    )
    
    
    if not visualSlot then
        
        warn(
        "Cosmetic has no visual slot: "
        .. tostring(itemId)
        )
        
        return false
        
    end
    
    
    character.Appearance.Cosmetics[
    visualSlot
    ] = itemId
    
    
    print("--------------------------------")
    print("COSMETIC EQUIPPED")
    print("Character: " .. character.Name)
    print("Item: " .. tostring(itemId))
    print("Visual Slot: " .. tostring(visualSlot))
    print("--------------------------------")
    
    
    CharacterManager.MarkDirty(
    player
    )
    
    
    return true
    
end


--------------------------------------------------
-- EQUIP EQUIPMENT
--------------------------------------------------

local function equipEquipment(
    player,
    character,
    itemId
    )
    
    local slots =
    ItemCatalog.GetItemSlots(
    itemId
    )
    
    
    if not slots
        or #slots == 0 then
        
        warn(
        "Equipment has no equipment slots: "
        .. tostring(itemId)
        )
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- VALIDATE ALL SLOTS
    --------------------------------------------------
    
    for _, slot
        in ipairs(slots) do
        
        if not isValidEquipmentSlot(
            slot
            ) then
            
            warn(
            "Invalid equipment slot: "
            .. tostring(slot)
            .. " for item "
            .. tostring(itemId)
            )
            
            return false
            
        end
        
    end
    
    
    --------------------------------------------------
    -- CHECK CONFLICT
    --------------------------------------------------
    
    local conflict,
    conflictSlot,
    conflictItem =
    hasEquipmentConflict(
    character,
    slots,
    itemId
    )
    
    
    if conflict then
        
        warn(
        "Equipment conflict. "
        .. "Slot: "
        .. tostring(conflictSlot)
        .. " Item: "
        .. tostring(conflictItem)
        )
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- EQUIP INTO ALL REQUIRED SLOTS
    --------------------------------------------------
    
    for _, slot
        in ipairs(slots) do
        
        character.Appearance.Equipment[
        slot
        ] = itemId
        
    end
    
    
    print("--------------------------------")
    print("EQUIPMENT EQUIPPED")
    print("Character: " .. character.Name)
    print("Item: " .. tostring(itemId))
    print("Slots:")
    
    
    for _, slot
        in ipairs(slots) do
        
        print(
        "  "
        .. tostring(slot)
        )
        
    end
    
    
    print("--------------------------------")
    
    
    CharacterManager.MarkDirty(
    player
    )
    
    
    return true
    
end


--------------------------------------------------
-- EQUIP ITEM
--------------------------------------------------

function CharacterManager.EquipItem(
    player,
    itemId
    )
    
    if not player
        or not itemId then
        
        return false
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        warn(
        "Cannot equip item. "
        .. "No active character."
        )
        
        return false
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    --------------------------------------------------
    -- MUST OWN ITEM
    --------------------------------------------------
    
    if not CharacterManager.OwnsItem(
        player,
        itemId
        ) then
        
        warn(
        "Character does not own item: "
        .. tostring(itemId)
        )
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- GET ITEM
    --------------------------------------------------
    
    local itemData =
    ItemCatalog.GetItem(
    itemId
    )
    
    
    if not itemData then
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- COSMETIC
    --------------------------------------------------
    
    if ItemCatalog.IsCosmetic(
        itemId
        ) then
        
        return equipCosmetic(
        player,
        character,
        itemId
        )
        
    end
    
    
    --------------------------------------------------
    -- EQUIPMENT
    --------------------------------------------------
    
    if ItemCatalog.IsEquipment(
        itemId
        ) then
        
        return equipEquipment(
        player,
        character,
        itemId
        )
        
    end
    
    
    --------------------------------------------------
    -- NOT EQUIPPABLE
    --------------------------------------------------
    
    warn(
    "Item is not equippable: "
    .. tostring(itemId)
    )
    
    
    return false
    
end


--------------------------------------------------
-- UNEQUIP EQUIPMENT
--------------------------------------------------
--
-- Removes an equipment item from every
-- logical equipment slot it currently occupies.
--------------------------------------------------

function CharacterManager.UnequipItem(
    player,
    itemId
    )
    
    if not player
        or not itemId then
        
        return false
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        return false
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    local equipment =
    character.Appearance.Equipment
    
    
    local removed = false
    
    
    for slot, equippedItem
        in pairs(equipment) do
        
        if equippedItem == itemId then
            
            equipment[slot] =
            nil
            
            removed = true
            
        end
        
    end
    
    
    if not removed then
        
        warn(
        "Item is not equipped: "
        .. tostring(itemId)
        )
        
        return false
        
    end
    
    
    CharacterManager.MarkDirty(
    player
    )
    
    
    print("--------------------------------")
    print("EQUIPMENT UNEQUIPPED")
    print("Character: " .. character.Name)
    print("Item: " .. itemId)
    print("--------------------------------")
    
    
    return true
    
end


--------------------------------------------------
-- UNEQUIP COSMETIC
--------------------------------------------------

function CharacterManager.UnequipCosmetic(
    player,
    visualSlot
    )
    
    if not player
        or not visualSlot then
        
        return false
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        return false
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    local cosmetics =
    character.Appearance.Cosmetics
    
    
    if not cosmetics[visualSlot] then
        
        warn(
        "No cosmetic equipped in slot: "
        .. tostring(visualSlot)
        )
        
        return false
        
    end
    
    
    cosmetics[visualSlot] =
    nil
    
    
    CharacterManager.MarkDirty(
    player
    )
    
    
    print("--------------------------------")
    print("COSMETIC UNEQUIPPED")
    print("Character: " .. character.Name)
    print("Visual Slot: " .. tostring(visualSlot))
    print("--------------------------------")
    
    
    return true
    
end


--------------------------------------------------
-- GET EQUIPMENT
--------------------------------------------------

function CharacterManager.GetEquipment(
    player
    )
    
    if not player then
        
        return {}
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        return {}
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    return character.Appearance.Equipment
    
end


--------------------------------------------------
-- GET COSMETICS
--------------------------------------------------

function CharacterManager.GetCosmetics(
    player
    )
    
    if not player then
        
        return {}
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        return {}
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    return character.Appearance.Cosmetics
    
end


--------------------------------------------------
-- GET APPEARANCE
--------------------------------------------------

function CharacterManager.GetAppearance(
    player
    )
    
    if not player then
        
        return nil
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        return nil
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    return character.Appearance
    
end


--------------------------------------------------
-- GET CUSTOMIZATION
--------------------------------------------------

function CharacterManager.GetCustomization(
    player
    )
    
    if not player then
        
        return {}
        
    end
    
    
    local appearance =
    CharacterManager.GetAppearance(
    player
    )
    
    
    if not appearance then
        
        return {}
        
    end
    
    
    return appearance.Customization
    
end


--------------------------------------------------
-- SET CUSTOMIZATION
--------------------------------------------------

function CharacterManager.SetCustomization(
    player,
    customization
    )
    
    if not player then
        
        return false
        
    end
    
    
    if typeof(customization) ~= "table" then
        
        return false
        
    end
    
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if not character then
        
        return false
        
    end
    
    
    ensureCharacterStructure(
    character
    )
    
    
    character.Appearance.Customization =
    customization
    
    
    CharacterManager.MarkDirty(
    player
    )
    
    
    return true
    
end


--------------------------------------------------
-- GET CHARACTER
--------------------------------------------------

function CharacterManager.GetCharacter(
    player,
    characterId
    )
    
    if not player
        or not characterId then
        
        return nil
        
    end
    
    
    local character =
    findCharacter(
    player,
    characterId
    )
    
    
    if character then
        
        ensureCharacterStructure(
        character
        )
        
    end
    
    
    return character
    
end


--------------------------------------------------
-- CLEAR ACTIVE CHARACTER
--------------------------------------------------

function CharacterManager.ClearActiveCharacter(
    player
    )
    
    if not player then
        
        return
        
    end
    
    
    activeCharacters[player.UserId] =
    nil
    
end


--------------------------------------------------
-- REMOVE PLAYER
--------------------------------------------------

function CharacterManager.RemovePlayer(
    player
    )
    
    if not player then
        
        return
        
    end
    
    
    local userId =
    player.UserId
    
    
    playerData[userId] =
    nil
    
    
    activeCharacters[userId] =
    nil
    
    
    dirtyPlayers[userId] =
    nil
    
    
    print(
    "Character data removed from memory for "
    .. player.Name
    )
    
end


--------------------------------------------------
-- RETURN
--------------------------------------------------

return CharacterManager
