-- LOCAL SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- INVENTORY UI V1
--
-- Client-only presentation and interaction layer.
--
-- V1:
-- * Inventory grid
-- * Item selection
-- * Item details
-- * Quantity selection
-- * Move Inventory -> Storage
-- * Drop Inventory -> Ground with confirmation
--
-- Drag & Drop is intentionally prepared for a later
-- interaction pass. The server remains authoritative.
--------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local CharacterRemote = ReplicatedStorage:WaitForChild("CharacterRemote")

local UIAudio = require(
script.Parent:WaitForChild("UIAudio")
)

--------------------------------------------------
-- COLORS
--------------------------------------------------

local COLORS = {
ParchmentLight = Color3.fromRGB(252, 239, 207),
Parchment = Color3.fromRGB(231, 207, 159),
ParchmentMid = Color3.fromRGB(213, 181, 123),
ParchmentDark = Color3.fromRGB(184, 145, 82),

Wood = Color3.fromRGB(108, 71, 36),
WoodMid = Color3.fromRGB(88, 56, 28),
WoodDark = Color3.fromRGB(66, 41, 21),

Leather = Color3.fromRGB(101, 67, 34),
LeatherDark = Color3.fromRGB(64, 40, 21),

GoldBright = Color3.fromRGB(255, 224, 132),
Gold = Color3.fromRGB(216, 170, 73),
GoldDark = Color3.fromRGB(126, 87, 34),

TextDark = Color3.fromRGB(59, 39, 22),
TextMid = Color3.fromRGB(103, 72, 38),
TextLight = Color3.fromRGB(255, 239, 190),

Emerald = Color3.fromRGB(30, 126, 72),
EmeraldDark = Color3.fromRGB(12, 54, 34),

Ruby = Color3.fromRGB(157, 36, 49),
RubyDark = Color3.fromRGB(74, 17, 25),

White = Color3.fromRGB(255, 255, 255),
Black = Color3.fromRGB(0, 0, 0),
}

local MAX_INVENTORY_SLOTS = 60

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
    return corner
end

local function addStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = 0
    stroke.Parent = object
    return stroke
end

local function addGradient(object, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, color1),
    ColorSequenceKeypoint.new(1, color2),
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = object
    return gradient
end

local function tween(object, duration, properties, style, direction)
    return TweenService:Create(
    object,
    TweenInfo.new(
    duration or 0.2,
    style or Enum.EasingStyle.Quad,
    direction or Enum.EasingDirection.Out
    ),
    properties
    )
end

local function createText(parent, text, size, position, color, font, z)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = font or Enum.Font.Garamond
    label.ZIndex = z or 1
    label.Parent = parent
    return label
end

--------------------------------------------------
-- OLD GUI CLEANUP
--------------------------------------------------

local oldGui = playerGui:FindFirstChild("InventoryUI")

if oldGui then
    oldGui:Destroy()
end

--------------------------------------------------
-- SCREEN GUI
--------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 300
screenGui.Enabled = false
screenGui.Parent = playerGui

--------------------------------------------------
-- INVENTORY HUB BUTTON
--------------------------------------------------

local buttonGui = Instance.new("ScreenGui")
buttonGui.Name = "InventoryButtonUI"
buttonGui.ResetOnSpawn = false
buttonGui.IgnoreGuiInset = true
buttonGui.DisplayOrder = 299
buttonGui.Enabled = false
buttonGui.Parent = playerGui

local inventoryButton = Instance.new("TextButton")
inventoryButton.Name = "InventoryButton"
inventoryButton.Size = UDim2.fromOffset(42, 42)
inventoryButton.Position = UDim2.fromOffset(0, 7)
inventoryButton.BackgroundColor3 = COLORS.Parchment
inventoryButton.BorderSizePixel = 0
inventoryButton.Text = "🎒"
inventoryButton.TextColor3 = COLORS.GoldBright
inventoryButton.TextSize = 24
inventoryButton.Font = Enum.Font.Gotham
inventoryButton.AutoButtonColor = false
inventoryButton.ZIndex = 20
inventoryButton.Parent = buttonGui
addCorner(inventoryButton, 9)
addStroke(inventoryButton, COLORS.Gold, 2)
UIAudio.BindButton(inventoryButton, {Click = "Open"})

local function updateInventoryButtonPosition()
    -- CharacterHUD is always centered at X = 0.5 and uses 20% of the
    -- screen width. Put the backpack immediately to its right.
    inventoryButton.AnchorPoint = Vector2.new(0, 0)
    inventoryButton.Position = UDim2.new(0.60, 6, 0, 7)
end

updateInventoryButtonPosition()

--------------------------------------------------
-- ROOT
--------------------------------------------------

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = COLORS.Black
root.BackgroundTransparency = 0.38
root.BorderSizePixel = 0
root.Parent = screenGui

--------------------------------------------------
-- MAIN PANEL
--------------------------------------------------

local panel = Instance.new("Frame")
panel.Name = "InventoryPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.92, 0.84)
panel.BackgroundColor3 = COLORS.Parchment
panel.BorderSizePixel = 0
panel.Parent = root

addCorner(panel, 14)
addStroke(panel, COLORS.GoldDark, 3)
addGradient(panel, COLORS.ParchmentLight, COLORS.ParchmentDark, 90)

--------------------------------------------------
-- TOP DECORATION
--------------------------------------------------

createText(
panel,
"✦ ───────── ◆ ───────── ✦",
UDim2.fromScale(0.72, 0.055),
UDim2.fromScale(0.14, 0.018),
COLORS.GoldDark,
Enum.Font.Fantasy,
2
)

createText(
panel,
"INVENTORY",
UDim2.fromScale(0.56, 0.105),
UDim2.fromScale(0.22, 0.07),
COLORS.TextDark,
Enum.Font.Fantasy,
3
)

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.fromScale(0.075, 0.075)
closeButton.Position = UDim2.fromScale(0.905, 0.035)
closeButton.BackgroundColor3 = COLORS.WoodDark
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = COLORS.GoldBright
closeButton.TextScaled = true
closeButton.Font = Enum.Font.Fantasy
closeButton.AutoButtonColor = false
closeButton.ZIndex = 10
closeButton.Parent = panel
addCorner(closeButton, 8)
addStroke(closeButton, COLORS.Gold, 2)
UIAudio.BindButton(closeButton, {Click = "Close"})

--------------------------------------------------
-- INVENTORY AREA
--------------------------------------------------

local inventoryArea = Instance.new("Frame")
inventoryArea.Name = "InventoryArea"
inventoryArea.Size = UDim2.fromScale(0.59, 0.73)
inventoryArea.Position = UDim2.fromScale(0.035, 0.19)
inventoryArea.BackgroundColor3 = COLORS.LeatherDark
inventoryArea.BorderSizePixel = 0
inventoryArea.Parent = panel
addCorner(inventoryArea, 10)
addStroke(inventoryArea, COLORS.GoldDark, 2)

createText(
inventoryArea,
"ITEMS",
UDim2.fromScale(0.28, 0.08),
UDim2.fromScale(0.035, 0.02),
COLORS.GoldBright,
Enum.Font.Fantasy,
5
)

--------------------------------------------------
-- GRID
--------------------------------------------------

local itemGrid = Instance.new("ScrollingFrame")
itemGrid.Name = "ItemGrid"
itemGrid.Size = UDim2.new(1, -18, 1, -58)
itemGrid.Position = UDim2.new(0, 9, 0, 45)
itemGrid.BackgroundTransparency = 1
itemGrid.BorderSizePixel = 0
itemGrid.ScrollBarThickness = 5
itemGrid.ScrollBarImageColor3 = COLORS.Gold
itemGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
itemGrid.Parent = inventoryArea

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0.22, 0, 0, 105)
gridLayout.CellPadding = UDim2.new(0.025, 0, 0, 10)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = itemGrid

--------------------------------------------------
-- DETAILS AREA
--------------------------------------------------

local details = Instance.new("Frame")
details.Name = "ItemDetails"
details.Size = UDim2.fromScale(0.335, 0.73)
details.Position = UDim2.fromScale(0.65, 0.19)
details.BackgroundColor3 = COLORS.Leather
details.BorderSizePixel = 0
details.Parent = panel
addCorner(details, 10)
addStroke(details, COLORS.GoldDark, 2)

createText(
details,
"ITEM DETAILS",
UDim2.fromScale(0.86, 0.08),
UDim2.fromScale(0.07, 0.035),
COLORS.GoldBright,
Enum.Font.Fantasy,
5
)

local selectedName = createText(
details,
"Select an item",
UDim2.fromScale(0.86, 0.11),
UDim2.fromScale(0.07, 0.14),
COLORS.TextLight,
Enum.Font.Fantasy,
5
)

local selectedCategory = createText(
details,
"",
UDim2.fromScale(0.86, 0.07),
UDim2.fromScale(0.07, 0.255),
COLORS.GoldBright,
Enum.Font.Garamond,
5
)

local selectedQuantity = createText(
details,
"",
UDim2.fromScale(0.86, 0.07),
UDim2.fromScale(0.07, 0.325),
COLORS.TextLight,
Enum.Font.Garamond,
5
)

local selectedDescription = createText(
details,
"",
UDim2.fromScale(0.86, 0.22),
UDim2.fromScale(0.07, 0.405),
COLORS.TextLight,
Enum.Font.Garamond,
5
)

--------------------------------------------------
-- ACTION BUTTONS
--------------------------------------------------

local storageButton = Instance.new("TextButton")
storageButton.Name = "MoveToStorage"
storageButton.Size = UDim2.fromScale(0.86, 0.105)
storageButton.Position = UDim2.fromScale(0.07, 0.66)
storageButton.BackgroundColor3 = COLORS.Emerald
storageButton.BorderSizePixel = 0
storageButton.Text = "MOVE TO STORAGE"
storageButton.TextColor3 = COLORS.GoldBright
storageButton.TextScaled = true
storageButton.Font = Enum.Font.Fantasy
storageButton.AutoButtonColor = false
storageButton.ZIndex = 5
storageButton.Parent = details
addCorner(storageButton, 8)
addStroke(storageButton, COLORS.Gold, 2)
addGradient(storageButton, Color3.fromRGB(89, 201, 128), COLORS.EmeraldDark, 90)
UIAudio.BindButton(storageButton, {Click = "Confirm"})

local dropButton = Instance.new("TextButton")
dropButton.Name = "Drop"
dropButton.Size = UDim2.fromScale(0.86, 0.105)
dropButton.Position = UDim2.fromScale(0.07, 0.79)
dropButton.BackgroundColor3 = COLORS.Ruby
dropButton.BorderSizePixel = 0
dropButton.Text = "DROP"
dropButton.TextColor3 = COLORS.GoldBright
dropButton.TextScaled = true
dropButton.Font = Enum.Font.Fantasy
dropButton.AutoButtonColor = false
dropButton.ZIndex = 5
dropButton.Parent = details
addCorner(dropButton, 8)
addStroke(dropButton, COLORS.Gold, 2)
addGradient(dropButton, Color3.fromRGB(231, 81, 96), COLORS.RubyDark, 90)
UIAudio.BindButton(dropButton, {Click = "Drop"})

local storageOpenButton = Instance.new("TextButton")
storageOpenButton.Name = "OpenStorage"
storageOpenButton.Size = UDim2.fromScale(0.86, 0.075)
storageOpenButton.Position = UDim2.fromScale(0.07, 0.915)
storageOpenButton.BackgroundColor3 = COLORS.Wood
storageOpenButton.BorderSizePixel = 0
storageOpenButton.Text = "OPEN STORAGE"
storageOpenButton.TextColor3 = COLORS.GoldBright
storageOpenButton.TextScaled = true
storageOpenButton.Font = Enum.Font.Fantasy
storageOpenButton.AutoButtonColor = false
storageOpenButton.ZIndex = 5
storageOpenButton.Parent = details
addCorner(storageOpenButton, 8)
addStroke(storageOpenButton, COLORS.Gold, 2)
UIAudio.BindButton(storageOpenButton, {Click = "Open"})

--------------------------------------------------
-- EMPTY / STATUS
--------------------------------------------------

local statusLabel = createText(
inventoryArea,
"",
UDim2.fromScale(0.86, 0.08),
UDim2.fromScale(0.07, 0.89),
COLORS.GoldBright,
Enum.Font.Garamond,
6
)

--------------------------------------------------
-- STATE
--------------------------------------------------

--------------------------------------------------
-- ITEM ICON
--------------------------------------------------

local function iconFor(data)
    local itemType = tostring((data or {}).Type or "")
    
    if itemType == "Weapon"
        or itemType == "Armor"
        or itemType == "Shield" then
        return "EQUIP"
    elseif itemType == "Consumable" then
        return "USE"
    elseif itemType == "Material" then
        return "MAT"
    elseif itemType == "QuestItem" then
        return "QUEST"
    elseif itemType == "Currency" then
        return "COIN"
    elseif itemType == "Hair"
        or itemType == "WeaponSkin"
        or itemType == "ArmorSkin" then
        return "COS"
    end
    
    return "ITEM"
end


local function getIconImage(data)
    local assetId = tonumber(
    (data or {}).IconAssetId
    or (data or {}).WorldAssetId
    or (data or {}).AssetId
    )
    
    if not assetId then
        return nil
    end
    
    return "rbxthumb://type=Asset&id="
    .. tostring(assetId)
    .. "&w=150&h=150"
end



local inventoryState = {}
local inventorySlotsState = 0
local inventoryMaxSlotsState = MAX_INVENTORY_SLOTS
local selectedItemId = nil
local selectedQuantityValue = 1

local dragEntry = nil
local dragInput = nil
local dragGhost = nil
local dragActive = false
local dragMoved = false
local dragStartPosition = nil
local handleDragDrop = nil

local function pointInside(guiObject, position)
    local absolute = guiObject.AbsolutePosition
    local size = guiObject.AbsoluteSize
    
    return position.X >= absolute.X
    and position.X <= absolute.X + size.X
    and position.Y >= absolute.Y
    and position.Y <= absolute.Y + size.Y
end

local function cancelDrag()
    if dragGhost then
        dragGhost:Destroy()
        dragGhost = nil
    end
    
    dragEntry = nil
    dragInput = nil
    dragActive = false
    dragMoved = false
    dragStartPosition = nil
end

local function updateDragGhost(position)
    if dragGhost then
        dragGhost.Position = UDim2.fromOffset(
        position.X - 45,
        position.Y - 45
        )
    end
end

local function beginDrag(entry, input)
    if dragActive then
        return
    end
    
    dragEntry = entry
    dragInput = input
    dragActive = true
    dragMoved = false
    dragStartPosition = Vector2.new(
    input.Position.X,
    input.Position.Y
    )
    
    dragGhost = Instance.new("Frame")
    dragGhost.Name = "DragGhost"
    dragGhost.Size = UDim2.fromOffset(90, 90)
    dragGhost.BackgroundColor3 = COLORS.WoodMid
    dragGhost.BackgroundTransparency = 0.12
    dragGhost.BorderSizePixel = 0
    dragGhost.ZIndex = 500
    dragGhost.Parent = screenGui
    addCorner(dragGhost, 10)
    addStroke(dragGhost, COLORS.GoldBright, 2)
    
    local data = entry.Data or {}
    
    local image = Instance.new("ImageLabel")
    image.Size = UDim2.fromScale(0.72, 0.72)
    image.Position = UDim2.fromScale(0.14, 0.06)
    image.BackgroundTransparency = 1
    image.Image = getIconImage(data) or ""
    image.ScaleType = Enum.ScaleType.Fit
    image.ZIndex = 501
    image.Parent = dragGhost
    
    local fallback = createText(
    dragGhost,
    iconFor(data),
    UDim2.fromScale(0.8, 0.55),
    UDim2.fromScale(0.1, 0.1),
    COLORS.GoldBright,
    Enum.Font.Fantasy,
    501
    )
    
    if image.Image ~= "" then
        fallback.Visible = false
    end
    
    updateDragGhost(dragStartPosition)
    UIAudio.Play("Select")
end

UserInputService.InputChanged:Connect(function(input)
    if not dragActive or not dragInput then
        return
    end
    
    local isMovement =
    input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch
    
    if input == dragInput or isMovement then
        local position = Vector2.new(
        input.Position.X,
        input.Position.Y
        )
        
        if dragStartPosition
            and (position - dragStartPosition).Magnitude >= 8 then
            dragMoved = true
        end
        
        updateDragGhost(position)
    end
end)

--------------------------------------------------
-- BUTTON ENABLE STATE
--------------------------------------------------

local function setActionEnabled(button, enabled)
    button.Active = enabled
    button.Selectable = enabled
    button.AutoButtonColor = false
    button.TextTransparency = enabled and 0 or 0.5
end

local function updateActionButtons()
    local entry
    
    for _, item in ipairs(inventoryState) do
        if item.ItemId == selectedItemId then
            entry = item
            break
        end
    end
    
    local enabled = entry ~= nil and (tonumber(entry.Quantity) or 0) > 0
    
    setActionEnabled(storageButton, enabled)
    setActionEnabled(dropButton, enabled)
end

--------------------------------------------------
-- DETAILS
--------------------------------------------------

local function updateDetails()
    if not selectedItemId then
        selectedName.Text = "Select an item"
        selectedCategory.Text = ""
        selectedQuantity.Text = ""
        selectedDescription.Text = ""
        updateActionButtons()
        return
    end
    
    local entry
    
    for _, item in ipairs(inventoryState) do
        if item.ItemId == selectedItemId then
            entry = item
            break
        end
    end
    
    if not entry then
        selectedItemId = nil
        updateDetails()
        return
    end
    
    local data = entry.Data or {}
    
    selectedName.Text = data.Name or entry.ItemId
    selectedCategory.Text =
    tostring(data.Type or "Item")
    .. "  •  x"
    .. tostring(entry.Quantity or 1)
    
    selectedQuantity.Text =
    "Quantity available: "
    .. tostring(entry.Quantity or 1)
    
    selectedDescription.Text =
    data.Description
    or "No description available."
    
    updateActionButtons()
end

--------------------------------------------------
-- CREATE ITEM CARD
--------------------------------------------------

local function createItemCard(entry, order)
    local data = entry.Data or {}
    
    local card = Instance.new("TextButton")
    card.Name = "Item_" .. tostring(entry.ItemId)
    card.LayoutOrder = order
    card.BackgroundColor3 = COLORS.WoodMid
    card.BorderSizePixel = 0
    card.Text = ""
    card.AutoButtonColor = false
    card.ZIndex = 5
    card.Parent = itemGrid
    
    addCorner(card, 8)
    
    local stroke = addStroke(
    card,
    COLORS.GoldDark,
    1.5
    )
    
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "ItemIcon"
    iconImage.Size = UDim2.fromScale(0.62, 0.48)
    iconImage.Position = UDim2.fromScale(0.19, 0.06)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = getIconImage(data) or ""
    iconImage.ScaleType = Enum.ScaleType.Fit
    iconImage.ZIndex = 6
    iconImage.Parent = card
    
    local iconFallback = createText(
    card,
    iconFor(data),
    UDim2.fromScale(0.82, 0.42),
    UDim2.fromScale(0.09, 0.09),
    COLORS.GoldBright,
    Enum.Font.Fantasy,
    6
    )
    
    if iconImage.Image ~= "" then
        iconFallback.Visible = false
    end
    
    local name = createText(
    card,
    data.Name or entry.ItemId,
    UDim2.fromScale(0.9, 0.28),
    UDim2.fromScale(0.05, 0.52),
    COLORS.TextLight,
    Enum.Font.Garamond,
    6
    )
    
    local quantity = createText(
    card,
    "x" .. tostring(entry.Quantity or 1),
    UDim2.fromScale(0.35, 0.18),
    UDim2.fromScale(0.61, 0.78),
    COLORS.GoldBright,
    Enum.Font.Fantasy,
    7
    )
    
    
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(entry, input)
        end
    end)
    
    card.Activated:Connect(function()
        selectedItemId = entry.ItemId
        selectedQuantityValue = 1
        
        UIAudio.Play("Select")
        
        if stroke then
            stroke.Color = COLORS.GoldBright
            stroke.Thickness = 3
        end
        
        for _, sibling in ipairs(itemGrid:GetChildren()) do
            if sibling:IsA("TextButton") and sibling ~= card then
                local siblingStroke = sibling:FindFirstChildOfClass("UIStroke")
                if siblingStroke then
                    siblingStroke.Color = COLORS.GoldDark
                    siblingStroke.Thickness = 1.5
                end
            end
        end
        
        updateDetails()
    end)
    
    card.MouseEnter:Connect(function()
        tween(
        card,
        0.12,
        {BackgroundColor3 = COLORS.Wood}
        ):Play()
    end)
    
    card.MouseLeave:Connect(function()
        tween(
        card,
        0.12,
        {BackgroundColor3 = COLORS.WoodMid}
        ):Play()
    end)
    
    return card
end

--------------------------------------------------
-- RENDER
--------------------------------------------------

local function renderInventory(data)
    inventoryState = {}
    
    for _, child in ipairs(itemGrid:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if type(data) ~= "table" then
        data = {}
    end
    
    for index, rawEntry in ipairs(data) do
        if type(rawEntry) == "table" then
            local entry = {
            ItemId = rawEntry.ItemId,
            Quantity = tonumber(rawEntry.Quantity) or 1,
            Data = rawEntry.Data or {},
            }
            
            if entry.ItemId then
                table.insert(inventoryState, entry)
                createItemCard(entry, index)
            end
        end
    end
    
    local slotCount = tonumber(inventorySlotsState) or #inventoryState
    local slotMax = tonumber(inventoryMaxSlotsState) or MAX_INVENTORY_SLOTS
    
    if #inventoryState == 0 then
        statusLabel.Text = "0 / " .. tostring(slotMax) .. " slots • Inventory is empty."
    else
        statusLabel.Text =
        tostring(slotCount)
        .. " / "
        .. tostring(slotMax)
        .. " slots • "
        .. tostring(#inventoryState)
        .. " item stack"
        .. (#inventoryState == 1 and "" or "s")
    end
    
    task.defer(function()
        itemGrid.CanvasSize = UDim2.new(
        0,
        0,
        0,
        gridLayout.AbsoluteContentSize.Y + 12
        )
    end)
    
    updateDetails()
end

--------------------------------------------------
-- QUANTITY MODAL
--------------------------------------------------

local function showQuantityModal(titleText, maxQuantity, confirmText, onConfirm, danger)
    maxQuantity = math.max(1, tonumber(maxQuantity) or 1)
    
    local overlay = Instance.new("Frame")
    overlay.Name = "QuantityModal"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = COLORS.Black
    overlay.BackgroundTransparency = 0.42
    overlay.ZIndex = 100
    overlay.Parent = root
    
    local modal = Instance.new("Frame")
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.Position = UDim2.fromScale(0.5, 0.5)
    modal.Size = UDim2.fromScale(0.44, 0.35)
    modal.BackgroundColor3 = COLORS.Parchment
    modal.BorderSizePixel = 0
    modal.ZIndex = 101
    modal.Parent = overlay
    
    addCorner(modal, 12)
    addStroke(modal, COLORS.GoldDark, 3)
    
    createText(
    modal,
    titleText,
    UDim2.fromScale(0.86, 0.16),
    UDim2.fromScale(0.07, 0.08),
    COLORS.TextDark,
    Enum.Font.Fantasy,
    102
    )
    
    local quantityLabel = Instance.new("TextBox")
    quantityLabel.Name = "QuantityInput"
    quantityLabel.Size = UDim2.fromScale(0.52, 0.2)
    quantityLabel.Position = UDim2.fromScale(0.24, 0.28)
    quantityLabel.BackgroundColor3 = COLORS.ParchmentLight
    quantityLabel.BorderSizePixel = 0
    quantityLabel.Text = "1"
    quantityLabel.PlaceholderText = "1 - " .. tostring(maxQuantity)
    quantityLabel.TextColor3 = COLORS.TextDark
    quantityLabel.TextScaled = true
    quantityLabel.Font = Enum.Font.Fantasy
    quantityLabel.ClearTextOnFocus = false
    quantityLabel.TextXAlignment = Enum.TextXAlignment.Center
    quantityLabel.ZIndex = 102
    quantityLabel.Parent = modal
    addCorner(quantityLabel, 7)
    addStroke(quantityLabel, COLORS.GoldDark, 2)
    
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.fromScale(0.16, 0.2)
    minus.Position = UDim2.fromScale(0.08, 0.55)
    minus.BackgroundColor3 = COLORS.Wood
    minus.Text = "-"
    minus.TextColor3 = COLORS.GoldBright
    minus.TextScaled = true
    minus.Font = Enum.Font.Fantasy
    minus.AutoButtonColor = false
    minus.ZIndex = 102
    minus.Parent = modal
    addCorner(minus, 7)
    addStroke(minus, COLORS.Gold, 2)
    UIAudio.BindButton(minus)
    
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.fromScale(0.16, 0.2)
    plus.Position = UDim2.fromScale(0.76, 0.55)
    plus.BackgroundColor3 = COLORS.Wood
    plus.Text = "+"
    plus.TextColor3 = COLORS.GoldBright
    plus.TextScaled = true
    plus.Font = Enum.Font.Fantasy
    plus.AutoButtonColor = false
    plus.ZIndex = 102
    plus.Parent = modal
    addCorner(plus, 7)
    addStroke(plus, COLORS.Gold, 2)
    UIAudio.BindButton(plus)
    
    local cancel = Instance.new("TextButton")
    cancel.Size = UDim2.fromScale(0.31, 0.18)
    cancel.Position = UDim2.fromScale(0.08, 0.77)
    cancel.BackgroundColor3 = COLORS.WoodDark
    cancel.Text = "CANCEL"
    cancel.TextColor3 = COLORS.GoldBright
    cancel.TextScaled = true
    cancel.Font = Enum.Font.Fantasy
    cancel.AutoButtonColor = false
    cancel.ZIndex = 102
    cancel.Parent = modal
    addCorner(cancel, 7)
    addStroke(cancel, COLORS.Gold, 2)
    UIAudio.BindButton(cancel, {Click = "Cancel"})
    
    local confirm = Instance.new("TextButton")
    confirm.Size = UDim2.fromScale(0.47, 0.18)
    confirm.Position = UDim2.fromScale(0.45, 0.77)
    confirm.BackgroundColor3 = danger and COLORS.Ruby or COLORS.Emerald
    confirm.Text = confirmText
    confirm.TextColor3 = COLORS.GoldBright
    confirm.TextScaled = true
    confirm.Font = Enum.Font.Fantasy
    confirm.AutoButtonColor = false
    confirm.ZIndex = 102
    confirm.Parent = modal
    addCorner(confirm, 7)
    addStroke(confirm, COLORS.Gold, 2)
    UIAudio.BindButton(
    confirm,
    {Click = danger and "Drop" or "Confirm"}
    )
    
    local quantity = 1
    
    local function readTypedQuantity()
        local value = tonumber(quantityLabel.Text)
        if not value then
            return quantity
        end
        
        return math.clamp(math.floor(value), 1, maxQuantity)
    end
    
    local function refresh()
        quantity = math.clamp(quantity, 1, maxQuantity)
        quantityLabel.Text = tostring(quantity)
    end
    
    quantityLabel.FocusLost:Connect(function()
        quantity = readTypedQuantity()
        refresh()
    end)
    
    minus.Activated:Connect(function()
        quantity = math.max(1, quantity - 1)
        refresh()
    end)
    
    plus.Activated:Connect(function()
        quantity = math.min(maxQuantity, quantity + 1)
        refresh()
    end)
    
    local closed = false
    
    local function close()
        if closed then
            return
        end
        
        closed = true
        overlay:Destroy()
    end
    
    cancel.Activated:Connect(close)
    
    confirm.Activated:Connect(function()
        quantity = readTypedQuantity()
        refresh()
        onConfirm(quantity)
        close()
    end)
end

handleDragDrop = function(position)
    local entry = dragEntry
    
    if not entry then
        cancelDrag()
        return
    end
    
    if pointInside(storageButton, position) then
        selectedItemId = entry.ItemId
        showQuantityModal(
        "MOVE TO STORAGE",
        entry.Quantity,
        "MOVE",
        function(quantity)
            CharacterRemote:FireServer(
            "MoveItemToStorage",
            {
            ItemId = entry.ItemId,
            Quantity = quantity,
            }
            )
        end,
        false
        )
        cancelDrag()
        return
    end
    
    if pointInside(dropButton, position) then
        selectedItemId = entry.ItemId
        showQuantityModal(
        "DROP ITEM",
        entry.Quantity,
        "DROP",
        function(quantity)
            CharacterRemote:FireServer(
            "DropItem",
            {
            ItemId = entry.ItemId,
            Quantity = quantity,
            }
            )
        end,
        true
        )
        cancelDrag()
        return
    end
    
    cancelDrag()
    UIAudio.Play("Cancel")
end

UserInputService.InputEnded:Connect(function(input)
    if not dragActive or not dragInput then
        return
    end
    
    if input == dragInput
        or input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        local position = Vector2.new(
        input.Position.X,
        input.Position.Y
        )
        
        if dragMoved and handleDragDrop then
            handleDragDrop(position)
        else
            cancelDrag()
        end
    end
end)

--------------------------------------------------
-- ACTIONS
--------------------------------------------------

storageButton.Activated:Connect(function()
    if not selectedItemId then
        UIAudio.Play("Error")
        return
    end
    
    local entry
    
    for _, item in ipairs(inventoryState) do
        if item.ItemId == selectedItemId then
            entry = item
            break
        end
    end
    
    if not entry then
        UIAudio.Play("Error")
        return
    end
    
    showQuantityModal(
    "MOVE TO STORAGE",
    entry.Quantity,
    "MOVE",
    function(quantity)
        CharacterRemote:FireServer(
        "MoveItemToStorage",
        {
        ItemId = selectedItemId,
        Quantity = quantity,
        }
        )
    end,
    false
    )
end)

dropButton.Activated:Connect(function()
    if not selectedItemId then
        UIAudio.Play("Error")
        return
    end
    
    local entry
    
    for _, item in ipairs(inventoryState) do
        if item.ItemId == selectedItemId then
            entry = item
            break
        end
    end
    
    if not entry then
        UIAudio.Play("Error")
        return
    end
    
    showQuantityModal(
    "DROP ITEM",
    entry.Quantity,
    "DROP",
    function(quantity)
        CharacterRemote:FireServer(
        "DropItem",
        {
        ItemId = selectedItemId,
        Quantity = quantity,
        }
        )
    end,
    true
    )
end)

storageOpenButton.Activated:Connect(function()
    local storageUI = playerGui:FindFirstChild("StorageUI")
    
    if storageUI then
        screenGui.Enabled = false
        storageUI.Enabled = true
        UIAudio.Play("Open")
    else
        UIAudio.Play("Error")
        statusLabel.Text = "Storage UI is not installed."
    end
end)

--------------------------------------------------
-- CLOSE
--------------------------------------------------

closeButton.Activated:Connect(function()
    screenGui.Enabled = false
end)

root.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == Enum.KeyCode.Escape then
        screenGui.Enabled = false
    end
end)

--------------------------------------------------
-- INVENTORY BUTTON / CHARACTER LIFECYCLE
--------------------------------------------------

local activeCharacterReady = false

local function hideInventoryUI()
    activeCharacterReady = false
    screenGui.Enabled = false
    buttonGui.Enabled = false
end

local function showInventoryButton()
    activeCharacterReady = true
    updateInventoryButtonPosition()
    buttonGui.Enabled = true
end

inventoryButton.Activated:Connect(function()
    if not activeCharacterReady then
        return
    end
    
    if screenGui.Enabled then
        screenGui.Enabled = false
        UIAudio.Play("Close")
        return
    end
    
    CharacterRemote:FireServer("OpenInventory")
end)

--------------------------------------------------
-- SERVER EVENTS
--------------------------------------------------

CharacterRemote.OnClientEvent:Connect(function(action, data)
    
    if action == "CharacterSelected" then
        -- The server has accepted the selected character.
        -- Do NOT depend on CharacterUI's internal timing here.
        -- CharacterUI and InventoryUI listen to the same RemoteEvent.
        screenGui.Enabled = false
        showInventoryButton()
        
    elseif action == "EnterMainMenu"
        or action == "CharacterSpawnFailed" then
        
        hideInventoryUI()
        
    elseif action == "InventoryOpened" then
        -- Keep the backpack visible while the Inventory is open.
        showInventoryButton()
        screenGui.Enabled = true
        
        if type(data) == "table" and type(data.Inventory) == "table" then
            inventorySlotsState = tonumber(data.InventorySlots) or #data.Inventory
            inventoryMaxSlotsState = tonumber(data.InventoryMaxSlots) or MAX_INVENTORY_SLOTS
            renderInventory(data.Inventory)
        else
            inventorySlotsState = 0
            inventoryMaxSlotsState = MAX_INVENTORY_SLOTS
            renderInventory({})
        end
        
        UIAudio.Play("Open")
        
    elseif action == "InventoryActionResult" then
        
        if type(data) == "table" and type(data.Inventory) == "table" then
            inventorySlotsState = tonumber(data.InventorySlots) or #data.Inventory
            inventoryMaxSlotsState = tonumber(data.InventoryMaxSlots) or MAX_INVENTORY_SLOTS
            renderInventory(data.Inventory)
        end
        
        UIAudio.Play("Confirm")
        
    elseif action == "InventoryActionFailed" then
        UIAudio.Play("Error")
        
        statusLabel.Text =
        "Action failed: "
        .. tostring(data or "UNKNOWN_ERROR")
        
        task.delay(3, function()
            if screenGui.Enabled then
                if #inventoryState > 0 then
                    statusLabel.Text =
                    tostring(#inventoryState)
                    .. " item stack"
                    .. (#inventoryState == 1 and "" or "s")
                else
                    statusLabel.Text = "Your inventory is empty."
                end
            end
        end)
    end
end)

--------------------------------------------------
-- INITIAL STATE
--------------------------------------------------

hideInventoryUI()
