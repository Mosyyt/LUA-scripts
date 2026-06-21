local Players = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local character = lp.Character
local rps = game.ReplicatedStorage.Remotes

local UIS = game:GetService("UserInputService")
local Library = loadstring(game:HttpGet(
                               "https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua"))()
local Distance
local Distance2
local ShootingPower
local Goals
local previousGoal
local WalkSPEED
local JumpPOWER
function highlight(Goal)
    local Highlight = Instance.new("Highlight", Goal)
    Highlight.Enabled = true
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.FillColor = Color3.fromRGB(10, 10, 10)
    Highlight.OutlineColor = Color3.fromRGB(85, 105, 230)
    Highlight.FillTransparency = 0
    Highlight.OutlineTransparency = 0
end
-- Window
local Window = Library:Create({ToggleKey = Enum.KeyCode.Insert})

-- Tab
local Tab = Window:Tab({
    Name = "Striker Odyessy",
    Description = "Codexus Hub",
    Icon = "rbxassetid://11254763826", -- Tab Icon
    Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
    Hidden = false -- IGNORE THIS
})
-- Section
Tab:Section({Name = "~Functions~"})

Tab:Label({Text = "I advice going team 1 kinda keep in mind that is the Beta"})

Tab:Dropdown({
    Name = "Select Goal",
    Items = {"Gates1", "Gates2", 4}, -- Table
    Callback = function(item)
        Goals = item
        if previousGoal and previousGoal:FindFirstChild("Highlight") then
            previousGoal.Highlight:Destroy()
        end

        previousGoal = workspace.GameField:FindFirstChild(Goals)

        if previousGoal then highlight(previousGoal) end
    end
})

local AutoGoalsConnection

Tab:Toggle({
    Name = "Auto Goals",
    Default = false, -- Default Value
    Callback = function(enabled)
        if enabled then
            AutoGoalsConnection = rs.Heartbeat:Connect(function()
                if character then
                    local ball = character:FindFirstChild("Ball")
                    if ball then
                        local goal = workspace.GameField:FindFirstChild(Goals)
                        if goal and goal.Name == "Gates2" then
                            local goalPosition = goal.PrimaryPart.Position
                            character.PrimaryPart.CFrame = CFrame.new(
                                                               goalPosition) +
                                                               Vector3.new(50,
                                                                           8, 20)
                            character:SetPrimaryPartCFrame(CFrame.lookAt(
                                                               character.PrimaryPart
                                                                   .Position,
                                                               goalPosition))
                            lp.Character.Humanoid:ChangeState(11)
                            task.wait(.2)
                            rps.UseKeyboardSkillRemote:FireServer("PunchBall",
                                                                  ball, 4,
                                                                  ball.Ball
                                                                      .CFrame
                                                                      .LookVector,
                                                                  ball.Ball
                                                                      .CFrame
                                                                      .LookVector)
                        elseif goal and goal.Name == "Gates1" then
                            local goalPosition = goal.Hitbox.Position
                            character.PrimaryPart.CFrame = CFrame.new(
                                                               goalPosition) +
                                                               Vector3.new(50,
                                                                           3, 10)
                            character:SetPrimaryPartCFrame(CFrame.lookAt(
                                                               character.PrimaryPart
                                                                   .Position,
                                                               goalPosition))
                            lp.Character.Humanoid:ChangeState(11)
                            rps.UseKeyboardSkillRemote:FireServer("PunchBall",
                                                                  ball, 7,
                                                                  ball.Ball
                                                                      .CFrame
                                                                      .LookVector,
                                                                  ball.Ball
                                                                      .CFrame
                                                                      .LookVector)
                        end
                    end
                end
            end)
        else
            if AutoGoalsConnection then
                AutoGoalsConnection:Disconnect()
                AutoGoalsConnection = nil
            end
        end
    end
})

Tab:Button({
    Name = "Grab Ball",
    Callback = function()
        Retards1 = Players:GetPlayers()
        for i = 1, #Retards1 do
            local v1 = Retards1[i]
            if v1.Name ~= lp.Name and v1.Character:FindFirstChild("Ball") and
                lp:DistanceFromCharacter(v1.Character.PrimaryPart.Position) <
                700 and v1.Character.Humanoid.Health > 0 and
                v1.Character:FindFirstChild("HumanoidRootPart") then
                rps.UseKeyboardSkillRemote:FireServer("TackleBegin")
                rps.UseKeyboardSkillRemote:FireServer("Tackle",
                                                      v1.Character.Ball.Ball,
                                                      v1.Character.Ball.Ball
                                                          .CFrame)
                break
            end
        end
    end
})

Tab:Slider({
    Name = "Tackle Aura Distance",
    Min = 1, -- Min Val
    Max = 25, -- Max Val
    Default = 10, -- Default Val
    Callback = function(val) Distance = val end
})

Tab:Toggle({
    Name = "Tackle Aura",
    Default = false, -- Default Value
    Callback = function(state22)
        if state22 then
            TackleAura = rs.Heartbeat:Connect(function()
                if TackleAura then
                    Retards = Players:GetPlayers()
                    for i = 1, #Retards do
                        local v = Retards[i]
                        if v.Name ~= lp.Name and
                            v.Character:FindFirstChild("Ball") and
                            lp:DistanceFromCharacter(
                                v.Character.PrimaryPart.Position) < Distance and
                            v.Character.Humanoid.Health > 0 and
                            v.Character:FindFirstChild("HumanoidRootPart") then
                            rps.UseKeyboardSkillRemote:FireServer("TackleBegin")
                            rps.UseKeyboardSkillRemote:FireServer("Tackle",
                                                                  v.Character
                                                                      .Ball.Ball,
                                                                  v.Character
                                                                      .Ball.Ball
                                                                      .CFrame)
                        end
                    end
                end
            end)
            return
        end
        TackleAura:Disconnect()
    end
})
Tab:Slider({
    Name = "Take Ball Aura Distance",
    Min = 1, -- Min Val
    Max = 25, -- Max Val
    Default = 10, -- Default Val
    Callback = function(val1) Distance2 = val1 end
})

Tab:Toggle({
    Name = "Take Ball Aura",
    Default = false, -- Default Value
    Callback = function(state221)
        if state221 then
            TakeBallAura = rs.Heartbeat:Connect(function()
                if TackleAura then
                    Retards3 = Players:GetPlayers()
                    for i = 1, #Retards3 do
                        local v3 = Retards3[i]
                        if v3.Name ~= lp.Name and
                            v3.Character:FindFirstChild("Ball") and
                            lp:DistanceFromCharacter(
                                v3.Character.PrimaryPart.Position) < Distance2 and
                            v3.Character.Humanoid.Health > 0 and
                            v3.Character:FindFirstChild("HumanoidRootPart") then
                            rps.PunchRemote:FireServer("TakeBall",
                                                       v3.Character.Ball.Ball)
                        end
                    end
                end
            end)
            return
        end
        TakeBallAura:Disconnect()
    end
})
Tab:Slider({
    Name = "Shot Power",
    Min = 1, -- Min Val
    Max = 7, -- Max Val
    Default = 4, -- Default Val
    Callback = function(val31) ShootingPower = val31 end
})

local inputConnection -- Variable to store the event connection

Tab:Toggle({
    Name = "Modify Power",
    Default = false,
    Callback = function(bool)
        if bool then
            if not inputConnection then
                inputConnection = UIS.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and
                        lp.Character:FindFirstChild("Ball") then
                        rps.UseKeyboardSkillRemote:FireServer("PunchBall",
                                                              lp.Character:FindFirstChild(
                                                                  "Ball"),
                                                              ShootingPower,
                                                              lp.Character:FindFirstChild(
                                                                  "Ball").Ball
                                                                  .CFrame
                                                                  .LookVector,
                                                              lp.Character:FindFirstChild(
                                                                  "Ball").Ball
                                                                  .CFrame
                                                                  .LookVector)
                    end
                end)
            end
        else
            if inputConnection then
                inputConnection:Disconnect()
                inputConnection = nil
            end
        end
    end
})

local Tab2 = Window:Tab({
    Name = "Player",
    Description = "Player Tab",
    Icon = "rbxassetid://6031215978", -- Tab Icon
    Color = Color3.new(1, 0.968627, 0), -- Tab Colour
    Hidden = false -- IGNORE THIS
})

Tab2:Slider({
    Name = "Walkspeed",
    Min = 1, -- Min Val
    Max = 200, -- Max Val
    Default = 16, -- Default Val
    Callback = function(val312val312)
        WalkSPEED = val312val312
        character:FindFirstChildOfClass('Humanoid'):GetPropertyChangedSignal(
            "WalkSpeed"):Connect(function()
            character.Humanoid.WalkSpeed = WalkSPEED
        end)
        character.Humanoid.WalkSpeed = WalkSPEED
    end
})
Tab2:Slider({
    Name = "Jump Power",
    Min = 1, -- Min Val
    Max = 200, -- Max Val
    Default = 30, -- Default Val
    Callback = function(val312val3121)
        JumpPOWER = val312val3121
        character:FindFirstChildOfClass('Humanoid'):GetPropertyChangedSignal(
            "WalkSpeed"):Connect(function()
            character.Humanoid.JumpPower = JumpPOWER
        end)
        character.Humanoid.JumpPower = JumpPOWER
    end
})
-- Accessing settings tab
local SettingsTab = Window.SettingsTab
Window:Notify({
    Name = "Notification",
    Text = "Press Insert To Toggle GUI",
    Duration = 5,
    Callback = function() return end -- Callback when the notification ends
})
