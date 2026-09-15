-- MODULE SCRIPT -- 
--------------------------------------------------
-- YAMA: LEGENDS
-- CURRENCY SERVICE
-- Character Gold + Account Banking Account
--------------------------------------------------

local CharacterManager = require(
script.Parent:WaitForChild("CharacterManager")
)

local CurrencyService = {}

--------------------------------------------------
-- VALIDATION
--------------------------------------------------

local function normalizeAmount(amount)
    amount = tonumber(amount)
    
    if not amount then
        return nil
    end
    
    amount = math.floor(amount)
    
    if amount < 0 then
        return nil
    end
    
    return amount
end

local function getCharacter(player)
    if not player then
        return nil
    end
    
    local character =
    CharacterManager.GetActiveCharacter(player)
    
    if not character then
        return nil
    end
    
    character.Gold =
    math.max(0, math.floor(tonumber(character.Gold) or 0))
    
    return character
end

local function getBank(player)
    if not player then
        return nil
    end
    
    local data =
    CharacterManager.GetPlayerData(player)
    
    if not data then
        return nil
    end
    
    data.BankingAccount =
    data.BankingAccount
    or {}
    
    data.BankingAccount.Balance =
    math.max(0, math.floor(tonumber(data.BankingAccount.Balance) or 0))
    
    return data.BankingAccount
end

--------------------------------------------------
-- CHARACTER GOLD
--------------------------------------------------

function CurrencyService.GetGold(player)
    local character = getCharacter(player)
    
    if not character then
        return 0
    end
    
    return character.Gold
end

function CurrencyService.SetGold(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false, "INVALID_AMOUNT"
    end
    
    local character = getCharacter(player)
    
    if not character then
        return false, "NO_ACTIVE_CHARACTER"
    end
    
    character.Gold = amount
    
    CharacterManager.MarkDirty(player)
    
    return true, character.Gold
end

function CurrencyService.AddGold(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false, "INVALID_AMOUNT"
    end
    
    local character = getCharacter(player)
    
    if not character then
        return false, "NO_ACTIVE_CHARACTER"
    end
    
    character.Gold += amount
    
    CharacterManager.MarkDirty(player)
    
    return true, character.Gold
end

function CurrencyService.CanAfford(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false
    end
    
    return CurrencyService.GetGold(player) >= amount
end

function CurrencyService.RemoveGold(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false, "INVALID_AMOUNT"
    end
    
    local character = getCharacter(player)
    
    if not character then
        return false, "NO_ACTIVE_CHARACTER"
    end
    
    if character.Gold < amount then
        return false, "NOT_ENOUGH_GOLD"
    end
    
    character.Gold -= amount
    
    CharacterManager.MarkDirty(player)
    
    return true, character.Gold
end

--------------------------------------------------
-- BANKING ACCOUNT
--------------------------------------------------

function CurrencyService.GetBankBalance(player)
    local bank = getBank(player)
    
    if not bank then
        return 0
    end
    
    return bank.Balance
end

function CurrencyService.SetBankBalance(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false, "INVALID_AMOUNT"
    end
    
    local bank = getBank(player)
    
    if not bank then
        return false, "PLAYER_DATA_NOT_LOADED"
    end
    
    bank.Balance = amount
    
    CharacterManager.MarkDirty(player)
    
    return true, bank.Balance
end

function CurrencyService.AddBankGold(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false, "INVALID_AMOUNT"
    end
    
    local bank = getBank(player)
    
    if not bank then
        return false, "PLAYER_DATA_NOT_LOADED"
    end
    
    bank.Balance += amount
    
    CharacterManager.MarkDirty(player)
    
    return true, bank.Balance
end

function CurrencyService.CanWithdraw(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false
    end
    
    return CurrencyService.GetBankBalance(player) >= amount
end

function CurrencyService.RemoveBankGold(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false, "INVALID_AMOUNT"
    end
    
    local bank = getBank(player)
    
    if not bank then
        return false, "PLAYER_DATA_NOT_LOADED"
    end
    
    if bank.Balance < amount then
        return false, "NOT_ENOUGH_BANK_GOLD"
    end
    
    bank.Balance -= amount
    
    CharacterManager.MarkDirty(player)
    
    return true, bank.Balance
end

--------------------------------------------------
-- BANK TRANSFERS
--------------------------------------------------

function CurrencyService.DepositGold(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false, "INVALID_AMOUNT"
    end
    
    local character = getCharacter(player)
    local bank = getBank(player)
    
    if not character then
        return false, "NO_ACTIVE_CHARACTER"
    end
    
    if not bank then
        return false, "PLAYER_DATA_NOT_LOADED"
    end
    
    if character.Gold < amount then
        return false, "NOT_ENOUGH_GOLD"
    end
    
    character.Gold -= amount
    bank.Balance += amount
    
    CharacterManager.MarkDirty(player)
    
    return true, {
    Gold = character.Gold,
    BankBalance = bank.Balance
    }
end

function CurrencyService.WithdrawGold(player, amount)
    amount = normalizeAmount(amount)
    
    if amount == nil then
        return false, "INVALID_AMOUNT"
    end
    
    local character = getCharacter(player)
    local bank = getBank(player)
    
    if not character then
        return false, "NO_ACTIVE_CHARACTER"
    end
    
    if not bank then
        return false, "PLAYER_DATA_NOT_LOADED"
    end
    
    if bank.Balance < amount then
        return false, "NOT_ENOUGH_BANK_GOLD"
    end
    
    bank.Balance -= amount
    character.Gold += amount
    
    CharacterManager.MarkDirty(player)
    
    return true, {
    Gold = character.Gold,
    BankBalance = bank.Balance
    }
end

return CurrencyService
