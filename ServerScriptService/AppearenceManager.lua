-- MODULE SCRIPT --
--------------------------------------------------
-- YAMA: LEGENDS
-- APPEARANCE MANAGER
--------------------------------------------------

local AppearanceManager = {}


--------------------------------------------------
-- ROBLOX AVATAR SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local AssetService = game:GetService("AssetService")
local AvatarEditorService = game:GetService("AvatarEditorService")

local faceResolutionCache = {}

local resolveFace
local applyFace

--------------------------------------------------
-- SAFE DEFAULT SKIN
--
-- A newly-created HumanoidDescription can otherwise
-- arrive with black body-color properties when no skin
-- customization has been selected yet.
--------------------------------------------------

local DEFAULT_SKIN_COLOR = Color3.fromRGB(255, 204, 153)

local function applyDefaultSkinColor(description)
    if not description then
        return
    end
    
    description.HeadColor = DEFAULT_SKIN_COLOR
    description.LeftArmColor = DEFAULT_SKIN_COLOR
    description.RightArmColor = DEFAULT_SKIN_COLOR
    description.LeftLegColor = DEFAULT_SKIN_COLOR
    description.RightLegColor = DEFAULT_SKIN_COLOR
    description.TorsoColor = DEFAULT_SKIN_COLOR
end

local function applyDynamicHeadData(targetDescription, sourceDescription, fallbackHeadId)
    if not targetDescription then return false end
    local headId = fallbackHeadId
    if sourceDescription then
        local sourceHead = tonumber(sourceDescription.Head)
        if sourceHead and sourceHead > 0 then headId = sourceHead end
    end
    if not headId or headId <= 0 then return false end
    pcall(function()
        targetDescription.Head = headId
        targetDescription.Face = 0
    end)
    if not sourceDescription then return true end
    pcall(function()
        targetDescription.MoodAnimation = tonumber(sourceDescription.MoodAnimation) or 0
        targetDescription.StaticFacialAnimation = sourceDescription.StaticFacialAnimation
    end)
    local okSource, sourceAccessories = pcall(function() return sourceDescription:GetAccessories(true) end)
        local okCurrent, currentAccessories = pcall(function() return targetDescription:GetAccessories(true) end)
            if okSource and sourceAccessories and okCurrent and currentAccessories then
                local merged = {}
                for _, accessory in ipairs(currentAccessories) do
                    local t = tostring(accessory.AccessoryType)
                    if not t:match("Eyebrow$") and not t:match("Eyelash$") then table.insert(merged, accessory) end
                end
                for _, accessory in ipairs(sourceAccessories) do
                    local t = tostring(accessory.AccessoryType)
                    if t:match("Eyebrow$") or t:match("Eyelash$") then table.insert(merged, accessory) end
                end
                pcall(function() targetDescription:SetAccessories(merged, true) end)
                end
                    return true
                end
                
                -- These entries are known Dynamic Head bundle IDs.
                -- They must never be assigned directly to HumanoidDescription.Face.
                local FACE_BUNDLE_IDS = {
                [1601912] = true,
                [945] = true,
                [946] = true,
                [948] = true,
                [858696] = true,
                [956] = true,
                [3102] = true,
                [2924073754063] = true,
                [270257809508766] = true,
                }
                
                -- Direct Dynamic Head asset IDs. These must use HumanoidDescription.Head.
                local DIRECT_DYNAMIC_HEAD_IDS = {
                [138869154852215] = true,
                }
                
                
                --------------------------------------------------
                -- CATALOG FOLDER
                --------------------------------------------------
                
                local CatalogFolder =
                script.Parent.Catalog
                
                
                --------------------------------------------------
                -- LOAD CATALOGS
                --------------------------------------------------
                
                local DefaultAppearanceCatalog =
                require(
                CatalogFolder:WaitForChild(
                "DefaultAppearanceCatalog"
                )
                )
                
                
                local CosmeticCatalog =
                require(
                CatalogFolder:WaitForChild(
                "CosmeticCatalog"
                )
                )
                
                
                local EquipmentCatalog =
                require(
                CatalogFolder:WaitForChild(
                "EquipmentCatalog"
                )
                )
                
                
                --------------------------------------------------
                -- APPEARANCE PART CATALOG
                --
                -- Contains reusable visual building blocks.
                --
                -- IMPORTANT:
                -- Class defaults are NOT stored here.
                -- Class defaults are stored in
                -- DefaultAppearanceCatalog.
                --------------------------------------------------
                
                local CreationOptions = {
                
                Skin = DefaultAppearanceCatalog.CreationOptions
                and DefaultAppearanceCatalog.CreationOptions.Skin
                or {},
                
                Hair = DefaultAppearanceCatalog.CreationOptions
                and DefaultAppearanceCatalog.CreationOptions.Hair
                or {},
                
                Face = DefaultAppearanceCatalog.CreationOptions
                and DefaultAppearanceCatalog.CreationOptions.Face
                or {},
                
                Looks = DefaultAppearanceCatalog.CreationLooks
                or {}
                
                }
                
                
                local AppearanceCatalog = {
                
                --------------------------------------------------
                -- BODY
                --------------------------------------------------
                
                Body = {
                
                -- Future body visual parts.
                
                },
                
                
                --------------------------------------------------
                -- HAIR
                --------------------------------------------------
                
                Hair = {
                
                Default = {
                
                HairAccessory = ""
                
                },
                
                Pal_Hair = {
                
                HairAccessory = "63690008"
                
                },
                
                Warrior_Hair = {
                
                HairAccessory = "102535903158992"
                
                },
                
                Hair01 = {HairAccessory = "78483505436895"},
                Hair02 = {HairAccessory = "9244021842"},
                Hair03 = {HairAccessory = "9243992729"},
                Hair04 = {HairAccessory = "9174354743"},
                Hair05 = {HairAccessory = "62234425"},
                Hair06 = {HairAccessory = "7193442167"},
                Hair07 = {HairAccessory = "6993754725"},
                Hair08 = {HairAccessory = "7193448988"},
                Hair09 = {HairAccessory = "553722174"},
                Hair10 = {HairAccessory = "9244095135"}
                
                },
                
                
                --------------------------------------------------
                -- FACE
                --------------------------------------------------
                
                Face = {
                
                Default = {
                
                Face = 0
                
                },
                
                Face01 = {Face = 1601912},
                Face02 = {Face = 51953343082478},
                Face03 = {Face = 250788615967680},
                Face04 = {Face = 2924073754063},
                Face05 = {Face = 270257809508766},
                Face06 = {Face = 948},
                Face07 = {Face = 138869154852215},
                Face08 = {Face = 858696},
                Face09 = {Face = 3102},
                Face10 = {Face = 956}
                
                },
                
                
                --------------------------------------------------
                -- SHIRT
                --------------------------------------------------
                
                Shirt = {
                
                Default = {
                
                Shirt = 0
                
                },
                
                Adventurer_Default = {
                
                Shirt = DefaultAppearanceCatalog.AdventurerDefaultClothing.Shirt or 0
                
                }
                
                },
                
                
                --------------------------------------------------
                -- PANTS
                --------------------------------------------------
                
                Pants = {
                
                Default = {
                
                Pants = 0
                
                },
                
                Adventurer_Default = {
                
                Pants = DefaultAppearanceCatalog.AdventurerDefaultClothing.Pants or 0
                
                }
                
                },
                
                
                --------------------------------------------------
                -- HAT
                --------------------------------------------------
                
                Hat = {},
                
                
                --------------------------------------------------
                -- BACK
                --------------------------------------------------
                
                Back = {},
                
                
                --------------------------------------------------
                -- ACCESSORY
                --------------------------------------------------
                
                Accessory = {},
                
                
                --------------------------------------------------
                -- WEAPON
                --
                -- Weapon visuals may eventually be handled
                -- by equipment/cosmetic models instead of
                -- HumanoidDescription.
                --------------------------------------------------
                
                Weapon = {}
                
                }
                
                
                --------------------------------------------------
                -- GET DEFAULT CLASS APPEARANCE
                --------------------------------------------------
                
                --------------------------------------------------
                -- CREATION APPEARANCE OPTIONS
                --------------------------------------------------
                
                function AppearanceManager.GetCreationOptions()
                    
                    return CreationOptions
                    
                end
                
                
                function AppearanceManager.GetCreationAppearance(
                    customization
                    )
                    
                    return {
                    
                    Class = "Adventurer",
                    
                    Equipment = {},
                    
                    Cosmetics = {},
                    
                    Customization = customization or {}
                    
                    }
                    
                end
                
                
                function AppearanceManager.ValidateCustomization(
                    customization
                    )
                    
                    if customization == nil then
                        return true
                    end
                    
                    if typeof(customization) ~= "table" then
                        return false
                    end
                    
                    if customization.Skin
                        and CreationOptions.Skin[customization.Skin] == nil then
                        return false
                    end
                    
                    if customization.Hair
                        and AppearanceCatalog.Hair[customization.Hair] == nil then
                        return false
                    end
                    
                    if customization.Face
                        and AppearanceCatalog.Face[customization.Face] == nil then
                        return false
                    end
                    
                    return true
                    
                end
                
                
                function AppearanceManager.GetDefaultAppearance(
                    className
                    )
                    
                    if not className then
                        
                        warn(
                        "Cannot get default appearance without class."
                        )
                        
                        return nil
                        
                    end
                    
                    
                    local defaultAppearance =
                    DefaultAppearanceCatalog[className]
                    
                    
                    if not defaultAppearance then
                        
                        warn(
                        "Default appearance not found for class: "
                        .. tostring(className)
                        )
                        
                        return nil
                        
                    end
                    
                    
                    return defaultAppearance
                    
                end
                
                
                --------------------------------------------------
                -- GET EQUIPMENT DATA
                --------------------------------------------------
                
                function AppearanceManager.GetEquipmentData(
                    itemId
                    )
                    
                    if not itemId then
                        
                        return nil
                        
                    end
                    
                    
                    for _, category
                        in pairs(EquipmentCatalog) do
                        
                        if category[itemId] then
                            
                            return category[itemId]
                            
                        end
                        
                    end
                    
                    
                    return nil
                    
                end
                
                
                --------------------------------------------------
                -- GET COSMETIC DATA
                --------------------------------------------------
                
                function AppearanceManager.GetCosmeticData(
                    itemId
                    )
                    
                    if not itemId then
                        
                        return nil
                        
                    end
                    
                    
                    for _, category
                        in pairs(CosmeticCatalog) do
                        
                        if category[itemId] then
                            
                            return category[itemId]
                            
                        end
                        
                    end
                    
                    
                    return nil
                    
                end
                
                
                --------------------------------------------------
                -- GET APPEARANCE CATALOG
                --------------------------------------------------
                
                function AppearanceManager.GetAppearanceCatalog()
                    
                    return AppearanceCatalog
                    
                end
                
                
                --------------------------------------------------
                -- GET PART DATA
                --------------------------------------------------
                
                function AppearanceManager.GetPartData(
                    partType,
                    partId
                    )
                    
                    if not partType or not partId then
                        
                        return nil
                        
                    end
                    
                    
                    local partCatalog =
                    AppearanceCatalog[partType]
                    
                    
                    if not partCatalog then
                        
                        warn(
                        "Appearance part type not found: "
                        .. tostring(partType)
                        )
                        
                        return nil
                        
                    end
                    
                    
                    local partData =
                    partCatalog[partId]
                    
                    
                    if not partData then
                        
                        warn(
                        "Appearance not found: "
                        .. tostring(partType)
                        .. " / "
                        .. tostring(partId)
                        )
                        
                        return nil
                        
                    end
                    
                    
                    return partData
                    
                end
                
                
                --------------------------------------------------
                -- APPLY PART DATA
                --------------------------------------------------
                
                local function applyPartData(
                    description,
                    partData
                    )
                    
                    if not description then
                        
                        return
                        
                    end
                    
                    
                    if not partData then
                        
                        return
                        
                    end
                    
                    
                    for property, value
                        in pairs(partData) do
                        
                        if description[property] ~= nil then
                            
                            description[property] =
                            value
                            
                        end
                        
                    end
                    
                end
                
                
                --------------------------------------------------
                -- APPLY HAIR ACCESSORY
                --------------------------------------------------
                
                local function applyHairAccessory(description, hairAccessoryId)
                    if not description then
                        return
                    end
                    
                    -- Clear the direct property first so a previous hair cannot remain.
                    pcall(function()
                        description.HairAccessory = ""
                    end)
                    
                    if not hairAccessoryId or tostring(hairAccessoryId) == "" then
                        return
                    end
                    
                    local assetId = tonumber(hairAccessoryId)
                    if not assetId then
                        return
                    end
                    
                    -- Use the modern accessory API. This is more reliable for rigid
                    -- hair accessories than relying only on the string property.
                    local ok, err = pcall(function()
                        description:SetAccessories({
                        {
                        AssetId = assetId,
                        AccessoryType = Enum.AccessoryType.Hair,
                        }
                        }, true)
                    end)
                    
                    if not ok then
                        -- Fallback to the classic HumanoidDescription property.
                        pcall(function()
                            description.HairAccessory = tostring(assetId)
                        end)
                        warn("YAMA: SetAccessories failed for hair " .. tostring(assetId) .. ": " .. tostring(err))
                    end
                end
                
                
                --------------------------------------------------
                -- APPLY DEFAULT APPEARANCE
                --------------------------------------------------
                
                local function applyDefaultAppearance(
                    description,
                    appearance
                    )
                    
                    if not appearance then
                        
                        return
                        
                    end
                    
                    
                    --------------------------------------------------
                    -- BODY
                    --------------------------------------------------
                    --
                    -- Body values such as "Adventurer_Default" are
                    -- CLASS PRESET identifiers, not entries in the
                    -- reusable AppearanceCatalog.Body table.
                    --
                    -- HumanoidDescription already provides the default
                    -- R15 body. We therefore do NOT resolve Body through
                    -- GetPartData(), which prevents false warnings such as:
                    -- "Appearance not found: Body / Adventurer_Default".
                    --
                    -- When we later add real body presets, this section can
                    -- be extended to apply their HumanoidDescription data.
                    --------------------------------------------------
                    
                    
                    --------------------------------------------------
                    -- HAIR
                    --------------------------------------------------
                    
                    if appearance.Hair then
                        
                        local hairData =
                        AppearanceManager.GetPartData(
                        "Hair",
                        appearance.Hair
                        )
                        
                        if hairData then
                            applyHairAccessory(
                            description,
                            hairData.HairAccessory
                            )
                        end
                        
                    end
                    
                    
                    --------------------------------------------------
                    -- FACE
                    --------------------------------------------------
                    
                    if appearance.Face then
                        
                        local faceData =
                        AppearanceManager.GetPartData(
                        "Face",
                        appearance.Face
                        )
                        
                        
                        if faceData and faceData.Face then
                            applyFace(description, faceData.Face)
                        end
                        
                    end
                    
                    
                    --------------------------------------------------
                    -- SHIRT
                    --------------------------------------------------
                    
                    if appearance.Shirt then
                        
                        local shirtData =
                        AppearanceManager.GetPartData(
                        "Shirt",
                        appearance.Shirt
                        )
                        
                        
                        applyPartData(
                        description,
                        shirtData
                        )
                        
                    end
                    
                    
                    --------------------------------------------------
                    -- PANTS
                    --------------------------------------------------
                    
                    if appearance.Pants then
                        
                        local pantsData =
                        AppearanceManager.GetPartData(
                        "Pants",
                        appearance.Pants
                        )
                        
                        
                        applyPartData(
                        description,
                        pantsData
                        )
                        
                    end
                    
                    
                    --------------------------------------------------
                    -- HAT
                    --------------------------------------------------
                    
                    if appearance.Hat then
                        
                        local hatData =
                        AppearanceManager.GetPartData(
                        "Hat",
                        appearance.Hat
                        )
                        
                        
                        applyPartData(
                        description,
                        hatData
                        )
                        
                    end
                    
                    
                    --------------------------------------------------
                    -- BACK
                    --------------------------------------------------
                    
                    if appearance.Back then
                        
                        local backData =
                        AppearanceManager.GetPartData(
                        "Back",
                        appearance.Back
                        )
                        
                        
                        applyPartData(
                        description,
                        backData
                        )
                        
                    end
                    
                    
                    --------------------------------------------------
                    -- ACCESSORY
                    --------------------------------------------------
                    
                    if appearance.Accessory then
                        
                        local accessoryData =
                        AppearanceManager.GetPartData(
                        "Accessory",
                        appearance.Accessory
                        )
                        
                        
                        applyPartData(
                        description,
                        accessoryData
                        )
                        
                    end
                    
                end
                
                
                --------------------------------------------------
                -- RESOLVE FACE / DYNAMIC HEAD
                --------------------------------------------------
                
                resolveFace = function(faceId)
                    local numericId = tonumber(faceId)
                    if not numericId or numericId <= 0 then
                        return nil, nil
                    end
                    
                    local cached = faceResolutionCache[numericId]
                    if cached then
                        return cached.Kind, cached.Id, cached.Description
                    elseif cached == false then
                        return nil, nil
                    end
                    
                    -- Helper: Roblox API fields can be returned as strings/enums depending
                    -- on the API path/version. Normalize them before comparing.
                    local function isType(value, expected)
                        local text = tostring(value)
                        return text == expected or text:match("%." .. expected .. "$") ~= nil
                    end
                    
                    -- 1) Direct Dynamic Head asset: resolve its associated bundle/outfit so
                    -- the resulting description retains MoodAnimation and facial data.
                    local okAssetBundles, assetBundles = pcall(function()
                        return AvatarEditorService:GetBundlesByAssetIdAsync(numericId, 10)
                    end)
                    if okAssetBundles and assetBundles then
                        local okPage, page = pcall(function() return assetBundles:GetCurrentPage() end)
                            if okPage and page then
                                for _, bundle in ipairs(page) do
                                    local bundleId = tonumber(bundle.Id or bundle.BundleId)
                                    if bundleId and bundleId > 0 then
                                        local okDetails, bundleInfo = pcall(function() return AssetService:GetBundleDetailsAsync(bundleId) end)
                                            if okDetails and bundleInfo then
                                                local outfitId
                                                for _, item in ipairs(bundleInfo.Items or {}) do
                                                    if isType(item.Type, "UserOutfit") then outfitId = tonumber(item.Id); break end
                                                end
                                                if outfitId then
                                                    local okDesc, bundleDescription = pcall(function() return Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId) end)
                                                        if okDesc and bundleDescription then
                                                            local headId = tonumber(bundleDescription.Head)
                                                            if headId and headId > 0 then
                                                                faceResolutionCache[numericId] = {Kind="HeadOutfit", Id=headId, Description=bundleDescription}
                                                                return "HeadOutfit", headId, bundleDescription
                                                            end
                                                            bundleDescription:Destroy()
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                -- 2) Try bundle resolution first for known bundle IDs.
                                -- Roblox documents that GetBundleDetailsAsync returns bundle Items and
                                -- that DynamicHead items can be identified through AssetType.
                                if FACE_BUNDLE_IDS[numericId] then
                                    local okBundle, bundleInfo = pcall(function()
                                        return AssetService:GetBundleDetailsAsync(numericId)
                                    end)
                                    
                                    if okBundle and bundleInfo then
                                        local outfitId
                                        local dynamicHeadId
                                        
                                        for _, item in ipairs(bundleInfo.Items or {}) do
                                            if isType(item.Type, "UserOutfit") then
                                                outfitId = tonumber(item.Id)
                                            elseif isType(item.AssetType, "DynamicHead") then
                                                dynamicHeadId = tonumber(item.Id)
                                            end
                                        end
                                        
                                        if outfitId then
                                            local okDescription, bundleDescription = pcall(function()
                                                return Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId)
                                            end)
                                            
                                            if okDescription and bundleDescription then
                                                local headId = tonumber(bundleDescription.Head)
                                                
                                                if headId and headId > 0 then
                                                    faceResolutionCache[numericId] = {
                                                    Kind = "HeadOutfit",
                                                    Id = headId,
                                                    Description = bundleDescription,
                                                    }
                                                    return "HeadOutfit", headId, bundleDescription
                                                end
                                                
                                                bundleDescription:Destroy()
                                            end
                                        end
                                        
                                        if dynamicHeadId and dynamicHeadId > 0 then
                                            faceResolutionCache[numericId] = {
                                            Kind = "Head",
                                            Id = dynamicHeadId
                                            }
                                            return "Head", dynamicHeadId
                                        end
                                    end
                                end
                                
                                -- 2) Ask Roblox what type the numeric asset is. Normalize AssetType
                                -- because it may be returned as a string or enum-like value.
                                local okAsset, assetInfo = pcall(function()
                                    return AvatarEditorService:GetItemDetailsAsync(
                                    numericId,
                                    Enum.AvatarItemType.Asset
                                    )
                                end)
                                
                                if okAsset and assetInfo then
                                    if isType(assetInfo.AssetType, "DynamicHead") then
                                        faceResolutionCache[numericId] = {
                                        Kind = "Head",
                                        Id = numericId
                                        }
                                        return "Head", numericId
                                    end
                                    
                                    if isType(assetInfo.AssetType, "Face") then
                                        faceResolutionCache[numericId] = {
                                        Kind = "Face",
                                        Id = numericId
                                        }
                                        return "Face", numericId
                                    end
                                end
                                
                                -- 3) If the ID was not recognized as an asset, try it as a bundle even
                                -- when it was not in the static list. This covers newer/UGC face bundles.
                                local okFallbackBundle, fallbackBundle = pcall(function()
                                    return AssetService:GetBundleDetailsAsync(numericId)
                                end)
                                
                                if okFallbackBundle and fallbackBundle then
                                    local outfitId
                                    local dynamicHeadId
                                    
                                    for _, item in ipairs(fallbackBundle.Items or {}) do
                                        if isType(item.Type, "UserOutfit") then
                                            outfitId = tonumber(item.Id)
                                        elseif isType(item.AssetType, "DynamicHead") then
                                            dynamicHeadId = tonumber(item.Id)
                                        end
                                    end
                                    
                                    if outfitId then
                                        local okDescription, bundleDescription = pcall(function()
                                            return Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId)
                                        end)
                                        
                                        if okDescription and bundleDescription then
                                            local headId = tonumber(bundleDescription.Head)
                                            
                                            if headId and headId > 0 then
                                                faceResolutionCache[numericId] = {
                                                Kind = "HeadOutfit",
                                                Id = headId,
                                                Description = bundleDescription
                                                }
                                                return "HeadOutfit", headId, bundleDescription
                                            end
                                            
                                            bundleDescription:Destroy()
                                        end
                                    end
                                    
                                    if dynamicHeadId and dynamicHeadId > 0 then
                                        faceResolutionCache[numericId] = {
                                        Kind = "Head",
                                        Id = dynamicHeadId
                                        }
                                        return "Head", dynamicHeadId
                                    end
                                end
                                
                                -- 4) Last compatibility path for a classic Face ID.
                                if not FACE_BUNDLE_IDS[numericId] then
                                    faceResolutionCache[numericId] = {
                                    Kind = "Face",
                                    Id = numericId
                                    }
                                    return "Face", numericId
                                end
                                
                                warn("YAMA: Could not resolve face asset " .. tostring(numericId))
                                faceResolutionCache[numericId] = false
                                return nil, nil
                            end
                            
                            applyFace = function(description, faceId)
                                if not description then
                                    return
                                end
                                
                                local kind, numericId, sourceDescription = resolveFace(faceId)
                                
                                if kind == "HeadOutfit" and numericId then
                                    applyDynamicHeadData(description, sourceDescription, numericId)
                                    if sourceDescription and sourceDescription ~= description then sourceDescription:Destroy() end
                                    local cached = faceResolutionCache[tonumber(faceId)]
                                    if cached then cached.Description = nil end
                                    return
                                end
                                
                                if kind == "Head" and numericId then
                                    pcall(function()
                                        description.Head = numericId
                                        description.Face = 0
                                    end)
                                    return
                                end
                                
                                if kind == "Face" and numericId then
                                    pcall(function()
                                        description.Face = numericId
                                    end)
                                    return
                                end
                                
                                -- Never feed an unresolved bundle ID into HumanoidDescription.Face.
                                pcall(function()
                                    description.Face = 0
                                end)
                            end
                            
                            
                            --------------------------------------------------
                            -- APPLY CREATION CUSTOMIZATION
                            --------------------------------------------------
                            
                            local function applyCustomization(
                                description,
                                customization
                                )
                                
                                if not description or not customization then
                                    return
                                end
                                
                                --------------------------------------------------
                                -- SKIN
                                --------------------------------------------------
                                
                                if customization.Skin then
                                    
                                    local skinData =
                                    CreationOptions.Skin[customization.Skin]
                                    
                                    local skinColor =
                                    skinData and skinData.Color
                                    
                                    if skinColor then
                                        
                                        description.HeadColor = skinColor
                                        description.LeftArmColor = skinColor
                                        description.RightArmColor = skinColor
                                        description.LeftLegColor = skinColor
                                        description.RightLegColor = skinColor
                                        description.TorsoColor = skinColor
                                        
                                    end
                                    
                                end
                                
                                --------------------------------------------------
                                -- HAIR
                                --------------------------------------------------
                                
                                if customization.Hair then
                                    
                                    local hairData =
                                    AppearanceManager.GetPartData(
                                    "Hair",
                                    customization.Hair
                                    )
                                    
                                    if hairData then
                                        applyHairAccessory(
                                        description,
                                        hairData.HairAccessory
                                        )
                                    end
                                    
                                end
                                
                                --------------------------------------------------
                                -- FACE
                                --------------------------------------------------
                                
                                if customization.Face then
                                    
                                    local faceData =
                                    AppearanceManager.GetPartData(
                                    "Face",
                                    customization.Face
                                    )
                                    
                                    if faceData and faceData.Face then
                                        applyFace(description, faceData.Face)
                                    end
                                    
                                end
                                
                            end
                            
                            
                            --------------------------------------------------
                            -- APPLY EQUIPMENT
                            --------------------------------------------------
                            
                            local function applyEquipment(
                                description,
                                equipment
                                )
                                
                                if not equipment then
                                    
                                    return
                                    
                                end
                                
                                
                                for slot, itemId
                                    in pairs(equipment) do
                                    
                                    if itemId then
                                        
                                        local itemData =
                                        AppearanceManager.GetEquipmentData(
                                        itemId
                                        )
                                        
                                        
                                        if not itemData then
                                            
                                            warn(
                                            "Equipment not found while building appearance: "
                                            .. tostring(itemId)
                                            )
                                            
                                        else
                                            
                                            --------------------------------------------------
                                            -- Equipment visual layer
                                            --------------------------------------------------
                                            
                                            if itemData.Appearance then
                                                
                                                applyPartData(
                                                description,
                                                itemData.Appearance
                                                )
                                                
                                            end
                                            
                                        end
                                        
                                    end
                                    
                                end
                                
                            end
                            
                            
                            --------------------------------------------------
                            -- APPLY COSMETICS
                            --------------------------------------------------
                            
                            local function applyCosmetics(
                                description,
                                cosmetics
                                )
                                
                                if not cosmetics then
                                    
                                    return
                                    
                                end
                                
                                
                                for slot, itemId
                                    in pairs(cosmetics) do
                                    
                                    if itemId then
                                        
                                        local cosmeticData =
                                        AppearanceManager.GetCosmeticData(
                                        itemId
                                        )
                                        
                                        
                                        if not cosmeticData then
                                            
                                            warn(
                                            "Cosmetic not found while building appearance: "
                                            .. tostring(itemId)
                                            )
                                            
                                        else
                                            
                                            --------------------------------------------------
                                            -- Cosmetic visual layer
                                            --
                                            -- This is applied AFTER equipment,
                                            -- therefore it has visual priority.
                                            --------------------------------------------------
                                            
                                            if cosmeticData.Appearance then
                                                
                                                applyPartData(
                                                description,
                                                cosmeticData.Appearance
                                                )
                                                
                                            end
                                            
                                        end
                                        
                                    end
                                    
                                end
                                
                            end
                            
                            
                            --------------------------------------------------
                            -- BUILD DESCRIPTION
                            --------------------------------------------------
                            
                            function AppearanceManager.BuildDescription(
                                appearance
                                )
                                
                                if not appearance then
                                    
                                    warn(
                                    "Cannot build appearance without appearance data."
                                    )
                                    
                                    return nil
                                    
                                end
                                
                                
                                local description =
                                Instance.new(
                                "HumanoidDescription"
                                )
                                
                                -- Always start from a visible, non-black body.
                                -- A selected Skin customization will override this below.
                                applyDefaultSkinColor(description)
                                
                                
                                --------------------------------------------------
                                -- LAYER 1
                                -- DEFAULT
                                --------------------------------------------------
                                
                                local defaultAppearance
                                
                                
                                if appearance.Class then
                                    
                                    defaultAppearance =
                                    AppearanceManager.GetDefaultAppearance(
                                    appearance.Class
                                    )
                                    
                                else
                                    
                                    --------------------------------------------------
                                    -- BACKWARD COMPATIBILITY
                                    --
                                    -- Supports the old appearance structure
                                    -- while existing characters are migrated.
                                    --------------------------------------------------
                                    
                                    defaultAppearance =
                                    appearance
                                    
                                end
                                
                                
                                applyDefaultAppearance(
                                description,
                                defaultAppearance
                                )
                                
                                --------------------------------------------------
                                -- SAFE DEFAULT FACE
                                --
                                -- The legacy "Default" face is 0. For YAMA creation
                                -- and newly-created characters we want an actual face
                                -- visible immediately. Face01 is resolved by the same
                                -- dynamic-head compatibility path used elsewhere.
                                --------------------------------------------------
                                
                                local customization = appearance.Customization or {}
                                
                                if not customization.Face
                                    and (tonumber(description.Face) or 0) == 0 then
                                    applyFace(description, 1601912)
                                end
                                
                                
                                --------------------------------------------------
                                -- LAYER 2
                                -- EQUIPMENT
                                --
                                -- Equipment overrides default appearance.
                                --------------------------------------------------
                                
                                applyEquipment(
                                description,
                                appearance.Equipment
                                )
                                
                                
                                --------------------------------------------------
                                -- LAYER 3
                                -- COSMETICS
                                --
                                -- Cosmetics override equipment.
                                --------------------------------------------------
                                
                                applyCosmetics(
                                description,
                                appearance.Cosmetics
                                )
                                
                                
                                --------------------------------------------------
                                -- LAYER 4
                                -- CUSTOMIZATION
                                --
                                -- Future character customization.
                                --
                                -- Examples:
                                -- HairColor
                                -- SkinColor
                                -- EyeColor
                                -- etc.
                                --------------------------------------------------
                                
                                if appearance.Customization then
                                    
                                    applyCustomization(
                                    description,
                                    customization
                                    )
                                    
                                end
                                
                                --------------------------------------------------
                                -- FINAL AVATAR RULE CONVERSION
                                --
                                -- Roblox can migrate a classic Face asset to its
                                -- corresponding Dynamic Head automatically. This is
                                -- especially important after the 2026 face migration.
                                -- If the service is unavailable, keep the original
                                -- description so the preview/spawn flow is not broken.
                                --------------------------------------------------
                                
                                if description.Face and description.Face ~= 0 then
                                    local okConform, conformed = pcall(function()
                                        return AvatarEditorService:ConformToAvatarRulesAsync(
                                        description
                                        )
                                    end)
                                    
                                    if okConform and conformed then
                                        description:Destroy()
                                        description = conformed
                                    end
                                end
                                
                                return description
                                
                            end
                            
                            
                            --------------------------------------------------
                            -- VALIDATE DEFAULT APPEARANCE
                            --------------------------------------------------
                            
                            function AppearanceManager.ValidateDefaultAppearance(
                                className
                                )
                                
                                local appearance =
                                AppearanceManager.GetDefaultAppearance(
                                className
                                )
                                
                                
                                if not appearance then
                                    
                                    return false
                                    
                                end
                                
                                
                                for partType, partId
                                    in pairs(appearance) do
                                    
                                    if partId ~= nil then
                                        
                                        -- Body is a class preset identifier, not a
                                        -- reusable AppearanceCatalog entry.
                                        if partType ~= "Body" then
                                            
                                            local partData =
                                            AppearanceManager.GetPartData(
                                            partType,
                                            partId
                                            )
                                            
                                            if not partData then
                                                
                                                warn(
                                                "Invalid default appearance: "
                                                .. tostring(className)
                                                .. " / "
                                                .. tostring(partType)
                                                .. " / "
                                                .. tostring(p