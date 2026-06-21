local LPlayer = game:GetService("Players").LocalPlayer
local rs = game:GetService("RunService")

local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()
local w = library:CreateWindow("A") 
local b = w:CreateFolder("B") 

local AutoWorkConnection
local AutoSkillConnection
local AutoTaxConnection

b:Toggle(
    "Auto Work",
    function(state22)
        if state22 then
            AutoWorkConnection =
                rs.Heartbeat:Connect(
                function()
                    if LPlayer.PlayerGui.Stats.ExpBar.WorkingTime.Visible == true then
                        LPlayer.PlayerGui.TapTapGameplay.TapServer.ServerEvent:FireServer()
                    else
                        game:GetService("ReplicatedStorage").Events.StartWorking:FireServer()
                    end
                end
            )
            return
        end
        AutoWorkConnection:Disconnect()
    end
)

local UpgradesTable = {}
for i,v in pairs(LPlayer.PlayerUpgrades:GetChildren()) do 
    table.insert(UpgradesTable, v.Name)
end

local selectedSkill = nil
b:Dropdown("Dropdown",UpgradesTable,true,function(Skill)
    selectedSkill = Skill
end)

b:Toggle(
    "Auto Upgrade",
    function(state2)
        if state2 then
            AutoSkillConnection =
                rs.Heartbeat:Connect(
                function()
                    game:GetService("ReplicatedStorage").Events.UpgradePlayer:InvokeServer(selectedSkill)
                    task.wait(1)
                end
            )
            return
        end
        AutoSkillConnection:Disconnect()
    end
)
b:Toggle(
    "Auto Tax",
    function(state23)
        if state23 then
            AutoTaxConnection =
                rs.Heartbeat:Connect(
                function()

                end
            )
            return
        end
        AutoTaxConnection:Disconnect()
    end
)
