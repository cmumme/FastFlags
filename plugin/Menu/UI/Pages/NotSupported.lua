--[[
    NotSupported.lua
    @author typechecked
    @date 7/30/2023

    The page displayed when there is no support library found.
]]--

-- Dependencies
local PluginEssentials = require(script.Parent.Parent.Parent.Parent.Dependencies.PluginEssentials)

return function ()
    return PluginEssentials.Label {
        Text = "This game doesn't support fast flags.",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5)
    }
end