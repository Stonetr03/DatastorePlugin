-- Stonetr03

local Config = require(script.Parent:WaitForChild("Config"));
local Fusion = Config.Fusion
local DataStore = require(script.Parent:WaitForChild("Datastore"))

local Value = Fusion.Value

local Module = {
    CurrentDataStore = Value("");
    CurrentScope = Value("");
    CurrentKey = Value("");

    BlackoutVis = Value(false);
    SaveVis = Value(false);

    CurrentData = Value({});
    OriginalData = Value({});
}

function Module:RemoveDataStore()
    Module.CurrentDataStore:set("");
    Module.CurrentScope:set("");
    Module.CurrentData:set({});
    Module.OriginalData:set({});
    Module.BlackoutVis:set(false)
    Module.SaveVis:set(false)
    DataStore:Cleanup()
    return
end

function Module:GetDataStore(Name,Scope,props)
    Module:RemoveDataStore()

    Module.CurrentDataStore:set(Name);
    Module.CurrentScope:set(Scope);

    if Scope == "" then
        Scope = nil
    end

    local s = DataStore:GetDataStore(Name,Scope)
    if s == true then
        -- Next Ui
        return true
    elseif s == false then
        -- Error Ui
        props.Error:set(401)
        return false
    end

end

-- ProcessTable and CloneData are used to Desync the tables given from Datastore Function
local function ProcessTable(t)
    local NewTab = {}
    for i,v in pairs(t) do
        if typeof(v) == "table" then
            NewTab[i] = table.clone(ProcessTable(v))
        else
            NewTab[i] = v
        end
    end
    return NewTab
end
local function CloneData(Data)
    if typeof(Data) == "table" then
        return ProcessTable(table.clone(Data))
    else
        return Data
    end
end

local function CompareTables(a,b)
    local Same = true
    for i,v in pairs(a) do
        if typeof(v) == "table" then
            if typeof(b[i]) == "table" then
                -- Both Tables
                if CompareTables(a[i],b[i]) == false then
                    Same = false
                end
            else
                Same = false
            end
        else
            if b[i] and b[i] == v then else
                Same = false
            end
        end
    end
    for i,v in pairs(b) do
        if typeof(v) == "table" then
            if typeof(a[i]) == "table" then
                -- Both Tables
                if CompareTables(a[i],b[i]) == false then
                    Same = false
                end
            else
                Same = false
            end
        else
            if a[i] and a[i] == v then else
                Same = false
            end
        end
    end
    return Same
end

function Module:GetKey(Key)
    local Data = DataStore:GetKey(Key)
    Module.CurrentKey:set(Key)
    if Data == nil then
        -- No Data
        Module.BlackoutVis:set(true)
    else
        Module.OriginalData:set({[Key] = CloneData(Data)})
        Module.CurrentData:set({[Key] = CloneData(Data)})
    end
end

function Module:UpdateKey(NewValue)
    if Module.CurrentKey:get() ~= "" then
        if NewValue == nil then
            -- Delete Key
            Module.CurrentData:set({[Module.CurrentKey:get()] = nil})
            Module.BlackoutVis:set(true)
        else
            -- Update Key
            Module.CurrentData:set({[Module.CurrentKey:get()] = NewValue})
        end

        -- Save Light
        Module.SaveVis:set(not CompareTables(Module.CurrentData:get(),Module.OriginalData:get()))

    end
end

function Module:SaveKey()
    if Module.CurrentKey:get() ~= "" and CompareTables(Module.CurrentData:get(),Module.OriginalData:get()) == false then
        -- Save Data
        if Module.CurrentData:get()[Module.CurrentKey:get()] == nil then
            -- Remove Async
            
        else
            DataStore:SaveKey(Module.CurrentKey:get(),Module.CurrentData:get()[Module.CurrentKey:get()])
        end
    end
end

return Module
