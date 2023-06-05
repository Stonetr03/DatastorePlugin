-- Stonetr03

local Module = {}

local DataStoreService = game:GetService("DataStoreService")
local DataStore

function Module:GetDataStore(Name,Scope)
    local s,e = pcall(function()
        DataStore = DataStoreService:GetDataStore(Name,Scope)
    end)
    if s and DataStore then
        return true
    else
        warn("Error Getting Datastore:",e)
        return false
    end
end

function Module:Cleanup()
    DataStore = nil
    return true
end

function Module:GetKey(Key)
    local Data
    local s,e = pcall(function()
        Data = DataStore:GetAsync(Key)
    end)
    if s then
        return Data
    else
        warn("Error getting data:",e)
        return nil
    end
end

function Module:SaveKey(Key,Data)
    local s,e = pcall(function()
        DataStore:SetAsync(Key,Data)
    end)
    if not s then
        warn("Error saving data:",e)
    end
end

function Module:RemoveKey(Key)
    local s,e = pcall(function()
        DataStore:RemoveAsync(Key)
    end)
    if not s then
        warn("Error deleting data:",e)
    end
end

return Module
