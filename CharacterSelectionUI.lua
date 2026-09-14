local CharacterSelectionUI = {}
local CharacterCard = require(script.Parent:WaitForChild("CharacterCard"))
local CharacterPreview = require(script.Parent:WaitForChild("CharacterPreview"))

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

local function updateSelectionVisual(card)
    if state.SelectedCard and state.SelectedCard.Parent then
        local old = state.SelectedCard:FindFirstChild("SelectionStroke")
        if old then old:Destroy() end
    end
    state.SelectedCard = card
    if card then
        local stroke = state.Helpers.AddStroke(card, state.Helpers.Colors.GoldBright, 3)
        stroke.Name = "SelectionStroke"
        stroke.Transparency = 0
    end
end

local function setActionsEnabled(enabled)
    if state.PlayButton then
        state.PlayButton.Active = enabled
        state.PlayButton.AutoButtonColor = enabled
        state.PlayButton.TextTransparency = enabled and 0 or 0.45
    end
    if state.DeleteButton then
        state.DeleteButton.Active = enabled
        state.DeleteButton.AutoButtonColor = enabled
        state.DeleteButton.TextTransparency = enabled and 0 or 0.45
    end
end

local function addShine(button, helpers)
    local mask = Instance.new("Frame")
    mask.Size = UDim2.fromScale(1, 1)
    mask.BackgroundTransparency = 1
    mask.BorderSizePixel = 0
    mask.ClipsDescendants = true
    mask.ZIndex = button.ZIndex + 1
    mask.Parent = button
    helpers.AddCorner(mask, 8)
    local shine = Instance.new("Frame")
    shine.Size = UDim2.new(0.16, 0, 1.7, 0)
    shine.Position = UDim2.fromScale(-0.35, -0.35)
    shine.BackgroundColor3 = helpers.Colors.White
    shine.BackgroundTransparency = 0.9
    shine.BorderSizePixel = 0
    shine.Rotation = 18
    shine.ZIndex = button.ZIndex + 2
    shine.Parent = mask
    helpers.AddCorner(shine, 10)
    local gradient = Instance.new("UIGradient")
    gradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.5,0.15), NumberSequenceKeypoint.new(1,1)})
    gradient.Parent = shine
    task.spawn(function()
        while button.Parent do
            shine.Position = UDim2.fromScale(-0.35, -0.35)
            helpers.Tween(shine, 1.35, {Position = UDim2.fromScale(1.2, -0.35)}, Enum.EasingStyle.Linear):Play()
            task.wait(4)
        end
    end)
end

local function createActionButton(parent, name, text, background, helpers)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.fromScale(0.43, 0.72)
    button.Position = UDim2.fromScale(name == "PlaySelected" and 0.05 or 0.52, 0.14)
    button.BackgroundColor3 = background
    button.BorderSizePixel = 0
    button.Text = text
    button.TextScaled = true
    button.TextColor3 = helpers.Colors.GoldBright
    button.Font = Enum.Font.Fantasy
    button.AutoButtonColor = false
    button.ClipsDescendants = true
    button.ZIndex = 20
    button.Parent = parent
    helpers.AddCorner(button, 8)
    local stroke = helpers.AddStroke(button, helpers.Colors.Gold, 2)
    helpers.AddGradient(button, background:Lerp(helpers.Colors.White, 0.15), background:Lerp(helpers.Colors.Black, 0.35), 90)
    helpers.SetupButtonEffects(button, stroke, 1)
    addShine(button, helpers)
    return button
end

function CharacterSelectionUI.Initialize(config)
    state.CharacterList = config.CharacterList
    state.ListLayout = config.ListLayout
    state.CharacterRemote = config.CharacterRemote
    state.Helpers = config
    state.Cards = {}
    
    state.PlayButton = createActionButton(config.ActionBar, "PlaySelected", "PLAY", config.Colors.Emerald, config)
    state.DeleteButton = createActionButton(config.ActionBar, "DeleteSelected", "DELETE", config.Colors.Ruby, config)
    
    state.PlayButton.Activated:Connect(function()
        if state.SelectedCharacter then
            state.CharacterRemote:FireServer("SelectCharacter", state.SelectedCharacter.Id)
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
        if child:IsA("Frame") then child:Destroy() end
    end
    
    state.Cards = {}
    state.SelectedCharacter = nil
    state.SelectedCard = nil
    setActionsEnabled(false)
    
    for _, character in ipairs(characters or {}) do
        local card = CharacterCard.Create(character, state.CharacterList, state.Helpers, CharacterPreview)
        state.Cards[tostring(character.Id)] = card
        card.Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                state.SelectedCharacter = character
                updateSelectionVisual(card.Frame)
                setActionsEnabled(true)
            end
        end)
        state.CharacterRemote:FireServer("GetCharacterPreview", character.Id)
    end
    
    task.defer(function()
        state.CharacterList.CanvasSize = UDim2.new(0, state.ListLayout.AbsoluteContentSize.X + 24, 0, 0)
    end)
end

function CharacterSelectionUI.HandlePreview(data, previewFolder)
    if type(data) ~= "table" then return end
    local cardData = state.Cards[tostring(data.CharacterId)]
    if not cardData then return end
    local previewName = data.PreviewName
    if not previewName then return end
    
    local previewModel = previewFolder and previewFolder:FindFirstChild(previewName)
    if not previewModel and previewFolder then
        local startTime = os.clock()
        repeat
        task.wait()
        previewModel = previewFolder:FindFirstChild(previewName)
        until previewModel or (os.clock() - startTime) >= 5
    end
    if previewModel then
        CharacterPreview.Render(cardData.Viewport, previewModel)
    end
end

return CharacterSelectionUI
