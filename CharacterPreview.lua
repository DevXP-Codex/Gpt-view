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
        -- Aim slightly above the torso center so the portrait reads
        -- naturally as chest/upper-body instead of stomach/waist.
        return torso.Position + Vector3.new(0, torso.Size.Y * 0.10, 0)
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
    
    local portraitHeight = math.max(topY - target.Y, 1.8)
    
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
    + Vector3.new(0, 0.02, -distance)
    
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
