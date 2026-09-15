-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- ITEM DROP SERVICE V3
--------------------------------------------------
--
-- World drops are independent objects.
-- A monster, chest, quest, event or player may create one.
-- This module never assumes the source has an Inventory.
--
-- V3:
-- * 3D catalog asset visuals
-- * Cached asset templates
-- * Click/tap pickup through ClickDetector
-- * Quantity attribute kept on the world object
--------------------------------------------------

local HttpService = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local ItemCatalog =
require(script.Parent.Catalog.ItemCatalog)

local ItemDropService = {}

local DROP_FOLDER_NAME = "YAMA_ItemDrops"
local CLICK_DISTANCE = 14
local MAX_VISUAL_SIZE = 2.25

local dropFolder =
Workspace:FindFirstChild(DROP_FOLDER_NAME)

if not dropFolder then
    dropFolder = Instance.new("Folder")
    dropFolder.Name = DROP_FOLDER_NAME
    dropFolder.Parent = Workspace
end

local drops = {}
local assetTemplates = {}
local pickupHandler = nil

local function normalizeQuantity(quantity)
    quantity = tonumber(quantity) or 1
    quantity = math.floor(quantity)
    if quantity < 1 then
        return nil
    end
    return quantity
end

--------------------------------------------------
-- PICKUP HANDLER
--------------------------------------------------

function ItemDropService.SetPickupHandler(handler)
    pickupHandler = handler
end

--------------------------------------------------
-- ASSET TEMPLATE
--------------------------------------------------

local function getWorldAssetId(itemId)
    local data = ItemCatalog.GetItem(itemId)
    if not data then
        return nil
    end
    
    return tonumber(
    data.WorldAssetId
    or data.AssetId
    )
end


local function loadAssetTemplate(itemId)
    local assetId = getWorldAssetId(itemId)
    if not assetId then
        return nil
    end
    
    if assetTemplates[assetId] then
        return assetTemplates[assetId]:Clone()
    end
    
    local success, loaded = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)
    
    if not success or not loaded then
        warn(
        "Failed to load world item asset "
        .. tostring(assetId)
        .. " for "
        .. tostring(itemId)
        .. ": "
        .. tostring(loaded)
        )
        return nil
    end
    
    local template
    
    if loaded:IsA("Model") then
        template = loaded
    else
        template = Instance.new("Model")
        loaded.Parent = template
    end
    
    template.Name = "WorldItemTemplate_" .. tostring(itemId)
    
    for _, object in ipairs(template:GetDescendants()) do
        if object:IsA("Script")
            or object:IsA("LocalScript") then
            object:Destroy()
        elseif object:IsA("BasePart") then
            object.Anchored = true
            object.CanCollide = false
            object.CanTouch = false
            object.CanQuery = true
        end
    end
    
    assetTemplates[assetId] = template
    
    return template:Clone()
end

--------------------------------------------------
-- FALLBACK VISUAL
--------------------------------------------------

local function createFallbackVisual(itemId)
    local part = Instance.new("Part")
    part.Name = "FallbackVisual"
    part.Size = Vector3.new(1.4, 0.7, 1.4)
    part.Shape = Enum.PartType.Block
    part.Material = Enum.Material.SmoothPlastic
    part.Color = Color3.fromRGB(184, 145, 82)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = true
    
    local data = ItemCatalog.GetItem(itemId) or {}
    if data.Type == "Consumable" then
        part.Color = Color3.fromRGB(157, 36, 49)
    elseif data.Type == "Material" then
        part.Color = Color3.fromRGB(108, 71, 36)
    elseif data.Type == "Currency" then
        part.Shape = Enum.PartType.Cylinder
        part.Color = Color3.fromRGB(255, 224, 80)
    end
    
    return part
end

--------------------------------------------------
-- VISUAL SETUP
--------------------------------------------------

local function getPrimaryPart(model)
    if not model or not model:IsA("Model") then
        return nil
    end
    
    if model.PrimaryPart then
        return model.PrimaryPart
    end
    
    local best
    local bestVolume = 0
    
    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("BasePart") then
            local volume = object.Size.X * object.Size.Y * object.Size.Z
            if volume > bestVolume then
                best = object
                bestVolume = volume
            end
        end
    end
    
    if best then
        model.PrimaryPart = best
    end
    
    return best
end


local function prepareVisual(visual, itemId, dropId, quantity, position)
    local model
    
    if visual:IsA("Model") then
        model = visual
    else
        model = Instance.new("Model")
        visual.Parent = model
    end
    
    model.Name = "DropVisual_" .. tostring(dropId)
    
    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Script")
            or object:IsA("LocalScript") then
            object:Destroy()
        elseif object:IsA("BasePart") then
            object.Anchored = true
            object.CanCollide = false
            object.CanTouch = false
            object.CanQuery = true
        end
    end
    
    local primary = getPrimaryPart(model)
    
    if not primary then
        model:Destroy()
        return nil
    end
    
    local _, size = model:GetBoundingBox()
    local largest = math.max(size.X, size.Y, size.Z)
    
    if largest > MAX_VISUAL_SIZE then
        local scale = MAX_VISUAL_SIZE / largest
        pcall(function()
            model:ScaleTo(scale)
        end)
    end
    
    model:PivotTo(CFrame.new(position))
    
    local boxCFrame, boxSize = model:GetBoundingBox()
    local bottomY = boxCFrame.Position.Y - (boxSize.Y * 0.5)
    local lift = position.Y - bottomY + 0.05
    
    model:PivotTo(
    model:GetPivot()
    + Vector3.new(0, lift, 0)
    )
    
    model:SetAttribute("DropId", dropId)
    model:SetAttribute("ItemId", itemId)
    model:SetAttribute("Quantity", quantity)
    
    model.Parent = dropFolder
    
    local clickPart = getPrimaryPart(model)
    
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = CLICK_DISTANCE
    clickDetector.Parent = clickPart
    
    clickDetector.MouseClick:Connect(function(player)
        if pickupHandler then
            pickupHandler(player, dropId)
        end
    end)
    
    return model
end

--------------------------------------------------
-- CREATE DROP
--------------------------------------------------

function ItemDropService.CreateDrop(itemId, quantity, position)
    if typeof(itemId) ~= "string" then
        return nil
    end
    
    if not ItemCatalog.GetItem(itemId) then
        warn(
        "Cannot create drop for unknown item: "
        .. tostring(itemId)
        )
        return nil
    end
    
    quantity = normalizeQuantity(quantity)
    if not quantity then
        return nil
    end
    
    local isUnique =
    ItemCatalog.IsEquipment(itemId)
    or ItemCatalog.IsCosmetic(itemId)
    
    if isUnique and quantity ~= 1 then
        return nil
    end
    
    if typeof(position) ~= "Vector3" then
        return nil
    end
    
    local dropId = HttpService:GenerateGUID(false)
    
    local visual = loadAssetTemplate(itemId)
    
    if not visual then
        visual = createFallbackVisual(itemId)
    end
    
    visual = prepareVisual(
    visual,
    itemId,
    dropId,
    quantity,
    position
    )
    
    if not visual then
        warn(
        "Could not create world visual for item: "
        .. tostring(itemId)
        )
        return nil
    end
    
    drops[dropId] = {
    DropId = dropId,
    ItemId = itemId,
    Quantity = quantity,
    Position = position,
    Instance = visual,
    }
    
    return drops[dropId]
end

--------------------------------------------------
-- GET DROP
--------------------------------------------------

function ItemDropService.GetDrop(dropId)
    if typeof(dropId) ~= "string" then
        return nil
    end
    return drops[dropId]
end

--------------------------------------------------
-- GET ALL DROPS
--------------------------------------------------

function ItemDropService.GetDrops()
    local result = {}
    
    for _, drop in pairs(drops) do
        table.insert(result, {
        DropId = drop.DropId,
        ItemId = drop.ItemId,
        Quantity = drop.Quantity,
        Position = drop.Position,
        })
    end
    
    return result
end

--------------------------------------------------
-- REDUCE DROP
--------------------------------------------------

function ItemDropService.ReduceDrop(dropId, quantity)
    local drop = ItemDropService.GetDrop(dropId)
    if not drop then
        return false
    end
    
    quantity = normalizeQuantity(quantity)
    if not quantity or quantity > drop.Quantity then
        return false
    end
    
    drop.Quantity -= quantity
    
    if drop.Instance then
        drop.Instance:SetAttribute("Quantity", drop.Quantity)
    end
    
    if drop.Quantity <= 0 then
        ItemDropService.RemoveDrop(dropId)
    end
    
    return true
end

--------------------------------------------------
-- REMOVE DROP
--------------------------------------------------

function ItemDropService.RemoveDrop(dropId)
    local drop = drops[dropId]
    if not drop then
        return false
    end
    
    if drop.Instance then
        drop.Instance:Destroy()
    end
    
    drops[dropId] = nil
    return true
end

return ItemDropService
