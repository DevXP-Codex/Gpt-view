-- LOCAL SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- IN-GAME MENU
--------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local CharacterRemote =
ReplicatedStorage:WaitForChild("CharacterRemote")


--------------------------------------------------
-- SCREEN GUI
--------------------------------------------------

local playerGui =
player:WaitForChild("PlayerGui")

local oldGui =
playerGui:FindFirstChild("InGameMenu")

if oldGui then
    oldGui:Destroy()
end

local screenGui =
Instance.new("ScreenGui")

screenGui.Name =
"InGameMenu"

screenGui.ResetOnSpawn =
false

screenGui.IgnoreGuiInset =
true

screenGui.DisplayOrder =
150

screenGui.Enabled =
false

screenGui.Parent =
playerGui


--------------------------------------------------
-- MENU BUTTON
--------------------------------------------------

local menuButton =
Instance.new("TextButton")

menuButton.Name =
"MenuButton"

menuButton.Size =
UDim2.fromScale(0.13, 0.065)

menuButton.Position =
UDim2.fromScale(0.84, 0.04)

menuButton.BackgroundColor3 =
Color3.fromRGB(66, 41, 21)

menuButton.BorderSizePixel =
0

menuButton.Text =
"MENU"

menuButton.TextColor3 =
Color3.fromRGB(255, 224, 132)

menuButton.TextScaled =
true

menuButton.Font =
Enum.Font.Fantasy

menuButton.AutoButtonColor =
false

menuButton.ZIndex =
10

menuButton.Parent =
screenGui

local buttonCorner =
Instance.new("UICorner")

buttonCorner.CornerRadius =
UDim.new(0, 8)

buttonCorner.Parent =
menuButton

local buttonStroke =
Instance.new("UIStroke")

buttonStroke.Color =
Color3.fromRGB(216, 170, 73)

buttonStroke.Thickness =
2

buttonStroke.Parent =
menuButton


--------------------------------------------------
-- MENU PANEL
--------------------------------------------------

local menuPanel =
Instance.new("Frame")

menuPanel.Name =
"MenuPanel"

menuPanel.Size =
UDim2.fromScale(0.34, 0.56)

menuPanel.Position =
UDim2.fromScale(0.33, 0.22)

menuPanel.BackgroundColor3 =
Color3.fromRGB(108, 71, 36)

menuPanel.BorderSizePixel =
0

menuPanel.Visible =
false

menuPanel.ZIndex =
20

menuPanel.Parent =
screenGui

local panelCorner =
Instance.new("UICorner")

panelCorner.CornerRadius =
UDim.new(0, 12)

panelCorner.Parent =
menuPanel

local panelStroke =
Instance.new("UIStroke")

panelStroke.Color =
Color3.fromRGB(216, 170, 73)

panelStroke.Thickness =
2

panelStroke.Parent =
menuPanel


--------------------------------------------------
-- TITLE
--------------------------------------------------

local title =
Instance.new("TextLabel")

title.Size =
UDim2.fromScale(0.8, 0.13)

title.Position =
UDim2.fromScale(0.1, 0.05)

title.BackgroundTransparency =
1

title.Text =
"YAMA: LEGENDS"

title.TextColor3 =
Color3.fromRGB(255, 224, 132)

title.TextScaled =
true

title.Font =
Enum.Font.Fantasy

title.ZIndex =
21

title.Parent =
menuPanel


--------------------------------------------------
-- BUTTON HELPER
--------------------------------------------------

local function createMenuButton(
    buttonName,
    text,
    position,
    backgroundColor
    )
    
    local button =
    Instance.new("TextButton")
    
    button.Name =
    buttonName
    
    button.Size =
    UDim2.fromScale(0.72, 0.12)
    
    button.Position =
    position
    
    button.BackgroundColor3 =
    backgroundColor
    
    button.BorderSizePixel =
    0
    
    button.Text =
    text
    
    button.TextColor3 =
    Color3.fromRGB(255, 224, 132)
    
    button.TextScaled =
    true
    
    button.Font =
    Enum.Font.Fantasy
    
    button.AutoButtonColor =
    false
    
    button.ZIndex =
    21
    
    button.Parent =
    menuPanel
    
    local corner =
    Instance.new("UICorner")
    
    corner.CornerRadius =
    UDim.new(0, 8)
    
    corner.Parent =
    button
    
    local stroke =
    Instance.new("UIStroke")
    
    stroke.Color =
    Color3.fromRGB(216, 170, 73)
    
    stroke.Thickness =
    2
    
    stroke.Parent =
    button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(
        button,
        TweenInfo.new(0.12),
        {Size = UDim2.fromScale(0.75, 0.125)}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(
        button,
        TweenInfo.new(0.12),
        {Size = UDim2.fromScale(0.72, 0.12)}
        ):Play()
    end)
    
    return button
    
end


--------------------------------------------------
-- MENU OPTIONS
--------------------------------------------------

local changeCharacterButton =
createMenuButton(
"ChangeCharacter",
"CHANGE CHARACTER",
UDim2.fromScale(0.14, 0.23),
Color3.fromRGB(30, 126, 72)
)

local inventoryButton =
createMenuButton(
"Inventory",
"INVENTORY",
UDim2.fromScale(0.14, 0.38),
Color3.fromRGB(88, 56, 28)
)

local testItemButton =
createMenuButton(
"AddTestItem",
"ADD TEST ITEM",
UDim2.fromScale(0.14, 0.53),
Color3.fromRGB(88, 56, 28)
)

local exitButton =
createMenuButton(
"ExitGame",
"EXIT GAME",
UDim2.fromScale(0.14, 0.68),
Color3.fromRGB(157, 36, 49)
)


--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local closeButton =
createMenuButton(
"Close",
"CLOSE",
UDim2.fromScale(0.14, 0.83),
Color3.fromRGB(66, 41, 21)
)


--------------------------------------------------
-- OPEN / CLOSE
--------------------------------------------------

menuButton.Activated:Connect(function()
    
    menuPanel.Visible =
    not menuPanel.Visible
    
end)


closeButton.Activated:Connect(function()
    
    menuPanel.Visible =
    false
    
end)


--------------------------------------------------
-- CHANGE CHARACTER
--------------------------------------------------

changeCharacterButton.Activated:Connect(function()
    
    menuPanel.Visible =
    false
    
    -- The server removes the active character,
    -- saves the player and returns the client to MainMenu.
    CharacterRemote:FireServer(
    "ChangeCharacter"
    )
    
end)


--------------------------------------------------
-- INVENTORY
--------------------------------------------------

inventoryButton.Activated:Connect(function()
    
    menuPanel.Visible =
    false
    
    CharacterRemote:FireServer(
    "OpenInventory"
    )
    
end)


--------------------------------------------------
-- TEMP TEST ITEM
--------------------------------------------------

testItemButton.Activated:Connect(function()
    
    CharacterRemote:FireServer(
    "AddTestItem"
    )
    
end)


--------------------------------------------------
-- EXIT
--------------------------------------------------

exitButton.Activated:Connect(function()
    
    menuPanel.Visible =
    false
    
    CharacterRemote:FireServer(
    "ExitGame"
    )
    
end)


--------------------------------------------------
-- SERVER EVENTS
--------------------------------------------------

CharacterRemote.OnClientEvent:Connect(
function(action, data)
    
    if action == "CharacterSelected" then
        
        screenGui.Enabled =
        true
        
        menuPanel.Visible =
        false
        
        
    elseif action == "EnterMainMenu" then
        
        -- Hide the in-game menu immediately.
        menuPanel.Visible =
        false
        
        screenGui.Enabled =
        false
        
        
        -- MainMenu owns the actual return-to-menu flow.
        local mainMenu =
        playerGui:FindFirstChild("MainMenu")
        
        if mainMenu then
            
            mainMenu.Enabled =
            true
            
            local mainFrame =
            mainMenu:FindFirstChild("MainFrame", true)
            
            if mainFrame then
                mainFrame.Visible =
                true
            end
            
        end
        
        
    elseif action == "InventoryOpened" then
        
        print(
        "Inventory opened"
        )
        
    end
    
end)


--------------------------------------------------
-- INITIAL STATE
--------------------------------------------------

screenGui.Enabled =
false

menuPanel.Visible =
false
