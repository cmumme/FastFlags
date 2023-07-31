local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
--[[
    Menu.lua
    @author typechecked
    @date 7/30/2023

    The plugin menu code for SGH's fast flag system.
]]--

-- Dependencies
local Signal = require(script.Parent.Dependencies.Signal)
local Fusion = require(script.Parent.Dependencies.Fusion)
local UI = require(script.UI)
local Plugin = script:FindFirstAncestorWhichIsA("Plugin")

-- Fusion
local Value = Fusion.Value

-- Variables
local Menu = {
    Toggled = Signal.new(),
    IsOpen = false,
    Widget = Plugin:CreateDockWidgetPluginGui("FastFlags:Menu", DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Float,
        false,
        false,
        400,
        300,
        200,
        150
    ))
}

-- Functions
local function assertf(c,m,...)
	if c then return end
	error(m:format(...),0)
end

local loading,ERR = {},{}
local function customRequire(mod)
	local cached = loading[mod]
	while cached == false do wait() cached = loading[mod] end
	assertf(cached ~= ERR,"Error while loading module")
	if cached then return cached end
	local s,e = loadstring(mod.Source)
	assertf(s,"Parsing error for %s: %s", mod:GetFullName(), tostring(e))
	--loading[mod] = false
	local env = setmetatable({
		script = mod;
		require = customRequire;
        _G = {
            RanInCustomRequire = true
        }
	},{__index=getfenv()})
	s,e = pcall(setfenv(s,env))
	if not s then --[[loading[mod] = ERR]] end
	assertf(s,"Running error for %s: %s", mod:GetFullName(), tostring(e))
	--[[loading[mod] = e]] return e
end

function Menu:Open()
    if(self.IsOpen) then return end
    self.Widget.Enabled = true

    self.IsOpen = true
    self.Toggled:Fire(self.IsOpen)
end

function Menu:Close()
    if(not self.IsOpen) then return end

    self.Widget.Enabled = false

    self.IsOpen = false
    self.Toggled:Fire(self.IsOpen)
end

function Menu:ToggleMenu()
    if(not self.IsOpen) then
        self:Open()
    else
        self:Close()
    end
end

function Menu:UpdateSupportLibrary()
    local SupportLibrary = CollectionService:GetTagged("FastFlagsSupportLibrary")[1]

    if(SupportLibrary and SupportLibrary:IsA("ModuleScript")) then
        local newRequire = customRequire(SupportLibrary)

        repeat
            task.wait()
        until newRequire.Initialized

        self.SupportLibraryState:set(newRequire)
    else
        self.SupportLibraryState:set(nil)
    end
end

function Menu:ListenForSupportLibrary()
    self:UpdateSupportLibrary()
    coroutine.wrap(function()
        while task.wait(5) and not self.SupportLibraryState:get() do
            self:UpdateSupportLibrary()
        end
    end)()
end

function Menu:SetupUI()
    self.SupportLibraryState = Value(nil)
    self.UI = UI {
        SupportLibrary = self.SupportLibraryState,
        Menu = self
    }
    self.UI.Parent = self.Widget
end

function Menu:SetupWidget()
    self.Widget.Name = "Fast Flags"
    self.Widget.Title = "Fast Flags"

    self.Widget:BindToClose(function()
        self:Close()
    end)
end

function Menu:Initialize()
    self:SetupWidget()
    self:SetupUI()
    self:ListenForSupportLibrary()
end

Menu:Initialize()

return Menu