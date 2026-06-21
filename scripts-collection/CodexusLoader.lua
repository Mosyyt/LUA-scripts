getgenv().EXEC_ON_SYNX = false

function DestroyIfAlreadyLoaded()
	if gethui then
		for i, v in pairs(gethui():GetChildren()) do
			if v.Name == getgenv().CODEXLOADERSTR or v.Name == "CodexusHubLoader" then
				v:Destroy()
				return
			end
		end
	end
	if syn and syn.protect_gui then
		local children = game:GetService("CoreGui"):GetChildren()

		for i, v in pairs(children) do
			if v.Name == getgenv().CODEXLOADERSTR or v.Name == "CodexusHubLoader" then
				syn.unprotect_gui(v)
				v:Destroy()
				return
			end
		end
	end
end

function RandomString(len)
	if not len then
		len = 50
	end
	local sets = { { 97, 122 }, { 65, 90 }, { 48, 57 } } -- a-z, A-Z, 0-9
	local str = ""
	for i = 1, len do
		math.randomseed(os.clock() ^ 5)
		local charset = sets[math.random(1, #sets)]
		str = str .. string.char(math.random(charset[1], charset[2]))
	end
	return str
end

function HideUi(uiElement)
	if gethui then
		uiElement.Parent = gethui()
		return true
	end
	if syn.protect_gui then
		syn.protect_gui(uiElement)
		uiElement.Parent = game:GetService("CoreGui")
		return true
	end

	return false
end

-- Gets the first valid HttpRequest function.
function GetRequestFunction()
	return http_request or syn.request or http.request or request
end

function DefaultRobloxNotification(title, text, duration)
	local StarterGui = game:GetService("StarterGui")
	StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = duration })
end

function PISSOFF(reason)
	game.Players.LocalPlayer:Kick(reason)
end

-- Gets the magic value the key system is attached to.
function GetKeySystemMagicValue()
	local old = getthreadidentity()
	setthreadidentity(2)
	local resp = GetRequestFunction()({
		Url = "https://api.sussy.dev/v2/Roblox/Exploiting/GetHwid",
		Method = "GET",
	})

	if resp.Body == "No Hardware Id Found." then
		PISSOFF("Loader -> Unsupported Executor")
		if LPH_OBFUSCATED then
			LPH_CRASH()
		end
	end

	setthreadidentity(old)
	return resp.Body
end

--- Automatically kills common anticheats, like Adonis.
function InutilizeAnticheat()
	local executorRequest = GetRequestFunction()

	local response = executorRequest({
		Url = "https://api.sussy.dev/v1/KeySystem/Assets/GetPublicFile?fileName=disableac.lua",
		Method = "GET",
	})

	if response.StatusCode ~= 200 then
		DefaultRobloxNotification(
			"Anticheat Hooks",
			"We failed to fetch the common anticheat hooks, don't worry, though.",
			5
		)
		return false
	end -- Not initialized, AC hooks disabled

	local successfullyHooked = loadstring(response.Body)()

	if successfullyHooked then
		DefaultRobloxNotification("Anticheat Hooks", "Hooks enabled!", 5)
		return true
	end
end

function OhYesHeHasMoney(key)
	local executorRequest = GetRequestFunction()

	local response = executorRequest({
		Url = "https://api.sussy.dev/v1/KeySystem/IsPremiumKey",
		Method = "GET",
		Headers = {
			["X-KeySystem-Authorization"] = string.format("KeySystem %s", key),
		},
	})

	return response.StatusCode == 200
end

function ValidateKey_A(key)
	local executorRequest = GetRequestFunction()

	-- All the APIs has been checked to see if they exists, use them with basically no fear!

	local response = executorRequest({
		Url = "https://api.sussy.dev/v1/KeySystem/Validatekey",
		Method = "GET",
		Headers = {
			["X-KeySystem-Authorization"] = string.format("KeySystem %s", key),
		},
	})

	if response.StatusCode ~= 200 then
		return false
	end

	local responseAsJson = game:GetService("HttpService"):JSONDecode(response.Body)

	local token = responseAsJson.Token
	local createdFor = responseAsJson.CreatedFor
	local magicValue = responseAsJson.MagicValue

	if token ~= key then
		return false
	end
	if magicValue ~= GetKeySystemMagicValue() then
		return false
	end
	if createdFor ~= createdFor then
		return false
	end

	return true
end

function VerifyKeyButton(key)
	local executorRequest = GetRequestFunction()

	-- All the APIs has been checked to see if they exists, use them with basically no fear!

	local response = executorRequest({
		Url = "https://api.sussy.dev/v1/KeySystem/Validatekey",
		Method = "GET",
		Headers = {
			["X-KeySystem-Authorization"] = string.format("KeySystem %s", key),
		},
	})
	if response.StatusCode == 200 then
		local responseAsJson = game:GetService("HttpService"):JSONDecode(response.Body)

		local token = responseAsJson.Token
		local createdFor = responseAsJson.CreatedFor
		local magicValue = responseAsJson.MagicValue

		if token ~= key then
			game.Players.LocalPlayer:Kick("Possible key system tampering, rejoin to retry.")
		end

		if magicValue ~= GetKeySystemMagicValue() then
			DefaultRobloxNotification("Invalid Key", "This key is not attached to your hardware id.", 10)
			getfenv().LOADER_ERR = "This key is not attached to your hardware id."
			getfenv().VERIFICATION_SUCCEEDED = false
			return
		end

		if createdFor ~= getfenv().GUI_KEYSYS_CREATED_FOR then
			DefaultRobloxNotification(
				"Invalid Key",
				"This key is not for " .. getfenv().GUI_KEYSYS_CREATED_FOR .. " rather it is for " .. createdFor,
				10
			)

			getfenv().VERIFICATION_SUCCEEDED = false
			return
		end

		getfenv().WHITELIST_KEY = token -- Set whitelist token

		DefaultRobloxNotification("Valid Key!", "Your key is valid, and has been saved! The hub will now load!", 10)

		task.wait(1) -- Crash Mitigation

		writefile("chub_key.txt", getfenv().WHITELIST_KEY)

		getfenv().VERIFICATION_SUCCEEDED = true
		return
	else
		PISSOFF("Failed -> Invalid Key")
		getfenv().VERIFICATION_SUCCEEDED = false
	end
end

function VerfyExecutorApis()
	-- Common on BOTH UNC and SynX

	if not identifyexecutor then
		return false
	end
	if not isfile then
		return false
	end
	if not isfolder then
		return false
	end
	if not writefile then
		return false
	end
	if not readfile then
		return false
	end

	if syn and identifyexecutor() == "Synapse" then
		-- Synapse Specific
		-- Check for SynapseX API implementations
		-- If we have synapse specific implemnentations and identifyexecutor() returns "Synapse" then
		-- we can assure this is synapsex, and we don't have any UNC, because they are unfunny.

		if not syn.crypt or not syn.crypt.base64encode then
			return false
		end
		if not syn.request then
			return false
		end

		getgenv().EXEC_ON_SYNX = true
		return true
	end

	-- UNC Support
	if not gethui then
		return false
	end

	if not http_request or not http.request or not request then
		return false
	end

	if not crypt or not crypt.base64encode then
		return false
	end

	return true -- Lmao.
end

-- Holds a reference to the ScreenGui used by the loader. THIS IS INITIALIZED AFTER CALLING InstanciateUiComponents()
CodexusMainGuiReference = nil

-- Returns a table that contains references to the initialized items.
function InstanciateUiComponents()
	-- Instance Initialization:
	CodexusMainGuiReference = Instance.new("ScreenGui")
	local CodexusHubLoader = CodexusMainGuiReference

	local MainFrame = Instance.new("ImageLabel")
	local MainFrameShadow = Instance.new("ImageLabel")
	local Pattern = Instance.new("ImageLabel")
	local UICorner = Instance.new("UICorner")
	local ButtonHolder = Instance.new("ImageLabel")
	local VerifyYourKey = Instance.new("TextButton")
	local UIGradient = Instance.new("UIGradient")
	local GetKey = Instance.new("TextButton")
	local UIGradient_2 = Instance.new("UIGradient")
	local VerifyKeyBackground = Instance.new("ImageLabel")
	local GetKeyBackground = Instance.new("ImageLabel")
	local KeyInsertBackFrame = Instance.new("ImageLabel")
	local KeyInsertTextBox = Instance.new("TextBox")
	local Logo = Instance.new("ImageLabel")
	local GUITitle = Instance.new("TextLabel")
	local UIGradient_3 = Instance.new("UIGradient")

	local ElementTable = {
		CodexusHubLoader,
		MainFrame,
		MainFrameShadow,
		Pattern,
		UICorner,
		ButtonHolder,
		VerifyYourKey,
		UIGradient,
		GetKey,
		UIGradient_2,
		VerifyKeyBackground,
		GetKeyBackground,
		KeyInsertBackFrame,
		KeyInsertTextBox,
		Logo,
		GUITitle,
		UIGradient_3,
	}

	-- Properties:

	CodexusHubLoader.Name = getgenv().CODEXLOADERSTR or "CodexusHubLoader"

	-- UI Will be hidden if this call succeeds
	if not HideUi(CodexusHubLoader) then
		game:GetService("Players").LocalPlayer:Kick("Loader error -> Cannot assure a safe initialization!")
	end
	if not getgenv().CODEXLOADERSTR then
		getgenv().CODEXLOADERSTR = RandomString()
		CodexusHubLoader.Name = getgenv().CODEXLOADERSTR
	end

	MainFrame.Name = "MainFrame"
	MainFrame.Parent = CodexusHubLoader
	MainFrame.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	MainFrame.BackgroundTransparency = 1.000
	MainFrame.BorderSizePixel = 0
	MainFrame.Position = UDim2.new(0.216682643, 0, 0.156626493, 0)
	MainFrame.Size = UDim2.new(0, 630, 0, 341)
	MainFrame.ZIndex = 2
	MainFrame.Image = "rbxassetid://3570695787"
	MainFrame.ImageColor3 = Color3.fromRGB(56, 56, 56)
	MainFrame.ScaleType = Enum.ScaleType.Slice
	MainFrame.SliceCenter = Rect.new(100, 100, 100, 100)
	MainFrame.SliceScale = 0.250

	-- Make draggable.
	coroutine.wrap(function()
		local script = Instance.new("LocalScript", MainFrame)

		local UserInputService = game:GetService("UserInputService")

		local gui = script.Parent

		local dragging
		local dragInput
		local dragStart
		local startPos

		local function update(input)
			local delta = input.Position - dragStart
			gui.Position =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		gui.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
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
			if
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)()

	MainFrameShadow.Name = "MainFrameShadow"
	MainFrameShadow.Parent = MainFrame
	MainFrameShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	MainFrameShadow.BackgroundTransparency = 1.000
	MainFrameShadow.Position = UDim2.new(0, 10, 0, 10)
	MainFrameShadow.Size = UDim2.new(1, 0, 1, 0)
	MainFrameShadow.Image = "rbxassetid://3570695787"
	MainFrameShadow.ImageColor3 = Color3.fromRGB(40, 40, 40)
	MainFrameShadow.ScaleType = Enum.ScaleType.Slice
	MainFrameShadow.SliceCenter = Rect.new(100, 100, 100, 100)
	MainFrameShadow.SliceScale = 0.250

	Pattern.Name = "Pattern"
	Pattern.Parent = MainFrame
	Pattern.AnchorPoint = Vector2.new(0.5, 0.5)
	Pattern.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Pattern.BackgroundTransparency = 1.000
	Pattern.BorderSizePixel = 0
	Pattern.Position = UDim2.new(0.5, 0, 0.499083579, 0)
	Pattern.Size = UDim2.new(0, 630, 0, 340)
	Pattern.ZIndex = 2
	Pattern.Image = "rbxassetid://2151741365"
	Pattern.ImageColor3 = Color3.fromRGB(0, 166, 255)
	Pattern.ImageTransparency = 0.600
	Pattern.ScaleType = Enum.ScaleType.Tile
	Pattern.SliceCenter = Rect.new(0, 256, 0, 256)
	Pattern.TileSize = UDim2.new(0, 250, 0, 250)

	UICorner.CornerRadius = UDim.new(0.100000001, 0)
	UICorner.Parent = Pattern

	ButtonHolder.Name = "ButtonHolder"
	ButtonHolder.Parent = MainFrame
	ButtonHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ButtonHolder.BackgroundTransparency = 1.000
	ButtonHolder.Position = UDim2.new(0, 23, 0, 224)
	ButtonHolder.Size = UDim2.new(0.933333337, 0, 0.278592408, 0)
	ButtonHolder.ZIndex = 3
	ButtonHolder.Image = "rbxassetid://3570695787"
	ButtonHolder.ImageColor3 = Color3.fromRGB(40, 40, 40)
	ButtonHolder.ScaleType = Enum.ScaleType.Slice
	ButtonHolder.SliceCenter = Rect.new(100, 100, 100, 100)
	ButtonHolder.SliceScale = 0.250

	VerifyYourKey.Name = "VerifyYourKey"
	VerifyYourKey.Parent = ButtonHolder
	VerifyYourKey.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	VerifyYourKey.BackgroundTransparency = 1.000
	VerifyYourKey.BorderColor3 = Color3.fromRGB(0, 0, 0)
	VerifyYourKey.BorderSizePixel = 0
	VerifyYourKey.Position = UDim2.new(0.550760925, 0, 0.165607154, 0)
	VerifyYourKey.Size = UDim2.new(0, 227, 0, 60)
	VerifyYourKey.ZIndex = 4
	VerifyYourKey.Font = Enum.Font.SourceSans
	VerifyYourKey.Text = "Verify Your Key"
	VerifyYourKey.TextColor3 = Color3.fromRGB(255, 255, 255)
	VerifyYourKey.TextScaled = true
	VerifyYourKey.TextSize = 14.000
	VerifyYourKey.TextWrapped = true
	VerifyYourKey.MouseButton1Click:Connect(function()
		if KeyInsertTextBox.Text == "" then
			DefaultRobloxNotification(
				"You didn't give a key at all",
				"Place a key before clicking the verify button!",
				15
			)
			return
		end
		VerifyKeyButton(KeyInsertTextBox.Text)
	end)

	UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(81, 180, 185)),
		ColorSequenceKeypoint.new(0.53, Color3.fromRGB(77, 235, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(85, 173, 226)),
	})
	UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 0.00),
		NumberSequenceKeypoint.new(1.00, 0.41),
	})
	UIGradient.Parent = VerifyYourKey

	GetKey.Name = "Get Key"
	GetKey.Parent = ButtonHolder
	GetKey.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	GetKey.BackgroundTransparency = 1.000
	GetKey.BorderColor3 = Color3.fromRGB(0, 0, 0)
	GetKey.BorderSizePixel = 0
	GetKey.Position = UDim2.new(0.0572074838, 0, 0.165607214, 0)
	GetKey.Size = UDim2.new(0, 227, 0, 60)
	GetKey.ZIndex = 4
	GetKey.Font = Enum.Font.SourceSans
	GetKey.Text = "Get Key (Copy URL)"
	GetKey.TextColor3 = Color3.fromRGB(255, 255, 255)
	GetKey.TextScaled = true
	GetKey.TextSize = 14.000
	GetKey.TextWrapped = true
	GetKey.MouseButton1Click:Connect(function()
		local setclip = setclipboard or (syn and syn.write_clipboard)
		setclip("https://sussy.dev/KeySystem/GenerateKey?hardwareid=" .. GetKeySystemMagicValue())
		DefaultRobloxNotification(
			"Copied to Clipboard!",
			"Your personalized Key System URL has been copied to your clipboard; if it didn't copy, try again, else, join the Discord to get a key that way!",
			15
		)
	end)

	UIGradient_2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(81, 180, 185)),
		ColorSequenceKeypoint.new(0.53, Color3.fromRGB(77, 235, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(85, 173, 226)),
	})
	UIGradient_2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 0.00),
		NumberSequenceKeypoint.new(1.00, 0.41),
	})
	UIGradient_2.Parent = GetKey

	VerifyKeyBackground.Name = "VerifyKeyBackground"
	VerifyKeyBackground.Parent = ButtonHolder
	VerifyKeyBackground.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	VerifyKeyBackground.BackgroundTransparency = 1.000
	VerifyKeyBackground.BorderSizePixel = 0
	VerifyKeyBackground.Position = UDim2.new(0.519287765, 0, 0.165607646, 0)
	VerifyKeyBackground.Size = UDim2.new(0, 265, 0, 63)
	VerifyKeyBackground.ZIndex = 3
	VerifyKeyBackground.Image = "rbxassetid://3570695787"
	VerifyKeyBackground.ImageColor3 = Color3.fromRGB(56, 56, 56)
	VerifyKeyBackground.ScaleType = Enum.ScaleType.Slice
	VerifyKeyBackground.SliceCenter = Rect.new(100, 100, 100, 100)
	VerifyKeyBackground.SliceScale = 0.250

	GetKeyBackground.Name = "GetKeyBackground"
	GetKeyBackground.Parent = ButtonHolder
	GetKeyBackground.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	GetKeyBackground.BackgroundTransparency = 1.000
	GetKeyBackground.BorderSizePixel = 0
	GetKeyBackground.Position = UDim2.new(0.0252641793, 0, 0.166084349, 0)
	GetKeyBackground.Size = UDim2.new(0, 265, 0, 63)
	GetKeyBackground.ZIndex = 3
	GetKeyBackground.Image = "rbxassetid://3570695787"
	GetKeyBackground.ImageColor3 = Color3.fromRGB(56, 56, 56)
	GetKeyBackground.ScaleType = Enum.ScaleType.Slice
	GetKeyBackground.SliceCenter = Rect.new(100, 100, 100, 100)
	GetKeyBackground.SliceScale = 0.250

	KeyInsertBackFrame.Name = "KeyInsertBackFrame"
	KeyInsertBackFrame.Parent = MainFrame
	KeyInsertBackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	KeyInsertBackFrame.BackgroundTransparency = 1.000
	KeyInsertBackFrame.Position = UDim2.new(0, 10, 0, 112)
	KeyInsertBackFrame.Size = UDim2.new(0.969841242, 0, 0.219941378, 0)
	KeyInsertBackFrame.ZIndex = 3
	KeyInsertBackFrame.Image = "rbxassetid://3570695787"
	KeyInsertBackFrame.ImageColor3 = Color3.fromRGB(40, 40, 40)
	KeyInsertBackFrame.ScaleType = Enum.ScaleType.Slice
	KeyInsertBackFrame.SliceCenter = Rect.new(100, 100, 100, 100)
	KeyInsertBackFrame.SliceScale = 0.250

	KeyInsertTextBox.Name = "KeyInsertTextBox"
	KeyInsertTextBox.Parent = KeyInsertBackFrame
	KeyInsertTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	KeyInsertTextBox.BackgroundTransparency = 1.000
	KeyInsertTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	KeyInsertTextBox.BorderSizePixel = 0
	KeyInsertTextBox.Size = UDim2.new(0, 611, 0, 75)
	KeyInsertTextBox.ZIndex = 3
	KeyInsertTextBox.Font = Enum.Font.SourceSans
	KeyInsertTextBox.Text = "Put Your Key Here"
	KeyInsertTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeyInsertTextBox.TextScaled = true
	KeyInsertTextBox.TextSize = 14.000
	KeyInsertTextBox.TextWrapped = true

	Logo.Name = "Logo"
	Logo.Parent = MainFrame
	Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Logo.BackgroundTransparency = 1.000
	Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Logo.BorderSizePixel = 0
	Logo.Position = UDim2.new(0.782539546, 0, 0, 0)
	Logo.Size = UDim2.new(0, 158, 0, 120)
	Logo.ZIndex = 3
	Logo.Image = "rbxassetid://13984442620"

	GUITitle.Name = "GUITitle"
	GUITitle.Parent = MainFrame
	GUITitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	GUITitle.BackgroundTransparency = 1.000
	GUITitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	GUITitle.BorderSizePixel = 0
	GUITitle.Position = UDim2.new(1.86264515e-09, 0, 0.102639295, 0)
	GUITitle.Size = UDim2.new(0, 469, 0, 49)
	GUITitle.ZIndex = 2
	GUITitle.Font = Enum.Font.SourceSans
	GUITitle.Text = "Codexus Hub Loader"
	GUITitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	GUITitle.TextScaled = true
	GUITitle.TextSize = 14.000
	GUITitle.TextWrapped = true

	UIGradient_3.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(81, 180, 185)),
		ColorSequenceKeypoint.new(0.53, Color3.fromRGB(77, 235, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(85, 173, 226)),
	})
	UIGradient_3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 0.00),
		NumberSequenceKeypoint.new(1.00, 0.41),
	})
	UIGradient_3.Parent = GUITitle
end

function LoadScript()
	local response = GetRequestFunction()({
		Url = "https://api.sussy.dev/v1/KeySystem/Assets/GetFile?fileName=Codexus_Hub_" .. game.GameId .. ".lua",
		Method = "GET",
		Headers = {
			["X-KeySystem-Authorization"] = string.format("KeySystem %s", getfenv().WHITELIST_KEY),
		},
	})

	-- Set premiumality :trol:
	getfenv().PREMIUM_USER = OhYesHeHasMoney(getfenv().WHITELIST_KEY)

	if response.StatusCode ~= 200 then
		PISSOFF("Loader Error -> This game is not supported on the hub.")
		if LPH_OBFUSCATED then
			LPH_CRASH()
		end
		return
	end

	if not ValidateKey_A(getfenv().WHITELIST_KEY) then
		PISSOFF("Whitelisitng Erro -> Possible Tampering of the environment. Try again.")
		if LPH_OBFUSCATED then
			LPH_CRASH()
		end
		return
	end

	loadstring(response.Body)()
	return InutilizeAnticheat()
end

function GetSavedKey()
	if isfile("chub_key.txt") then
		return readfile("chub_key.txt")
	end
	return nil
end

function MarkFirstStart()
	if not isfile("chub_started_stub") then
		writefile("chub_started_stub", "")
	end
	return true
end

function IsFirstStart()
	return not isfile("chub_started_stub")
end

function CheckForSavedKey(verifyKey)
	if verifyKey then
		local savedKey = GetSavedKey()
		if not savedKey then
			return nil
		end
		if ValidateKey_A(savedKey) then
			getfenv().WHITELIST_KEY = savedKey
			return true
		end
	end
end

if not VerfyExecutorApis() then
	PISSOFF("Loader error -> Missing Executor APIs")
	if LPH_OBFUSCATED then
		LPH_CRASH()
	end
	return
end

-- #region Anti Tampering prelude

function IsScriptObfuscated()
	return (LPH_OBFUSCATED or _77Crash)
end

function CrashObfuscatorVM()
	if LPH_OBFUSCATED then
		LPH_CRASH()
	end
	if _77Crash then
		_77Crash()
	end
end

if rconsoleprint then
	hookfunction(
		rconsoleprint,
		newcclosure(function(...)
			return nil
		end)
	)
end
if consoleprint then
	hookfunction(
		consoleprint,
		newcclosure(function(...)
			return nil
		end)
	)
end

local functions = {
	rconsoleprint,
	print,
	setclipboard,
	rconsoleerr,
	rconsolewarn,
	warn,
	error,
}

for _, v in next, functions do
	local old
	old = hookfunction(
		v,
		newcclosure(function(...)
			local args = { ... }
			for i, v in next, args do
				if tostring(i):find("http") or tostring(v):find("http") then
					if IsScriptObfuscated() then
						CrashObfuscatorVM()
					end
					while true do
					end
				end
			end
			return old(...)
		end)
	)
end

if _G.ID then
	if IsScriptObfuscated() then
		CrashObfuscatorVM()
	end
	while true do
	end
end
setmetatable(_G, {
	__newindex = function(...)
		if select(2, ...) == "ID" then
			if IsScriptObfuscated() then
				CrashObfuscatorVM()
			end
			while true do
			end
		end
	end,
})

if islclosure(GetRequestFunction()) then
	if IsScriptObfuscated() then
		CrashObfuscatorVM()
	end
	while true do
	end
end

-- #endregion Anti Tamperimg prelude

DestroyIfAlreadyLoaded()

if IsFirstStart() then
	DefaultRobloxNotification("Hello!", "Welcome, " .. game.Players.LocalPlayer.DisplayName .. " to Codexus Hub!", 10)
else
	DefaultRobloxNotification(
		"Hello! Welcome back!",
		"Welcome back, " .. game.Players.LocalPlayer.DisplayName .. " to Codexus Hub!",
		10
	)
end

MarkFirstStart()

local savedKeyCheckedSucceeded = CheckForSavedKey(true)
if savedKeyCheckedSucceeded then
	if not ValidateKey_A(getfenv().WHITELIST_KEY) then
		PISSOFF("Possible Tampering of the environment. Try again.")
		if LPH_OBFUSCATED then
			LPH_CRASH()
		end
	end
	DefaultRobloxNotification(
		"Hello!",
		"Welcome back, "
			.. game.Players.LocalPlayer.DisplayName
			.. " We found a key! We are loading the respective GUI!",
		10
	)
	getgenv().WHITEKEY = getfenv().WHITELIST_KEY
	LoadScript()
	return
elseif savedKeyCheckedSucceeded == false then
	DefaultRobloxNotification(
		"Hello!",
		"Welcome back, "
			.. game.Players.LocalPlayer.DisplayName
			.. " We found a key, but it was deemed to no longer be valid, refresh it!",
		10
	)
end
-- All APIs that are required have been found! We can continue, with no fear!

getfenv().GUI_KEYSYS_CREATED_FOR = "Codexus Hub"

if getgenv().wl_key then
	if ValidateKey_A(getgenv().wl_key) then
		writefile("chub_key.txt", getgenv().wl_key)

		if ValidateKey_A(getgenv().wl_key) then
			getfenv().WHITELIST_KEY = getgenv().wl_key
			getgenv().WHITEKEY = getfenv().WHITELIST_KEY
			DefaultRobloxNotification(
				"Valid whitelist key detected",
				"We found a whitelist key, and it has been validated successfully!",
				10
			)
			LoadScript()
			return
		else
			PISSOFF("Possible key system bypass attempt. Try again.")
			if LPH_OBFUSCATED then
				LPH_CRASH()
			end
		end
		return
	end

	DefaultRobloxNotification(
		"We have detected a whitelist key",
		"But it was not valid, paste a valid one to continue",
		15
	)
end

InstanciateUiComponents()

while getfenv().VERIFICATION_SUCCEEDED == nil do
	task.wait(1)
end

CodexusMainGuiReference:Destroy()

if getfenv().VERIFICATION_SUCCEEDED == false then
	PISSOFF("Loader Error -> " .. getfenv().LOADER_ERR)
	if LPH_OBFUSCATED then
		LPH_CRASH()
	end
end

-- We can continue loading the script, but just in case, check the whitelist key again.

if not ValidateKey_A(getfenv().WHITELIST_KEY) then
	PISSOFF("Possible Tampering of the environment. Try again.")
	if LPH_OBFUSCATED then
		LPH_CRASH()
	end
end

getgenv().WHITEKEY = getfenv().WHITELIST_KEY
LoadScript()

--! getfenv().PREMIUM_USER == THE USER IS PREMIUM; THE USER MAY USE THE SCRIPT!
