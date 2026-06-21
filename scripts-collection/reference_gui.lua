local Library = loadstring(game:HttpGet("YourUrl"))()

-- Window
local Window = Library:Create({ToggleKey = Enum.KeyCode.RightShift})

-- Tab
local Tab = Window:Tab({
    Name = "Tab",
    Description = "Tab description",
    Icon = "rbxassetid://11254763826", -- Tab Icon
    Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
    Hidden = false -- IGNORE THIS
})

-- Section
local Section = Tab:Section({Name = "Section"})

-- Label
local Label = Tab:Label({Text = "Label"})

Label:SetText("New Label Text") -- Update Label

-- Button
local Button = Tab:Button({
    Name = "Button",
    Callback = function()
        -- Callback
    end
})

-- Toggle
local Toggle = Tab:Toggle({
    Name = "Toggle",
    Default = true, -- Default Value
    Callback = function(bool)
        -- Callback
    end
})

-- Slider
local Slider = Tab:Slider({
    Name = "Slider",
    Min = 0, -- Min Val
    Max = 10, -- Max Val
    Default = 5, -- Default Val
    Callback = function(val)
        -- Callback
    end
})

Slider:SetValue(5) -- Update Slider Value

-- Textbox
local Textbox = Tab:Textbox({
    Name = "Textbox",
    Default = "Default Text", -- Default Text in the box
    Callback = function(txt)
        -- Callback
    end
})

-- Dropdown
local Dropdown = Tab:Dropdown({
    Name = "Dropdown",
    Items = {"Item1", "Item2", "Item3", 3, 4}, -- Tabel
    Callback = function(item)
        -- Callback
    end
})

Dropdown:Clear()

Dropdown:UpdateList({
    Items = {"Item1", "Item2", "Item3"},
    Replace = true --- Whether or not to clear the dropdown when updating
}) -- update Dropdown with a list

-- Notify
Window:Notify({
    Name = "Notification",
    Text = "Some notification",
    Duration = 5,
    Callback = function() return end -- Callback when the notification ends
})

-- Accessing settings tab
local SettingsTab = Window.SettingsTab
