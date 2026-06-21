-- Auto Collect Function
local function autoCollect()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local items = workspace.Items:GetChildren()
    
    if #items > 0 then
        -- Save current position before teleporting
        lastPosition = humanoidRootPart.CFrame
        
        -- Collect items if they exist
        for i,v in pairs(items) do 
            -- Get the CFrame to teleport to
            local targetCFrame
            
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                targetCFrame = v.Handle.CFrame
            elseif v:IsA("MeshPart") then
                targetCFrame = v.CFrame
            else
                continue -- Skip if it's neither
            end
            
            -- Teleport to the item
            humanoidRootPart.CFrame = targetCFrame
            
            -- Fire the collect remote
            game:GetService("ReplicatedStorage")["shared/network/MiningNetwork@GlobalMiningEvents"].CollectItem:FireServer(v:GetAttribute("ID"))
            
            task.wait(0.05) -- Small delay between teleports
        end
        
        -- Return to last position after collecting all items
        if lastPosition then
            humanoidRootPart.CFrame = lastPosition
        end
    end
end
local Fun = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/nightmares.fun-UI-Library/main/source.lua"))()
local window = Fun.Create("Mines")
local tab = window:Tab("Functions")
local section = tab:Section("Functions")

-- Variables
local drillAuraEnabled = false
local drillAuraConnection = nil
local autoCollectEnabled = false
local autoCollectConnection = nil
local lastPosition = nil

-- Drill Aura Function
local function drillAura()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local remote = game:GetService("ReplicatedStorage")["shared/network/MiningNetwork@GlobalMiningFunctions"].Drill
    
    -- Get player position
    local playerPos = humanoidRootPart.Position
    
    -- Drill in multiple positions around the player
    for i = 0, 7 do
        local angle = (i / 8) * math.pi * 2
        local x = math.cos(angle) * 8  -- 8 stud radius
        local z = math.sin(angle) * 8
        
        local arguments = {
            [1] = 1,
            [2] = {
                ["direction"] = Vector3.new(x, -7.5, z),  -- Using similar format to your original
                ["heat"] = 0,
                ["overheated"] = false
            }
        }
        
        remote:FireServer(unpack(arguments))
    end
end

-- Get Ruby Drill Function
local function getRubydrill()
    local remote = game:GetService("ReplicatedStorage").Ml.EquipItem
    local player = game:GetService("Players").LocalPlayer
    local backpack = player.Backpack
    
    pcall(function()
        remote:FireServer("Ruby Drill")
    end)
    
    task.wait(0.1)
    local drill = backpack:FindFirstChild("Ruby Drill")
    if not drill then
        local drillModel = game:GetService("ReplicatedStorage").Assets.Models.Drills:FindFirstChild("Ruby Drill")
        if drillModel then
            drill = drillModel:Clone()
            drill.Parent = backpack
            task.wait(0.1)
        else
            warn("Ruby Drill not found anywhere")
            return
        end
    end
    
    if drill:FindFirstChild("Handle") then
        drill.Handle.Anchored = false
    end
    
    task.wait(0.1)
    
    if drill:FindFirstChild("Drill") then
        drill.Drill.Anchored = true
    end
    
    print("Ruby Drill equipped!")
end

-- UI Elements
section:Toggle("OP Aura", function(enabled)
    drillAuraEnabled = enabled
    
    if drillAuraEnabled then
        -- Start the drill aura loop
        task.spawn(function()
            while drillAuraEnabled do
                drillAura()
                task.wait()
            end
        end)
        print("OP Aura: ON")
    else
        -- Stop the drill aura loop
        drillAuraEnabled = false
        print("OP Aura: OFF")
    end
end)

section:Toggle("Auto Collect", function(enabled)
    autoCollectEnabled = enabled
    
    if autoCollectEnabled then
        -- Start the auto collect loop
        task.spawn(function()
            while autoCollectEnabled do
                autoCollect()
                task.wait(0.5) -- Collect every 0.5 seconds
            end
        end)
        print("Auto Collect: ON")
    else
        -- Stop the auto collect loop
        autoCollectEnabled = false
        print("Auto Collect: OFF")
    end
end)

section:Button("Get Ruby Drill", function()
    getRubydrill()
end)
