local LPlayer = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local rs = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Mouse = LPlayer:GetMouse()

-- Global variables
_G.BoxESP = true
_G.Tracers = true
_G.PlayerNames = true
_G.TeamCheck = true
_G.ESPColor = Color3.fromRGB(115, 173, 101)

local function createTracer(player)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = _G.ESPColor
    Tracer.Thickness = 1
    Tracer.Transparency = 1
       
    function updateTracer()
        rs.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LPlayer and player.Character.Humanoid.Health > 0 then
                local Vector, OnScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if OnScreen then
                    Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Vector.X, Vector.Y)
                    if _G.TeamCheck and player.TeamColor == LPlayer.TeamColor then
                        Tracer.Visible = false
                    else
                        Tracer.Visible = _G.Tracers
                    end
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

local function createPlayerName(player)
    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Color = _G.ESPColor
    Text.Size = 14
    Text.Center = true
    Text.Font = 1
    Text.Outline = true
    
    function updatePlayerName()
        rs.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") and player ~= LPlayer and player.Character.Humanoid.Health > 0 then
                local Vector, OnScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if OnScreen then
                    Text.Position = Vector2.new(Vector.X, Vector.Y - 30)
                    Text.Text = player.Name .. "\nHealth: " .. math.floor(player.Character.Humanoid.Health) .. "\nDistance: " .. math.floor((player.Character.HumanoidRootPart.Position - LPlayer.Character.HumanoidRootPart.Position).magnitude)
                    if _G.TeamCheck and player.TeamColor == LPlayer.TeamColor then
                        Text.Visible = false
                    else
                        Text.Visible = _G.PlayerNames
                    end
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
            if LPlayer ~= plr and _G.BoxESP and plr.Character ~= nil and plr.Character:FindFirstChildOfClass("Humanoid") ~= nil and plr.Character.PrimaryPart ~= nil and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
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

                        if _G.TeamCheck and plr.TeamColor == LPlayer.TeamColor then
                            Box.Visible = false
                        else
                            Box.Visible = true
                        end
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


-- Function to toggle ESPs
local function toggleESP()
    _G.Tracers = not _G.Tracers
    _G.PlayerNames = not _G.PlayerNames
    _G.BoxESP = not _G.BoxESP
end

-- Keybind to toggle ESPs
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then  -- Change the keybind as needed
        toggleESP()
    end
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
