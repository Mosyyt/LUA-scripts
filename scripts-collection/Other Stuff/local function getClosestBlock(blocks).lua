local function getClosestBlock(blocks)
    local closestBlock = nil
    local closestDistance = math.huge
    local playerPosition = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character.HumanoidRootPart.Position

    if not playerPosition then
        return nil
    end

    for _, block in pairs(blocks) do
        local distance = (playerPosition - block.Position).Magnitude
        if distance < closestDistance then
            closestBlock = block
            closestDistance = distance
        end
    end

    return closestBlock
end

local activeBlocks = workspace.__THINGS.__INSTANCE_CONTAINER.Active.Digsite.Important.ActiveBlocks:GetChildren()
local closestBlock = getClosestBlock(activeBlocks)

if closestBlock then
    local args = {
        [1] = "Digsite",
        [2] = "DigBlock",
        [3] = closestBlock:GetAttribute("Coord")
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Instancing_FireCustomFromClient"):FireServer(unpack(args))
end
