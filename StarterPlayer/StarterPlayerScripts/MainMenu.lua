print("MAIN MENU:", script:GetFullName())
print("MAIN MENU PARENT:", script.Parent:GetFullName())

for _, child in ipairs(script.Parent:GetChildren()) do
    print("CHILD:", child.Name, child.ClassName)
end

 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local CharacterRemote =
ReplicatedStorage:WaitForChild("CharacterRemote")

--------------------------------------------------
-- COLORS
--------------------------------------------------

local COLORS = {

-- PARCHMENT
ParchmentLight = Color3.fromRGB(252, 239, 207),
Parchment = Color3.fromRGB(231, 207, 159),
ParchmentMid = Color3.fromRGB(213, 181, 123),
ParchmentDark = Color3.fromRGB(184, 145, 82),

-- WOOD
WoodLight = Color3.fromRGB(137, 96, 51),
Wood = Color3.fromRGB(108, 71, 36),
WoodMid = Color3.fromRGB(88, 56, 28),
WoodDark = Color3.fromRGB(66, 41, 21),

-- LEATHER
Leather = Color3.fromRGB(101, 67, 34),
LeatherLight = Color3.fromRGB(125, 84, 43),
LeatherDark = Color3.fromRGB(64, 40, 21),

-- GOLD
GoldBright = Color3.fromRGB(255, 224, 132),
Gold = Color3.fromRGB(216, 170, 73),
GoldLight = Color3.fromRGB(240, 199, 105),
GoldDark = Color3.fromRGB(126, 87, 34),

-- TEXT
TextDark = Color3.fromRGB(59, 39, 22),
TextMid = Color3.fromRGB(103, 72, 38),
TextLight = Color3.fromRGB(255, 239, 190),

-- EMERALD
EmeraldBright = Color3.fromRGB(89, 201, 128),
Emerald = Color3.fromRGB(30, 126, 72),
EmeraldMid = Color3.fromRGB(22, 94, 55),
EmeraldDark = Color3.fromRGB(12, 54, 34),

-- RUBY
RubyBright = Color3.fromRGB(231, 81, 96),
Ruby = Color3.fromRGB(157, 36, 49),
RubyMid = Color3.fromRGB(116, 25, 36),
RubyDark = Color3.fromRGB(74, 17, 25),

-- NEUTRAL
Black = Color3.fromRGB(0, 0, 0),
White = Color3.fromRGB(255, 255, 255),
}


--------------------------------------------------
-- MAIN MENU AUDIO CONFIG
--------------------------------------------------
-- Replace only the numeric IDs when you choose the final sounds.
-- Leave a value empty ("") to disable that sound temporarily.

local SOUND_IDS = {
BackgroundMusic = "136945845024364",
HoverSound = "131677038997771",
ClickSound = "100809160609628",
DeleteSound = "131500586020769",
}


--------------------------------------------------
-- SCREEN GUI
--------------------------------------------------

local screenGui =
Instance.new("ScreenGui")

screenGui.Name =
"MainMenu"

screenGui.ResetOnSpawn =
false

screenGui.IgnoreGuiInset =
true

screenGui.DisplayOrder =
100

screenGui.Parent =
player:WaitForChild("PlayerGui")


--------------------------------------------------
-- UI LAYERS
--------------------------------------------------

-- Everything related to the normal menu
local menuLayer =
Instance.new("Frame")

menuLayer.Name =
"MenuLayer"

menuLayer.Size =
UDim2.fromScale(1, 1)

menuLayer.BackgroundTransparency =
1

menuLayer.BorderSizePixel =
0

menuLayer.ZIndex =
1

menuLayer.Parent =
screenGui


-- Dedicated layer for modal windows.
-- This is ALWAYS above the character cards.
local modalLayer =
Instance.new("Frame")

modalLayer.Name =
"ModalLayer"

modalLayer.Size =
UDim2.fromScale(1, 1)

modalLayer.BackgroundTransparency =
1

modalLayer.BorderSizePixel =
0

modalLayer.ZIndex =
1000

modalLayer.Visible =
true

modalLayer.Parent =
screenGui


-- Dedicated layer for system messages.
-- This stays above creation/delete modals and character cards.
local messageLayer =
Instance.new("Frame")

messageLayer.Name =
"MessageLayer"

messageLayer.Size =
UDim2.fromScale(1, 1)

messageLayer.BackgroundTransparency =
1

messageLayer.BorderSizePixel =
0

messageLayer.ZIndex =
2000

messageLayer.Parent =
screenGui


--------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------

local function addCorner(
    object,
    radius
    )
    
    local corner =
    Instance.new("UICorner")
    
    corner.CornerRadius =
    UDim.new(
    0,
    radius
    )
    
    corner.Parent =
    object
    
    return corner
    
end


local function addStroke(
    object,
    color,
    thickness
    )
    
    local stroke =
    Instance.new("UIStroke")
    
    stroke.Color =
    color
    
    stroke.Thickness =
    thickness
    
    stroke.Transparency =
    0
    
    stroke.Parent =
    object
    
    return stroke
    
end


local function addGradient(
    object,
    color1,
    color2,
    rotation
    )
    
    local gradient =
    Instance.new("UIGradient")
    
    gradient.Color =
    ColorSequence.new({
    
    ColorSequenceKeypoint.new(
    0,
    color1
    ),
    
    ColorSequenceKeypoint.new(
    1,
    color2
    )
    
    })
    
    gradient.Rotation =
    rotation or 90
    
    gradient.Parent =
    object
    
    return gradient
    
end


local function tween(
    object,
    duration,
    properties,
    style,
    direction
    )
    
    local info =
    TweenInfo.new(
    
    duration or 0.2,
    
    style or
    Enum.EasingStyle.Quad,
    
    direction or
    Enum.EasingDirection.Out
    
    )
    
    return TweenService:Create(
    object,
    info,
    properties
    )
    
end


--------------------------------------------------
-- SOUND OBJECTS
--------------------------------------------------
-- Roblox audio assets should be assigned as rbxassetid://<ID>.
-- The Sound objects live in SoundService so they are not tied to
-- the ScreenGui being enabled/disabled.
 
local function createSound(name, assetId, volume, looped)
    local sound = Instance.new("Sound")
    sound.Name = name
    sound.SoundId = assetId ~= "" and ("rbxassetid://" .. assetId) or ""
    sound.Volume = volume or 1
    sound.Looped = looped or false
    sound.Parent = SoundService
    return sound
end
 
local backgroundMusic =
createSound(
"YAMA_MainMenuMusic",
SOUND_IDS.BackgroundMusic,
0.32,
true
)
 
local hoverSound =
createSound(
"YAMA_MainMenuHover",
SOUND_IDS.HoverSound,
0.22,
false
)
 
local clickSound =
createSound(
"YAMA_MainMenuClick",
SOUND_IDS.ClickSound,
0.42,
false
)
 
local deleteSound =
createSound(
"YAMA_MainMenuDelete",
SOUND_IDS.DeleteSound,
0.5,
false
)
 
--------------------------------------------------
-- SOUND
--------------------------------------------------
 
local function playSound(sound)
    if not sound or sound.SoundId == "" then
        return
    end
    
    -- UI sounds are cloned so rapid clicks/hovers do not restart
    -- the original sound and cut each other off.
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

local function setupButtonEffects(
    button,
    stroke,
    baseScale,
    clickSoundOverride
    )
    
    local scale =
    Instance.new("UIScale")
    
    scale.Scale =
    baseScale or 1
    
    scale.Parent =
    button
    
    
    local hovering =
    false
    
    
    button.MouseEnter:Connect(function()
        
        hovering =
        true
        
        playSound(
        hoverSound
        )
        
        tween(
        scale,
        0.14,
        {
        Scale = 1.045
        },
        Enum.EasingStyle.Quad
        ):Play()
        
        
        if stroke then
            
            tween(
            stroke,
            0.14,
            {
            Thickness = 3,
            Color =
            COLORS.GoldBright
            }
            ):Play()
            
        end
        
    end)
    
    
    button.MouseLeave:Connect(function()
        
        hovering =
        false
        
        tween(
        scale,
        0.14,
        {
        Scale =
        baseScale or 1
        },
        Enum.EasingStyle.Quad
        ):Play()
        
        
        if stroke then
            
            tween(
            stroke,
            0.14,
            {
            Thickness = 2,
            Color =
            COLORS.Gold
            }
            ):Play()
            
        end
        
    end)
    
    
    button.Activated:Connect(function()
        
        playSound(
        clickSoundOverride or clickSound
        )
        
        tween(
        scale,
        0.06,
        {
        Scale = 0.94
        },
        Enum.EasingStyle.Quad
        ):Play()
        
        
        task.delay(
        0.07,
        function()
            
            if
                button
                and button.Parent
                then
                
                tween(
                scale,
                0.16,
                {
                Scale =
                hovering
                and 1.045
                or (
                baseScale
                or 1
                )
                },
                Enum.EasingStyle.Back
                ):Play()
                
            end
            
        end
        )
        
    end)
    
end


--------------------------------------------------
-- MAIN FRAME
--------------------------------------------------

local mainFrame =
Instance.new("Frame")

mainFrame.Name =
"MainFrame"

mainFrame.Size =
UDim2.fromScale(
1,
1
)

mainFrame.Position =
UDim2.fromScale(
0,
0
)

mainFrame.BackgroundColor3 =
COLORS.Parchment

mainFrame.BorderSizePixel =
0

mainFrame.ClipsDescendants =
true

mainFrame.ZIndex =
1

mainFrame.Parent =
menuLayer


--------------------------------------------------
-- PARCHMENT GRADIENT
--------------------------------------------------

addGradient(
mainFrame,
COLORS.ParchmentLight,
COLORS.ParchmentDark,
90
)


--------------------------------------------------
-- CENTER LIGHT
--------------------------------------------------

local centerLight =
Instance.new("Frame")

centerLight.Name =
"CenterLight"

centerLight.Size =
UDim2.fromScale(
0.65,
0.75
)

centerLight.Position =
UDim2.fromScale(
0.175,
0.13
)

centerLight.BackgroundColor3 =
COLORS.ParchmentLight

centerLight.BackgroundTransparency =
0.72

centerLight.BorderSizePixel =
0

centerLight.ZIndex =
2

centerLight.Parent =
mainFrame

addCorner(
centerLight,
30
)


--------------------------------------------------
-- OUTER BORDER
--------------------------------------------------

local outerBorder =
Instance.new("Frame")

outerBorder.Size =
UDim2.new(
1,
-16,
1,
-16
)

outerBorder.Position =
UDim2.fromScale(
0.5,
0.5
)

outerBorder.AnchorPoint =
Vector2.new(
0.5,
0.5
)

outerBorder.BackgroundTransparency =
1

outerBorder.BorderSizePixel =
0

outerBorder.ZIndex =
3

outerBorder.Parent =
mainFrame

local outerStroke =
addStroke(
outerBorder,
COLORS.GoldDark,
3
)


--------------------------------------------------
-- INNER BORDER
--------------------------------------------------

local innerBorder =
Instance.new("Frame")

innerBorder.Size =
UDim2.new(
1,
-30,
1,
-30
)

innerBorder.Position =
UDim2.fromScale(
0.5,
0.5
)

innerBorder.AnchorPoint =
Vector2.new(
0.5,
0.5
)

innerBorder.BackgroundTransparency =
1

innerBorder.BorderSizePixel =
0

innerBorder.ZIndex =
3

innerBorder.Parent =
mainFrame

local innerStroke =
addStroke(
innerBorder,
COLORS.Gold,
1
)


--------------------------------------------------
-- BORDER PULSE
--------------------------------------------------

task.spawn(function()
    
    while screenGui.Parent do
        
        tween(
        outerStroke,
        1.8,
        {
        Transparency = 0.25
        },
        Enum.EasingStyle.Sine
        ):Play()
        
        
        tween(
        innerStroke,
        1.8,
        {
        Transparency = 0.45
        },
        Enum.EasingStyle.Sine
        ):Play()
        
        
        task.wait(1.8)
        
        
        tween(
        outerStroke,
        1.8,
        {
        Transparency = 0
        },
        Enum.EasingStyle.Sine
        ):Play()
        
        
        tween(
        innerStroke,
        1.8,
        {
        Transparency = 0
        },
        Enum.EasingStyle.Sine
        ):Play()
        
        
        task.wait(1.8)
        
    end
    
end)


--------------------------------------------------
-- DECORATIVE CORNERS
--------------------------------------------------

local function createCorner(
    position,
    rotation
    )
    
    local corner =
    Instance.new("TextLabel")
    
    corner.Size =
    UDim2.fromScale(
    0.12,
    0.07
    )
    
    corner.Position =
    position
    
    corner.BackgroundTransparency =
    1
    
    corner.Text =
    "❖"
    
    corner.TextScaled =
    true
    
    corner.TextColor3 =
    COLORS.Gold
    
    corner.Font =
    Enum.Font.Fantasy
    
    corner.Rotation =
    rotation
    
    corner.ZIndex =
    5
    
    corner.Parent =
    mainFrame
    
    return corner
    
end


createCorner(
UDim2.fromScale(
0.01,
0.01
),
0
)

createCorner(
UDim2.fromScale(
0.89,
0.01
),
90
)

createCorner(
UDim2.fromScale(
0.01,
0.92
),
-90
)

createCorner(
UDim2.fromScale(
0.89,
0.92
),
180
)


--------------------------------------------------
-- TOP DECORATION
--------------------------------------------------

local topDecoration =
Instance.new("TextLabel")

topDecoration.Size =
UDim2.fromScale(
0.78,
0.045
)

topDecoration.Position =
UDim2.fromScale(
0.11,
0.015
)

topDecoration.BackgroundTransparency =
1

topDecoration.Text =
"✦ ─────────────── ◆ ─────────────── ✦"

topDecoration.TextScaled =
true

topDecoration.TextColor3 =
COLORS.GoldDark

topDecoration.Font =
Enum.Font.Fantasy

topDecoration.ZIndex =
5

topDecoration.Parent =
mainFrame


--------------------------------------------------
-- TITLE SHADOW
--------------------------------------------------

local titleShadow =
Instance.new("TextLabel")

titleShadow.Size =
UDim2.fromScale(
0.9,
0.13
)

titleShadow.Position =
UDim2.fromScale(
0.05,
0.055
)

titleShadow.BackgroundTransparency =
1

titleShadow.Text =
"YAMA: LEGENDS"

titleShadow.TextScaled =
true

titleShadow.TextColor3 =
COLORS.GoldDark

titleShadow.Font =
Enum.Font.Fantasy

titleShadow.TextTransparency =
1

titleShadow.ZIndex =
6

titleShadow.Parent =
mainFrame


--------------------------------------------------
-- TITLE
--------------------------------------------------

local title =
Instance.new("TextLabel")

title.Name =
"Title"

title.Size =
UDim2.fromScale(
0.9,
0.13
)

title.Position =
UDim2.fromScale(
0.05,
0.05
)

title.BackgroundTransparency =
1

title.Text =
"YAMA: LEGENDS"

title.TextScaled =
true

title.TextColor3 =
COLORS.GoldBright

title.Font =
Enum.Font.Fantasy

title.TextTransparency =
1

title.ZIndex =
7

title.Parent =
mainFrame


--------------------------------------------------
-- TITLE ANIMATION
--------------------------------------------------

tween(
titleShadow,
0.7,
{
TextTransparency = 0
}
):Play()


task.delay(
0.12,
function()
    
    tween(
    title,
    0.75,
    {
    TextTransparency = 0
    }
    ):Play()
    
end
)


--------------------------------------------------
-- SUBTITLE
--------------------------------------------------

local subtitle =
Instance.new("TextLabel")

subtitle.Name =
"Subtitle"

subtitle.Size =
UDim2.fromScale(
0.8,
0.055
)

subtitle.Position =
UDim2.fromScale(
0.1,
0.185
)

subtitle.BackgroundTransparency =
1

subtitle.Text =
"YOUR CHARACTERS"

subtitle.TextScaled =
true

subtitle.TextColor3 =
COLORS.TextDark

subtitle.Font =
Enum.Font.Garamond

subtitle.TextTransparency =
1

subtitle.ZIndex =
7

subtitle.Parent =
mainFrame


task.delay(
0.35,
function()
    
    tween(
    subtitle,
    0.6,
    {
    TextTransparency = 0
    }
    ):Play()
    
end
)


--------------------------------------------------
-- DIVIDER
--------------------------------------------------

local divider =
Instance.new("TextLabel")

divider.Size =
UDim2.fromScale(
0.7,
0.035
)

divider.Position =
UDim2.fromScale(
0.15,
0.245
)

divider.BackgroundTransparency =
1

divider.Text =
"─────── ◆ ───────"

divider.TextScaled =
true

divider.TextColor3 =
COLORS.GoldDark

divider.Font =
Enum.Font.Fantasy

divider.ZIndex =
7

divider.Parent =
mainFrame


--------------------------------------------------
-- CHARACTER LIST BACKGROUND
--------------------------------------------------

local listBackground = Instance.new("Frame")
listBackground.Name = "CharacterListBackground"
listBackground.Size = UDim2.fromScale(0.86, 0.47)
listBackground.Position = UDim2.fromScale(0.07, 0.285)
listBackground.BackgroundColor3 = COLORS.WoodDark
listBackground.BackgroundTransparency = 0.04
listBackground.BorderSizePixel = 0
listBackground.ZIndex = 4
listBackground.Parent = mainFrame
addCorner(listBackground, 13)
addStroke(listBackground, COLORS.GoldDark, 2)

local listHighlight = Instance.new("Frame")
listHighlight.Size = UDim2.new(1, -8, 0, 3)
listHighlight.Position = UDim2.new(0, 4, 0, 4)
listHighlight.BackgroundColor3 = COLORS.Gold
listHighlight.BackgroundTransparency = 0.45
listHighlight.BorderSizePixel = 0
listHighlight.ZIndex = 5
listHighlight.Parent = listBackground
addCorner(listHighlight, 2)

local characterList = Instance.new("ScrollingFrame")
characterList.Name = "CharacterList"
characterList.Size = UDim2.new(1, -18, 0.78, -6)
characterList.Position = UDim2.new(0.5, 0, 0, 12)
characterList.AnchorPoint = Vector2.new(0.5, 0)
characterList.BackgroundTransparency = 1
characterList.BorderSizePixel = 0
characterList.CanvasSize = UDim2.fromScale(0, 0)
characterList.ScrollBarThickness = 6
characterList.ScrollBarImageColor3 = COLORS.Gold
characterList.ScrollingDirection = Enum.ScrollingDirection.X
characterList.ZIndex = 5
characterList.Parent = listBackground

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 12)
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Parent = characterList

local actionBar = Instance.new("Frame")
actionBar.Name = "CharacterActions"
actionBar.Size = UDim2.new(1, -18, 0.18, 0)
actionBar.Position = UDim2.new(0.5, 0, 0.80, 0)
actionBar.AnchorPoint = Vector2.new(0.5, 0)
actionBar.BackgroundTransparency = 1
actionBar.BorderSizePixel = 0
actionBar.ZIndex = 18
actionBar.Parent = listBackground

--------------------------------------------------
-- MESSAGE
--------------------------------------------------

local messageLabel =
Instance.new("TextLabel")

messageLabel.Name =
"Message"

messageLabel.Size =
UDim2.fromScale(
0.72,
0.065
)

messageLabel.Position =
UDim2.fromScale(
0.14,
0.765
)

messageLabel.BackgroundColor3 =
COLORS.LeatherDark

messageLabel.BackgroundTransparency =
0.03

messageLabel.Text =
""

messageLabel.TextScaled =
true

messageLabel.TextWrapped =
true

messageLabel.TextColor3 =
COLORS.GoldBright

messageLabel.Font =
Enum.Font.Garamond

messageLabel.Visible =
false

messageLabel.ZIndex =
2001

messageLabel.Parent =
messageLayer

addCorner(
messageLabel,
8
)

addStroke(
messageLabel,
COLORS.Gold,
2
)


--------------------------------------------------
-- MESSAGE
--------------------------------------------------

local messageToken =
0

local function showMessage(text)
    
    messageToken += 1
    
    local token =
    messageToken
    
    messageLabel.Text =
    text
    
    messageLabel.Visible =
    true
    
    messageLabel.TextTransparency =
    1
    
    messageLabel.BackgroundTransparency =
    1
    
    
    tween(
    messageLabel,
    0.2,
    {
    TextTransparency = 0,
    BackgroundTransparency = 0.03
    }
    ):Play()
    
    
    task.delay(
    3,
    function()
        
        if token ~=
            messageToken then
            return
        end
        
        
        tween(
        messageLabel,
        0.25,
        {
        TextTransparency = 1,
        BackgroundTransparency = 1
        }
        ):Play()
        
        
        task.delay(
        0.25,
        function()
            
            if token ==
                messageToken then
                
                messageLabel.Visible =
                false
                
            end
            
        end
        )
        
    end
    )
    
end


--------------------------------------------------
-- CHARACTER CREATION MODULE
--------------------------------------------------

local CharacterCreationUI =
require(script:WaitForChild("CharacterCreationUI"))

CharacterCreationUI.Initialize({
MainFrame = mainFrame,
CharacterRemote = CharacterRemote,
Colors = COLORS,
ShowMessage = showMessage,
Tween = tween,
AddCorner = addCorner,
AddStroke = addStroke,
AddGradient = addGradient,
SetupButtonEffects = setupButtonEffects,
})


-- CHARACTER SELECTION MODULE
--------------------------------------------------

-- Forward declaration: the delete modal is defined below.
local showDeleteConfirmation

local CharacterSelectionUI = require(script:WaitForChild("CharacterSelectionUI"))

CharacterSelectionUI.Initialize({
CharacterList = characterList,
ListLayout = listLayout,
ActionBar = actionBar,
CharacterRemote = CharacterRemote,
Colors = COLORS,
Tween = tween,
AddCorner = addCorner,
AddStroke = addStroke,
AddGradient = addGradient,
SetupButtonEffects = setupButtonEffects,
OnDelete = function(character)
    showDeleteConfirmation(character)
end,
})

--------------------------------------------------
-- DELETE CONFIRMATION
--
-- IMPORTANT:
-- This entire modal is created inside modalLayer.
-- It is therefore above CharacterList and all cards.
--------------------------------------------------

showDeleteConfirmation = function(
    character
    )
    
    --------------------------------------------------
    -- MODAL ROOT
    --------------------------------------------------
    
    local modal =
    Instance.new("Frame")
    
    modal.Name =
    "DeleteModal"
    
    modal.Size =
    UDim2.fromScale(
    1,
    1
    )
    
    modal.Position =
    UDim2.fromScale(
    0,
    0
    )
    
    modal.BackgroundTransparency =
    1
    
    modal.BorderSizePixel =
    0
    
    modal.ZIndex =
    1000
    
    modal.Parent =
    modalLayer
    
    
    --------------------------------------------------
    -- DARK OVERLAY
    --------------------------------------------------
    
    local overlay =
    Instance.new("Frame")
    
    overlay.Name =
    "Overlay"
    
    overlay.Size =
    UDim2.fromScale(
    1,
    1
    )
    
    overlay.Position =
    UDim2.fromScale(
    0,
    0
    )
    
    overlay.BackgroundColor3 =
    COLORS.Black
    
    overlay.BackgroundTransparency =
    1
    
    overlay.BorderSizePixel =
    0
    
    overlay.ZIndex =
    1000
    
    overlay.Parent =
    modal
    
    
    --------------------------------------------------
    -- PANEL SHADOW
    --------------------------------------------------
    
    local shadow =
    Instance.new("Frame")
    
    shadow.Size =
    UDim2.new(
    0.76,
    10,
    0.55,
    10
    )
    
    shadow.Position =
    UDim2.fromScale(
    0.12,
    0.225
    )
    
    shadow.BackgroundColor3 =
    COLORS.Black
    
    shadow.BackgroundTransparency =
    0.55
    
    shadow.BorderSizePixel =
    0
    
    shadow.ZIndex =
    1001
    
    shadow.Parent =
    modal
    
    addCorner(
    shadow,
    16
    )
    
    
    --------------------------------------------------
    -- CONFIRMATION PANEL
    --------------------------------------------------
    
    local confirmation =
    Instance.new("Frame")
    
    confirmation.Name =
    "DeleteConfirmation"
    
    confirmation.Size =
    UDim2.fromScale(
    0.76,
    0.55
    )
    
    confirmation.Position =
    UDim2.fromScale(
    0.12,
    0.26
    )
    
    confirmation.BackgroundColor3 =
    COLORS.Parchment
    
    confirmation.BackgroundTransparency =
    1
    
    confirmation.BorderSizePixel =
    0
    
    confirmation.ZIndex =
    1002
    
    confirmation.Parent =
    modal
    
    addCorner(
    confirmation,
    13
    )
    
    local confirmationStroke =
    addStroke(
    confirmation,
    COLORS.Ruby,
    3
    )
    
    addGradient(
    confirmation,
    COLORS.ParchmentLight,
    COLORS.Parchment,
    90
    )
    
    
    --------------------------------------------------
    -- CONFIRMATION SCALE
    --------------------------------------------------
    
    local confirmationScale =
    Instance.new("UIScale")
    
    confirmationScale.Scale =
    0.82
    
    confirmationScale.Parent =
    confirmation
    
    
    --------------------------------------------------
    -- TOP DECORATION
    --------------------------------------------------
    
    local confirmationDecoration =
    Instance.new("TextLabel")
    
    confirmationDecoration.Size =
    UDim2.fromScale(
    0.75,
    0.08
    )
    
    confirmationDecoration.Position =
    UDim2.fromScale(
    0.125,
    0.015
    )
    
    confirmationDecoration.BackgroundTransparency =
    1
    
    confirmationDecoration.Text =
    "◆ ───────── ◆"
    
    confirmationDecoration.TextScaled =
    true
    
    confirmationDecoration.TextColor3 =
    COLORS.Ruby
    
    confirmationDecoration.Font =
    Enum.Font.Fantasy
    
    confirmationDecoration.ZIndex =
    1003
    
    confirmationDecoration.Parent =
    confirmation
    
    
    --------------------------------------------------
    -- TITLE
    --------------------------------------------------
    
    local confirmationTitle =
    Instance.new("TextLabel")
    
    confirmationTitle.Size =
    UDim2.fromScale(
    0.9,
    0.15
    )
    
    confirmationTitle.Position =
    UDim2.fromScale(
    0.05,
    0.10
    )
    
    confirmationTitle.BackgroundTransparency =
    1
    
    confirmationTitle.Text =
    "DELETE CHARACTER?"
    
    confirmationTitle.TextScaled =
    true
    
    confirmationTitle.TextColor3 =
    COLORS.RubyDark
    
    confirmationTitle.Font =
    Enum.Font.Fantasy
    
    confirmationTitle.ZIndex =
    1003
    
    confirmationTitle.Parent =
    confirmation
    
    
    --------------------------------------------------
    -- WARNING
    --------------------------------------------------
    
    local warning =
    Instance.new("TextLabel")
    
    warning.Size =
    UDim2.fromScale(
    0.84,
    0.32
    )
    
    warning.Position =
    UDim2.fromScale(
    0.08,
    0.29
    )
    
    warning.BackgroundTransparency =
    1
    
    warning.Text =
    "Are you sure you want to delete "
    .. tostring(
    character.Name
    )
    .. "?\n\n"
    .. "This character cannot be recovered.\n"
    .. "All items will be permanently lost."
    
    warning.TextWrapped =
    true
    
    warning.TextScaled =
    true
    
    warning.TextColor3 =
    COLORS.TextDark
    
    warning.Font =
    Enum.Font.Garamond
    
    warning.ZIndex =
    1003
    
    warning.Parent =
    confirmation
    
    
    --------------------------------------------------
    -- DELETE BUTTON
    --------------------------------------------------
    
    local deleteConfirm =
    Instance.new("TextButton")
    
    deleteConfirm.Name =
    "ConfirmDelete"
    
    deleteConfirm.Size =
    UDim2.fromScale(
    0.35,
    0.16
    )
    
    deleteConfirm.Position =
    UDim2.fromScale(
    0.08,
    0.75
    )
    
    deleteConfirm.BackgroundColor3 =
    COLORS.Ruby
    
    deleteConfirm.BorderSizePixel =
    0
    
    deleteConfirm.Text =
    "DELETE"
    
    deleteConfirm.TextScaled =
    true
    
    deleteConfirm.TextColor3 =
    COLORS.GoldBright
    
    deleteConfirm.Font =
    Enum.Font.Fantasy
    
    deleteConfirm.AutoButtonColor =
    false
    
    deleteConfirm.ClipsDescendants =
    true
    
    deleteConfirm.ZIndex =
    1004
    
    deleteConfirm.Parent =
    confirmation
    
    addCorner(
    deleteConfirm,
    8
    )
    
    local deleteConfirmStroke =
    addStroke(
    deleteConfirm,
    COLORS.Gold,
    2
    )
    
    addGradient(
    deleteConfirm,
    COLORS.RubyBright,
    COLORS.RubyDark,
    90
    )
    
    setupButtonEffects(
    deleteConfirm,
    deleteConfirmStroke,
    1,
    deleteSound
    )
    
    --------------------------------------------------
    -- CANCEL BUTTON
    --------------------------------------------------
    
    local cancelDelete =
    Instance.new("TextButton")
    
    cancelDelete.Name =
    "CancelDelete"
    
    cancelDelete.Size =
    UDim2.fromScale(
    0.35,
    0.16
    )
    
    cancelDelete.Position =
    UDim2.fromScale(
    0.57,
    0.75
    )
    
    cancelDelete.BackgroundColor3 =
    COLORS.Wood
    
    cancelDelete.BorderSizePixel =
    0
    
    cancelDelete.Text =
    "CANCEL"
    
    cancelDelete.TextScaled =
    true
    
    cancelDelete.TextColor3 =
    COLORS.TextLight
    
    cancelDelete.Font =
    Enum.Font.Garamond
    
    cancelDelete.AutoButtonColor =
    false
    
    cancelDelete.ZIndex =
    1004
    
    cancelDelete.Parent =
    confirmation
    
    addCorner(
    cancelDelete,
    8
    )
    
    local cancelDeleteStroke =
    addStroke(
    cancelDelete,
    COLORS.GoldDark,
    2
    )
    
    addGradient(
    cancelDelete,
    COLORS.WoodLight,
    COLORS.WoodDark,
    90
    )
    
    setupButtonEffects(
    cancelDelete,
    cancelDeleteStroke,
    1
    )
    
    
    --------------------------------------------------
    -- OPEN ANIMATION
    --------------------------------------------------
    
    tween(
    overlay,
    0.22,
    {
    BackgroundTransparency =
    0.48
    },
    Enum.EasingStyle.Quad
    ):Play()
    
    
    tween(
    shadow,
    0.22,
    {
    BackgroundTransparency =
    0.55
    },
    Enum.EasingStyle.Quad
    ):Play()
    
    
    tween(
    confirmation,
    0.22,
    {
    BackgroundTransparency =
    0
    },
    Enum.EasingStyle.Quad
    ):Play()
    
    
    tween(
    confirmationScale,
    0.32,
    {
    Scale = 1
    },
    Enum.EasingStyle.Back
    ):Play()
    
    
    tween(
    confirmation,
    0.28,
    {
    Position =
    UDim2.fromScale(
    0.12,
    0.225
    )
    },
    Enum.EasingStyle.Back
    ):Play()
    
    
    --------------------------------------------------
    -- CLOSE FUNCTION
    --------------------------------------------------
    
    local closing =
    false
    
    
    local function closeModal()
        
        if closing then
            return
        end
        
        closing =
        true
        
        
        tween(
        overlay,
        0.15,
        {
        BackgroundTransparency =
        1
        }
        ):Play()
        
        
        tween(
        shadow,
        0.15,
        {
        BackgroundTransparency =
        1
        }
        ):Play()
        
        
        tween(
        confirmationScale,
        0.16,
        {
        Scale =
        0.9
        },
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
        ):Play()
        
        
        tween(
        confirmation,
        0.16,
        {
        BackgroundTransparency =
        1
        },
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
        ):Play()
        
        
        task.delay(
        0.18,
        function()
            
            if modal then
                modal:Destroy()
            end
            
        end
        )
        
    end
    
    
    --------------------------------------------------
    -- DELETE ACTION
    --------------------------------------------------
    
    deleteConfirm.Activated:Connect(function()
        
        playSound(
        deleteSound
        )
        
        
        CharacterRemote:FireServer(
        "DeleteCharacter",
        character.Id
        )
        
        
        closeModal()
        
    end)
    
    
    --------------------------------------------------
    -- CANCEL ACTION
    --------------------------------------------------
    
    cancelDelete.Activated:Connect(function()
        
        closeModal()
        
    end)
    
end


--------------------------------------------------
-- DISPLAY CHARACTERS
--------------------------------------------------

local function displayCharacters(characters)
    CharacterSelectionUI.Display(characters)
end

--------------------------------------------------
-- SERVER RESPONSES
--------------------------------------------------

CharacterRemote.OnClientEvent:Connect(function(action, data)
    if action == "CharacterList" then
        if type(data) == "table" then
            displayCharacters(data)
        else
            displayCharacters({})
        end
        
    elseif action == "CharacterCreated"
        or action == "CharacterCreationFailed"
        or action == "CreationAppearanceOptions"
        or action == "CreationAppearancePreview"
        or action == "CreationAppearancePreviewFailed" then
        
        CharacterCreationUI.HandleServerResponse(action, data)
        
    elseif action == "CharacterPreview" then
        local previewFolder = ReplicatedStorage:FindFirstChild("YAMA_CharacterPreviews")
        if previewFolder then
            CharacterSelectionUI.HandlePreview(data, previewFolder)
        end
        
    elseif action == "CharacterSelected" then
        showMessage("Entering world...")
        mainFrame.Visible = false
        
        if backgroundMusic.IsPlaying then
            backgroundMusic:Stop()
        end
        
    elseif action == "EnterMainMenu" then
        CharacterCreationUI.Close()
        
        for _, child in ipairs(modalLayer:GetChildren()) do
            child:Destroy()
        end
        
        screenGui.Enabled = true
        mainFrame.Visible = true
        
        if backgroundMusic.SoundId ~= "" and not backgroundMusic.IsPlaying then
            backgroundMusic:Play()
        end
        
        showMessage("Choose your character.")
        CharacterRemote:FireServer("GetCharacters")
        
    elseif action == "CharacterDeleted" then
        print("Character deleted successfully")
        showMessage("Character deleted.")
        CharacterRemote:FireServer("GetCharacters")
        
    elseif action == "CharacterSelectionFailed" then
        showMessage("Character selection failed.")
        
    elseif action == "CharacterSpawnFailed" then
        showMessage("Character spawn failed.")
    end
end)

--------------------------------------------------
-- START MUSIC
--------------------------------------------------

if backgroundMusic.SoundId ~= "" then
    backgroundMusic:Play()
end

--------------------------------------------------
-- CLEANUP
--------------------------------------------------
-- MainMenu may be recreated. Remove its SoundService objects
-- when this script/GUI is destroyed to avoid duplicate music.
 
script.Destroying:Connect(function()
    if backgroundMusic then
        backgroundMusic:Stop()
    end
    
    for _, sound in ipairs(SoundService:GetChildren()) do
        if sound.Name == "YAMA_MainMenuMusic"
            or sound.Name == "YAMA_MainMenuHover"
            or sound.Name == "YAMA_MainMenuClick"
            or sound.Name == "YAMA_MainMenuDelete" then
            sound:Destroy()
        end
    end
end)
 
--------------------------------------------------
-- REQUEST CHARACTERS
--------------------------------------------------

task.wait(1)
CharacterRemote:FireServer("GetCharacters")
