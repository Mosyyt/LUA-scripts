local Players = game.Players
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/H3XDaemon/IreXion-UI-Library/main/IreXion%20UI%20Library"))()
local SelectedTeam
local Gui = Library:AddGui({
	Title = {"Super League Soccer", "BeboMods"},
	ThemeColor = Color3.fromRGB(255, 255, 255),
	ToggleKey = Enum.KeyCode.Insert,
})
local Tab = Gui:AddTab("Functions")

local Category = Tab:AddCategory("~Main Function~")
local AutoTackleConnection
local AutoGrabLooseBallConnection
local AutoDribbleConnection
local AutoScoreConnection
local InfStaminaConnection
local AutoGoalKeepConnection
local function InfStamina()
    lp.Character:GetAttributeChangedSignal("Stamina"):Connect(function()
        lp.Character:SetAttribute("Stamina", 9999)
    end)
end
Category:AddDropdown("Select Opposite Team", {"Away Team", "Home Team"}, function(name)
	SelectedTeam = name
end)
Category:AddToggle(
    "Auto Score",
    false,
    function(state25)
        if state25 then
            AutoScoreConnection = rs.Heartbeat:connect(
                function()
                    for _,v in pairs(game:GetService("Workspace"):GetChildren()) do
                        if v.Name == "Gameball"  and not lp.Character:FindFirstChild("Gameball") then
                          firetouchinterest(workspace.Map[SelectedTeam]["Goal (Scaled)"].Goal, v, 0)
                          firetouchinterest(workspace.Map[SelectedTeam]["Goal (Scaled)"].Goal, v, 1)
                          game:GetService("ReplicatedStorage").RemoteEvents.Football.Shoot:FireServer()
                        end
                    end
                end
            )
        else
            if AutoScoreConnection then
                AutoScoreConnection:Disconnect()
                AutoScoreConnection = nil
            end
        end
    end
)
Category:AddToggle(
    "Auto Tackle",
    false,
    function(state)
        if state then
            AutoTackleConnection = rs.Heartbeat:connect(
                function()
                    game:GetService("ReplicatedStorage").RemoteEvents.Football.Tackle:FireServer()
                    game:GetService("ReplicatedStorage").RemoteEvents.Football.Tackle:FireServer()
                    game:GetService("ReplicatedStorage").RemoteEvents.Football.Tackle:FireServer()
                end
            )
        else
            if AutoTackleConnection then
                AutoTackleConnection:Disconnect()
                AutoTackleConnection = nil
            end
        end
    end
)

Category:AddToggle(
    "Grab Loose Ball",
    false,
    function(state1)
        if state1 then
            AutoGrabLooseBallConnection = rs.Heartbeat:connect(
                function()
                    for _,v in pairs(game:GetService("Workspace"):GetChildren()) do
                        if v.Name == "Gameball"  then
                          firetouchinterest(game.Players.LocalPlayer.Character.PrimaryPart, v, 0)
                          firetouchinterest(game.Players.LocalPlayer.Character.PrimaryPart, v, 1)
                        end
                    end
                end
            )
        else
            if AutoGrabLooseBallConnection then
                AutoGrabLooseBallConnection:Disconnect()
                AutoGrabLooseBallConnection = nil
            end
        end
    end
)
local Bind = Category:AddBind("Grab Ball", Enum.KeyCode.F, function()
	print("Toggled GUI")
    for _,v in pairs(game:GetService("Workspace"):GetChildren()) do
        if v.Name == "Gameball"  then
          firetouchinterest(game.Players.LocalPlayer.Character.PrimaryPart, v, 0)
          firetouchinterest(game.Players.LocalPlayer.Character.PrimaryPart, v, 1)
        end
    end
end)

Category:AddToggle(
    "Auto Dribble",
    false,
    function(state2)
        if state2 then
            AutoDribbleConnection = rs.Heartbeat:connect(
                function()
                    game:GetService("ReplicatedStorage").RemoteEvents.Football.Dribble:FireServer()
                    game:GetService("ReplicatedStorage").RemoteEvents.Football.Dribble:FireServer()
                end
            )
        else
            if AutoDribbleConnection then
                AutoDribbleConnection:Disconnect()
                AutoDribbleConnection = nil
            end
        end
    end
)


Category:AddToggle(
    "Inf Stamina",
    false,
    function(state23)
        if state23 then
            InfStaminaConnection = rs.Heartbeat:connect(
                function()
                    InfStamina()
                end
            )
        else
            if InfStaminaConnection then
                InfStaminaConnection:Disconnect()
                InfStaminaConnection = nil
            end
        end
    end
)
Category:AddToggle(
    "Auto Goal Keep",
    false,
    function(state2544)
        if state2544 then
            AutoGoalKeepConnection = rs.Heartbeat:connect(
                function()
                    for _,v in pairs(game:GetService("Workspace"):GetChildren()) do
                        if v.Name == "Gameball" and game.Players.LocalPlayer:DistanceFromCharacter(v.Position) < 50  then
                          firetouchinterest(game.Players.LocalPlayer.Character.PrimaryPart, v, 0)
                          firetouchinterest(game.Players.LocalPlayer.Character.PrimaryPart, v, 1)
                        end
                    end
                end
            )
        else
            if AutoGoalKeepConnection then
                AutoGoalKeepConnection:Disconnect()
                AutoGoalKeepConnection = nil
            end
        end
    end
)