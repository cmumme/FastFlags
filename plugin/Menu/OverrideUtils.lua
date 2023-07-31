--[[
    OverrideUtils.lua
    @author typechecked
    @date 7/30/2023

    Utilities for interacting with the fast flags plugin override folder.
]]--

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local FORMAT_VERSION = "v1"
local OVERRIDE_STORAGE_NAME = `FastFlags:{FORMAT_VERSION}:PluginOverride`

local OverrideUtils = { }

function OverrideUtils:GetFolder()
    local Folder = ReplicatedStorage:FindFirstChild(OVERRIDE_STORAGE_NAME) or Instance.new("Folder")
    Folder.Name = OVERRIDE_STORAGE_NAME
    Folder.Parent = ReplicatedStorage

    return Folder
end

function OverrideUtils:CreateOverride(Name: string, Value: any)
    local Override = Instance.new("Configuration")
    Override:SetAttribute("FastFlag_FormatVersion", FORMAT_VERSION)
    Override:SetAttribute("FastFlag_Value", Value)
    Override.Name = Name
    Override.Parent = OverrideUtils:GetFolder()

    return Override
end

function OverrideUtils:GetValue(Name: string)
    local Override = self:GetOverride(Name)

    return Override and Override:GetAttribute("FastFlag_Value") or nil
end

function OverrideUtils:SetOverride(Name: string, Value: any)
    local Override = self:GetOverride(Name, true, Value)

    Override:SetAttribute("FastFlag_Value", Value)
end

function OverrideUtils:DeleteOverride(Name: string)
    local Override = self:GetOverride(Name)

    if(Override) then
        Override:Destroy()
    end
end

function OverrideUtils:GetOverride(Name: string, CreateIfNotExists: boolean, DefaultValue: any)
    return self:GetFolder():FindFirstChild(Name) or (CreateIfNotExists and self:CreateOverride(Name, DefaultValue) or nil)
end

return OverrideUtils