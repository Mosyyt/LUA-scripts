-- #region Functions
local _ = ""
--- Gets the executor's Request function.
--- @return function Returns a client able to issue HttpRequest, which takes in an HttpRequest table as a parameter; UNC Spec -> https://github.com/unified-naming-convention/NamingStandard/blob/main/api/misc.md#request
function GetRequestFunction()
    return http_request or (syn and syn.request) or (http and http.request) or
               request
end

--- Gets the body of an HttpRequest using GetRequestFunction() as the HttpClient.
--- @return string A String that is the body of the HttpResponse
function GetRequestBodyFromUrl(urlLink)
    return GetRequestFunction()({Url = urlLink}).Body
end
--- @return boolean Returns a boolean that signifies if the script is obfuscated by either Luraph or 77Obfuscator
function IsScriptObfuscated() return (_77Crash or LPH_OBFUSCATED) end

--- Crashes the obfuscator's Lua bytecode interpreter, if it is obfuscated.
function CrashObfuscatorVM()
    if IsScriptObfuscated() then
        if LPH_OBFUSCATED then LPH_CRASH() end
        if _77Crash then _77Crash() end
    end
end

--- Should allow the player to noclip, doesn't work for some reason :headstone:
function Noclip()
    local lp = game:GetService("Players").LocalPlayer
    for i, v in pairs(lp.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide == true then
            v.CanCollide = false
        end
    end
end

function DisableNoClip()
    local lp = game:GetService("Players").LocalPlayer
    for i, v in pairs(lp.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide == false then
            v.CanCollide = true
        end
    end
end

function hopServers(wnd)
    print("Hopping servers...")
    task.spawn(function()
        wnd:Notify({
            Name = "Hopping servers...",
            Text = "The script is hopping servers! Please wait!",
            Duration = 5
        })
    end)
    local serverHop = (loadstring(GetRequestBodyFromUrl(
                                      "https://api.sussy.dev/v1/KeySystem/Assets/GetPublicFile?fileName=serverhop.lua")))();
    local queueTp = queueonteleport or queue_on_teleport

    if not queueTp then
        task.spawn(function()
            wnd:Notify({
                Name = "The script could not be 'prepared' for after the teleport!",
                Text = "Remember to reload it yourself!",
                Duration = 5
            })
        end)
    else
        queueTp(
            "function GetRequestFunction()return http_request or (syn and syn.request) or (http and http.request) or request end;function GetRequestBodyFromUrl(url) return GetRequestFunction()({Url = url}).Body end;loadstring(GetRequestBodyFromUrl(\"https://api.sussy.dev/v1/KeySystem/Assets/GetPublicFile?fileName=Codexus_Hub_loader.lua\"), true)()")
        task.wait(1)
    end

    task.spawn(function() serverHop:Teleport(game.PlaceId) end)
end

--- Yields the current thread until the next game Heartbeat.
function WaitNextHeartBeat() game:GetService("RunService").Heartbeat:Wait() end

function FreezeLocalPlayerCharacter()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local nofall = LocalPlayer.Character.HumanoidRootPart:FindFirstChild(
                       "FREEZED_CHAR")
    if nofall then return nofall end
    nofall =
        Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
    nofall.Name = "FREEZED_CHAR"
    nofall.Velocity = Vector3.new(0, 0, 0)
    return nofall
end

function UnfreezeLocalPlayerCharacter()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local nofallObj = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                          :FindFirstChild("FREEZED_CHAR")
    if not nofallObj then return false; end
    nofallObj:Destroy()
    return true
end

-- #endregion Functions

-- #region Validation Prelude
local _ = ""
-- Gets the first valid HttpRequest function.
function GetRequestFunction_Jaja()
    return http_request or syn.request or http.request or request
end

-- Gets the magic value the key system is attached to.
function _GetKeySystemMagicValue()
    return tostring(game.Players.LocalPlayer.UserId)
end

function KickPlayer(reason) game.Players.LocalPlayer:Kick(reason) end

function ValidateKey_(key)
    local executorRequest = GetRequestFunction_Jaja()

    -- All the APIs has been checked to see if they exists, use them with basically no fear!

    local response = executorRequest({
        Url = "https://api.sussy.dev/v1/KeySystem/Validatekey",
        Method = "GET",
        Headers = {
            ["X-KeySystem-Authorization"] = string.format("KeySystem %s", key)
        }
    })

    if response.StatusCode ~= 200 then return false end

    local responseAsJson = game:GetService("HttpService"):JSONDecode(
                               response.Body)

    local token = responseAsJson.Token
    local createdFor = responseAsJson.CreatedFor
    local magicValue = responseAsJson.MagicValue

    if token ~= key then return false end
    if magicValue ~= _GetKeySystemMagicValue() then return false end
    if createdFor ~= createdFor then return false end

    return true
end

function IsScriptObfuscated() return (LPH_OBFUSCATED or _77Crash) end
function CrashObfuscatorVM()
    if LPH_OBFUSCATED then LPH_CRASH() end
    if _77Crash then _77Crash() end
end
if IsScriptObfuscated() and
    (not _G.WHITEKEY or _G.WHITEKEY and not ValidateKey_(_G.WHITEKEY)) then
    KickPlayer("Are you seriously trying to steal our scripts? Shame on you!")
    CrashObfuscatorVM()
end

-- #endregion Validation Prelude

-- #region Service + Basic Variables Initialization
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = PlayerService.LocalPlayer
local LocalPlayerCharacter = LocalPlayer.Character
LocalPlayer.CharacterAdded:Connect(function(character)
    LocalPlayerCharacter = character
end)
local Characters = workspace.Mobs

local Library = (loadstring(GetRequestBodyFromUrl(
                                "https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua")))();
local Window = Library:Create({ToggleKey = Enum.KeyCode.Insert});

-- #endregion Service + Basic Variables Initialization 
--[[

local library = loadstring(game:HttpGet(
                               ("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3")))()
local w = library:CreateWindow("Muimi")
local Main = w:CreateFolder("Functions")
local mobs = {
    "Bandit", "Treeling", "Dwarf", "DwarfBoss", "Heavenly Martial Master"
}
local SelectedMob
local Distance
local CurrentMob

table.sort(mobs, function(a, b) return a < b end)

Main:Dropdown("Select Mob", mobs, true, function(mob) SelectedMob = mob end)

Main:Slider("Distance", {min = 1, max = 7, precise = false},
            function(DSSA) Distance = DSSA end)
local FarmSelected -- Weird shit it destroies the mod you will get brain fucked
Main:Toggle("Farm Mob", function(state)
    if state then
        FarmSelected = RunService.Heartbeat:connect(function()
            if not CurrentMob or not CurrentMob:FindFirstChild("Humanoid") or
                not CurrentMob:FindFirstChild("HumanoidRootPart") then
                CurrentMob = nil
                Mobs = Characters:GetChildren()
                for i = 1, #Mobs do
                    local v = Mobs[i]
                    if string.find(v.Name, SelectedMob) and v.Humanoid.Health >
                        0 and v:FindFirstChild("HumanoidRootPart") then -- is that you dottik?
                        CurrentMob = v
                        break
                    end
                end
            end

            if CurrentMob then
                LocalPlayerCharacter.HumanoidRootPart.CFrame =
                    CurrentMob.HumanoidRootPart.CFrame *
                        CFrame.Angles(math.rad(90), 0, 0) +
                        Vector3.new(0, -Distance, 0)
            end
        end)
        return
    end
    FarmSelected:Disconnect()
end)
]]

function initAutos(window)
    local SimpleAutosTab = window:Tab({
        Name = "Simple Automatics",
        Description = "Autos Tab",
        Icon = "rbxassetid://6031215978", -- Tab Icon
        Color = Color3.new(1, 0.968627, 0), -- Tab Colour
        Hidden = false -- IGNORE THIS
    })
    --- @type boolean
    local signalStop = false
    --- @type thread | nil
    local farmMapThread = nil
    SimpleAutosTab:Toggle({
        Name = "Farm all Map Items (Loose)",
        Default = false,
        Callback = function(state)
            if not state then signalStop = true end

            if state then
                signalStop = false
                farmMapThread = task.spawn(function()
                    --- Returns all the usable interactives in the map, only their proximity prompts!
                    --- @return table proximityPromptArray An array of type ProximityPrompt
                    local function GetAllUsableInteractibles()
                        local collectableInteractiblesFolder =
                            workspace.Interactables.Trinklet

                        local tableFinal = {}
                        --- @type Instance
                        for _, v in ipairs(
                                        collectableInteractiblesFolder:GetDescendants()) do
                            if v.ClassName == "ProximityPrompt" then
                                -- A target, add to secondary table.
                                table.insert(tableFinal, v)
                            end
                        end
                        return tableFinal
                    end

                    local originalCFrame =
                        LocalPlayerCharacter.HumanoidRootPart.CFrame
                    local farmTargets = GetAllUsableInteractibles()
                    print("Farming " .. #farmTargets ..
                              " valid items on the map, this will take approximately " ..
                              math.round(0.2 * 2 * #farmTargets) ..
                              " seconds to complete!")
                    FreezeLocalPlayerCharacter()
                    --- @type ProximityPrompt
                    for i, prompt in farmTargets do
                        if signalStop then break end
                        -- Get the PrimaryPart/First Ancestor that IS a part.
                        if prompt.Parent and prompt.Parent.ClassName == "Part" or
                            prompt:FindFirstAncestorWhichIsA("Part") then
                            local origin = prompt.Parent or
                                               prompt:FindFirstAncestorOfClass(
                                                   "Part")

                            local newPlayerPos =
                                CFrame.new(origin.CFrame.Position +
                                               Vector3.new(0, -5, 0),
                                           origin.CFrame.Position)

                            LocalPlayerCharacter.HumanoidRootPart.CFrame =
                                newPlayerPos
                            task.wait(.2)
                            fireproximityprompt(prompt)
                            task.wait(.2)
                            print("Grabbed item " .. i .. "/" .. #farmTargets)
                        end
                    end
                    print("Finalized")
                    LocalPlayerCharacter.HumanoidRootPart.CFrame =
                        originalCFrame
                    UnfreezeLocalPlayerCharacter()

                end)
            end
        end
    })

    --- @type boolean
    local signalStopWheat = false
    --- @type thread | nil
    local farmWheatThread = nil
    SimpleAutosTab:Toggle({
        Name = "Farm Wheat (Loose)",
        Default = false,
        Callback = function(state)
            if not state then signalStopWheat = true end

            if state then
                signalStopWheat = false
                farmWheatThread = task.spawn(function()
                    --- Returns all the usable interactives in the map, only their proximity prompts!
                    --- @return table proximityPromptArray An array of type ProximityPrompt
                    local function GetAllUsableInteractibles()
                        local collectableInteractiblesFolder =
                            workspace.Interactables.Wheat

                        local tableFinal = {}
                        --- @type Instance
                        for _, v in ipairs(
                                        collectableInteractiblesFolder:GetDescendants()) do
                            if v.ClassName == "ProximityPrompt" then
                                -- A target, add to secondary table.
                                table.insert(tableFinal, v)
                            end
                        end
                        return tableFinal
                    end

                    local originalCFrame =
                        LocalPlayerCharacter.HumanoidRootPart.CFrame
                    local farmTargets = GetAllUsableInteractibles()
                    print("Farming " .. #farmTargets ..
                              " wheat on the map, this will take approximately " ..
                              math.round(0.4 * 2 * #farmTargets) ..
                              " seconds to complete!")
                    FreezeLocalPlayerCharacter()
                    --- @type ProximityPrompt
                    for i, prompt in farmTargets do
                        if signalStopWheat then break end
                        -- Get the PrimaryPart/First Ancestor that IS a part.
                        if prompt.Parent and prompt.Parent.ClassName ==
                            "UnionOperation" or
                            prompt:FindFirstAncestorWhichIsA("UnionOperation") then
                            local origin = prompt.Parent or
                                               prompt:FindFirstAncestorOfClass(
                                                   "UnionOperation")

                            local newPlayerPos =
                                CFrame.new(origin.CFrame.Position +
                                               Vector3.new(0, -5, 0),
                                           origin.CFrame.Position)

                            LocalPlayerCharacter.HumanoidRootPart.CFrame =
                                newPlayerPos
                            task.wait(0.4)
                            fireproximityprompt(prompt)
                            task.wait(0.4)
                            print("Farmed Wheat " .. i .. "/" .. #farmTargets)
                        end
                    end
                    print("Finalized")
                    LocalPlayerCharacter.HumanoidRootPart.CFrame =
                        originalCFrame
                    UnfreezeLocalPlayerCharacter()

                end)
            end
        end
    })

    --- @type thread | nil
    local autoDropThread = nil
    SimpleAutosTab:Toggle({
        Name = "Drop all Wheat (Backpack)",
        Default = false,
        Callback = function(state)
            if autoDropThread then
                task.cancel(autoDropThread);
                autoDropThread = nil
            end

            if state then
                autoDropThread = task.spawn(function()
                    local stopProcedure = false
                    while not stopProcedure do
                        local wheatOnBackpack =
                            LocalPlayer.Backpack:FindFirstChild("Wheat")

                        if wheatOnBackpack then
                            local backpackItems =
                                LocalPlayer.Backpack:GetChildren()
                            for _, item in ipairs(backpackItems) do
                                if item.Name == "Wheat" then
                                    if not LocalPlayerCharacter then
                                        LocalPlayerCharacter =
                                            LocalPlayer.CharacterAdded:Wait()
                                    end
                                    item.Parent = LocalPlayerCharacter
                                    ReplicatedStorage.Remotes.Misc.DropTool:FireServer()
                                    task.wait(0.1)
                                end
                            end
                        else
                            stopProcedure = true
                        end
                    end
                end)
            end
        end
    })
end

function initPlayer(window)
    local PlayerTab = window:Tab({
        Name = "Player",
        Description = "Player Tab",
        Icon = "rbxassetid://6031215978", -- Tab Icon
        Color = Color3.new(1, 0.968627, 0), -- Tab Colour
        Hidden = false -- IGNORE THIS
    })

    local infjumpenabled = false;
    PlayerTab:Button({
        Name = "Reset Character",
        Callback = function() LocalPlayerCharacter.Humanoid.Health = 0; end
    });

    --- @type RBXScriptConnection | nil
    local noclipConnection = nil
    PlayerTab:Toggle({
        Name = "Noclip",
        Default = false,
        Callback = function(enableNoClip)
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end

            if enableNoClip then
                noclipConnection =
                    game:GetService("RunService").Stepped:Connect(function()
                        Noclip()
                    end)
            end
        end
    });

    local infiniteJumpConnection = nil
    PlayerTab:Toggle({
        Name = "Infinite Jump",
        Default = false,
        Callback = function(enableInfiniteJump)
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
            end
            if enableInfiniteJump then
                infiniteJumpConnection =
                    UserInputService.JumpRequest:Connect(function()
                        if LocalPlayerCharacter and
                            LocalPlayerCharacter:FindFirstChild("Humanoid") then -- First humanoid found; hijack the second humanoid.
                            LocalPlayerCharacter.Humanoid:ChangeState(
                                Enum.HumanoidStateType.Jumping)
                        else
                            window:Notify({
                                Name = "No player found!",
                                Text = "The script has lost its reference to the player, please try again in a bit!",
                                Duration = 5,
                                Callback = function()
                                    LocalPlayerCharacter = LocalPlayer.Character
                                end -- Callback when the notification ends <Not required in this case!>
                            })
                        end
                    end)
            end
        end
    })

    local jumpHeightSteppedConnection = nil
    local enableHackedJumpHeight = false
    PlayerTab:Toggle({
        Name = "Enable Hacked Jump Height",
        Default = false,
        Callback = function(enableHackedJh)
            enableHackedJumpHeight = enableHackedJh

            if not enableHackedJumpHeight and jumpHeightSteppedConnection then
                jumpHeightSteppedConnection:Disconnect()
            end
        end
    })

    PlayerTab:Slider({
        Name = "Jump Height",
        Default = LocalPlayerCharacter.Humanoid.JumpHeight,
        Min = 16,
        Max = 300,
        Callback = function(newJumpPower)
            if jumpHeightSteppedConnection then
                jumpHeightSteppedConnection:Disconnect()
            end
            if enableHackedJumpHeight then
                jumpHeightSteppedConnection =
                    RunService.Stepped:Connect(function()
                        pcall(function()
                            if LocalPlayerCharacter and
                                LocalPlayerCharacter.Humanoid then
                                LocalPlayerCharacter.Humanoid.JumpHeight =
                                    newJumpPower
                            end
                        end)
                    end)
            end
        end
    })
    local walkspeedSteppedConnection = nil
    local enableHackedWalkspeed = false
    PlayerTab:Toggle({
        Name = "Enable Hacked Walkspeed",
        Default = false,
        Callback = function(enableHackedWs)
            enableHackedWalkspeed = enableHackedWs
            if not enableHackedWalkspeed and walkspeedSteppedConnection then
                walkspeedSteppedConnection:Disconnect()
            end
        end
    })

    PlayerTab:Slider({
        Name = "Walk Speed",
        Default = LocalPlayerCharacter.Humanoid.WalkSpeed,
        Min = 16,
        Max = 300,
        Callback = function(newWalkspeed)
            if walkspeedSteppedConnection then
                walkspeedSteppedConnection:Disconnect()
            end
            if enableHackedWalkspeed then
                walkspeedSteppedConnection =
                    RunService.Stepped:Connect(function()
                        pcall(function()
                            if LocalPlayerCharacter and
                                LocalPlayerCharacter.Humanoid then
                                LocalPlayerCharacter.Humanoid.WalkSpeed =
                                    newWalkspeed
                            end
                        end)
                    end)
            end
        end
    })

    local idleConnection = nil
    PlayerTab:Toggle({
        Name = "Anti AFK",
        Default = false,
        Callback = function(antiAfkState)
            if idleConnection then
                idleConnection:Disconnect()
                idleConnection = nil
            end

            if antiAfkState then
                local VirtualUser = game:GetService("VirtualUser")

                idleConnection = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    task.spawn(function()
                        window:Notify({
                            Name = "Anti AFK Triggered!",
                            Text = "Roblox attempted to kick you, but the anti afk prevented it :)"
                        })
                    end)
                end)
            end
        end
    })
end

initAutos(Window)
initPlayer(Window)
