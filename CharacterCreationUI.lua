local CharacterCreationUI = {}

local initialized = false
local refs = {}

local ATTRIBUTE_NAMES = {"STR", "DEX", "INT", "VIT", "LUK"}
local INITIAL_POINTS = 25

local attributes = {
	STR = 0,
	DEX = 0,
	INT = 0,
	VIT = 0,
	LUK = 0,
}

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
	row.Size = UDim2.fromScale(0.72, 0.09)
	row.Position = UDim2.fromScale(0.14, 0.365 + ((index - 1) * 0.085))
	row.BackgroundColor3 = colors.Leather
	row.BackgroundTransparency = 0.04
	row.BorderSizePixel = 0
	row.ZIndex = 35
	row.Parent = panel

	refs.addCorner(row, 7)
	refs.addStroke(row, colors.GoldDark, 1)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.28, 1)
	label.Position = UDim2.fromScale(0.03, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextScaled = true
	label.TextColor3 = colors.TextLight
	label.Font = Enum.Font.Fantasy
	label.ZIndex = 36
	label.Parent = row

	local minusButton = Instance.new("TextButton")
	minusButton.Size = UDim2.fromScale(0.14, 0.72)
	minusButton.Position = UDim2.fromScale(0.54, 0.14)
	minusButton.BackgroundColor3 = colors.WoodDark
	minusButton.BorderSizePixel = 0
	minusButton.Text = "−"
	minusButton.TextScaled = true
	minusButton.TextColor3 = colors.GoldBright
	minusButton.Font = Enum.Font.Fantasy
	minusButton.AutoButtonColor = false
	minusButton.ZIndex = 36
	minusButton.Parent = row
	refs.addCorner(minusButton, 6)
	refs.addStroke(minusButton, colors.GoldDark, 1)

	local value = Instance.new("TextLabel")
	value.Size = UDim2.fromScale(0.14, 0.72)
	value.Position = UDim2.fromScale(0.70, 0.14)
	value.BackgroundTransparency = 1
	value.Text = "0"
	value.TextScaled = true
	value.TextColor3 = colors.GoldBright
	value.Font = Enum.Font.Fantasy
	value.ZIndex = 36
	value.Parent = row

	local plusButton = Instance.new("TextButton")
	plusButton.Size = UDim2.fromScale(0.14, 0.72)
	plusButton.Position = UDim2.fromScale(0.84, 0.14)
	plusButton.BackgroundColor3 = colors.WoodDark
	plusButton.BorderSizePixel = 0
	plusButton.Text = "+"
	plusButton.TextScaled = true
	plusButton.TextColor3 = colors.GoldBright
	plusButton.Font = Enum.Font.Fantasy
	plusButton.AutoButtonColor = false
	plusButton.ZIndex = 36
	plusButton.Parent = row
	refs.addCorner(plusButton, 6)
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

local function closeInstant()
	if not refs.createPanel then
		return
	end

	refs.createPanel.Visible = false
	refs.createShadow.Visible = false
	refs.nameInput.Text = ""
	resetAttributes()
	updateAttributeRows()
end

local function open()
	if not initialized then
		return
	end

	resetAttributes()
	refs.nameInput.Text = ""
	updateAttributeRows()

	refs.createPanel.Visible = true
	refs.createShadow.Visible = true

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
	}

	refs.characterRemote:FireServer("CreateCharacter", payload)
end

local function handleServerResponse(action, data)
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
	title.Size = UDim2.fromScale(0.9, 0.09)
	title.Position = UDim2.fromScale(0.05, 0.035)
	title.BackgroundTransparency = 1
	title.Text = "CREATE CHARACTER"
	title.TextScaled = true
	title.TextColor3 = refs.colors.TextDark
	title.Font = Enum.Font.Fantasy
	title.ZIndex = 32
	title.Parent = createPanel

	local divider = Instance.new("TextLabel")
	divider.Size = UDim2.fromScale(0.72, 0.035)
	divider.Position = UDim2.fromScale(0.14, 0.115)
	divider.BackgroundTransparency = 1
	divider.Text = "──── ◆ ────"
	divider.TextScaled = true
	divider.TextColor3 = refs.colors.GoldDark
	divider.Font = Enum.Font.Fantasy
	divider.ZIndex = 32
	divider.Parent = createPanel

	--------------------------------------------------
	-- NAME
	--------------------------------------------------

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(0.72, 0.045)
	nameLabel.Position = UDim2.fromScale(0.14, 0.155)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "CHARACTER NAME"
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = refs.colors.TextMid
	nameLabel.Font = Enum.Font.Garamond
	nameLabel.ZIndex = 32
	nameLabel.Parent = createPanel

	local nameInput = Instance.new("TextBox")
	nameInput.Name = "NameInput"
	nameInput.Size = UDim2.fromScale(0.72, 0.085)
	nameInput.Position = UDim2.fromScale(0.14, 0.205)
	nameInput.BackgroundColor3 = refs.colors.Leather
	nameInput.BorderSizePixel = 0
	nameInput.PlaceholderText = "Enter character name"
	nameInput.PlaceholderColor3 = Color3.fromRGB(214, 185, 139)
	nameInput.Text = ""
	nameInput.TextScaled = true
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
	-- ATTRIBUTES
	--------------------------------------------------

	local attributeTitle = Instance.new("TextLabel")
	attributeTitle.Size = UDim2.fromScale(0.72, 0.045)
	attributeTitle.Position = UDim2.fromScale(0.14, 0.305)
	attributeTitle.BackgroundTransparency = 1
	attributeTitle.Text = "DISTRIBUTE YOUR 25 INITIAL ATTRIBUTE POINTS"
	attributeTitle.TextScaled = true
	attributeTitle.TextColor3 = refs.colors.TextMid
	attributeTitle.Font = Enum.Font.Garamond
	attributeTitle.ZIndex = 32
	attributeTitle.Parent = createPanel

	for index, name in ipairs(ATTRIBUTE_NAMES) do
		createAttributeRow(name, index)
	end

	local pointsLabel = Instance.new("TextLabel")
	pointsLabel.Name = "AvailablePoints"
	pointsLabel.Size = UDim2.fromScale(0.72, 0.055)
	pointsLabel.Position = UDim2.fromScale(0.14, 0.80)
	pointsLabel.BackgroundTransparency = 1
	pointsLabel.Text = "AVAILABLE POINTS: 25"
	pointsLabel.TextScaled = true
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
	confirmButton.Size = UDim2.fromScale(0.43, 0.075)
	confirmButton.Position = UDim2.fromScale(0.14, 0.875)
	confirmButton.BackgroundColor3 = refs.colors.Emerald
	confirmButton.BorderSizePixel = 0
	confirmButton.Text = "DISTRIBUTE ALL POINTS"
	confirmButton.TextScaled = true
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
	cancelButton.Size = UDim2.fromScale(0.27, 0.075)
	cancelButton.Position = UDim2.fromScale(0.59, 0.875)
	cancelButton.BackgroundColor3 = refs.colors.Ruby
	cancelButton.BorderSizePixel = 0
	cancelButton.Text = "CANCEL"
	cancelButton.TextScaled = true
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
