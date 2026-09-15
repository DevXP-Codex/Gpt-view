-- MODULE SCRIPT --

local CharacterCreationUI = {}

local initialized = false
local refs = {}

local CharacterPreview = require(script.Parent:WaitForChild("CharacterPreview"))

local ATTRIBUTE_NAMES = {"STR", "DEX", "INT", "VIT", "LUK"}
local INITIAL_POINTS = 25

local attributes = {
STR = 0,
DEX = 0,
INT = 0,
VIT = 0,
LUK = 0,
}

local customization = {Skin = nil, Hair = "Pal_Hair", Face = "Face01"}
local customizationOptions = {Skin = {}, Hair = {}, Face = {}}
local previewRequestToken = 0

local function resetAttributes()
    for _, name in ipairs(ATTRIBUTE_NAMES) do
        attributes[name] = 0
    end
end

local function getSpentPoints()
    local total = 0
    for _, name in ipairs(ATTRIBUTE_NAMES) do
        total += attributes[name]
    end
    return total
end

local function updatePointDisplay()
    if not refs.pointsLabel then
        return
    end
    
    local spent = getSpentPoints()
    local remaining = INITIAL_POINTS - spent
    
    refs.pointsLabel.Text = "AVAILABLE POINTS: " .. tostring(remaining)
    
    if remaining == 0 then
        refs.pointsLabel.TextColor3 = refs.colors.EmeraldBright
        refs.confirmButton.Text = "CREATE CHARACTER"
    else
        refs.pointsLabel.TextColor3 = refs.colors.Ruby
        refs.confirmButton.Text = "DISTRIBUTE ALL POINTS"
    end
end

local function updateAttributeRows()
    for _, name in ipairs(ATTRIBUTE_NAMES) do
        local row = refs.rows[name]
        if row then
            row.value.Text = tostring(attributes[name])
            row.minusButton.TextTransparency = attributes[name] <= 0 and 0.55 or 0
            row.plusButton.TextTransparency = getSpentPoints() >= INITIAL_POINTS and 0.55 or 0
        end
    end
    
    updatePointDisplay()
end

local function changeAttribute(name, amount)
    local current = attributes[name]
    local nextValue = current + amount
    
    if nextValue < 0 then
        return
    end
    
    if amount > 0 and getSpentPoints() >= INITIAL_POINTS then
        return
    end
    
    attributes[name] = nextValue
    updateAttributeRows()
end

local function createAttributeRow(name, index)
    local panel = refs.createPanel
    local colors = refs.colors

    local row = Instance.new("Frame")
    row.Name = name .. "Row"
    row.Size = UDim2.fromScale(0.55, 0.052)
    row.Position = UDim2.fromScale(0.08, 0.585 + ((index - 1) * 0.053))
    row.BackgroundColor3 = colors.Leather
    row.BackgroundTransparency = 0.04
    row.BorderSizePixel = 0
    row.ZIndex = 35
    row.Parent = panel

    refs.addCorner(row, 6)
    refs.addStroke(row, colors.GoldDark, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(0.24, 1)
    label.Position = UDim2.fromScale(0.035, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextSize = 20
    label.TextColor3 = colors.TextLight
    label.Font = Enum.Font.Fantasy
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 36
    label.Parent = row

    local minusButton = Instance.new("TextButton")
    minusButton.Size = UDim2.fromScale(0.11, 0.76)
    minusButton.Position = UDim2.fromScale(0.57, 0.12)
    minusButton.BackgroundColor3 = colors.WoodDark
    minusButton.BorderSizePixel = 0
    minusButton.Text = "−"
    minusButton.TextSize = 20
    minusButton.TextColor3 = colors.GoldBright
    minusButton.Font = Enum.Font.Fantasy
    minusButton.AutoButtonColor = false
    minusButton.ZIndex = 36
    minusButton.Parent = row
    refs.addCorner(minusButton, 5)
    refs.addStroke(minusButton, colors.GoldDark, 1)

    local value = Instance.new("TextLabel")
    value.Size = UDim2.fromScale(0.14, 0.76)
    value.Position = UDim2.fromScale(0.70, 0.12)
    value.BackgroundTransparency = 1
    value.Text = "0"
    value.TextSize = 18
    value.TextColor3 = colors.GoldBright
    value.Font = Enum.Font.Fantasy
    value.TextXAlignment = Enum.TextXAlignment.Center
    value.TextYAlignment = Enum.TextYAlignment.Center
    value.ZIndex = 36
    value.Parent = row

    local plusButton = Instance.new("TextButton")
    plusButton.Size = UDim2.fromScale(0.11, 0.76)
    plusButton.Position = UDim2.fromScale(0.86, 0.12)
    plusButton.BackgroundColor3 = colors.WoodDark
    plusButton.BorderSizePixel = 0
    plusButton.Text = "+"
    plusButton.TextSize = 20
    plusButton.TextColor3 = colors.GoldBright
    plusButton.Font = Enum.Font.Fantasy
    plusButton.AutoButtonColor = false
    plusButton.ZIndex = 36
    plusButton.Parent = row
    refs.addCorner(plusButton, 5)
    refs.addStroke(plusButton, colors.GoldDark, 1)

    minusButton.Activated:Connect(function()
        changeAttribute(name, -1)
    end)

    plusButton.Activated:Connect(function()
        changeAttribute(name, 1)
    end)

    refs.rows[name] = {
        frame = row,
        value = value,
        minusButton = minusButton,
        plusButton = plusButton,
    }
end

local function optionIndex(category, id)
    for index, option in ipairs(customizationOptions[category] or {}) do
        if tostring(option.Id) == tostring(id) then
            return index
        end
    end
    return nil
end

local function updateCustomizationLabel(category)
    local ref = refs.customization and refs.customization[category]
    if not ref then
        return
    end

    local index = optionIndex(category, customization[category])
    local option = index and customizationOptions[category][index]
    ref.value.Text = option and tostring(option.Name)
        or tostring(customization[category] or "Default")
end

local function requestCreationPreview()
    if not refs.characterRemote then
        return
    end

    previewRequestToken += 1
    local token = previewRequestToken

    task.delay(0.08, function()
        if token ~= previewRequestToken then
            return
        end

        refs.characterRemote:FireServer("GetCreationPreview", {
            Skin = customization.Skin,
            Hair = customization.Hair,
            Face = customization.Face,
        })
    end)
end

local function setCustomization(category, direction)
    local options = customizationOptions[category]
    if not options or #options == 0 then
        return
    end

    local current = optionIndex(category, customization[category]) or 1
    local nextIndex = current + direction

    if nextIndex < 1 then
        nextIndex = #options
    elseif nextIndex > #options then
        nextIndex = 1
    end

    customization[category] = options[nextIndex].Id
    updateCustomizationLabel(category)
    requestCreationPreview()
end

local function buildCustomizationRow(category, title, y)
    local panel, colors = refs.createPanel, refs.colors

    local row = Instance.new("Frame")
    row.Name = category .. "Customization"
    row.Size = UDim2.fromScale(0.55, 0.068)
    row.Position = UDim2.fromScale(0.08, y)
    row.BackgroundColor3 = colors.Leather
    row.BackgroundTransparency = 0.04
    row.BorderSizePixel = 0
    row.ZIndex = 35
    row.Parent = panel

    refs.addCorner(row, 7)
    refs.addStroke(row, colors.GoldDark, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(0.25, 1)
    label.Position = UDim2.fromScale(0.035, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextSize = 20
    label.TextColor3 = colors.TextLight
    label.Font = Enum.Font.Fantasy
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 36
    label.Parent = row

    local previous = Instance.new("TextButton")
    previous.Size = UDim2.fromScale(0.10, 0.72)
    previous.Position = UDim2.fromScale(0.56, 0.14)
    previous.BackgroundColor3 = colors.WoodDark
    previous.BorderSizePixel = 0
    previous.Text = "‹"
    previous.TextSize = 23
    previous.TextColor3 = colors.GoldBright
    previous.Font = Enum.Font.Fantasy
    previous.AutoButtonColor = false
    previous.ZIndex = 36
    previous.Parent = row
    refs.addCorner(previous, 6)
    refs.addStroke(previous, colors.GoldDark, 1)

    local value = Instance.new("TextLabel")
    value.Size = UDim2.fromScale(0.22, 0.78)
    value.Position = UDim2.fromScale(0.67, 0.11)
    value.BackgroundTransparency = 1
    value.Text = tostring(customization[category] or "Default")
    value.TextSize = 17
    value.TextColor3 = colors.GoldBright
    value.Font = Enum.Font.Fantasy
    value.TextXAlignment = Enum.TextXAlignment.Center
    value.TextYAlignment = Enum.TextYAlignment.Center
    value.TextTruncate = Enum.TextTruncate.AtEnd
    value.ZIndex = 36
    value.Parent = row

    local nextButton = Instance.new("TextButton")
    nextButton.Size = UDim2.fromScale(0.10, 0.72)
    nextButton.Position = UDim2.fromScale(0.87, 0.14)
    nextButton.BackgroundColor3 = colors.WoodDark
    nextButton.BorderSizePixel = 0
    nextButton.Text = "›"
    nextButton.TextSize = 23
    nextButton.TextColor3 = colors.GoldBright
    nextButton.Font = Enum.Font.Fantasy
    nextButton.AutoButtonColor = false
    nextButton.ZIndex = 36
    nextButton.Parent = row
    refs.addCorner(nextButton, 6)
    refs.addStroke(nextButton, colors.GoldDark, 1)

    previous.Activated:Connect(function()
        setCustomization(category, -1)
    end)

    nextButton.Activated:Connect(function()
        setCustomization(category, 1)
    end)

    refs.customization = refs.customization or {}
    refs.customization[category] = {
        row = row,
        value = value,
        previous = previous,
        next = nextButton,
    }
end

local function updateCustomizationOptions(data)
    if typeof(data) ~= "table" then
        return
    end

    for _, category in ipairs({"Skin", "Hair", "Face"}) do
        if typeof(data[category]) == "table" then
            customizationOptions[category] = data[category]
        end
    end

    if not optionIndex("Skin", customization.Skin) then
        customization.Skin = customizationOptions.Skin[1]
            and customizationOptions.Skin[1].Id
            or customization.Skin
    end

    if not optionIndex("Hair", customization.Hair) then
        customization.Hair = customizationOptions.Hair[1]
            and customizationOptions.Hair[1].Id
            or customization.Hair
    end

    if not optionIndex("Face", customization.Face) then
        customization.Face = customizationOptions.Face[1]
            and customizationOptions.Face[1].Id
            or customization.Face
    end

    for _, category in ipairs({"Skin", "Hair", "Face"}) do
        updateCustomizationLabel(category)
    end
end

local function closeInstant()
            if not refs.createPanel then
                return
            end
            
            refs.createPanel.Visible = false
            refs.createShadow.Visible = false
            refs.nameInput.Text = ""
            resetAttributes()
            customization.Skin = customizationOptions.Skin[1] and customizationOptions.Skin[1].Id or customization.Skin
            customization.Hair = "Pal_Hair"
            customization.Face = "Face01"
            updateAttributeRows()
            if refs.customization then for _, category in ipairs({"Skin", "Hair", "Face"}) do updateCustomizationLabel(category) end end
        end
        
        local function open()
            if not initialized then
                return
            end
            
            resetAttributes()
            refs.nameInput.Text = ""
            customization.Skin = customizationOptions.Skin[1] and customizationOptions.Skin[1].Id or customization.Skin
            customization.Hair = "Pal_Hair"
            customization.Face = "Face01"
            updateAttributeRows()
            
            refs.createPanel.Visible = true
            refs.createShadow.Visible = true
            
            if refs.characterRemote then
                refs.characterRemote:FireServer("GetCreationPreview", customization)
            end
            
            refs.createPanel.Size = UDim2.fromScale(0.72, 0.78)
            refs.createPanel.Position = UDim2.fromScale(0.14, 0.11)
            refs.createPanel.BackgroundTransparency = 1
            
            refs.tween(
            refs.createPanel,
            0.28,
            {
            Size = UDim2.fromScale(0.88, 0.86),
            Position = UDim2.fromScale(0.06, 0.07),
            BackgroundTransparency = 0,
            },
            Enum.EasingStyle.Back
            ):Play()
            
            refs.createShadow.Size = UDim2.new(0.72, 10, 0.78, 10)
            refs.createShadow.Position = UDim2.fromScale(0.14, 0.11)
            
            refs.tween(
            refs.createShadow,
            0.28,
            {
            Size = UDim2.new(0.88, 10, 0.86, 10),
            Position = UDim2.new(0.06, 5, 0.07, 7),
            },
            Enum.EasingStyle.Back
            ):Play()
        end
        
        local function close()
            if not initialized then
                return
            end
            
            refs.tween(
            refs.createPanel,
            0.16,
            {
            Size = UDim2.fromScale(0.72, 0.78),
            Position = UDim2.fromScale(0.14, 0.11),
            BackgroundTransparency = 1,
            },
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
            ):Play()
            
            refs.tween(
            refs.createShadow,
            0.16,
            {
            Size = UDim2.new(0.72, 10, 0.78, 10),
            Position = UDim2.fromScale(0.14, 0.11),
            },
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
            ):Play()
            
            task.delay(0.17, function()
                if not initialized then
                    return
                end
                closeInstant()
            end)
        end
        
        local function confirm()
            if not initialized then
                return
            end
            
            local name = refs.nameInput.Text
            
            if name == "" then
                refs.showMessage("Enter a character name.")
                return
            end
            
            local spent = getSpentPoints()
            
            if spent ~= INITIAL_POINTS then
                refs.showMessage("Distribute all 25 attribute points before creating your character.")
                return
            end
            
            local payload = {
            Name = name,
            Attributes = {
            STR = attributes.STR,
            DEX = attributes.DEX,
            INT = attributes.INT,
            VIT = attributes.VIT,
            LUK = attributes.LUK,
            },
            Customization = {
            Skin = customization.Skin,
            Hair = customization.Hair,
            Face = customization.Face,
            },
            }
            
            refs.characterRemote:FireServer("CreateCharacter", payload)
        end
        
        local function handleServerResponse(action, data)
            if action == "CreationAppearanceOptions" then
                updateCustomizationOptions(data)
                return true
            end
            
            if action == "CreationAppearancePreview" then
                if not refs.creationViewport then
                    return true
                end
                
                local previewFolder = game:GetService("ReplicatedStorage"):FindFirstChild("YAMA_CharacterPreviews")
                if not previewFolder or typeof(data) ~= "table" or not data.PreviewName then
                    return true
                end
                
                local previewModel = previewFolder:FindFirstChild(data.PreviewName)
                local deadline = os.clock() + 5
                
                while not previewModel and os.clock() < deadline do
                    task.wait(0.05)
                    previewModel = previewFolder:FindFirstChild(data.PreviewName)
                end
                
                if previewModel and previewModel:IsA("Model") then
                    local ok, rendered = pcall(function()
                        return CharacterPreview.Render(refs.creationViewport, previewModel)
                    end)
                    if refs.creationFallback then
                        refs.creationFallback.Visible = not ok or not rendered
                    end
                else
                    if refs.creationFallback then refs.creationFallback.Visible = true end
                end
                return true
            end
            
            if action == "CreationAppearancePreviewFailed" then
                if refs.creationFallback then refs.creationFallback.Visible = true end
                return true
            end
            
            if action == "CharacterCreated" then
                closeInstant()
                refs.characterRemote:FireServer("GetCharacters")
                return true
            end
            
            if action == "CharacterCreationFailed" then
                if data == "CHARACTER_LIMIT" then
                    refs.showMessage("Character limit reached.")
                elseif data == "NAME_TOO_SHORT" then
                    refs.showMessage("Character name must be at least 3 characters.")
                elseif data == "NAME_TOO_LONG" then
                    refs.showMessage("Character name cannot exceed 16 characters.")
                elseif data == "NAME_ALREADY_EXISTS" then
                    refs.showMessage("A character with this name already exists.")
                elseif data == "INVALID_NAME" then
                    refs.showMessage("Invalid character name.")
                elseif data == "ATTRIBUTE_POINTS_REQUIRED" then
                    refs.showMessage("You must distribute all 25 attribute points.")
                elseif data == "INVALID_ATTRIBUTES" then
                    refs.showMessage("Invalid attribute distribution.")
                elseif data == "INVALID_CUSTOMIZATION" then
                    refs.showMessage("Invalid character customization.")
                else
                    refs.showMessage("Character creation failed.")
                end
                return true
            end
            
            if action == "EnterMainMenu" then
                closeInstant()
                return false
            end
            
            return false
        end
        
        function CharacterCreationUI.Initialize(config)
            if initialized then
                return
            end
            
            assert(config, "CharacterCreationUI requires a config table")
            assert(config.MainFrame, "CharacterCreationUI requires MainFrame")
            assert(config.CharacterRemote, "CharacterCreationUI requires CharacterRemote")
            assert(config.Colors, "CharacterCreationUI requires Colors")
            
            refs.mainFrame = config.MainFrame
            refs.characterRemote = config.CharacterRemote
            refs.colors = config.Colors
            refs.showMessage = config.ShowMessage
            refs.tween = config.Tween
            refs.addCorner = config.AddCorner
            refs.addStroke = config.AddStroke
            refs.addGradient = config.AddGradient
            refs.setupButtonEffects = config.SetupButtonEffects
            
            assert(refs.showMessage, "CharacterCreationUI requires ShowMessage")
            assert(refs.tween, "CharacterCreationUI requires Tween")
            assert(refs.addCorner, "CharacterCreationUI requires AddCorner")
            assert(refs.addStroke, "CharacterCreationUI requires AddStroke")
            
            refs.rows = {}
            
            --------------------------------------------------
            -- CREATE BUTTON
            --------------------------------------------------
            
            local createButton = Instance.new("TextButton")
            createButton.Name = "CreateCharacter"
            createButton.Size = UDim2.fromScale(0.65, 0.085)
            createButton.Position = UDim2.fromScale(0.175, 0.855)
            createButton.BackgroundColor3 = refs.colors.Wood
            createButton.BorderSizePixel = 0
            createButton.Text = "+  CREATE CHARACTER"
            createButton.TextScaled = true
            createButton.TextColor3 = refs.colors.GoldBright
            createButton.Font = Enum.Font.Fantasy
            createButton.AutoButtonColor = false
            createButton.ZIndex = 8
            createButton.Parent = refs.mainFrame
            
            refs.addCorner(createButton, 10)
            local createStroke = refs.addStroke(createButton, refs.colors.Gold, 2)
            
            if refs.addGradient then
                refs.addGradient(
                createButton,
                refs.colors.WoodLight,
                refs.colors.WoodDark,
                90
                )
            end
            
            if refs.setupButtonEffects then
                refs.setupButtonEffects(createButton, createStroke, 1)
            end
            
            refs.createButton = createButton
            
            --------------------------------------------------
            -- SHADOW
            --------------------------------------------------
            
            local createShadow = Instance.new("Frame")
            createShadow.Name = "CreateShadow"
            createShadow.Size = UDim2.new(0.88, 10, 0.86, 10)
            createShadow.Position = UDim2.new(0.06, 5, 0.07, 7)
            createShadow.BackgroundColor3 = refs.colors.Black
            createShadow.BackgroundTransparency = 0.7
            createShadow.BorderSizePixel = 0
            createShadow.ZIndex = 29
            createShadow.Visible = false
            createShadow.Parent = refs.mainFrame
            refs.addCorner(createShadow, 16)
            refs.createShadow = createShadow
            
            --------------------------------------------------
            -- PANEL
            --------------------------------------------------
            
            local createPanel = Instance.new("Frame")
            createPanel.Name = "CreatePanel"
            createPanel.Size = UDim2.fromScale(0.88, 0.86)
            createPanel.Position = UDim2.fromScale(0.06, 0.07)
            createPanel.BackgroundColor3 = refs.colors.Parchment
            createPanel.BorderSizePixel = 0
            createPanel.Visible = false
            createPanel.ZIndex = 30
            createPanel.Parent = refs.mainFrame
            
            refs.addCorner(createPanel, 14)
            refs.addStroke(createPanel, refs.colors.Gold, 3)
            
            if refs.addGradient then
                refs.addGradient(
                createPanel,
                refs.colors.ParchmentLight,
                refs.colors.Parchment,
                90
                )
            end
            
            refs.createPanel = createPanel
            
            --------------------------------------------------
            -- TITLE
            --------------------------------------------------
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.fromScale(0.9, 0.085)
            title.Position = UDim2.fromScale(0.05, 0.035)
            title.BackgroundTransparency = 1
            title.Text = "CREATE CHARACTER"
            title.TextScaled = false
            title.TextSize = 34
            title.TextColor3 = refs.colors.TextDark
            title.Font = Enum.Font.Fantasy
            title.ZIndex = 32
            title.Parent = createPanel
            
            local divider = Instance.new("TextLabel")
            divider.Size = UDim2.fromScale(0.55, 0.035)
            divider.Position = UDim2.fromScale(0.08, 0.115)
            divider.BackgroundTransparency = 1
            divider.Text = "──── ◆ ────"
            divider.TextScaled = false
            divider.TextSize = 16
            divider.TextColor3 = refs.colors.GoldDark
            divider.Font = Enum.Font.Fantasy
            divider.ZIndex = 32
            divider.Parent = createPanel
            
            --------------------------------------------------
            -- NAME
            --------------------------------------------------
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.fromScale(0.55, 0.045)
            nameLabel.Position = UDim2.fromScale(0.08, 0.155)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = "CHARACTER NAME"
            nameLabel.TextScaled = false
            nameLabel.TextSize = 17
            nameLabel.TextColor3 = refs.colors.TextMid
            nameLabel.Font = Enum.Font.Garamond
            nameLabel.ZIndex = 32
            nameLabel.Parent = createPanel
            
            local nameInput = Instance.new("TextBox")
            nameInput.Name = "NameInput"
            nameInput.Size = UDim2.fromScale(0.55, 0.085)
            nameInput.Position = UDim2.fromScale(0.08, 0.205)
            nameInput.BackgroundColor3 = refs.colors.Leather
            nameInput.BorderSizePixel = 0
            nameInput.PlaceholderText = "Enter character name"
            nameInput.PlaceholderColor3 = Color3.fromRGB(214, 185, 139)
            nameInput.Text = ""
            nameInput.TextScaled = false
            nameInput.TextSize = 24
            nameInput.TextXAlignment = Enum.TextXAlignment.Center
            nameInput.TextYAlignment = Enum.TextYAlignment.Center
            nameInput.TextColor3 = refs.colors.TextLight
            nameInput.Font = Enum.Font.Garamond
            nameInput.ClearTextOnFocus = false
            nameInput.ZIndex = 32
            nameInput.Parent = createPanel
            
            refs.addCorner(nameInput, 8)
            local inputStroke = refs.addStroke(nameInput, refs.colors.GoldDark, 2)
            
            nameInput.Focused:Connect(function()
                refs.tween(inputStroke, 0.15, {
                Thickness = 3,
                Color = refs.colors.GoldBright,
                }):Play()
            end)
            
            nameInput.FocusLost:Connect(function()
                refs.tween(inputStroke, 0.15, {
                Thickness = 2,
                Color = refs.colors.GoldDark,
                }):Play()
            end)
            
            refs.nameInput = nameInput
            
            --------------------------------------------------
            -- LIVE CHARACTER CUSTOMIZATION
            --------------------------------------------------
            
            refs.customization = {}
            buildCustomizationRow("Skin", "SKIN", 0.305)
            buildCustomizationRow("Hair", "HAIR", 0.380)
            buildCustomizationRow("Face", "FACE", 0.455)
            
            --------------------------------------------------
            -- CHARACTER PORTRAIT
            -- Uses the exact same CharacterPreview renderer as CharacterUI.
            --------------------------------------------------
            
            local portraitFrame = Instance.new("Frame")
            portraitFrame.Name = "CreationPortrait"
            portraitFrame.Size = UDim2.fromScale(0.30, 0.60)
            portraitFrame.Position = UDim2.fromScale(0.66, 0.22)
            portraitFrame.BackgroundColor3 = refs.colors.Leather
            portraitFrame.BorderSizePixel = 0
            portraitFrame.ZIndex = 32
            portraitFrame.Parent = createPanel
            refs.addCorner(portraitFrame, 10)
            refs.addStroke(portraitFrame, refs.colors.Gold, 2)
            
            if refs.addGradient then
                refs.addGradient(
                portraitFrame,
                refs.colors.LeatherLight,
                refs.colors.LeatherDark,
                90
                )
            end
            
            local portraitInner = Instance.new("Frame")
            portraitInner.Name = "PortraitInner"
            portraitInner.Size = UDim2.new(1, -10, 1, -10)
            portraitInner.Position = UDim2.fromScale(0.5, 0.5)
            portraitInner.AnchorPoint = Vector2.new(0.5, 0.5)
            portraitInner.BackgroundTransparency = 1
            portraitInner.BorderSizePixel = 0
            portraitInner.ClipsDescendants = true
            portraitInner.ZIndex = 33
            portraitInner.Parent = portraitFrame
            refs.addCorner(portraitInner, 7)
            
            local portraitViewport = CharacterPreview.Create(portraitInner, {
            AddCorner = refs.addCorner,
            })
            
            portraitViewport.ZIndex = 34
            refs.creationViewport = portraitViewport
            
            local portraitCaption = Instance.new("TextLabel")
            portraitCaption.Name = "PortraitCaption"
            portraitCaption.Size = UDim2.new(0.88, 0, 0.065, 0)
            portraitCaption.Position = UDim2.fromScale(0.06, 0.925)
            portraitCaption.BackgroundTransparency = 1
            portraitCaption.Text = "ADVENTURER"
            portraitCaption.TextScaled = false
            portraitCaption.TextSize = 16
            portraitCaption.TextColor3 = refs.colors.GoldBright
            portraitCaption.Font = Enum.Font.Fantasy
            portraitCaption.ZIndex = 36
            portraitCaption.Parent = portraitFrame
            
            local portraitFallback = Instance.new("TextLabel")
            portraitFallback.Name = "PortraitFallback"
            portraitFallback.Size = UDim2.new(0.8, 0, 0.30, 0)
            portraitFallback.Position = UDim2.fromScale(0.1, 0.35)
            portraitFallback.BackgroundTransparency = 1
            portraitFallback.Text = "CHARACTER\nPREVIEW"
            portraitFallback.TextScaled = false
            portraitFallback.TextSize = 18
            portraitFallback.TextWrapped = true
            portraitFallback.TextColor3 = refs.colors.TextMid
            portraitFallback.Font = Enum.Font.Garamond
            portraitFallback.ZIndex = 35
            portraitFallback.Parent = portraitInner
            refs.creationFallback = portraitFallback
            
            --------------------------------------------------
            -- ATTRIBUTES
            --------------------------------------------------
            
            local attributeTitle = Instance.new("TextLabel")
            attributeTitle.Size = UDim2.fromScale(0.55, 0.045)
            attributeTitle.Position = UDim2.fromScale(0.08, 0.55)
            attributeTitle.BackgroundTransparency = 1
            attributeTitle.Text = "DISTRIBUTE YOUR 25 INITIAL ATTRIBUTE POINTS"
            attributeTitle.TextScaled = false
            attributeTitle.TextSize = 13
            attributeTitle.TextXAlignment = Enum.TextXAlignment.Left
            attributeTitle.TextColor3 = refs.colors.TextMid
            attributeTitle.Font = Enum.Font.Garamond
            attributeTitle.ZIndex = 32
            attributeTitle.Parent = createPanel
            
            for index, name in ipairs(ATTRIBUTE_NAMES) do
                createAttributeRow(name, index)
            end
            
            local pointsLabel = Instance.new("TextLabel")
            pointsLabel.Name = "AvailablePoints"
            pointsLabel.Size = UDim2.fromScale(0.55, 0.055)
            pointsLabel.Position = UDim2.fromScale(0.08, 0.855)
            pointsLabel.BackgroundTransparency = 1
            pointsLabel.Text = "AVAILABLE POINTS: 25"
            pointsLabel.TextScaled = false
            pointsLabel.TextSize = 17
            pointsLabel.TextXAlignment = Enum.TextXAlignment.Left
            pointsLabel.TextColor3 = refs.colors.Ruby
            pointsLabel.Font = Enum.Font.Fantasy
            pointsLabel.ZIndex = 32
            pointsLabel.Parent = createPanel
            refs.pointsLabel = pointsLabel
            
            --------------------------------------------------
            -- BUTTONS
            --------------------------------------------------
            
            local confirmButton = Instance.new("TextButton")
            confirmButton.Name = "Confirm"
            confirmButton.Size = UDim2.fromScale(0.33, 0.075)
            confirmButton.Position = UDim2.fromScale(0.08, 0.91)
            confirmButton.BackgroundColor3 = refs.colors.Emerald
            confirmButton.BorderSizePixel = 0
            confirmButton.Text = "DISTRIBUTE ALL POINTS"
            confirmButton.TextScaled = false
            confirmButton.TextSize = 16
            confirmButton.TextColor3 = refs.colors.GoldBright
            confirmButton.Font = Enum.Font.Fantasy
            confirmButton.AutoButtonColor = false
            confirmButton.ZIndex = 32
            confirmButton.Parent = createPanel
            
            refs.addCorner(confirmButton, 8)
            local confirmStroke = refs.addStroke(confirmButton, refs.colors.EmeraldBright, 2)
            if refs.addGradient then
                refs.addGradient(confirmButton, refs.colors.Emerald, refs.colors.EmeraldDark, 90)
            end
            if refs.setupButtonEffects then
                refs.setupButtonEffects(confirmButton, confirmStroke, 1)
            end
            refs.confirmButton = confirmButton
            
            local cancelButton = Instance.new("TextButton")
            cancelButton.Name = "Cancel"
            cancelButton.Size = UDim2.fromScale(0.22, 0.075)
            cancelButton.Position = UDim2.fromScale(0.43, 0.91)
            cancelButton.BackgroundColor3 = refs.colors.Ruby
            cancelButton.BorderSizePixel = 0
            cancelButton.Text = "CANCEL"
            cancelButton.TextScaled = false
            cancelButton.TextSize = 16
            cancelButton.TextColor3 = refs.colors.TextLight
            cancelButton.Font = Enum.Font.Fantasy
            cancelButton.AutoButtonColor = false
            cancelButton.ZIndex = 32
            cancelButton.Parent = createPanel
            
            refs.addCorner(cancelButton, 8)
            local cancelStroke = refs.addStroke(cancelButton, refs.colors.RubyBright, 2)
            if refs.addGradient then
                refs.addGradient(cancelButton, refs.colors.Ruby, refs.colors.RubyDark, 90)
            end
            if refs.setupButtonEffects then
                refs.setupButtonEffects(cancelButton, cancelStroke, 1)
            end
            
            createButton.Activated:Connect(open)
            cancelButton.Activated:Connect(close)
            confirmButton.Activated:Connect(confirm)
            
            initialized = true
            resetAttributes()
            updateAttributeRows()
        end
        
        function CharacterCreationUI.Open()
            open()
        end
        
        function CharacterCreationUI.Close()
            closeInstant()
        end
        
        function CharacterCreationUI.HandleServerResponse(action, data)
            return handleServerResponse(action, data)
        end
        
        function CharacterCreationUI.GetAttributes()
            return {
            STR = attributes.STR,
            DEX = attributes.DEX,
            INT = attributes.INT,
            VIT = attributes.VIT,
            LUK = attributes.LUK,
            }
        end
        
        function CharacterCreationUI.GetPointsRemaining()
            return INITIAL_POINTS - getSpentPoints()
        end
        
        return CharacterCreationUI
