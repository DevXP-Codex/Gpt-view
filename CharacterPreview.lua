local CharacterPreview = {}

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
    elseif object:IsA("Script") or object:IsA("LocalScript") then
        object:Destroy()
    end
end

local function getBodyFrame(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    local head = model:FindFirstChild("Head")
    
    if root and head and root:IsA("BasePart") and head:IsA("BasePart") then
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

function CharacterPreview.Create(parent, helpers)
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
    camera.Parent = viewport
    viewport.CurrentCamera = camera
    
    return viewport
end

function CharacterPreview.Render(viewport, previewModel)
    if not viewport or not viewport:IsA("ViewportFrame") then
        return false
    end
    if not previewModel or not previewModel:IsA("Model") then
        return false
    end
    
    local world = viewport:FindFirstChild("WorldModel")
    local camera = viewport:FindFirstChild("PreviewCamera")
    if not world or not camera then
        return false
    end
    
    world:ClearAllChildren()
    
    local model = previewModel:Clone()
    for _, object in ipairs(model:GetDescendants()) do
        configureObject(object)
    end
    model.Parent = world
    
    -- Normalize using the actual body/root instead of the full bounding box.
    -- Hair/accessories can be large and must NOT make the character appear to shrink.
    local frameCenter, bodyHeight = getBodyFrame(model)
    model:PivotTo(model:GetPivot() * CFrame.new(-frameCenter.X, -frameCenter.Y, -frameCenter.Z))
    
    local distance = math.max(bodyHeight * 1.35, 3.2)
    local target = Vector3.new(0, bodyHeight * 0.08, 0)
    local cameraPosition = target + Vector3.new(0, bodyHeight * 0.04, -distance)
    
    camera.FieldOfView = 32
    camera.CFrame = CFrame.lookAt(cameraPosition, target)
    viewport.CurrentCamera = camera
    
    task.defer(function()
        if model.Parent == world and viewport.Parent and camera.Parent == viewport then
            viewport.CurrentCamera = nil
            task.wait()
            viewport.CurrentCamera = camera
        end
    end)
    
    return true
end

return CharacterPreview
