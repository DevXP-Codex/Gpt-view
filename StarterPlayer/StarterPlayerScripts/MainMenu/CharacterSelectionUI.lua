-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- CHARACTER SELECTION UI
--
-- Uses the SAME CharacterPreview renderer as CharacterUI.
-- No local camera, bounding-box, rotation or framing logic.
--------------------------------------------------
 
local CharacterSelectionUI = {}
 
local state = {
CharacterList = nil,
ListLayout = nil,
CharacterRemote = nil,
Helpers = nil,
SelectedCharacter = nil,
SelectedCard = nil,
Cards = {},
PlayButton = nil,
DeleteButton = nil,
}
 
local CharacterPreview = require(
script.Parent:WaitForChild("CharacterPreview")
)
 
local function updateSelectionVisual(card)
    if state.SelectedCard and state.SelectedCard.Parent then
        local old = state.SelectedCard:FindFirstChild("SelectionStroke")
        if old then old:Destroy() end
    end
    
    state.SelectedCard = card
    
    if card then
        local stroke = state.Helpers.AddStroke(
        card,
        state.Helpers.Colors.GoldBright,
        3
        )
        stroke.Name = "SelectionStroke"
    end
end
 
local function setActionsEnabled(enabled)
    for _, button in ipairs({state.PlayButton, state.DeleteButton}) do
        if button then
            button.Active = enabled
            button.AutoButtonColor = enabled
            button.TextTransparency = enabled and 0 or 0.45
        end
    end
end
 
local function getClassInfo(characterClass)
    local name = string.lower(tostring(characterClass or "Adventurer"))
    
    if string.find(name, "sword") then
        return "⚔", "SWORDSMAN"
    elseif string.find(name, "archer") then
        return "♢", "ARCHER"
    elseif string.find(name, "mage") then
        return "✦", "MAGE"
    end
    
    return "◆", string.upper(tostring(characterClass or "ADVENTURER"))
end
 
local function createActionButton(parent, name, text, background)
    local h = state.Helpers
    local colors = h.Colors
    
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.fromScale(0.43, 0.72)
    button.Position = UDim2.fromScale(
    name == "PlaySelected" and 0.05 or 0.52,
    0.14
    )
    button.BackgroundColor3 = background
    button.BorderSizePixel = 0
    button.Text = text
    button.TextScaled = true
    button.TextColor3 = colors.GoldBright
    button.Font = Enum.Font.Fantasy
    button.AutoButtonColor = false
    button.ClipsDescendants = true
    button.ZIndex = 20
    button.Parent = parent
    
    h.AddCorner(button, 8)
    local stroke = h.AddStroke(button, colors.Gold, 2)
    
    if h.AddGradient then
        h.AddGradient(
        button,
        background:Lerp(colors.White, 0.15),
        background:Lerp(colors.Black, 0.35),
        90
        )
    end
    
    if h.SetupButtonEffects then
        h.SetupButtonEffects(button, stroke, 1)
    end
    
    return button
end
 
local function createCard(character)
    local h = state.Helpers
    local colors = h.Colors
    
    local container = Instance.new("Frame")
    container.Name = "CharacterCard"
    container.Size = UDim2.fromOffset(150, 150)
    container.BackgroundColor3 = colors.Wood
    container.BorderSizePixel = 0
    container.ZIndex = 6
    container.Parent = state.CharacterList
    container:SetAttribute("CharacterId", tostring(character.Id))
    
    h.AddCorner(container, 11)
    local cardStroke = h.AddStroke(container, colors.GoldDark, 2)
    
    if h.AddGradient then
        h.AddGradient(container, colors.WoodLight, colors.WoodDark, 90)
    end
    
    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = 1
    aspect.Parent = container
    
    local portrait = Instance.new("Frame")
    portrait.Name = "PortraitFrame"
    portrait.Size = UDim2.new(1, -14, 0.68, 0)
    portrait.Position = UDim2.new(0.5, 0, 0.04, 0)
    portrait.AnchorPoint = Vector2.new(0.5, 0)
    portrait.BackgroundColor3 = colors.Leather
    portrait.BorderSizePixel = 0
    portrait.ZIndex = 8
    portrait.Parent = container
    
    h.AddCorner(portrait, 8)
    local portraitStroke = h.AddStroke(portrait, colors.Gold, 2)
    
    if h.AddGradient then
        h.AddGradient(
        portrait,
        colors.LeatherLight,
        colors.LeatherDark,
        90
        )
    end
    
    local portraitInner = Instance.new("Frame")
    portraitInner.Name = "PortraitInner"
    portraitInner.Size = UDim2.new(1, -6, 1, -6)
    portraitInner.Position = UDim2.fromScale(0.5, 0.5)
    portraitInner.AnchorPoint = Vector2.new(0.5, 0.5)
    portraitInner.BackgroundTransparency = 1
    portraitInner.BorderSizePixel = 0
    portraitInner.ClipsDescendants = true
    portraitInner.ZIndex = 9
    portraitInner.Parent = portrait
    h.AddCorner(portraitInner, 5)
    h.AddStroke(portraitInner, colors.GoldDark, 1)
    
    -- CRITICAL: use the shared renderer. Do not create a local camera.
    local viewport = CharacterPreview.Create(portraitInner, {
    AddCorner = h.AddCorner,
    })
    
    viewport.ZIndex = 11
    
    local classBadge = Instance.new("TextLabel")
    classBadge.Name = "ClassBadge"
    classBadge.Size = UDim2.fromScale(0.25, 0.25)
    classBadge.Position = UDim2.fromScale(0.72, 0.03)
    classBadge.BackgroundColor3 = colors.WoodDark
    classBadge.BackgroundTransparency = 0.12
    classBadge.TextScaled = true
    classBadge.TextColor3 = colors.GoldBright
    classBadge.Font = Enum.Font.Fantasy
    classBadge.ZIndex = 15
    classBadge.Parent = portrait
    h.AddCorner(classBadge, 6)
    
    local icon, className = getClassInfo(character.Class)
    classBadge.Text = icon
    
    local name = Instance.new("TextLabel")
    name.Name = "CharacterName"
    name.Size = UDim2.new(0.92, 0, 0.12, 0)
    name.Position = UDim2.new(0.04, 0, 0.735, 0)
    name.BackgroundTransparency = 1
    name.Text = tostring(character.Name or "Character")
    name.TextScaled = true
    name.TextColor3 = colors.GoldBright
    name.Font = Enum.Font.Fantasy
    name.ZIndex = 10
    name.Parent = container
    
    local info = Instance.new("TextLabel")
    info.Name = "CharacterInfo"
    info.Size = UDim2.new(0.92, 0, 0.10, 0)
    info.Position = UDim2.new(0.04, 0, 0.86, 0)
    info.BackgroundTransparency = 1
    info.Text =
    "Lv. " .. tostring(character.Level or 1)
    .. "  •  " .. className
    info.TextScaled = true
    info.TextColor3 = colors.TextLight
    info.Font = Enum.Font.Garamond
    info.ZIndex = 10
    info.Parent = container
    
    container.MouseEnter:Connect(function()
        h.Tween(cardStroke, 0.18, {
        Thickness = 3,
        Color = colors.GoldBright,
        }):Play()
        
        h.Tween(portraitStroke, 0.18, {
        Thickness = 3,
        Color = colors.GoldBright,
        }):Play()
    end)
    
    container.MouseLeave:Connect(function()
        h.Tween(cardStroke, 0.18, {
        Thickness = 2,
        Color = colors.GoldDark,
        }):Play()
        
        h.Tween(portraitStroke, 0.18, {
        Thickness = 2,
        Color = colors.Gold,
        }):Play()
    end)
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            
            state.SelectedCharacter = character
            updateSelectionVisual(container)
            setActionsEnabled(true)
        end
    end)
    
    return {
    Frame = container,
    Viewport = viewport,
    Character = character,
    }
end
 
function CharacterSelectionUI.Initialize(config)
    state.CharacterList = config.CharacterList
    state.ListLayout = config.ListLayout
    state.CharacterRemote = config.CharacterRemote
    state.Helpers = config
    state.Cards = {}
    
    state.PlayButton = createActionButton(
    config.ActionBar,
    "PlaySelected",
    "PLAY",
    config.Colors.Emerald
    )
    
    state.DeleteButton = createActionButton(
    config.ActionBar,
    "DeleteSelected",
    "DELETE",
    config.Colors.Ruby
    )
    
    state.PlayButton.Activated:Connect(function()
        if state.SelectedCharacter then
            state.CharacterRemote:FireServer(
            "SelectCharacter",
            state.SelectedCharacter.Id
            )
        end
    end)
    
    state.DeleteButton.Activated:Connect(function()
        if state.SelectedCharacter and config.OnDelete then
            config.OnDelete(state.SelectedCharacter)
        end
    end)
    
    setActionsEnabled(false)
end
 
function CharacterSelectionUI.Display(characters)
    for _, child in ipairs(state.CharacterList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    state.Cards = {}
    state.SelectedCharacter = nil
    state.SelectedCard = nil
    setActionsEnabled(false)
    
    for _, character in ipairs(characters or {}) do
        local card = createCard(character)
        state.Cards[tostring(character.Id)] = card
        
        state.CharacterRemote:FireServer(
        "GetCharacterPreview",
        character.Id
        )
    end
    
    task.defer(function()
        state.CharacterList.CanvasSize = UDim2.new(
        0,
        state.ListLayout.AbsoluteContentSize.X + 24,
        0,
        0
        )
    end)
end
 
function CharacterSelectionUI.HandlePreview(data, previewFolder)
    if type(data) ~= "table" then
        return
    end
    
    local cardData = state.Cards[tostring(data.CharacterId)]
    if not cardData then
        return
    end
    
    local previewName = data.PreviewName
    if not previewName then
        return
    end
    
    local previewModel =
    previewFolder and previewFolder:FindFirstChild(previewName)
    
    if not previewModel and previewFolder then
        local deadline = os.clock() + 5
        
        repeat
        task.wait(0.05)
        previewModel = previewFolder:FindFirstChild(previewName)
        until previewModel or os.clock() >= deadline
    end
    
    if previewModel and previewModel:IsA("Model") then
        local ok, err = pcall(function()
            CharacterPreview.Render(
            cardData.Viewport,
            previewModel
            )
        end)
        
        if not ok then
            warn(
            "[YAMA CharacterSelectionUI] Portrait render failed:",
            err
            )
        end
    end
end
 
return CharacterSelectionUI
