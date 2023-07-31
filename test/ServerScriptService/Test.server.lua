--[[
    Test.server.lua
    @author typechecked
    @date 7/30/2023

    Test script for FastFlags
]]--

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local FastFlags = require(ReplicatedStorage.Packages.FastFlags)

FastFlags.FlagUpdated:Connect(function(FlagName: string)
    print(FlagName, FastFlags.Flags[FlagName].Value)
end)