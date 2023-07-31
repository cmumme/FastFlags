--[[
    Tag.lua
    @author typechecked
    @date 7/30/2023

    Tag that shows the environment or custom tag of an override.
]]--

-- Dependencies
local Fusion = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Dependencies.Fusion)

-- Fusion
local New = Fusion.New
local Children = Fusion.Children

return function (Properties: {
    Text: string,
    Color: Enum.StudioStyleGuideColor,
    Color3: Color3,
    TextColor3: Color3
})
    return New "TextLabel" {
        Text = Properties.Text,
        TextColor3 = Properties.TextColor3 or Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        FontFace = Font.fromName("SourceSansPro"),
        Size = UDim2.fromOffset(48, 14 * 1.3),
        BackgroundColor3 = Properties.Color3 or settings().Studio.Theme:GetColor(Properties.Color or Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Default),
        BorderSizePixel = 0,

        [Children] = {
            New "UICorner" { CornerRadius = UDim.new(0, 2) },
            New "UIStroke" { Color = Color3.fromRGB(53, 53, 53), Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }
        }
    }
end