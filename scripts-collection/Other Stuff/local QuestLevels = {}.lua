local QuestLevels = {}
local MobNames = {}
local CurrentLevel = 0

local Players = game.Players
local lp = Players.LocalPlayer

local function UpdatePlayerLevel()
    CurrentLevel = lp.PlayerData.Experience.Level.Value
end
UpdatePlayerLevel()
for _, v in pairs(workspace.Npc_Workspace.QuestGivers:GetDescendants()) do
    local level = string.match(v.Name, "Level (%d+)")
    if level then
        local index = v.Parent.Parent.Parent.Name
        QuestLevels[index] = tonumber(level)
        MobNames[tonumber(level)] = {}
        for i, mobs in pairs(v:GetChildren()) do
            if mobs:FindFirstChildOfClass("Folder") then
                table.insert(MobNames[tonumber(level)], mobs.Name)
            end
        end
    end
end

local function FindBestQuestLevel()
    local bestQuestLevel, bestMobNames, bestQuestIndex

    for index, level in pairs(QuestLevels) do
        if CurrentLevel >= level and (not bestQuestLevel or level > bestQuestLevel) then
            bestQuestLevel = level
            bestMobNames = MobNames[level]
            bestQuestIndex = index
        end
    end
    return bestQuestLevel, bestMobNames, bestQuestIndex
end

local bestQuestLevel, bestMobNames, bestQuestIndex = FindBestQuestLevel()
UpdatePlayerLevel()
local antifall = true


local function noclip()
    for i, v in pairs(lp.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide == true then
            v.CanCollide = false
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end
local mobReached = false
local function moveto(obj, speed)
    local info = TweenInfo.new(((lp.Character.HumanoidRootPart.Position - obj.Position).Magnitude) / speed, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(lp.Character.HumanoidRootPart, info, {CFrame = obj}) 

    if not lp.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
        antifall = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
        antifall.Velocity = Vector3.new(0, 0, 0)
        local noclipE = game:GetService("RunService").Stepped:Connect(noclip)
        tween:Play()
        tween.Completed:Connect(function()
            antifall:Destroy()
            noclipE:Disconnect()
            mobReached = true
        end)
    end
end
local CurrentMob = nil  -- Initialize the current target as nil

game:GetService("RunService").Heartbeat:Connect(function()
    local bestQuestLevel, bestMobNames, bestQuestIndex = FindBestQuestLevel()

    if bestQuestLevel then
        if not CurrentMob or not CurrentMob:FindFirstChild("Humanoid") then
            CurrentMob = nil
            for _, mobName in pairs(bestMobNames) do
                for _, v in pairs(workspace["NPC Zones"]:GetDescendants()) do
                    local humanoid = v:FindFirstChild("Humanoid")
                    if string.match(v.Name, mobName) and v ~= nil and humanoid and humanoid.Health > 0 then
                        CurrentMob = v
                        mobReached = false
                        break
                    end
                end
            end
        end
        if lp.Character.Humanoid.Health == 0 then
            mobReached = false
        end
        if  mobReached == false and CurrentMob then
            moveto(CurrentMob:GetPivot(), 170)
        elseif mobReached == true and CurrentMob then
            moveto(CFrame.new(CurrentMob.HumanoidRootPart.Position + Vector3.new(0, 7,0),CurrentMob.HumanoidRootPart.Position), 200)
        end
    end
end)
game:GetService("TweenService"):Create(
    lp.Character.HumanoidRootPart,
    TweenInfo.new(
        game.Players.LocalPlayer:DistanceFromCharacter(CurrentMob:FindFirstChild("HumanoidRootPart").Position) / 100
    ),
    {
        CFrame = CFrame.new(CurrentMob.HumanoidRootPart.Position + Vector3.new(0, 7,0),CurrentMob.HumanoidRootPart.Position)
    }
)
tween:Play()
