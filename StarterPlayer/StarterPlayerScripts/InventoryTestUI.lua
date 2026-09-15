-- LOCAL SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- INVENTORY / STORAGE TEST UI
-- TEMPORARY QA TOOL
--------------------------------------------------
 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
 
local remote = ReplicatedStorage:WaitForChild("InventoryTestRemote")
 
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryTestUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 1000
screenGui.Parent = playerGui
 
local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.Size = UDim2.fromScale(0.16, 0.055)
toggle.Position = UDim2.fromScale(0.82, 0.04)
toggle.BackgroundColor3 = Color3.fromRGB(55, 40, 24)
toggle.BorderSizePixel = 0
toggle.Text = "TEST LAB"
toggle.TextColor3 = Color3.fromRGB(255, 224, 132)
toggle.TextScaled = true
toggle.Font = Enum.Font.Fantasy
toggle.Parent = screenGui
 
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggle
 
local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(216, 170, 73)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggle
 
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromScale(0.34, 0.66)
panel.Position = UDim2.fromScale(0.63, 0.12)
panel.BackgroundColor3 = Color3.fromRGB(231, 207, 159)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screenGui
 
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel
 
local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(126, 87, 34)
panelStroke.Thickness = 3
panelStroke.Parent = panel
 
local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(0.9, 0.09)
title.Position = UDim2.fromScale(0.05, 0.025)
title.BackgroundTransparency = 1
title.Text = "INVENTORY TEST LAB"
title.TextColor3 = Color3.fromRGB(59, 39, 22)
title.TextScaled = true
title.Font = Enum.Font.Fantasy
title.Parent = panel
 
local status = Instance.new("TextLabel")
status.Size = UDim2.fromScale(0.9, 0.11)
status.Position = UDim2.fromScale(0.05, 0.12)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(103, 72, 38)
status.TextScaled = true
status.Font = Enum.Font.Garamond
status.Parent = panel
 
local function makeButton(text, position, size)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.fromScale(0.42, 0.075)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(88, 56, 28)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 224, 132)
    button.TextScaled = true
    button.Font = Enum.Font.Fantasy
    button.Parent = panel
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(216, 170, 73)
    stroke.Thickness = 1.5
    stroke.Parent = button
    
    return button
end
 
local buttons = {
{"Inventory 59", "Inventory59", 0.05, 0.25},
{"Inventory 60", "Inventory60", 0.53, 0.25},
{"Storage 599", "Storage599", 0.05, 0.34},
{"Storage 600", "Storage600", 0.53, 0.34},
{"Clear Inventory", "ClearInventory", 0.05, 0.45},
{"Clear Storage", "ClearStorage", 0.53, 0.45},
{"+ Health Potion", "AddHealthPotion", 0.05, 0.54},
{"+ Iron Ore", "AddIronOre", 0.53, 0.54},
{"+ Gold Coin", "AddGoldCoin", 0.05, 0.63},
}
 
for _, info in ipairs(buttons) do
    local button = makeButton(
    info[1],
    UDim2.fromScale(info[3], info[4])
    )
    
    button.Activated:Connect(function()
        status.Text = "Running: " .. info[1]
        remote:FireServer(info[2])
    end)
end
 
local help = Instance.new("TextLabel")
help.Size = UDim2.fromScale(0.9, 0.22)
help.Position = UDim2.fromScale(0.05, 0.72)
help.BackgroundTransparency = 1
help.Text =
"59/60 = one free slot\n"
.. "60/60 = full\n"
.. "599/600 = one free slot\n"
.. "600/600 = full\n\n"
.. "Clear test slots before finishing the test."
help.TextWrapped = true
help.TextColor3 = Color3.fromRGB(59, 39, 22)
help.TextScaled = true
help.Font = Enum.Font.Garamond
help.Parent = panel
 
toggle.Activated:Connect(function()
    panel.Visible = not panel.Visible
end)
 
remote.OnClientEvent:Connect(function(action, state, message, success)
    if action ~= "State" then
        return
    end
    
    status.Text = tostring(message or "Done")
    .. "\n\n"
    .. "Inventory: "
    .. tostring(state and state.InventorySlots or "?")
    .. "/"
    .. tostring(state and state.InventoryMaxSlots or "?")
    .. "\nStorage: "
    .. tostring(state and state.StorageSlots or "?")
    .. "/"
    .. tostring(state and state.StorageMaxSlots or "?")
    
    if success == false then
        status.Text = "FAILED\n\n" .. status.Text
    end
end)
