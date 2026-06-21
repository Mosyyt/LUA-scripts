if script_loaded then warn("Script is already loaded, please rejoin the game to load it again.") return end pcall(function() getgenv().script_loaded = true end)
warn("Loading...")

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

