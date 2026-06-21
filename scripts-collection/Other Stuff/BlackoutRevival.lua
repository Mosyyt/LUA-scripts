
local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3'))()

local w = library:CreateWindow("Blackout") -- Creates the window

local b = w:CreateFolder("Options") -- Creates the folder for options

-- Function to create Tracer for a player
local function createTracer(player)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = _G.ESPColor
    Tracer.Thickness = 1
    Tracer.Transparency = 1

    function updateTracer()
        game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") and player ~= localPlayer and player.Character.Humanoid.Health > 0 then
                local Vector, OnScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if OnScreen then
                    Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Vector.X, Vector.Y)
                    Tracer.Visible = _G.Tracers and not (_G.TeamCheck and player.TeamColor == localPlayer.TeamColor)
                else
                    Tracer.Visible = false
                end
            else
                Tracer.Visible = false
            end
        end)
    end
    updateTracer()
end

-- Function to create player name text
local function createPlayerName(player)
    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Color = _G.ESPColor
    Text.Size = 14
    Text.Center = true

    function updatePlayerName()
        game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") and player ~= localPlayer and player.Character.Humanoid.Health > 0 then
                local Vector, OnScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if OnScreen then
                    Text.Position = Vector2.new(Vector.X, Vector.Y - 30)
                    Text.Text = player.Name .. "\nHealth: " .. math.floor(player.Character.Humanoid.Health) .. "\nDistance: " .. math.floor((player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).magnitude)
                    Text.Visible = _G.PlayerNames and not (_G.TeamCheck and player.TeamColor == localPlayer.TeamColor)
                else
                    Text.Visible = false
                end
            else
                Text.Visible = false
            end
        end)
    end
    updatePlayerName()
end

-- Function to draw ESP box around player
local function DrawESP(plr)
    local Box = Drawing.new("Quad")
    Box.Visible = false
    Box.PointA = Vector2.new(0, 0)
    Box.PointB = Vector2.new(0, 0)
    Box.PointC = Vector2.new(0, 0)
    Box.PointD = Vector2.new(0, 0)
    Box.Color = _G.ESPColor
    Box.Thickness = 1
    Box.Transparency = 1

    local function Update()
        local c
        c = game:GetService("RunService").RenderStepped:Connect(function()
            if _G.BoxESP and plr.Character ~= nil and plr.Character:FindFirstChildOfClass("Humanoid") ~= nil and plr.Character.PrimaryPart ~= nil and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local pos, vis = camera:WorldToViewportPoint(plr.Character.PrimaryPart.Position)
                if vis then 
                    local points = {}
                    local c = 0
                    for _,v in pairs(plr.Character:GetChildren()) do
                        if v:IsA("BasePart") then
                            c = c + 1
                            local p, vis = camera:WorldToViewportPoint(v.Position)
                            if v == plr.Character.PrimaryPart then
                                p, vis = camera:WorldToViewportPoint((v.CFrame * CFrame.new(0, 0, -v.Size.Z)).p)
                            elseif v.Name == "Head" then
                                p, vis = camera:WorldToViewportPoint((v.CFrame * CFrame.new(0, v.Size.Y/2, v.Size.Z/1.25)).p)
                            elseif string.match(v.Name, "Left") then
                                p, vis = camera:WorldToViewportPoint((v.CFrame * CFrame.new(-v.Size.X/2, 0, 0)).p)
                            elseif string.match(v.Name, "Right") then
                                p, vis = camera:WorldToViewportPoint((v.CFrame * CFrame.new(v.Size.X/2, 0, 0)).p)
                            end
                            points[c] = {p, vis}
                        end
                    end

                    local TopY = math.huge
                    local DownY = -math.huge
                    local LeftX = math.huge
                    local RightX = -math.huge

                    local Left
                    local Right
                    local Top
                    local Bottom

                    local closest = nil
                    for _,v in pairs(points) do
                        if v[2] == true then
                            local p = v[1]
                            if p.Y < TopY then
                                Top = p
                                TopY = p.Y
                            end
                            if p.Y > DownY then
                                Bottom = p
                                DownY = p.Y
                            end
                            if p.X > RightX then
                                Right = p
                                RightX = p.X
                            end
                            if p.X < LeftX then
                                Left = p
                                LeftX = p.X
                            end
                        end
                    end

                    if Left ~= nil and Right ~= nil and Top ~= nil and Bottom ~= nil then
                        Box.PointA = Vector2.new(Right.X, Top.Y)
                        Box.PointB = Vector2.new(Left.X, Top.Y)
                        Box.PointC = Vector2.new(Left.X, Bottom.Y)
                        Box.PointD = Vector2.new(Right.X, Bottom.Y)

                        Box.Visible = true
                    else 
                        Box.Visible = false
                    end
                else 
                    Box.Visible = false
                end
            else
                Box.Visible = false
                if game.Players:FindFirstChild(plr.Name) == nil then
                    c:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- Toggle for Inf Stamina
b:Toggle("Inf Stamina Toggle", function(bool)
    if bool then
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if getnamecallmethod() == 'FireServer' and self.Name == 'Stamina' then
                args[1] = 0
            end
            return old(self, unpack(args))
        end)
    else
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        mt.__namecall = old
        setreadonly(mt, true)
    end
end)

-- Toggle for NPC Melee Aura
b:Toggle("NPC Melee Aura", function(bool)
    attackingNPCs = bool
end)

-- Function to handle NPC Melee Aura
game:GetService("RunService").RenderStepped:Connect(function()
    if attackingNPCs then
        for _, player in ipairs(workspace.NPCs.Hostile:GetChildren()) do
            local localPlayer = game:GetService("Players").LocalPlayer
            if localPlayer:DistanceFromCharacter(player and player:FindFirstChild("HumanoidRootPart") and player.HumanoidRootPart.Position or localPlayer.HumanoidRootPart.Position) <= 20 then
                if player and player:FindFirstChild("Humanoid") and player.Humanoid.Health >= 0 then
                    local ohInstance1 = player.HumanoidRootPart
                    local ohVector32 = player.HumanoidRootPart.Position
                    
                    game:GetService("ReplicatedStorage").MeleeStorage.Events.Hit:FireServer(ohInstance1, ohVector32)
                    game:GetService("ReplicatedStorage").MeleeStorage.Events.Swing:InvokeServer()
                end
            end
        end
    end
end)

-- Toggle for Players Melee Aura
b:Toggle("Players Melee Aura", function(bool)
    attackingPlayers = bool
end)

-- Function to handle Players Melee Aura
local function checkNearbyPlayers()
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player:FindFirstChild("Humanoid") and player.Humanoid.Health >= 0 then
            local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= 20 then
                local ohInstance1 = player.Character.HumanoidRootPart
                local ohVector32 = player.Character.HumanoidRootPart.Position
                game:GetService("ReplicatedStorage").MeleeStorage.Events.Hit:FireServer(ohInstance1, ohVector32)
                game:GetService("ReplicatedStorage").MeleeStorage.Events.Swing:InvokeServer()
            end
        end
    end
end

-- Function to handle Players Melee Aura rendering
game:GetService("RunService").RenderStepped:Connect(function()
    if attackingPlayers then
        checkNearbyPlayers()
    end
end)

-- Function to toggle Auto LockPick
local minigameToggle = false
local function toggleMinigameResult(bool)
    if bool then
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if getnamecallmethod() == 'FireServer' and self.Name == 'MinigameResult' then
                args[2] = true
            end
            return old(self, unpack(args))
        end)
    else
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        mt.__namecall = old
        setreadonly(mt, true)
    end
end

-- Toggle for Auto LockPick
b:Toggle("Auto LockPick", function(bool)
    minigameToggle = bool
    toggleMinigameResult(minigameToggle)
end)

-- Toggle for Tracers
b:Toggle("Tracers", function(bool)
    _G.Tracers = bool
end)

-- Toggle for Boxes
b:Toggle("Boxes", function(bool)
    _G.BoxESP = bool
end)

-- Toggle for Player Names
b:Toggle("Names", function(bool)
    _G.PlayerNames = bool
end)

-- Create ESPs for existing players
for _, player in pairs(game.Players:GetPlayers()) do
    createTracer(player)
    createPlayerName(player)
    DrawESP(player)
end

-- Connect to PlayerAdded event to create ESPs for new players
game.Players.PlayerAdded:Connect(function(player)
    createTracer(player)
    createPlayerName(player)
    DrawESP(player)
end)

















local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local rs = game:GetService("RunService")
local camera = game:GetService("Workspace").CurrentCamera
local UIS = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/UI.lua"))()
local Window = Library:Create({ToggleKey = Enum.KeyCode.Insert})


-- Global variables
_G.BoxESP = true
_G.Tracers = true
_G.PlayerNames = true
_G.TeamCheck = false
_G.ESPColor = Color3.new(0, 255, 0)  -- Green color
-- Tab
local Tab = Window:Tab({
    Name = "BlackOut - Codexus ",
    Description = "Tab description",
    Icon = "rbxassetid://11254763826", -- Tab Icon
    Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
    Hidden = false -- IGNORE THIS
})

-- Section
local Section = Tab:Section({Name = "Main"})

-- Label
local Label = Tab:Label({Text = "~Functions~"})
-- Function to create player ESP
local function DrawESP(player)
    local Box = Drawing.new("Quad")
    Box.Visible = false
    Box.PointA = Vector2.new(0, 0)
    Box.PointB = Vector2.new(0, 0)
    Box.PointC = Vector2.new(0, 0)
    Box.PointD = Vector2.new(0, 0)
    Box.Color = _G.ESPColor
    Box.Thickness = 1
    Box.Transparency = 1

    local function Update()
        local c
        c = game:GetService("RunService").RenderStepped:Connect(function()
            if _G.BoxESP and player ~= LocalPlayer and player.Character ~= nil and player.Character:FindFirstChildOfClass("Humanoid") ~= nil and player.Character.PrimaryPart ~= nil and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local pos, vis = camera:WorldToViewportPoint(player.Character.PrimaryPart.Position)
                if vis then 
                    local points = {}
                    local c = 0
                    for _,v in pairs(player.Character:GetChildren()) do
                        if v:IsA("BasePart") then
                            c = c + 1
                            local p, vis = camera:WorldToViewportPoint(v.Position)
                            if v == player.Character.PrimaryPart then
                                p, vis = camera:WorldToViewportPoint((v.CFrame * CFrame.new(0, 0, -v.Size.Z)).p)
                            elseif v.Name == "Head" then
                                p, vis = camera:WorldToViewportPoint((v.CFrame * CFrame.new(0, v.Size.Y/2, v.Size.Z/1.25)).p)
                            elseif string.match(v.Name, "Left") then
                                p, vis = camera:WorldToViewportPoint((v.CFrame * CFrame.new(-v.Size.X/2, 0, 0)).p)
                            elseif string.match(v.Name, "Right") then
                                p, vis = camera:WorldToViewportPoint((v.CFrame * CFrame.new(v.Size.X/2, 0, 0)).p)
                            end
                            points[c] = {p, vis}
                        end
                    end

                    local TopY = math.huge
                    local DownY = -math.huge
                    local LeftX = math.huge
                    local RightX = -math.huge

                    local Left
                    local Right
                    local Top
                    local Bottom

                    local closest = nil
                    for _,v in pairs(points) do
                        if v[2] == true then
                            local p = v[1]
                            if p.Y < TopY then
                                Top = p
                                TopY = p.Y
                            end
                            if p.Y > DownY then
                                Bottom = p
                                DownY = p.Y
                            end
                            if p.X > RightX then
                                Right = p
                                RightX = p.X
                            end
                            if p.X < LeftX then
                                Left = p
                                LeftX = p.X
                            end
                        end
                    end

                    if Left ~= nil and Right ~= nil and Top ~= nil and Bottom ~= nil then
                        Box.PointA = Vector2.new(Right.X, Top.Y)
                        Box.PointB = Vector2.new(Left.X, Top.Y)
                        Box.PointC = Vector2.new(Left.X, Bottom.Y)
                        Box.PointD = Vector2.new(Right.X, Bottom.Y)

                        Box.Visible = true
                    else 
                        Box.Visible = false
                    end
                else 
                    Box.Visible = false
                end
            else
                Box.Visible = false
                if game.Players:FindFirstChild(player.Name) == nil then
                    c:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- Function to create tracers
local function createTracer(player)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = _G.ESPColor
    Tracer.Thickness = 1
    Tracer.Transparency = 1

    function updateTracer()
        game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") and player ~= LocalPlayer and player.Character.Humanoid.Health > 0 then
                local Vector, OnScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if OnScreen then
                    Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Vector.X, Vector.Y)
                    Tracer.Visible = _G.Tracers and not (_G.TeamCheck and player.TeamColor == LocalPlayer.TeamColor)
                else
                    Tracer.Visible = false
                end
            else
                Tracer.Visible = false
            end
        end)
    end
    updateTracer()
end

-- Function to create player names
local function createPlayerName(player)
    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Color = _G.ESPColor
    Text.Size = 14
    Text.Center = true

    function updatePlayerName()
        game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") and player ~= LocalPlayer and player.Character.Humanoid.Health > 0 then
                local Vector, OnScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if OnScreen then
                    Text.Position = Vector2.new(Vector.X, Vector.Y - 30)
                    Text.Text = player.Name .. "\nHealth: " .. math.floor(player.Character.Humanoid.Health) .. "\nDistance: " .. math.floor((player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude)
                    Text.Visible = _G.PlayerNames and not (_G.TeamCheck and player.TeamColor == LocalPlayer.TeamColor)
                else
                    Text.Visible = false
                end
            else
                Text.Visible = false
            end
        end)
    end
    updatePlayerName()
end

-- Create ESPs for existing players
for _, player in pairs(Players:GetPlayers()) do
    DrawESP(player)
    createTracer(player)
    createPlayerName(player)
end

-- Connect to PlayerAdded event to create ESPs for new players
Players.PlayerAdded:Connect(function(player)
    DrawESP(player)
    createTracer(player)
    createPlayerName(player)
end)

local NPCAura;
Tab:Toggle({
    Name = "Melee NPC Aura",
    Default = false,
    Callback = function(state1)
        if NPCAura then
            NPCAura:Disconnect()
            NPCAura = nil
        end
        if state1 then
            NPCAura = rs.Heartbeat:Connect(function()
                for _, player in ipairs(workspace.NPCs.Hostile:GetChildren()) do
                    local localPlayer = game:GetService("Players").LocalPlayer
                    if localPlayer:DistanceFromCharacter(player and player:FindFirstChild("HumanoidRootPart") and player.HumanoidRootPart.Position or localPlayer.HumanoidRootPart.Position) <= 20 then
                        if player and player:FindFirstChild("Humanoid") and player.Humanoid.Health >= 0 then
                            local ohInstance1 = player.HumanoidRootPart
                            local ohVector32 = player.HumanoidRootPart.Position
                            
                            game:GetService("ReplicatedStorage").MeleeStorage.Events.Hit:FireServer(ohInstance1, ohVector32)
                            game:GetService("ReplicatedStorage").MeleeStorage.Events.Swing:InvokeServer()
                        end
                    end
                end
            end)
        end
    end
})

local PlayerAura;
Tab:Toggle({
    Name = "Melee Player Aura",
    Default = false,
    Callback = function(state2)
        if PlayerAura then
            PlayerAura:Disconnect()
            PlayerAura = nil
        end
        if state2 then
            PlayerAura = rs.Heartbeat:Connect(function()
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player:FindFirstChild("Humanoid") and player.Humanoid.Health >= 0 then
                        local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).magnitude
                        if distance <= 20 then
                            local ohInstance1 = player.Character.HumanoidRootPart
                            local ohVector32 = player.Character.HumanoidRootPart.Position
                            game:GetService("ReplicatedStorage").MeleeStorage.Events.Hit:FireServer(ohInstance1, ohVector32)
                            game:GetService("ReplicatedStorage").MeleeStorage.Events.Swing:InvokeServer()
                        end
                    end
                end
            end)
        end
    end
})



Tab:Toggle({
    Name = "Tracers",
    Default = false,
    Callback = function(state)
        _G.Tracers = state
    end
})

Tab:Toggle({
    Name = "Boxes",
    Default = false,
    Callback = function(state)
        _G.BoxESP = state
    end
})

Tab:Toggle({
    Name = "Player Names",
    Default = false,
    Callback = function(state)
        _G.PlayerNames = state
    end
})
for _, player in pairs(game.Players:GetPlayers()) do
    createTracer(player)
    createPlayerName(player)
	DrawESP(player)
end

-- Connect to PlayerAdded event to create ESPs for new players
game.Players.PlayerAdded:Connect(function(player)
    createTracer(player)
    createPlayerName(player)
	DrawESP(player)
end)
