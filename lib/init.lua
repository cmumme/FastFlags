--[[
    FastFlags.lua
    @author typechecked
    @date 7/30/2023

    The support library for in-game fast flags.
]]--

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Dependencies
local Signal = require(script.Parent.Signal)

-- Constants
local FLAG_SKELETON = {
    Name = "Uninitialized",
    Value = false,
    Source = "Fallback",
    LastUpdated = os.time()
}
local FORMAT_VERSION = "v1"
local OVERRIDE_STORAGE_NAME = `FastFlags:{FORMAT_VERSION}:PluginOverride`

-- Assets
local PluginOverrideStorage = ReplicatedStorage:FindFirstChild(OVERRIDE_STORAGE_NAME)

-- Functions
local function assertf(c,m,...)
	if c then return end
	error(m:format(...),0)
end

local loading,ERR = {},{}
local function customRequire(mod)
    if(not _G.RanInCustomRequire) then return require(mod) end

	local cached = loading[mod]
	while cached == false do wait() cached = loading[mod] end
	assertf(cached ~= ERR,"Error while loading module")
	if cached then return cached end
	local s,e = loadstring(mod.Source)
	assertf(s,"Parsing error for %s: %s", mod:GetFullName(), tostring(e))
	--[[loading[mod] = false]]
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

-- Flag Library
local FlagLibrary = ReplicatedStorage:FindFirstChild("FlagLibrary") and customRequire(ReplicatedStorage.FlagLibrary) or customRequire(script.FlagLibrary)

--- @class FastFlags
--- The support library for in-game fast flags, toggleable from the studio plugin.
local FastFlags = { }

--- @prop Flags { [string]: FlagData }
--- @within FastFlags
--- Contains all active flag data
FastFlags.Flags = { }

--- @prop FlagDefinitions { [string]: FlagDefinition }
--- @within FastFlags
--- Contains all flag definitions loaded from ``FlagLibrary``.
FastFlags.FlagDefinitions = { }

--- @prop Environment Environment
--- @within FastFlags
--- What environment the game is currently running in. Defaults to Testing if not live or studio.
FastFlags.Environment = "Testing"

--- @prop FlagUpdated RBXScriptSignal<string>
--- @within FastFlags
--- A signal that is fired when a flag has updated. Fires with a string argument that defines what flag was updated.
FastFlags.FlagUpdated = Signal.new()

-- Types
--- @type Environment "Live" | "Testing" | "Studio"
--- @within FastFlags
--- What environment the game is currently running in. Default to Testing if not live or studio.
export type Environment = "Live" | "Testing" | "Studio"

--- @type FlagValue string | boolean | number
--- @within FastFlags
--- The valid types a fast flag can contain
export type FlagValue = string | boolean | number

--- @type FlagSource "PluginOverride" | "Fallback"
--- @within FastFlags
--- The valid sources for a fast flag's value
export type FlagSource = "PluginOverride" | "Fallback"

--- @interface FlagData
--- @within FastFlags
--- .Name string -- The computer-readable name of this flag.
--- .Value FlagValue -- The live value of the flag in the current environment.
--- .Source FlagSource -- Where this flags value was derived from.
--- .Definition FlagDefinition -- The definition that this flag was created from.
--- .LastUpdated number -- The unix epoch timestamp in seconds that this flag was last updated at.
export type FlagData = {
    Name: string,
    Value: FlagValue,
    Source: FlagSource,
    Definition: FlagDefinition,
    LastUpdated: number
}

--- @interface FlagDefinition
--- @within FastFlags
--- .Name string -- The human-readable display name for this flag
--- .Description string -- The description for this flag, shown on the studio plugin.
--- .OverrideEnvironments {Environment} -- In what environments the studio plugin override for this flag should be taken as the real value.
--- .Tags {string} -- Any additional tags to attach to this flag.
--- .FallbackValue FlagValue -- The fallback value when no value is able to be fetched from the studio plugin overrides.
--- The Luau definition format used in the ``FlagLibrary``.
export type FlagDefinition = {
    Name: string,
    Description: string,
    OverrideEnvironments: {Environment},
    Tags: {string},
    FallbackValue: FlagValue
}

-- Enums
local FlagSource = {
    PluginOverride = "PluginOverride",
    Fallback = "Fallback"
}
local Environment = {
    Default = "Testing",
    Live = "Live",
    Testing = "Testing",
    Studio = "Studio"
}

function FastFlags:UpdateFlag(FlagName: FlagData | string, NewValue: FlagValue, Source: FlagSource, Definition: FlagDefinition)
    if(typeof(FlagName) ~= "string") then FlagName = FlagName.Name end
    local Flag = self.Flags[FlagName] or table.clone(FLAG_SKELETON)
    Flag.Name = FlagName -- In the case we're creating a skeleton.
    Flag.Value = NewValue
    Flag.Source = Source
    Flag.Definition = Definition or Flag.Definition
    Flag.LastUpdated = os.time()

    self.Flags[FlagName] = Flag

    self.FlagUpdated:Fire(FlagName)
end

function FastFlags:GetEnvironment(): Environment
    local NewEnvironment = Environment.Default

    if(game.GameId == FlagLibrary.LiveExperienceId) then
        NewEnvironment = Environment.Live
    end
    if(RunService:IsStudio()) then
        NewEnvironment = Environment.Studio
    end

    self.Environment = NewEnvironment

    return NewEnvironment
end

function FastFlags:FetchLibrary()
    for FlagName: string, FlagDefinition: FlagDefinition in pairs(FlagLibrary.Flags) do
        self.FlagDefinitions[FlagName] = FlagDefinition

        self:UpdateFlag(FlagName, FlagDefinition.FallbackValue, FlagSource.Fallback, FlagDefinition)
    end
end

function FastFlags:VerifyPluginOverride(PluginOverrideObject: Configuration)
    local VersionAttribute = PluginOverrideObject:GetAttribute("FastFlag_FormatVersion")
    local ValueAttribute = PluginOverrideObject:GetAttribute("FastFlag_Value")
    local ValueType = typeof(ValueAttribute)

    if(VersionAttribute and VersionAttribute ~= FORMAT_VERSION) then warn(`The flag plugin override for {PluginOverrideObject.Name} is outdated. We will not attempt to use it.`) return false end
    if(ValueAttribute == nil) then warn(`The plugin override {ValueAttribute} is corrupt. It does not have a value attribute. We will not attempt to use it.`) return false end
    if(
        ValueType ~= "string" and
        ValueType ~= "boolean" and
        ValueType ~= "number"
    ) then warn(`The plugin override {ValueAttribute} is corrupt. It has a non-serializable value attribute. We will not attempt to use it.`) return false end

    return true
end

function FastFlags:ProcessPluginOverride(PluginOverrideObject: Configuration)
    if(not self:VerifyPluginOverride(PluginOverrideObject)) then return end

    local ValueAttribute = PluginOverrideObject:GetAttribute("FastFlag_Value")

    local Flag = self.Flags[PluginOverrideObject.Name]
    if(not Flag) then warn(`Could not find a flag for the {PluginOverrideObject.Name} plugin override. We will not attempt to use it.`) return end

    PluginOverrideObject:GetAttributeChangedSignal("FastFlag_Value"):Connect(function()
        self:UpdateFlag(Flag, PluginOverrideObject:GetAttribute("FastFlag_Value"), FlagSource.PluginOverride)
    end)

    self:UpdateFlag(Flag, ValueAttribute, FlagSource.PluginOverride)
end

function FastFlags:ApplyPluginOverrides()
    if(not PluginOverrideStorage) then return end

    for _, PluginOverrideObject: Configuration in pairs(PluginOverrideStorage:GetChildren()) do
        self:ProcessPluginOverride(PluginOverrideObject)
    end

    PluginOverrideStorage.ChildAdded:Connect(function(PluginOverrideObject: Instance)
        self:ProcessPluginOverride(PluginOverrideObject)
    end)

    PluginOverrideStorage.ChildRemoved:Connect(function(PluginOverrideObject: Instance)
        if(not self:VerifyPluginOverride(PluginOverrideObject)) then return end

        local Flag = self.Flags[PluginOverrideObject.Name]
        if(not Flag) then return end

        self:UpdateFlag(Flag, self.FlagDefinitions[PluginOverrideObject.Name].FallbackValue, FlagSource.Fallback)
    end)
end

function FastFlags:ListenForPluginOverrides()
    self:ApplyPluginOverrides()

    if(not PluginOverrideStorage) then
        local ListeningEvent
        ListeningEvent = ReplicatedStorage.ChildAdded:Connect(function(Child)
            if(Child.Name == OVERRIDE_STORAGE_NAME) then
                PluginOverrideStorage = Child
                self:ApplyPluginOverrides()
                ListeningEvent:Disconnect()
            end
        end)
    end
end

function FastFlags:Initialize()
    self:GetEnvironment()
    self:FetchLibrary()
    self:ListenForPluginOverrides()

    self.Initialized = os.time()
end

FastFlags:Initialize()

return FastFlags