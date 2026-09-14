--------------------------------------------------
-- YAMA: LEGENDS
-- CHARACTER UI V3
--
-- Compact top HUD + responsive character menu.
-- Client-only presentation layer.
--------------------------------------------------
 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
 
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
 
local remote = ReplicatedStorage:WaitForChild("CharacterUIRemote")
local characterRemote = ReplicatedStorage:WaitForChild("CharacterRemote")
 
local UIAudio = require(
script.Parent:WaitForChild("UIAudio")
)
 
--------------------------------------------------
-- COLORS
--------------------------------------------------
 
local parchment = Color3.fromRGB(231, 218, 187)
local parchmentLight = Color3.fromRGB(247, 237, 211)
local parchmentDark = Color3.fromRGB(190, 170, 130)
local gold = Color3.fromRGB(194, 151, 63)
local goldBright = Color3.fromRGB(235, 196, 103)
local dark = Color3.fromRGB(48, 39, 29)
local muted = Color3.fromRGB(92, 78, 60)
local panelColor = Color3.fromRGB(214, 199, 164)
local slotColor = Color3.fromRGB(181, 163, 125)
local emptyColor = Color3.fromRGB(157, 143, 112)
local hpColor = Color3.fromRGB(157, 55, 48)
local spColor = Color3.fromRGB(62, 92, 157)
local xpColor = Color3.fromRGB(190, 148, 47)
 
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
    stroke.Parent = object
    return stroke
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
 
local function makeLabel(parent, name, text, size, position, textSize, color)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Text = text
    label.TextColor3 = color or dark
    label.TextSize = textSize or 14
    label.Font = Enum.Font.Garamond
    label.TextWrapped = true
    label.Parent = parent
    return label
end
 
local function makeButton(parent, name, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = text
    button.BackgroundColor3 = parchmentDark
    button.BorderSizePixel = 0
    button.TextColor3 = dark
    button.TextSize = 14
    button.Font = Enum.Font.Garamond
    button.AutoButtonColor = false
    button.Parent = parent
    addCorner(button, 7)
    addStroke(button, gold, 1.5)
    UIAudio.BindButton(button, {Click = "Click"})
    return button
end
 
local function formatNumber(value)
    value = tonumber(value) or 0
    if math.abs(value - math.floor(value)) < 0.001 then
        return tostring(math.floor(value))
    end
    return string.format("%.2f", value)
end
 
local function formatPercent(value)
    value = tonumber(value) or 0
    return string.format("%.2f%%", value * 100)
end
 
--------------------------------------------------
-- GUI
--------------------------------------------------
 
local gui = Instance.new("ScreenGui")
gui.Name = "CharacterUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 160
gui.Enabled = false
gui.Parent = playerGui
 
--------------------------------------------------
-- COMPACT TOP HUD
--------------------------------------------------
 
local hud = Instance.new("TextButton")
hud.Name = "CharacterHUD"
hud.AnchorPoint = Vector2.new(0.5, 0)
hud.Position = UDim2.new(0.5, 0, 0, 7)
-- Maximum 20% of the screen width.
hud.Size = UDim2.new(0.20, 0, 0, 42)
hud.BackgroundColor3 = parchment
hud.BorderSizePixel = 0
hud.Text = ""
hud.AutoButtonColor = false
hud.Parent = gui
addCorner(hud, 9)
addStroke(hud, gold, 2)
UIAudio.BindButton(hud, {Click = "Open"})
 
local hudName = makeLabel(
hud,
"Name",
"CHARACTER",
UDim2.new(0.64, -4, 0, 17),
UDim2.new(0, 6, 0, 3),
13,
dark
)
hudName.TextXAlignment = Enum.TextXAlignment.Left
hudName.TextTruncate = Enum.TextTruncate.AtEnd
 
local hudLevel = makeLabel(
hud,
"Level",
"Lv. 1",
UDim2.new(0.30, -4, 0, 17),
UDim2.new(0.69, 0, 0, 3),
11,
muted
)
hudLevel.TextXAlignment = Enum.TextXAlignment.Right
 
local function createMiniBar(parent, name, y, color)
    local background = Instance.new("Frame")
    background.Name = name .. "Background"
    background.Size = UDim2.new(1, -12, 0, 7)
    background.Position = UDim2.new(0, 6, 0, y)
    background.BackgroundColor3 = emptyColor
    background.BorderSizePixel = 0
    background.Parent = parent
    addCorner(background, 4)
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = background
    addCorner(fill, 4)
    
    local text = makeLabel(
    background,
    "Value",
    name,
    UDim2.new(1, 0, 1, 0),
    UDim2.new(0, 0, 0, 0),
    8,
    Color3.new(1, 1, 1)
    )
    text.TextXAlignment = Enum.TextXAlignment.Center
    
    return fill, text
end
 
local hpMiniFill, hpMiniText = createMiniBar(hud, "HP", 20, hpColor)
local spMiniFill, spMiniText = createMiniBar(hud, "SP", 30, spColor)
 
--------------------------------------------------
-- EXPANDED CHARACTER MENU
--------------------------------------------------
 
local panelFrame = Instance.new("Frame")
panelFrame.Name = "CharacterPanel"
panelFrame.AnchorPoint = Vector2.new(0.5, 0.5)
panelFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
-- Maximum 50% of the screen width.
panelFrame.Size = UDim2.new(0.50, 0, 0.78, 0)
panelFrame.BackgroundColor3 = parchment
panelFrame.BorderSizePixel = 0
panelFrame.Visible = false
panelFrame.Parent = gui
addCorner(panelFrame, 10)
addStroke(panelFrame, gold, 3)
 
local panelConstraint = Instance.new("UISizeConstraint")
panelConstraint.MinSize = Vector2.new(240, 230)
panelConstraint.MaxSize = Vector2.new(720, 620)
panelConstraint.Parent = panelFrame
 
local title = makeLabel(
panelFrame,
"Title",
"CHARACTER",
UDim2.new(1, -80, 0, 28),
UDim2.new(0, 12, 0, 7),
20,
dark
)
title.TextXAlignment = Enum.TextXAlignment.Left
 
title.TextTruncate = Enum.TextTruncate.AtEnd
 
local close = makeButton(panelFrame, "Close", "X")
close.Size = UDim2.fromOffset(32, 28)
close.Position = UDim2.new(1, -42, 0, 7)
UIAudio.BindButton(close, {Click = "Close"})
 
local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Position = UDim2.new(0, 8, 0, 43)
content.Size = UDim2.new(1, -16, 1, -50)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = gold
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = panelFrame
 
local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 6)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = content
 
local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingBottom = UDim.new(0, 8)
contentPadding.Parent = content
 
--------------------------------------------------
-- COLLAPSIBLE SECTION
--------------------------------------------------
 
local sectionIndex = 0
 
local function createSection(name, defaultOpen)
    sectionIndex += 1
    
    local section = Instance.new("Frame")
    section.Name = name .. "Section"
    section.Size = UDim2.new(1, -2, 0, 42)
    section.BackgroundColor3 = panelColor
    section.BorderSizePixel = 0
    section.LayoutOrder = sectionIndex
    section.Parent = content
    addCorner(section, 8)
    addStroke(section, gold, 1)
    
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.Text = ""
    header.AutoButtonColor = false
    header.Parent = section
    UIAudio.BindButton(header, {Click = "Click"})
    
    local arrow = makeLabel(
    header,
    "Arrow",
    defaultOpen and "▼" or "▶",
    UDim2.fromOffset(22, 26),
    UDim2.new(0, 7, 0, 7),
    12,
    goldBright
    )
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    
    local headerText = makeLabel(
    header,
    "Title",
    name,
    UDim2.new(1, -40, 0, 26),
    UDim2.new(0, 34, 0, 7),
    15,
    dark
    )
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Position = UDim2.new(0, 7, 0, 42)
    body.Size = UDim2.new(1, -14, 0, 0)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.Parent = section
    
    local open = defaultOpen
    
    local function setOpen(value, animate)
        open = value
        arrow.Text = open and "▼" or "▶"
        
        local targetHeight = tonumber(body:GetAttribute("OpenHeight")) or 0
        local sectionHeight = open and (targetHeight + 47) or 40
        
        if animate then
            tween(section, 0.18, {
            Size = UDim2.new(1, -2, 0, sectionHeight)
            }):Play()
            tween(body, 0.18, {
            Size = UDim2.new(1, -14, 0, open and targetHeight or 0)
            }):Play()
        else
            section.Size = UDim2.new(1, -2, 0, sectionHeight)
            body.Size = UDim2.new(1, -14, 0, open and targetHeight or 0)
        end
    end
    
    header.Activated:Connect(function()
        setOpen(not open, true)
    end)
    
    return section, body, setOpen
end
 
local function setBodyHeight(body, height)
    body:SetAttribute("OpenHeight", height)
end
 
--------------------------------------------------
-- GENERIC CARD
--------------------------------------------------
 
local function createCard(parent, name, position, size)
    local card = Instance.new("Frame")
    card.Name = name
    card.Position = position
    card.Size = size
    card.BackgroundColor3 = parchmentLight
    card.BorderSizePixel = 0
    card.Parent = parent
    addCorner(card, 7)
    addStroke(card, gold, 1)
    return card
end
 
--------------------------------------------------
-- OVERVIEW
--------------------------------------------------
 
local overviewSection, overviewBody = createSection("OVERVIEW", true)
setBodyHeight(overviewBody, 142)
overviewBody.Size = UDim2.new(1, -14, 0, 142)
overviewSection.Size = UDim2.new(1, -2, 0, 189)
 
local overviewLeft = createCard(
overviewBody,
"ResourcesCard",
UDim2.new(0, 0, 0, 0),
UDim2.new(0.48, -3, 1, 0)
)
 
local overviewRight = createCard(
overviewBody,
"CharacterCard2D",
UDim2.new(0.52, 3, 0, 0),
UDim2.new(0.48, -3, 1, 0)
)
 
local overviewName = makeLabel(
overviewLeft,
"Name",
"CHARACTER",
UDim2.new(1, -12, 0, 22),
UDim2.new(0, 6, 0, 5),
17,
dark
)
overviewName.TextXAlignment = Enum.TextXAlignment.Left
overviewName.TextTruncate = Enum.TextTruncate.AtEnd
 
local overviewTitle = makeLabel(
overviewLeft,
"Specialization",
"Adventurer",
UDim2.new(1, -12, 0, 18),
UDim2.new(0, 6, 0, 26),
11,
muted
)
overviewTitle.TextXAlignment = Enum.TextXAlignment.Left
 
local overviewLevel = makeLabel(
overviewLeft,
"Level",
"Lv. 1",
UDim2.new(0.32, -4, 0, 18),
UDim2.new(0.66, 0, 0, 6),
12,
dark
)
overviewLevel.TextXAlignment = Enum.TextXAlignment.Right
 
local function createResourceBar(parent, name, y, color)
    local label = makeLabel(
    parent,
    name .. "Label",
    name,
    UDim2.fromOffset(25, 17),
    UDim2.new(0, 6, 0, y),
    10,
    dark
    )
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local background = Instance.new("Frame")
    background.Name = name .. "Background"
    background.Position = UDim2.new(0, 34, 0, y + 3)
    background.Size = UDim2.new(1, -40, 0, 10)
    background.BackgroundColor3 = emptyColor
    background.BorderSizePixel = 0
    background.Parent = parent
    addCorner(background, 5)
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = background
    addCorner(fill, 5)
    
    local value = makeLabel(
    background,
    "Value",
    "0 / 0",
    UDim2.new(1, 0, 1, 0),
    UDim2.new(0, 0, 0, -3),
    8,
    Color3.new(1, 1, 1)
    )
    value.TextXAlignment = Enum.TextXAlignment.Center
    
    return fill, value
end
 
local overviewHPFill, overviewHPValue = createResourceBar(overviewLeft, "HP", 51, hpColor)
local overviewSPFill, overviewSPValue = createResourceBar(overviewLeft, "SP", 70, spColor)
local overviewXPFill, overviewXPValue = createResourceBar(overviewLeft, "XP", 89, xpColor)
 
local goldLabel = makeLabel(
overviewLeft,
"Gold",
"Gold: 0",
UDim2.new(1, -12, 0, 22),
UDim2.new(0, 6, 0, 112),
13,
gold
)
goldLabel.TextXAlignment = Enum.TextXAlignment.Left
 
local cardCaption = makeLabel(
overviewRight,
"Caption",
"CHARACTER CARD",
UDim2.new(1, -8, 0, 18),
UDim2.new(0, 4, 0, 4),
10,
muted
)
cardCaption.TextXAlignment = Enum.TextXAlignment.Center
 
local viewport = Instance.new("ViewportFrame")
viewport.Name = "CharacterRender2D"
viewport.Position = UDim2.new(0, 5, 0, 24)
viewport.Size = UDim2.new(1, -10, 1, -29)
viewport.BackgroundColor3 = Color3.fromRGB(224, 211, 181)
viewport.BorderSizePixel = 0
viewport.Ambient = Color3.fromRGB(190, 180, 155)
viewport.LightColor = Color3.fromRGB(255, 245, 220)
viewport.Parent = overviewRight
addCorner(viewport, 6)
 
-- Reusable character portrait renderer.
-- The ViewportFrame is a 3D model presented inside a 2D UI card.
-- This function can later be reused by MainMenu character cards.
local viewportWorldModel = Instance.new("WorldModel")
viewportWorldModel.Name = "CharacterWorld"
viewportWorldModel.Parent = viewport
 
local viewportCamera = Instance.new("Camera")
viewportCamera.Name = "CharacterCamera"
viewportCamera.FieldOfView = 30
viewportCamera.Parent = viewport
viewport.CurrentCamera = viewportCamera
 
local viewportFallback = makeLabel(
viewport,
"Fallback",
"CHARACTER\nPREVIEW",
UDim2.new(1, -10, 0.45, 0),
UDim2.new(0, 5, 0.30, 0),
13,
muted
)
viewportFallback.TextXAlignment = Enum.TextXAlignment.Center
viewportFallback.TextYAlignment = Enum.TextYAlignment.Center
 
local function clearCharacterViewport()
    for _, child in ipairs(viewportWorldModel:GetChildren()) do
        if not child:IsA("Light") then
            child:Destroy()
        end
    end
    viewportFallback.Visible = true
end
 
local function renderCharacterViewport(viewportFrame, sourceCharacter)
    if not viewportFrame or not sourceCharacter then
        clearCharacterViewport()
        return false
    end
    
    local worldModel = viewportFrame:FindFirstChild("CharacterWorld")
    local camera = viewportFrame:FindFirstChild("CharacterCamera")
    local fallback = viewportFrame:FindFirstChild("Fallback")
    
    if not worldModel or not camera then
        return false
    end
    
    for _, child in ipairs(worldModel:GetChildren()) do
        if not child:IsA("Light") then
            child:Destroy()
        end
    end
    
    local oldArchivable = sourceCharacter.Archivable
    sourceCharacter.Archivable = true
    local clone = sourceCharacter:Clone()
    sourceCharacter.Archivable = oldArchivable
    
    if not clone then
        if fallback then
            fallback.Visible = true
        end
        return false
    end
    
    clone.Name = "CharacterPreview"
    
    -- Runtime objects are not needed in a viewport preview.
    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("Script")
            or descendant:IsA("LocalScript")
            or descendant:IsA("ModuleScript")
            or descendant:IsA("Tool") then
            descendant:Destroy()
        end
    end
    
    clone.Parent = worldModel
    
    -- Normalize the model so its feet sit near the bottom of the card.
    local boxCFrame, boxSize = clone:GetBoundingBox()
    local bottomY = boxCFrame.Position.Y - (boxSize.Y * 0.5)
    clone:PivotTo(CFrame.new(0, -bottomY, 0) * clone:GetPivot())
    
    boxCFrame, boxSize = clone:GetBoundingBox()
    
    local height = math.max(boxSize.Y, 2)
    local width = math.max(boxSize.X, 1)
    local depth = math.max(boxSize.Z, 1)
    local target = boxCFrame.Position + Vector3.new(0, height * 0.53, 0)
    
    local verticalFov = math.rad(camera.FieldOfView)
    local viewportWidth = math.max(viewportFrame.AbsoluteSize.X, 1)
    local viewportHeight = math.max(viewportFrame.AbsoluteSize.Y, 1)
    local horizontalFov = 2 * math.atan(
    math.tan(verticalFov * 0.5) * viewportWidth / viewportHeight
    )
    
    local distanceByHeight =
    (height * 0.58) / math.tan(verticalFov * 0.5)
    
    local distanceByWidth =
    (width * 0.58) / math.tan(horizontalFov * 0.5)
    
    local distance = math.max(
    distanceByHeight,
    distanceByWidth,
    depth * 2.2
    )
    
    -- YAMA characters normally face their LookVector toward -Z,
    -- so the camera sits on -Z to show the front of the character.
    local cameraPosition =
    target + Vector3.new(0, height * 0.02, -distance)
    
    camera.CFrame = CFrame.lookAt(cameraPosition, target)
    camera.Focus = CFrame.new(target)
    
    if fallback then
        fallback.Visible = false
    end
    
    return true
end
 
--------------------------------------------------
-- ATTRIBUTES + DERIVED STATUS
--------------------------------------------------
 
local attributesSection, attributesBody = createSection("ATTRIBUTES", false)
setBodyHeight(attributesBody, 172)
 
local attributesLeft = createCard(
attributesBody,
"BasicAttributes",
UDim2.new(0, 0, 0, 0),
UDim2.new(0.48, -3, 1, 0)
)
 
local statusRight = createCard(
attributesBody,
"DerivedStatus",
UDim2.new(0.52, 3, 0, 0),
UDim2.new(0.48, -3, 1, 0)
)
 
local pointsLabel = makeLabel(
attributesLeft,
"Points",
"Points: 0",
UDim2.new(1, -10, 0, 18),
UDim2.new(0, 5, 0, 4),
10,
muted
)
pointsLabel.TextXAlignment = Enum.TextXAlignment.Right
 
local attributeRows = {}
local attributeNames = {
{"Strength", "STR"},
{"Dexterity", "DEX"},
{"Intelligence", "INT"},
{"Vitality", "VIT"},
{"Luck", "LUK"},
}
 
for index, info in ipairs(attributeNames) do
    local y = 25 + ((index - 1) * 27)
    local row = makeLabel(
    attributesLeft,
    info[1],
    info[2] .. "  0",
    UDim2.new(1, -10, 0, 24),
    UDim2.new(0, 5, 0, y),
    13,
    dark
    )
    row.TextXAlignment = Enum.TextXAlignment.Left
    attributeRows[info[1]] = row
end
 
local statusCaption = makeLabel(
statusRight,
"Caption",
"STATUS",
UDim2.new(1, -10, 0, 18),
UDim2.new(0, 5, 0, 4),
10,
muted
)
statusCaption.TextXAlignment = Enum.TextXAlignment.Center
 
local statusScroll = Instance.new("ScrollingFrame")
statusScroll.Name = "StatusScroll"
statusScroll.Position = UDim2.new(0, 5, 0, 24)
statusScroll.Size = UDim2.new(1, -10, 1, -29)
statusScroll.BackgroundTransparency = 1
statusScroll.BorderSizePixel = 0
statusScroll.ScrollBarThickness = 3
statusScroll.ScrollBarImageColor3 = gold
statusScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
statusScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
statusScroll.Parent = statusRight
 
local statusLayout = Instance.new("UIListLayout")
statusLayout.Padding = UDim.new(0, 1)
statusLayout.SortOrder = Enum.SortOrder.LayoutOrder
statusLayout.Parent = statusScroll
 
local statusRows = {}
local statusDefinitions = {
{"PhysicalAttack", "ATK"},
{"MagicAttack", "MATK"},
{"PhysicalDefense", "DEF"},
{"MagicDefense", "MDEF"},
{"Accuracy", "ACC"},
{"Evasion", "EVA"},
{"AttackSpeed", "ATK SPD"},
{"CastSpeed", "CAST SPD"},
{"CriticalChance", "CRIT"},
{"CriticalDamage", "CRIT DMG"},
{"PerfectDodge", "PERFECT DODGE"},
{"MovementSpeed", "MOVE SPD"},
{"HPRecovery", "HP REC"},
{"ManaRecovery", "SP REC"},
{"StatusResistance", "STATUS RES"},
}
 
for index, info in ipairs(statusDefinitions) do
    local y = 23 + ((index - 1) * 18)
    local row = makeLabel(
    statusScroll,
    info[1],
    info[2] .. "  0",
    UDim2.new(1, -6, 0, 17),
    UDim2.new(0, 0, 0, 0),
    9,
    dark
    )
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.LayoutOrder = index
    statusRows[info[1]] = row
end
 
--------------------------------------------------
-- EQUIPMENT + VISUAL
--
-- IMPORTANT:
-- This section intentionally does NOT use a ScrollingFrame/UIPageLayout.
-- Equipment and Visual are two fixed cards occupying the exact same area.
-- Only one card is visible at a time. This keeps the slot grid centered
-- against the actual Character UI body instead of a scrolling canvas.
 
local equipmentSection, equipmentBody = createSection("EQUIPMENT & VISUAL", false)
setBodyHeight(equipmentBody, 174)
 
local equipmentPage = createCard(
equipmentBody,
"EquipmentPage",
UDim2.new(0, 0, 0, 0),
UDim2.new(1, 0, 1, 0)
)
 
local visualPage = createCard(
equipmentBody,
"VisualPage",
UDim2.new(0, 0, 0, 0),
UDim2.new(1, 0, 1, 0)
)
 
equipmentPage.Visible = true
visualPage.Visible = false
 
local equipmentPageTitle = makeLabel(
equipmentPage,
"Title",
"EQUIPMENT",
UDim2.new(1, -10, 0, 18),
UDim2.new(0, 5, 0, 4),
10,
muted
)
equipmentPageTitle.TextXAlignment = Enum.TextXAlignment.Center
 
local visualPageTitle = makeLabel(
visualPage,
"Title",
"VISUAL",
UDim2.new(1, -10, 0, 18),
UDim2.new(0, 5, 0, 4),
10,
muted
)
visualPageTitle.TextXAlignment = Enum.TextXAlignment.Center
 
local function createSquareSlots(parent, slotNames, prefix)
    local result = {}
    
    -- The container is the complete page width.
    -- Its center is therefore exactly the center of CharacterUI.
    local container = Instance.new("Frame")
    container.Name = prefix .. "Slots"
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Size = UDim2.new(1, 0, 1, -31)
    container.Position = UDim2.new(0, 0, 0, 25)
    container.Parent = parent
    
    local positions = {
    -- Equipment: character-shaped arrangement.
    Head = UDim2.new(0.5, -19.5, 0, 2),
    MainHand = UDim2.new(0.5, -88.5, 0, 49),
    Body = UDim2.new(0.5, -42.5, 0, 49),
    Back = UDim2.new(0.5, 3.5, 0, 49),
    OffHand = UDim2.new(0.5, 49.5, 0, 49),
    Legs = UDim2.new(0.5, -19.5, 0, 96),
    Accessory = UDim2.new(0.5, 26.5, 0, 96),
    
    -- Visual.
    Hair = UDim2.new(0.5, -65.5, 0, 2),
    Face = UDim2.new(0.5, 26.5, 0, 2),
    }
    
    for _, slotName in ipairs(slotNames) do
        local frame = Instance.new("Frame")
        frame.Name = prefix .. slotName
        frame.BackgroundColor3 = slotColor
        frame.BorderSizePixel = 0
        frame.Size = UDim2.fromOffset(39, 39)
        frame.Position = positions[slotName]
        or UDim2.new(0.5, -19.5, 0, 4)
        frame.Parent = container
        addCorner(frame, 6)
        addStroke(frame, gold, 1)
        
        local slotText = makeLabel(
        frame,
        "SlotName",
        slotName,
        UDim2.new(1, -4, 0.42, 0),
        UDim2.new(0, 2, 0, 1),
        7,
        muted
        )
        slotText.TextXAlignment = Enum.TextXAlignment.Center
        slotText.TextTruncate = Enum.TextTruncate.AtEnd
        
        local itemText = makeLabel(
        frame,
        "Item",
        "—",
        UDim2.new(1, -4, 0.48, 0),
        UDim2.new(0, 2, 0.43, 0),
        7,
        dark
        )
        itemText.TextXAlignment = Enum.TextXAlignment.Center
        itemText.TextTruncate = Enum.TextTruncate.AtEnd
        
        result[slotName] = itemText
    end
    
    return result
end
 
local equipmentSlots = createSquareSlots(
equipmentPage,
{"Head", "Body", "Legs", "MainHand", "OffHand", "Back", "Accessory"},
"Equipment_"
)
 
local visualSlots = createSquareSlots(
visualPage,
{"Hair", "Face", "Head", "Body", "Legs", "MainHand", "OffHand", "Back"},
"Visual_"
)
 
-- Page switching is done by visibility only.
-- Both pages have exactly the same position and size.
local showingEquipment = true
 
local function showEquipmentPage()
    showingEquipment = true
    equipmentPage.Visible = true
    visualPage.Visible = false
end
 
local function showVisualPage()
    showingEquipment = false
    equipmentPage.Visible = false
    visualPage.Visible = true
end
 
local leftArrow = Instance.new("TextButton")
leftArrow.Name = "PreviousPage"
leftArrow.Size = UDim2.fromOffset(28, 28)
leftArrow.Position = UDim2.new(0, 4, 0.5, -14)
leftArrow.BackgroundColor3 = parchmentDark
leftArrow.BorderSizePixel = 0
leftArrow.Text = "◀"
leftArrow.TextColor3 = goldBright
leftArrow.TextSize = 15
leftArrow.Font = Enum.Font.GothamBold
leftArrow.AutoButtonColor = false
leftArrow.ZIndex = 10
leftArrow.Parent = equipmentBody
addCorner(leftArrow, 8)
addStroke(leftArrow, gold, 1)
UIAudio.BindButton(leftArrow, {Click = "Click"})
 
local rightArrow = Instance.new("TextButton")
rightArrow.Name = "NextPage"
rightArrow.Size = UDim2.fromOffset(28, 28)
rightArrow.Position = UDim2.new(1, -32, 0.5, -14)
rightArrow.BackgroundColor3 = parchmentDark
rightArrow.BorderSizePixel = 0
rightArrow.Text = "▶"
rightArrow.TextColor3 = goldBright
rightArrow.TextSize = 15
rightArrow.Font = Enum.Font.GothamBold
rightArrow.AutoButtonColor = false
rightArrow.ZIndex = 10
rightArrow.Parent = equipmentBody
addCorner(rightArrow, 8)
addStroke(rightArrow, gold, 1)
UIAudio.BindButton(rightArrow, {Click = "Click"})
 
leftArrow.Activated:Connect(function()
    if showingEquipment then
        showVisualPage()
    else
        showEquipmentPage()
    end
end)
 
rightArrow.Activated:Connect(function()
    if showingEquipment then
        showVisualPage()
    else
        showEquipmentPage()
    end
end)
 
-- SKILLS PLACEHOLDER (UNCHANGED)
--------------------------------------------------
 
local skillsSection, skillsBody = createSection("SKILLS & KNOWLEDGE", false)
setBodyHeight(skillsBody, 76)
 
local skillsText = makeLabel(
skillsBody,
"Placeholder",
"Knowledge, skills and masteries will appear here as they are discovered.",
UDim2.new(1, -8, 0, 64),
UDim2.new(0, 4, 0, 4),
13,
muted
)
skillsText.TextWrapped = true
skillsText.TextYAlignment = Enum.TextYAlignment.Center
 
--------------------------------------------------
-- DATA HELPERS
--------------------------------------------------
 
local function getEquippedName(value)
    if typeof(value) == "string" then
        return value
    end
    
    if typeof(value) == "table" then
        return value.ItemId
        or value.Id
        or value.Name
        or "Equipped"
    end
    
    return nil
end
 
local function fillSlots(slotLabels, data)
    for _, itemLabel in pairs(slotLabels) do
        itemLabel.Text = "—"
    end
    
    if typeof(data) ~= "table" then
        return
    end
    
    for slotName, value in pairs(data) do
        local itemLabel = slotLabels[slotName]
        if itemLabel then
            itemLabel.Text = getEquippedName(value) or "Equipped"
        end
    end
end
 
local function setBar(fill, valueLabel, current, maximum)
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    
    local ratio = 0
    if maximum > 0 then
        ratio = math.clamp(current / maximum, 0, 1)
    end
    
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    valueLabel.Text = string.format(
    "%d / %d",
    math.floor(current),
    math.floor(maximum)
    )
end
 
local function setMiniBar(fill, valueLabel, current, maximum, name)
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    
    local ratio = 0
    if maximum > 0 then
        ratio = math.clamp(current / maximum, 0, 1)
    end
    
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    valueLabel.Text = name
    .. " "
    .. math.floor(current)
    .. "/"
    .. math.floor(maximum)
end
 
local function formatStatusValue(statName, value)
    if statName == "CriticalChance"
        or statName == "PerfectDodge" then
        return formatPercent(value)
    end
    
    if statName == "CriticalDamage" then
        return formatNumber(value) .. "x"
    end
    
    return formatNumber(value)
end
 
--------------------------------------------------
-- RENDER
--------------------------------------------------
 
local function render(data)
    if typeof(data) ~= "table" then
        return
    end
    
    local level = tonumber(data.Level) or 1
    local xp = tonumber(data.XP) or 0
    local goldAmount = tonumber(data.Gold) or 0
    
    local characterName = tostring(data.Name or "Character")
    local specialization = tostring(
    data.Specialization
    or data.Title
    or "Adventurer"
    )
    
    overviewName.Text = characterName
    overviewTitle.Text = specialization
    overviewLevel.Text = "Lv. " .. tostring(level)
    
    hudName.Text = characterName
    hudLevel.Text = "Lv. " .. tostring(level)
    
    setBar(
    overviewHPFill,
    overviewHPValue,
    data.HP,
    data.MaxHP
    )
    
    setBar(
    overviewSPFill,
    overviewSPValue,
    data.SP,
    data.MaxSP
    )
    
    overviewXPValue.Text = tostring(math.floor(xp))
    overviewXPFill.Size = UDim2.new(0, 0, 1, 0)
    
    goldLabel.Text = "Gold: " .. tostring(math.floor(goldAmount))
    
    setMiniBar(
    hpMiniFill,
    hpMiniText,
    data.HP,
    data.MaxHP,
    "HP"
    )
    
    setMiniBar(
    spMiniFill,
    spMiniText,
    data.SP,
    data.MaxSP,
    "SP"
    )
    
    if player.Character then
        renderCharacterViewport(viewport, player.Character)
    else
        clearCharacterViewport()
    end
    
    pointsLabel.Text =
    "Points: " .. tostring(data.AttributePoints or 0)
    
    if typeof(data.Attributes) == "table" then
        for attributeName, row in pairs(attributeRows) do
            local short = "?"
            for _, info in ipairs(attributeNames) do
                if info[1] == attributeName then
                    short = info[2]
                    break
                end
            end
            
            row.Text = short .. "  " .. tostring(
            data.Attributes[attributeName] or 0
            )
        end
    end
    
    local derived = data.DerivedStats
    if typeof(derived) == "table" then
        for statName, row in pairs(statusRows) do
            local displayName = ""
            for _, info in ipairs(statusDefinitions) do
                if info[1] == statName then
                    displayName = info[2]
                    break
                end
            end
            
            row.Text = displayName .. "  " .. formatStatusValue(
            statName,
            derived[statName]
            )
        end
    else
        for statName, row in pairs(statusRows) do
            local displayName = ""
            for _, info in ipairs(statusDefinitions) do
                if info[1] == statName then
                    displayName = info[2]
                    break
                end
            end
            row.Text = displayName .. "  0"
        end
    end
    
    fillSlots(equipmentSlots, data.Equipment)
    fillSlots(visualSlots, data.Cosmetics)
end
 
--------------------------------------------------
-- OPEN / CLOSE
--------------------------------------------------
 
local panelOpen = false
 
local function openPanel()
    if not gui.Enabled then
        return
    end
    
    panelOpen = true
    panelFrame.Visible = true
    UIAudio.Play("Open")
    remote:FireServer("GetData")
end
 
local function closePanel(playSound)
    panelOpen = false
    panelFrame.Visible = false
    
    if playSound then
        UIAudio.Play("Close")
    end
end
 
hud.Activated:Connect(function()
    if panelOpen then
        closePanel(true)
    else
        openPanel()
    end
end)
 
close.Activated:Connect(function()
    closePanel(true)
end)
 
--------------------------------------------------
-- CHARACTER LIFECYCLE
--------------------------------------------------
 
local activeCharacterReady = false
local activeHumanoid = nil
local healthChangedConnection = nil
local maxHealthChangedConnection = nil
 
local function disconnectHealthConnection()
    if healthChangedConnection then
        healthChangedConnection:Disconnect()
        healthChangedConnection = nil
    end
    if maxHealthChangedConnection then
        maxHealthChangedConnection:Disconnect()
        maxHealthChangedConnection = nil
    end
    activeHumanoid = nil
end
 
local function updateLiveHP()
    if not activeHumanoid then
        return
    end
    
    local current = activeHumanoid.Health
    local maximum = activeHumanoid.MaxHealth
    
    setBar(
    overviewHPFill,
    overviewHPValue,
    current,
    maximum
    )
    
    setMiniBar(
    hpMiniFill,
    hpMiniText,
    current,
    maximum,
    "HP"
    )
end
 
local function bindLiveCharacter(character, humanoid)
    disconnectHealthConnection()
    activeHumanoid = humanoid
    
    if not activeHumanoid then
        return
    end
    
    healthChangedConnection = activeHumanoid.HealthChanged:Connect(function()
        if activeCharacterReady then
            updateLiveHP()
        end
    end)
    
    maxHealthChangedConnection =
    activeHumanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        if activeCharacterReady then
            updateLiveHP()
        end
    end)
    
    updateLiveHP()
    
    task.defer(function()
        if activeCharacterReady then
            renderCharacterViewport(viewport, character)
        end
    end)
end
 
local function hideCharacterUI()
    activeCharacterReady = false
    disconnectHealthConnection()
    clearCharacterViewport()
    closePanel(false)
    gui.Enabled = false
end
 
local function waitForCharacterModel()
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 8)
    end
    
    if not root then
        root = character:WaitForChild("HumanoidRootPart", 8)
    end
    
    return character, humanoid, root
end
 
characterRemote.OnClientEvent:Connect(function(action, value)
    if action == "CharacterSelected" then
        task.spawn(function()
            local character, humanoid, root = waitForCharacterModel()
            
            if character and humanoid and root then
                activeCharacterReady = true
                gui.Enabled = true
                bindLiveCharacter(character, humanoid)
                render(value)
            end
        end)
        
    elseif action == "EnterMainMenu"
        or action == "CharacterSpawnFailed" then
        hideCharacterUI()
    end
end)
 
remote.OnClientEvent:Connect(function(action, data)
    if action == "Data" then
        if activeCharacterReady then
            render(data)
        end
        
    elseif action == "Unavailable" then
        hideCharacterUI()
    end
end)
 
player.CharacterAdded:Connect(function(character)
    if not activeCharacterReady then
        hideCharacterUI()
        return
    end
    
    task.spawn(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            humanoid = character:WaitForChild("Humanoid", 8)
        end
        
        if not activeCharacterReady or not humanoid then
            return
        end
        
        bindLiveCharacter(character, humanoid)
        renderCharacterViewport(viewport, character)
    end)
end)
 
--------------------------------------------------
-- START HIDDEN
--------------------------------------------------
 
hideCharacterUI()
