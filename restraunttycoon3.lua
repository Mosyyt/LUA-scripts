-- Restaurant Automation with Luna UI - Complete Fixed Version
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer.PlayerScripts

-- Safe module imports with error handling
local CustomerSystem, TaskSystem, CookSystem, FurnitureUtility, Particle2D, CustomerState, TaskType

local function safeRequire(path, name)
    local success, module = pcall(function()
        return require(path)
    end)
    if success then
        return module
    else
        warn("Failed to load " .. name .. ": " .. tostring(module))
        return nil
    end
end

CustomerSystem = safeRequire(PlayerScripts.Source.Systems.Restaurant.Customers, "CustomerSystem")
TaskSystem = safeRequire(PlayerScripts.Source.Systems.Restaurant.Tasks, "TaskSystem")
CookSystem = safeRequire(PlayerScripts.Source.Systems.Cook, "CookSystem")
FurnitureUtility = safeRequire(ReplicatedStorage.Source.Utility.FurnitureUtility, "FurnitureUtility")
Particle2D = safeRequire(LocalPlayer.PlayerScripts.Source.Modules.Interfaces.Particle2D, "Particle2D")
CustomerState = safeRequire(ReplicatedStorage.Source.Enums.Restaurant.Customer.CustomerState, "CustomerState")
TaskType = safeRequire(ReplicatedStorage.Source.Enums.Restaurant.Task, "TaskType")

-- Configuration
local CONFIG = {
    ENABLED = false,
    CHECK_INTERVAL = 1,
    MAX_GROUPS = 100,
    MAX_CUSTOMERS = 70,
    DEBUG = false,
    
    AUTO_SEATING = false,
    AUTO_ORDERS = false,
    AUTO_SERVING = false,
    AUTO_DISHES = false,
    AUTO_BILLS = false,
    AUTO_COOKING = false,
    AUTO_COOKING_INTERACTIONS = false,
    
    SERVING_COOLDOWN = 0.5,
    COLLECTING_COOLDOWN = 1,
    BILLING_COOLDOWN = 1,
    COOKING_COOLDOWN = 1,
    
    -- Performance settings
    PERFORMANCE_MODE = "Balanced", -- "Efficient", "Balanced", "Aggressive"
    BATCH_SIZE = 5, -- How many actions to process per cycle
    INTERACTION_DELAY = 0.1, -- Delay between interactions
    SKIP_EMPTY_CYCLES = true, -- Skip cycles when nothing to do
    MAX_ACTIONS_PER_CYCLE = 20 -- Total actions limit per automation cycle
}

-- Anti-spam tracking
local lastActions = {
    orders = {},
    serves = {},
    dishes = {},
    bills = {},
    seats = {},
    cooking = 0
}

local cooldowns = {
    serving = false,
    collecting = false,
    billing = false,
    cooking = false
}

-- Utility Functions
local function getTycoon()
    local success, result = pcall(function()
        return (LocalPlayer.Tycoon and LocalPlayer.Tycoon.Value) or Workspace.Tycoons.Tycoon
    end)
    return success and result or nil
end

local function debugLog(task, message)
    if CONFIG.DEBUG then
        pcall(function()
            print("🤖 [" .. tostring(task) .. "]", tostring(message))
        end)
    end
end

local function setCooldown(type, duration)
    pcall(function()
        cooldowns[type] = true
        task.delay(duration, function()
            cooldowns[type] = false
        end)
    end)
end

local function canPerformAction(actionType, identifier)
    local success, result = pcall(function()
        local now = tick()
        local key = tostring(actionType) .. "_" .. tostring(identifier)
        
        if not lastActions[actionType] then
            lastActions[actionType] = {}
        end
        
        if lastActions[actionType][key] and (now - lastActions[actionType][key]) < 2 then
            return false
        end
        
        lastActions[actionType][key] = now
        return true
    end)
    
    return success and result or false
end

-- Performance optimization based on mode
local function applyPerformanceSettings()
    if CONFIG.PERFORMANCE_MODE == "Efficient" then
        CONFIG.CHECK_INTERVAL = 2
        CONFIG.INTERACTION_DELAY = 0.3
        CONFIG.BATCH_SIZE = 3
        CONFIG.SKIP_EMPTY_CYCLES = true
    elseif CONFIG.PERFORMANCE_MODE == "Balanced" then
        CONFIG.CHECK_INTERVAL = 1
        CONFIG.INTERACTION_DELAY = 0.1
        CONFIG.BATCH_SIZE = 5
        CONFIG.SKIP_EMPTY_CYCLES = true
    elseif CONFIG.PERFORMANCE_MODE == "Aggressive" then
        CONFIG.CHECK_INTERVAL = 0.3
        CONFIG.INTERACTION_DELAY = 0.01
        CONFIG.BATCH_SIZE = 10
        CONFIG.SKIP_EMPTY_CYCLES = false
    end
end
local function findAllKitchenModels(tycoon)
    if not tycoon then return {} end
    
    local success, result = pcall(function()
        local kitchens = {}
        if tycoon:FindFirstChild("Items") then
            for _, item in pairs(tycoon.Items:GetDescendants()) do
                if item:IsA("Model") and item:FindFirstChild("TicketBase") then
                    table.insert(kitchens, item)
                end
            end
        end
        return kitchens
    end)
    
    return success and result or {}
end

-- Find kitchen model helper (kept for compatibility)
local function findKitchenModel(tycoon)
    local kitchens = findAllKitchenModels(tycoon)
    return kitchens[1] or nil
end

-- Restaurant Functions
local function sendCustomersToTables(tycoon)
    if not CONFIG.AUTO_SEATING or not tycoon then return 0 end
    
    local success, result = pcall(function()
        local stats = 0
        
        for groupId = 1, CONFIG.MAX_GROUPS do
            local groupStr = tostring(groupId)
            local groupState = nil
            
            if CustomerSystem and CustomerSystem.GetGroupState then
                local stateSuccess, state = pcall(function()
                    return CustomerSystem:GetGroupState(tycoon, groupStr)
                end)
                if stateSuccess then groupState = state end
            end
            
            if groupState and CustomerState and groupState == CustomerState.Entered and canPerformAction("seats", groupId) then
                local tables = {}
                
                if tycoon:FindFirstChild("Items") then
                    for _, item in pairs(tycoon.Items:GetDescendants()) do
                        if item:IsA("Model") and FurnitureUtility and FurnitureUtility.IsTable then
                            local tableSuccess, isTable = pcall(function()
                                return FurnitureUtility:IsTable(item.Name)
                            end)
                            
                            if tableSuccess and isTable then
                                local inUse = item:GetAttribute("InUse")
                                if not inUse then
                                    table.insert(tables, item)
                                end
                            end
                        end
                    end
                end
                
                if #tables > 0 then
                    local selectedTable = tables[math.random(1, #tables)]
                    local taskData = {
                        Name = "SendToTable",
                        GroupId = groupStr,
                        Tycoon = tycoon,
                        FurnitureModel = selectedTable
                    }
                    
                    pcall(function()
                        ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer(taskData)
                    end)
                    
                    debugLog("SEATING", "Group " .. groupId .. " seated")
                    stats = stats + 1
                end
            end
        end
        
        return stats
    end)
    
    return success and type(result) == "number" and result or 0
end

local function takeCustomerOrders(tycoon)
    if not CONFIG.AUTO_ORDERS or not tycoon then return 0 end
    
    local success, result = pcall(function()
        local stats = 0
        local processed = 0
        
        for groupId = 1, CONFIG.MAX_GROUPS do
            for customerId = 1, CONFIG.MAX_CUSTOMERS do
                -- Batch processing limit
                if processed >= CONFIG.BATCH_SIZE then break end
                
                local groupStr, customerStr = tostring(groupId), tostring(customerId)
                local customerState = nil
                local actionKey = groupId .. "_" .. customerId
                
                if CustomerSystem and CustomerSystem.GetCustomerState then
                    local stateSuccess, state = pcall(function()
                        return CustomerSystem:GetCustomerState(tycoon, groupStr, customerStr)
                    end)
                    if stateSuccess then customerState = state end
                end
                
                if customerState and CustomerState and customerState == CustomerState.Ordering and canPerformAction("orders", actionKey) then
                    local taskData = {
                        Name = TaskType and TaskType.TakeOrder or "TakeOrder",
                        GroupId = groupStr,
                        CustomerId = customerStr,
                        Tycoon = tycoon
                    }
                    
                    pcall(function()
                        ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer(taskData)
                        ReplicatedStorage.Events.SoundRequested:Fire("AlienAccept5")
                    end)
                    
                    debugLog("ORDERS", "Order taken - Group:" .. groupId .. " Customer:" .. customerId)
                    stats = stats + 1
                    processed = processed + 1
                    
                    if CONFIG.INTERACTION_DELAY > 0 then
                        wait(CONFIG.INTERACTION_DELAY)
                    end
                end
            end
            if processed >= CONFIG.BATCH_SIZE then break end
        end
        
        return stats
    end)
    
    return success and type(result) == "number" and result or 0
end

local function serveFoodToCustomers(tycoon)
    if not CONFIG.AUTO_SERVING or not tycoon or cooldowns.serving then return 0 end
    
    local success, result = pcall(function()
        local stats = 0
        
        for groupId = 1, CONFIG.MAX_GROUPS do
            for customerId = 1, CONFIG.MAX_CUSTOMERS do
                local groupStr, customerStr = tostring(groupId), tostring(customerId)
                local customerData = nil
                local actionKey = groupId .. "_" .. customerId
                
                if CustomerSystem and CustomerSystem.GetCustomerData then
                    local dataSuccess, data = pcall(function()
                        return CustomerSystem:GetCustomerData(tycoon, groupStr, customerStr)
                    end)
                    if dataSuccess then customerData = data end
                end
                
                if customerData and customerData.State and CustomerState and customerData.State == CustomerState.WaitingForDish and canPerformAction("serves", actionKey) then
                    setCooldown("serving", CONFIG.SERVING_COOLDOWN)
                    
                    local foods = {}
                    if tycoon:FindFirstChild("Objects") and tycoon.Objects:FindFirstChild("Food") then
                        for _, food in pairs(tycoon.Objects.Food:GetChildren()) do
                            if food:IsA("Model") then
                                table.insert(foods, food)
                            end
                        end
                    end
                    
                    if #foods > 0 then
                        local foodModel = foods[math.random(1, #foods)]
                        local taskData = {
                            Name = TaskType and TaskType.Serve or "Serve",
                            GroupId = groupStr,
                            CustomerId = customerStr,
                            FoodModel = foodModel,
                            Tycoon = tycoon
                        }
                        
                        pcall(function()
                            ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer(taskData)
                            ReplicatedStorage.Events.SoundRequested:Fire("AlienAccept1")
                        end)
                        
                        debugLog("SERVING", "Food served - Group:" .. groupId .. " Customer:" .. customerId)
                        stats = stats + 1
                    end
                    
                    break
                end
            end
        end
        
        return stats
    end)
    
    return success and type(result) == "number" and result or 0
end

local function collectDishes(tycoon)
    if not CONFIG.AUTO_DISHES or not tycoon or cooldowns.collecting then return 0 end
    
    local success, result = pcall(function()
        local stats = 0
        
        if tycoon:FindFirstChild("Items") then
            for _, item in pairs(tycoon.Items:GetDescendants()) do
                if item:IsA("Model") and FurnitureUtility and FurnitureUtility.IsTable then
                    local tableSuccess, isTable = pcall(function()
                        return FurnitureUtility:IsTable(item.Name)
                    end)
                    
                    if tableSuccess and isTable then
                        local trash = item:FindFirstChild("Trash")
                        
                        if trash and canPerformAction("dishes", item.Name) then
                            setCooldown("collecting", CONFIG.COLLECTING_COOLDOWN)
                            
                            local taskData = {
                                Name = TaskType and TaskType.CollectDishes or "CollectDishes",
                                FurnitureModel = item,
                                Tycoon = tycoon
                            }
                            
                            pcall(function()
                                ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer(taskData)
                                ReplicatedStorage.Events.SoundRequested:Fire("AlienAccept5")
                            end)
                            
                            debugLog("DISHES", "Dishes collected from " .. item.Name)
                            stats = stats + 1
                            break
                        end
                    end
                end
            end
        end
        
        return stats
    end)
    
    return success and type(result) == "number" and result or 0
end

local function collectBills(tycoon)
    if not CONFIG.AUTO_BILLS or not tycoon or cooldowns.billing then return 0 end
    
    local success, result = pcall(function()
        local stats = 0
        
        if tycoon:FindFirstChild("Items") then
            for _, item in pairs(tycoon.Items:GetDescendants()) do
                if item:IsA("Model") and FurnitureUtility and FurnitureUtility.IsTable then
                    local tableSuccess, isTable = pcall(function()
                        return FurnitureUtility:IsTable(item.Name)
                    end)
                    
                    if tableSuccess and isTable then
                        local bill = item:FindFirstChild("Bill")
                        
                        if bill and canPerformAction("bills", item.Name) then
                            setCooldown("billing", CONFIG.BILLING_COOLDOWN)
                            
                            local taskData = {
                                Name = TaskType and TaskType.CollectBill or "CollectBill",
                                FurnitureModel = item,
                                Tycoon = tycoon
                            }
                            
                            pcall(function()
                                ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer(taskData)
                                ReplicatedStorage.Events.SoundRequested:Fire("Cash")
                                if Particle2D and Particle2D.CreateCurrencyParticles then
                                    Particle2D:CreateCurrencyParticles(bill:GetAttribute("Value") or 0)
                                end
                            end)
                            
                            debugLog("BILLS", "Bill collected from " .. item.Name)
                            stats = stats + 1
                            break
                        end
                    end
                end
            end
        end
        
        return stats
    end)
    
    return success and type(result) == "number" and result or 0
end

local function autoCookingInteractions(tycoon)
    if not CONFIG.AUTO_COOKING_INTERACTIONS or not tycoon then return 0 end
    
    local success, result = pcall(function()
        local stats = 0
        local maxInteractions = CONFIG.BATCH_SIZE -- Limit interactions per cycle
        
        if not workspace:FindFirstChild("Temp") then return 0 end
        
        -- Get all kitchen models with TicketBase
        local kitchenModels = findAllKitchenModels(tycoon)
        if #kitchenModels == 0 then return 0 end
        
        -- Process each prompt once with all kitchens, but limit total actions
        for _, v in pairs(workspace.Temp:GetChildren()) do
            if v:IsA("Part") and stats < maxInteractions then
                for _, child in pairs(v:GetChildren()) do
                    if string.find(child.Name, "%d") and stats < maxInteractions then
                        -- Use ALL kitchen models, but limit total interactions per cycle
                        for _, kitchenModel in pairs(kitchenModels) do
                            if stats >= maxInteractions then break end -- Stop if we hit the limit
                            
                            local worldPos = Vector3.new(-270, 1.100000023841858, 14)
                            
                            local base = kitchenModel:FindFirstChild("Base")
                            local attachment = base and base:FindFirstChild("Attachment")
                            if attachment then
                                worldPos = attachment.WorldPosition
                            end
                            
                            local interactionData = {
                                ["WorldPosition"] = worldPos,
                                ["Prompt"] = child,
                                ["Part"] = v,
                                ["InteractionType"] = "OrderCounter",
                                ["Id"] = child.Name,
                                ["TemporaryPart"] = v,
                                ["ActionText"] = "Cook",
                                ["Model"] = kitchenModel
                            }
                            
                            pcall(function()
                                ReplicatedStorage.Events.Restaurant.Interactions.Interacted:FireServer(tycoon, interactionData)
                            end)
                            
                            debugLog("COOKING-INTERACT", "Interacted with kitchen: " .. kitchenModel.Name .. " using prompt: " .. child.Name)
                            stats = stats + 1
                            
                            -- Only add delay if we're not at the limit (to speed up when needed)
                            if CONFIG.INTERACTION_DELAY > 0 and stats < maxInteractions then
                                wait(CONFIG.INTERACTION_DELAY)
                            end
                        end
                        
                        -- If we hit the limit, break out of prompt loop too
                        if stats >= maxInteractions then break end
                    end
                end
                
                -- If we hit the limit, break out of part loop too
                if stats >= maxInteractions then break end
            end
        end
        
        return stats
    end)
    
    return success and type(result) == "number" and result or 0
end

local function autoCompleteCooking(tycoon)
    if not CONFIG.AUTO_COOKING or not tycoon or cooldowns.cooking then return 0 end
    
    local success, result = pcall(function()
        local now = tick()
        if now - lastActions.cooking < CONFIG.COOKING_COOLDOWN then return 0 end
        
        lastActions.cooking = now
        setCooldown("cooking", CONFIG.COOKING_COOLDOWN)
        
        local stats = 0
        local currentKitchen = nil
        local currentItemType = nil
        
        if CookSystem then
            pcall(function()
                if CookSystem.GetCurrentKitchenModel then
                    currentKitchen = CookSystem:GetCurrentKitchenModel()
                end
                if CookSystem.CurrentItemType then
                    currentItemType = CookSystem.CurrentItemType
                end
            end)
        end
        
        if currentKitchen and currentItemType then
            pcall(function()
                ReplicatedStorage.Events.Cook.CookInputRequested:FireServer("CompleteTask", currentKitchen, currentItemType)
            end)
            debugLog("COOKING", "Completed current task")
            stats = stats + 1
        else
            if tycoon:FindFirstChild("Items") then
                for _, item in pairs(tycoon.Items:GetDescendants()) do
                    if item:IsA("Model") and (item.Name:match("^K%d+$") or item.Name:lower():find("kitchen")) then
                        pcall(function()
                            ReplicatedStorage.Events.Cook.CookInputRequested:FireServer("CompleteTask", item, "Kitchen")
                        end)
                        stats = stats + 1
                    end
                end
            end
        end
        
        return stats
    end)
    
    return success and type(result) == "number" and result or 0
end

-- Main automation function with task rotation
local function runAutomation()
    if not CONFIG.ENABLED then return end
    
    local tycoon = getTycoon()
    if not tycoon then return end
    
    local totalStats = {
        seats = 0,
        orders = 0,
        serves = 0,
        dishes = 0,
        bills = 0,
        cooking = 0,
        interactions = 0
    }
    
    -- Task rotation to prevent one task from dominating
    local functions = {
        {sendCustomersToTables, "seats"},
        {takeCustomerOrders, "orders"},
        {serveFoodToCustomers, "serves"},
        {collectDishes, "dishes"},
        {collectBills, "bills"},
        {autoCompleteCooking, "cooking"},
        {autoCookingInteractions, "interactions"}
    }
    
    -- Limit total actions per cycle to prevent blocking
    local totalActionsThisCycle = 0
    local maxActionsPerCycle = CONFIG.MAX_ACTIONS_PER_CYCLE or (CONFIG.BATCH_SIZE * 2)
    
    for _, funcData in pairs(functions) do
        if totalActionsThisCycle >= maxActionsPerCycle then
            break -- Stop if we've done too much this cycle
        end
        
        local func, statName = funcData[1], funcData[2]
        local success, result = pcall(function()
            return func(tycoon)
        end)
        
        if success and type(result) == "number" then
            totalStats[statName] = result
            totalActionsThisCycle = totalActionsThisCycle + result
        end
        
        -- Small break between different task types
        if result and result > 0 and CONFIG.INTERACTION_DELAY > 0 then
            wait(CONFIG.INTERACTION_DELAY)
        end
    end
    
    -- Skip cycle if nothing happened and efficiency mode is on
    if CONFIG.SKIP_EMPTY_CYCLES and totalActionsThisCycle == 0 then
        wait(CONFIG.CHECK_INTERVAL * 2) -- Wait longer on empty cycles
    end
    
    -- Debug summary
    if CONFIG.DEBUG then
        pcall(function()
            if totalActionsThisCycle > 0 then
                debugLog("SUMMARY", string.format("Seats:%d Orders:%d Serves:%d Dishes:%d Bills:%d Cooking:%d Interactions:%d", 
                    totalStats.seats, totalStats.orders, totalStats.serves, totalStats.dishes, totalStats.bills, totalStats.cooking, totalStats.interactions))
            end
        end)
    end
end

-- Load Luna UI
local function loadUI()
    local success, Luna = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua', true))()
    end)
    
    if not success then
        warn("Failed to load Luna UI")
        return
    end
    
    local windowSuccess, Window = pcall(function()
        return Luna:CreateWindow({
            Name = 'Restaurant Tycoon 3',
            Subtitle = 'Full Auto',
            LogoID = '111108278176277',
            LoadingEnabled = true,
            LoadingTitle = 'Loading Restaurant Tycoon 3...',
            LoadingSubtitle = 'Restaurant Tycoon 3',
            ConfigSettings = {
                RootFolder = 'RestaurantBot',
                ConfigFolder = 'Configs',
                AutoLoadConfig = true,
            },
        })
    end)
    
    if not windowSuccess then
        warn("Failed to create window")
        return
    end
    
    -- Create Main Tab
    local mainSuccess, MainTab = pcall(function()
        return Window:CreateTab({
            Name = 'Main Functions',
            Icon = 'restaurant',
            ImageSource = 'Material',
            ShowTitle = true,
        })
    end)
    
    if mainSuccess then
        pcall(function()
            MainTab:CreateToggle({
                Name = 'Enable Auto Farm',
                CurrentValue = false,
                Callback = function(Value)
                    CONFIG.ENABLED = Value
                    print(Value and "✅ Restaurant automation enabled!" or "⏹️ Restaurant automation disabled!")
                end,
            })
            
            MainTab:CreateSection("Restaurant Tasks")
            
            MainTab:CreateToggle({
                Name = 'Auto Seat Customers',
                CurrentValue = false,
                Callback = function(Value) CONFIG.AUTO_SEATING = Value end,
            })
            
            MainTab:CreateToggle({
                Name = 'Auto Take Orders',
                CurrentValue = false,
                Callback = function(Value) CONFIG.AUTO_ORDERS = Value end,
            })
            
            MainTab:CreateToggle({
                Name = 'Auto Serve Food',
                CurrentValue = false,
                Callback = function(Value) CONFIG.AUTO_SERVING = Value end,
            })
            
            MainTab:CreateToggle({
                Name = 'Auto Collect Dishes',
                CurrentValue = false,
                Callback = function(Value) CONFIG.AUTO_DISHES = Value end,
            })
            
            MainTab:CreateToggle({
                Name = 'Auto Collect Bills',
                CurrentValue = false,
                Callback = function(Value) CONFIG.AUTO_BILLS = Value end,
            })
            
            MainTab:CreateToggle({
                Name = 'Auto Complete Cooking',
                CurrentValue = false,
                Callback = function(Value) CONFIG.AUTO_COOKING = Value end,
            })
            
            MainTab:CreateToggle({
                Name = 'Auto Cooking Interactions',
                CurrentValue = false,
                Callback = function(Value) CONFIG.AUTO_COOKING_INTERACTIONS = Value end,
            })
            
            MainTab:CreateSection("Quick Actions")
            
            MainTab:CreateButton({
                Name = 'Enable All Tasks',
                Callback = function()
                    for key, _ in pairs(CONFIG) do
                        if key:find("AUTO_") then
                            CONFIG[key] = true
                        end
                    end
                    print("✅ All tasks enabled!")
                end,
            })
            
            MainTab:CreateButton({
                Name = 'Disable All Tasks',
                Callback = function()
                    for key, _ in pairs(CONFIG) do
                        if key:find("AUTO_") then
                            CONFIG[key] = false
                        end
                    end
                    print("⏹️ All tasks disabled!")
                end,
            })
        end)
    end
    
    -- Create Settings Tab
    local settingsSuccess, SettingsTab = pcall(function()
        return Window:CreateTab({
            Name = 'Settings',
            Icon = 'settings',
            ImageSource = 'Material',
            ShowTitle = true,
        })
    end)
    
    if settingsSuccess then
        pcall(function()
            SettingsTab:CreateSection("Performance Settings")
            
            SettingsTab:CreateDropdown({
                Name = 'Performance Mode',
                Options = {'Efficient', 'Balanced', 'Aggressive'},
                CurrentOption = {'Balanced'},
                Callback = function(Option)
                    CONFIG.PERFORMANCE_MODE = Option[1]
                    applyPerformanceSettings()
                    print("🚀 Performance mode set to:", Option[1])
                end,
            })
            
            SettingsTab:CreateSlider({
                Name = 'Batch Size (actions per cycle)',
                Range = {1, 20},
                Increment = 1,
                CurrentValue = 5,
                Callback = function(Value)
                    CONFIG.BATCH_SIZE = Value
                end,
            })
            
            SettingsTab:CreateSlider({
                Name = 'Interaction Delay (seconds)',
                Range = {0, 0.5},
                Increment = 0.01,
                CurrentValue = 0.1,
                Callback = function(Value)
                    CONFIG.INTERACTION_DELAY = Value
                end,
            })
            
            SettingsTab:CreateToggle({
                Name = 'Skip Empty Cycles',
                CurrentValue = true,
                Callback = function(Value)
                    CONFIG.SKIP_EMPTY_CYCLES = Value
                end,
            })
            
            SettingsTab:CreateSlider({
                Name = 'Max Actions Per Cycle',
                Range = {5, 50},
                Increment = 5,
                CurrentValue = 20,
                Callback = function(Value)
                    CONFIG.MAX_ACTIONS_PER_CYCLE = Value
                end,
            })
            
            SettingsTab:CreateSection("Basic Settings")
            
            SettingsTab:CreateSlider({
                Name = 'Check Interval (seconds)',
                Range = {0.5, 5},
                Increment = 0.1,
                CurrentValue = 1,
                Callback = function(Value) CONFIG.CHECK_INTERVAL = Value end,
            })
            
            SettingsTab:CreateSlider({
                Name = 'Max Groups',
                Range = {1, 100},
                Increment = 1,
                CurrentValue = 10,
                Callback = function(Value) CONFIG.MAX_GROUPS = Value end,
            })
            
            SettingsTab:CreateSlider({
                Name = 'Max Customers per Group',
                Range = {1, 70},
                Increment = 1,
                CurrentValue = 5,
                Callback = function(Value) CONFIG.MAX_CUSTOMERS = Value end,
            })
            
            SettingsTab:CreateToggle({
                Name = 'Debug Mode',
                CurrentValue = false,
                Callback = function(Value) CONFIG.DEBUG = Value end,
            })
        end)
    end
    
    -- Create Advanced Tab
    local advancedSuccess, AdvancedTab = pcall(function()
        return Window:CreateTab({
            Name = 'Advanced',
            Icon = 'engineering',
            ImageSource = 'Material',
            ShowTitle = true,
        })
    end)
    
    if advancedSuccess then
        pcall(function()
            AdvancedTab:CreateButton({
                Name = 'Test Cooking Interactions',
                Callback = function()
                    local tycoon = getTycoon()
                    if not tycoon then 
                        print("❌ No tycoon found")
                        return 
                    end
                    
                    print("🔥 Testing cooking interactions...")
                    local stats = autoCookingInteractions(tycoon)
                    print("✅ Completed", stats, "cooking interactions")
                end,
            })

            AdvancedTab:CreateButton({
                Name = 'Show Status',
                Callback = function()
                    print("=== RESTAURANT AUTOMATION STATUS ===")
                    print("Master Enabled:", CONFIG.ENABLED)
                    for key, value in pairs(CONFIG) do
                        if key:find("AUTO_") then
                            print(key:gsub("AUTO_", ""):gsub("_", " "):lower():gsub("^%l", string.upper) .. ":", value)
                        end
                    end
                    print("Current Tycoon:", getTycoon() and getTycoon().Name or "None")
                    print("====================================")
                end,
            })
            
            AdvancedTab:CreateButton({
                Name = 'Clear Spam Protection',
                Callback = function()
                    lastActions = {orders = {}, serves = {}, dishes = {}, bills = {}, seats = {}, cooking = 0}
                    cooldowns = {serving = false, collecting = false, billing = false, cooking = false}
                    print("🧹 Spam protection cleared!")
                end,
            })
        end)
    end
    
    -- Config Tab
    local configSuccess, ConfigTab = pcall(function()
        return Window:CreateTab({
            Name = 'Config',
            Icon = 'save',
            ImageSource = 'Material',
            ShowTitle = true,
        })
    end)
    
    if configSuccess then
        pcall(function()
            ConfigTab:BuildConfigSection()
        end)
    end
    
    -- Load config
    pcall(function()
        Luna:LoadAutoloadConfig()
    end)
end

-- Event handler with safety
if TaskSystem and TaskSystem.TaskInputReceived then
    pcall(function()
        TaskSystem.TaskInputReceived:Connect(function(taskData)
            if not CONFIG.ENABLED or not taskData or not taskData.Tycoon then return end
            
            pcall(function()
                local tycoon = taskData.Tycoon
                
                if taskData.CurrentTask == nil and taskData.GroupId and taskData.CustomerId then
                    if CustomerSystem and CustomerSystem.GetCustomerState and CustomerState then
                        local customerState = CustomerSystem:GetCustomerState(tycoon, taskData.GroupId, taskData.CustomerId)
                        if customerState == CustomerState.Ordering then
                            local actionKey = taskData.GroupId .. "_" .. taskData.CustomerId
                            if canPerformAction("orders", actionKey) then
                                local taskDataToSend = {
                                    Name = TaskType and TaskType.TakeOrder or "TakeOrder",
                                    GroupId = taskData.GroupId,
                                    CustomerId = taskData.CustomerId,
                                    Tycoon = tycoon
                                }
                                
                                ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer(taskDataToSend)
                                ReplicatedStorage.Events.SoundRequested:Fire("AlienAccept5")
                                debugLog("EVENT-ORDER", "Immediate order taken")
                            end
                        end
                    end
                end
            end)
        end)
    end)
end

-- Main automation loop
spawn(function()
    while true do
        pcall(function()
            if CONFIG.ENABLED then
                runAutomation()
            end
        end)
        wait(CONFIG.CHECK_INTERVAL)
    end
end)

-- Load UI
loadUI()

print("🤖 Restaurant Automation Loaded!")
print("🎛️ UI should be available if Luna loaded successfully")