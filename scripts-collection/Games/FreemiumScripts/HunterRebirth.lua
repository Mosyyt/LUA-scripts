local Players = game.Players
local rs = game.RunService
local lp = Players.LocalPlayer
local Library =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))(

)

local Window =
    Library:Create(
    {
        ToggleKey = Enum.KeyCode.Insert
    }
)

-- Tab
local Tab =
    Window:Tab(
    {
        Name = "Hunting Season Rebirth",
        Description = "Codexus Hub",
        Icon = "rbxassetid://11254763826", -- Tab Icon
        Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
        Hidden = false -- IGNORE THIS
    }
)
local FarmOres;
Tab:Toggle({
    Name = "Farm Selected Ore",
    Default = false,
    Callback = function(state3)
        if FarmOres then
            FarmOres:Disconnect()
            FarmOres = nil
        end

        if state3 then
            FarmOres = rs.Heartbeat:Connect(function()
            
            end)
        end
    end
})
