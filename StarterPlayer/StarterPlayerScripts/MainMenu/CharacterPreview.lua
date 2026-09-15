-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- CENTRAL CHARACTER PREVIEW
--
-- Shared renderer for:
--   CharacterUI
--   MainMenu / Character Creation
--   CharacterCard / Character Selection
--
-- Portrait framing:
--   - fixed front view
--   - close upper-body portrait
--   - focus on chest / upper torso
--   - head + chest remain visible
--------------------------------------------------
 
local CharacterPreview = {}
 
local DEFAULT_FOV = 30
local DEFAULT_DISTANCE = 4.2
local MIN_DISTANCE = 3.0
local MAX_DISTANCE = 7.5
 
local function configureObject(object)
    if object:IsA("BasePart") then
        object.Anchored = true
        object.CanCollide = false
        object.CanTouch = false
        object.CanQuery = false
        object.CastShadow = true
        object.Transparency = 0
    elseif object:IsA("Decal") or object:IsA("Texture") then
        object.Transparency = 0
    elseif object:IsA("Script")
        or object:IsA("LocalScript")
        or object:IsA("ModuleScript") then
        object:Destroy()
    end
end
 
local function getBodyParts(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    local head = model:FindFirstChild("Head")
    local torso = model:FindFirstChild("UpperTorso")
    or model:FindFirstChild("Torso")
    or model:FindFirstChild("LowerTorso")
    
    return root, head, torso
end
 
local function getBodyFrame(model)
    local root, head = getBodyParts(model)
    
    if root and head
        and root:IsA("BasePart")
        and head:IsA("BasePart") then
        
        local rootPos = root.Position
        local headPos = head.Position
        local bottomY = rootPos.Y - (root.Size.Y * 0.5)
        local topY = headPos.Y + (head.Size.Y * 0.5)
        local height = math.max(topY - bottomY, 2)
        local centerY = (topY + bottomY) * 0.5
        
        return Vector3.new(rootPos.X, centerY, rootPos.Z), height
    end
    
    local boxCFrame, boxSize = model:GetBoundingBox()
    return boxCFrame.Position, math.max(boxSize.Y, 2)
end
 
local function findChestTarget(model)
    local root, head, torso = getBodyParts(model)
    
    if torso and torso:IsA("BasePart") then
        -- Aim above the torso center so the portrait keeps the head
        -- comfortably inside the card instead of cutting it off.
        return torso.Position + Vector3.new(0, torso.Size.Y * 0.42, 0)
    end
    
    if root and root:IsA("BasePart") then
        return root.Position + Vector3.new(0, 1.05, 0)
    end
    
    if head and head:IsA("BasePart") then
        return head.Position - Vector3.new(0, head.Size.Y * 0.55, 0)
    end
    
    return Vector3.new(0, 0.35, 0)
end
 
local function getPortraitDistance(model, camera, viewport)
    local root, head, torso = getBodyParts(model)
    local target = findChestTarget(model)
    
    local topY
    if head and head:IsA("BasePart") then
        topY = head.Position.Y + head.Size.Y * 0.5 + 0.12
    else
        local boxCFrame, boxSize = model:GetBoundingBox()
        topY = boxCFrame.Position.Y + boxSize.Y * 0.5
    end
    
    local portraitHeight = math.max(topY - target.Y, 2.15)
    
    local verticalFov = math.rad(camera.FieldOfView)
    local viewportWidth = math.max(viewport.AbsoluteSize.X, 1)
    local viewportHeight = math.max(viewport.AbsoluteSize.Y, 1)
    
    local horizontalFov = 2 * math.atan(
    math.tan(verticalFov * 0.5)
    * viewportWidth / viewportHeight
    )
    
    -- Deliberately frames only the upper body instead of the full model.
    local distanceByHeight =
    (portraitHeight * 0.64)
    / math.tan(verticalFov * 0.5)
    
    local distance = distanceByHeight
    
    if torso and torso:IsA("BasePart") then
        local torsoWidth = math.max(torso.Size.X, 1)
        local distanceByWidth =
        (torsoWidth * 0.72)
        / math.tan(horizontalFov * 0.5)
        distance = math.max(distance, distanceByWidth)
    end
    
    return math.clamp(distance, MIN_DISTANCE, MAX_DISTANCE), target
end
 
function CharacterPreview.Create(parent, helpers)
    if not parent then
        return nil
    end
    
    local existing = parent:FindFirstChild("CharacterPreview")
    if existing and existing:IsA("ViewportFrame") then
        return existing
    end
    
    local viewport = Instance.new("ViewportFrame")
    viewport.Name = "CharacterPreview"
    viewport.Size = UDim2.fromScale(1, 1)
    viewport.BackgroundTransparency = 1
    viewport.BorderSizePixel = 0
    viewport.Ambient = Color3.fromRGB(180, 180, 180)
    viewport.LightColor = Color3.fromRGB(255, 255, 255)
    viewport.LightDirection = Vector3.new(-1, -1, -1)
    viewport.ZIndex = 11
    viewport.Parent = parent
    
    if helpers and helpers.AddCorner then
        helpers.AddCorner(viewport, 5)
    end
    
    local world = Instance.new("WorldModel")
    world.Name = "WorldModel"
    world.Parent = viewport
    
    local camera = Instance.new("Camera")
    camera.Name = "PreviewCamera"
    camera.FieldOfView = DEFAULT_FOV
    camera.Parent = viewport
    viewport.CurrentCamera = camera
    
    return viewport
end
 
function CharacterPreview.Clear(viewport)
    if not viewport or not viewport:IsA("ViewportFrame") then
        return false
    end
    
    local world = viewport:FindFirstChild("WorldModel")
    if world then
        world:ClearAllChildren()
    end
    
    return true
end
 
function CharacterPreview.GetModel(viewport)
    if not viewport or not viewport:IsA("ViewportFrame") then
        return nil
    end
    
    local world = viewport:FindFirstChild("WorldModel")
    if not world then
        return nil
    end
    
    return world:FindFirstChild("CharacterPreview")
end
 
 
 
local function repairPreviewHeadAssembly(model)
    if not model or model:GetAttribute("YAMA_Preview") ~= true then
        return
    end
    
    local head = model:FindFirstChild("Head")
    local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
    
    if not head or not torso or not head:IsA("BasePart") or not torso:IsA("BasePart") then
        return
    end
    
    local neck = torso:FindFirstChild("Neck")
    if not neck or not neck:IsA("Motor6D") then
        return
    end
    
    -- The Neck joint contains the authoritative rig relationship.
    -- If Roblox's preview model arrives with the head assembly displaced,
    -- use C0/C1 to recover the canonical head position without touching
    -- the working in-world character renderer.
    local expected = torso.CFrame * neck.C0 * neck.C1:Inverse()
    local delta = expected.Position - head.Position
    
    if delta.Magnitude <= 0.03 then
        return
    end
    
    head.CFrame = CFrame.new(expected.Position) * head.CFrame.Rotation
    
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("Accessory") then
            local handle = descendant:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.CFrame = handle.CFrame + delta
            end
        end
    end
end
 
function CharacterPreview.Render(viewport, previewModel)
    if not viewport or not viewport:IsA("ViewportFrame") then
        return false
    end
    
    if not previewModel or not previewModel:IsA("Model") then
        CharacterPreview.Clear(viewport)
        return false
    end
    
    local world = viewport:FindFirstChild("WorldModel")
    local camera = viewport:FindFirstChild("PreviewCamera")
    
    if not world or not camera then
        return false
    end
    
    world:ClearAllChildren()
    
    local oldArchivable = previewModel.Archivable
    previewModel.Archivable = true
    local model = previewModel:Clone()
    previewModel.Archivable = oldArchivable
    
    if not model then
        return false
    end
    
    model.Name = "CharacterPreview"
    
    for _, object in ipairs(model:GetDescendants()) do
        configureObject(object)
    end
    
    model.Parent = world
    
    repairPreviewHeadAssembly(model)
    
    -- Normalize the character to a FIXED portrait orientation first.
    --
    -- The previous version preserved the character's current pivot rotation.
    -- That made the camera appear dynamic: when the character turned in the
    -- world, the same turn was preserved inside the ViewportFrame.
    --
    -- YAMA portraits must always show the canonical front of the character.
    -- We therefore reset the cloned model's rotation before centering it.
    local pivot = model:GetPivot()
    model:PivotTo(CFrame.new(pivot.Position))
    
    -- Normalize around the real body rather than the full bounding box.
    -- Large hair/accessories therefore do not make the character tiny.
    local frameCenter = getBodyFrame(model)
    model:PivotTo(
    CFrame.new(-frameCenter.X, -frameCenter.Y, -frameCenter.Z)
    * model:GetPivot()
    )
    
    camera.FieldOfView = DEFAULT_FOV
    
    local distance, target = getPortraitDistance(model, camera, viewport)
    
    -- YAMA characters face -Z. The camera therefore stays on -Z.
    -- A tiny positive Y offset gives the portrait a natural eye-level angle
    -- while keeping the actual focus on the chest.
    local cameraPosition = target
    + Vector3.new(0, 0.06, -distance)
    
    camera.CFrame = CFrame.lookAt(cameraPosition, target)
    camera.Focus = CFrame.new(target)
    viewport.CurrentCamera = camera
    
    return true
end
 
-- Convenience alias for future real-time customization updates.
-- The caller can replace/update its model and call Update again.
function CharacterPreview.Update(viewport, previewModel)
    return CharacterPreview.Render(viewport, previewModel)
end
 
return CharacterPreview
