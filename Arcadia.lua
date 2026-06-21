-- Load UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3"))()

-- Create UI
local w = library:CreateWindow("Arcadia")
local b = w:CreateFolder("B")

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Remotes
local StartBattleRemote = ReplicatedStorage.Remotes.StartBattle
local MineOreRemote = ReplicatedStorage.Remotes.MineOre
local FinishBattleRemote = ReplicatedStorage.Remotes.Dead
local QuestCompleteRemote = ReplicatedStorage.Remotes.EnableQuestStat

-- Game Data
local fightsFolder = ReplicatedStorage:FindFirstChild("Fights")
local oreSpawns = workspace.Map.OreSpawns
local quests = LocalPlayer:FindFirstChild("Quests")

-- Variables
local battleName = nil
local enemyCount = 1
local isActive = true

-- Function to Mine All Ores
local function mineAllOres()
    for _, obj in pairs(oreSpawns:GetDescendants()) do
        if obj:IsA("Model") then
            MineOreRemote:FireServer(obj)
        end
    end
    print("Mined all ores.")
end

-- Function to Finish Current Battle
local function finishCurrentBattle()
    if fightsFolder then
        for _, item in ipairs(fightsFolder:GetDescendants()) do
            if string.find(item.Name, LocalPlayer.Name) then
                local battle = item.Parent.Parent
                for _, v in pairs(battle.Team2:GetChildren()) do
                    FinishBattleRemote:FireServer(v, battle, isActive)
                end
            end
        end
    end
    print("Finished current battle.")
end

-- Function to Start Battle
local function startBattle()
    if not battleName then
        print("Error: No battle name set!")
        return
    end
    
    -- Create enemy list based on selected count
    local enemies = {}
    for i = 1, enemyCount do
        table.insert(enemies, battleName)
    end

    -- Send battle start request
    StartBattleRemote:FireServer({[1] = LocalPlayer}, enemies, isActive)
    print("Started battle with " .. enemyCount .. "x " .. battleName)
end

-- Function to Complete All Quests
local function completeAllQuests()
    if quests then
        for _, quest in pairs(quests:GetChildren()) do
            for step = 1, 2 do
                local questStep = quest:FindFirstChild("Steps") and quest.Steps:FindFirstChild(tostring(step))
                if questStep then
                    QuestCompleteRemote:FireServer(questStep)
                end
            end
        end
        print("Completed all quests.")
    else
        print("No quests found.")
    end
end

-- UI Buttons
b:Button("Mine All Ores", mineAllOres)
b:Button("Finish Current Battle", finishCurrentBattle)

b:Box("Mob", "string", function(value) 
    battleName = value
    print("Battle Name Set To: " .. battleName)
end)

b:Box("Enemy Count", "number", function(value)
    enemyCount = tonumber(value) or 1 -- Ensure it's a valid number
    print("Enemy Count Set To: " .. enemyCount)
end)

b:Button("Start Battle", startBattle)
b:Button("Complete All Quests", completeAllQuests)
