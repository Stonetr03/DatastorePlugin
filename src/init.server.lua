-- Stonetr03

local plugin = plugin

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false, false,
	350, 250,
	200, 200
)
local MainWidget = plugin:CreateDockWidgetPluginGui("Datastore Editor", widgetInfo)
MainWidget.Title = "Datastore Editor"
MainWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local Toolbar = plugin:CreateToolbar("Datastore Editor")

local Button = Toolbar:CreateButton("Datastore Editor","Made by Stonetr03 Studios","http://www.roblox.com/asset/?id=13657060127")
Button.ClickableWhenViewportHidden = true
Button.Click:Connect(function()
	MainWidget.Enabled = not MainWidget.Enabled
end)

-- UI
local Fusion = require(script:WaitForChild("Packages"):WaitForChild("Fusion"))

local New = Fusion.New
local Children = Fusion.Children

local Ui = require(script:WaitForChild("Ui"))

New "Frame" {
    Parent = MainWidget;
    Size = UDim2.new(1,0,1,0);
    BackgroundTransparency = 1;
    [Children] = {
        Ui.MainUi {}
    }
}
