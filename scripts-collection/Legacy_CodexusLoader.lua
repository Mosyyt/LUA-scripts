local Request = http_request or syn.request or request
local fsPath = nil
for i, v in pairs(gethui():GetChildren()) do
    if string.find(v.Name, "Codexus") then v:Destroy() end
end
function getMagicValue_XABIUUASHDUAIHSDAUSHDIUASH()
    return tostring(game.Players.LocalPlayer.UserId)
end

function verifyKeySystem()

    if not getfenv().GUI_KEYSYS_CREATED_FOR then
        game.Players.LocalPlayer:Kick(
            "Key System misconfigured. Can not validate session")
    end
    if not crypt or not crypt.base64encode then
        game.Players.LocalPlayer:Kick(
            "Executor missing base64 implementation, can not proceed. Sorry.")
    end

    if not Request then
        game.Players.LocalPlayer:Kick(
            "Exploit does not support HttpRequest, we can not proceed, we are sorry.")
    end

    if isfile and writefile and readfile then
        local keySysFileExists = isfile(fsPath)

        if keySysFileExists then
            local key = readfile(fsPath)
            if key then
                print("Found key. Validating key...")
                local response = Request({
                    Url = "https://api.sussy.dev/v1/KeySystem/Validatekey",
                    Method = "GET",
                    Headers = {
                        ["X-KeySystem-Authorization"] = string.format(
                            "KeySystem %s", key)
                    }
                })

                if response.StatusCode == 200 then
                    local responseAsJson =
                        game:GetService("HttpService"):JSONDecode(response.Body)

                    local token = responseAsJson.Token
                    local createdFor = responseAsJson.CreatedFor
                    local validUntil = responseAsJson.ValidUntil
                    local magicValue = responseAsJson.MagicValue

                    if magicValue ~= getMagicValue_XABIUUASHDUAIHSDAUSHDIUASH() then
                        print("This key is not attached to your user id.")
                        getfenv().VERIFICATION_SUCCEEDED = false
                        return
                    end

                    if createdFor ~= getfenv().GUI_KEYSYS_CREATED_FOR then
                        print("This key is not for " ..
                                  getfenv().GUI_KEYSYS_CREATED_FOR ..
                                  " rather it is for " .. createdFor)
                        getfenv().VERIFICATION_SUCCEEDED = false
                        return
                    end

                    getfenv().WHITELIST_KEY = token -- Set whitelist token
                    print("Verification succeeded")
                    getfenv().VERIFICATION_SUCCEEDED = true
                    return
                else
                    print("Invalid key.")
                end
            else
                print("Key not found. Opening GUI.")
            end
        end
    else
        warn(
            "isfile/writefile/readfile function not supported, user will have to input the key all the time, sorry chief.")
    end
end
if not gethui then
    game.Players.LocalPlayer:Kick("Your exploit does not support gethui()")
end
local CodexusHub = Instance.new("ScreenGui")
local FrontFrame = Instance.new("Frame")
local BackFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Credits2 = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")
local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
local GetKey = Instance.new("TextButton")
local UICorner_3 = Instance.new("UICorner")
local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
local Credits2_2 = Instance.new("Frame")
local UICorner_4 = Instance.new("UICorner")
local Credits21 = Instance.new("TextButton")
local UICorner_5 = Instance.new("UICorner")
local UITextSizeConstraint_3 = Instance.new("UITextSizeConstraint")
local UIGradient = Instance.new("UIGradient")
local UICorner_6 = Instance.new("UICorner")
local ImageLabel = Instance.new("ImageLabel")
local TextBox = Instance.new("TextBox")
local GetKeyFrame = Instance.new("Frame")
local UICorner_7 = Instance.new("UICorner")
local AutoDetectButton = Instance.new("TextButton")
local UICorner_8 = Instance.new("UICorner")
local UITextSizeConstraint_4 = Instance.new("UITextSizeConstraint")
local AutoDetectFrame = Instance.new("Frame")
local UICorner_9 = Instance.new("UICorner")

-- Properties:

CodexusHub.Name = "CodexusHub"
CodexusHub.Parent = gethui()

FrontFrame.Name = "FrontFrame"
FrontFrame.Parent = CodexusHub
FrontFrame.BackgroundColor3 = Color3.fromRGB(44, 45, 45)
FrontFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
FrontFrame.BorderSizePixel = 0
FrontFrame.Position = UDim2.new(0.310990483, 0, 0.276605666, 0)
FrontFrame.Size = UDim2.new(0, 528, 0, 268)

BackFrame.Name = "BackFrame"
BackFrame.Parent = FrontFrame
BackFrame.BackgroundColor3 = Color3.fromRGB(49, 50, 51)
BackFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
BackFrame.BorderSizePixel = 0
BackFrame.Position = UDim2.new(-0.0253100544, 0, -0.0283684805, 0)
BackFrame.Size = UDim2.new(0, 554, 0, 287)
BackFrame.ZIndex = 0

UICorner.CornerRadius = UDim.new(0.100000001, 0)
UICorner.Parent = BackFrame

Credits2.Name = "Credits2"
Credits2.Parent = FrontFrame
Credits2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Credits2.BackgroundTransparency = 1.000
Credits2.Position = UDim2.new(0.360261679, 0, -0.000537753105, 0)
Credits2.Size = UDim2.new(0, 147, 0, 27)
Credits2.ZIndex = 3
Credits2.Font = Enum.Font.Gotham
Credits2.Text = "Made By: Bebo Mods"
Credits2.TextColor3 = Color3.fromRGB(255, 255, 255)
Credits2.TextScaled = true
Credits2.TextSize = 10.000
Credits2.TextWrapped = true

UICorner_2.CornerRadius = UDim.new(0.349999994, 0)
UICorner_2.Parent = Credits2

UITextSizeConstraint.Parent = Credits2
UITextSizeConstraint.MaxTextSize = 50

GetKey.Name = "Get Key"
GetKey.Parent = FrontFrame
GetKey.BackgroundColor3 = Color3.fromRGB(49, 50, 51)
GetKey.BackgroundTransparency = 0.900
GetKey.Position = UDim2.new(0.123244554, 0, 0.706436872, 0)
GetKey.Size = UDim2.new(0, 191, 0, 63)
GetKey.ZIndex = 3
GetKey.Font = Enum.Font.Gotham
GetKey.Text = "Get Key"
GetKey.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKey.TextScaled = true
GetKey.TextSize = 24.000
GetKey.TextWrapped = true
GetKey.MouseButton1Click:connect(function()
    ---@diagnostic disable-next-line: undefined-global
    local Request = http_request or syn.request or request
    if Request then
        Request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = game:GetService("HttpService"):JSONEncode({
                args = {
                    code = "75p9Z3jPh7" -- Replace with your Discord invite code
                },
                cmd = "INVITE_BROWSER",
                nonce = "."
            })
        })
    end
end)

UICorner_3.CornerRadius = UDim.new(0.349999994, 0)
UICorner_3.Parent = GetKey

UITextSizeConstraint_2.Parent = GetKey
UITextSizeConstraint_2.MaxTextSize = 24

Credits2_2.Name = "Credits2"
Credits2_2.Parent = FrontFrame
Credits2_2.BackgroundColor3 = Color3.fromRGB(49, 50, 51)
Credits2_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
Credits2_2.BorderSizePixel = 0
Credits2_2.Position = UDim2.new(0.0379468501, 0, 0.0795711875, 0)
Credits2_2.Size = UDim2.new(0, 134, 0, 54)

UICorner_4.CornerRadius = UDim.new(0.25, 0)
UICorner_4.Parent = Credits2_2

Credits21.Name = "Credits21"
Credits21.Parent = FrontFrame
Credits21.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Credits21.BackgroundTransparency = 1.000
Credits21.Position = UDim2.new(0.0326101184, 0, 0.126328051, 0)
Credits21.Size = UDim2.new(0, 138, 0, 27)
Credits21.ZIndex = 3
Credits21.Font = Enum.Font.Gotham
Credits21.Text = "Enjoy!!!"
Credits21.TextColor3 = Color3.fromRGB(255, 255, 255)
Credits21.TextScaled = true
Credits21.TextSize = 10.000
Credits21.TextWrapped = true

UICorner_5.CornerRadius = UDim.new(0.349999994, 0)
UICorner_5.Parent = Credits21

UITextSizeConstraint_3.Parent = Credits21
UITextSizeConstraint_3.MaxTextSize = 50

UIGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(251, 255, 240)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(252, 255, 244))
}
UIGradient.Parent = Credits21

UICorner_6.CornerRadius = UDim.new(0.100000001, 0)
UICorner_6.Parent = FrontFrame

ImageLabel.Parent = FrontFrame
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.Position = UDim2.new(0.751467168, 0, -0.00149303675, 0)
ImageLabel.Size = UDim2.new(0, 131, 0, 119)
ImageLabel.Image = "rbxassetid://12413216961"
ImageLabel.ScaleType = Enum.ScaleType.Crop

TextBox.Parent = FrontFrame
TextBox.BackgroundColor3 = Color3.fromRGB(49, 50, 51)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0.0267167035, 0, 0.439429343, 0)
TextBox.Size = UDim2.new(0, 498, 0, 50)
TextBox.Font = Enum.Font.SourceSans
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextScaled = true
TextBox.TextSize = 14.000
TextBox.TextWrapped = true
local function getKeyFromInput() return TextBox.Text end
GetKeyFrame.Name = "GetKeyFrame"
GetKeyFrame.Parent = FrontFrame
GetKeyFrame.BackgroundColor3 = Color3.fromRGB(49, 50, 51)
GetKeyFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
GetKeyFrame.BorderSizePixel = 0
GetKeyFrame.Position = UDim2.new(0.125068069, 0, 0.705040336, 0)
GetKeyFrame.Size = UDim2.new(0, 191, 0, 64)

UICorner_7.CornerRadius = UDim.new(0.25, 0)
UICorner_7.Parent = GetKeyFrame

AutoDetectButton.Name = "AutoDetectButton"
AutoDetectButton.Parent = FrontFrame
AutoDetectButton.BackgroundColor3 = Color3.fromRGB(49, 50, 51)
AutoDetectButton.BackgroundTransparency = 0.900
AutoDetectButton.Position = UDim2.new(0.519077897, 0, 0.706436932, 0)
AutoDetectButton.Size = UDim2.new(0, 191, 0, 63)
AutoDetectButton.ZIndex = 3
AutoDetectButton.Font = Enum.Font.Gotham
AutoDetectButton.Text = "Verify Key"
AutoDetectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoDetectButton.TextScaled = true
AutoDetectButton.TextSize = 24.000
AutoDetectButton.TextWrapped = true
AutoDetectButton.MouseButton1Click:Connect(function()
    if getKeyFromInput() == "" then
        print("[Sussy Development Key System] Invalid Key")
    end

    print("Verifying Key")
    local key = getKeyFromInput()
    if Request then
        local response = Request({
            Url = "https://api.sussy.dev/v1/KeySystem/Validatekey",
            Method = "GET",
            Headers = {
                ["X-KeySystem-Authorization"] = string.format("KeySystem %s",
                                                              key)
            }
        })

        if response.StatusCode == 200 then
            local responseAsJson = game:GetService("HttpService"):JSONDecode(
                                       response.Body)

            local token = responseAsJson.Token
            local createdFor = responseAsJson.CreatedFor
            local validUntil = responseAsJson.ValidUntil
            local magicValue = responseAsJson.MagicValue

            if token ~= key then
                game.Players.LocalPlayer:Kick(
                    "Possible key system tampering, rejoin to retry.")
            end

            if magicValue ~= getMagicValue_XABIUUASHDUAIHSDAUSHDIUASH() then
                print("This key is not attached to your user id.")
                getfenv().VERIFICATION_SUCCEEDED = false
                return
            end

            if createdFor ~= getfenv().GUI_KEYSYS_CREATED_FOR then
                print(
                    "This key is not for " .. getfenv().GUI_KEYSYS_CREATED_FOR ..
                        " rather it is for " .. createdFor)
                getfenv().VERIFICATION_SUCCEEDED = false
                return
            end

            getfenv().WHITELIST_KEY = token -- Set whitelist token
            print("Verification succeeded")
            getfenv().VERIFICATION_SUCCEEDED = true
            return
        else
            print("Invalid key.")
            getfenv().VERIFICATION_SUCCEEDED = false
        end

        return
    end

    game.Players.LocalPlayer:Kick(
        "Exploit does not support HttpRequest, we can not proceed, we are sorry.")
end)

UICorner_8.CornerRadius = UDim.new(0.349999994, 0)
UICorner_8.Parent = AutoDetectButton

UITextSizeConstraint_4.Parent = AutoDetectButton
UITextSizeConstraint_4.MaxTextSize = 24

AutoDetectFrame.Name = "AutoDetectFrame"
AutoDetectFrame.Parent = FrontFrame
AutoDetectFrame.BackgroundColor3 = Color3.fromRGB(49, 50, 51)
AutoDetectFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
AutoDetectFrame.BorderSizePixel = 0
AutoDetectFrame.Position = UDim2.new(0.519007444, 0, 0.705040336, 0)
AutoDetectFrame.Size = UDim2.new(0, 191, 0, 64)

UICorner_9.CornerRadius = UDim.new(0.25, 0)
UICorner_9.Parent = AutoDetectFrame

-- Scripts:

local function ULTEEV_fake_script() -- FrontFrame.Drag2 
    local script = Instance.new('LocalScript', FrontFrame)

    local UserInputService = game:GetService("UserInputService")

    local gui = script.Parent

    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                 startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
            input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

end
coroutine.wrap(ULTEEV_fake_script)()

getfenv().GUI_KEYSYS_CREATED_FOR = "Codexus Hub"
fsPath = getfenv().GUI_KEYSYS_CREATED_FOR .. "_codexus.key"
verifyKeySystem()

while not getfenv().VERIFICATION_SUCCEEDED do task.wait(1) end

CodexusHub:Destroy()

-- getfenv().WHITELIST_KEY - Contains the key used to verify, use it to access https://api.sussy.dev/ as a whitelisted user!

local whitelistKey = getfenv().WHITELIST_KEY

if not whitelistKey then
    game.Players.LocalPlayer:Kick(
        "Can not load: Missing KeySystem Authorization.")
end

local function GetScriptForCurrentGame()
    local response = Request({
        Url = "https://api.sussy.dev/v1/KeySystem/Assets/GetFile?fileName=Codexus_Hub_" ..
            game.PlaceId .. ".lua",
        Method = "GET",
        Headers = {
            ["X-KeySystem-Authorization"] = string.format("KeySystem %s",
                                                          getfenv().WHITELIST_KEY)
        }
    })

    if response.StatusCode ~= 200 then
        game.Players.LocalPlayer:Kick(
            "Script does not exist for this game, sorry mate.")
        if LPH_CRASH then 
        	LPH_CRASH()
        end
        return
    end

    return loadstring(response.Body)()
end

GetScriptForCurrentGame()
