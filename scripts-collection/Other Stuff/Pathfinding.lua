local Speed = 100
local Distance = 3

local player = game.Players.LocalPlayer

local pathService = game:GetService("PathfindingService")

local wayPFolder = Instance.new("Folder")
wayPFolder.Parent = workspace
wayPFolder.Name = "WayPoints"

game:GetService("RunService").RenderStepped:Connect(
    function()
        if Enabled then
            player.Character.Humanoid:ChangeState(11)
        end
    end
)

function tweenTP(target)
    local success, targetCFrame =
        pcall(
        function()
            return target.CFrame
        end
    )
    target = success and targetCFrame or target
    game:GetService("TweenService"):Create(
        player.Character.HumanoidRootPart,
        TweenInfo.new(player:DistanceFromCharacter(target.Position) / Speed, Enum.EasingStyle.Linear),
        {CFrame = target * CFrame.new(0, 0, Distance)}
    ):Play()
    wait(player:DistanceFromCharacter(target.Position) / Speed)
end

function TP(tar)
    local original, tar = tar, tar.Position
    if player:DistanceFromCharacter(tar) < 45 then
        pcall(
            function()
                player.Character.HumanoidRootPart.CFrame = original.CFrame * CFrame.new(0, 0, Distance)
            end
        )
        return true
    end
    local path =
        pathService:CreatePath({AgentRadius = 2, AgentHeight = 4, AgentWalkableClimb = math.huge, AgentCanJump = true})
    path:ComputeAsync(player.Character.HumanoidRootPart.Position, tar)
    if path.Status == Enum.PathStatus.Success then
        local wayP = path:GetWaypoints()
        for i, v in pairs(wayP) do
            local WaypointPART = Instance.new("Part")
            WaypointPART.Shape = "Ball"
            WaypointPART.Material = "Neon"
            WaypointPART.Size = Vector3.new(0.6, 0.6, 0.6)
            WaypointPART.Position = v.Position
            WaypointPART.Anchored = true
            WaypointPART.CanCollide = false
            WaypointPART.Parent = wayPFolder
            WaypointPART.Name = tostring(v)
        end
        for i, WaypointPART in pairs(wayP) do
            player.Character.HumanoidRootPart.CFrame = CFrame.new(WaypointPART.Position) + Vector3.new(0, 2, 0)
            wait()
            wayPFolder[tostring(WaypointPART)]:Destroy()
        end
        return true
    else
        tweenTP(original)
        return true
    end
    return false
end
for i, v in pairs(workspace.GangArea:GetChildren()) do
    if v.Name == "Door" then
        v:Destroy()
    end
end

workspace.GangArea.ChildAdded:Connect(
    function(child)
        if child.Name == "Door" then
            child:Destroy()
        end
    end
)

local vault = workspace.GangArea.Vault
TP(vault)
