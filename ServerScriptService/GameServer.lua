-- SCRIPT --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
Players.CharacterAutoLoads = false
 
 
--------------------------------------------------
-- CONFIG
--------------------------------------------------
 
local AUTO_SAVE_INTERVAL = 30
 
 
--------------------------------------------------
-- MODULES
--------------------------------------------------
 
local CharacterManager =
require(script.Parent.CharacterManager)
 
local AppearanceManager =
require(script.Parent.AppearanceManager)
 
local InventoryService =
require(script.Parent.InventoryService)
 
local ItemDropService =
require(script.Parent.ItemDropService)
 
local ItemCatalog =
require(script.Parent.Catalog.ItemCatalog)
 
local EquipmentVisualService =
require(script.Parent.EquipmentVisualService)
 
local CharacterRemote =
ReplicatedStorage:WaitForChild("CharacterRemote")
 
 
--------------------------------------------------
-- WORLD DROP PICKUP HANDLER
--------------------------------------------------
ItemDropService.SetPickupHandler(function(player, dropId)
    
    local success, result =
    InventoryService.PickupDrop(
    player,
    dropId,
    nil
    )
    
    if success then
        CharacterRemote:FireClient(
        player,
        "InventoryActionResult",
        InventoryService.GetState(player)
        )
    else
        CharacterRemote:FireClient(
        player,
        "InventoryActionFailed",
        result or "PICKUP_FAILED"
        )
    end
    
end)
 
 
--------------------------------------------------
-- CHARACTER PREVIEW STORAGE
--------------------------------------------------
 
local previewFolder =
ReplicatedStorage:FindFirstChild("YAMA_CharacterPreviews")
 
if not previewFolder then
    previewFolder = Instance.new("Folder")
    previewFolder.Name = "YAMA_CharacterPreviews"
    previewFolder.Parent = ReplicatedStorage
end
 
 
local function GetCharacterPreview(
    player,
    character
    )
    
    if not character then
        return nil
    end
    
    local description =
    AppearanceManager.BuildDescription(
    character.Appearance
    )
    
    if not description then
        return nil
    end
    
    local success, result =
    pcall(function()
        return Players:CreateHumanoidModelFromDescriptionAsync(
        description,
        Enum.HumanoidRigType.R15
        )
    end)
    
    description:Destroy()
    
    if not success then
        warn(
        "Failed to create character preview: "
        .. tostring(result)
        )
        return nil
    end
    
    local model = result
    
    if not model then
        return nil
    end
    
    model.Name =
    tostring(player.UserId)
    .. "_"
    .. tostring(character.Id)
    
    model:SetAttribute("YAMA_Preview", true)
    
    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Script")
            or object:IsA("LocalScript") then
            object:Destroy()
        elseif object:IsA("BasePart") then
            object.Anchored = true
            object.CanCollide = false
            object.CanTouch = false
            object.CanQuery = false
        end
    end
    
    local oldPreview =
    previewFolder:FindFirstChild(model.Name)
    
    if oldPreview then
        oldPreview:Destroy()
    end
    
    model.Parent = previewFolder
    
    task.delay(60, function()
        if model and model.Parent == previewFolder then
            model:Destroy()
        end
    end)
    
    return model
    
end
 
 
--------------------------------------------------
-- EQUIPMENT VISUALS
--------------------------------------------------
-- Physical equipment visuals are handled separately from
-- HumanoidDescription. This keeps the existing appearance
-- pipeline intact while allowing Creator Store weapon models
-- and shields to be attached to the live character.
--------------------------------------------------
local function GetEquipmentRenderProfile(itemData)
    if not itemData then
        return nil
    end
    
    if itemData.Type == "Shield" then
        return "Shield"
    end
    
    if itemData.Type == "Weapon" then
        local occupies = itemData.Occupies
        if type(occupies) == "table" then
            local mainHand = false
            local offHand = false
            
            for _, slot in ipairs(occupies) do
                if slot == "MainHand" then
                    mainHand = true
                elseif slot == "OffHand" then
                    offHand = true
                end
            end
            
            if mainHand and offHand then
                return "TwoHandWeapon"
            end
        end
        
        return "OneHandWeapon"
    end
    
    return nil
end
 
local function ApplyEquipmentVisuals(
    player,
    character
    )
    
    if not player or not character or not player.Character then
        return false
    end
    
    EquipmentVisualService.Clear(player.Character)
    
    local equipment =
    character.Appearance
    and character.Appearance.Equipment
    
    if type(equipment) ~= "table" then
        return true
    end
    
    local applied = {}
    
    for _, itemId in pairs(equipment) do
        if itemId and not applied[itemId] then
            applied[itemId] = true
            
            local itemData =
            ItemCatalog.GetItem(itemId)
            
            local renderProfile =
            GetEquipmentRenderProfile(itemData)
            
            -- Armor/clothing visuals remain in the existing
            -- AppearanceManager pipeline for now. The physical
            -- equipment service is currently responsible only
            -- for weapon/shield models.
            if itemData
                and itemData.AppearanceId
                and renderProfile then
                
                local visualData = {}
                for key, value in pairs(itemData) do
                    visualData[key] = value
                end
                visualData.RenderProfile = renderProfile
                
                local success, reason =
                EquipmentVisualService.AttachItem(
                player.Character,
                visualData
                )
                
                if not success then
                    warn(
                    "Failed to apply equipment visual for "
                    .. tostring(itemId)
                    .. ": "
                    .. tostring(reason)
                    )
                end
            end
        end
    end
    
    return true
end
 
--------------------------------------------------
-- CHARACTER APPEARANCE
--------------------------------------------------
 
local function ApplyCharacterAppearance(
    player,
    character
    )
    
    if not player.Character then
        
        warn(
        "Cannot apply appearance: character does not exist for "
        .. player.Name
        )
        
        return false
        
    end
    
    
    local humanoid =
    player.Character:FindFirstChildOfClass(
    "Humanoid"
    )
    
    
    if not humanoid then
        
        warn(
        "Cannot apply appearance: Humanoid not found for "
        .. player.Name
        )
        
        return false
        
    end
    
    
    local description =
    AppearanceManager.BuildDescription(
    character.Appearance
    )
    
    
    if not description then
        
        warn(
        "Failed to build appearance for "
        .. character.Name
        )
        
        return false
        
    end
    
    
    local success, errorMessage =
    pcall(function()
        
        humanoid:ApplyDescription(
        description
        )
        
    end)
    
    
    description:Destroy()
    
    
    if not success then
        
        warn(
        "Failed to update character appearance: "
        .. tostring(errorMessage)
        )
        
        return false
        
    end
    
    -- Rebuild physical equipment visuals after HumanoidDescription
    -- has been applied. Applying the description can replace parts
    -- of the character model, so the visual attachments must follow it.
    ApplyEquipmentVisuals(
    player,
    character
    )
    
    return true
    
end
 
 
--------------------------------------------------
-- SPAWN CHARACTER
--------------------------------------------------
 
local function SpawnCharacter(
    player,
    character
    )
    
    local description =
    AppearanceManager.BuildDescription(
    character.Appearance
    )
    
    
    if not description then
        
        warn(
        "Failed to build appearance for "
        .. character.Name
        )
        
        return false
        
    end
    
    
    local success, errorMessage =
    pcall(function()
        
        player:LoadCharacterWithHumanoidDescription(
        description
        )
        
    end)
    
    
    description:Destroy()
    
    
    if not success then
        
        warn(
        "Failed to spawn YAMA character: "
        .. tostring(errorMessage)
        )
        
        return false
        
    end
    
    
    --------------------------------------------------
    -- LOAD SAVED POSITION
    --------------------------------------------------
    
    if character.Position then
        
        local x = character.Position.X
        local y = character.Position.Y
        local z = character.Position.Z
        
        
        if x ~= nil
            and y ~= nil
            and z ~= nil then
            
            local rootPart =
            player.Character:WaitForChild(
            "HumanoidRootPart",
            5
            )
            
            
            if rootPart then
                
                rootPart.CFrame =
                CFrame.new(
                x,
                y,
                z
                )
                
                
                print("--------------------------------")
                print("SAVED POSITION LOADED")
                print("Character: " .. character.Name)
                print("X: " .. tostring(x))
                print("Y: " .. tostring(y))
                print("Z: " .. tostring(z))
                print("--------------------------------")
                
            else
                
                warn(
                "HumanoidRootPart not found while loading position for "
                .. character.Name
                )
                
            end
            
        end
        
    end
    
    -- Restore physical equipment visuals after the character model
    -- has been created and positioned. Visual failures do not prevent
    -- the character itself from spawning.
    ApplyEquipmentVisuals(
    player,
    character
    )
    
    return true
    
end
 
 
--------------------------------------------------
-- SERVER START
--------------------------------------------------
 
print("================================")
print("YAMA: LEGENDS")
print("Game Server Started")
print("================================")
 
 
--------------------------------------------------
-- PLAYER ADDED
--------------------------------------------------
 
Players.PlayerAdded:Connect(function(player)
    
    print("Player joined: " .. player.Name)
    
    CharacterManager.LoadPlayer(player)
    
end)
 
 
--------------------------------------------------
-- PLAYER REMOVING
--------------------------------------------------
 
Players.PlayerRemoving:Connect(function(player)
    
    print("Player leaving: " .. player.Name)
    
    
    CharacterManager.SavePlayer(player)
    
    
    local prefix =
    tostring(player.UserId) .. "_"
    
    for _, preview in ipairs(
        previewFolder:GetChildren()
        ) do
        
        if string.sub(
            preview.Name,
            1,
            #prefix
            ) == prefix then
            
            preview:Destroy()
            
        end
        
    end
    
    
    CharacterManager.RemovePlayer(player)
    
end)
 
 
--------------------------------------------------
-- AUTO SAVE
--------------------------------------------------
 
local function AutoSavePlayer(player)
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    
    if character then
        
        CharacterManager.SaveActiveCharacterPosition(
        player
        )
        
    end
    
    
    CharacterManager.SavePlayer(player)
    
end
 
 
task.spawn(function()
    
    while true do
        
        task.wait(AUTO_SAVE_INTERVAL)
        
        
        for _, player
            in ipairs(Players:GetPlayers()) do
            
            AutoSavePlayer(player)
            
        end
        
    end
    
end)
 
 
--------------------------------------------------
-- CHARACTER REMOTE
--------------------------------------------------
 
CharacterRemote.OnServerEvent:Connect(
function(player, action, value)
    
    print("Remote request from: " .. player.Name)
    print("Action: " .. tostring(action))
    
    
    --------------------------------------------------
    -- GET CHARACTERS
    --------------------------------------------------
    
    if action == "GetCharacters" then
        
        local characters =
        CharacterManager.GetCharacters(
        player
        )
        
        
        CharacterRemote:FireClient(
        player,
        "CharacterList",
        characters
        )
        
    elseif action == "GetCreationPreview" then
        
        local customization = typeof(value) == "table" and value or {}
        
        local options = AppearanceManager.GetCreationOptions() or {}
        local catalog = AppearanceManager.GetAppearanceCatalog() or {}
        
        local function makeOptionList(source)
            local list = {}
            for key, data in pairs(source or {}) do
                if key ~= "Default" then
                    local displayName = key
                    if typeof(data) == "table" and data.DisplayName then
                        displayName = tostring(data.DisplayName)
                    end
                    table.insert(list, {Id = key, Name = displayName})
                end
            end
            table.sort(list, function(a,b) return tostring(a.Name) < tostring(b.Name) end)
                return list
            end
            
            local optionPayload = {
            Skin = makeOptionList(options.Skin),
            Hair = makeOptionList(catalog.Hair),
            Face = makeOptionList(catalog.Face),
            }
            
            CharacterRemote:FireClient(player, "CreationAppearanceOptions", optionPayload)
            
            if not customization.Skin then
                local firstSkin = optionPayload.Skin[1]
                if firstSkin then customization.Skin = firstSkin.Id end
            end
            if not customization.Hair then customization.Hair = "Pal_Hair" end
            if not customization.Face then customization.Face = "Face01" end
            
            local creationAppearance = AppearanceManager.GetCreationAppearance(customization)
            local description = AppearanceManager.BuildDescription(creationAppearance)
            local previewModel
            
            if description then
                local success, result = pcall(function()
                    return Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
                end)
                description:Destroy()
                if success then
                    previewModel = result
                else
                    warn("Failed to create creation preview: " .. tostring(result))
                end
            end
            
            if previewModel then
                previewModel.Name = tostring(player.UserId) .. "_CreationPreview"
                previewModel:SetAttribute("YAMA_Preview", true)
                for _, object in ipairs(previewModel:GetDescendants()) do
                    if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") then
                        object:Destroy()
                    elseif object:IsA("BasePart") then
                        object.Anchored = true
                        object.CanCollide = false
                        object.CanTouch = false
                        object.CanQuery = false
                    end
                end
                local oldPreview = previewFolder:FindFirstChild(previewModel.Name)
                if oldPreview then oldPreview:Destroy() end
                previewModel.Parent = previewFolder
                task.delay(60, function()
                    if previewModel and previewModel.Parent == previewFolder then previewModel:Destroy() end
                end)
                CharacterRemote:FireClient(player, "CreationAppearancePreview", {
                PreviewName = previewModel.Name,
                Customization = customization,
                })
            else
                CharacterRemote:FireClient(player, "CreationAppearancePreviewFailed", "PREVIEW_GENERATION_FAILED")
            end
            
        elseif action == "GetCharacterPreview" then
            
            local characterId = value
            local characters =
            CharacterManager.GetCharacters(
            player
            )
            
            local character
            
            for _, candidate in ipairs(characters) do
                if candidate.Id == characterId then
                    character = candidate
                    break
                end
            end
            
            if character then
                
                local previewModel =
                GetCharacterPreview(
                player,
                character
                )
                
                if previewModel then
                    
                    CharacterRemote:FireClient(
                    player,
                    "CharacterPreview",
                    {
                    CharacterId = character.Id,
                    PreviewName = previewModel.Name
                    }
                    )
                    
                end
                
            end
            
            
        elseif action == "OpenInventory" then
            
            print("--------------------------------")
            print("INVENTORY REQUEST")
            print("Player: " .. player.Name)
            print("--------------------------------")
            
            
            local inventoryState =
            InventoryService.GetState(
            player
            )
            
            
            CharacterRemote:FireClient(
            player,
            "InventoryOpened",
            inventoryState
            )
            
            --------------------------------------------------
            -- CREATE CHARACTER
            --------------------------------------------------
            
        elseif action == "MoveItemToStorage" then
            
            local payload =
            typeof(value) == "table" and value or {}
            
            local itemId = payload.ItemId
            local quantity = payload.Quantity
            
            print("MOVE INVENTORY -> STORAGE")
            print("Item: " .. tostring(itemId))
            print("Quantity: " .. tostring(quantity))
            
            local success, reason =
            InventoryService.MoveToStorage(
            player,
            itemId,
            quantity
            )
            
            if success then
                CharacterRemote:FireClient(
                player,
                "InventoryActionResult",
                InventoryService.GetState(player)
                )
            else
                warn("Move to storage failed: " .. tostring(reason))
                CharacterRemote:FireClient(
                player,
                "InventoryActionFailed",
                reason or "MOVE_TO_STORAGE_FAILED"
                )
            end
            
        elseif action == "MoveItemFromStorage" then
            
            local payload =
            typeof(value) == "table" and value or {}
            
            local itemId = payload.ItemId
            local quantity = payload.Quantity
            
            print("MOVE STORAGE -> INVENTORY")
            print("Item: " .. tostring(itemId))
            print("Quantity: " .. tostring(quantity))
            
            local success, reason =
            InventoryService.MoveFromStorage(
            player,
            itemId,
            quantity
            )
            
            if success then
                CharacterRemote:FireClient(
                player,
                "InventoryActionResult",
                InventoryService.GetState(player)
                )
            else
                warn("Move from storage failed: " .. tostring(reason))
                CharacterRemote:FireClient(
                player,
                "InventoryActionFailed",
                reason or "MOVE_FROM_STORAGE_FAILED"
                )
            end
            
        elseif action == "DropItem" then
            
            local payload =
            typeof(value) == "table" and value or {}
            
            local itemId = payload.ItemId
            local quantity = payload.Quantity
            
            print("DROP ITEM")
            print("Item: " .. tostring(itemId))
            print("Quantity: " .. tostring(quantity))
            
            local success, result =
            InventoryService.DropFromInventory(
            player,
            itemId,
            quantity
            )
            
            if success then
                CharacterRemote:FireClient(
                player,
                "InventoryActionResult",
                InventoryService.GetState(player)
                )
            else
                warn("Drop item failed: " .. tostring(result))
                CharacterRemote:FireClient(
                player,
                "InventoryActionFailed",
                result or "DROP_FAILED"
                )
            end
            
            --------------------------------------------------
            -- CREATE CHARACTER
            --------------------------------------------------
        elseif action == "CreateCharacter" then
            
            local payload = value
            
            if typeof(payload) ~= "table" then
                
                CharacterRemote:FireClient(
                player,
                "CharacterCreationFailed",
                "INVALID_NAME"
                )
                
                return
                
            end
            
            
            local characterName = payload.Name
            local attributes = payload.Attributes
            local customization = payload.Customization
            
            
            local character,
            success,
            reason =
            CharacterManager.CreateCharacter(
            player,
            characterName,
            attributes,
            customization
            )
            
            
            if success then
                
                CharacterRemote:FireClient(
                player,
                "CharacterCreated",
                character
                )
                
            else
                
                CharacterRemote:FireClient(
                player,
                "CharacterCreationFailed",
                reason
                )
                
            end
            
            
            --------------------------------------------------
            -- SELECT CHARACTER
            --------------------------------------------------
            
        elseif action == "SelectCharacter" then
            
            local characterId = value
            
            
            local character =
            CharacterManager.SelectCharacter(
            player,
            characterId
            )
            
            
            if not character then
                
                CharacterRemote:FireClient(
                player,
                "CharacterSelectionFailed"
                )
                
                return
                
            end
            
            
            print(
            "Selected character: "
            .. character.Name
            )
            
            
            --------------------------------------------------
            -- SET ACTIVE CHARACTER
            --------------------------------------------------
            
            local activeSet =
            CharacterManager.SetActiveCharacter(
            player,
            character.Id
            )
            
            
            if not activeSet then
                
                CharacterRemote:FireClient(
                player,
                "CharacterSelectionFailed"
                )
                
                return
                
            end
            
            
            --------------------------------------------------
            -- SPAWN
            --------------------------------------------------
            
            local success =
            SpawnCharacter(
            player,
            character
            )
            
            
            if success then
                
                print("--------------------------------")
                print("YAMA CHARACTER SPAWNED")
                print("Player: " .. player.Name)
                print("Character: " .. character.Name)
                print("Class: " .. character.Class)
                print(
                "Appearance Class: "
                .. tostring(character.Appearance.Class))
                print("--------------------------------")
                
                
                CharacterRemote:FireClient(
                player,
                "CharacterSelected",
                character
                )
                
            else
                
                CharacterManager.ClearActiveCharacter(
                player
                )
                
                
                CharacterRemote:FireClient(
                player,
                "CharacterSpawnFailed"
                )
                
            end
            
            
            --------------------------------------------------
            -- CHANGE CHARACTER
            --------------------------------------------------
            
        elseif action == "ChangeCharacter" then
            
            print("--------------------------------")
            print("CHARACTER CHANGE REQUEST")
            print("Player: " .. player.Name)
            print("--------------------------------")
            
            
            --------------------------------------------------
            -- SAVE CURRENT CHARACTER
            --------------------------------------------------
            
            CharacterManager.SavePlayer(
            player
            )
            
            
            --------------------------------------------------
            -- REMOVE CURRENT CHARACTER MODEL
            --------------------------------------------------
            
            if player.Character then
                
                player.Character:Destroy()
                
            end
            
            
            --------------------------------------------------
            -- CLEAR ACTIVE CHARACTER
            --------------------------------------------------
            
            CharacterManager.ClearActiveCharacter(
            player
            )
            
            
            -- Remove this player's temporary preview models.
            local prefix =
            tostring(player.UserId) .. "_"
            
            for _, preview in ipairs(
                previewFolder:GetChildren()
                ) do
                
                if string.sub(
                    preview.Name,
                    1,
                    #prefix
                    ) == prefix then
                    
                    preview:Destroy()
                    
                end
                
            end
            
            
            --------------------------------------------------
            -- RETURN TO MAIN MENU
            --------------------------------------------------
            
            CharacterRemote:FireClient(
            player,
            "EnterMainMenu"
            )
            
            
            --------------------------------------------------
            -- EXIT GAME
            --------------------------------------------------
            
        elseif action == "ExitGame" then
            
            print("--------------------------------")
            print("EXIT REQUEST")
            print("Player: " .. player.Name)
            print("--------------------------------")
            
            
            --------------------------------------------------
            -- SAVE EVERYTHING
            --------------------------------------------------
            
            CharacterManager.SavePlayer(
            player
            )
            
            
            --------------------------------------------------
            -- KICK PLAYER
            --------------------------------------------------
            
            player:Kick(
            "Thank you for playing YAMA: Legends!"
            )
            
            
            --------------------------------------------------
            -- EQUIP ITEM
            --------------------------------------------------
            
        elseif action == "EquipItem" then
            
            local itemId = value
            
            print("--------------------------------")
            print("EQUIP ITEM REQUEST")
            print("Player: " .. player.Name)
            print("Item ID: " .. tostring(itemId))
            print("--------------------------------")
            
            local success,
            reason =
            CharacterManager.EquipItem(
            player,
            itemId
            )
            
            if not success then
                CharacterRemote:FireClient(
                player,
                "ItemEquipFailed",
                reason or "EQUIP_FAILED"
                )
                
                return
            end
            
            local character =
            CharacterManager.GetActiveCharacter(
            player
            )
            
            if not character then
                CharacterRemote:FireClient(
                player,
                "ItemEquipFailed",
                "NO_ACTIVE_CHARACTER"
                )
                
                return
            end
            
            local appearanceSuccess =
            ApplyCharacterAppearance(
            player,
            character
            )
            
            if not appearanceSuccess then
                warn(
                "Item equip succeeded, but appearance refresh failed"
                )
            end
            
            print("--------------------------------")
            print("ITEM EQUIPPED")
            print("Character: " .. character.Name)
            print("Item: " .. tostring(itemId))
            print("--------------------------------")
            
            CharacterRemote:FireClient(
            player,
            "InventoryActionResult",
            InventoryService.GetState(player)
            )
            
            CharacterRemote:FireClient(
            player,
            "ItemEquipped",
            character
            )
            
            
            --------------------------------------------------
            -- UNEQUIP EQUIPMENT
            --------------------------------------------------
            
        elseif action == "UnequipItem" then
            
            local itemId = value
            
            local success,
            reason =
            CharacterManager.UnequipItem(
            player,
            itemId
            )
            
            if not success then
                CharacterRemote:FireClient(
                player,
                "ItemUnequipFailed",
                reason or "UNEQUIP_FAILED"
                )
                
                return
            end
            
            local character =
            CharacterManager.GetActiveCharacter(
            player
            )
            
            if character then
                ApplyCharacterAppearance(
                player,
                character
                )
            end
            
            CharacterRemote:FireClient(
            player,
            "InventoryActionResult",
            InventoryService.GetState(player)
            )
            
            CharacterRemote:FireClient(
            player,
            "ItemUnequipped",
            character
            )
            
            
            --------------------------------------------------
            -- UNEQUIP COSMETIC / VISUAL
            --------------------------------------------------
            
        elseif action == "UnequipCosmetic" then
            
            local visualSlot = value
            
            local success,
            reason =
            CharacterManager.UnequipCosmetic(
            player,
            visualSlot
            )
            
            if not success then
                CharacterRemote:FireClient(
                player,
                "ItemUnequipFailed",
                reason or "UNEQUIP_FAILED"
                )
                
                return
            end
            
            local character =
            CharacterManager.GetActiveCharacter(
            player
            )
            
            if character then
                ApplyCharacterAppearance(
                player,
                character
                )
            end
            
            CharacterRemote:FireClient(
            player,
            "InventoryActionResult",
            InventoryService.GetState(player)
            )
            
            CharacterRemote:FireClient(
            player,
            "ItemUnequipped",
            character
            )
            
            
            ------TEMPORARY ITEM------
        elseif action == "AddTestItem" then
            
            print("--------------------------------")
            print("ADDING TEST ITEM")
            print("Player: " .. player.Name)
            print("--------------------------------")
            
            local success =
            CharacterManager.AddItem(
            player,
            "Warrior_Hair"
            )
            
            if success then
                
                print("TEST ITEM ADDED SUCCESSFULLY")
                
                CharacterRemote:FireClient(
                player,
                "TestItemAdded"
                )
                
            else
                
                warn("FAILED TO ADD TEST ITEM")
                
                CharacterRemote:FireClient(
                player,
                "TestItemAddFailed"
                )
                
            end
            -----FIM TEMP ITEM-----
            
            
            
            --------------------------------------------------
            -- DELETE CHARACTER
            --------------------------------------------------
            
        elseif action == "DeleteCharacter" then
            
            local characterId = value
            
            
            local success =
            CharacterManager.DeleteCharacter(
            player,
            characterId
            )
            
            
            if success then
                
                CharacterRemote:FireClient(
                player,
                "CharacterDeleted"
                )
                
            else
                
                CharacterRemote:FireClient(
                player,
                "CharacterDeletionFailed"
                )
                
            end
            
        end
        
    end
    )
