local CharacterCard = {}

local function getClassIcon(characterClass)
    local className = string.lower(tostring(characterClass or "Adventurer"))
    if string.find(className, "sword") then
        return "⚔", "SWORDSMAN"
    elseif string.find(className, "archer") then
        return "♢", "ARCHER"
    elseif string.find(className, "mage") then
        return "✦", "MAGE"
    end
    return "◆", string.upper(tostring(characterClass or "ADVENTURER"))
end

local function addGemShine(button, helpers)
    local shineMask = Instance.new("Frame")
    shineMask.Name = "ShineMask"
    shineMask.Size = UDim2.fromScale(1, 1)
    shineMask.BackgroundTransparency = 1
    shineMask.BorderSizePixel = 0
    shineMask.ClipsDescendants = true
    shineMask.ZIndex = button.ZIndex + 1
    shineMask.Parent = button
    helpers.AddCorner(shineMask, 9)
    
    local shine = Instance.new("Frame")
    shine.Name = "Shine"
    shine.Size = UDim2.new(0.16, 0, 1.7, 0)
    shine.Position = UDim2.fromScale(-0.35, -0.35)
    shine.BackgroundColor3 = helpers.Colors.White
    shine.BackgroundTransparency = 0.9
    shine.BorderSizePixel = 0
    shine.Rotation = 18
    shine.ZIndex = button.ZIndex + 2
    shine.Parent = shineMask
    helpers.AddCorner(shine, 10)
    
    local gradient = Instance.new("UIGradient")
    gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.35, 0.75),
    NumberSequenceKeypoint.new(0.5, 0.15),
    NumberSequenceKeypoint.new(0.65, 0.75),
    NumberSequenceKeypoint.new(1, 1),
    })
    gradient.Parent = shine
    
    task.spawn(function()
        while button.Parent do
            shine.Position = UDim2.fromScale(-0.35, -0.35)
            helpers.Tween(shine, 1.35, {Position = UDim2.fromScale(1.2, -0.35)}, Enum.EasingStyle.Linear):Play()
            task.wait(4)
        end
    end)
end

function CharacterCard.Create(character, parent, helpers, preview)
    local container = Instance.new("Frame")
    container.Name = "CharacterCard"
    container.Size = UDim2.fromOffset(150, 150)
    container.BackgroundColor3 = helpers.Colors.Wood
    container.BorderSizePixel = 0
    container.ZIndex = 6
    container.Parent = parent
    container:SetAttribute("CharacterId", tostring(character.Id))
    helpers.AddCorner(container, 11)
    local cardStroke = helpers.AddStroke(container, helpers.Colors.GoldDark, 2)
    helpers.AddGradient(container, helpers.Colors.WoodLight, helpers.Colors.WoodDark, 90)
    
    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = 1
    aspect.Parent = container
    
    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(1, -8, 1, -8)
    inner.Position = UDim2.fromScale(0.5, 0.5)
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.BackgroundTransparency = 1
    inner.BorderSizePixel = 0
    inner.ZIndex = 7
    inner.Parent = container
    helpers.AddCorner(inner, 8)
    helpers.AddStroke(inner, helpers.Colors.GoldDark, 1)
    
    local portrait = Instance.new("Frame")
    portrait.Name = "PortraitFrame"
    portrait.Size = UDim2.new(1, -14, 0.68, 0)
    portrait.Position = UDim2.new(0.5, 0, 0.04, 0)
    portrait.AnchorPoint = Vector2.new(0.5, 0)
    portrait.BackgroundColor3 = helpers.Colors.Leather
    portrait.BorderSizePixel = 0
    portrait.ZIndex = 8
    portrait.Parent = container
    helpers.AddCorner(portrait, 8)
    local portraitStroke = helpers.AddStroke(portrait, helpers.Colors.Gold, 2)
    helpers.AddGradient(portrait, helpers.Colors.LeatherLight, helpers.Colors.LeatherDark, 90)
    
    local portraitInner = Instance.new("Frame")
    portraitInner.Size = UDim2.new(1, -6, 1, -6)
    portraitInner.Position = UDim2.fromScale(0.5, 0.5)
    portraitInner.AnchorPoint = Vector2.new(0.5, 0.5)
    portraitInner.BackgroundTransparency = 1
    portraitInner.BorderSizePixel = 0
    portraitInner.ZIndex = 9
    portraitInner.Parent = portrait
    helpers.AddCorner(portraitInner, 5)
    helpers.AddStroke(portraitInner, helpers.Colors.GoldDark, 1)
    local viewport = preview.Create(portraitInner, helpers)
    
    local classBadge = Instance.new("TextLabel")
    classBadge.Name = "ClassBadge"
    classBadge.Size = UDim2.fromScale(0.25, 0.25)
    classBadge.Position = UDim2.fromScale(0.72, 0.03)
    classBadge.BackgroundColor3 = helpers.Colors.WoodDark
    classBadge.BackgroundTransparency = 0.12
    classBadge.TextScaled = true
    classBadge.TextColor3 = helpers.Colors.GoldBright
    classBadge.Font = Enum.Font.Fantasy
    classBadge.ZIndex = 15
    classBadge.Parent = portrait
    helpers.AddCorner(classBadge, 6)
    
    local icon, className = getClassIcon(character.Class)
    classBadge.Text = icon
    
    local name = Instance.new("TextLabel")
    name.Name = "CharacterName"
    name.Size = UDim2.new(0.92, 0, 0.12, 0)
    name.Position = UDim2.new(0.04, 0, 0.735, 0)
    name.BackgroundTransparency = 1
    name.Text = tostring(character.Name)
    name.TextScaled = true
    name.TextColor3 = helpers.Colors.GoldBright
    name.Font = Enum.Font.Fantasy
    name.ZIndex = 10
    name.Parent = container
    
    local info = Instance.new("TextLabel")
    info.Name = "CharacterInfo"
    info.Size = UDim2.new(0.92, 0, 0.10, 0)
    info.Position = UDim2.new(0.04, 0, 0.86, 0)
    info.BackgroundTransparency = 1
    info.Text = "Lv. " .. tostring(character.Level or 1) .. "  •  " .. className
    info.TextScaled = true
    info.TextColor3 = helpers.Colors.TextLight
    info.Font = Enum.Font.Garamond
    info.ZIndex = 10
    info.Parent = container
    
    local scale = Instance.new("UIScale")
    scale.Scale = 0.94
    scale.Parent = container
    container.BackgroundTransparency = 1
    name.TextTransparency = 1
    info.TextTransparency = 1
    portrait.BackgroundTransparency = 1
    
    task.delay(0.05, function()
        if not container.Parent then return end
        helpers.Tween(scale, 0.35, {Scale = 1}, Enum.EasingStyle.Back):Play()
        helpers.Tween(container, 0.35, {BackgroundTransparency = 0}):Play()
        helpers.Tween(name, 0.35, {TextTransparency = 0}):Play()
        helpers.Tween(info, 0.4, {TextTransparency = 0}):Play()
        helpers.Tween(portrait, 0.35, {BackgroundTransparency = 0}):Play()
    end)
    
    container.MouseEnter:Connect(function()
        helpers.Tween(cardStroke, 0.18, {Thickness = 3, Color = helpers.Colors.GoldBright}):Play()
        helpers.Tween(portraitStroke, 0.18, {Thickness = 3, Color = helpers.Colors.GoldBright}):Play()
    end)
    container.MouseLeave:Connect(function()
        helpers.Tween(cardStroke, 0.18, {Thickness = 2, Color = helpers.Colors.GoldDark}):Play()
        helpers.Tween(portraitStroke, 0.18, {Thickness = 2, Color = helpers.Colors.Gold}):Play()
    end)
    
    task.spawn(function()
        while classBadge.Parent do
            helpers.Tween(classBadge, 1.5, {TextColor3 = helpers.Colors.GoldLight}, Enum.EasingStyle.Sine):Play()
            task.wait(1.5)
            helpers.Tween(classBadge, 1.5, {TextColor3 = helpers.Colors.GoldBright}, Enum.EasingStyle.Sine):Play()
            task.wait(1.5)
        end
    end)
    
    return {
    Frame = container,
    Viewport = viewport,
    Character = character,
    }
end

return CharacterCard
