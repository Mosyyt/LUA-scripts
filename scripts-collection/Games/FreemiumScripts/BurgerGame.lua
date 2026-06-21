-- ! DECLARE UTILITIES
function ToggleLightSwitch()
    local args_ = {
        [1] = "CanGrab",
        [2] = workspace.GameData.Objects.LightswitchDiner,
        [3] = false
    }

    game:GetService("ReplicatedStorage").Remotes.Ask:InvokeServer(unpack(args_))
    IsLightSwitchEnabled = not IsLightSwitchEnabled
end
-- ! ANTI-TAMPERING/KEY SYSTEM CHECK
-- ! WHITELIST_KEY IS SET BY THE LOADER, IF UNSET, KICK!
if getfenv().WHITELIST_KEY == nil then
    game.Players.LocalPlayer:Kick("You are not allowed to use this script.")
end

-- ! LOAD GUI

-- ! INITIALIZE LIBRARY
Library = loadstring(game:HttpGet(
                         "https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))()

-- State Variables (Lol)
IsLightSwitchEnabled = false

-- ! INITIALIZATION FUNCTIONS

-- ! Initialize the Orders Tab.
function initializeOrdersTab()
    local Tab = Window:Tab({
        Name = "Orders",
        Description = "Order ingredients when away of the ordering menu",
        Icon = "rbxassetid://13260102569"
    })

    task.spawn(function() -- This locks the thread.
        Window:Notify({
            Title = "NOTE: Default Keybinds:",
            Text = "V for 3rd person, DEL minimize.",
            Duration = 10
        })
    end)

    local function createButton(name)
        Tab:Button({
            Name = "Order " .. name,
            Description = "Orders " .. name,
            Callback = function()
                local args = {[1] = "Order", [2] = name}
                game:GetService("ReplicatedStorage").Remotes.Tell:FireServer(
                    unpack(args))
            end
        })
    end

    createButton("Bread")
    createButton("Fries")
    createButton("Veggies")
    createButton("Cups")
    createButton("Trays")
    createButton("Meat")

    -- Toggle Front Diner Light
    Tab:Button{
        Name = "Toggle Front Diner Light",
        Description = "(May not work if your far away from the switch)",
        Callback = function() ToggleLightSwitch() end
    }
end

function initializeAutosTab()
    local Tab = Window:Tab({
        Name = "Automatics",
        Icon = "rbxassetid://6034996695",
        Description = "Automatics, such as Auto-Delivery and such."
    })

    local toggleLightSwitchOnNightTimeEnabled = false
    local function ToggleLightOnNightTime()
        -- Implement detection for when the light is on or off.
        local toggledThisNight = false
        local toggledThisDay = false
        while true do
            if toggleLightSwitchOnNightTimeEnabled then return end
            wait(1)

            if toggledThisDay == false and
                game:GetService("Workspace").GameData.Open.Value == true then
                ToggleLightSwitch()
                toggledThisNight = false
                toggledThisDay = true
            end

            if toggledThisNight == false and
                game:GetService("Workspace").GameData.Open.Value == false then
                ToggleLightSwitch()
                toggledThisNight = true
                toggledThisDay = false
            end
        end
    end

    numBeforeOrder = 3

    -- Enable Order When Under AMOUNT_HERE

    Tab:Toggle({
        Name = "Toggle front diner light when closed",
        Default = false,
        Description = "Toggles the front diner light when the diner is closed",
        Callback = function(state)
            if state then
                toggleLightSwitchOnNightTimeEnabled = false
                ToggleLightOnNightTime()
            else
                toggleLightSwitchOnNightTimeEnabled = true
            end
        end
    })

    local BUYAMOUNTCONNECTION = nil
    local boxes = {
        {
            Object = workspace.GameData.Objects.BoxFriCon,
            Args = {[1] = "Order", [2] = "Cups"}
        }, {
            Object = workspace.GameData.Objects.Boxreal,
            Args = {[1] = "Order", [2] = "Cups"}
        }, {
            Object = workspace.GameData.Objects.Boxtray,
            Args = {[1] = "Order", [2] = "Trays"}
        }, {
            Object = workspace.GameData.Objects.Boxbbun,
            Args = {[1] = "Order", [2] = "Bread"}
        }, {
            Object = workspace.GameData.Objects.Boxtbun,
            Args = {[1] = "Order", [2] = "Bread"}
        }, {
            Object = workspace.GameData.Objects.Boxbrgr,
            Args = {[1] = "Order", [2] = "Meat"}
        }, {
            Object = workspace.GameData.Objects.Boxbac,
            Args = {[1] = "Order", [2] = "Meat"}
        }, {
            Object = workspace.GameData.Objects.Boxfri,
            Args = {[1] = "Order", [2] = "Fries"}
        }, {
            Object = workspace.GameData.Objects.Boxtom,
            Args = {[1] = "Order", [2] = "Veggies"}
        }, {
            Object = workspace.GameData.Objects.Boxchz,
            Args = {[1] = "Order", [2] = "Veggies"}
        }, {
            Object = workspace.GameData.Objects.Boxpcl,
            Args = {[1] = "Order", [2] = "Veggies"}
        }, {
            Object = workspace.GameData.Objects.Boxoni,
            Args = {[1] = "Order", [2] = "Veggies"}
        }, {
            Object = workspace.GameData.Objects.Boxltc,
            Args = {[1] = "Order", [2] = "Veggies"}
        }
    }
    -- Enable Order When Under AMOUNT_HERE
    Tab:Toggle({
        Name = "Order When Under _",
        Default = false,
        Description = "Orders any ingredient when it has less than the selected amount",
        Callback = function(state)
            if state then
                local replicatedStorageService = game:GetService(
                                                     "ReplicatedStorage")
                BUYAMOUNTCONNECTION =
                    game:GetService("RunService").Heartbeat:Connect(function()
                        for _, box in ipairs(boxes) do
                            if box.Object.Amount.Value < numBeforeOrder then
                                replicatedStorageService.Remotes.Tell:FireServer(
                                    unpack(box.Args))
                            end
                        end
                    end)
            else
                BUYAMOUNTCONNECTION:Disconnect()
            end
        end
    })

    -- Order When Under (Select Amount)
    Tab:Textbox({
        Name = "Order When Under...",
        Default = 3,
        Callback = function(text)
            local num = tonumber(text)
            if (num == nil) then
                Window:Notify({
                    Title = "This is just for numbers!",
                    Text = "The prompt you just edited only supports numbers for obvious reasons!",
                    Duration = 5
                })
            else
                numBeforeOrder = num
            end
        end
    })
end

-- Window
-- ! INITIALIZE WINDOW.
Window = Library:Create({ToggleKey = Enum.KeyCode.RightShift})

initializeOrdersTab()
initializeAutosTab()
