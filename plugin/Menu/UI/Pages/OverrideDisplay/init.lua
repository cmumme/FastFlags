--[[
    OverrideDisplay.lua
    @author typechecked
    @date 7/30/2023

    The initial page that displays all the game's flags.
]]--

-- Dependencies
local Fusion = require(script.Parent.Parent.Parent.Parent.Dependencies.Fusion)
local PluginEssentials = require(script.Parent.Parent.Parent.Parent.Dependencies.PluginEssentials)
local Item = require(script.Item)

-- Fusion
local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues

return function (Properties: {
    ---@diagnostic disable-next-line:undefined-type
    SupportLibrary: Fusion.Value<table | nil>
})
    return Computed(function()
        local Length = 0
        for _,_ in pairs(Properties.SupportLibrary:get().Flags) do
            Length += 1
        end

        return (Length > 0) and PluginEssentials.ScrollFrame {
            ZIndex = 1,
            UILayout = New "UIListLayout" { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) },
            CanvasScaleConstraint = Enum.ScrollingDirection.X,

            [Children] = {
                ForValues(Properties.SupportLibrary:get().Flags, function(Flag: table)
                    return Item {
                        Flag = Flag,
                        SupportLibrary = Properties.SupportLibrary:get()
                    }
                end, Fusion.cleanup)
            }
        } or PluginEssentials.Label {
            Text = "Looks like you don't have any flags in this game yet. Create one in the FlagsLibrary.",
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Center,
            Size = UDim2.fromScale(1, 1)
        }
    end, Fusion.cleanup)
end