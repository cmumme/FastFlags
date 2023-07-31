--[[
    FastFlags.lua
    @author typechecked
    @date 7/30/2023

    The main plugin code for SGH's fast flag system.
]]--

-- Plugin Variables
local Toolbar = plugin:CreateToolbar("FastFlags")
local OpenMenuButton = Toolbar:CreateButton("OpenMenu", "Open fast flags menu", "rbxassetid://3944688398", "Open Menu")

if(pcall(function()
    loadstring("")()
end)) then
    OpenMenuButton.Enabled = true
    local Menu = require(script.Menu)

    OpenMenuButton.Click:Connect(function()
        Menu:ToggleMenu()
    end)

    Menu.Toggled:Connect(function()
        OpenMenuButton:SetActive(Menu.IsOpen)
    end)
else
    OpenMenuButton.Enabled = false
end