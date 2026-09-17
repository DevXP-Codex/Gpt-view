-- LOCAL SCRIPT -- 
--------------------------------------------------
-- YAMA: LEGENDS
-- STORAGE UI V1
--
-- Client-only presentation layer for Shared Storage.
-- Uses the same CharacterRemote and UIAudio module
-- already used by InventoryUI.
--------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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
TextLight = Color3.fromRGB(255, 239, 190),

Emerald = Color3.fromRGB(30, 126, 72),
EmeraldDark = Color3.fromRGB(12, 54, 34),

Ruby = Color3.fromRGB(157, 36, 49),
Black = Color3.fromRGB(0, 0, 0),
}

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

local function tween(object, duration, properties)
    return TweenService:Create(
    object,
    TweenInfo.new(
    duration or 0.2,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
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
-- GUI
--------------------------------------------------

local oldGui = playerGui:FindFirstChild("StorageUI")
if oldGui then
    oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StorageUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 301
screenGui.Enabled = false
screenGui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = COLORS.Black
root.BackgroundTransparency = 0.38
root.BorderSizePixel = 0
root.Parent = screenGui

local panel = Instance.new("Frame")
panel.Name = "StoragePanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.92, 0.84)
panel.BackgroundColor3 = COLORS.Parchment
panel.BorderSizePixel = 0
panel.Parent = root
addCorner(panel, 14)
addStroke(panel, COLORS.GoldDark, 3)
addGradient(panel, COLORS.ParchmentLight, COLORS.ParchmentDark, 90)

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
"SHARED STORAGE",
UDim2.fromScale(0.64, 0.105),
UDim2.fromScale(0.18, 0.07),
COLORS.TextDark,
Enum.Font.Fantasy,
3
)

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

local storageArea = Instance.new("Frame")
storageArea.Name = "StorageArea"
storageArea.Size = UDim2.fromScale(0.59, 0.73)
storageArea.Position = UDim2.fromScale(0.035, 0.19)
storageArea.BackgroundColor3 = COLORS.LeatherDark
storageArea.BorderSizePixel = 0
storageArea.Parent = panel
addCorner(storageArea, 10)
addStroke(storageArea, COLORS.GoldDark, 2)

createText(
storageArea,
"STORED ITEMS",
UDim2.fromScale(0.42, 0.08),
UDim2.fromScale(0.035, 0.02),
COLORS.GoldBright,
Enum.Font.Fantasy,
5
)

local itemGrid = Instance.new("ScrollingFrame")
itemGrid.Name = "ItemGrid"
itemGrid.Size = UDim2.new(1, -18, 1, -58)
itemGrid.Position = UDim2.new(0, 9, 0, 45)
itemGrid.BackgroundTransparency = 1
itemGrid.BorderSizePixel = 0
itemGrid.ScrollBarThickness = 5
itemGrid.ScrollBarImageColor3 = COLORS.Gold
itemGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
itemGrid.Parent = storageArea

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0.22, 0, 0, 105)
gridLayout.CellPadding = UDim2.new(0.025, 0, 0, 10)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = itemGrid

local statusLabel = createText(
storageArea,
"",
UDim2.fromScale(0.86, 0.08),
UDim2.fromScale(0.07, 0.89),
COLORS.GoldBright,
Enum.Font.Garamond,
6
)

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
"STORAGE DETAILS",
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

local returnInventoryButton = Instance.new("TextButton")
returnInventoryButton.Name = "ReturnInventory"
returnInventoryButton.Size = UDim2.fromScale(0.86, 0.105)
returnInventoryButton.Position = UDim2.fromScale(0.07, 0.66)
returnInventoryButton.BackgroundColor3 = COLORS.Wood
returnInventoryButton.BorderSizePixel = 0
returnInventoryButton.Text = "BACK TO INVENTORY"
returnInventoryButton.TextColor3 = COLORS.GoldBright
returnInventoryButton.TextScaled = true
returnInventoryButton.Font = Enum.Font.Fantasy
returnInventoryButton.AutoButtonColor = false
returnInventoryButton.ZIndex = 5
returnInventoryButton.Parent = details
addCorner(returnInventoryButton, 8)
addStroke(returnInventoryButton, COLORS.Gold, 2)
addGradient(returnInventoryButton, COLORS.ParchmentDark, COLORS.WoodDark, 90)
UIAudio.BindButton(returnInventoryButton, {Click = "Close"})

local withdrawButton = Instance.new("TextButton")
withdrawButton.Name = "MoveToInventory"
withdrawButton.Size = UDim2.fromScale(0.86, 0.105)
withdrawButton.Position = UDim2.fromScale(0.07, 0.79)
withdrawButton.BackgroundColor3 = COLORS.Emerald
withdrawButton.BorderSizePixel = 0
withdrawButton.Text = "MOVE TO INVENTORY"
withdrawButton.TextColor3 = COLORS.GoldBright
withdrawButton.TextScaled = true
withdrawButton.Font = Enum.Font.Fantasy
withdrawButton.AutoButtonColor = false
withdrawButton.ZIndex = 5
withdrawButton.Parent = details
addCorner(withdrawButton, 8)
addStroke(withdrawButton, COLORS.Gold, 2)
addGradient(withdrawButton, Color3.fromRGB(89, 201, 128), COLORS.EmeraldDark, 90)
UIAudio.BindButton(withdrawButton, {Click = "Confirm"})

--------------------------------------------------
-- STATE
--------------------------------------------------

local storageState = {}
local selectedItemId = nil
local selectedQuantityValue = 1

local function setActionEnabled(button, enabled)
    button.Active = enabled
    button.Selectable = enabled
    button.AutoButtonColor = false
    button.TextTransparency = enabled and 0 or 0.5
end

local function findEntry(itemId)
    for _, item in ipairs(storageState) do
        if item.ItemId == itemId then
            return item
        end
    end
    return nil
end

local function updateActionButtons()
    local entry = findEntry(selectedItemId)
    setActionEnabled(withdrawButton, entry ~= nil and (tonumber(entry.Quantity) or 0) > 0)
end

local function updateDetails()
    if not selectedItemId then
        selectedName.Text = "Select an item"
        selectedCategory.Text = ""
        selectedQuantity.Text = ""
        selectedDescription.Text = ""
        updateActionButtons()
        return
    end
    
    local entry = findEntry(selectedItemId)
    if not entry then
        selectedItemId = nil
        updateDetails()
        return
    end
    
    local data = entry.Data or {}
    
    selectedName.Text = data.Name or entry.ItemId
    selectedCategory.Text = tostring(data.Type or "Item")
    .. "  •  x"
    .. tostring(entry.Quantity or 1)
    selectedQuantity.Text = "Quantity stored: " .. tostring(entry.Quantity or 1)
    selectedDescription.Text = data.Description or "No description available."
    
    updateActionButtons()
end

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
    elseif itemType == "Hair"
        or itemType == "WeaponSkin"
        or itemType == "ArmorSkin" then
        return "COS"
    end
    
    return "ITEM"
end

local function getIconImage(data)
    data = data or {}
    
    local rawAssetId =
    data.IconAssetId
    or data.WorldAssetId
    or data.AssetId
    
    if rawAssetId == nil then
        return nil
    end
    
    local assetId = tonumber(rawAssetId)
    
    if not assetId then
        assetId = tonumber(
        tostring(rawAssetId):match("(%d+)")
        )
    end
    
    if not assetId or assetId <= 0 then
        return nil
    end
    
    return "rbxthumb://type=Asset&id="
    .. tostring(assetId)
    .. "&w=150&h=150"
end

--------------------------------------------------
-- QUANTITY MODAL
--------------------------------------------------

local function showQuantityModal(titleText, maxQuantity, confirmText, onConfirm)
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
    quantityLabel.PlaceholderText = "1-" .. tostring(maxQuantity)
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
    confirm.BackgroundColor3 = COLORS.Emerald
    confirm.Text = confirmText
    confirm.TextColor3 = COLORS.GoldBright
    confirm.TextScaled = true
    confirm.Font = Enum.Font.Fantasy
    confirm.AutoButtonColor = false
    confirm.ZIndex = 102
    confirm.Parent = modal
    addCorner(confirm, 7)
    addStroke(confirm, COLORS.Gold, 2)
    UIAudio.BindButton(confirm, {Click = "Confirm"})
    
    local quantity = 1
    
    local function readTypedQuantity()
        local digits = tostring(quantityLabel.Text):match("%d+")
        local value = tonumber(digits)
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

--------------------------------------------------
-- ITEM CARD
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
    
    local stroke = addStroke(card, COLORS.GoldDark, 1.5)
    
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
    
    createText(
    card,
    data.Name or entry.ItemId,
    UDim2.fromScale(0.9, 0.28),
    UDim2.fromScale(0.05, 0.52),
    COLORS.TextLight,
    Enum.Font.Garamond,
    6
    )
    
    createText(
    card,
    "x" .. tostring(entry.Quantity or 1),
    UDim2.fromScale(0.35, 0.18),
    UDim2.fromScale(0.61, 0.78),
    COLORS.GoldBright,
    Enum.Font.Fantasy,
    7
    )
    
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
        tween(card, 0.12, {
        BackgroundColor3 = COLORS.Wood
        }):Play()
    end)
    
    card.MouseLeave:Connect(function()
        tween(card, 0.12, {
        BackgroundColor3 = COLORS.WoodMid
        }):Play()
    end)
end

--------------------------------------------------
-- RENDER
--------------------------------------------------

local function renderStorage(data)
    storageState = {}
    
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
                table.insert(storageState, entry)
                createItemCard(entry, index)
            end
        end
    end
    
    if #storageState == 0 then
        statusLabel.Text = "Your shared storage is empty."
    else
        statusLabel.Text = tostring(#storageState)
        .. " stored stack"
        .. (#storageState == 1 and "" or "s")
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
-- ACTIONS
--------------------------------------------------

withdrawButton.Activated:Connect(function()
    local entry = findEntry(selectedItemId)
    if not entry then
        UIAudio.Play("Error")
        return
    end
    
    showQuantityModal(
    "MOVE TO INVENTORY",
    entry.Quantity,
    "MOVE",
    function(quantity)
        CharacterRemote:FireServer(
        "MoveItemFromStorage",
        {
        ItemId = selectedItemId,
        Quantity = quantity,
        }
        )
    end
    )
end)

returnInventoryButton.Activated:Connect(function()
    screenGui.Enabled = false
    local inventoryUI = playerGui:FindFirstChild("InventoryUI")
    if inventoryUI then
        inventoryUI.Enabled = true
        UIAudio.Play("Open")
    end
end)

closeButton.Activated:Connect(function()
    screenGui.Enabled = false
end)

--------------------------------------------------
-- SERVER EVENTS
--------------------------------------------------

CharacterRemote.OnClientEvent:Connect(function(action, data)
    if action == "CharacterSelected" then
        screenGui.Enabled = false
        
    elseif action == "EnterMainMenu" then
        screenGui.Enabled = false
        
    elseif action == "InventoryOpened" then
        if type(data) == "table" then
            renderStorage(data.Storage or {})
        end
        
    elseif action == "InventoryActionResult" then
        if type(data) == "table" then
            renderStorage(data.Storage or {})
        end
        UIAudio.Play("Confirm")
        
    elseif action == "InventoryActionFailed" then
        UIAudio.Play("Error")
        statusLabel.Text = "Action failed: " .. tostring(data or "UNKNOWN_ERROR")
        
        task.delay(3, function()
            if screenGui.Enabled then
                if #storageState > 0 then
                    statusLabel.Text = tostring(#storageState)
                    .. " stored stack"
                    .. (#storageState == 1 and "" or "s")
                else
                    statusLabel.Text = "Your shared storage is empty."
                end
            end
        end)
    end
end)

screenGui.Enabled = false
