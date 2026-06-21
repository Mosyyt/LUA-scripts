local Players = game.Players
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()

local w = library:CreateWindow("Combat") -- Creates the window

local b = w:CreateFolder("Functions") -- Creates the folder(U will put here your buttons,etc)
local Mobs = {}
local SelectedMob
local MobsFolder = workspace.MobFolder
local MobsNameFolder = game:GetService("ReplicatedStorage").MobDrops
local CurrentMob
local FarmSelectdMobConnection
local MobInstaKillConnection

local WeaponReachConnection
local reachDistance


for i, v in pairs(MobsNameFolder:GetChildren()) do
    table.insert(Mobs, v.Name)
end
function grabWeapon()
    for _, v in pairs(lp.Character:GetChildren()) do
        local damagePart = v:FindFirstChildWhichIsA("BasePart")
        if damagePart and string.find(damagePart.Name, "Damage") then
            return v, damagePart
        end
    end
end

local weapon, damagePart = grabWeapon()


b:Dropdown("Select Mob",Mobs,true,function(MobSSSS) --true/false, replaces the current title "Dropdown" with the option that t
    SelectedMob = MobSSSS
    print(SelectedMob)
end)
local function FindNextValidMob()
    local mobs = MobsFolder:GetChildren()
    for i = 1, #mobs do
        local v = mobs[i]
        local humanoid = v:FindFirstChildOfClass("Humanoid")
        if v.Name == SelectedMob and humanoid and humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            return v
        end
    end
end

local function MoveToNextMob()
    if MobsFolder and MobsFolder:FindFirstChild(SelectedMob) then
        CurrentMob = CurrentMob or FindNextValidMob()

        if CurrentMob then
            local humanoid = CurrentMob:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                repeat
                    task.wait()
                 
                    lp.Character.HumanoidRootPart.CFrame = CurrentMob:GetPivot() * CFrame.Angles(math.rad(-90), 0, 0) + Vector3.new(0, 6, 0)
                until not CurrentMob or not FarmSelectdMobConnection or humanoid.Health == 0

                CurrentMob = FindNextValidMob()
            else
                CurrentMob = FindNextValidMob()
            end
        end
    end
end

b:Toggle(
    "Farm Selected Mob",
    function(state)
        if state then
            FarmSelectdMobConnection = rs.Heartbeat:Connect(function()
                MoveToNextMob()
            end)
        else
            if FarmSelectdMobConnection then
                FarmSelectdMobConnection:Disconnect()
                FarmSelectdMobConnection = nil
            end
        end
    end
)
b:Toggle(
    "Mob Insta Kill",
    function(state1)
        if state1 then
            MobInstaKillConnection = rs.Heartbeat:Connect(
                function()
                Mobs = MobsFolder:GetChildren()
                for i = 1, #Mobs do
                    local v = Mobs[i]
                        local MobDistanceTOPlayer =
                            (lp.Character.HumanoidRootPart.Position - v:GetPivot().Position).Magnitude
                        if MobDistanceTOPlayer < 12 and v:FindFirstChild("MobArea") and v:FindFirstChildOfClass("Humanoid").Health ~= 0 then
                            game:GetService("ReplicatedStorage").Events.DamageEvents.DamageDetect:FireServer(true,"Attack", v.MobArea, damagePart)
                            game:GetService("ReplicatedStorage").Events.DamageEvents.DamageDetect:FireServer(true,"Attack", v.MobArea, damagePart)
                            game:GetService("ReplicatedStorage").Events.DamageEvents.DamageDetect:FireServer(true,"Attack", v.MobArea, damagePart)
                            game:GetService("ReplicatedStorage").Events.DamageEvents.DamageDetect:FireServer(true,"Attack", v.MobArea, damagePart)
                            game:GetService("ReplicatedStorage").Events.DamageEvents.DamageDetect:FireServer(true,"Attack", v.MobArea, damagePart)
                            game:GetService("ReplicatedStorage").Events.DamageEvents.DamageDetect:FireServer(true,"Attack", v.MobArea, damagePart)
                        end
                    end
                end
            )
        else
            if MobInstaKillConnection then
                MobInstaKillConnection:Disconnect()
                MobInstaKillConnection = nil
            end
        end
    end
)
b:Slider("Reach Distance",{
    min = 1; -- min value of the slider
    max = 80; -- max value of the slider
    precise = true; -- max 2 decimals
},function(value)
    reachDistance = value
    print(reachDistance)
end)
b:Toggle(
    "Weapon Reach",
    function(state25)
        if state25 then
            WeaponReachConnection =
                rs.Heartbeat:Connect(
                function()
                    for _, v in pairs(MobsFolder:GetChildren()) do
                        local mobArea = v:FindFirstChild("MobArea")
                        if mobArea then
                            local distance = (mobArea.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                            if distance <= reachDistance then
                                if damagePart then
                                    firetouchinterest(damagePart, mobArea, 0)
                                    firetouchinterest(damagePart, mobArea, 1)
                                end
                            end
                        end
                    end
                end
            )
        else
            if WeaponReachConnection then
                WeaponReachConnection:Disconnect()
                WeaponReachConnection = nil
            end
        end
    end
)
local MiscTab = library:CreateWindow("Misc")
local x = MiscTab:CreateFolder("Functions")
local Dupe
local DupeConnection
local function PickupItems()
    for _, v in pairs(workspace.Chests:GetChildren()) do
        local itemsInsideItem = v:FindFirstChild("Item")
        local distance = (v:GetPivot().Position - lp.Character.HumanoidRootPart.Position).Magnitude
        if itemsInsideItem and distance <= 50 then
            for _, item in pairs(itemsInsideItem:GetChildren()) do
                game.ReplicatedStorage.Events.ItemEvents.ItemPickup:FireServer(v, item.Name, "Chest")
                task.wait(.2)
            end
        end
    end
end
local ChestsTable = {}

function UpdateChests()
    ChestsTable = {} -- Clear the table before updating
    for _, v in pairs(workspace.Chests:GetChildren()) do
        table.insert(ChestsTable, v.Name)
    end
end

UpdateChests()

local dropdownd = x:Dropdown("Chests Dropdown", ChestsTable, true, function(Csss)
    lp.Character:PivotTo(workspace.Chests[Csss]:GetPivot())
end)

workspace.Chests.ChildAdded:Connect(function()
    UpdateChests()
    dropdownd:Refresh(ChestsTable)
end)

workspace.Chests.ChildRemoved:Connect(function(removedChest)
    UpdateChests()
    dropdownd:Refresh(ChestsTable)
end)
x:Label("Go near a chest and toggle it",{
    TextSize = 17; -- Self Explaining
    TextColor = Color3.fromRGB(255,255,255); -- Self Explaining
    BgColor = Color3.fromRGB(69,69,69); -- Self Explaining
    
}) 
local DupeConnection

x:Toggle(
    "Dupe Chest Items",
    function(isToggled)
        Dupe = isToggled
        
        if Dupe then
            if not DupeConnection then
                DupeConnection = rs.Heartbeat:Connect(function()
                    PickupItems()
                end)
            end
        else
            if DupeConnection then
                DupeConnection:Disconnect()
                DupeConnection = nil
            end
        end
    end
)


x:Toggle(
    "Inf Stamina",
    function(sss)
       local State = sss
        game:GetService("Players").LocalPlayer.LeadStats.Stamina:GetPropertyChangedSignal("Value"):Connect(
            function()
                if State then
                    game:GetService("Players").LocalPlayer.LeadStats.Stamina.Value =
                        game:GetService("Players").LocalPlayer.LeadStats.MaxStamina.Value
                end
            end
        )
    end
)

x:Toggle(
    "No Dodge Cooldown",
    function(sss1)
        local State1 = sss1
        lp.Character.Dodging:GetPropertyChangedSignal("Value"):Connect(
            function()
                if State1 then
                    lp.Character.Dodging.Value = false
                end
            end
        )
    end
)

x:Toggle(
    "Anti KB",
    function(sss1s)
        local State1s = sss1s
        lp.Character.Knockbacked:GetPropertyChangedSignal("Value"):Connect(
            function()
                if State1s then
                    lp.Character.Knockbacked.Value = false
                end
            end
        )
    end
)
