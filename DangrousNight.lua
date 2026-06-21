local success, Fun = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/nightmares.fun-UI-Library/main/source.lua"))()
end)

if not success or not Fun then
    warn("Failed to load UI Library")
    return
end

local success, window = pcall(function()
    return Fun.Create("DNIGHT")
end)

if not success or not window then
    warn("Failed to create UI window")
    return
end

-- Player variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tab setup
local tab = window:Tab("Main")
local itemsSection = tab:Section("Items")
local actionsSection = tab:Section("Actions")

-- Functions with error handling
local function collectAll()
    pcall(function()
        for _, tool in pairs(workspace:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                local prompt = tool.PrimaryPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    tool.Parent = LocalPlayer.Backpack
                end
            end
        end
    end)
end

local function stealPlayersFood()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            game:GetService("ReplicatedStorage").ConsumeToolEvent:FireServer(tool)
                        end
                    end
                end
            end
        end
    end)
end

-- Create dropdown for items with error handling
local Items = {}
local itemNames = {}
local selectedItem

pcall(function()
    for _, v in pairs(workspace.Wyposazenie.MarketWyposazenie:GetChildren()) do 
        if not itemNames[v.Name] then
            table.insert(Items, v.Name)
            itemNames[v.Name] = true
        end
    end
end)

itemsSection:Dropdown("Spawn Items", Items, function(selected)
    pcall(function()
        selectedItem = selected
        local item = workspace.Wyposazenie.MarketWyposazenie[selectedItem]
        if item then
            game:GetService("ReplicatedStorage").PickupItemEvent:FireServer(item)
        end
    end)
end)

-- Add action buttons with error handling
actionsSection:Button("Collect All Tools", function()
    pcall(collectAll)
end)

actionsSection:Button("Steal Players Food", function()
    pcall(stealPlayersFood)
end)
actionsSection:Button("No E Cooldown", function()
    game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
        prompt.HoldDuration = 0
    end)
end)