-- Variables
local LPlayer = game:GetService("Players").LocalPlayer
local remote = game:GetService("ReplicatedStorage")["Projectiles: Entity Collide"]
local LMouse = LPlayer:GetMouse()
local camera = game:GetService("Workspace").CurrentCamera
local rs = game:GetService("RunService")
local HitboxConnection
local KillAllConnection
local SniperBotConnection
_G.HitboxSizes = 20
_G.TeamCheck = false
_G.Tracers = false
_G.PlayerNames = false
_G.ESPColor = Color3.new(255, 255, 255)
_G.IgnoreFunction = false
_G.fovAmount = 120

-- Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3"))()
local w = library:CreateWindow("Shit Shitball 2")
local b = w:CreateFolder("Combat")

-- Create Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = _G.fovAmount
fovCircle.Visible = false
fovCircle.Color = Color3.fromRGB(212, 34, 255)
fovCircle.Thickness = 1
fovCircle.NumSides = 16
fovCircle.Position = Vector2.new(0, 0)

-- Functions
local function canSeePlayer(player)
    local cameraPosition = camera.CFrame.p
    local character = player.Character
    if not character then
        return false
    end
    local head = character:FindFirstChild("Head")
    if not head then
        return false
    end
    local headPosition = head.Position
    local rayDirection = (headPosition - cameraPosition).unit
    local ray = Ray.new(cameraPosition, rayDirection * (headPosition - cameraPosition).magnitude)
    local part, hitPosition, hitNormal = workspace:FindPartOnRayWithIgnoreList(ray, {LPlayer.Character})
    if not part or part:IsDescendantOf(character) then
        return true
    end
    return false
end

local function toggleTableAttribute(attribute, value)
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" and rawget(gcVal, attribute) then
            gcVal[attribute] = value
        end
    end
end

local function createTracer(player)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.new(255, 0, 0)
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
                        Tracer.Color = _G.ESPColor
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
    Text.Color = Color3.new(255, 255, 255)
    Text.Size = 14
    Text.Center = true
    function updatePlayerName()
        rs.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") and player ~= LPlayer and player.Character.Humanoid.Health > 0 then
                local Vector, OnScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if OnScreen then
                    Text.Position = Vector2.new(Vector.X, Vector.Y - 30)
                    Text.Text = player.Name
                    if _G.TeamCheck and player.TeamColor == LPlayer.TeamColor then
                        Text.Visible = false
                    else
                        Text.Visible = _G.PlayerNames
                        Text.Color = _G.ESPColor
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

local function highlightPlayers(enabled)
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local connections = {}
    local Storage = Instance.new("Folder")
    Storage.Parent = CoreGui
    Storage.Name = "Highlights"
    function Highlight(plr)
        local Highlight = Instance.new("Highlight")
        Highlight.Name = plr.Name
        Highlight.FillColor = Color3.fromRGB(175, 25, 255)
        Highlight.DepthMode = "AlwaysOnTop"
        Highlight.FillTransparency = 1
        Highlight.OutlineColor = _G.ESPColor
        Highlight.OutlineTransparency = 0
        Highlight.Parent = Storage
        local plrchar = plr.Character
        if plrchar then
            Highlight.Adornee = plrchar
        end
        connections[plr] = plr.CharacterAdded:Connect(function(char)
            Highlight.Adornee = char
        end)
    end
    Players.PlayerAdded:Connect(Highlight)
    for i, v in pairs(Players:GetPlayers()) do
        if not _G.TeamCheck or v.Team ~= lp.Team then
            Highlight(v)
        end
    end
    Players.PlayerRemoving:Connect(function(plr)
        local plrname = plr.Name
        if Storage[plrname] then
            Storage[plrname]:Destroy()
        end
        if connections[plr] then
            connections[plr]:Disconnect()
        end
    end)
end

local function UpdateFovCircle()
    local mousePos = camera.WorldToViewportPoint(camera, LMouse.Hit.Position)
    fovCircle.Radius = _G.fovAmount
    fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    local hue = tick() % 1
    local rainbowColor = Color3.fromHSV(hue, 1, 1)
    fovCircle.Color = rainbowColor
end

local function IsInFov(position)
    local mousePos = Vector2.new(LMouse.X, LMouse.Y)
    local screenPosition, isVisible = camera:WorldToViewportPoint(position)
    local distanceToMouse = (mousePos - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
    return isVisible and distanceToMouse <= _G.fovAmount
end

local function GetClosestPlayer()
    local ClosestDistance, ClosestPlayer = math.huge, nil
    for _, Player in pairs(game:GetService("Players"):GetPlayers()) do
        if Player ~= LPlayer then
            local Character = Player.Character
            if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart and IsInFov(HumanoidRootPart.Position) and (not _G.TeamCheck or Player.Team ~= LPlayer.Team) then
                    local screenPosition, isVisible = camera:WorldToViewportPoint(HumanoidRootPart.Position)
                    if isVisible then
                        local distanceToMouse = (LMouse.X - screenPosition.X) ^ 2 + (LMouse.Y - screenPosition.Y) ^ 2
                        if distanceToMouse < ClosestDistance then
                            ClosestPlayer = Player
                            ClosestDistance = distanceToMouse
                        end
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

local function GetClosestHitbox()
    local ClosestDistance, ClosestHitbox = math.huge, nil
    for _, itbox in pairs(workspace.__THINGS.CharacterHighlights.Enemies:GetChildren()) do
        if itbox:IsA("Model") then
            local hitboxMain = (itbox:FindFirstChild("Hitbox")):FindFirstChild("Main")
            if hitboxMain then
                local screenPosition, isVisible = camera:WorldToViewportPoint(hitboxMain.Position)
                if isVisible then
                    local distanceToMouse = (LMouse.X - screenPosition.X) ^ 2 + (LMouse.Y - screenPosition.Y) ^ 2
                    if distanceToMouse < ClosestDistance then
                        ClosestHitbox = hitboxMain
                        ClosestDistance = distanceToMouse
                    end
                end
            end
        end
    end
    return ClosestHitbox
end

local function mouse1click()
    local screenCenter = Vector2.new(((game:GetService("GuiService")):GetScreenResolution()).X / 2, ((game:GetService("GuiService")):GetScreenResolution()).Y / 2)
    local x, y = screenCenter.X, screenCenter.Y
    local virtual_input_manager = game:GetService("VirtualInputManager")
    virtual_input_manager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    virtual_input_manager:SendMouseButtonEvent(x, y, 0, true, game, 1)
end

-- Player Loop
for _, player in pairs(game.Players:GetPlayers()) do
    createTracer(player)
    createPlayerName(player)
end

game.Players.PlayerAdded:Connect(function(player)
    createTracer(player)
    createPlayerName(player)
end)

-- Event Listeners
rs.RenderStepped:Connect(UpdateFovCircle)

-- UI Elements
b:Slider("Fov Size", {min = 10, max = 500, precise = false}, function(value)
    _G.fovAmount = value
end)

b:Toggle("Enable Fov", function(bool)
    fovCircle.Visible = bool
end)

b:Toggle("Wall Bang", function(bool)
    _G.IgnoreFunction = bool
end)

b:Toggle("Silent Aim", function(bool)
    EnableSilentAim = bool
    if EnableSilentAim then
        oldNamecall = hookmetamethod(remote, "__namecall", newcclosure(function(self, ...)
            if typeof(self) == "Instance" then
                local method = getnamecallmethod()
                local remArgs = {...}
                if method and (method == "FireServer" and self == remote) then
                    local closestHitbox = GetClosestHitbox()
                    print(closestHitbox)
                    local target = GetClosestPlayer()
                    if closestHitbox and target and canSeePlayer(target) then
                        remArgs[2]["part"] = closestHitbox
                        remArgs[2]["partPath"] = closestHitbox:GetFullName()
                        setnamecallmethod(method)
                        return oldNamecall(self, unpack(remArgs))
                    else
                        setnamecallmethod(method)
                    end
                end
            end
            return oldNamecall(self, ...)
        end))
    elseif oldNamecall then
        hookmetamethod(remote, "__namecall", oldNamecall)
        oldNamecall = nil
    end
end)

b:Toggle("Kill All", function(state)
    if state then
        KillAllConnection = rs.Heartbeat:Connect(function()
            for i, v in pairs(game.Players:GetChildren()) do
                if v and v.Team ~= game.Players.LocalPlayer.Team and v:GetAttribute("Spawned") and
                    game.Players.LocalPlayer:GetAttribute("Spawned") and not v.Character:FindFirstChild("ForceField") then
                    v.Character.HumanoidRootPart.CFrame = workspace.CurrentCamera.CFrame:ToWorldSpace(CFrame.new(0, 0, -6))
                end        
            end
        end)
        return
    end
    KillAllConnection:Disconnect()
end)

b:Toggle("Sniper Bot", function(state)
    if state then
        SniperBotConnection = rs.Heartbeat:Connect(function()
            local target = GetClosestPlayer()
            local targetchar = target and target.Character or nil
            local targetHead = targetchar and targetchar:FindFirstChild("Head") or nil
            if target and targetchar and targetHead and canSeePlayer(target) then
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
                mouse1click()
            end
        end)
        return
    end
    SniperBotConnection:Disconnect()
end)

b:Slider("Hitbox Size", {min = 1, max = 150, precise = false}, function(value)
    _G.HitboxSizes = Vector3.new(value, value, value)
end)

b:Toggle("Hitboxes", function(state)
    if state then
        HitboxConnection = rs.Heartbeat:Connect(function()
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player.Character then
                    local hitbox = player.Character:FindFirstChild("Hitbox")
                    if hitbox then
                        local main = hitbox:FindFirstChild("Main")
                        if Player ~= LPlayer and main and main.Size ~= _G.HitboxSizes then
                            main.Size = _G.HitboxSizes
                            main.CFrame = workspace.CurrentCamera.CFrame:ToWorldSpace(CFrame.new(0, 0, -7))
                        end
                    end
                end
            end
        end)
        return
    end
    if HitboxConnection then
        HitboxConnection:Disconnect()
    end
end)

local f = library:CreateWindow("Visuals")
local x = f:CreateFolder("Visuals")
x:Toggle("TeamCheck", function(bool)
    _G.TeamCheck = bool
end)

x:Toggle("Tracers", function(bool)
    _G.Tracers = bool
end)

x:Toggle("Player Names", function(bool) _G.PlayerNames = bool
for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("NameTag") then
            player.Character.NameTag.Visible = bool
        end
    end
end)

x:Toggle("Outlines", function(bool)
    _G.HighlightPlayers = bool
    highlightPlayers(bool)
end)

x:ColorPicker("ESP Color", Color3.fromRGB(255, 255, 255), function(color)
    _G.ESPColor = color
    for _, highlight in pairs(game:GetService("CoreGui").Highlights:GetChildren()) do
        highlight.OutlineColor = color
    end
end)

local t = library:CreateWindow("Guns")
local c = t:CreateFolder("Guns")
c:Toggle("FireRate", function(bool)
    if bool then
        toggleTableAttribute("firerate", 0)
    else
        toggleTableAttribute("firerate", 0.47)
    end
end)

c:Toggle("Velocity", function(bool)
    if bool then
        toggleTableAttribute("Velocity", 4000)
    else
        toggleTableAttribute("Velocity", 1000)
    end
end)

c:Toggle("Gravity", function(bool)
    if bool then
        toggleTableAttribute("Gravity", 0)
    else
        toggleTableAttribute("Gravity", 100)
    end
end)
