-- TODO: Clean up ESP code.
-- TODO: Fix bugs in Full Bright
-- TODO: Mostly, rewrite Game Events, due to broken features.
-- ! ANTI-TAMPERING/KEY SYSTEM CHECK
-- ! WHITELIST_KEY IS SET BY THE LOADER, IF UNSET, KICK!
if getfenv().WHITELIST_KEY == nil then
    game.Players.LocalPlayer:Kick("You are not allowed to use this script.")
end

-- ! LOAD GUI

-- ! INITIALIZE LIBRARY
Library = loadstring(game:HttpGet(
                         "https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))()

-- ! INITIALIZATION FUNCTIONS

function initializeMiscTab()
    local Tab = Window:Tab({
        Name = "Misc",
        Icon = "rbxassetid://13260871719",
        Description = "Miscellaneous"
    })

    local fullbrightCnn = nil
    Tab:Button({
        Name = "Full Bright",
        Callback = function()
            local function setFullBright()
                local replicatedStg = game:GetService("ReplicatedStorage")
                replicatedStg.NightProperties.Brightness.Value = 6
                replicatedStg.DayProperties.Brightness.Value = 6
                replicatedStg.NightProperties.ClockTime.Value = 13
                replicatedStg.DayProperties.ClockTime.Value = 13

                replicatedStg.NightProperties["ColorShift_Top"].Value =
                    Color3.new(1, 1, 1)
                replicatedStg.DayProperties["ColorShift_Top"].Value =
                    Color3.new(1, 1, 1)

                replicatedStg.DayProperties["Ambient"].Value = Color3.new(1, 1,
                                                                          1)
                replicatedStg.NightProperties["Ambient"].Value = Color3.new(1,
                                                                            1, 1)
                replicatedStg.CurrentLightingProperties["Ambient"].Value =
                    Color3.new(1, 1, 1)
                replicatedStg.CurrentLightingProperties2["Ambient"].Value =
                    Color3.new(1, 1, 1)
                replicatedStg.Ambient.Value = Color3.new(1, 1, 1)
            end
            setFullBright()
            fullbrightCnn = game:GetService("RunService").Heartbeat:Connect(
                                function()
                    task.wait(10)
                    setFullBright()
                end)
        end
    })
    local infSprintClosure = loadstring(game:HttpGet(
                                            ("https://pastebin.com/raw/UJWKsHXC"),
                                            true))
    local infStaminaSet = false
    local sprintUnsetRemovalConnection = nil
    local sprintSetOnAddedConnection = nil

    Tab:Button({
        Name = "Infinite Stamina",
        Callback = function()
            if game.Players.LocalPlayer.Character == nil then
                Window:Notify({
                    Title = "Your character does not exist",
                    Text = "Infinite stamina not set. Please spawn before triggering it, this is only going to happen this first time!",
                    Duration = 5
                })
                return
            end

            if infStaminaSet then
                Window:Notify({
                    Title = "Infinite Stamina",
                    Text = "Infinite stamina is already enabled!",
                    Duration = 5
                })
                return
            end

            if sprintUnsetRemovalConnection == nil then
                sprintUnsetRemovalConnection =
                    game.Players.LocalPlayer.CharacterRemoving:Connect(
                        function(char)
                            infStaminaSet = false
                        end)
            end
            if sprintSetOnAddedConnection == nil then
                sprintSetOnAddedConnection =
                    game.Players.LocalPlayer.CharacterAdded:Connect(
                        function(char)
                            infStaminaSet = true
                            task.wait(3)
                            infSprintClosure()
                        end)
            end

            infSprintClosure()
            infStaminaSet = true
        end
    })

    local fovHbCnn = nil
    Tab:Slider({
        Name = "Fog Render Distance",
        Default = game:GetService("ReplicatedStorage").CurrentLightingProperties
            .FogEnd.Value,
        Min = 0,
        Max = 1000,
        Callback = function(fogDistance)
            if fovHbCnn then fovHbCnn:Disconnect() end
            local replicatedStg = game:GetService("ReplicatedStorage")
            replicatedStg.DayProperties.FogEnd.Value = fogDistance
            replicatedStg.NightProperties.FogEnd.Value = fogDistance

            fovHbCnn = game:GetService("RunService").Heartbeat:Connect(
                           function()
                    game:GetService("ReplicatedStorage").CurrentLightingProperties
                        .FogEnd.Value = fogDistance
                end)
        end
    })
    heartBeatGameEventsCnn = nil
    heartBeatPlayerDownedCnn = nil
    Tab:Toggle({
        Name = "Game Events",
        Default = false,
        Callback = function(state)
            -- LOCALS FOR EVENTS SYSTEM
            alertedPowerLow = false
            alertedNightStarted = true
            alertedNightOrDayCycle = false
            alertedRakeSpawned = false
            alertedRakeAttackPlayer = false
            alertedRakeChasing = false
            alertedBloodHour = false
            alertedTurningDayTime = false
            rakeWorkspaceReference = nil
            -- (END) LOCALS FOR EVENTS SYSTEM
            if state and heartBeatGameEventsCnn == nil then
                local replicatedStorage = game:GetService("ReplicatedStorage")
                heartBeatGameEventsCnn =
                    game:GetService("RunService").Heartbeat:Connect(function()
                        if not alertedPowerLow and
                            replicatedStorage.PowerValues.PowerLevel.Value /
                            replicatedStorage.PowerValues.PPMS.Value < 20 then
                            alertedPowerLow = true
                            Window:Notify({
                                Title = "Power Status:",
                                Text = "The power will run out soon, around " ..
                                    replicatedStorage.PowerValues.PowerLevel
                                        .Value /
                                    replicatedStorage.PowerValues.PPMS.Value ..
                                    " seconds left!",
                                Duration = 10,
                                Callback = function()
                                    return
                                end
                            })
                        end

                        -- Restore switch.
                        if alertedPowerLow and
                            replicatedStorage.PowerValues.PowerLevel.Value > 500 then
                            alertedPowerLow = false
                        end

                        if replicatedStorage.Night.Value == true and
                            replicatedStorage.Timer.Value > 450 and
                            not alertedNightStarted then
                            alertedBloodHour = false -- Restore when false.
                            alertedNightStarted = true
                            alertedNightOrDayCycle = false
                            alertedRakeSpawned = false
                            Window:Notify({
                                Title = "Night started",
                                Text = "The in-game night cycle has started.",
                                Duration = 10,
                                Callback = function()
                                    return
                                end
                            })
                        end

                        if replicatedStorage.Timer.Value <= 15 and
                            replicatedStorage.Timer.Value > 0 and
                            not alertedNightOrDayCycle then
                            alertedNightOrDayCycle = true
                            if replicatedStorage.Night.Value then
                                Window:Notify({
                                    Title = "Night ends soon",
                                    Text = "The in-game night will end in " ..
                                        replicatedStorage.Timer.Value ..
                                        " seconds.",
                                    Duration = 15,
                                    Callback = function()
                                        return
                                    end
                                })
                            else
                                Window:Notify({
                                    Title = "Night starts soon",
                                    Text = "The in-game night will start in " ..
                                        replicatedStorage.Timer.Value ..
                                        " seconds.",
                                    Duration = 15,
                                    Callback = function()
                                        return
                                    end
                                })
                            end
                        end

                        if replicatedStorage.Timer.Value == 0 then
                            alertedNightOrDayCycle = false
                            alertedNightStarted = false
                        end

                        if rakeWorkspaceReference and not alertedRakeSpawned then
                            alertedRakeSpawned = true
                            Window:Notify({
                                Title = "The Rake Status",
                                Text = "The Rake has spawned in the map.",
                                Duration = 15,
                                Callback = function()
                                    return
                                end
                            })
                        end

                        if game:GetService("ReplicatedStorage").InitiateBloodHour
                            .Value == true and not alertedBloodHour then
                            alertedBloodHour = true
                            Window:Notify({
                                Title = "Blood Hour started",
                                Text = "The blood hour has started",
                                Duration = 10,
                                Callback = function()
                                    return
                                end
                            })
                        end

                        if rakeWorkspaceReference == nil then
                            rakeWorkspaceReference = false -- Stub.
                            task.spawn(function()
                                while workspace:FindFirstChild("Rake") == nil do
                                    task.wait(5)
                                end
                                rakeWorkspaceReference =
                                    workspace:FindFirstChild("Rake")
                            end)
                        end

                        if rakeWorkspaceReference then
                            local monster =
                                rakeWorkspaceReference:FindFirstChild("Monster")

                            if monster == nil then
                                return
                            end

                            if monster.WalkSpeed > 29 and
                                not game:GetService("ReplicatedStorage").InitiateBloodHour
                                    .Value and not alertedTurningDayTime then
                                alertedTurningDayTime = true
                                Window:Notify({
                                    Title = "The Rake AI",
                                    Text = "The rake is hiding back to its base (Turning daytime)!",
                                    Duration = 10,
                                    Callback = function()
                                        return
                                    end
                                })
                            end
                            if monster.WalkSpeed > 16 and not alertedRakeChasing then
                                alertedRakeChasing = true
                                Window:Notify({
                                    Title = "The Rake AI",
                                    Text = "The rake is chasing somebody",
                                    Duration = 10,
                                    Callback = function()
                                        return
                                    end
                                })
                            end
                            if alertedRakeChasing and monster.WalkSpeed == 13 then
                                alertedRakeChasing = false
                                Window:Notify({
                                    Title = "The Rake AI",
                                    Text = "The rake has stopped chasing",
                                    Duration = 10,
                                    Callback = function()
                                        return
                                    end
                                })
                            end

                            if not alertedRakeAttackPlayer and monster.WalkSpeed <=
                                10 then
                                alertedRakeAttackPlayer = true
                                Window:Notify({
                                    Title = "The Rake AI",
                                    Text = "The rake has possibly attacked somebody",
                                    Duration = 5,
                                    Callback = function()
                                        return
                                    end
                                })
                            end
                            if alertedRakeAttackPlayer and monster.WalkSpeed >
                                10 then
                                alertedRakeAttackPlayer = false -- Do magic.
                            end
                        end
                    end)
                local downedPlayers = {}
                cleanupTask = task.spawn(function()
                    while task.wait(40) and heartBeatPlayerDownedCnn do
                        downedPlayers = {}
                    end
                    local cpy = cleanupTask
                    cleanupTask = nil
                    task.cancel(cpy)
                end)
                local function ShowGuiForPlayerDowned(v)
                    if v.Character.Downed.Value == true then
                        downedPlayers[v.Name] = true
                        Window:Notify({
                            Title = "A Player has been downed!",
                            Text = v.Character.Name .. " has been downed",
                            Duration = 10,
                            Callback = function()
                                return
                            end
                        })
                    end
                end
                heartBeatPlayerDownedCnn =
                    game:GetService("RunService").Heartbeat:Connect(function()
                        for i, v in ipairs(game.Players:GetChildren()) do
                            if downedPlayers[v.Name] == nil and v and
                                v.Character and v.Character.Downed then
                                ShowGuiForPlayerDowned(v)
                            end -- This code compiles, highlighting and LSP being gay
                        end
                    end)
            end

            if not state and heartBeatGameEventsCnn and heartBeatPlayerDownedCnn then
                heartBeatGameEventsCnn:Disconnect()
                heartBeatPlayerDownedCnn:Disconnect()
                if cleanupTask then task.cancel(cleanupTask) end
            end
        end
    })
end

function initializeVisualsTab()
    local espItems = {}
    local Tab = Window:Tab({
        Name = "Visuals",
        Description = "Visuals Tab (ESP)",
        Icon = "rbxassetid://6523858394", -- Tab Icon
        Hidden = false -- IGNORE THIS
    })

    local destroyingRakeConnection = nil
    local rakeStateKeeper = nil
    Tab:Toggle({
        Name = "The Rake ESP",
        Default = false,
        Description = "Marks the Rake using an ESP!",
        Callback = function(state)
            local espOrigin_ = workspace:FindFirstChild("Rake") -- Just for setting Parent

            local espName = "The Rake"

            local function DestroyRakeESP()
                if espItems == nil then return end

                for i, value in ipairs(espItems) do
                    if value["Identifier"] == "Rake" then
                        if value["Glow"] then
                            value["Glow"]:Destroy()
                        end

                        if value["Text"] and value["Text"] == "The Rake" then
                            value["Text"]:Destroy()
                        end

                        if value["BillboardObject"] then
                            value["BillboardObject"]:Destroy()
                        end

                        table.remove(espItems, i)
                        return
                    end
                end
            end

            local function CreateRakeESP(espOrigin)
                espBillboard = Instance.new("BillboardGui")
                espBillboard.Name = "ESP_BILL"
                espBillboard.AlwaysOnTop = true
                espBillboard.LightInfluence = 1
                espBillboard.Size = UDim2.new(0, 100, 0, 20)
                espBillboard.StudsOffset = Vector3.new(0, 1, 0)
                espBillboard.Adornee = espOrigin
                espBillboard.Parent = espOrigin -- gethui()

                espText = Instance.new("TextLabel")
                espText.Name = "ESPLabel"
                espText.BackgroundTransparency = 1
                espText.Size = UDim2.new(1, 0, 1, 0)
                espText.Font = Enum.Font.SourceSansBold
                espText.FontSize = Enum.FontSize.Size14
                espText.TextColor3 = Color3.new(1, 1, 1) -- change text to something idfk
                espText.TextStrokeTransparency = 0.5
                espText.TextScaled = true
                espText.TextWrapped = true
                espText.Text = espName
                espText.Parent = espBillboard

                espGlow = Instance.new("BoxHandleAdornment")
                espGlow.Name = "ESPBox"
                espGlow.Adornee = espOrigin
                espGlow.AlwaysOnTop = true
                espGlow.Size = Vector3.new(2, 6, 3)
                espGlow.Color3 = Color3.new(0.9, 0.3, 0.41)
                espGlow.Transparency = 0.7
                espGlow.ZIndex = 1
                espGlow.Parent = espOrigin -- gethui()

                table.insert(espItems, {
                    Glow = espGlow,
                    Text = espText,
                    BillboardObject = espBillboard,
                    Identifier = "Rake"
                })
            end

            local refRake = espOrigin_
            local createdEsp = false
            if state then
                if rakeStateKeeper == nil then
                    rakeStateKeeper = task.spawn(function()
                        while true do
                            task.wait(5)
                            if refRake == nil then
                                while workspace:FindFirstChild("Rake") == nil do
                                    task.wait(5)
                                end
                                refRake = workspace:FindFirstChild("Rake")
                                CreateRakeESP(refRake)
                                if destroyingRakeConnection == nil then
                                    destroyingRakeConnection =
                                        refRake.Destroying:Connect(function()
                                            DestroyRakeESP()
                                            refRake = nil
                                            createdEsp = false
                                        end)
                                end
                            end
                        end
                    end)
                end
                if refRake then CreateRakeESP(refRake) end
                if destroyingRakeConnection then
                    destroyingRakeConnection:Disconnect()
                    destroyingRakeConnection = nil
                end
                if destroyingRakeConnection == nil and refRake then
                    destroyingRakeConnection =
                        refRake.Destroying:Connect(function()
                            DestroyRakeESP()
                            refRake = nil
                            createdEsp = false
                        end)
                end
            else
                DestroyRakeESP()
            end
        end
    })

    local plrAddedCnn = nil
    local plrRemovedCnn = nil
    Tab:Toggle({
        Name = "Players ESP",
        Default = false,
        Callback = function(state)
            local espName = "The Rake"

            local function DestroyEsp(espId)
                if espItems == nil then return end

                for i, value in ipairs(espItems) do
                    if value["Identifier"] == espId then
                        if value["Glow"] then
                            value["Glow"]:Destroy()
                        end

                        if value["Text"] and value["Text"] ~= "Rake" then
                            value["Text"]:Destroy()
                        end

                        if value["BillboardObject"] then
                            value["BillboardObject"]:Destroy()
                        end

                        table.remove(espItems, i)
                        return
                    end
                end
            end

            local function CreateEsp(espOrigin, espName, identifier)
                espBillboard = Instance.new("BillboardGui")
                espBillboard.Name = "ESP_BILL"
                espBillboard.AlwaysOnTop = true
                espBillboard.LightInfluence = 1
                espBillboard.Size = UDim2.new(0, 100, 0, 20)
                espBillboard.StudsOffset = Vector3.new(0, 1, 0)
                espBillboard.Adornee = espOrigin
                espBillboard.Parent = espOrigin -- gethui()

                espText = Instance.new("TextLabel")
                espText.Name = "ESPLabel"
                espText.BackgroundTransparency = 1
                espText.Size = UDim2.new(1, 0, 1, 0)
                espText.Font = Enum.Font.SourceSansBold
                espText.FontSize = Enum.FontSize.Size14
                espText.TextColor3 = Color3.new(1, 1, 1) -- change text to something idfk
                espText.TextStrokeTransparency = 0.5
                espText.TextScaled = true
                espText.TextWrapped = true
                espText.Text = espName
                espText.Parent = espBillboard

                espGlow = Instance.new("BoxHandleAdornment")
                espGlow.Name = "ESPBox"
                espGlow.Adornee = espOrigin
                espGlow.AlwaysOnTop = true
                espGlow.Size = Vector3.new(4, 6, 3)
                espGlow.Color3 = Color3.new(0.4, 0.7, 0.5)
                espGlow.Transparency = 0.7
                espGlow.ZIndex = 1
                espGlow.Parent = espOrigin -- gethui()

                table.insert(espItems, {
                    Glow = espGlow,
                    Text = espText,
                    BillboardObject = espBillboard,
                    Identifier = identifier
                })
            end

            local refRake = nil
            local createdEsp = false
            if state then
                for i, v in ipairs(game.Players:GetChildren()) do
                    if v.UserId ~= game.Players.LocalPlayer.UserId and
                        v.Character and v.Character:FindFirstChild("Humanoid") then
                        local uid = v.UserId
                        CreateEsp(v.Character, v.Character.Name, uid)
                        v.CharacterAdded:Connect(function(char)
                            task.wait(2)

                            CreateEsp(char, char.Name, uid)
                        end)
                        v.CharacterRemoving:Connect(function()
                            task.wait(2)

                            DestroyEsp(uid)
                        end)
                    end
                end
                if plrAddedCnn == nil then
                    plrAddedCnn =
                        game:GetService("Players").PlayerAdded:Connect(function(
                            playerObject)
                            local uid = playerObject.UserId
                            playerObject.CharacterAdded:Connect(function(char)
                                task.wait(2)

                                CreateEsp(char, char.Name, uid)
                            end)
                            playerObject.CharacterRemoving:Connect(function()
                                task.wait(2)

                                DestroyEsp(uid)
                            end)
                        end)
                    plrRemovedCnn =
                        game:GetService("Players").PlayerRemoving:Connect(
                            function(player)
                                DestroyEsp(player.UserId)
                            end)
                end
            else
                for i, v in ipairs(game.Players:GetChildren()) do
                    if v.Character and v.Character:FindFirstChild("Humanoid") then
                        DestroyEsp(v.UserId)
                    end
                end
                if plrAddedCnn then plrAddedCnn:Disconnect() end
                if plrRemovedCnn then plrRemovedCnn:Disconnect() end
            end
        end
    })
end

-- ! INITIALIZE WINDOW.
Window = Library:Create({ToggleKey = Enum.KeyCode.Insert})

initializeMiscTab()
initializeVisualsTab()
