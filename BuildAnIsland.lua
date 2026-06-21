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
    Name = 'Mosy Hub',
    Subtitle = 'By Mosy',
    LogoID = '111108278176277',
    LoadingEnabled = true,
    LoadingTitle = 'Loading Mosy Hub...',
    LoadingSubtitle = 'Build An Island',
    ConfigSettings = {
        RootFolder = 'Mosy',
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