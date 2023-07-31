--[[
    UI.lua
    @author typechecked
    @date 7/30/2023

    The plugin menu UI for SGH's fast flag system.
]]--

-- Dependencies
local Fusion = require(script.Parent.Parent.Dependencies.Fusion)
local PluginEssentials = require(script.Parent.Parent.Dependencies.PluginEssentials)
local OverrideDisplay = require(script.Pages.OverrideDisplay)
local NotSupported = require(script.Pages.NotSupported)

-- Fusion
local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

return function (Properties: {
    ---@diagnostic disable-next-line:undefined-type
    SupportLibrary: Fusion.Value<table | nil>,
    Menu: table
})
    return PluginEssentials.Background {
        [Children] = {
            New "UIPadding" { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) },
            New "UIListLayout" { },

            New "Frame" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, 24),

                [Children] = {
                    New "UIListLayout" { VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Right, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) },

                    PluginEssentials.IconButton {
                        Icon = "rbxassetid://4335476290",
                        Enabled = true,
                        Size = UDim2.fromOffset(24, 24),
                        LayoutOrder = 0,

                        Activated = function()
                            Properties.Menu:UpdateSupportLibrary()
                        end
                    }
                }
            },

            New "Frame" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(0, 24),

                [Children] = {
                    Computed(function()
                        return Properties.SupportLibrary:get() and
                            OverrideDisplay { SupportLibrary = Properties.SupportLibrary} or
                            NotSupported ( )
                    end, Fusion.cleanup)
                }
            }
        }
    }
end