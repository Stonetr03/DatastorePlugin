-- Stonetr03

local Config = require(script.Parent:WaitForChild("Config"));
local Fusion = Config.Fusion
local State = require(script.Parent:WaitForChild("State"));

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Ref = Fusion.Ref

local Module = {}

-- Values
local NameInput = Value();
local ScopeInput = Value();
local KeyInput = Value();
local InsertInput = Value();

local MenuOpen = Value(1)
local ErrorTxt = Value(0)
local ScrollSize = Value(0)

local InsertFunc
local InsertVis = Value(0)

local function CountTable(t)
    if typeof(t) ~= "table" then
        return 0
    end
    local c = 0
    for _,_ in pairs(t) do
        c+=1
    end
    return c
end
local function TableType(t: table)
    local array = true
    local dict = true

    if t == nil then
        t = {}
    end

    -- Check if table is array
    for i,_ in pairs(t) do
        if type(i) ~= "number" or math.floor(i) ~= i then
            array = false
            break
        end
    end

    -- Check if table is dictionary
    for i,_ in pairs(t) do
        if type(i) ~= "string" then
            dict = false
            break
        end
    end

    -- table type
    if array and dict then
        return 3 -- Empty Table
    elseif array then
        return 1 -- Array
    elseif dict then
        return 2 -- Dict
    else
        return 2 -- Mixed Table
    end
end

-- Ui

local function StringUi(i,v,Tab,Update,Start) -- i,v, Tab Spacing, Update Function, Start of Table
    local Color = Color3.new(1,1,1);
    if Start == true then
        Color = Config.IndexColors.key
    else
        if Config.IndexColors[typeof(i)] then
            Color = Config.IndexColors[typeof(i)]
        end
    end
    local vColor = Value(Color3.new(1,1,1));
    if Config.ValueColors[typeof(v)] then
        vColor:set(Config.ValueColors[typeof(v)])
    end

    local BgTransparency = Value(1)
    local DelFrameVis = Value(false)

    local Text = Value(tostring(v))
    local TextRef = Value()
    if typeof(v) == "string" then
        Text:set('"' .. Text:get() .. '"')
    end

    local Ui = New "Frame" {
        BackgroundTransparency = 1;
        Size = UDim2.new(1,0,0,25);
        Name = i;
        [Children] = {
            DelFrame = New "Frame" {
                Size = UDim2.new(1,0,0,25);
                BackgroundColor3 = Color3.new(0,0,0);
                BackgroundTransparency = 0.4;
                ZIndex = 5;
                Visible = Computed(function()
                    return DelFrameVis:get()
                end)
            };
            BG = New "Frame" {
                Size = UDim2.new(1,0,0,25);
                ZIndex = 2;
                [Event "MouseEnter"] = function()
                    BgTransparency:set(0.9);
                end;
                [Event "MouseLeave"] = function()
                    BgTransparency:set(1)
                end;
                BackgroundTransparency = Computed(function()
                    return BgTransparency:get()
                end);
            };
            Key = New "TextBox" {
                BackgroundTransparency = 1;
                Position = UDim2.new(0,22 + (Tab * Config.Spacing),0,0);
                Size = UDim2.new(0.5,-25,0,25);
                Text = tostring(i);
                TextColor3 = Color;
                TextSize = 20;
                TextEditable = false;
                ClearTextOnFocus = false;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 3;
            };
            Value = New "TextBox" {
                BackgroundTransparency = 1;
                Position = UDim2.new(0.5,10,0,0);
                Size = UDim2.new(0.5,-15,0,25);
                Text = Computed(function()
                    return Text:get()
                end);
                TextColor3 = Computed(function()
                    return vColor:get()
                end);
                TextSize = 20;
                TextEditable = true;
                ClearTextOnFocus = false;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 3;
                -- Edit Functions
                [Ref] = TextRef;
                [Event "FocusLost"] = function()
                    local NewText = TextRef:get().Text
                    local NewValue = nil
                    if NewText == "true" then
                        NewValue = true;
                    elseif NewText == "false" then
                        NewValue = false;
                    elseif NewText == "nil" then
                        NewValue = nil
                        DelFrameVis:set(true)
                    elseif tonumber(NewText) ~= nil then
                        NewValue = tonumber(NewText)
                    elseif NewText == "{}" then
                        NewValue = {}
                    else
                        -- String
                        if string.sub(NewText,1,1) == '"' and string.sub(NewText,string.len(NewText)) == '"' then
                            -- Remove "
                            NewValue = tostring(string.sub(NewText,2,(string.len(NewText) - 1)))
                        elseif string.sub(NewText,1,1) == "'" and string.sub(NewText,string.len(NewText)) == "'" then
                            -- Remove '
                            NewValue = tostring(string.sub(NewText,2,(string.len(NewText) - 1)))
                            NewText = '"' .. NewValue .. '"'
                        else
                            NewValue = tostring(NewText)
                            NewText = '"' .. NewValue .. '"'
                        end
                    end
                    Text:set(NewText)
                    if Config.ValueColors[typeof(NewValue)] then
                        vColor:set(Config.ValueColors[typeof(NewValue)])
                    end
                    -- Update Value
                    if v ~= NewValue then
                        v = NewValue
                        Update(NewValue)
                    end
                    if v ~= nil then
                        DelFrameVis:set(false)
                    end
                end
            };
            Delete = New "ImageButton" {
                BackgroundColor3 = Color3.new(0,0,0);
                BackgroundTransparency = 0.85;
                AnchorPoint = Vector2.new(1,0);
                Position = UDim2.new(1,-5,0,0);
                Size = UDim2.new(0,25,0,25);
                Image = "rbxassetid://11293981586";
                ZIndex = 4;
                Visible = Computed(function()
                    if BgTransparency:get() == 1 then
                        return false
                    else
                        return true
                    end
                end);
                [Event "MouseButton1Up"] = function()
                    local NewText = "nil"
                    Text:set(NewText)
                    -- Update Value
                    v = nil
                    DelFrameVis:set(true)
                    Update(nil)
                    if Config.ValueColors[typeof(nil)] then
                        vColor:set(Config.ValueColors[typeof(nil)])
                    end
                end
            };
        }
    }

    return Ui,function()
        Text:set("nil")
        -- Update Value
        v = nil
        DelFrameVis:set(true)
        if Config.ValueColors[typeof(nil)] then
            vColor:set(Config.ValueColors[typeof(nil)])
        end
        return
    end
end
local function TableUi(i,v,Tab,Update,SetParentSize,Start)
    local Color = Color3.new(1,1,1);
    if Start == true then
        Color = Config.IndexColors.key
    else
        if Config.IndexColors[typeof(i)] then
            Color = Config.IndexColors[typeof(i)]
        end
    end
    local vColor = Value(Color3.new(1,1,1));
    if Config.ValueColors[typeof(v)] then
        vColor:set(Config.ValueColors[typeof(v)])
    end

    local RenderingValues = Value(v)
    local Count = CountTable(v)

    local vText = Value("table: ...")
    if Count == 0 then
        vText:set("table: {}")
    end

    local BgTransparency = Value(1)
    local Open = Value(false)
    local DelFrameVis = Value(false)

    local ChildrenSize = Value(0)

    local Dels = {} -- Delete Functions
    local Ui = New "Frame" {
        BackgroundTransparency = 1;
        Size = Computed(function()
            if Open:get() == true then
                return UDim2.new(1,0,0,25 + (Count * 25) + ChildrenSize:get())
            else
                return UDim2.new(1,0,0,25)
            end
        end);
        Name = i;
        [Children] = {
            DelFrame = New "Frame" {
                Size = UDim2.new(1,0,0,25);
                BackgroundColor3 = Color3.new(0,0,0);
                BackgroundTransparency = 0.4;
                ZIndex = 5;
                Visible = Computed(function()
                    return DelFrameVis:get()
                end)
            };
            BG = New "Frame" {
                Size = UDim2.new(1,0,0,25);
                ZIndex = 2;
                [Event "MouseEnter"] = function()
                    BgTransparency:set(0.9);
                end;
                [Event "MouseLeave"] = function()
                    BgTransparency:set(1)
                end;
                BackgroundTransparency = Computed(function()
                    return BgTransparency:get()
                end);
            };
            Key = New "TextBox" {
                BackgroundTransparency = 1;
                Position = UDim2.new(0,22 + (Tab * Config.Spacing),0,0);
                Size = UDim2.new(0.5,-25,0,25);
                Text = tostring(i);
                TextColor3 = Color;
                TextSize = 20;
                TextEditable = false;
                ClearTextOnFocus = false;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 3;
            };
            Value = New "TextBox" {
                BackgroundTransparency = 1;
                Position = UDim2.new(0.5,10,0,0);
                Size = UDim2.new(0.5,-15,0,25);
                Text = Computed(function()
                    return vText:get()
                end);
                TextColor3 = Computed(function()
                    return vColor:get()
                end);
                TextSize = 20;
                TextEditable = false;
                ClearTextOnFocus = false;
                TextXAlignment = Enum.TextXAlignment.Left;
                -- Tables Not Editable.
                ZIndex = 3;
            };
            Dropdown = New "ImageButton" {
                BackgroundTransparency = 1;
                Size = UDim2.new(0,25,0,25);
                Position = UDim2.new(0,0 + (Tab * Config.Spacing),0,0);
                Image = "http://www.roblox.com/asset/?id=13611120673";
                Rotation = Computed(function()
                    if Open:get() == true then
                        return 0
                    else
                        return -90
                    end
                end);
                [Event "MouseButton1Up"] = function()
                    Open:set(not Open:get());

                    if Open:get() == true then
                        SetParentSize((Count * 25) + ChildrenSize:get())
                    else
                        SetParentSize(-((Count * 25)+ChildrenSize:get()))
                    end

                end;
                ZIndex = 3;
            };
            Line = New "Frame" {
                BackgroundTransparency = 0;
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Position = UDim2.new(0,11 + (Tab * Config.Spacing),0,25);
                Size = UDim2.new(0,2,1,-25);
                ZIndex = 3;
            };
            Container = New "Frame" {
                BackgroundTransparency = 1;
                Position = UDim2.new(0,0,0,25);
                Size = UDim2.new(1,0,1,-25);
                Visible = Open;
                [Children] = {
                    UIListLayout = New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Vertical;
                        HorizontalAlignment = Enum.HorizontalAlignment.Left;
                        SortOrder = Enum.SortOrder.Name;
                        VerticalAlignment = Enum.VerticalAlignment.Top;
                    };
                    List = Fusion.ForPairs(RenderingValues,function(ind,val)
                        local ReturnUi
                        if typeof(val) == "table" then
                            local NewUi,f = TableUi(ind,val,Tab+1,function(NewValue)
                                -- Update Value
                                if v == nil then
                                    v = {}
                                    DelFrameVis:set(false)
                                    vText:set("table: ...")
                                end
                                v[ind] = NewValue
                                Update(v)
                            end,function(Size: number)
                                -- Update Size
                                ChildrenSize:set(ChildrenSize:get() + Size)
                                SetParentSize(Size)
                            end,false)
                            if typeof(f) == "function" then
                                table.insert(Dels,f)
                            end
                            ReturnUi = NewUi
                        else
                            local NewUi,f = StringUi(ind,val,Tab+1,function(NewValue)
                                -- Update Value
                                if v == nil then
                                    v = {}
                                    DelFrameVis:set(false)
                                    vText:set("table: ...")
                                end
                                v[ind] = NewValue
                                Update(v)
                                if typeof(NewValue) == "table" then
                                    RenderingValues:set(v)
                                end
                            end,false)
                            if typeof(f) == "function" then
                                table.insert(Dels,f)
                            end
                            ReturnUi = NewUi
                        end
                        return ind, ReturnUi
                    end,Fusion.cleanup)
                }
            };
            Delete = New "ImageButton" {
                BackgroundColor3 = Color3.new(0,0,0);
                BackgroundTransparency = 0.85;
                AnchorPoint = Vector2.new(1,0);
                Position = UDim2.new(1,-5,0,0);
                Size = UDim2.new(0,25,0,25);
                Image = "rbxassetid://11293981586";
                ZIndex = 4;
                Visible = Computed(function()
                    if BgTransparency:get() == 1 then
                        return false
                    else
                        return true
                    end
                end);
                [Event "MouseButton1Up"] = function()
                    local NewText = "nil"
                    vText:set(NewText)
                    -- Update Value
                    v = nil
                    DelFrameVis:set(true)
                    Update(nil)
                    for _,f in pairs(Dels) do
                        f()
                    end
                end;
            };
            Add = New "ImageButton" {
                BackgroundColor3 = Color3.new(0,0,0);
                BackgroundTransparency = 0.85;
                AnchorPoint = Vector2.new(1,0);
                Position = UDim2.new(1,-30,0,0);
                Size = UDim2.new(0,25,0,25);
                Image = "rbxassetid://11295291707";
                ZIndex = 4;
                Visible = Computed(function()
                    if BgTransparency:get() == 1 then
                        return false
                    else
                        return true
                   end
                end);
                [Event "MouseButton1Up"] = function()
                    InsertFunc = function(t: number,index: string) -- 0:cancel, 1:first, 2:last, 3:custom;index
                        if t == 0 then
                            return
                        elseif t == 1 then
                            Count+=1
                            if Open:get() == true then
                                SetParentSize(25)
                                Open:set(false)
                                Open:set(true)
                            end
                            if v == nil then
                                v = {}
                                DelFrameVis:set(false)
                            end
                            vText:set("table: ...")
                            if #v > 0 then
                                -- Bump all
                                local newTab = {}
                                for j,k in pairs(v) do
                                    if typeof(j) == "number" then
                                        newTab[j+1] = k
                                    else
                                        newTab[j] = k
                                    end
                                end
                                v = newTab
                            end
                            v[1] = "value"
                            Update(v)
                        elseif t == 2 then
                            Count+=1
                            if Open:get() == true then
                                SetParentSize(25)
                                Open:set(false)
                                Open:set(true)
                            end
                            if v == nil then
                                v = {}
                                DelFrameVis:set(false)
                            end
                            vText:set("table: ...")
                            -- Get Max Value
                            local max = 0
                            for j,_ in pairs(v) do
                                if typeof(j) == "number" and j > max then
                                    max = j
                                end
                            end
                            v[max+1] = "value"
                            Update(v)
                        elseif t == 3 then
                            if v[index] ~= nil then
                                return
                            end
                            Count+=1
                            if Open:get() == true then
                                SetParentSize(25)
                                Open:set(false)
                                Open:set(true)
                            end
                            if v == nil then
                                v = {}
                                DelFrameVis:set(false)
                            end
                            vText:set("table: ...")
                            v[index] = "value"
                            Update(v)
                        end
                        RenderingValues:set(v)
                    end
                    InsertVis:set(TableType(v))
                end
            };
        }
    }

    return Ui,function()
        for _,f in pairs(Dels) do
            f()
        end

        vText:set("nil")
        -- Update Value
        v = nil
        DelFrameVis:set(true)
        if Config.ValueColors[typeof(nil)] then
            vColor:set(Config.ValueColors[typeof(nil)])
        end
        return
    end
end

function Module.MainUi()
    return New "Frame" {
        Size = UDim2.new(1,0,1,0);
        BackgroundColor3 = Color3.new(0,0,0);
        [Children] = {
            -- Connect Frame
            Connect = New "Frame" {
                Size = UDim2.new(1,0,1,0);
                BackgroundTransparency = 1;
                Visible = Computed(function()
                    if MenuOpen:get() == 1 then
                        return true
                    else
                        return false
                    end
                end);
                [Children] = {
                    Title = New "TextLabel" {
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,30);
                        Text = "Connect to Datastore";
                        TextColor3 = Color3.new(1,1,1);
                        TextSize = 20;
                    };
                    DataStoreInput = New "TextBox" {
                        BackgroundTransparency = 0.9;
                        BackgroundColor3 = Color3.new(1,1,1);
                        ClearTextOnFocus = false;
                        Position = UDim2.new(0,5,0,30);
                        Size = UDim2.new(1,-10,0,30);
                        TextEditable = true;
                        PlaceholderText = "Name";
                        Text = "";
                        PlaceholderColor3 = Color3.fromRGB(209,209,209);
                        TextColor3 = Color3.new(1,1,1);
                        TextSize = 20;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        [Ref] = NameInput;
                        [Children] = {
                            New "UIPadding" {
                                PaddingLeft = UDim.new(0,5);
                                PaddingRight = UDim.new(0,5);
                            };
                            New "UIStroke" {
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                Color = Color3.new(1,1,1);
                                Transparency = 0.8;
                                Thickness = 1;
                            }
                        }
                    };
                    Scope = New "TextBox" {
                        BackgroundTransparency = 0.9;
                        BackgroundColor3 = Color3.new(1,1,1);
                        ClearTextOnFocus = false;
                        Position = UDim2.new(0,5,0,68);
                        Size = UDim2.new(1,-10,0,30);
                        TextEditable = true;
                        PlaceholderText = "Scope";
                        Text = "";
                        PlaceholderColor3 = Color3.fromRGB(209,209,209);
                        TextColor3 = Color3.new(1,1,1);
                        TextSize = 20;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        [Ref] = ScopeInput;
                        [Children] = {
                            New "UIPadding" {
                                PaddingLeft = UDim.new(0,5);
                                PaddingRight = UDim.new(0,5);
                            };
                            New "UIStroke" {
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                Color = Color3.new(1,1,1);
                                Transparency = 0.8;
                                Thickness = 1;
                            }
                        }
                    };
                    Connect = New "TextButton" {
                        BackgroundTransparency = 0.85;
                        BackgroundColor3 = Color3.new(1,1,1);
                        Position = UDim2.new(0,5,0,106);
                        Size = UDim2.new(1,-10,0,30);
                        Text = "Connect";
                        TextColor3 = Color3.new(1,1,1);
                        TextSize = 20;
                        [Event "MouseButton1Up"] = function()
                            if NameInput:get().Text == "" then
                                ErrorTxt:set(400)
                            else
                                ErrorTxt:set(0)
                                local s = State:GetDataStore(NameInput:get().Text, ScopeInput:get().Text, {Error = ErrorTxt})
                                if s == true then
                                    -- Next
                                    MenuOpen:set(2)
                                end
                            end
                        end
                    };
                    Error = New "TextLabel" {
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0,0,0,142);
                        Size = UDim2.new(1,0,1,-142);
                        Text = Computed(function()
                            return Config.Errors[ErrorTxt:get()]
                        end);
                        TextColor3 = Color3.new(1,1,1);
                        TextSize = 20;
                        TextWrapped = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Top;
                        [Children] = {
                            New "UIPadding" {
                                PaddingLeft = UDim.new(0,5);
                                PaddingRight = UDim.new(0,5);
                            }
                        }
                    };
                    Version = New "TextLabel" {
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,20);
                        AnchorPoint = Vector2.new(0,1);
                        Position = UDim2.new(0,3,1,0);
                        Text = Config.Version;
                        TextColor3 = Color3.fromRGB(122, 122, 122);
                        TextSize = 15;
                        TextXAlignment = Enum.TextXAlignment.Left;
                    };
                }
            };
            -- Data Frame
            DataFrame = New "Frame" {
                Size = UDim2.new(1,0,1,0);
                BackgroundTransparency = 1;
                Visible = Computed(function()
                    if MenuOpen:get() == 2 then
                        return true
                    else
                        return false
                    end
                end);
                [Children] = {
                    Topbar = New "Frame" {
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,40);
                        [Children] = {
                            Key = New "TextBox" {
                                BackgroundTransparency = 0.9;
                                BackgroundColor3 = Color3.new(1,1,1);
                                ClearTextOnFocus = false;
                                Position = UDim2.new(0,40,0,5);
                                Size = UDim2.new(1,-150,0,30);
                                TextEditable = true;
                                PlaceholderText = "Key";
                                Text = "";
                                PlaceholderColor3 = Color3.fromRGB(209,209,209);
                                TextColor3 = Color3.new(1,1,1);
                                TextSize = 20;
                                TextXAlignment = Enum.TextXAlignment.Left;
                                [Ref] = KeyInput;
                                [Event "FocusLost"] = function()
                                    -- Get Key
                                    if State.CurrentKey:get() ~= KeyInput:get().Text then
                                        State:GetKey(KeyInput:get().Text)
                                    end
                                end;
                                [Children] = {
                                    New "UIPadding" {
                                        PaddingLeft = UDim.new(0,5);
                                        PaddingRight = UDim.new(0,5);
                                    };
                                    New "UIStroke" {
                                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                        Color = Color3.new(1,1,1);
                                        Transparency = 0.8;
                                        Thickness = 1;
                                    }
                                }
                            };

                            Back = New "ImageButton" {
                                BackgroundTransparency = 0.85;
                                BackgroundColor3 = Color3.new(1,1,1);
                                Position = UDim2.new(0,5,0,5);
                                Size = UDim2.new(0,30,0,30);
                                Image = "rbxassetid://11422143469";
                                [Event "MouseButton1Up"] = function()
                                    MenuOpen:set(1)
                                    State:RemoveDataStore()
                                    KeyInput:get().Text = "";
                                end;
                            };
                            Delete = New "ImageButton" {
                                AnchorPoint = Vector2.new(1,0);
                                BackgroundTransparency = 0.85;
                                BackgroundColor3 = Color3.new(1,1,1);
                                Position = UDim2.new(1,-5,0,5);
                                Size = UDim2.new(0,30,0,30);
                                Image = "rbxassetid://11326877050";
                                [Event "MouseButton1Up"] = function()
                                    State:UpdateKey(nil)
                                end;
                            };
                            Save = New "ImageButton" {
                                AnchorPoint = Vector2.new(1,0);
                                BackgroundTransparency = 0.85;
                                BackgroundColor3 = Color3.new(1,1,1);
                                Position = UDim2.new(1,-40,0,5);
                                Size = UDim2.new(0,30,0,30);
                                Image = Computed(function()
                                    if State.IsSaving:get() == true then
                                        return ""
                                    else
                                        return "rbxassetid://11419703493"
                                    end
                                end);
                                ImageColor3 = Computed(function()
                                    if State.SaveVis:get() == true then
                                        return Color3.new(1,1,1);
                                    else
                                        return Color3.fromRGB(129, 129, 129)
                                    end
                                end);
                                [Event "MouseButton1Up"] = function()
                                    State:SaveKey()
                                end;
                                [Children] = New "ImageLabel" {
                                    Size = UDim2.new(1,0,1,0);
                                    BackgroundTransparency = 1;
                                    Image = "rbxassetid://11963357970";
                                    Visible = State.IsSaving;
                                    Rotation = Computed(function()
                                        local angle = State.SaveSpin:get() * 220 -- speed
                                        angle %= 360
                                        return -angle
                                    end);
                                }
                            };
                            Reload = New "ImageButton" {
                                AnchorPoint = Vector2.new(1,0);
                                BackgroundTransparency = 0.85;
                                BackgroundColor3 = Color3.new(1,1,1);
                                Position = UDim2.new(1,-75,0,5);
                                Size = UDim2.new(0,30,0,30);
                                Image = "rbxassetid://11293978505";
                                [Event "MouseButton1Up"] = function()
                                    State:GetKey(KeyInput:get().Text)
                                end
                            }
                        }
                    };
                    ScrollingFrame = New "ScrollingFrame" {
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0,0,0,40);
                        Size = UDim2.new(1,0,1,-40);
                        BottomImage = "";
                        TopImage = "";
                        MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
                        ScrollingDirection = Enum.ScrollingDirection.Y;
                        ScrollBarThickness = 5;
                        ScrollBarImageColor3 = Color3.new(1,1,1);
                        CanvasSize = Computed(function()
                            return UDim2.new(0,0,0,ScrollSize:get())
                        end);
                        [Children] = {
                            UIListLayout = New "UIListLayout" {
                                FillDirection = Enum.FillDirection.Vertical;
                                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                                SortOrder = Enum.SortOrder.Name;
                                VerticalAlignment = Enum.VerticalAlignment.Top;
                            };
                            List = Fusion.ForPairs(State.CurrentData,function(i,v)
                                local Ui
                                if typeof(v) == "table" then
                                    Ui = TableUi(i,v,0,function(NewValue)
                                        -- Update Value
                                        State:UpdateKey(NewValue)
                                    end,function(Size: number)
                                        -- Update Size
                                        ScrollSize:set( ScrollSize:get() + Size )
                                    end,true,function(f)

                                    end)
                                else
                                    Ui = StringUi(i,v,0,function(NewValue)
                                        -- Update Value
                                        State:UpdateKey(NewValue)
                                    end,true,function(f)

                                    end)
                                end
                                ScrollSize:set(25)
                                return i, Ui
                            end,Fusion.cleanup)
                        }
                    };
                    Blackout = New "TextLabel" {
                        BackgroundTransparency = 0;
                        BackgroundColor3 = Color3.new(0,0,0);
                        Position = UDim2.new(0,0,0,40);
                        Size = UDim2.new(1,0,1,-40);
                        Text = Computed(function()
                            return "No Data Found"
                        end);
                        TextColor3 = Color3.new(1,1,1);
                        TextSize = 20;
                        TextWrapped = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Top;
                        Visible = Computed(function()
                            return State.BlackoutVis:get()
                        end);
                        ZIndex = 8;
                        [Children] = {
                            New "UIPadding" {
                                PaddingLeft = UDim.new(0,5);
                                PaddingRight = UDim.new(0,5);
                            }
                        }
                    };
                    Insert = New "TextButton" {
                        AutoButtonColor = false;
                        BackgroundColor3 = Color3.new(0,0,0);
                        BackgroundTransparency = 0.7;
                        Size = UDim2.new(1,0,1,0);
                        Text = "";
                        ZIndex = 6;
                        Visible = Computed(function()
                            if InsertVis:get() == 0 then
                                return false
                            end
                            return true
                        end);
                        [Event "MouseButton1Up"] = function()
                            -- Cancel
                            if typeof(InsertFunc) == "function" then
                                InsertFunc(0)
                            end
                            InsertVis:set(0)
                            InsertFunc = nil
                        end;

                        [Children] = {
                            New "Frame" {
                                AnchorPoint = Vector2.new(0.5,0.5);
                                BackgroundTransparency = 1;
                                Position = UDim2.new(0.5,0,0.5,0);
                                Size = UDim2.new(0.2,0,0,65);

                                [Children] = {
                                    New "UIListLayout" {
                                        Padding = UDim.new(0,5);
                                        SortOrder = Enum.SortOrder.LayoutOrder;
                                        VerticalAlignment = Enum.VerticalAlignment.Center;
                                    };
                                    New "UISizeConstraint" {
                                        MinSize = Vector2.new(150,0);
                                    };
                                    -- Insert First
                                    New "TextButton" {
                                        BackgroundColor3 = Color3.fromRGB(25,25,25);
                                        Font = Enum.Font.SourceSans;
                                        LayoutOrder = 1;
                                        Size = UDim2.new(1,0,0,30);
                                        Text = "Insert First";
                                        TextColor3 = Color3.new(1,1,1);
                                        TextSize = 20;
                                        TextWrapped = false;
                                        ZIndex = 7;
                                        [Event "MouseButton1Up"] = function()
                                            -- Insert
                                            if typeof(InsertFunc) == "function" then
                                                InsertFunc(1)
                                            end
                                            InsertVis:set(0)
                                            InsertFunc = nil
                                        end;
                                        Visible = Computed(function()
                                            if InsertVis:get() == 1 or InsertVis:get() == 3 then
                                                return true
                                            end
                                            return false
                                        end);
                                    };
                                    -- Insert Last
                                    New "TextButton" {
                                        BackgroundColor3 = Color3.fromRGB(25,25,25);
                                        Font = Enum.Font.SourceSans;
                                        LayoutOrder = 2;
                                        Size = UDim2.new(1,0,0,30);
                                        Text = "Insert Last";
                                        TextColor3 = Color3.new(1,1,1);
                                        TextSize = 20;
                                        TextWrapped = false;
                                        ZIndex = 7;
                                        [Event "MouseButton1Up"] = function()
                                            -- Insert
                                            if typeof(InsertFunc) == "function" then
                                                InsertFunc(2)
                                            end
                                            InsertVis:set(0)
                                            InsertFunc = nil
                                        end;
                                        Visible = Computed(function()
                                            if InsertVis:get() == 1 or InsertVis:get() == 3 then
                                                return true
                                            end
                                            return false
                                        end);
                                    };
                                    -- Index
                                    Key = New "TextBox" {
                                        BackgroundColor3 = Color3.fromRGB(25,25,25);
                                        ClearTextOnFocus = false;
                                        Size = UDim2.new(1,0,0,30);
                                        TextEditable = true;
                                        PlaceholderText = "Index";
                                        Text = "";
                                        PlaceholderColor3 = Color3.fromRGB(209,209,209);
                                        TextColor3 = Color3.new(1,1,1);
                                        TextSize = 20;
                                        TextXAlignment = Enum.TextXAlignment.Center;
                                        LayoutOrder = 3;
                                        ZIndex = 7;
                                        [Ref] = InsertInput;
                                        [Event "FocusLost"] = function()
                                            -- Set Index
                                            if typeof(InsertFunc) == "function" and InsertInput:get().Text ~= "" then
                                                local txt = InsertInput:get().Text
                                                if InsertVis:get() == 1 then
                                                    if tonumber(txt) == nil or tonumber(txt) <= 0 then
                                                        InsertInput:get().Text = ""
                                                        InsertVis:set(0)
                                                        InsertFunc = nil
                                                        return
                                                    else
                                                        txt = tonumber(txt)
                                                    end
                                                end
                                                InsertFunc(3,txt)
                                                InsertInput:get().Text = ""
                                            end
                                            InsertVis:set(0)
                                            InsertFunc = nil
                                        end;
                                        [Children] = {
                                            New "UIPadding" {
                                                PaddingLeft = UDim.new(0,5);
                                                PaddingRight = UDim.new(0,5);
                                            };
                                            New "UIStroke" {
                                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                                Color = Color3.new(1,1,1);
                                                Transparency = 0.8;
                                                Thickness = 1;
                                            }
                                        };
                                        Visible = Computed(function()
                                            if InsertVis:get() == 2 or InsertVis:get() == 3 or InsertVis:get() == 1 then
                                                return true
                                            end
                                            return false
                                        end);
                                    };

                                }
                            }
                        }
                    }
                }
            };
        }
    }
end

return Module
