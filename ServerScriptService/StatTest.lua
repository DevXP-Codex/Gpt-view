-- SCRIPT --
local Players = game:GetService("Players")

local CharacterManager =
require(script.Parent.CharacterManager)

local StatManager =
require(script.Parent.StatManager)

Players.PlayerAdded:Connect(function(player)
    
    task.wait(5)
    
    local data =
    CharacterManager.GetPlayerData(player)
    
    if not data then
        warn("STAT TEST: Player data not loaded")
        return
    end
    
    local characters =
    CharacterManager.GetCharacters(player)
    
    if #characters == 0 then
        warn("STAT TEST: No characters")
        return
    end
    
    CharacterManager.SelectCharacter(
    player,
    characters[1].Id
    )
    
    local character =
    CharacterManager.GetActiveCharacter(
    player
    )
    
    if not character then
        warn("STAT TEST: No active character")
        return
    end
    
    print("================================")
    print("YAMA STAT SYSTEM TEST")
    print("Character:", character.Name)
    print("================================")
    
    local attributes =
    StatManager.GetAttributes(character)
    
    for name, value in pairs(attributes) do
        print(name, value)
    end
    
    print("--------------------------------")
    
    local stats =
    StatManager.GetDerivedStats(character)
    
    for name, value in pairs(stats) do
        print(name, value)
    end
    
    print("--------------------------------")
    
    print(
    "Attribute Points:",
    character.AttributePoints
    )
    
    print(
    "STR next cost:",
    StatManager.GetAttributeCost(
    character.Attributes.Strength
    )
    )
    
    print(
    "Physical Damage:",
    StatManager.CalculatePhysicalDamage(
    stats.PhysicalAttack,
    stats.PhysicalDefense
    )
    )
    
    print(
    "Magic Damage:",
    StatManager.CalculateMagicDamage(
    stats.MagicAttack,
    1.5,
    stats.MagicDefense
    )
    )
    
    print("================================")
    
end)
