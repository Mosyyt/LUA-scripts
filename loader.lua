if game.GameId == 7453941040 then -- DANGEROUS NIGHT
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


elseif game.GameId == 7355857660 then -- Skinwalker

local Fun = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/nightmares.fun-UI-Library/main/source.lua"))()
local window = Fun.Create("SWS")

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


	
elseif game.GameId == 7513130835 then -- untitled drill game


local Fun = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/nightmares.fun-UI-Library/main/source.lua"))()
local window = Fun.Create("UDG")

-- Create tabs
local mainTab = window:Tab("Main")
local farmTab = window:Tab("Farm")

-- Services
local players = game:GetService("Players")
local plr = players.LocalPlayer
local sellPart = workspace:FindFirstChild("Scripted"):FindFirstChild("Sell")
local drillsUi = plr.PlayerGui:FindFirstChild("Menu"):FindFirstChild("CanvasGroup").Buy
local handdrillsUi = plr.PlayerGui:FindFirstChild("Menu"):FindFirstChild("CanvasGroup").HandDrills
local plot = nil

-- Variables
local playerList = {}
local choosenPlayer = nil
local delay = 10
local delayDrills = 10
local storDelay = 10
local lastPos = nil
local Options = {
    drillsUI = false,
    handdrillsUI = false,
    autodrill = false,
    autopickup = false,
    autosell = false,
    autorebith = false,
    collectdrills = false,
    collectstorage = false,
    drillsfull = false,
    drillsdelay = false,
    storagesfull = false,
    storagesdelay = false
}

-- // Get Player Plot
if plr then
    for _, p in ipairs(workspace.Plots:GetChildren()) do
        if p:FindFirstChild("Owner") and p.Owner.Value == plr then
            plot = p
            break
        end
    end
end

-- // Sell Logic
local function sell()
    local wasDrillsUiOpen = drillsUi.Visible
    local wasHandDrillsUiOpen = handdrillsUi.Visible

    drillsUi.Visible = false
    handdrillsUi.Visible = false
    
    lastPos = plr.Character:FindFirstChild("HumanoidRootPart").CFrame
    plr.Character:FindFirstChild("HumanoidRootPart").CFrame = sellPart.CFrame
    task.wait(0.2)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Knit = require(ReplicatedStorage.Packages:WaitForChild("Knit"))
    local OreService = Knit.GetService("OreService")

    OreService.SellAll:Fire()
    task.wait(0.2)

    if lastPos and lastPos ~= nil then
        plr.Character:FindFirstChild("HumanoidRootPart").CFrame = lastPos
    end

    if wasDrillsUiOpen then
        drillsUi.Visible = true
        Options.drillsUI = true
    end

    if wasHandDrillsUiOpen then
        handdrillsUi.Visible = true
        Options.handdrillsUI = true
    end
end

-- // Player List Functions
local function updatePlayerList()
    playerList = {}
    for _, v in ipairs(players:GetPlayers()) do
        if v ~= plr then
            table.insert(playerList, v.Name)
        end
    end
    -- Update dropdown values here
end

players.PlayerAdded:Connect(function()
    updatePlayerList()
end)

players.PlayerRemoving:Connect(function()
    updatePlayerList()
end)

-- Main Tab
local mainSection = mainTab:Section("UI Controls")

mainSection:Toggle("Open Drills UI", function(value)
    Options.drillsUI = value
    if Options.drillsUI then
        Options.handdrillsUI = false
    end
    drillsUi.Visible = Options.drillsUI
end)

mainSection:Toggle("Open HandDrills UI", function(value)
    Options.handdrillsUI = value
    if Options.handdrillsUI then
        Options.drillsUI = false
    end
    handdrillsUi.Visible = Options.handdrillsUI
end)

-- Monitor UI visibility changes
drillsUi:GetPropertyChangedSignal("Visible"):Connect(function()
    if not drillsUi.Visible then
        Options.drillsUI = false
    end
end)

handdrillsUi:GetPropertyChangedSignal("Visible"):Connect(function()
    if not handdrillsUi.Visible then
        Options.handdrillsUI = false
    end
end)

local playerSection = mainTab:Section("Player Options")

-- Initialize player list
updatePlayerList()

playerSection:Dropdown("Choose Players", playerList, function(value)
    choosenPlayer = value
end)

playerSection:Button("Teleport to Player", function()
    if choosenPlayer then
        local targetPlayer = players:FindFirstChild(choosenPlayer)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetPlayer.Character.HumanoidRootPart.CFrame
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = targetPosition
            else
                warn("Error: Your character is missing HumanoidRootPart")
            end
        else
            warn("Error: Target player not found or invalid")
        end
    else
        warn("Error: No player selected")
    end
end)

playerSection:Button("Teleport to Player Plot", function()
    if choosenPlayer then
        local targetPlayer = players:FindFirstChild(choosenPlayer)
        if targetPlayer then
            local targetPlot = nil
            for _, p in ipairs(workspace.Plots:GetChildren()) do
                if p:FindFirstChild("Owner") and p.Owner.Value == targetPlayer then
                    targetPlot = p
                    break
                end
            end

            if targetPlot and targetPlot:FindFirstChild("PlotSpawn") then
                local plotCenter = targetPlot.PlotSpawn.CFrame
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = plotCenter
                else
                    warn("Error: Your character is missing HumanoidRootPart")
                end
            else
                warn("Error: Target player's plot not found or invalid")
            end
        else
            warn("Error: Target player not found")
        end
    else
        warn("Error: No player selected")
    end
end)

playerSection:Button("Anti AFK", function()
    local bb = game:GetService("VirtualUser")
    plr.Idled:Connect(
        function()
            bb:CaptureController()
            bb:ClickButton2(Vector2.new())
        end
    )
    warn("Anti AFK enabled")
end)

-- Farm Tab
local autoFarmSection = farmTab:Section("Auto Farm")

autoFarmSection:Toggle("Auto Drill", function(value)
    Options.autodrill = value
    if Options.autodrill then
        task.spawn(function()
            while Options.autodrill do
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild(
                    "Services"
                ):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("RequestRandomOre"):FireServer()
                task.wait(.01)
            end
        end)
    end
end)

autoFarmSection:Toggle("Auto Drill Pickup", function(value)
    Options.autopickup = value
    if Options.autopickup then
        task.spawn(function()
            while Options.autopickup do
                local drill = (function()
                    for _, obj in pairs(plr.Character:GetChildren()) do
                        if obj:GetAttribute("Type") == "HandDrill" then
                            return obj
                        end
                    end
                end)()
                if not drill then
                    for _, obj in pairs(plr.Backpack:GetChildren()) do
                        if obj:GetAttribute("Type") == "HandDrill" then
                            obj.Parent = plr.Character
                            break
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end
end)

autoFarmSection:Button("Sell All", function()
    sell()
end)

autoFarmSection:TextBox("Auto Sell Delay", function(value)
    local num = tonumber(value)
    if num and num >= 1 then
        delay = num
    else
        warn("Warning: Only numbers (1+)")
    end
end)

autoFarmSection:Toggle("Auto Sell", function(value)
    Options.autosell = value
    if Options.autosell then
        task.spawn(function()
            while Options.autosell do
                sell()
                task.wait(delay)
            end
        end)
    end
end)

autoFarmSection:Toggle("Auto Rebirth", function(value)
    Options.autorebith = value
    if Options.autorebith then
        task.spawn(function()
            while Options.autorebith do
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild(
                    "RebirthService"
                ):WaitForChild("RE"):WaitForChild("RebirthRequest"):FireServer()
                task.wait(1)
            end
        end)
    end
end)

local collectSection = farmTab:Section("Auto Collect")

collectSection:Toggle("Auto Collect Drills", function(value)
    Options.collectdrills = value
    if Options.collectdrills then
        task.spawn(function()
            while Options.collectdrills do
                if plot and plot:FindFirstChild("Drills") then
                    for _, drill in pairs(plot.Drills:GetChildren()) do
                        if not Options.collectdrills then break end

                        local drillData = drill:FindFirstChild("DrillData")
                        local ores = drill:FindFirstChild("Ores")
                        if drillData and ores then
                            local capacity = drillData:FindFirstChild("Capacity")
                            if capacity then
                                local val = 0
                                for _, ore in pairs(ores:GetChildren()) do
                                    if ore:IsA("IntValue") or ore:IsA("NumberValue") then
                                        val += ore.Value
                                    end
                                end
                                if Options.drillsdelay or not Options.drillsfull or val >= capacity.Value then
                                    game:GetService("ReplicatedStorage").Packages.Knit.Services.PlotService.RE.CollectDrill:FireServer(drill)
                                end
                            end
                        end
                    end
                end
                task.wait(Options.drillsdelay and delayDrills or 2)
            end
        end)
    end
end)

collectSection:Toggle("Auto Collect Storages", function(value)
    Options.collectstorage = value
    if Options.collectstorage then
        task.spawn(function()
            while Options.collectstorage do
                if plot and plot:FindFirstChild("Storage") then
                    for _, storage in pairs(plot.Storage:GetChildren()) do
                        if not Options.collectstorage then break end

                        local storageData = storage:FindFirstChild("DrillData")
                        local storageOres = storage:FindFirstChild("Ores")
                        if storageData and storageOres then
                            local storageCapacity = storageData:FindFirstChild("Capacity")
                            if storageCapacity then
                                local storVal = 0
                                for _, ore in pairs(storageOres:GetChildren()) do
                                    if ore:IsA("IntValue") or ore:IsA("NumberValue") then
                                        storVal += ore.Value
                                    end
                                end
                                if (Options.storagesfull and storVal >= storageCapacity.Value) or not Options.storagesfull then
                                    game:GetService("ReplicatedStorage").Packages.Knit.Services.PlotService.RE.CollectDrill:FireServer(storage)
                                end
                            end
                        end
                    end
                end
                task.wait(Options.storagesdelay and storDelay or 2)
            end
        end)
    end
end)

local settingsSection = farmTab:Section("Collection Settings")

settingsSection:Toggle("If drill is full", function(value)
    Options.drillsfull = value
    if Options.drillsfull and Options.drillsdelay then
        Options.drillsdelay = false
    end
end)

settingsSection:Toggle("In ... seconds", function(value)
    Options.drillsdelay = value
    if Options.drillsdelay and Options.drillsfull then
        Options.drillsfull = false
    end
end)

settingsSection:TextBox("Drills Delay", function(value)
    local num = tonumber(value)
    if num and num >= 1 then
        delayDrills = num
    else
        warn("Warning: Only numbers (1+)")
    end
end)

settingsSection:Toggle("If storage is full", function(value)
    Options.storagesfull = value
    if Options.storagesfull and Options.storagesdelay then
        Options.storagesdelay = false
    end
end)

settingsSection:Toggle("In ... seconds", function(value)
    Options.storagesdelay = value
    if Options.storagesdelay and Options.storagesfull then
        Options.storagesfull = false
    end
end)

settingsSection:TextBox("Storages Delay", function(value)
    local num = tonumber(value)
    if num and num >= 1 then
        storDelay = num
    else
        warn("Warning: Only numbers (1+)")
    end
end)


elseif game.GameId == 7432254268 then -- Mines

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


elseif game.GameId == 7541395924 then -- Build An Island
-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local player = Players.LocalPlayer

-- Feature Toggles
local autoFarmResources = false
local selectedResources = {}
local autoBuySeeds = false
local selectedSeeds = {}
local autoBuyBees = false
local selectedBees = {}
local autoBuyPotions = false
local selectedPotions = {}
local autoPlant = false
local autoHarvest = false
local autoSell = false
local sellDelay = 0.1
local autoFuelMine = false
local autoCollectGoldMine = false
local autoCraft = false
local selectedCrafters = {}
local craftDelay = 0.1

-- Resources Table
local resourcesList = {}
for i, v in pairs(game:GetService('ReplicatedStorage').Storage.Resources:GetChildren()) do
    table.insert(resourcesList, v.Name)
end

-- Seeds Table
local seeds = {}
for i,v in pairs(game:GetService("ReplicatedStorage").Storage.BackpackItems:GetChildren()) do 
    if string.find(v.Name,"Seeds") then 
        table.insert(seeds, v.Name)
    end
end

local function autoCraftFunction()
    if selectedCrafters and type(selectedCrafters) == "table" and #selectedCrafters > 0 then
        local myPlot = workspace.Plots[game.Players.LocalPlayer.Name]
        if myPlot and myPlot:FindFirstChild("Land") then
            for _, crafterName in pairs(selectedCrafters) do
                for i, v in pairs(myPlot.Land:GetChildren()) do
                    if v:FindFirstChild('Crafter') then
                        local displayName = v.Crafter.Attachment:GetAttribute('Display')
                        if displayName == crafterName then
                            local remote = game:GetService('ReplicatedStorage').Communication.Craft
                            local arguments = {
                                [1] = v.Crafter.Attachment,
                            }
                            remote:FireServer(unpack(arguments))
                            task.wait(craftDelay) -- Delay between each craft
                            break
                        end
                    end
                end
            end
        end
    end
end

local function autoCollectGoldMineFunction()
    local myPlot = workspace.Plots[game.Players.LocalPlayer.Name]
    local landFolder = myPlot:FindFirstChild("Land")
    if landFolder then
        for i,v in pairs(landFolder:GetChildren()) do
            if v:FindFirstChild("GoldMineModel") then 
                local remote = game:GetService("ReplicatedStorage").Communication.Goldmine
                local arguments = {
                    [1] = v.Name,
                    [2] = 2,
                }
                remote:FireServer(unpack(arguments))
                task.wait(0.1)
            end
        end
    end
end

local function buyPotion(potionName)
    local merchantGui = player:FindFirstChild("PlayerGui"):FindFirstChild("Main")
    if merchantGui then
        local potionFrame = merchantGui.Menus.Merchant.Inner.ScrollingFrame.Hold:FindFirstChild(potionName)
        if potionFrame then
            local soldFrame = potionFrame:FindFirstChild("Sold")
            if soldFrame and not soldFrame.Visible then
                -- Item is not sold out, buy it
                game:GetService('ReplicatedStorage').Communication.BuyFromMerchant:FireServer(potionName,false)
            end
        end
    end
end

local function buyBee(beeName)
    local merchantGui = player:FindFirstChild("PlayerGui"):FindFirstChild("Main")
    if merchantGui then
        local beeFrame = merchantGui.Menus.Merchant.Inner.ScrollingFrame.Hold:FindFirstChild(beeName)
        if beeFrame then
            local soldFrame = beeFrame:FindFirstChild("Sold")
            if soldFrame and not soldFrame.Visible then
                -- Item is not sold out, buy it
                game:GetService('ReplicatedStorage').Communication.BuyFromMerchant:FireServer(beeName,false)
            end
        end
    end
end

-- Bees Table
local bees = {}
for i,v in pairs(game:GetService("ReplicatedStorage").Storage.BackpackItems:GetChildren()) do 
    if string.find(v.Name,"Bee") then 
        table.insert(bees, v.Name)
    end
end

-- Potions Table
local potions = {}
for i,v in pairs(game:GetService("ReplicatedStorage").Storage.BackpackItems:GetChildren()) do 
    if string.find(v.Name,"Potion") then 
        table.insert(potions, v.Name)
    end
end

-- Crafters Table
local crafters = {}
task.spawn(function()
    repeat task.wait(1) until workspace.Plots:FindFirstChild(game.Players.LocalPlayer.Name)
    local myPlot = workspace.Plots[game.Players.LocalPlayer.Name]
    if myPlot:FindFirstChild("Land") then
        for i, v in pairs(myPlot.Land:GetChildren()) do
            if v:FindFirstChild('Crafter') then
                local displayName = v.Crafter.Attachment:GetAttribute('Display')
                if displayName then
                    table.insert(crafters, displayName)
                end
            end
        end
    end
end)

-- Load Luna UI
local Luna = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua',
        true
    )
)()

local Window = Luna:CreateWindow({
    Name = 'Xetra Hub',
    Subtitle = 'By BeboMods',
    LogoID = '111108278176277',
    LoadingEnabled = true,
    LoadingTitle = 'Loading Xetra Hub...',
    LoadingSubtitle = 'Build An Island',
    ConfigSettings = {
        RootFolder = 'Xetra',
        ConfigFolder = 'Configs',
        AutoLoadConfig = true,
    },
})

-- Create Tab
local FarmTab = Window:CreateTab({
    Name = 'Farm',
    Icon = 'agriculture',
    ImageSource = 'Material',
    ShowTitle = true,
})

-- Farm Tab Content
FarmTab:CreateToggle({
    Name = 'Auto Farm Resources',
    CurrentValue = false,
    Callback = function(Value)
        autoFarmResources = Value
    end,
})

FarmTab:CreateDropdown({
    Name = 'Select Resources',
    Options = resourcesList,
    CurrentOption = { 'Bamboo' },
    MultipleOptions = true,
    Callback = function(Options)
        selectedResources = Options
    end,
})

FarmTab:CreateToggle({
    Name = 'Auto Plant',
    CurrentValue = false,
    Callback = function(Value)
        autoPlant = Value
    end,
})

FarmTab:CreateToggle({
    Name = 'Auto Harvest',
    CurrentValue = false,
    Callback = function(Value)
        autoHarvest = Value
    end,
})

FarmTab:CreateToggle({
    Name = 'Auto Sell',
    CurrentValue = false,
    Callback = function(Value)
        autoSell = Value
    end,
})

FarmTab:CreateSlider({
    Name = 'Sell Delay',
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = 0.1,
    Callback = function(Value)
        sellDelay = Value
    end,
})

FarmTab:CreateToggle({
    Name = 'Auto Fuel Mine',
    CurrentValue = false,
    Callback = function(Value)
        autoFuelMine = Value
    end,
})

FarmTab:CreateToggle({
    Name = 'Auto Collect Gold Mine',
    CurrentValue = false,
    Callback = function(Value)
        autoCollectGoldMine = Value
    end,
})

FarmTab:CreateToggle({
    Name = 'Auto Craft',
    CurrentValue = false,
    Callback = function(Value)
        autoCraft = Value
    end,
})

FarmTab:CreateDropdown({
    Name = 'Select Crafters',
    Options = crafters,
    CurrentOption = {crafters[1] or "No Crafters"},
    MultipleOptions = true,
    Callback = function(Options)
        selectedCrafters = Options
    end,
})

FarmTab:CreateSlider({
    Name = 'Craft Delay',
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = 0.1,
    Callback = function(Value)
        craftDelay = Value
    end,
})

-- Shop Tab
local ShopTab = Window:CreateTab({
    Name = 'Shop',
    Icon = 'shopping_cart',
    ImageSource = 'Material',
    ShowTitle = true,
})

-- Shop Tab Content
ShopTab:CreateToggle({
    Name = 'Auto Buy Seeds',
    CurrentValue = false,
    Callback = function(Value)
        autoBuySeeds = Value
    end,
})

ShopTab:CreateDropdown({
    Name = 'Select Seeds',
    Options = seeds,
    CurrentOption = {seeds[1] or "Corn Seeds"},
    MultipleOptions = true,
    Callback = function(Options)
        selectedSeeds = Options
    end,
})

ShopTab:CreateToggle({
    Name = 'Auto Buy Bees',
    CurrentValue = false,
    Callback = function(Value)
        autoBuyBees = Value
    end,
})

ShopTab:CreateDropdown({
    Name = 'Select Bees',
    Options = bees,
    CurrentOption = {bees[1] or "Worker Bee"},
    MultipleOptions = true,
    Callback = function(Options)
        selectedBees = Options
    end,
})

ShopTab:CreateToggle({
    Name = 'Auto Buy Potions',
    CurrentValue = false,
    Callback = function(Value)
        autoBuyPotions = Value
    end,
})

ShopTab:CreateDropdown({
    Name = 'Select Potions',
    Options = potions,
    CurrentOption = {potions[1] or "Speed Potion"},
    MultipleOptions = true,
    Callback = function(Options)
        selectedPotions = Options
    end,
})

-- Config Tab
local ConfigTab = Window:CreateTab({
    Name = 'Config',
    Icon = 'settings',
    ImageSource = 'Material',
    ShowTitle = true,
})

ConfigTab:BuildConfigSection()
Window:CreateHomeTab({
    SupportedExecutors = { 'Synapse', 'ScriptWare', 'Krnl', 'Fluxus' },
    DiscordInvite = 'DR2RdatRjc',
    Icon = 1,
})

Luna:LoadAutoloadConfig()

-- Resource Functions
local myPlot = workspace.Plots[game.Players.LocalPlayer.Name]

local function breakResource(resourceObject)
    if
        resourceObject
        and resourceObject:GetAttribute('HP')
        and resourceObject:GetAttribute('HP') > 0
    then
        game
            :GetService('ReplicatedStorage').Communication.HitResource
            :FireServer(resourceObject)
        return true
    end
    return false
end

local function buySeed(seedName)
    local merchantGui = player:FindFirstChild("PlayerGui"):FindFirstChild("Main")
    if merchantGui then
        local seedFrame = merchantGui.Menus.Merchant.Inner.ScrollingFrame.Hold:FindFirstChild(seedName)
        if seedFrame then
            local soldFrame = seedFrame:FindFirstChild("Sold")
            if soldFrame and not soldFrame.Visible then
                -- Item is not sold out, buy it
                game:GetService('ReplicatedStorage').Communication.BuyFromMerchant:FireServer(seedName,false)
            end
        end
    end
end

local function autoFuelMineFunction()
    local backpack = player:WaitForChild("Backpack")
    local coalCrate = backpack:FindFirstChild("Coal Crate")
    
    if coalCrate then
        for i,v in pairs(myPlot.Land:GetChildren()) do
            if v:FindFirstChild("GoldMineModel") then 
                local remote = game:GetService('ReplicatedStorage').Communication.Goldmine
                local arguments = {
                    [1] = v.Name,
                    [2] = 1,
                }
                remote:FireServer(unpack(arguments))
                task.wait(0.1)
            end
        end
    end
end

local function autoSellFunction()
    local backpack = player:WaitForChild("Backpack")
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("Hash") then
            local remote = game:GetService('ReplicatedStorage').Communication.SellToMerchant
            local arguments = {
                [1] = false,
                [2] = {
                    [1] = item:GetAttribute("Hash")
                },
            }
            remote:FireServer(unpack(arguments))
            task.wait(sellDelay)
        end
    end
end

local function autoPlantFunction()
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Find a seed tool in backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Seeds") then
            -- Equip the seed tool
            humanoid:EquipTool(tool)
            
            -- Wait for tool to be equipped
            repeat task.wait() until tool.Parent == character
            
            -- Find random garden bed to plant on
            local myPlot = workspace.Plots[game.Players.LocalPlayer.Name]
            if myPlot and myPlot:FindFirstChild("Land") then
                local gardenBeds = {}
                for _, plot in pairs(myPlot.Land:GetChildren()) do
                    if plot:FindFirstChild("Garden") and plot.Garden:FindFirstChild("Bed") then
                        table.insert(gardenBeds, plot.Garden.Bed)
                    end
                end
                
                if #gardenBeds > 0 then
                    -- Pick random garden bed
                    local randomBed = gardenBeds[math.random(1, #gardenBeds)]
                    local bedPosition = randomBed.Position
                    
                    -- Generate random position on the bed
                    local randomX = bedPosition.X + math.random(-2, 2)
                    local randomZ = bedPosition.Z + math.random(-2, 2)
                    local plantPosition = Vector3.new(randomX, 0, randomZ)
                    
                    -- Plant it
                    local remote = game:GetService('ReplicatedStorage').Communication.Plant
                    local arguments = {
                        [1] = tool,
                        [2] = plantPosition,
                    }
                    remote:FireServer(unpack(arguments))
                end
            end
            
            break -- Only plant one seed at a time
        end
    end
end

local function autoHarvestFunction()
    local plantsFolder = myPlot:FindFirstChild("Plants")
    if plantsFolder then
        for _, plant in pairs(plantsFolder:GetChildren()) do
            local grown = plant:GetAttribute("Grown") == true
            local outputVisible = plant:GetAttribute("OutputVisible")
            local shouldHarvest = false
            
            -- Check all 3 conditions
            if outputVisible ~= nil then
                -- For plants with OutputVisible attribute
                if outputVisible == true or (grown and outputVisible == true) then
                    shouldHarvest = true
                end
            elseif grown then
                -- For plants without OutputVisible attribute, just check Grown
                shouldHarvest = true
            end
            
            if shouldHarvest then
                local remote = game:GetService("ReplicatedStorage").Communication.Harvest
                local arguments = {
                    [1] = plant.Name
                }
                remote:FireServer(unpack(arguments))
                task.wait(0.1)
            end
        end
    end
end

-- Auto Farm Loop
task.spawn(function()
    while task.wait(.1) do
        if autoFarmResources then
            if myPlot and myPlot:FindFirstChild('Resources') then
                for _, resourceObj in pairs(myPlot.Resources:GetChildren()) do
                    if resourceObj:GetAttribute('HP') and resourceObj:GetAttribute('HP') > 0 then
                        if #selectedResources > 0 then
                            for _, selectedName in pairs(selectedResources) do
                                if resourceObj.Name == selectedName then
                                    breakResource(resourceObj)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Plant Loop
task.spawn(function()
    while task.wait(1) do
        if autoPlant then
            autoPlantFunction()
        end
    end
end)

-- Auto Harvest Loop
task.spawn(function()
    while task.wait(1) do
        if autoHarvest then
            autoHarvestFunction()
        end
    end
end)

-- Auto Sell Loop
task.spawn(function()
    while task.wait(1) do
        if autoSell then
            autoSellFunction()
        end
    end
end)

-- Auto Fuel Mine Loop
task.spawn(function()
    while task.wait(1) do
        if autoFuelMine then
            autoFuelMineFunction()
        end
    end
end)

-- Auto Collect Gold Mine Loop
task.spawn(function()
    while task.wait(1) do
        if autoCollectGoldMine then
            autoCollectGoldMineFunction()
        end
    end
end)

-- Auto Craft Loop
task.spawn(function()
    while task.wait(craftDelay) do
        if autoCraft then
            autoCraftFunction()
        end
    end
end)

-- Auto Buy Seeds Loop
task.spawn(function()
    while task.wait(1) do
        if autoBuySeeds and selectedSeeds and type(selectedSeeds) == "table" and #selectedSeeds > 0 then
            for _, seedName in pairs(selectedSeeds) do
                buySeed(seedName)
                task.wait(0.1)
            end
        end
    end
end)

-- Auto Buy Bees Loop
task.spawn(function()
    while task.wait(1) do
        if autoBuyBees and selectedBees and type(selectedBees) == "table" and #selectedBees > 0 then
            for _, beeName in pairs(selectedBees) do
                buyBee(beeName)
                task.wait(0.1)
            end
        end
    end
end)

-- Auto Buy Potions Loop
task.spawn(function()
    while task.wait(1) do
        if autoBuyPotions and selectedPotions and type(selectedPotions) == "table" and #selectedPotions > 0 then
            for _, potionName in pairs(selectedPotions) do
                buyPotion(potionName)
                task.wait(0.1)
            end
        end
    end
end)
elseif game.GameId == 7436755782 then -- Grow A Garden

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local backpack = player:FindFirstChild("Backpack")
local remote = ReplicatedStorage.GameEvents:FindFirstChild("Plant_RE")
local teleportBackPosition = nil

-- Feature Toggles
local autoCollect = false
local autoBuyAllSeeds = false
local autoBuySpecificSeed = false
local autoPlant = false
local autoWalkToPlant = false
local selectedSeeds = {}
local sellAtCount = 10
local sellInterval = 0
local sellWhenFull = false
local sellBasedOnSlider = false
local autoBuyRobuxSeeds = false
local autoSell = false

-- New Features
local autoFarmEnabled = false
local autoBuyGear = false
local autoBuyBloodMoon = false
local autoBuyEggs = false
local selectedGears = {}
local selectedBMItems = {}
local mutationESPEnabled = false
local selectedMutationsESP = {"Gold", "Frozen", "Rainbow"}
local autoFavoriteEnabled = false
local selectedMutationsFav = {"Gold", "Frozen", "Rainbow"}

-- Auto Farm Settings
local autoFarmSettings = {
    delay = 0.1,
    teleportSpeed = 0.15,
    collectDelay = 0.2,
    targetMutations = {"All"},
    mutationOnly = false,
    smartTeleport = true,
    autoSell = true
}

-- Item Lists
local gearItems = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler","Favorite Tool"}
local bmItems = {"Mysterious Crate","Night Egg","Night Seed Pack","Blood Banana","Moon Melon","Star Caller","Blood Hedgehog","Blood Kiwi","Blood Owl"}
local mutationOptions = {"All","Wet","Gold","Frozen","Rainbow","Choc","Chilled","Shocked","Moonlit","Bloodlit","Celestial"}

-- ESP Variables
local mutationColors = {
    Wet = Color3.fromRGB(0, 0, 255),
    Gold = Color3.fromRGB(255, 215, 0),
    Frozen = Color3.fromRGB(135, 206, 250),
    Rainbow = Color3.fromRGB(255, 255, 255),
    Choc = Color3.fromRGB(139, 69, 19),
    Chilled = Color3.fromRGB(0, 255, 255),
    Shocked = Color3.fromRGB(255, 255, 100),
    Moonlit = Color3.fromRGB(128, 0, 128),
    Bloodlit = Color3.fromRGB(200, 0, 0),
    Celestial = Color3.fromRGB(200, 150, 255)
}

local espBillboards = {}
local espHighlights = {}

-- Load Luna UI
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

local Window = Luna:CreateWindow({
    Name = 'Xetra Hub',
    Subtitle = 'By BeboMods',
    LogoID = '111108278176277',
    LoadingEnabled = true,
    LoadingTitle = 'Loading Xetra Hub...',
    LoadingSubtitle = 'Grow A Garden',
    ConfigSettings = {
        RootFolder = 'Xetra',
        ConfigFolder = 'Configs',
        AutoLoadConfig = true,
    },
})

-- Utility Functions
local function parseMoney(moneyStr)
    if not moneyStr then return 0 end
    moneyStr = tostring(moneyStr):gsub("Â¢", ""):gsub(",", ""):gsub(" ", ""):gsub("%$", "")
    local multiplier = 1
    if moneyStr:lower():find("k") then
        multiplier = 1000
        moneyStr = moneyStr:lower():gsub("k", "")
    elseif moneyStr:lower():find("m") then
        multiplier = 1000000
        moneyStr = moneyStr:lower():gsub("m", "")
    end
    return (tonumber(moneyStr) or 0) * multiplier
end

local function getPlayerMoney()
    local leaderstats = player:FindFirstChild("leaderstats")
    local shecklesStat = leaderstats and leaderstats:FindFirstChild("Sheckles")
    return parseMoney((shecklesStat and shecklesStat.Value) or 0)
end

local function isInventoryFull()
    return #player.Backpack:GetChildren() >= 200
end

-- Function to fetch available seed names
local function getAvailableSeedNames()
    local shopUI = player:FindFirstChild("PlayerGui"):FindFirstChild("Seed_Shop")
    if not shopUI then return {} end

    local names = {}
    local scroll = shopUI.Frame.ScrollingFrame
    for _, item in pairs(scroll:GetChildren()) do
        if item:IsA("Frame") and not item.Name:match("_Padding$") then
            table.insert(names, item.Name)
        end
    end
    return names
end

-- Create Tabs
local FarmTab = Window:CreateTab({
    Name = "Farm",
    Icon = "home",
    ImageSource = "Material",
    ShowTitle = true
})

local AutoFarmTab = Window:CreateTab({
    Name = "Auto Farm",
    Icon = "autorenew",
    ImageSource = "Material", 
    ShowTitle = true
})

local SellTab = Window:CreateTab({
    Name = "Sell",
    Icon = "attach_money",
    ImageSource = "Material",
    ShowTitle = true
})

local SeedBuyingTab = Window:CreateTab({
    Name = "Seed Buying",
    Icon = "shopping_cart",
    ImageSource = "Material",
    ShowTitle = true
})

local ShopTab = Window:CreateTab({
    Name = "Shop",
    Icon = "store",
    ImageSource = "Material",
    ShowTitle = true
})

local MutationTab = Window:CreateTab({
    Name = "Mutations",
    Icon = "star",
    ImageSource = "Material",
    ShowTitle = true
})

local ESPTab = Window:CreateTab({
    Name = "ESP",
    Icon = "visibility",
    ImageSource = "Material",
    ShowTitle = true
})

local ConfigTab = Window:CreateTab({
    Name = "Config",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

-- Get owned plot
local function getOwnedPlot()
    for _, plot in pairs(workspace.Farm:GetChildren()) do
        local important = plot:FindFirstChild("Important") or plot:FindFirstChild("Importanert")
        if important then
            local data = important:FindFirstChild("Data")
            if data and data:FindFirstChild("Owner") and data.Owner.Value == player.Name then
                return plot
            end
        end
    end
    return nil
end

-- Function to teleport and sell
local function teleportAndSell()
    local originalPosition = player.Character and player.Character.HumanoidRootPart.Position
    local tutorialPoint = workspace.Tutorial_Points:FindFirstChild("Tutorial_Point_2")
    
    if tutorialPoint then
        teleportBackPosition = originalPosition
        player.Character:SetPrimaryPartCFrame(tutorialPoint.CFrame)
        task.wait(.1)
        ReplicatedStorage.GameEvents:FindFirstChild("Sell_Inventory"):FireServer()
        task.wait(1)
        if teleportBackPosition then
            player.Character:SetPrimaryPartCFrame(CFrame.new(teleportBackPosition))
        end
    end
end

-- Enhanced Auto Farm Functions
local function updateFarmData()
    local farms = {}
    local plants = {}
    for _, farm in pairs(workspace:FindFirstChild("Farm"):GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == player.Name then
            table.insert(farms, farm)
            local plantsFolder = farm.Important:FindFirstChild("Plants_Physical")
            if plantsFolder then
                for _, plantModel in pairs(plantsFolder:GetChildren()) do
                    for _, part in pairs(plantModel:GetDescendants()) do
                        if part:IsA("BasePart") and part:FindFirstChildOfClass("ProximityPrompt") then
                            table.insert(plants, part)
                            break
                        end
                    end
                end
            end
        end
    end
    return farms, plants
end

local function checkMutationMatch(fruitModel)
    if not autoFarmSettings.mutationOnly or table.find(autoFarmSettings.targetMutations, "All") then 
        return true 
    end
    
    for _, mutation in ipairs(autoFarmSettings.targetMutations) do
        if fruitModel:GetAttribute(mutation) then
            return true
        end
    end
    return false
end

local function smartTeleport(pos, speed)
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if autoFarmSettings.smartTeleport then
        local tween = TweenService:Create(root, TweenInfo.new(speed or autoFarmSettings.teleportSpeed, Enum.EasingStyle.Linear), 
            {CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))})
        tween:Play()
        tween.Completed:Wait()
    else
        root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    end
end

-- Auto Farm Loop
local autoFarmThread
local function startAutoFarm()
    if autoFarmThread then task.cancel(autoFarmThread) end
    autoFarmThread = task.spawn(function()
        while autoFarmEnabled do
            if isInventoryFull() and autoFarmSettings.autoSell then
                teleportAndSell()
                task.wait(1)
            end
            
            local farms, plants = updateFarmData()
            
            for _, part in pairs(plants) do
                if not autoFarmEnabled then break end
                if isInventoryFull() and autoFarmSettings.autoSell then
                    teleportAndSell()
                    task.wait(1)
                end
                
                if part and part.Parent then
                    local fruitModel = part:FindFirstAncestorOfClass("Model")
                    if fruitModel and checkMutationMatch(fruitModel) then
                        local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            smartTeleport(part.Position, autoFarmSettings.teleportSpeed)
                            task.wait(autoFarmSettings.collectDelay)
                            
                            for _, farm in pairs(farms) do
                                if not autoFarmEnabled or isInventoryFull() then break end
                                for _, obj in pairs(farm:GetDescendants()) do
                                    if obj:IsA("ProximityPrompt") then
                                        local str = tostring(obj.Parent)
                                        if not (str:find("Grow_Sign") or str:find("Core_Part")) then
                                            fireproximityprompt(obj, 1)
                                        end
                                    end
                                end
                            end
                            task.wait(autoFarmSettings.delay)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- ESP Functions
local function createESP(fruitModel)
    if espBillboards[fruitModel] then
        espBillboards[fruitModel]:Destroy()
        espBillboards[fruitModel] = nil
    end
    if espHighlights[fruitModel] then
        espHighlights[fruitModel]:Destroy()
        espHighlights[fruitModel] = nil
    end

    if not mutationESPEnabled then return end

    local activeMutations = {}
    for _, mutation in ipairs(mutationOptions) do
        if mutation ~= "All" and table.find(selectedMutationsESP, mutation) and fruitModel:GetAttribute(mutation) then
            table.insert(activeMutations, mutation)
        end
    end

    if #activeMutations == 0 then return end

    local text = fruitModel.Name .. " - " .. table.concat(activeMutations, ", ")
    local espColor = mutationColors[activeMutations[1]] or Color3.fromRGB(255, 255, 255)

    local highlight = Instance.new("Highlight")
    highlight.Name = "MutationESP_Highlight"
    highlight.FillTransparency = 1
    highlight.OutlineColor = espColor
    highlight.OutlineTransparency = 0.3
    highlight.Adornee = fruitModel
    highlight.Parent = fruitModel
    espHighlights[fruitModel] = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MutationESP"
    billboard.Adornee = fruitModel.PrimaryPart or fruitModel:FindFirstChildWhichIsA("BasePart")
    billboard.Size = UDim2.fromOffset(200, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "{" .. text .. "}"
    textLabel.TextColor3 = espColor
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    billboard.Parent = fruitModel
    espBillboards[fruitModel] = billboard
end

local function updateESP()
    for _, billboard in pairs(espBillboards) do
        billboard:Destroy()
    end
    for _, highlight in pairs(espHighlights) do
        highlight:Destroy()
    end
    table.clear(espBillboards)
    table.clear(espHighlights)

    if not mutationESPEnabled or not workspace:FindFirstChild("Farm") then return end

    local farms = {}
    for _, farm in ipairs(workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == player.Name then
            table.insert(farms, farm)
        end
    end

    for _, farm in ipairs(farms) do
        local plantsFolder = farm.Important:FindFirstChild("Plants_Physical")
        if plantsFolder then
            for _, plantModel in ipairs(plantsFolder:GetChildren()) do
                if plantModel:IsA("Model") then
                    local fruitsFolder = plantModel:FindFirstChild("Fruits")
                    if fruitsFolder then
                        for _, fruitModel in ipairs(fruitsFolder:GetChildren()) do
                            if fruitModel:IsA("Model") then
                                createESP(fruitModel)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Auto Favorite Functions
local favoriteEvent = ReplicatedStorage.GameEvents:WaitForChild("Favorite_Item")
local favoriteConnection = nil

local function toolMatchesMutation(toolName)
    for _, mutation in ipairs(selectedMutationsFav) do
        if string.find(toolName, mutation) then
            return true
        end
    end
    return false
end

local function isToolFavorited(tool)
    return tool:GetAttribute("Favorite") or (tool:FindFirstChild("Favorite") and tool.Favorite.Value)
end

local function favoriteToolIfMatches(tool)
    if toolMatchesMutation(tool.Name) and not isToolFavorited(tool) then
        favoriteEvent:FireServer(tool)
        task.wait(0.1)
    end
end

local function setupAutoFavorite()
    if favoriteConnection then favoriteConnection:Disconnect() end
    local backpack = player:WaitForChild("Backpack")
    favoriteConnection = backpack.ChildAdded:Connect(function(tool)
        task.wait(0.1)
        favoriteToolIfMatches(tool)
    end)
    
    for _, tool in ipairs(backpack:GetChildren()) do
        favoriteToolIfMatches(tool)
    end
end

-- Shop Functions
local function getItemPrice(path, item)
    local container = path:FindFirstChild(item)
    if not container then return math.huge end
    local frame = container:FindFirstChild("Frame")
    if not frame then return math.huge end
    local buyBtn = frame:FindFirstChild("Sheckles_Buy")
    if not buyBtn then return math.huge end
    local inStock = buyBtn:FindFirstChild("In_Stock")
    if not inStock then return math.huge end
    local costText = inStock:FindFirstChild("Cost_Text")
    if not costText or not costText.Text then return math.huge end
    return parseMoney(costText.Text)
end

local function tryPurchase(path, remote, item)
    local itemPrice = getItemPrice(path, item)
    local playerMoney = getPlayerMoney()
    if playerMoney > 0 and itemPrice > 0 and playerMoney >= itemPrice then
        local container = path:FindFirstChild(item)
        if container and container:FindFirstChild("Frame") then
            local buyBtn = container.Frame:FindFirstChild("Sheckles_Buy")
            if buyBtn and buyBtn:FindFirstChild("In_Stock") and buyBtn.In_Stock.Visible then
                remote:FireServer(item)
                return true
            end
        end
    end
    return false
end

-- Farm Tab Content
FarmTab:CreateSection("Farming Automation")

FarmTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Callback = function(Value)
        autoCollect = Value
    end
}, "AutoCollect")

FarmTab:CreateToggle({
    Name = "Auto Walk To Plant",
    CurrentValue = false,
    Callback = function(Value)
        autoWalkToPlant = Value
    end
}, "AutoWalk")

FarmTab:CreateToggle({
    Name = "Auto Plant",
    CurrentValue = false,
    Callback = function(Value)
        autoPlant = Value
    end
}, "AutoPlant")

-- Auto Farm Tab Content
AutoFarmTab:CreateSection("Enhanced Auto Farm")

AutoFarmTab:CreateToggle({
    Name = "Enable Auto Farm",
    Description = "Advanced farming with mutation filtering",
    CurrentValue = false,
    Callback = function(state)
        autoFarmEnabled = state
        if state then
            startAutoFarm()
        elseif autoFarmThread then
            task.cancel(autoFarmThread)
        end
    end
}, "EnhancedAutoFarm")

AutoFarmTab:CreateSlider({
    Name = "Farm Delay",
    Range = {0.01, 2},
    Increment = 0.01,
    CurrentValue = 0.1,
    Callback = function(value)
        autoFarmSettings.delay = value
    end
}, "FarmDelay")

AutoFarmTab:CreateSlider({
    Name = "Teleport Speed",
    Range = {0.01, 1},
    Increment = 0.01,
    CurrentValue = 0.15,
    Callback = function(value)
        autoFarmSettings.teleportSpeed = value
    end
}, "TeleportSpeed")

AutoFarmTab:CreateSection("Mutation Filtering")

AutoFarmTab:CreateDropdown({
    Name = "Target Mutations",
    Description = "Select which mutations to prioritize",
    Options = mutationOptions,
    CurrentOption = {"All"},
    MultipleOptions = true,
    Callback = function(Options)
        autoFarmSettings.targetMutations = Options
    end
}, "FarmMutationFilter")

AutoFarmTab:CreateToggle({
    Name = "Mutation Only Mode",
    Description = "Only collect fruits with selected mutations",
    CurrentValue = false,
    Callback = function(state)
        autoFarmSettings.mutationOnly = state
    end
}, "MutationOnly")

AutoFarmTab:CreateToggle({
    Name = "Smart Teleport",
    Description = "Use smooth teleportation",
    CurrentValue = true,
    Callback = function(state)
        autoFarmSettings.smartTeleport = state
    end
}, "SmartTeleport")

AutoFarmTab:CreateToggle({
    Name = "Auto Sell When Full",
    Description = "Automatically sell when inventory is full",
    CurrentValue = true,
    Callback = function(state)
        autoFarmSettings.autoSell = state
    end
}, "FarmAutoSell")

-- Sell Tab Content
SellTab:CreateSection("Selling Options")

SellTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(Value)
        autoSell = Value
    end
}, "AutoSell")

SellTab:CreateToggle({
    Name = "Sell When Backpack Full",
    CurrentValue = false,
    Callback = function(Value)
        sellWhenFull = Value
    end
}, "SellWhenFull")

SellTab:CreateToggle({
    Name = "Sell Based on Item Count",
    CurrentValue = false,
    Callback = function(Value)
        sellBasedOnSlider = Value
    end
}, "SellCount")

SellTab:CreateSlider({
    Name = "Sell At Count",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value)
        sellAtCount = Value
    end
}, "SellAtCount")

SellTab:CreateButton({
    Name = "Sell All Now",
    Description = "Instantly sell all items",
    Callback = function()
        teleportAndSell()
    end
})

-- Seed Buying Tab Content
SeedBuyingTab:CreateSection("Seed Purchasing")

SeedBuyingTab:CreateToggle({
    Name = "Auto Buy/Dupe Robux Seeds",
    CurrentValue = false,
    Callback = function(Value)
        autoBuyRobuxSeeds = Value
    end
}, "AutoBuyRobux")

SeedBuyingTab:CreateToggle({
    Name = "Auto Buy All Seeds",
    CurrentValue = false,
    Callback = function(Value)
        autoBuyAllSeeds = Value
    end
}, "AutoBuyAll")

SeedBuyingTab:CreateToggle({
    Name = "Auto Buy Specific Seeds",
    CurrentValue = false,
    Callback = function(Value)
        autoBuySpecificSeed = Value
    end
}, "AutoBuySpecific")

-- Create seed dropdown (with dynamic update)
local seedDropdown
task.spawn(function()
    repeat task.wait(1) until player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Seed_Shop")
    local seedNames = getAvailableSeedNames()
    seedDropdown = SeedBuyingTab:CreateDropdown({
        Name = "Choose Specific Seeds",
        Options = seedNames,
        CurrentOption = {"Carrot"},
        MultipleOptions = true,
        Callback = function(Options)
            selectedSeeds = Options
        end
    }, "SeedSelection")
end)

-- Shop Tab Content
ShopTab:CreateSection("Additional Shop Items")

ShopTab:CreateDropdown({
    Name = "Select Gear",
    Description = "Choose which gear to auto buy",
    Options = gearItems,
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedGears = Options
    end
}, "GearSelection")

ShopTab:CreateToggle({
    Name = "Auto Buy Gear",
    Description = "Automatically purchase selected gear",
    CurrentValue = false,
    Callback = function(Value)
        autoBuyGear = Value
    end
}, "AutoBuyGear")

ShopTab:CreateDropdown({
    Name = "Blood Moon Items",
    Description = "Choose which Blood Moon items to auto buy",
    Options = bmItems,
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedBMItems = Options
    end
}, "BMSelection")

ShopTab:CreateToggle({
    Name = "Auto Buy Blood Moon Items",
    Description = "Automatically buy Blood Moon shop items",
    CurrentValue = false,
    Callback = function(Value)
        autoBuyBloodMoon = Value
    end
}, "AutoBuyBM")

ShopTab:CreateToggle({
    Name = "Auto Buy Eggs",
    Description = "Automatically buy pet eggs",
    CurrentValue = false,
    Callback = function(value)
        autoBuyEggs = value
    end
}, "AutoBuyEggs")

ShopTab:CreateSection("Shop Menus")

ShopTab:CreateButton({
    Name = "Open Seed Shop",
    Callback = function()
        player.PlayerGui.Seed_Shop.Enabled = not player.PlayerGui.Seed_Shop.Enabled
    end
})

ShopTab:CreateButton({
    Name = "Open Gear Shop",
    Callback = function()
        player.PlayerGui.Gear_Shop.Enabled = not player.PlayerGui.Gear_Shop.Enabled
    end
})

ShopTab:CreateButton({
    Name = "Open Blood Shop",
    Callback = function()
        player.PlayerGui.EventShop_UI.Enabled = not player.PlayerGui.EventShop_UI.Enabled
    end
})

-- Mutation Tab Content
MutationTab:CreateSection("Auto Favorite")

MutationTab:CreateDropdown({
    Name = "Mutations to Auto-Favorite",
    Description = "Select mutations to automatically favorite",
    Options = {"Wet","Gold","Frozen","Rainbow","Choc","Chilled","Shocked","Moonlit","Bloodlit","Celestial"},
    CurrentOption = {"Gold", "Frozen", "Rainbow"},
    MultipleOptions = true,
    Callback = function(Options)
        selectedMutationsFav = Options
    end
}, "FavoriteMutations")

MutationTab:CreateToggle({
    Name = "Auto Favorite",
    Description = "Automatically favorite items with selected mutations",
    CurrentValue = false,
    Callback = function(Value)
        autoFavoriteEnabled = Value
        if Value then
            setupAutoFavorite()
        elseif favoriteConnection then
            favoriteConnection:Disconnect()
            favoriteConnection = nil
        end
    end
}, "AutoFavorite")

MutationTab:CreateButton({
    Name = "Unfavorite All",
    Description = "Remove favorite from all items",
    Callback = function()
        local backpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack")
        for _, tool in ipairs(backpack:GetChildren()) do
            local isFavorited = tool:GetAttribute("Favorite") or (tool:FindFirstChild("Favorite") and tool.Favorite.Value)
            if isFavorited then
                favoriteEvent:FireServer(tool)
                task.wait()
            end
        end
    end
})

-- ESP Tab Content
ESPTab:CreateSection("Mutation ESP")

ESPTab:CreateDropdown({
    Name = "ESP Mutations",
    Description = "Select mutations to highlight with ESP",
    Options = {"Wet","Gold","Frozen","Rainbow","Choc","Chilled","Shocked","Moonlit","Bloodlit","Celestial"},
    CurrentOption = {"Gold", "Frozen", "Rainbow"},
    MultipleOptions = true,
    Callback = function(options)
        selectedMutationsESP = options
        updateESP()
    end
}, "ESPMutations")

ESPTab:CreateToggle({
    Name = "Enable Mutation ESP",
    Description = "Shows ESP for fruits with selected mutations",
    CurrentValue = false,
    Callback = function(value)
        mutationESPEnabled = value
        updateESP()
    end
}, "EnableESP")

ESPTab:CreateButton({
    Name = "Refresh ESP",
    Description = "Manually refresh ESP highlights",
    Callback = function()
        updateESP()
    end
})

-- Config Tab Content
ConfigTab:BuildConfigSection()
Window:CreateHomeTab({
    SupportedExecutors = {"Synapse", "ScriptWare", "Krnl", "Fluxus"},
    DiscordInvite = "",
    Icon = 1
})

Luna:LoadAutoloadConfig()

-- Auto Collect (Original)
task.spawn(function()
    while task.wait(1) do
        if autoCollect then
            local plot = getOwnedPlot()
            local farm = plot and plot:FindFirstChild("Important"):FindFirstChild("Plants_Physical")
            if farm then
                for _, prompt in ipairs(farm:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if playerRoot then
                            local dist = (playerRoot.Position - prompt.Parent.Parent.PrimaryPart.Position).Magnitude
                            if dist <= 20 then
                                prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
                                prompt.MaxActivationDistance = 100
                                prompt.RequiresLineOfSight = false
                                fireproximityprompt(prompt, 1, true)
                            elseif autoWalkToPlant then
                                local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
                                if humanoid then
                                    humanoid.Jump = true
                                    humanoid:MoveTo(prompt.Parent.Parent.PrimaryPart.Position + Vector3.new(0, 5, 0))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Sell based on different conditions
task.spawn(function()
    while task.wait() do
        if autoSell then
            local holdableCount = 0
            for _, item in ipairs(backpack:GetChildren()) do
                if item:GetAttribute("ITEM_TYPE") == "Holdable" then
                    holdableCount = holdableCount + 1
                end
            end

            if sellWhenFull then
                local notificationUI = player:FindFirstChild("PlayerGui"):FindFirstChild("Top_Notification")
                local notificationFrame = notificationUI and notificationUI:FindFirstChild("Frame")
                local notification = notificationFrame and notificationFrame:FindFirstChild("Notification_UI")
                if notification and notification:GetAttribute("OG") == "Max backpack space! Go sell!" then
                    teleportAndSell()
                end
            end

            if sellBasedOnSlider and holdableCount >= sellAtCount then
                teleportAndSell()
            end
        end
    end
end)

-- Auto Buy Seeds
local function autoBuySeedsFunction()
    local shopUI = player:FindFirstChild("PlayerGui"):FindFirstChild("Seed_Shop")
    if not shopUI then return end

    local scroll = shopUI.Frame.ScrollingFrame
    for _, item in pairs(scroll:GetChildren()) do
        if item:IsA("Frame") and not item.Name:match("_Padding$") then
            local mainFrame = item:FindFirstChild("Main_Frame")
            if mainFrame then
                local stockTextLabel = mainFrame:FindFirstChild("Stock_Text")
                if stockTextLabel then
                    local stock = tonumber(stockTextLabel.Text:match("X(%d+) Stock"))
                    if stock and stock > 0 then
                        if autoBuyAllSeeds then
                            ReplicatedStorage.GameEvents:WaitForChild("BuySeedStock"):FireServer(item.Name)
                        end
                        
                        if autoBuySpecificSeed and #selectedSeeds > 0 then
                            for _, selectedSeed in ipairs(selectedSeeds) do
                                if selectedSeed == item.Name then
                                    ReplicatedStorage.GameEvents:WaitForChild("BuySeedStock"):FireServer(item.Name)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Auto Buy Gear Function
local function autoBuyGearFunction()
    if not autoBuyGear or #selectedGears == 0 then return end
    
    local gearPath = player.PlayerGui.Gear_Shop.Frame.ScrollingFrame
    local gearRemote = ReplicatedStorage.GameEvents:WaitForChild("BuyGearStock")
    
    for _, gear in ipairs(selectedGears) do
        tryPurchase(gearPath, gearRemote, gear)
    end
end

-- Auto Buy Blood Moon Function
local function autoBuyBloodMoonFunction()
    if not autoBuyBloodMoon or #selectedBMItems == 0 then return end
    
    local bmPath = player.PlayerGui.EventShop_UI.Frame.ScrollingFrame
    local bmRemote = ReplicatedStorage.GameEvents:WaitForChild("BuyEventShopStock")
    
    for _, item in ipairs(selectedBMItems) do
        tryPurchase(bmPath, bmRemote, item)
    end
end

-- Auto Buy Eggs Function
local Autoegg_npc = workspace:WaitForChild("NPCS"):WaitForChild("Pet Stand")
local Autoegg_timer = Autoegg_npc.Timer.SurfaceGui:WaitForChild("ResetTimeLabel")
local Autoegg_eggLocations = Autoegg_npc:WaitForChild("EggLocations")
local Autoegg_events = ReplicatedStorage:WaitForChild("GameEvents")
local Autoegg_firstRun = true

local function autoBuyEggsFunction()
    if not autoBuyEggs then return end
    
    if not Autoegg_firstRun then
        while Autoegg_timer.Text ~= "00:00:00" do
            task.wait(0.1)
        end
        task.wait(3)
    else
        Autoegg_firstRun = false
    end

    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local targetCFrame = CFrame.new(-255.12291, 2.99999976, -1.13749218)
    player.Character.HumanoidRootPart.CFrame = targetCFrame

    for _, obj in ipairs(Autoegg_eggLocations:GetChildren()) do
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                child.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
            end
        end
    end

    local commonEggPrompt = Autoegg_eggLocations:FindFirstChild("Common Egg")
    if commonEggPrompt then
        pcall(function() fireproximityprompt(commonEggPrompt:FindFirstChild("ProximityPrompt")) end)
        task.wait(0.3)
        pcall(function() Autoegg_events:WaitForChild("BuyPetEgg"):FireServer(1) end)
    end

    local eggSlot6 = Autoegg_eggLocations:GetChildren()[6]
    if eggSlot6 then
        pcall(function() fireproximityprompt(eggSlot6:FindFirstChild("ProximityPrompt")) end)
        task.wait(0.3)
        pcall(function() Autoegg_events:WaitForChild("BuyPetEgg"):FireServer(2) end)
    end

    local eggSlot5 = Autoegg_eggLocations:GetChildren()[5]
    if eggSlot5 then
        pcall(function() fireproximityprompt(eggSlot5:FindFirstChild("ProximityPrompt")) end)
        task.wait(0.3)
        pcall(function() Autoegg_events:WaitForChild("BuyPetEgg"):FireServer(3) end)
    end
end

-- Auto Buy Seeds Loop
task.spawn(function()
    while task.wait(0.2) do
        if autoBuyAllSeeds or (autoBuySpecificSeed and #selectedSeeds > 0) then
            autoBuySeedsFunction()
        end
    end
end)

-- Auto Buy Gear Loop
task.spawn(function()
    while task.wait(0.5) do
        if autoBuyGear then
            autoBuyGearFunction()
        end
    end
end)

-- Auto Buy Blood Moon Loop
task.spawn(function()
    while task.wait(0.5) do
        if autoBuyBloodMoon then
            autoBuyBloodMoonFunction()
        end
    end
end)

-- Auto Buy Robux Seeds Loop
task.spawn(function()
    while task.wait(5) do
        if autoBuyRobuxSeeds then
            for i = 1, 5 do
                ReplicatedStorage.GameEvents.EasterShopService:FireServer("PurchaseSeed", i)
            end
        end
    end
end)

-- Auto Buy Eggs Loop
task.spawn(function()
    while task.wait(0.5) do
        if autoBuyEggs then
            autoBuyEggsFunction()
        end
    end
end)

-- Find seed tool
local function findSeedTool()
    for _, item in ipairs(player.Character:GetChildren()) do
        if item:IsA("Tool") and item.Name:find("Seed") then
            local crop = item.Name:match("^(.-) Seed")
            return item, crop
        end
    end
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:find("Seed") then
            local crop = item.Name:match("^(.-) Seed")
            return item, crop
        end
    end
    return nil, nil
end

-- Auto Plant
task.spawn(function()
    while task.wait() do
        if autoPlant then
            local character = player.Character or player.CharacterAdded:Wait()
            local root = character:FindFirstChild("HumanoidRootPart")
            local pos = Vector3.new(math.floor(root.Position.X), 0.1, math.floor(root.Position.Z))
            local tool, seedType = findSeedTool()

            if tool and seedType then
                if tool.Parent == backpack then
                    character:FindFirstChild("Humanoid"):EquipTool(tool)
                    repeat task.wait() until tool.Parent == character
                end
                remote:FireServer(pos, seedType)
            end
        end
    end
end)

-- ESP Update Logic
workspace.Farm.DescendantAdded:Connect(function(descendant)
    if mutationESPEnabled and descendant:IsA("Model") and descendant.Parent.Name == "Fruits" then
        local plantModel = descendant.Parent.Parent
        local farm = plantModel:FindFirstAncestorOfClass("Model")
        local data = farm and farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == player.Name then
            createESP(descendant)
        end
    end
end)

-- Initial ESP setup
task.spawn(function()
    task.wait(5) -- Wait for game to load
    updateESP()
end)

-- Periodic ESP refresh
task.spawn(function()
    while task.wait(10) do
        if mutationESPEnabled then
            updateESP()
        end
    end
end)

end

