
local playerRestraunt =
    workspace.OwnedRestaurants[game.Players.LocalPlayer.Name]

-- Helper function to get ingredient by name using player data
local function getIngredient(ingredientName)
    for i, v in pairs(game:GetService('Players').LocalPlayer.Data.Foods:GetChildren()) do
        if v.Item.Value == ingredientName then
            for x, y in pairs(playerRestraunt.Ingredients:GetChildren()) do
                if v.Name == y.Name then
                    local remote =
                        game:GetService('ReplicatedStorage').Remotes.Gameplay.TakeIngredient
                    local arguments = { [1] = y }
                    remote:FireServer(unpack(arguments))
                    return true
                end
            end
        end
    end
    return false
end


-- Updated functions using the new system
local function takePatty()
    return getIngredient('Raw Patty')
end

local function getPaper()
    return getIngredient('Paper')
end

local function getBun()
    return getIngredient('Burger Buns') -- Adjust name if needed
end

-- Helper function to get items from trash
local function getFromTrash(lookfor)
    for i, v in pairs(playerRestraunt.Trash:GetChildren()) do
        if v.Name == lookfor then
            return v
        end
    end
end

local function snapOnCook()
    for i, v in pairs(playerRestraunt.Furniture.Cooktop.Cooktop:GetChildren()) do
        if v:IsA('Part') then
            local rawPatty = v:FindFirstChild('Raw Patty')
            if rawPatty and not rawPatty:GetAttribute('Occupied') then
                local remote =
                    game:GetService('ReplicatedStorage').Remotes.Gameplay.SnapIngredient
                local arguments = {
                    [1] = getFromTrash('Raw Patty'),
                    [2] = v,
                }
                remote:FireServer(unpack(arguments))
                print('✅ Snapped patty on cooktop!')
                break
            end
        end
    end
end

local function sanpBunOnPaper()
    local bun = getFromTrash('Burger Bun')
    local paper = getFromTrash('Paper')

    if bun and paper and paper.Part then
        local remote =
            game:GetService('ReplicatedStorage').Remotes.Gameplay.SnapIngredient
        local arguments = {
            [1] = bun,
            [2] = paper.Part,
        }
        remote:FireServer(unpack(arguments))
        print('✅ Snapped bun on paper!')
    else
        print('❌ Missing bun or paper in trash!')
    end
end

local function snapPattyOnAllValidBurgers()
    local cookedPatty = getFromTrash('Cooked Patty')
    if not cookedPatty then
        print('❌ No cooked patty found in trash!')
        return
    end

    local burgerCount = 0
    for _, item in pairs(playerRestraunt.Trash:GetChildren()) do
        if item.Name == 'Burger' then
            local ingredients = item:FindFirstChild('Ingredients')
            if ingredients then
                local hasBun, hasPatty = false, false
                for _, ingredient in pairs(ingredients:GetChildren()) do
                    if ingredient.Name == 'Burger Bun' then
                        hasBun = true
                    elseif ingredient.Name == 'Cooked Patty' then
                        hasPatty = true
                    end
                end

                if hasBun and not hasPatty then
                    game
                        :GetService('ReplicatedStorage').Remotes.Gameplay.SnapIngredient
                        :FireServer(cookedPatty, item.Part)
                    burgerCount = burgerCount + 1
                    print('✅ Added patty to burger!')
                    break
                end
            end
        end
    end

    if burgerCount == 0 then
        print('❌ No valid burgers found to add patty!')
    end
end

local function wrapFinishedBurgers()
    local wrappedCount = 0
    for _, burger in pairs(playerRestraunt.Trash:GetChildren()) do
        if burger.Name == 'Burger' then
            local cookedPatty = burger.Part
                and burger.Part:FindFirstChild('Cooked Patty')
            if cookedPatty then
                local finished = cookedPatty:FindFirstChild('Finished')
                local wrap = cookedPatty:FindFirstChild('Wrap')

                if finished and finished.Value == true and wrap then
                    wrap:FireServer()
                    wrappedCount = wrappedCount + 1
                    print('✅ Wrapped finished burger!')
                end
            end
        end
    end

    if wrappedCount == 0 then
        print('❌ No finished burgers found to wrap!')
    else
        print('🎉 Wrapped ' .. wrappedCount .. ' burgers total!')
    end
end
local playerRestraunt =
    workspace.OwnedRestaurants[game.Players.LocalPlayer.Name]

local function autoFlipBurgers()
    for i, v in pairs(playerRestraunt.Furniture.Cooktop.Cooktop:GetChildren()) do
        if v:IsA('Part') then
            local rawPatty = v:FindFirstChild('Raw Patty')
            if rawPatty then
                local flipRemote = rawPatty:FindFirstChild('Flip')
                if flipRemote then
                    local arguments = {}
                    flipRemote:FireServer(unpack(arguments))
                    print('🔥 Flipped patty on cooktop!')
                end
            end
        end
    end
end

-- Execute the functions
takePatty()
snapOnCook()
getPaper()
getBun()
sanpBunOnPaper()
snapPattyOnAllValidBurgers()
wrapFinishedBurgers()
autoFlipBurgers()


-- Debug function to see available ingredients
local function debugIngredients()
    print('=== AVAILABLE INGREDIENTS ===')
    local playerData = game:GetService('Players').LocalPlayer.Data.Foods
    for ingredientId, foodData in pairs(playerData:GetChildren()) do
        local itemValue = foodData:FindFirstChild('Item')
        if itemValue then
            local inRestaurant = playerRestraunt.Ingredients:FindFirstChild(
                ingredientId
            ) and '✅' or '❌'
            print(
                inRestaurant
                    .. ' '
                    .. itemValue.Value
                    .. ' (ID: '
                    .. ingredientId
                    .. ')'
            )
        end
    end
    print('=============================')
end

-- Uncomment to debug ingredients
 debugIngredients()
