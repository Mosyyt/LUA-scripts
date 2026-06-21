local Players = game.Players
local rs = game.RunService
local lp = Players.LocalPlayer
local Characters = workspace.Entities
local NPcsFolder = workspace.NPCs
local function ChangeNames()
    for i, v in ipairs(Characters:GetChildren()) do
        if not v:FindFirstChild("Health") then
            local underscoreIndex = string.find(v.Name, "_")
            if underscoreIndex then
                v.Name = string.sub(v.Name, 1, underscoreIndex - 1)
                print(v.Name .. "Mob Name just changed which means it's spawned gl with that lol")
            end
        end
    end
end
ChangeNames()
Characters.ChildAdded:Connect(ChangeNames)
local Library =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))(

)

local mobs = {}
local NPCs = {"Nel Tu", "Bambietta", "Kisuke", "Rin", "V - Unequaled, Unrivaled", "1"}
local SelectedPlayer

for _, v in next, Characters:GetChildren() do
    if not v:FindFirstChild("Health") then
        table.insert(mobs, v.Name)
    end
end

table.sort(
    mobs,
    function(a, b)
        return a < b
    end
)

function RemoveTableDupes(tab)
    local hash = {}
    local res = {}
    for _, v in ipairs(tab) do
        if (not hash[v]) then
            res[#res + 1] = v
            hash[v] = true
        end
    end
    return res
end

mobs = RemoveTableDupes(mobs)


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
        Name = "Type Soul",
        Description = "Codexus Hub",
        Icon = "rbxassetid://11254763826", -- Tab Icon
        Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
        Hidden = false -- IGNORE THIS
    }
)
local farmHeartbeatConnection
local TweenService = game:GetService("TweenService")
local antifall = nil
local noclipE = nil
local currentMob = nil
local shouldGoUp = false -- Flag to track whether to go up to the surface or not

local function noclip()
    for i, v in pairs(lp.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide == true then
            v.CanCollide = false
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

local function moveto(obj, speed)
    local lp = game:GetService("Players").LocalPlayer

    local function moveToDestination(destinationPos)
        local info = TweenInfo.new(
            (lp.Character.HumanoidRootPart.Position - destinationPos).Magnitude / speed,
            Enum.EasingStyle.Linear
        )

        local tween = TweenService:Create(
            lp.Character.HumanoidRootPart,
            info,
            {CFrame = CFrame.new(destinationPos)}
        )

        if not antifall then
            antifall = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
            antifall.Velocity = Vector3.new(0, 0, 0)
            noclipE = game:GetService("RunService").Stepped:Connect(noclip)

            tween:Play()
            tween.Completed:Connect(function()
                antifall:Destroy()
                antifall = nil
                noclipE:Disconnect()

                if destinationPos == currentMob.Position then
                    if shouldGoUp then
                        shouldGoUp = false -- Reset the flag

                        task.wait(0.5) -- Wait for a short duration before going up to the surface
                        moveToDestination(destinationPos + Vector3.new(0, 7, 0)) -- Go up to the surface
                    else
                        shouldGoUp = true -- Set the flag to go up to the surface next time
                    end
                else
                    currentMob = nil
                end
            end)
        end
    end

    -- Update the current mob
    currentMob = obj

    local undergroundPos = obj.Position - Vector3.new(0, 30, 0) -- Adjust the Y value based on the desired underground depth

    -- Move to the underground position
    moveToDestination(undergroundPos)
end

Tab:Toggle(
    {
        Name = "Farm Near Mobs",
        Default = false,
        Callback = function(state)
            if state then
                if farmHeartbeatConnection then
                    farmHeartbeatConnection:Disconnect()
                    farmHeartbeatConnection = nil
                end

                farmHeartbeatConnection =
                    rs.Heartbeat:Connect(
                    function()
                        if currentMob and (not currentMob.Parent or currentMob:FindFirstChild("Health") or currentMob:FindFirstChild("Humanoid").Health == 0) then
                            currentMob = nil
                        end

                        if not currentMob then
                            local Mobs = Characters:GetChildren()
                            local nearestModel = nil
                            local nearestDistance = math.huge
                            for i = 1, #Mobs do
                                local v = Mobs[i]
                                if
                                    v.Name ~= "LostSoul" and not v:FindFirstChild("Health") and
                                        v:FindFirstChild("Humanoid").Health ~= 0
                                then
                                    local distance = (v:GetPivot().Position - lp.Character.PrimaryPart.Position).Magnitude
                                    if distance < nearestDistance then
                                        nearestModel = v
                                        nearestDistance = distance
                                    end
                                end
                            end
                            if nearestModel then
                                moveto(nearestModel:GetPivot(), 70) -- Adjust the speed as needed
                            end
                        end
                    end
                )
            else
                if farmHeartbeatConnection then
                    farmHeartbeatConnection:Disconnect()
                    farmHeartbeatConnection = nil
                end

                if currentMob then
                    currentMob = nil
                end
            end
        end
    }
)



local farmHeartbeatConnection23
Tab:Toggle(
    {
        Name = "light Attack",
        Default = false,
        Callback = function(state23)
            if state23 then -- Fixed variable name (state2 instead of state)
                if farmHeartbeatConnection23 then
                    farmHeartbeatConnection23:Disconnect()
                end
                farmHeartbeatConnection23 =
                    rs.Heartbeat:Connect(
                    function()
                        game:GetService("ReplicatedStorage").Remotes.ServerCombatHandler:FireServer("LightAttack")
                    end
                )
            else
                if farmHeartbeatConnection23 then
                    farmHeartbeatConnection23:Disconnect()
                end
            end
        end
    }
)
local farmHeartbeatConnection231
Tab:Toggle(
    {
        Name = "Critical Attack",
        Default = false,
        Callback = function(state231)
            if state231 then -- Fixed variable name (state2 instead of state)
                if farmHeartbeatConnection231 then
                    farmHeartbeatConnection231:Disconnect()
                end
                farmHeartbeatConnection231 =
                    rs.Heartbeat:Connect(
                    function()
                        game:GetService("ReplicatedStorage").Remotes.ServerCombatHandler:FireServer("CriticalAttack")
                    end
                )
            else
                if farmHeartbeatConnection231 then
                    farmHeartbeatConnection231:Disconnect()
                end
            end
        end
    }
)

local AutoParry
Tab:Toggle(
    {
        Name = "Auto Block/Parry?",
        Default = false,
        Callback = function(state22d)
            AutoParry = state22d
        end
    }
)

spawn(function()
    while true do
        task.wait(.25)
        if AutoParry then
            pcall(
                function()
                    local characterHandler = lp.Character.CharacterHandler
                    local blockRemote = characterHandler.Remotes.Block
        
                    local shouldBlock = false
        
                    for _, player in pairs(Characters:GetChildren()) do
                        if player.Name ~= lp.Name then
                            if player and player:FindFirstChild("HumanoidRootPart") then
                                local distance = lp:DistanceFromCharacter(player.HumanoidRootPart.Position)
                                if distance <= 8 then
                                    local currentState = player:GetAttribute("CurrentState")
                                    if currentState ~= "Idle" and currentState ~= "Sprinting" and currentState ~= "WeaponDrawn" and currentState ~= "Unconscious" then
                                        shouldBlock = true
                                        break
                                    end
                                end
                            end
                        end
                    end
        
                    if shouldBlock then
                        blockRemote:FireServer("Pressed")
                    else
                        blockRemote:FireServer("Released")
                    end
                end
            )
        end
    end
end)

local PlayersTable = {}
for i,v in pairs(Characters:GetChildren()) do 
    if v:FindFirstChild("Health") and v.Name ~= lp.Name then 
        table.insert(PlayersTable, v.Name) 
    end
end
local Dropdown = Tab:Dropdown(
    {
        Name = "Select Player",
        Items = {table.unpack(PlayersTable)}, -- Table
        Callback = function(PlayerSelected)
            SelectedPlayer = PlayerSelected
        end
    }
)
local Button = Tab:Button({
    Name = "Update Dropdown",
    Callback = function()
        PlayersTable = {} -- Clear the PlayersTable before updating
        for i, v in pairs(Characters:GetChildren()) do
            if v:FindFirstChild("Health") and v.Name ~= lp.Name then
                table.insert(PlayersTable, v.Name)
            end
        end
        Dropdown:Clear() -- Clear the existing dropdown items
        Dropdown:UpdateList({
            Items = PlayersTable,
            Replace = true
        })
    end
})


local farmHeartbeatConnection2

Tab:Toggle(
    {
        Name = "Farm Selected Player",
        Default = false,
        Callback = function(state2)
            if state2 then -- Fixed variable name (state2 instead of state)
                if farmHeartbeatConnection2 then
                    farmHeartbeatConnection2:Disconnect()
                end
                farmHeartbeatConnection2 =
                    rs.Heartbeat:Connect(
                    function()
                        for i,v in pairs(Characters:GetChildren()) do 
                            if v.Name == SelectedPlayer then 
                                repeat
                                    task.wait() 
                                    moveto(v:GetPivot(), 70)
                                until v:FindFirstChild("Humanoid").Health == 0 or not state2 -- Changed from 'state2' to 'not state2' to exit the loop when the toggle is turned off
                            end
                        end
                    end
                )
            else
                if farmHeartbeatConnection2 then
                    farmHeartbeatConnection2:Disconnect()
                end
            end
        end
    }
)

Tab:Dropdown(
    {
        Name = "NPC Teleports",
        Items = {table.unpack(NPCs)}, -- Table
        Callback = function(NPCSelected)
            local NPCSSS = NPcsFolder:GetDescendants()
            for i = 1, #NPCSSS do
                local v = NPCSSS[i]
                if v.Name == NPCSelected and v:IsA("Model") then
              
                    moveto(v:GetPivot(), 70)

                end
            end
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
local infjumpenabled = false

Tab2:Button(
    {
        Name = "Reset Character",
        Callback = function()
            lp.Character.Humanoid.Health = 0
        end
    }
)

Tab2:Button(
    {
        Name = "BTools",
        Callback = function()
            local tool1 = Instance.new("HopperBin", lp.Backpack)
            local tool2 = Instance.new("HopperBin", lp.Backpack)
            local tool3 = Instance.new("HopperBin", lp.Backpack)
            local tool4 = Instance.new("HopperBin", lp.Backpack)
            local tool5 = Instance.new("HopperBin", lp.Backpack)
            tool1.BinType = "Clone"
            tool2.BinType = "GameTool"
            tool3.BinType = "Hammer"
            tool4.BinType = "Script"
            tool5.BinType = "Grab"
        end
    }
)

Tab2:Toggle(
    {
        Name = "Noclip",
        Default = false, -- Default Value
        Callback = function(NoclIp)
            _G.NoclIp2 = NoclIp or false
            game:GetService("RunService").Stepped:connect(
                function()
                    if _G.NoclIp2 then
                        noclip()
                    end
                end
            )
        end
    }
)

game:GetService("UserInputService").JumpRequest:Connect(
    function()
        if infjumpenabled then
            game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end
    end
)

Tab2:Toggle(
    {
        Name = "Inf Jump",
        Default = false, -- Default Value
        Callback = function(InfJUmp)
            infjumpenabled = InfJUmp
        end
    }
)
Tab2:Slider(
    {
        Name = "HipHeight",
        Min = 0, -- Min Val
        Max = 200, -- Max Val
        Default = 0, -- Default Val
        Callback = function(val22)
            lp.Character.Humanoid.HipHeight = val22
        end
    }
)

Tab2:Slider(
    {
        Name = "Jump Power",
        Min = 1,
        Max = 300,
        Default = 16,
        Callback = function(value)
            _G.HackedJumpPower = (value)

            local Plrs = game:GetService("Players")

            local MyPlr = Plrs.LocalPlayer
            local MyChar = MyPlr.Character

            if MyChar then
                local Hum = MyChar.Humanoid
                Hum.Changed:connect(
                    function()
                        Hum.JumpPower = _G.HackedJumpPower
                    end
                )
                Hum.JumpPower = _G.HackedJumpPower
            end

            MyPlr.CharacterAdded:connect(
                function(Char)
                    MyChar = Char
                    repeat
                        wait()
                    until Char:FindFirstChild("Humanoid")
                    local Hum = Char.Humanoid
                    Hum.Changed:connect(
                        function()
                            Hum.JumpPower = _G.HackedJumpPower
                        end
                    )
                    Hum.JumpPower = _G.HackedJumpPower
                end
            )
        end
    }
)

Tab2:Slider(
    {
        Name = "Walkspeed",
        Min = 1,
        Max = 300,
        Default = 16,
        Callback = function(value)
            _G.HackedWalkSpeed = (value)

            local Plrs = game:GetService("Players")

            local MyPlr = Plrs.LocalPlayer
            local MyChar = MyPlr.Character

            if MyChar then
                local Hum = MyChar.Humanoid
                Hum.Changed:connect(
                    function()
                        Hum.WalkSpeed = _G.HackedWalkSpeed
                    end
                )
                Hum.WalkSpeed = _G.HackedWalkSpeed
            end

            MyPlr.CharacterAdded:connect(
                function(Char)
                    MyChar = Char
                    repeat
                        wait()
                    until Char:FindFirstChild("Humanoid")
                    local Hum = Char.Humanoid
                    Hum.Changed:connect(
                        function()
                            Hum.WalkSpeed = _G.HackedWalkSpeed
                        end
                    )
                    Hum.WalkSpeed = _G.HackedWalkSpeed
                end
            )
        end
    }
)
local camera = workspace.CurrentCamera
local entitiesFolder = workspace.Entities
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local espEnabled = false

local function esp(entity)
   local humanoid = entity:FindFirstChild("Humanoid")
   local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart")

   if not humanoid or not humanoidRootPart then
       return
   end

   local textLabel = Drawing.new("Text")
   textLabel.Visible = false
   textLabel.Center = true
   textLabel.Outline = true
   textLabel.Font = 1
   textLabel.Color = Color3.fromRGB(35, 251, 2)
   textLabel.Size = 15

   local ancestryChangedConnection
   local healthChangedConnection
   local renderSteppedConnection

   local function disconnectConnections()
       textLabel.Visible = false
       textLabel:Remove()
       if ancestryChangedConnection then
           ancestryChangedConnection:Disconnect()
           ancestryChangedConnection = nil
       end
       if healthChangedConnection then
           healthChangedConnection:Disconnect()
           healthChangedConnection = nil
       end
       if renderSteppedConnection then
           renderSteppedConnection:Disconnect()
           renderSteppedConnection = nil
       end
   end

   ancestryChangedConnection = entity.AncestryChanged:Connect(function(_, parent)
       if not parent then
           disconnectConnections()
       end
   end)

   healthChangedConnection = humanoid.HealthChanged:Connect(function(health)
       if health <= 0 then
           disconnectConnections()
       end
   end)

   renderSteppedConnection = runService.RenderStepped:Connect(function()
       local hrpPosition, hrpOnScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
       if hrpOnScreen then
           local distance = math.floor((humanoidRootPart.Position - camera.CFrame.Position).Magnitude + 0.5)
           textLabel.Position = Vector2.new(hrpPosition.X, hrpPosition.Y)
           textLabel.Text = string.format("%s | Health: %d | Distance: %d studs", entity.Name, humanoid.Health, distance)
           textLabel.Visible = espEnabled
       else
           textLabel.Visible = false
       end
   end)
end

local function entityAdded(entity)
   if entity:IsA("Model") and not entity:FindFirstChild("Health") then
       esp(entity)
   end
   entity.ChildAdded:Connect(function(child)
       if child:IsA("Model") and not child:FindFirstChild("Health") then
           esp(child)
       end
   end)
end

local function toggleESP()
   espEnabled = not espEnabled
   for _, entity in ipairs(entitiesFolder:GetChildren()) do
       if not entity:FindFirstChild("Health") then
           entityAdded(entity)
       end
   end
end

userInputService.InputBegan:Connect(function(input)
   if input.KeyCode == Enum.KeyCode.G then
       toggleESP()
   end
end)

for _, entity in ipairs(entitiesFolder:GetChildren()) do
   if not entity:FindFirstChild("Health") then
       entityAdded(entity)
   end
end

entitiesFolder.ChildAdded:Connect(entityAdded)
local camera = workspace.CurrentCamera
local entitiesFolder = workspace.Entities
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local espEnabled1 = false

local function esp(entity)
   local humanoid = entity:FindFirstChild("Humanoid")
   local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart")

   if not humanoid or not humanoidRootPart then
       return
   end

   local textLabel = Drawing.new("Text")
   textLabel.Visible = false
   textLabel.Center = true
   textLabel.Outline = true
   textLabel.Font = 1
   textLabel.Color = Color3.fromRGB(255, 255, 255)
   textLabel.Size = 15

   local ancestryChangedConnection
   local healthChangedConnection
   local renderSteppedConnection

   local function disconnectConnections()
       textLabel.Visible = false
       textLabel:Remove()
       if ancestryChangedConnection then
           ancestryChangedConnection:Disconnect()
           ancestryChangedConnection = nil
       end
       if healthChangedConnection then
           healthChangedConnection:Disconnect()
           healthChangedConnection = nil
       end
       if renderSteppedConnection then
           renderSteppedConnection:Disconnect()
           renderSteppedConnection = nil
       end
   end

   ancestryChangedConnection = entity.AncestryChanged:Connect(function(_, parent)
       if not parent then
           disconnectConnections()
       end
   end)

   healthChangedConnection = humanoid.HealthChanged:Connect(function(health)
       if health <= 0 then
           disconnectConnections()
       end
   end)

   renderSteppedConnection = runService.RenderStepped:Connect(function()
       local hrpPosition, hrpOnScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
       if hrpOnScreen then
           local distance = math.floor((humanoidRootPart.Position - camera.CFrame.Position).Magnitude + 0.5)
           textLabel.Position = Vector2.new(hrpPosition.X, hrpPosition.Y)
           textLabel.Text = string.format("%s | Health: %d | Distance: %d studs", entity.Name, humanoid.Health, distance)
           textLabel.Visible = espEnabled1
       else
           textLabel.Visible = false
       end
   end)
end

local function entityAdded(entity)
   if entity:IsA("Model") and entity:FindFirstChild("Health") and entity.Name ~= lp.Name then
       esp(entity)
   end
   entity.ChildAdded:Connect(function(child)
       if child:IsA("Model") and child:FindFirstChild("Health") and child.Name ~= lp.Name then
           esp(child)
       end
   end)
end

local function toggleESP()
   espEnabled1 = not espEnabled1
   for _, entity in ipairs(entitiesFolder:GetChildren()) do
       if entity:FindFirstChild("Health") and entity.Name ~= lp.Name then
           entityAdded(entity)
       end
   end
end

userInputService.InputBegan:Connect(function(input)
   if input.KeyCode == Enum.KeyCode.H then
       toggleESP()
   end
end)

for _, entity in ipairs(entitiesFolder:GetChildren()) do
   if entity:FindFirstChild("Health") and entity.Name ~= lp.Name then
       entityAdded(entity)
   end
end

entitiesFolder.ChildAdded:Connect(entityAdded)
