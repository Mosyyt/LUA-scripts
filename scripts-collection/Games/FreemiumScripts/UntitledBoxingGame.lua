local Players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local character = lp.Character

local Library =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))(

)
local Distance
local HitboxSize
local WalkSPEED
local JumpPOWER

-- Window
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
        Name = "Untitled Boxing Game",
        Description = "Codexus Hub",
        Icon = "rbxassetid://11254763826", -- Tab Icon
        Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
        Hidden = false -- IGNORE THIS
    }
)
-- Section
Tab:Section(
    {
        Name = "~Functions~"
    }
)
Tab:Label({
	Text = "To avoid kicking use the kill aura in rings only and also fighiting multiple enemies"
})

Tab:Slider(
    {
        Name = "Kill Aura Distance",
        Min = 1, -- Min Val
        Max = 17, -- Max Val
        Default = 10, -- Default Val
        Callback = function(val)
            Distance = val
        end
    }
)

Tab:Toggle(
    {
        Name = "Kill Aura",
        Default = false,
        Callback = function(state22)
            KillAura = state22
        end
    }
)

spawn(function()
    while true do
        task.wait(0.8)
        
        if KillAura then
            local localCharacter = lp.Character
            if not localCharacter then
                break
            end
            local humanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
            
            for _, player in ipairs(Players:GetPlayers()) do
                local character = player.Character
                if character and character ~= localCharacter then
                    local position = character.PrimaryPart.Position
                    local humanoid = character.Humanoid
                    if lp:DistanceFromCharacter(position) <= Distance and humanoid.Health > 0 and humanoidRootPart then
                        game:GetService("ReplicatedStorage").RemoteEvents.HandleEquip:FireServer(true)
                        
                        local A_1 = {
                            ["Victim"] = character,
                            ["Character"] = localCharacter,
                            ["IsHeavy"] = true,
                            ["CurrentHeavy"] = 1,
                            ["CurrentPunch"] = 1,
                            ["CurrentCombo"] = 2
                        }
                        game:GetService("ReplicatedStorage").RemoteEvents.TryAttack:FireServer(A_1)
                        
                        break
                    end
                end
            end
        end
    end
end)

Tab:Slider(
    {
        Name = "Hitbox Size",
        Min = 1, -- Min Val
        Max = 50, -- Max Val
        Default = 15, -- Default Val
        Callback = function(val)
            HitboxSize = val
        end
    }
)
local HitboxConnection = nil -- Initialize hitbox connection

local function ModifyHitboxSize(size)
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            pcall(function()
                player.Character.HumanoidRootPart.Size = size
                player.Character.HumanoidRootPart.Transparency = 0.8
                player.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really black")
                player.Character.HumanoidRootPart.Material = "Neon"
                player.Character.HumanoidRootPart.CanCollide = false
            end)
        end
    end
end

local function ToggleCallback(state)
    if state then
        HitboxConnection = rs.Heartbeat:Connect(function()
            ModifyHitboxSize(Vector3.new(HitboxSize, HitboxSize, HitboxSize))
        end)
    else
        if HitboxConnection then
            HitboxConnection:Disconnect()
            HitboxConnection = nil
            -- Reset hitbox sizes when the toggle is turned off
            ModifyHitboxSize(Vector3.new(2, 2, 1))
        end
    end
end

Tab:Toggle(
    {
        Name = "Hitbox",
        Default = false,
        Callback = ToggleCallback
    }
)
Tab:Button(
    {
        Name = "Inf Dash",
        Callback = function()
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall =
                newcclosure(
                function(self, ...)
                    local args = {...}
                    if getnamecallmethod() == "FireServer" and self.Name == "TryDash" then
                        args[1] = "YOUR MOM"
                    end
                    return old(self, unpack(args))
                end
            )
        end
    }
)


local Tab2 =
    Window:Tab(
    {
        Name = "Player",
        Description = "Player Tab",
        Icon = "rbxassetid://6031215978", -- Tab Icon
        Color = Color3.new(1, 0.968627, 0), -- Tab Colour
        Hidden = false -- IGNORE THIS
    }
)

Tab2:Slider(
    {
        Name = "Walkspeed",
        Min = 1, -- Min Val
        Max = 200, -- Max Val
        Default = 16, -- Default Val
        Callback = function(val312val312)
            WalkSPEED = val312val312
            character:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(
                function()
                    character.Humanoid.WalkSpeed = WalkSPEED
                end
            )
            character.Humanoid.WalkSpeed = WalkSPEED
        end
    }
)
Tab2:Slider(
    {
        Name = "Jump Power",
        Min = 1, -- Min Val
        Max = 200, -- Max Val
        Default = 30, -- Default Val
        Callback = function(val312val3121)
            JumpPOWER = val312val3121
            character:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(
                function()
                    character.Humanoid.JumpPower = JumpPOWER
                end
            )
            character.Humanoid.JumpPower = JumpPOWER
        end
    }
)
-- Accessing settings tab
local SettingsTab = Window.SettingsTab

Window:Notify({
	Name = "Notification",
	Text = "Press Insert To Toggle GUI",
	Duration = 5,
	Callback = function() return end -- Callback when the notification ends
})
