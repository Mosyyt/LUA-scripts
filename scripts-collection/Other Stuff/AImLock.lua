local LPlayer = game:GetService("Players").LocalPlayer
local LMouse = LPlayer:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera
local fovAmount = 120
local teamCheck = false

local fovCircle = Drawing.new("Circle")
fovCircle.Radius = fovAmount
fovCircle.Visible = true
fovCircle.Color = Color3.fromRGB(247, 126, 192)
fovCircle.Thickness = 1
fovCircle.NumSides = 11
fovCircle.Position = Vector2.new(0, 0)

local function UpdateFovCircle()
    local mousePos = Camera.WorldToViewportPoint(Camera, LMouse.Hit.Position)
    fovCircle.Radius = fovAmount
    fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
end

local function IsInFov(position)
    local mousePos = Vector2.new(LMouse.X, LMouse.Y)
    local screenPosition, isVisible = Camera:WorldToViewportPoint(position)
    local distanceToMouse = (mousePos - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude
    return isVisible and distanceToMouse <= fovAmount
end

local function GetClosestPlayer()
    local ClosestDistance, ClosestPlayer = math.huge, nil

    for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
        if Player ~= LPlayer and (not teamCheck or Player.Team ~= LPlayer.Team) then -- Add team check condition
            local Character = Player.Character
            if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    local distanceToCamera = (Camera.CFrame.Position - HumanoidRootPart.Position).Magnitude
                    if distanceToCamera <= 30 then
                        ClosestPlayer = Player
                        ClosestDistance = 0 -- set to 0 to ensure this player is chosen immediately
                        break -- no need to continue searching
                    elseif IsInFov(HumanoidRootPart.Position) then
                        local screenPosition, isVisible = Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                        if isVisible then
                            local distanceToMouse = (LMouse.X - screenPosition.X) ^ 2
                                + (LMouse.Y - screenPosition.Y) ^ 2
                            if distanceToMouse < ClosestDistance then
                                ClosestPlayer = Player
                                ClosestDistance = distanceToMouse
                            end
                        end
                    end
                end
            end
        end
    end

    return ClosestPlayer
end



local function LockCameraOnClosestPlayer()
    local target = GetClosestPlayer()
    if target then
        local targetCharacter = target.Character
        if targetCharacter then
            local targetHumanoidRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
            local targetHead = targetCharacter:FindFirstChild("Head")
            if targetHumanoidRootPart then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            end
        end
    end
end

local isCameraLockEnabled = false

local function ToggleCameraLock()
    isCameraLockEnabled = not isCameraLockEnabled
end

-- Keybind toggle to turn camera locking on and off
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        ToggleCameraLock()
    end
end)

-- Connect the camera locking function to the RenderStepped event
game:GetService("RunService").RenderStepped:Connect(function()
    if isCameraLockEnabled then
        LockCameraOnClosestPlayer()
    end
    UpdateFovCircle()
end)


hookfunction(print,warn)