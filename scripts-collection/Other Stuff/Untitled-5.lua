game:GetService("Players").LocalPlayer.PlayerGui.Stats.ExpBar.WorkingTime
while task.wait() do
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("StartWorking"):FireServer()
    game:GetService("Players").LocalPlayer:WaitForChild("ServerEvent"):FireServer()
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CollectWork"):InvokeServer()
end

while task.wait() do
    game:GetService("Players").LocalPlayer.ServerEvent:FireServer()
end
game:GetService("Players").LocalPlayer.PlayerGui.Stats.ExpBar.WorkingTime

game:GetService("Players").LocalPlayer:WaitForChild("ServerEvent"):FireServer()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function fireRemoteEvent()
game:GetService("Players").LocalPlayer.PlayerGui.TapTapGameplay.TapServer.ServerEvent:FireServer()
end
while true do
    if LocalPlayer.PlayerGui.Stats.ExpBar.WorkingTime.Visible == true then
        fireRemoteEvent()
    else
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("StartWorking"):FireServer()
    end
    wait(.1) 
end

local ohString1 = "Skill"

game:GetService("ReplicatedStorage").Events.UpgradePlayer:InvokeServer(ohString1)