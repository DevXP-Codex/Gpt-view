-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- CENTRAL CHARACTER PREVIEW
--
-- Shared renderer for CharacterUI, MainMenu creation,
-- and MainMenu character selection cards.
--
-- This version deliberately separates two jobs:
--   1. Normalize generated preview rigs to a canonical pose.
--   2. Frame the head + upper torso consistently in 2D.
--------------------------------------------------

local CharacterPreview = {}

local DEFAULT_FOV = 32
local MIN_DISTANCE = 3.2
local MAX_DISTANCE = 7.5
local FRAME_PADDING = 1.12

local BODY_PART_NAMES = {
    HumanoidRootPart = true,
    Head = true,
    Torso = true,
    UpperTorso = true,
    LowerTorso = true,
    LeftUpperArm = true,
    LeftLowerArm = true,
    LeftHand = true,
    RightUpperArm = true,
    RightLowerArm = true,
    RightHand = true,
    LeftUpperLeg = true,
    LeftLowerLeg = true,
    LeftFoot = true,
    RightUpperLeg = true,
    RightLowerLeg = true,
    RightFoot = true,
    LeftArm = true,
    RightArm = true,
    LeftLeg = true,
    RightLeg = true,
}

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

local function getBodyPartSet(model)
    local set = {}
    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("BasePart") and BODY_PART_NAMES[object.Name] then
            set[object] = true
        end
    end
    return set
end

local function computeJointCFrameFromPart0(part0, joint)
    local transform = CFrame.identity
    if joint:IsA("Motor6D") then
        -- A generated preview may inherit a non-zero animation transform.
        -- We explicitly ignore it for a neutral portrait pose.
        transform = CFrame.identity
    end

    return part0.CFrame * joint.C0 * transform * joint.C1:Inverse()
end

local function computeJointCFrameFromPart1(part1, joint)
    local transform = CFrame.identity
    if joint:IsA("Motor6D") then
        transform = CFrame.identity
    end

    return part1.CFrame * joint.C1 * transform:Inverse() * joint.C0:Inverse()
end

local function normalizeBodyRig(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then
        return
    end

    local bodyParts = getBodyPartSet(model)

    -- Put every Motor6D in a neutral pose first. This prevents an inherited
    -- animation/transform from changing the portrait between previews.
    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Motor6D") then
            object.Transform = CFrame.identity
        end
    end

    -- Canonical YAMA portrait orientation: character faces -Z.
    root.CFrame = CFrame.new(0, 0, 0)

    -- Rebuild only the humanoid body from the authoritative Motor6D C0/C1
    -- relationships. This fixes generated preview models where the head or
    -- another body segment arrives visually detached from the torso.
    local visited = {[root] = true}
    local changed = true
    local safety = 0

    while changed and safety < 32 do
        changed = false
        safety += 1

        for _, object in ipairs(model:GetDescendants()) do
            if object:IsA("Motor6D") then
                local part0 = object.Part0
                local part1 = object.Part1

                if part0 and part1 and bodyParts[part0] and bodyParts[part1] then
                    if visited[part0] and not visited[part1] then
                        part1.CFrame = computeJointCFrameFromPart0(part0, object)
                        visited[part1] = true
                        changed = true
                    elseif visited[part1] and not visited[part0] then
                        part0.CFrame = computeJointCFrameFromPart1(part1, object)
                        visited[part0] = true
                        changed = true
                    end
                end
            end
        end
    end

    -- Preserve each accessory's original relative transform to its attached
    -- body part, then reapply that transform after the body was normalized.
    local accessoryRelations = {}

    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Weld") or object:IsA("Motor6D") then
            local part0 = object.Part0
            local part1 = object.Part1

            if part0 and part1 then
                local part0IsBody = bodyParts[part0] == true
                local part1IsBody = bodyParts[part1] == true

                if part0IsBody ~= part1IsBody then
                    if part0IsBody then
                        table.insert(accessoryRelations, {
                            Part0 = part0,
                            Part1 = part1,
                            C0 = object.C0,
                            C1 = object.C1,
                            Motor = object:IsA("Motor6D"),
                        })
                    else
                        table.insert(accessoryRelations, {
                            Part0 = part1,
                            Part1 = part0,
                            C0 = object.C1,
                            C1 = object.C0,
                            Motor = object:IsA("Motor6D"),
                        })
                    end
                end
            end
        elseif object:IsA("WeldConstraint") then
            local part0 = object.Part0
            local part1 = object.Part1
            if part0 and part1 then
                local part0IsBody = bodyParts[part0] == true
                local part1IsBody = bodyParts[part1] == true
                if part0IsBody ~= part1IsBody then
                    local bodyPart = part0IsBody and part0 or part1
                    local otherPart = part0IsBody and part1 or part0
                    table.insert(accessoryRelations, {
                        Part0 = bodyPart,
                        Part1 = otherPart,
                        Relative = bodyPart.CFrame:ToObjectSpace(otherPart.CFrame),
                        Constraint = true,
                    })
                end
            end
        end
    end

    for _, relation in ipairs(accessoryRelations) do
        if relation.Part0 and relation.Part1
            and relation.Part0:IsA("BasePart")
            and relation.Part1:IsA("BasePart") then

            if relation.Constraint then
                relation.Part1.CFrame = relation.Part0.CFrame * relation.Relative
            else
                relation.Part1.CFrame =
                    relation.Part0.CFrame
                    * relation.C0
                    * relation.C1:Inverse()
            end
        end
    end
end

local function getPortraitTargetAndSpan(model)
    local root, head, torso = getBodyParts(model)

    if head and head:IsA("BasePart") then
        local torsoBottom

        if torso and torso:IsA("BasePart") then
            torsoBottom = torso.Position.Y - torso.Size.Y * 0.55
        elseif root and root:IsA("BasePart") then
            torsoBottom = root.Position.Y + root.Size.Y * 0.05
        else
            torsoBottom = head.Position.Y - 1.5
        end

        local headTop = head.Position.Y + head.Size.Y * 0.55
        local top = headTop
        local bottom = torsoBottom
        local span = math.max(top - bottom, 2.35)
        local targetY = bottom + span * 0.54

        return Vector3.new(0, targetY, 0), span
    end

    local boxCFrame, boxSize = model:GetBoundingBox()
    local span = math.max(boxSize.Y, 2.35)
    return Vector3.new(0, boxCFrame.Position.Y, 0), span
end

local function getPortraitDistance(model, camera)
    local target, span = getPortraitTargetAndSpan(model)
    local verticalFov = math.rad(camera.FieldOfView)

    -- Fit the head + upper torso vertically. This intentionally does NOT use
    -- the full-body bounding box, because hair/accessories can make the whole
    -- model unnecessarily tiny.
    local distance =
        (span * FRAME_PADDING)
        / (2 * math.tan(verticalFov * 0.5))

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
    viewport.Ambient = Color3.fromRGB(190, 180, 155)
    viewport.LightColor = Color3.fromRGB(255, 245, 220)
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

    -- Normalize the generated R15/R6 preview before any camera calculation.
    normalizeBodyRig(model)

    camera.FieldOfView = DEFAULT_FOV

    local distance, target = getPortraitDistance(model, camera)

    -- The normalized rig faces -Z, so the portrait camera stays on -Z.
    local cameraPosition = target + Vector3.new(0, 0.02, -distance)
    camera.CFrame = CFrame.lookAt(cameraPosition, target)
    camera.Focus = CFrame.new(target)
    viewport.CurrentCamera = camera

    return true
end

function CharacterPreview.Update(viewport, previewModel)
    return CharacterPreview.Render(viewport, previewModel)
end

return CharacterPreview
