pcall(function() game:GetService("Workspace").Live.Script:Destroy() end)

local Players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local infjumpenabled = false

local Library = loadstring(game:HttpGet(
                               "https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))()
local Tools = {
    "Nagi Nagi no mi", "Suke Suke no mi", "Guru Guru no mi", "Sube Sube No mi",
    "Dark Magic (Simon)", "Purple Flare", "Airwalk", "Blaze", "Mera Mera no mi",
    "Zushi Zushi no mi", "Goro Goro no mi", "Suna Suna no mi",
    "Moku Moku no mi", "Yami Yami no mi", "Gomu Gomu no mi", "Pika Pika no mi",
    "Hie Hie no mi", "Anti Magic", "Sunshine (Escanor)"
}

local Mobs = {}
local Quests = {}
local SelectedMob
local SelectedQuest
local Distance
local CurrentMob

for i, v in pairs(game.workspace.Live:GetChildren()) do
    table.insert(Mobs, v.Name)
end
for i, v in pairs(game:GetService("Workspace").QuestBoards:GetDescendants()) do
    if string.find(v.Name, "Defeat") then table.insert(Quests, v.Name) end
end
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
Mobs = RemoveTableDupes(Mobs)

-- Window
local Window = Library:Create({ToggleKey = Enum.KeyCode.Insert})

-- Tab
local Tab = Window:Tab({
    Name = "Project XXL",
    Description = "Codexus Hub",
    Icon = "rbxassetid://11254763826", -- Tab Icon
    Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
    Hidden = false -- IGNORE THIS
})
-- Section
Tab:Section({Name = "~Functions~"})
Tab:Label({Text = "Enjoy!!"})

Tab:Dropdown({
    Name = "Select Mob",
    Items = {table.unpack(Mobs)}, -- Table
    Callback = function(MobSelected) SelectedMob = MobSelected end
})

Tab:Slider({
    Name = "Mob Distance",
    Min = 1, -- Min Val
    Max = 8, -- Max Val
    Default = 5, -- Default Val
    Callback = function(DSSA) Distance = DSSA end
})
local FarmSelected
Tab:Toggle({
    Name = "Farm Mob",
    Default = false,
    Callback = function(state22)
        if state22 then
            FarmSelected = rs.Heartbeat:connect(function()
                if not CurrentMob or not CurrentMob:FindFirstChild("Humanoid") or
                    not CurrentMob:FindFirstChild("HumanoidRootPart") then
                    CurrentMob = nil
                    Mobs = game.workspace.Live:GetChildren()
                    for i = 1, #Mobs do
                        local v = Mobs[i]
                        if v.Name == SelectedMob and v ~= nil and
                            v.Humanoid.Health > 0 and
                            v:FindFirstChild("HumanoidRootPart") then
                            CurrentMob = v
                            break
                        end
                    end
                end

                if CurrentMob then
                    lp.Character.Humanoid:ChangeState(11)
                    lp.Character.HumanoidRootPart.CFrame =
                        CurrentMob.HumanoidRootPart.CFrame *
                            CFrame.Angles(math.rad(-90), 0, 0) +
                            Vector3.new(0, Distance, 0)
                end
            end)
            return
        end
        FarmSelected:Disconnect()
    end
})

Tab:Dropdown({
    Name = "Select Quest",
    Items = {table.unpack(Quests)}, -- Table
    Callback = function(Quest) SelectedQuest = Quest end
})
local AutoQuest
Tab:Toggle({
    Name = "Auto Quest",
    Default = false, -- Default Value
    Callback = function(ss11)
        if ss11 then
            AutoQuest = rs.Heartbeat:Connect(function()
                if AutoQuest then
                    if lp.PlayerGui.Menu.QuestFrame.Visible == false then
                        game:GetService("ReplicatedStorage").RemoteEvents
                            .ChangeQuestRemote:FireServer(game:GetService(
                                                              "ReplicatedStorage").Quests[SelectedQuest])
                    end
                end
            end)
            return
        end
        AutoQuest:Disconnect()
    end
})
local ChestFarm
Tab:Toggle({
    Name = "Chest Farm",
    Default = false, -- Default Value
    Callback = function(ss112)
        if ss112 then
            ChestFarm = rs.Heartbeat:Connect(function()
                if ChestFarm then
                    local Chests =
                        game:GetService("Workspace").Chests:GetChildren()
                    for i = 1, #Chests do
                        local v = Chests[i]
                        if v.Transparency == 0 then
                            game:GetService("Players").LocalPlayer.Character
                                .HumanoidRootPart.CFrame = v.CFrame
                            break
                        end
                    end
                end
            end)
            return
        end
        ChestFarm:Disconnect()
    end
})
local KillAura
Tab:Toggle({
    Name = "Kill Aura",
    Default = false, -- Default Value
    Callback = function(ss1122)
        if ss1122 then
            KillAura = rs.Heartbeat:Connect(function()
                if KillAura then
                    local Mobss1 = game.workspace.Live:GetChildren()
                    for i = 1, #Mobss1 do
                        local x = Mobss1[i]
                        if x:FindFirstChild("Humanoid").Health > 0 and
                            x:FindFirstChild("HumanoidRootPart") and
                            lp:DistanceFromCharacter(x.HumanoidRootPart.Position) <
                            15 then
                            game:GetService("ReplicatedStorage").RemoteEvents
                                .BladeCombatRemote:FireServer(false,
                                                              x.HumanoidRootPart
                                                                  .Position,
                                                              x.HumanoidRootPart
                                                                  .CFrame)
                        end
                    end
                end
            end)
            return
        end
        KillAura:Disconnect()
    end
})
local AntiMobs
Tab:Toggle({
    Name = "Anti Mobs",
    Default = false, -- Default Value
    Callback = function(AntiMobs2)
        if AntiMobs2 then
            AntiMobs = rs.Heartbeat:Connect(function()
                if AntiMobs then
                    local Mobss = game.workspace.Live:GetChildren()
                    for i = 1, #Mobss do
                        local v = Mobss[i]
                        if v:FindFirstChild("Humanoid").Health > 0 and
                            v:FindFirstChild("HumanoidRootPart") and
                            lp:DistanceFromCharacter(v.HumanoidRootPart.Position) <
                            12 then
                            v.HumanoidRootPart.CFrame = lp.Character
                                                            .HumanoidRootPart
                                                            .CFrame +
                                                            Vector3.new(10, 0, 0)
                        end
                    end
                end
            end)
            return
        end
        AntiMobs:Disconnect()
    end
})
local Tab2 = Window:Tab({
    Name = "Player",
    Description = "Player Tab",
    Icon = "rbxassetid://6031215978", -- Tab Icon
    Color = Color3.new(1, 0.968627, 0), -- Tab Colour
    Hidden = false -- IGNORE THIS
})
Tab2:Button({
    Name = "Reset Character",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
    end
})

Tab2:Button({
    Name = "BTools",
    Callback = function()
        local tool1 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        local tool2 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        local tool3 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        local tool4 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        local tool5 = Instance.new("HopperBin",
                                   game.Players.LocalPlayer.Backpack)
        tool1.BinType = "Clone"
        tool2.BinType = "GameTool"
        tool3.BinType = "Hammer"
        tool4.BinType = "Script"
        tool5.BinType = "Grab"
    end
})

Tab2:Toggle({
    Name = "Noclip",
    Default = false, -- Default Value
    Callback = function(NoclIp)
        _G.NoclIp2 = NoclIp or false
        game:GetService("RunService").Stepped:connect(function()
            if _G.NoclIp2 then
                pcall(function()
                    lp = game:service "Players".LocalPlayer
                    lp.Character.Head.CanCollide = false
                    lp.Character.LowerTorso.CanCollide = false
                    lp.Character.UpperTorso.CanCollide = false
                    lp.Character.HumanoidRootPart.CanCollide = false
                    if lp.Character:FindFirstChild "Badge" then
                        lp.Character.Badge.CanCollide = false
                    end
                end)
            end
        end)
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infjumpenabled then
        game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(
            "Jumping")
    end
end)

Tab2:Toggle({
    Name = "Inf Jump",
    Default = false, -- Default Value
    Callback = function(InfJUmp) infjumpenabled = InfJUmp end
})

Tab2:Slider({
    Name = "Walkspeed",
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
            Hum.Changed:connect(function()
                Hum.JumpPower = _G.HackedJumpPower
            end)
            Hum.JumpPower = _G.HackedJumpPower
        end

        MyPlr.CharacterAdded:connect(function(Char)
            MyChar = Char
            repeat wait() until Char:FindFirstChild("Humanoid")
            local Hum = Char.Humanoid
            Hum.Changed:connect(function()
                Hum.JumpPower = _G.HackedJumpPower
            end)
            Hum.JumpPower = _G.HackedJumpPower
        end)
    end
})

Tab2:Slider({
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
            Hum.Changed:connect(function()
                Hum.WalkSpeed = _G.HackedWalkSpeed
            end)
            Hum.WalkSpeed = _G.HackedWalkSpeed
        end

        MyPlr.CharacterAdded:connect(function(Char)
            MyChar = Char
            repeat wait() until Char:FindFirstChild("Humanoid")
            local Hum = Char.Humanoid
            Hum.Changed:connect(function()
                Hum.WalkSpeed = _G.HackedWalkSpeed
            end)
            Hum.WalkSpeed = _G.HackedWalkSpeed
        end)
    end
})
local Tab3 = Window:Tab({
    Name = "Fruit Sniper",
    Description = "Snipe Fruits",
    Icon = "rbxassetid://6034684937", -- Tab Icon
    Color = Color3.new(0.564705, 0, 1), -- Tab Colour
    Hidden = false -- IGNORE THIS
})
local Option1
local Option2
local Option3
local Option4
local Option5
local Option6
Tab3:Dropdown({
    Name = "Select Fruit 1",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value1) Option1 = Value1 end
})

Tab3:Dropdown({
    Name = "Select Fruit 2",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value2) Option2 = Value2 end
})

Tab3:Dropdown({
    Name = "Select Fruit 3",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value3) Option3 = Value3 end
})

Tab3:Dropdown({
    Name = "Select Fruit 4",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value4) Option4 = Value4 end
})

Tab3:Dropdown({
    Name = "Select Fruit 5",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value5) Option5 = Value5 end
})

Tab3:Dropdown({
    Name = "Select Fruit 6",
    Items = {table.unpack(Tools)}, -- Table
    Callback = function(Value6) Option6 = Value6 end
})
local SnipeFruit
Tab3:Toggle({
    Name = "Auto Snipe Selected",
    Default = false,
    Callback = function(Snipe) SnipeFruit = Snipe end
})

spawn(function()
    while task.wait(1) do
        if SnipeFruit then
            local Sniper = game.workspace:GetChildren()
            for i = 1, #Sniper do
                local v = Sniper[i]
                if v:IsA("Tool") and string.find(v.Name, Option1) or
                    string.find(v.Name, Option2) or string.find(v.Name, Option3) or
                    string.find(v.Name, Option4) or string.find(v.Name, Option5) or
                    string.find(v.Name, Option6) then
                    v.Handle.CFrame = game.Players.LocalPlayer.Character
                                          .PrimaryPart.CFrame
                end
            end
        end
    end
end)
Window:Notify({
    Name = "Notification",
    Text = "Press Insert To Toggle GUI",
    Duration = 5,
    Callback = function() return end -- Callback when the notification ends
})
