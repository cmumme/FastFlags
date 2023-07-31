--[[
    Item.lua
    @author typechecked
    @date 7/30/2023

    Defines the UI for an item in OverrideDisplay.
]]--

-- Dependencies
local Fusion = require(script.Parent.Parent.Parent.Parent.Parent.Dependencies.Fusion)
local PluginEssentials = require(script.Parent.Parent.Parent.Parent.Parent.Dependencies.PluginEssentials)
local OverrideUtils = require(script.Parent.Parent.Parent.Parent.OverrideUtils)
local Tag = require(script.Tag)

-- Fusion
local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local Value = Fusion.Value

return function (Properties: {
    Flag: table,
    SupportLibrary: table
})
    local InputValue = Value(Properties.Flag.Definition.FallbackValue)
    local ResetEnabled = Value(false)

    local function Update()
        local OverrideValue = OverrideUtils:GetValue(Properties.Flag.Name)
        if(OverrideValue ~= nil) then
            InputValue:set(OverrideValue)
        else
            InputValue:set(Properties.Flag.Value)
        end
        ResetEnabled:set(OverrideUtils:GetOverride(Properties.Flag.Name) and true or false)
    end

    Properties.SupportLibrary.FlagUpdated:Connect(Update)

    local function UpdateValue(NewValue: any)
        OverrideUtils:SetOverride(Properties.Flag.Name, NewValue)
        Update()
    end

    Update()

    return PluginEssentials.Background {
        ZIndex = 1,
        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        [Children] = {
            New "UIListLayout" { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) },
            New "Frame" {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 0,

                [Children] = {
                    New "UIListLayout" { SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, },

                    PluginEssentials.Title {
                        Text = Properties.Flag.Definition.Name,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.fromOffset(0, 0),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        LayoutOrder = 0
                    },
                    New "Frame" {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(0, 1),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        LayoutOrder = 1,

                        [Children] = {
                            New "UIGridLayout" { SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, CellPadding = UDim2.fromOffset(8, 8), CellSize = UDim2.fromOffset(48, 14*1.3), FillDirectionMaxCells = 3 },

                            ForValues(Properties.Flag.Definition.OverrideEnvironments, function(TagValue)
                                return Tag {
                                    Text = TagValue,
                                    Color = TagValue == "Studio" and
                                        Enum.StudioStyleGuideColor.MainButton or
                                            TagValue == "Testing" and
                                        Enum.StudioStyleGuideColor.WarningText or
                                        nil,
                                    Color3 = TagValue == "Live" and
                                        Color3.fromRGB(35, 146, 35) or
                                        nil
                                }
                            end, Fusion.cleanup)
                        }
                    }
                }
            },
            New "Frame" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 1,

                [Children] = {
                    New "UIListLayout" { SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8) },

                    PluginEssentials.Label {
                        Size = UDim2.fromScale(0.65, 0),
                        Text = Properties.Flag.Definition.Description,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextWrapped = true
                    },
                    New "Frame" {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.35, -8, 1, 0),

                        [Children] = {
                            New "UIListLayout" { SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8) },

                            typeof(Properties.Flag.Definition.FallbackValue == "boolean") and
                            PluginEssentials.Checkbox {
                                Size = UDim2.fromOffset(15, 15),
                                AutomaticSize = Enum.AutomaticSize.X,
                                Value = InputValue,
                                OnChange = UpdateValue
                            } or
                            PluginEssentials.Label {
                                Size = UDim2.fromScale(0, 0),
                                Text = "Unsupported type",
                                TextXAlignment = Enum.TextXAlignment.Left,
                                AutomaticSize = Enum.AutomaticSize.XY
                            },

                            PluginEssentials.Button {
                                Text = "Reset",
                                Size = UDim2.fromOffset(72, 24),
                                Activated = function()
                                    OverrideUtils:DeleteOverride(Properties.Flag.Name)
                                    Update()
                                end,
                                Visible = ResetEnabled
                            }
                        }
                    }
                }
            }
        }
    }
end