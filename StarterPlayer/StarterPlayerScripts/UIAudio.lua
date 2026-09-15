-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- SHARED UI AUDIO
--
-- One reusable audio module for all menus.
-- Future UIs should require this module instead
-- of creating their own click/hover sounds.
--------------------------------------------------
 
local SoundService = game:GetService("SoundService")
 
local UIAudio = {}
 
--------------------------------------------------
-- CONFIG
--
-- Assign Roblox audio asset IDs here.
-- Example:
-- Click = "123456789"
--------------------------------------------------
 
UIAudio.SoundIds = {
Click = "138567614125924",
Hover = "119354387183704",
Select = "111174530730534",
Confirm = "96219687807442",
Cancel = "121577114498111",
Error = "550209561",
Open = "127877437691780",
Close = "8968249849",
Pickup = "2575934454",
Drop = "115624513042963",
}
 
UIAudio.Volumes = {
Click = 0.42,
Hover = 0.22,
Select = 0.38,
Confirm = 0.48,
Cancel = 0.35,
Error = 0.42,
Open = 0.38,
Close = 0.35,
Pickup = 0.42,
Drop = 0.45,
}
 
--------------------------------------------------
-- INTERNAL SOUND CACHE
--------------------------------------------------
 
local sounds = {}
 
local function getSound(soundType)
    local assetId = UIAudio.SoundIds[soundType]
    
    if not assetId or assetId == "" then
        return nil
    end
    
    if sounds[soundType] and sounds[soundType].Parent then
        return sounds[soundType]
    end
    
    local sound = Instance.new("Sound")
    sound.Name = "YAMA_UI_" .. tostring(soundType)
    sound.SoundId = "rbxassetid://" .. tostring(assetId)
    sound.Volume = UIAudio.Volumes[soundType] or 0.4
    sound.Looped = false
    sound.Parent = SoundService
    
    sounds[soundType] = sound
    
    return sound
end
 
--------------------------------------------------
-- PLAY
--------------------------------------------------
-- Sounds are cloned so rapid interactions do not
-- cut each other off.
 
function UIAudio.Play(soundType)
    local sound = getSound(soundType)
    
    if not sound then
        return
    end
    
    local oneShot = sound:Clone()
    oneShot.Looped = false
    oneShot.Parent = SoundService
    
    SoundService:PlayLocalSound(oneShot)
    
    task.delay(5, function()
        if oneShot and oneShot.Parent then
            oneShot:Destroy()
        end
    end)
end
 
--------------------------------------------------
-- BUTTON EFFECTS
--------------------------------------------------
 
function UIAudio.BindButton(button, options)
    if not button then
        return
    end
    
    options = options or {}
    
    local clickType = options.Click or "Click"
    local hoverType = options.Hover or "Hover"
    local pressScale = options.PressScale or 0.96
    local hoverScale = options.HoverScale or 1.035
    
    local scale = button:FindFirstChild("YAMA_UI_Scale")
    
    if not scale then
        scale = Instance.new("UIScale")
        scale.Name = "YAMA_UI_Scale"
        scale.Scale = 1
        scale.Parent = button
    end
    
    local TweenService = game:GetService("TweenService")
    
    button.MouseEnter:Connect(function()
        UIAudio.Play(hoverType)
        
        TweenService:Create(
        scale,
        TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Scale = hoverScale}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(
        scale,
        TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Scale = 1}
        ):Play()
    end)
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            
            TweenService:Create(
            scale,
            TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Scale = pressScale}
            ):Play()
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            
            TweenService:Create(
            scale,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Scale = 1}
            ):Play()
        end
    end)
    
    button.Activated:Connect(function()
        UIAudio.Play(clickType)
    end)
end
 
--------------------------------------------------
-- CLEANUP
--------------------------------------------------
 
function UIAudio.Cleanup()
    for soundType, sound in pairs(sounds) do
        if sound and sound.Parent then
            sound:Destroy()
        end
        sounds[soundType] = nil
    end
end
 
return UIAudio
