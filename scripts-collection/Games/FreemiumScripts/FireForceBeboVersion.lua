local players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = players.LocalPlayer
local Characters = workspace.Alive
local VirtualInputManager = game:GetService("VirtualInputManager")

local Library =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))(

)
local mobNames = {'AdultCivilianNPC', 'Amaterasu', 'Backpacker', 'BerserkerInfernal', 'Brandon', 'CarThief', 'ChildCivilianNPC', 'ChildNPC', 'CrawlerInfernal', 'Curt', 'ExplodingInfernal', 'FireForceScientist', 'Girl', 'Inca', 'Infernal', 'Infernal Demon', 'Infernal Oni', 'Infernal2', 'LightningNPC', 'OldLady', 'OldMan', 'Parry Block', 'Parry No Block', 'Pedro', 'PurseNPC', 'PurseNPC', 'RealExaminer', 'Shadow', 'ShoNPC', 'ShoTest', 'SummoningInfernal', 'Thug1', 'ThugNPC', 'UnknownExaminer', 'WhiteCladDefender1', 'WhiteCladScout', 'WhiteCladTraitor1', 'WhiteCladTraitor2'}
local SelectedMob
local Distance
local function clickUiButton(v, state)
	VirtualInputManager:SendMouseButtonEvent(v.AbsolutePosition.X + v.AbsoluteSize.X / 2, v.AbsolutePosition.Y + 66, 0, state, game, 1)
end
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
        Name = "Fire Force",
        Description = "Codexus Hub",
        Icon = "rbxassetid://11254763826", -- Tab Icon
        Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
        Hidden = false -- IGNORE THIS
    }
)
Tab:Dropdown(
    {
        Name = "Select Mob",
        Items = mobNames, -- Table
        Callback = function(Mob)
            SelectedMob = Mob
        end
    }
)
Tab:Slider(
    {
        Name = "Mob Distance",
        Min = 1, -- Min Val
        Max = 8, -- Max Val
        Default = 5, -- Default Val
        Callback = function(DSSA)
            Distance = DSSA
        end
    }
)
local FarmSelected
local TweenService = game:GetService("TweenService")
local noclipE = false
local antifall = true

local function noclip()
    for i, v in pairs(lp.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide == true then
            v.CanCollide = false
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

local function moveto(obj, speed, dist)
    local info = TweenInfo.new(((lp.Character.HumanoidRootPart.Position -
                                   obj.Position).Magnitude) / speed,
                               Enum.EasingStyle.Linear)
    local tween = TweenService:Create(lp.Character.HumanoidRootPart, info,
                                      {CFrame = obj + dist})

    if not lp.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
        antifall = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
        antifall.Velocity = Vector3.new(0, 0, 0)
        noclipE = game:GetService("RunService").Stepped:Connect(noclip)
        tween:Play()
    end

    tween.Completed:Connect(function()
        antifall:Destroy()
        noclipE:Disconnect()
    end)
end
Tab:Toggle(
    {
        Name = "Farm Mob",
        Default = false,
        Callback = function(state1)
            if state1 then
                FarmSelected =
                    rs.Heartbeat:Connect(
                    function()
                        if not CurrentMob or not CurrentMob:FindFirstChildOfClass("Humanoid") or
                            (CurrentMob:FindFirstChildOfClass("Humanoid") and CurrentMob:FindFirstChildOfClass("Humanoid").Health == 0) or
                            not CurrentMob:FindFirstChild("HumanoidRootPart")
                        then
                            CurrentMob = nil
                            local Mobs = Characters:GetChildren()
                            for i = 1, #Mobs do
                                local v = Mobs[i]
                                if
                                    v.Name == SelectedMob and
                                    (v:FindFirstChildOfClass("Humanoid") and v:FindFirstChildOfClass("Humanoid").Health > 0) and
                                    v:FindFirstChild("HumanoidRootPart") and lp.Character
                                then
                                    local head = v:FindFirstChild("Head")
                                    local missionMarker = head and head:FindFirstChild("MissionMarker")
                                    if not missionMarker or not (missionMarker:FindFirstChild("ImageLabel") and missionMarker.ImageLabel.Visible) then
                                        CurrentMob = v
                                        break
                                    end
                                end
                            end
                        end

                        if CurrentMob and lp.Character then
                            local knockedValue = CurrentMob:FindFirstChild("Knocked")
                            if not knockedValue then
                                    moveto(CurrentMob.Head.CFrame ,100,Vector3.new(0, 0, 0))
                            else
                                game:GetService("ReplicatedStorage").Events.GripEvent:FireServer(false, CurrentMob)
                            end
                        end
                    end
                )
            else
                if FarmSelected then
                    FarmSelected:Disconnect()
                end
            end
        end
    }
)
local function KillAuraF(KADistance)
    for i, v in pairs(workspace.Alive:GetChildren()) do
        local knockedValue = v:FindFirstChild("Knocked")
        local carriedValue = v:FindFirstChild("Carried")
        
        if lp.Character and v.Name ~= lp.Name and not carriedValue then
            local targetPosition = nil
            if v:FindFirstChild("Head") then
                targetPosition = v.Head.Position
            elseif v:FindFirstChild("HumanoidRootPart") then
                targetPosition = v.HumanoidRootPart.Position
            end

            if targetPosition and lp:DistanceFromCharacter(targetPosition) <= KADistance and not knockedValue then
                game:GetService("ReplicatedStorage").Events.CombatEvent:FireServer(
                    math.random(1, 3),
                    lp.Character.FistCombat,
                    v:GetPivot(),
                    true
                )
                game:GetService("ReplicatedStorage").Events.M2Event:FireServer(lp.Character.FistCombat, 0, true)
            end
        end
    end
end



local KillAura 

Tab:Toggle(
    {
        Name = "Kill Aura",
        Default = false,
        Callback = function(KillAura2)
            if KillAura2 then
                KillAura =
                    rs.Heartbeat:Connect(
                    function()
                        KillAuraF(13)
                    end
                )
            else
                if KillAura then
                    KillAura:Disconnect()
                end
            end
        end
    }
)

local DTraining = false
Tab:Toggle({
    Name = "Defense Training",
    Default = false,
    Callback = function(bool312)
        DTraining = bool312
    end
})

task.spawn(function()
    while true do
        if DTraining then
            for _, v in ipairs(lp.PlayerGui.TrainingGui.KeyOrder:GetChildren()) do
                if v:IsA("Frame") then
                    local keyText = v.Key and v.Key.Text
                    if keyText then
                        game:GetService("ReplicatedStorage").Events.TrainingEvent:FireServer("Defense", keyText)
                    end
                end
            end
        end
        task.wait(.1) 
    end
end)

local StrengthTraining

Tab:Toggle(
    {
        Name = "Strength Training",
        Default = false,
        Callback = function(StrengthTraining2)
            if StrengthTraining2 then
                StrengthTraining =
                    rs.Heartbeat:Connect(
                    function()
                        local playerGui = lp:FindFirstChildOfClass("PlayerGui")
                        if playerGui then
                            local trainingGui = playerGui.TrainingGui
                            local clickButton =
                                trainingGui and trainingGui.KeyArea and
                                trainingGui.KeyArea:FindFirstChild("ClickButton")
                            if clickButton then
                                clickUiButton(clickButton, true)
                                clickUiButton(clickButton, false)
                            end
                        end
                    end
                )
            else
                if StrengthTraining then
                    StrengthTraining:Disconnect()
                end
            end
        end
    }
)
local Markers = {}

local function UpdateMarkers()
    for i, v in ipairs(workspace.AllMissionMarkers:GetChildren()) do 
        table.insert(Markers, v.Name)
    end
end

UpdateMarkers()

local Dropdown = Tab:Dropdown({
    Name = "Select Marker",
    Items = Markers,
    Callback = function(item)
        game.Players.LocalPlayer.Character:PivotTo(workspace.AllMissionMarkers[item].Adornee:GetPivot())
    end
})



Tab:Button({
    Name = "UpdateButton",
    Text = "Update Dropdown",
    Callback = function()
        UpdateMarkers()
        Dropdown:UpdateList({
            Items = Markers,
            Replace = true
        })
    end
})

--- Update Markers
workspace.AllMissionMarkers.ChildAdded:Connect(function()
    UpdateMarkers()
    Dropdown:UpdateList({
        Items = Markers,
        Replace = true
    })
end)
workspace.AllMissionMarkers.ChildRemoved:Connect(function()
    UpdateMarkers()
    Dropdown:UpdateList({
        Items = Markers,
        Replace = true
    })
end)
---

local selectedPlayer
local PlayersTable = {}

local function UpdatePlayers()
    PlayersTable = {}
    for i, v in ipairs(game.Players:GetPlayers()) do 
        table.insert(PlayersTable, v.Name)
    end
end

UpdatePlayers()

local Dropdown4 = Tab:Dropdown({
    Name = "Select Player",
    Items = PlayersTable,
    Callback = function(Player91)
        selectedPlayer = Player91
    end
})

local PlayerFarmTP 

Tab:Toggle({
    Name = "Farm Player",
    Default = false,
    Callback = function(PlayerFarmTP2)
        if PlayerFarmTP2 then
            PlayerFarmTP =
                rs.Heartbeat:Connect(
                function()
                    for i, v in pairs(workspace.Alive:GetChildren()) do
                        if lp.Character and v.Name ~= lp.Name and v.Name == selectedPlayer and v.Humanoid.Health > 5 and not v:FindFirstChild("Knocked") then
                            moveto(v:GetPivot() ,100,Vector3.new(0, 0, 0))
                            KillAuraF(10)
                        end
                    end
                end
            )
        else
            if PlayerFarmTP then
                PlayerFarmTP:Disconnect()
            end
        end
    end
})

-- Update PlayersTable and Dropdown when players join or leave the game
game.Players.PlayerAdded:Connect(function(player)
    UpdatePlayers()
    Dropdown4:UpdateList({
        Items = PlayersTable,
        Replace = true
    })
end)

game.Players.PlayerRemoving:Connect(function(player)
    UpdatePlayers()
    Dropdown4:UpdateList({
        Items = PlayersTable,
        Replace = true
    })
end)