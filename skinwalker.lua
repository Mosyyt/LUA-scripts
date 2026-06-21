local Fun = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/nightmares.fun-UI-Library/main/source.lua"))()
local window = Fun.Create("skinwalker")

-- Settings
getgenv().settings = {
    auto_shoot = true,
    auto_store = true,
    auto_collect_money = false
}

if getgenv().execute then return end
getgenv().execute = true

-- Services
local replicated_storage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local local_player = players.LocalPlayer
local run_service = game:GetService("RunService")

-- Remotes
local shoot_remote = replicated_storage.Remotes.SniperShot
local store_remote = replicated_storage.Remotes.Store
local skin_walkers = workspace.Runners.Skinwalkers

-- Tabs
local main_tab = window:Tab("Main")
local items_tab = window:Tab("Items")
local misc_tab = window:Tab("Misc")

-- Main Tab Sections
local auto_section = main_tab:Section("Auto Functions")
local kill_section = main_tab:Section("Kill Functions")

-- Items Tab Sections
local give_section = items_tab:Section("Give Items")

-- Misc Tab Sections
local char_section = misc_tab:Section("Character")
local money_section = misc_tab:Section("Money")
local info_section = misc_tab:Section("Info")

-- Auto Collect Money Bags
local function autoCollectMoneyBags()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, v in pairs(workspace.GameObjects:GetChildren()) do
        if v:FindFirstChild("ProximityPrompt") and v:IsA("BasePart") then
            local distance = (v.Position - root.Position).Magnitude
            if distance <= 10 then
                fireproximityprompt(v.ProximityPrompt)
            end
        end
    end
end

-- Auto Money Collection Loop
run_service.Heartbeat:Connect(function()
    if getgenv().settings.auto_collect_money then
        pcall(autoCollectMoneyBags)
    end
end)

-- Auto Functions
auto_section:Toggle("Auto Shoot", function(state)
    getgenv().settings.auto_shoot = state
end)

auto_section:Toggle("Auto Store", function(state)
    getgenv().settings.auto_store = state
end)

-- Money Functions
money_section:Toggle("Auto Collect Money", function(state)
    getgenv().settings.auto_collect_money = state
end)

-- Kill Functions
local function kill_player(player)
    pcall(function()
        local head = player:FindFirstChild("Head")
        if not head then return end

        local head_position = head.Position
        
        if getgenv().settings.auto_shoot then
            shoot_remote:FireServer(head_position, head_position, head)
        end
        
        if getgenv().settings.auto_store then
            store_remote:FireServer(player)
        end
    end)
end

kill_section:Button("Kill All Skinwalkers", function()
    for _,v in pairs(skin_walkers:GetChildren()) do
        kill_player(v)
    end
end)

skin_walkers.ChildAdded:Connect(kill_player)

-- Give Items
give_section:Button("Get 999 Cola", function()
    pcall(function()
        local cola_amount = 999
        replicated_storage.Assets.Tools.Cola.Amount.Value = cola_amount
        replicated_storage.Assets.Tools.Cola.Parent = local_player.Backpack
    end)
end)

give_section:Button("Get Gatling Gun", function()
    pcall(function()
        replicated_storage.Assets.Tools.Gatling.Parent = local_player.Backpack
    end)
end)

give_section:Button("Get 999 Snappers", function()
    pcall(function()
        local snapper_amount = 999
        replicated_storage.Assets.Tools.Snapper.Amount.Value = snapper_amount
        replicated_storage.Assets.Tools.Snapper.Parent = local_player.Backpack
    end)
end)

give_section:Button("Get 999 Turrets", function()
    pcall(function()
        local turret_amount = 999
        replicated_storage.Assets.Tools.Turret.Amount.Value = turret_amount
        replicated_storage.Assets.Tools.Turret.Parent = local_player.Backpack
    end)
end)

-- Character
char_section:Slider("WalkSpeed", 16, 200, function(value)
    pcall(function()
        local_player.Character.Humanoid.WalkSpeed = value
    end)
end)

char_section:Slider("Jump Power", 16, 200, function(value)
    pcall(function()
        local_player.Character.Humanoid.JumpPower = value
    end)
end)

