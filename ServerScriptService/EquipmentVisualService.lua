-- MODULE SCRIPT --
-- YAMA: LEGENDS
-- EQUIPMENT VISUAL SERVICE - PHASE 1
--
-- Loads physical Creator Store assets and attaches them to the live character.
-- This is intentionally separate from HumanoidDescription:
-- arbitrary weapon/shield models are not clothing properties.

local AssetService = game:GetService("AssetService")
local ServerStorage = game:GetService("ServerStorage")

local CatalogFolder = script.Parent:WaitForChild("Catalog")
local AssetRegistry = require(CatalogFolder:WaitForChild("AssetRegistry"))
local RenderProfiles = require(CatalogFolder:WaitForChild("RenderProfiles"))

local EquipmentVisualService = {}

local LIVE_FOLDER_NAME = "YAMA_EquipmentVisuals"

local function getLiveFolder(character)
    local folder = character:FindFirstChild(LIVE_FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = LIVE_FOLDER_NAME
        folder.Parent = character
    end
    return folder
end

local function getAttachPart(character, name)
    return character:FindFirstChild(name)
end

local function getBaseParts(instance)
    local parts = {}
    if instance:IsA("BasePart") then
        table.insert(parts, instance)
    end
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(parts, descendant)
        end
    end
    return parts
end

local function chooseRoot(instance)
    if instance:IsA("BasePart") then
        return instance
    end

    if instance:IsA("Model") and instance.PrimaryPart then
        return instance.PrimaryPart
    end

    local parts = getBaseParts(instance)
    return parts[1]
end

local function prepareModel(model)
    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript") then
            object:Destroy()
        elseif object:IsA("BasePart") then
            object.Anchored = false
            object.CanCollide = false
            object.CanTouch = false
            object.CanQuery = false
            object.Massless = true
        end
    end
end

local function weldAllToRoot(model, root)
    for _, part in ipairs(getBaseParts(model)) do
        if part ~= root then
            local weld = Instance.new("WeldConstraint")
            weld.Name = "YAMA_AssetWeld"
            weld.Part0 = root
            weld.Part1 = part
            weld.Parent = root
        end
    end
end

local function attachModel(model, character, attachmentPartName)
    local target = getAttachPart(character, attachmentPartName)
    if not target then
        return false, "Attachment part not found: " .. tostring(attachmentPartName)
    end

    local root = chooseRoot(model)
    if not root then
        return false, "Asset contains no BasePart"
    end

    if model:IsA("Model") then
        model.PrimaryPart = root
    end

    prepareModel(model)
    weldAllToRoot(model, root)

    if model:IsA("Model") then
        model:PivotTo(target.CFrame)
    else
        root.CFrame = target.CFrame
    end

    local weld = Instance.new("WeldConstraint")
    weld.Name = "YAMA_EquipmentAttachment"
    weld.Part0 = target
    weld.Part1 = root
    weld.Parent = root

    model.Parent = getLiveFolder(character)
    return true
end

function EquipmentVisualService.Clear(character)
    if not character then
        return
    end

    local folder = character:FindFirstChild(LIVE_FOLDER_NAME)
    if folder then
        folder:Destroy()
    end
end

function EquipmentVisualService.GetAppearanceId(itemData)
    if not itemData then
        return nil
    end
    return itemData.AppearanceId
end

function EquipmentVisualService.AttachItem(character, itemData)
    if not character or not itemData then
        return false, "Missing character or item data"
    end

    local appearanceId = itemData.AppearanceId
    if not appearanceId then
        return true
    end

    local assetData = AssetRegistry.Get(appearanceId)
    if not assetData or not assetData.AssetId then
        return false, "Asset not registered: " .. tostring(appearanceId)
    end

    local profile = RenderProfiles[itemData.RenderProfile or "OneHandWeapon"]
    if not profile then
        return false, "Render profile not found"
    end

    local ok, loaded = pcall(function()
        return AssetService:LoadAssetAsync(assetData.AssetId)
    end)

    if not ok or not loaded then
        return false, "Failed to load asset " .. tostring(assetData.AssetId) .. ": " .. tostring(loaded)
    end

    local rootModel = loaded
    rootModel.Name = tostring(itemData.Id) .. "_Visual"

    local success, errorMessage = attachModel(
        rootModel,
        character,
        profile.Attachment
    )

    if not success then
        rootModel:Destroy()
        return false, errorMessage
    end

    rootModel:SetAttribute("YAMA_ItemId", tostring(itemData.Id))
    rootModel:SetAttribute("YAMA_AppearanceId", tostring(appearanceId))

    return true
end

return EquipmentVisualService
