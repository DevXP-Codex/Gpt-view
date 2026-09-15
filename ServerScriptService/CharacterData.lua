-- MODULE SCRIPT --
local DataStoreService = game:GetService("DataStoreService")
 
local CharacterStore =
DataStoreService:GetDataStore(
"YAMA_Legends_Characters_v1"
)
 
local CharacterData = {}
 
----------------------------------------------
-- SAVE CONTROL
----------------------------------------------
 
local savingPlayers = {}
 
----------------------------------------------
-- DEFAULT DATA
----------------------------------------------
 
local function getDefaultData()
    
    return {
    Characters = {},
    
    -- Shared bank balance for the player account.
    -- This is account-wide and available to all characters.
    BankingAccount = {
    Balance = 0
    }
    }
    
end
 
----------------------------------------------
-- LOAD
----------------------------------------------
 
function CharacterData.Load(player)
    
    local key =
    "Player_" .. player.UserId
    
    
    local success, data = pcall(function()
        
        return CharacterStore:GetAsync(key)
        
    end)
    
    
    if success then
        
        if data == nil then
            
            print(
            "No saved data found for "
            .. player.Name
            )
            
            data = getDefaultData()
            
        else
            
            print(
            "Saved data loaded for "
            .. player.Name
            )
            
        end
        
        
        return data
        
    end
    
    
    warn(
    "Failed to load data for "
    .. player.Name
    )
    
    warn(data)
    
    
    return getDefaultData()
    
end
 
----------------------------------------------
-- SAVE
----------------------------------------------
 
function CharacterData.Save(player, data)
    
    local userId =
    player.UserId
    
    local key =
    "Player_" .. userId
    
    
    ------------------------------------------
    -- CHECK SAVE IN PROGRESS
    ------------------------------------------
    
    if savingPlayers[userId] then
        
        warn(
        "Save already in progress for "
        .. player.Name
        )
        
        return false
        
    end
    
    
    ------------------------------------------
    -- LOCK
    ------------------------------------------
    
    savingPlayers[userId] = true
    
    
    ------------------------------------------
    -- SAVE
    ------------------------------------------
    
    local success, errorMessage = pcall(function()
        
        CharacterStore:SetAsync(
        key,
        data
        )
        
    end)
    
    
    ------------------------------------------
    -- UNLOCK
    ------------------------------------------
    
    savingPlayers[userId] = nil
    
    
    ------------------------------------------
    -- RESULT
    ------------------------------------------
    
    if success then
        
        print(
        "Data saved for "
        .. player.Name
        )
        
        return true
        
    end
    
    
    warn(
    "Failed to save data for "
    .. player.Name
    )
    
    warn(errorMessage)
    
    
    return false
    
end
 
----------------------------------------------
-- RETURN
----------------------------------------------
 
return CharacterData
 
