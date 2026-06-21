-- #region Services

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

local Mouse = LocalPlayer:GetMouse()
local NavHover = false

-- #endregion Services

-- #region Helpers
local Helpers = {}

--- Generates a Random string. Not cryptographically secure.
--- @param length number The length of the string.
--- @return string rngString The randomly generated string.
function Helpers.RandomStringGenerator(length)
	if not length then
		length = math.random(0, 20)
	end
	local sets = { { 97, 122 }, { 65, 90 }, { 48, 57 } } -- a-z, A-Z, 0-9
	local str = ""

	for _ = 1, length do
		math.randomseed(os.clock() / length ^ 5)
		local charset = sets[math.random(1, #sets)]
		str = str .. string.char(math.random(charset[1], charset[2]))
	end

	return str
end

--- Protects a GUI from getting detected. Milage may vary due to executor's implementation.
--- Remarks: The ScreenGui will be parented after this call. Do not modify the Parent!
--- @param screenGui ScreenGui The screen GUI that should be protected.
function Helpers.ProtectGui(screenGui)
	if gethui then
		-- Get Hidden UI is here.
		screenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		-- Synapse :heart:
		syn.protect_gui(screenGui)
		screenGui.Parent = cloneref(game:GetService("CoreGui"))
	else
		-- We have no safer bet being honest.
		screenGui.Parent = cloneref(game:GetService("CoreGui"))
	end
end

-- #endregion Helpers

-- #region Stub Declarations

--! Code extracted from codexus's misc project -> betterinit.lua
if not newcclosure then
	--- Wraps the given closure into a CClosure.
	--- @param f function The function to wrap onto a CClosure.
	--- @return function newCClosure The closure, but now identifying itself as a C closure.
	function newcclosure(f)
		if not iscclosure(f) then
			return coroutine.wrap(function(...)
				while true do
					coroutine.yield(f(...))
				end
			end)
		else
			return f
		end
	end
end

--! Code extracted from codexus's misc project -> betterinit.lua
if not cloneref then
	local Part = Instance.new("Part")
	local lua_reg = debug.getregistry or getreg
	for _, regVal in next, lua_reg() do
		if type(regVal) == "table" and #regVal then
			if rawget(regVal, "__mode") == "kvs" then
				for _, tableVal in next, regVal do
					-- We found the table containing the references.
					if tableVal == Part then
						getgenv().InstanceList = regVal
						break
					end
				end
			end
		end
	end
	-- Destroy the part.
	Part:Destroy()
	--- Allows you to clone a reference, and modify it, without the game knowing about it.
	--- @param instance Instance The instance you wish to clone.
	--- @return Instance Instance A copy of the instance.
	function cloneref(instance)
		if not getgenv().InstanceList then
			error("No instance list found on the global executor environment, Initialization error!")
		end
		for b, c in next, getgenv().InstanceList do
			if c == instance then
				getgenv().InstanceList[b] = nil
				return instance
			end
		end
	end

	getgenv().cloneref = newcclosure(cloneref)
end

--! Code extracted from codexus's misc project -> betterinit.lua
if not getgenv().gethui or not gethui then
	if sethiddenproperty then
		--- @type Instance
		local coreGuiRef = game:GetService("CoreGui")
		--- @type table | nil
		local childAddedConnections = nil
		--- @type table | nil
		local descendantAddedConnections = nil

		if getconnections then
			descendantAddedConnections = getconnections(coreGuiRef.DescendantAdded)
			childAddedConnections = getconnections(coreGuiRef.ChildAdded)
			-- Prevent game from reading the ChildAdded event in CoreGui until we are finished creating the child.
			for _, cnn in next, childAddedConnections do
				cnn:Disable() -- Disable connections...
			end

			-- Prevent game from reading the DescendantAdded event in CoreGui, to avoid them finding the gethui() folder via it.
			for _, cnn in next, descendantAddedConnections do
				cnn:Disable() -- Disable connections...
			end
		end

		local folder = Instance.new("Folder", coreGuiRef)
		folder.Name = Helpers.RandomStringGenerator(50)
		--- Avoid indexing... | PoV: Yeah this is more of a meme, it doesn't wanna work on my Fluxus install (lol)
		sethiddenproperty(folder, "RobloxLocked", true)
		if getconnections then
			-- Restore Events.
			for _, cnn in next, childAddedConnections do
				cnn:Enable() -- Enable connections...
			end
		end

		-- #region Hooks

		local huiParent = folder.Parent
		local huiName = folder.Name

		local findFirstChild = game.FindFirstChild
		local getDescendants = game.GetDescendants
		local isDescendantOf = game.IsDescendantOf
		local isAncestorOf = game.IsAncestorOf
		--- This hook watches for FindFirstChild-style attacks and more, and tries to deal with them!
		local oldNamecallFindFirstChild
		oldNamecallFindFirstChild = hookmetamethod(
			game,
			"__namecall",
			newcclosure(function(...)
				local self = select(1, ...)
				if self and not checkcaller() then
					local namecall = getnamecallmethod()
					if namecall == "FindFirstChild" then
						local args = { ... }
						local beRecursive = false
						local targetObject = nil

						if #args == 2 then
							targetObject = args[1]
							beRecursive = args[2]
						elseif #args == 1 then
							targetObject = args[1]
							beRecursive = false
						else
							-- Instantly return.
							return oldNamecallFindFirstChild(...)
						end
						if targetObject == huiName then
							return nil -- This is probably gethui()
						end

						if self == huiParent or beRecursive then
							-- This may be an attack vector, modify path!
							local found = findFirstChild(targetObject, beRecursive)

							if found == folder then -- Hide the gethui() folder.
								return nil
							else
								return found -- This is not parented to our gethui
							end
						else
							return oldNamecallFindFirstChild(...)
						end
					end

					if namecall == "WaitForChild" then
						local args = { ... }
						local targetObjectName = nil

						if #args > 0 then
							targetObjectName = args[1]
						else
							-- Instantly return, not what we expected.
							return oldNamecallFindFirstChild(...)
						end
						if targetObjectName == huiName then
							return nil -- This is probably gethui()
						end
						return oldNamecallFindFirstChild(...)
					end

					if namecall == "GetDescendants" then
						local args = { ... }

						if #args ~= 0 then
							-- Invalid parameters, GetDecendants only accepts self.
							return oldNamecallFindFirstChild(...)
						end

						-- Self is gethui or a descendant of it.
						if self == cloneref(folder) or isDescendantOf(self, cloneref(folder)) then
							return {}
						end

						return oldNamecallFindFirstChild(...)
					end
					if namecall == "GetChildren" then
						if self == cloneref(folder) or isDescendantOf(self, cloneref(folder)) then
							return nil
						else
							return oldNamecallFindFirstChild(...)
						end
					end
				end
				return oldNamecallFindFirstChild(...)
			end)
		)

		-- #endregion Hooks

		--- Returns an 'hidden' folder in CoreGui.
		--- @return Folder hiddenFolder Returns n 'hidden' folder inside CoreGui.
		function gethui()
			return folder
		end

		getgenv().gethui = newcclosure(gethui)
	else
		if not sethiddenproperty and rconsoleprint then
			rconsoleprint("[WARN] Lua Init: Cannot implement gethui! Missing sethiddenproperty")
		end
	end
end

-- #endregion Stub Declarations

-- #region Class Declarations

-- #region TweenOptions

--- Defines a class to ease working with the Library's Tweening system.
--- @class TweenOptions
local TweenOptions = {
	--- The length in seconds of the tween
	Length = 0,
	--- The easing style of the tween.
	Style = Enum.EasingStyle.Linear,
	--- The easing direction of the Tween.
	Direction = Enum.EasingDirection.Out,
	--- The goal state of the object.
	Goal = {},
	--- Metamethod meant to get the type of objects in Luau's Typeof.
	__type = "TweenOptions",
}

--- Construct a new TweenOptions class instance.
--- @param length number The length, in seconds, the tweening should take.
--- @param easingStyle Enum.EasingStyle The easing style of the Tween.
--- @param easingDirection Enum.EasingDirection The easing direction of the tween.
--- @param goal table The new parameters the object should have after tweening
--- @return TweenOptions tweenOptions The TweenOptions instance representing the given object.
function TweenOptions.new(length, easingStyle, easingDirection, goal)
	--- @type TweenOptions
	local self = {}

	self.Length = length
	self.Style = easingStyle
	self.Direction = easingDirection
	self.Goal = goal

	return setmetatable(self, TweenOptions)
end

TweenOptions = table.freeze(TweenOptions)

-- #endregion TweenOptions

-- #region Library

local Library = {
	DragSpeed = 0.07,
	MainFrameHover = false,
	Sliding = false,
	Loaded = false,
	LockDragging = false,
	ExistingColorPicker = nil,
	--- @type Library.GUI
	Gui = {
		__type = "CodexusGui",
	},
}

-- #region [LIBRARY SUBCLASS!] Library.GUI

--- Initializes a new GUI.
--- @param toggleKey Enum.KeyCode The key used to hide and show the GUI.
--- @return Library.GUI A new Library.GUI construct used to build a GUI.
function Library.Gui.new(toggleKey)
	--- @class Library.GUI
	local self = {
		TweeningToggle = false,
		ToggleKey = toggleKey,
		Hidden = false,
		CurrentTab = nil,
		CurrentTabIndex = 0,
		CurrentTheme = {
			Main = Color3.fromRGB(36, 38, 43),
			Secondary = Color3.fromRGB(22, 23, 26),
			Tertiary = Color3.fromRGB(20, 23, 25),
			Text = Color3.fromRGB(255, 255, 255),
			Controls = Color3.fromRGB(37, 40, 45),
		},
	}

	self = setmetatable(self, Library.Gui)
	return table.freeze(self)
end

Library.Gui = table.freeze(Library.Gui) -- Freeze.

-- #endregion [LIBRARY SUBCLASS!] Library.GUI

-- #endregion Library

-- #endregion Class Declarations

-- Var

local ThemeInstances = {
	["Controls"] = {},
	["MainFrame"] = nil,
	["NavFrame"] = nil,
	["Outline"] = {},
	["Label"] = {},
	["Seperators"] = {},
	["Indicators"] = {},
}

local ThemeColor = {
	Main = ColorSequence.new({
		ColorSequenceKeypoint.new(0.000, Color3.fromRGB(64, 0, 255)),
		ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 56, 42)),
	}),
	Secondary = ColorSequence.new({
		ColorSequenceKeypoint.new(0.000, Color3.fromRGB(103, 28, 28)),
		ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 76, 20)),
	}),
	Text = Color3.fromRGB(255, 153, 64),
	Controls = ColorSequence.new({
		ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 29, 38)),
		ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 24, 44)),
	}),
	Outline = Color3.fromRGB(242, 255, 0),
	Label = ColorSequence.new({
		ColorSequenceKeypoint.new(0.000, Color3.fromRGB(183, 255, 255)),
		ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 110)),
	}),
	Indicator = Color3.fromRGB(20, 23, 25),
	BaseMainColor = Color3.new(),
}

-- Lib
local LibraryFrame = {}
local TabIndex = 0

do
	--- The Ancestor of everything. The start point.
	LibraryFrame.MainScreenGui = Instance.new("ScreenGui")
	LibraryFrame.MainScreenGui.Name = Helpers.RandomStringGenerator(35)
	LibraryFrame.MainScreenGui["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
	Helpers.ProtectGui(LibraryFrame.MainScreenGui)

	--- Frame in charge of holding the GUI's Notifications.
	LibraryFrame.NotificationHolder = Instance.new("Frame", LibraryFrame.MainScreenGui)
	LibraryFrame.NotificationHolder.BorderSizePixel = 0
	LibraryFrame.NotificationHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LibraryFrame.NotificationHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	LibraryFrame.NotificationHolder.BackgroundTransparency = 1
	LibraryFrame.NotificationHolder.Size = UDim2.new(1, 0, 1, 0)
	LibraryFrame.NotificationHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
	LibraryFrame.NotificationHolder.Name = [[NotifHolder_]] .. Helpers.RandomStringGenerato(6)

	-- StarterGui.UiLib.NotifHolder.UIListLayout
	LibraryFrame.UiListLayout = Instance.new("UIListLayout", LibraryFrame.NotificationHolder)
	LibraryFrame.UiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	LibraryFrame.UiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	LibraryFrame.UiListLayout.Padding = UDim.new(0, 6)
	LibraryFrame.UiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- StarterGui.UiLib.NotifHolder.UIPadding
	LibraryFrame.Padding = Instance.new("UIPadding", LibraryFrame.NotificationHolder)
	LibraryFrame.Padding.PaddingRight = UDim.new(0, 15)
	LibraryFrame.Padding.PaddingBottom = UDim.new(0, 10)
end

--- Tweens an Object with the given parameters.
--- @param object Instance The object to tween.
--- @param options TweenOptions The options with which the object should be tweened
--- @param callback function A Callback that gets called when the operation is completed
function Library:Tween(object, options, callback)
	if typeof(callback) ~= "function" then
		error("Tweening failed. Expected Function, got '" .. typeof(callback) .. "'!")
	end

	---@diagnostic disable-next-line: invalid-class-name
	if typeof(options) ~= "TweenOptions" then -- Class name is defined on the __type metamethod, but not on global type system.
		error("Tweening failed. Expected TweenOptions, got '" .. typeof(options) .. "'!")
	end

	local tweeninfo = TweenInfo.new(options.Length, options.Style, options.Direction)

	local Tween = TweenService:Create(object, tweeninfo, options.Goal)
	Tween:Play()

	if callback then
		Tween.Completed:Connect(function()
			callback()
		end)
	end

	return Tween
end

function Library:Place_Defaults(defaults, options)
	defaults = defaults or {}
	options = options or {}
	for option, value in next, options do
		defaults[option] = value
	end

	return defaults
end

--- Resizes a Canvas given the number of children Frame(s) it contains.
--- @return Tween tweenObject The tween that represents the resizing "animation"
function Library:ResizeCanvas(Tab)
	local numberOfChildren = 0
	local ChildOffset = 0

	--- @type Instance
	for _, v in pairs(Tab:GetChildren()) do
		if v:IsA("Frame") then
			--- @type Frame
			local frame = v
			numberOfChildren += 1
			ChildOffset = ChildOffset + frame.Size.Y.Offset
		end
	end

	local NumChildOffset = numberOfChildren * 8

	local CanvasSizeY = NumChildOffset + ChildOffset + 22

	return Library:Tween(Tab, {
		Length = 0.5,
		Goal = { CanvasSize = UDim2.new(0, 0, 0, CanvasSizeY) },
	})
end

function Library:ToolTip(Text)
	local ToolTip = {}

	do
		-- The text label that represesnts the tooltip.
		ToolTip.TextLabel = Instance.new("TextLabel", LibraryFrame.MainScreenGui)
		ToolTip.TextLabel.BorderSizePixel = 0
		ToolTip.TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		ToolTip.TextLabel.TextSize = 12
		ToolTip.TextLabel.Text = Text
		ToolTip.TextLabel.TextColor3 = Color3.new(1, 1, 1)
		ToolTip.TextLabel.Size = UDim2.new(0, 68, 0, 18)
		ToolTip.TextLabel.Name = [[ToolTip]]
		ToolTip.TextLabel.Font = Enum.Font.Gotham
		ToolTip.TextLabel.BackgroundTransparency = 0.5
		ToolTip.TextLabel.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
	end

	local Bound = TextService:GetTextSize(
		ToolTip.TextLabel.Text,
		ToolTip.TextLabel.TextSize,
		ToolTip.TextLabel.Font,
		Vector2.new(ToolTip.TextLabel.AbsoluteSize.X, ToolTip.TextLabel.AbsoluteSize.Y)
	)
	ToolTip.TextLabel.Size = UDim2.new(0, (Bound.X + 28), 0, 18)

	local RSSync = RunService.Heartbeat:Connect(function()
		ToolTip.TextLabel.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
	end)

	function ToolTip:Destroy()
		RSSync:Disconnect()
		ToolTip.TextLabel:Destroy()
	end

	return ToolTip
end

function Library:ColorPicker(Callback, DefaultColor)
	local ColorPicker = {
		ColorH = 1,
		ColorS = 1,
		ColorV = 1,
		OldVal = nil,
		Hover = false,
	}

	if Library.ExistingColorPicker ~= nil then
		Library.ExistingColorPicker:Destroy()
	end

	do
		-- StarterGui.UiLib.ColorPicker
		ColorPicker["72"] = Instance.new("Frame", LibraryFrame.MainScreenGui)
		ColorPicker["72"]["ZIndex"] = 2
		ColorPicker["72"]["BorderSizePixel"] = 0
		ColorPicker["72"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["72"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
		ColorPicker["72"]["Size"] = UDim2.new(0, 270, 0, 311)
		ColorPicker["72"]["Position"] = UDim2.new(0.8289999961853027, 0, 0.5, 0)
		ColorPicker["72"]["Name"] = [[ColorPicker]]

		Library.ExistingColorPicker = ColorPicker["72"]

		-- StarterGui.UiLib.ColorPicker.UIGradient
		ColorPicker["73"] = Instance.new("UIGradient", ColorPicker["72"])
		ColorPicker["73"]["Rotation"] = 90
		ColorPicker["73"]["Color"] = ThemeColor.Controls

		ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = ColorPicker["73"]

		-- StarterGui.UiLib.ColorPicker.UICorner
		ColorPicker["74"] = Instance.new("UICorner", ColorPicker["72"])
		ColorPicker["74"]["CornerRadius"] = UDim.new(0, 4)

		-- StarterGui.UiLib.ColorPicker.Color
		ColorPicker["75"] = Instance.new("ImageLabel", ColorPicker["72"])
		ColorPicker["75"]["ZIndex"] = 10
		ColorPicker["75"]["BackgroundColor3"] = Color3.fromRGB(255, 4, 8)
		ColorPicker["75"]["AnchorPoint"] = Vector2.new(0.5, 0)
		ColorPicker["75"]["Image"] = [[rbxassetid://4155801252]]
		ColorPicker["75"]["Size"] = UDim2.new(0, 212, 0, 239)
		ColorPicker["75"]["Name"] = [[Color]]
		ColorPicker["75"]["Position"] = UDim2.new(0, 122, 0, 15)

		-- StarterGui.UiLib.ColorPicker.Color.ColorCorner
		ColorPicker["76"] = Instance.new("UICorner", ColorPicker["75"])
		ColorPicker["76"]["Name"] = [[ColorCorner]]
		ColorPicker["76"]["CornerRadius"] = UDim.new(0, 3)

		-- StarterGui.UiLib.ColorPicker.Color.ColorSelection
		ColorPicker["77"] = Instance.new("ImageLabel", ColorPicker["75"])
		ColorPicker["77"]["BorderSizePixel"] = 0
		ColorPicker["77"]["ScaleType"] = Enum.ScaleType.Fit
		ColorPicker["77"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["77"]["BorderMode"] = Enum.BorderMode.Inset
		ColorPicker["77"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
		ColorPicker["77"]["Image"] = [[http://www.roblox.com/asset/?id=4805639000]]
		ColorPicker["77"]["Size"] = UDim2.new(0, 18, 0, 18)
		ColorPicker["77"]["Name"] = [[ColorSelection]]
		ColorPicker["77"]["BackgroundTransparency"] = 1
		ColorPicker["77"]["Position"] = UDim2.new(0.8784236311912537, 0, 0.16129031777381897, 0)

		-- StarterGui.UiLib.ColorPicker.Hue
		ColorPicker["78"] = Instance.new("ImageLabel", ColorPicker["72"])
		ColorPicker["78"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["78"]["AnchorPoint"] = Vector2.new(0.5, 0)
		ColorPicker["78"]["Size"] = UDim2.new(0, 14, 0, 239)
		ColorPicker["78"]["Name"] = [[Hue]]
		ColorPicker["78"]["Position"] = UDim2.new(0, 249, 0, 15)

		-- StarterGui.UiLib.ColorPicker.Hue.HueCorner
		ColorPicker["79"] = Instance.new("UICorner", ColorPicker["78"])
		ColorPicker["79"]["Name"] = [[HueCorner]]
		ColorPicker["79"]["CornerRadius"] = UDim.new(0, 3)

		-- StarterGui.UiLib.ColorPicker.Hue.HueGradient
		ColorPicker["7a"] = Instance.new("UIGradient", ColorPicker["78"])
		ColorPicker["7a"]["Name"] = [[HueGradient]]
		ColorPicker["7a"]["Rotation"] = 270
		ColorPicker["7a"]["Color"] = ColorSequence.new({
			ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 5)),
			ColorSequenceKeypoint.new(0.087, Color3.fromRGB(239, 0, 255)),
			ColorSequenceKeypoint.new(0.230, Color3.fromRGB(18, 0, 255)),
			ColorSequenceKeypoint.new(0.443, Color3.fromRGB(3, 176, 255)),
			ColorSequenceKeypoint.new(0.582, Color3.fromRGB(167, 255, 0)),
			ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 26, 26)),
		})

		-- StarterGui.UiLib.ColorPicker.Hue.ColorSelection
		ColorPicker["7b"] = Instance.new("ImageLabel", ColorPicker["78"])
		ColorPicker["7b"]["BorderSizePixel"] = 0
		ColorPicker["7b"]["ScaleType"] = Enum.ScaleType.Fit
		ColorPicker["7b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["7b"]["BorderMode"] = Enum.BorderMode.Inset
		ColorPicker["7b"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
		ColorPicker["7b"]["Image"] = [[http://www.roblox.com/asset/?id=4805639000]]
		ColorPicker["7b"]["Size"] = UDim2.new(0, 18, 0, 18)
		ColorPicker["7b"]["Name"] = [[ColorSelection]]
		ColorPicker["7b"]["BackgroundTransparency"] = 1
		ColorPicker["7b"]["Position"] = UDim2.new(0.44985219836235046, 0, 0.15198799967765808, 0)

		-- StarterGui.UiLib.ColorPicker.Textboxes
		ColorPicker["7c"] = Instance.new("Frame", ColorPicker["72"])
		ColorPicker["7c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["7c"]["BackgroundTransparency"] = 1
		ColorPicker["7c"]["Size"] = UDim2.new(0, 270, 0, 42)
		ColorPicker["7c"]["Position"] = UDim2.new(0, 0, 0, 262)
		ColorPicker["7c"]["Name"] = [[Textboxes]]

		-- StarterGui.UiLib.ColorPicker.Textboxes.HEX
		ColorPicker["7d"] = Instance.new("TextBox", ColorPicker["7c"])
		ColorPicker["7d"]["CursorPosition"] = -1
		ColorPicker["7d"]["ZIndex"] = 2
		ColorPicker["7d"]["TextColor3"] = ThemeColor.Text
		ColorPicker["7d"]["TextSize"] = 11
		ColorPicker["7d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
		ColorPicker["7d"]["LayoutOrder"] = 1
		ColorPicker["7d"]["BackgroundTransparency"] = 1
		ColorPicker["7d"]["Size"] = UDim2.new(0, 79, 0, 21)
		ColorPicker["7d"]["Text"] = [[#ef2424]]
		ColorPicker["7d"]["Position"] = UDim2.new(0.03333333134651184, 0, -0.007427334785461426, 0)
		ColorPicker["7d"]["Font"] = Enum.Font.Gotham
		ColorPicker["7d"]["Name"] = [[HEX]]
		ColorPicker["7d"]["ClearTextOnFocus"] = false

		-- StarterGui.UiLib.ColorPicker.Textboxes.HEX.UICorner
		ColorPicker["7e"] = Instance.new("UICorner", ColorPicker["7d"])
		ColorPicker["7e"]["CornerRadius"] = UDim.new(0, 3)

		-- StarterGui.UiLib.ColorPicker.Textboxes.HEX.UIStroke
		ColorPicker["7f"] = Instance.new("UIStroke", ColorPicker["7d"])
		ColorPicker["7f"]["Color"] = ThemeColor.Text
		ColorPicker["7f"]["Transparency"] = 0.699999988079071
		ColorPicker["7f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border

		ThemeInstances["Seperators"][#ThemeInstances["Seperators"] + 1] = ColorPicker["7f"]

		-- StarterGui.UiLib.ColorPicker.Textboxes.R
		ColorPicker["80"] = Instance.new("TextBox", ColorPicker["7c"])
		ColorPicker["80"]["CursorPosition"] = -1
		ColorPicker["80"]["ZIndex"] = 2
		ColorPicker["80"]["TextColor3"] = ThemeColor.Text
		ColorPicker["80"]["TextSize"] = 11
		ColorPicker["80"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
		ColorPicker["80"]["LayoutOrder"] = 2
		ColorPicker["80"]["BackgroundTransparency"] = 1
		ColorPicker["80"]["Size"] = UDim2.new(0, 47, 0, 21)
		ColorPicker["80"]["Text"] = [[209]]
		ColorPicker["80"]["Position"] = UDim2.new(0.35185185074806213, 0, -0.007426868658512831, 0)
		ColorPicker["80"]["Font"] = Enum.Font.Gotham
		ColorPicker["80"]["Name"] = [[H]]
		ColorPicker["80"]["ClearTextOnFocus"] = false

		-- StarterGui.UiLib.ColorPicker.Textboxes.R.UICorner
		ColorPicker["81"] = Instance.new("UICorner", ColorPicker["80"])
		ColorPicker["81"]["CornerRadius"] = UDim.new(0, 3)

		-- StarterGui.UiLib.ColorPicker.Textboxes.R.UIStroke
		ColorPicker["82"] = Instance.new("UIStroke", ColorPicker["80"])
		ColorPicker["82"]["Color"] = ThemeColor.Text
		ColorPicker["82"]["Transparency"] = 0.699999988079071
		ColorPicker["82"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border

		ThemeInstances["Seperators"][#ThemeInstances["Seperators"] + 1] = ColorPicker["82"]

		-- StarterGui.UiLib.ColorPicker.Textboxes.G
		ColorPicker["83"] = Instance.new("TextBox", ColorPicker["7c"])
		ColorPicker["83"]["CursorPosition"] = -1
		ColorPicker["83"]["ZIndex"] = 2
		ColorPicker["83"]["TextColor3"] = ThemeColor.Text
		ColorPicker["83"]["TextSize"] = 11
		ColorPicker["83"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
		ColorPicker["83"]["LayoutOrder"] = 2
		ColorPicker["83"]["BackgroundTransparency"] = 1
		ColorPicker["83"]["Size"] = UDim2.new(0, 47, 0, 21)
		ColorPicker["83"]["Text"] = [[2]]
		ColorPicker["83"]["Position"] = UDim2.new(0.5666666626930237, 0, -0.007426868658512831, 0)
		ColorPicker["83"]["Font"] = Enum.Font.Gotham
		ColorPicker["83"]["Name"] = [[S]]
		ColorPicker["83"]["ClearTextOnFocus"] = false

		-- StarterGui.UiLib.ColorPicker.Textboxes.G.UICorner
		ColorPicker["84"] = Instance.new("UICorner", ColorPicker["83"])
		ColorPicker["84"]["CornerRadius"] = UDim.new(0, 3)

		-- StarterGui.UiLib.ColorPicker.Textboxes.G.UIStroke
		ColorPicker["85"] = Instance.new("UIStroke", ColorPicker["83"])
		ColorPicker["85"]["Color"] = ThemeColor.Text
		ColorPicker["85"]["Transparency"] = 0.699999988079071
		ColorPicker["85"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border

		ThemeInstances["Seperators"][#ThemeInstances["Seperators"] + 1] = ColorPicker["85"]

		-- StarterGui.UiLib.ColorPicker.Textboxes.B
		ColorPicker["86"] = Instance.new("TextBox", ColorPicker["7c"])
		ColorPicker["86"]["CursorPosition"] = -1
		ColorPicker["86"]["ZIndex"] = 2
		ColorPicker["86"]["TextColor3"] = ThemeColor.Text
		ColorPicker["86"]["TextSize"] = 11
		ColorPicker["86"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
		ColorPicker["86"]["LayoutOrder"] = 2
		ColorPicker["86"]["BackgroundTransparency"] = 1
		ColorPicker["86"]["Size"] = UDim2.new(0, 47, 0, 21)
		ColorPicker["86"]["Text"] = [[7]]
		ColorPicker["86"]["Position"] = UDim2.new(0.7814815044403076, 0, -0.007426868658512831, 0)
		ColorPicker["86"]["Font"] = Enum.Font.Gotham
		ColorPicker["86"]["Name"] = [[V]]
		ColorPicker["86"]["ClearTextOnFocus"] = false

		-- StarterGui.UiLib.ColorPicker.Textboxes.B.UICorner
		ColorPicker["87"] = Instance.new("UICorner", ColorPicker["86"])
		ColorPicker["87"]["CornerRadius"] = UDim.new(0, 3)

		-- StarterGui.UiLib.ColorPicker.Textboxes.B.UIStroke
		ColorPicker["88"] = Instance.new("UIStroke", ColorPicker["86"])
		ColorPicker["88"]["Color"] = ThemeColor.Text
		ColorPicker["88"]["Transparency"] = 0.699999988079071
		ColorPicker["88"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border

		ThemeInstances["Seperators"][#ThemeInstances["Seperators"] + 1] = ColorPicker["88"]

		-- StarterGui.UiLib.ColorPicker.Textboxes.UIListLayout
		ColorPicker["89"] = Instance.new("UIListLayout", ColorPicker["7c"])
		ColorPicker["89"]["FillDirection"] = Enum.FillDirection.Horizontal
		ColorPicker["89"]["Padding"] = UDim.new(0, 7)
		ColorPicker["89"]["SortOrder"] = Enum.SortOrder.LayoutOrder

		-- StarterGui.UiLib.ColorPicker.Textboxes.UIPadding
		ColorPicker["8a"] = Instance.new("UIPadding", ColorPicker["7c"])
		ColorPicker["8a"]["PaddingLeft"] = UDim.new(0, 16)

		-- StarterGui.UiLib.ColorPicker.TextLabels
		ColorPicker["8b"] = Instance.new("Frame", ColorPicker["72"])
		ColorPicker["8b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["8b"]["BackgroundTransparency"] = 1
		ColorPicker["8b"]["Size"] = UDim2.new(0, 270, 0, 28)
		ColorPicker["8b"]["Position"] = UDim2.new(0, 0, 0, 281)
		ColorPicker["8b"]["Name"] = [[TextLabels]]

		-- StarterGui.UiLib.ColorPicker.TextLabels.UIListLayout
		ColorPicker["8c"] = Instance.new("UIListLayout", ColorPicker["8b"])
		ColorPicker["8c"]["FillDirection"] = Enum.FillDirection.Horizontal
		ColorPicker["8c"]["Padding"] = UDim.new(0, 7)
		ColorPicker["8c"]["SortOrder"] = Enum.SortOrder.LayoutOrder

		-- StarterGui.UiLib.ColorPicker.TextLabels.UIPadding
		ColorPicker["8d"] = Instance.new("UIPadding", ColorPicker["8b"])
		ColorPicker["8d"]["PaddingLeft"] = UDim.new(0, 16)

		-- StarterGui.UiLib.ColorPicker.TextLabels.R
		ColorPicker["8e"] = Instance.new("TextLabel", ColorPicker["8b"])
		ColorPicker["8e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["8e"]["TextTransparency"] = 0.699999988079071
		ColorPicker["8e"]["TextSize"] = 11
		ColorPicker["8e"]["TextColor3"] = ThemeColor.Text
		ColorPicker["8e"]["LayoutOrder"] = 2
		ColorPicker["8e"]["Size"] = UDim2.new(0, 47, 0, 21)
		ColorPicker["8e"]["Text"] = [[H]]
		ColorPicker["8e"]["Name"] = [[H]]
		ColorPicker["8e"]["Font"] = Enum.Font.GothamMedium
		ColorPicker["8e"]["BackgroundTransparency"] = 1

		-- StarterGui.UiLib.ColorPicker.TextLabels.HEX
		ColorPicker["8f"] = Instance.new("TextLabel", ColorPicker["8b"])
		ColorPicker["8f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["8f"]["TextTransparency"] = 0.699999988079071
		ColorPicker["8f"]["TextSize"] = 11
		ColorPicker["8f"]["TextColor3"] = ThemeColor.Text
		ColorPicker["8f"]["Size"] = UDim2.new(0, 79, 0, 21)
		ColorPicker["8f"]["Text"] = [[HEX]]
		ColorPicker["8f"]["Name"] = [[HEX]]
		ColorPicker["8f"]["Font"] = Enum.Font.GothamMedium
		ColorPicker["8f"]["BackgroundTransparency"] = 1

		-- StarterGui.UiLib.ColorPicker.TextLabels.G
		ColorPicker["90"] = Instance.new("TextLabel", ColorPicker["8b"])
		ColorPicker["90"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["90"]["TextTransparency"] = 0.699999988079071
		ColorPicker["90"]["TextSize"] = 11
		ColorPicker["90"]["TextColor3"] = ThemeColor.Text
		ColorPicker["90"]["LayoutOrder"] = 2
		ColorPicker["90"]["Size"] = UDim2.new(0, 47, 0, 21)
		ColorPicker["90"]["Text"] = [[S]]
		ColorPicker["90"]["Name"] = [[S]]
		ColorPicker["90"]["Font"] = Enum.Font.GothamMedium
		ColorPicker["90"]["BackgroundTransparency"] = 1

		-- StarterGui.UiLib.ColorPicker.TextLabels.B
		ColorPicker["91"] = Instance.new("TextLabel", ColorPicker["8b"])
		ColorPicker["91"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		ColorPicker["91"]["TextTransparency"] = 0.699999988079071
		ColorPicker["91"]["TextSize"] = 11
		ColorPicker["91"]["TextColor3"] = ThemeColor.Text
		ColorPicker["91"]["LayoutOrder"] = 2
		ColorPicker["91"]["Size"] = UDim2.new(0, 47, 0, 21)
		ColorPicker["91"]["Text"] = [[V]]
		ColorPicker["91"]["Name"] = [[V]]
		ColorPicker["91"]["Font"] = Enum.Font.GothamMedium
		ColorPicker["91"]["BackgroundTransparency"] = 1

		-- StarterGui.UiLib.ColorPicker.TextButton
		ColorPicker["92"] = Instance.new("TextButton", ColorPicker["72"])
		ColorPicker["92"]["ZIndex"] = 3
		ColorPicker["92"]["BorderSizePixel"] = 0
		ColorPicker["92"]["TextSize"] = 14
		ColorPicker["92"]["BackgroundColor3"] = Color3.fromRGB(219, 0, 0)
		ColorPicker["92"]["TextColor3"] = ThemeColor.Text
		ColorPicker["92"]["Size"] = UDim2.new(0, 8, 0, 8)
		ColorPicker["92"]["Text"] = [[]]
		ColorPicker["92"]["Font"] = Enum.Font.SourceSans
		ColorPicker["92"]["Position"] = UDim2.new(0, 266, 0, -3)

		-- StarterGui.UiLib.ColorPicker.TextButton.UICorner
		ColorPicker["93"] = Instance.new("UICorner", ColorPicker["92"])
	end

	do
		local SelectingColor
		function ColorPicker:updateTextboxVal()
			ColorPicker["80"]["Text"] = math.floor(ColorPicker.ColorH * 256)
			ColorPicker["83"]["Text"] = math.floor(ColorPicker.ColorS * 256)
			ColorPicker["86"]["Text"] = math.floor(ColorPicker.ColorV * 256)

			ColorPicker["7d"].Text = ColorPicker.OldVal:ToHex()
		end

		function ColorPicker:UpdateColorPicker()
			Library:Tween(ColorPicker["75"], {
				Length = 0.5,
				Goal = { BackgroundColor3 = Color3.fromHSV(ColorPicker.ColorH, 1, 1) },
			})
			pcall(function()
				if ColorPicker.OldVal ~= Color3.fromHSV(ColorPicker.ColorH, ColorPicker.ColorS, ColorPicker.ColorV) then
					Callback(Color3.fromHSV(ColorPicker.ColorH, ColorPicker.ColorS, ColorPicker.ColorV))
				end
			end)
			ColorPicker.OldVal = Color3.fromHSV(ColorPicker.ColorH, ColorPicker.ColorS, ColorPicker.ColorV)
			ColorPicker:updateTextboxVal()
		end

		function ColorPicker:SetColor(Color)
			local H, S, V = Color:ToHSV()
			ColorPicker.ColorH = H
			ColorPicker.ColorS = S
			ColorPicker.ColorV = V

			Library:Tween(ColorPicker["7b"], {
				Length = 0,
				Goal = { Position = UDim2.new(0.5, 0, H, 0) },
			})

			local VisualColorY = 1 - ColorPicker.ColorV

			Library:Tween(ColorPicker["77"], {
				Length = 0,
				Goal = { Position = UDim2.new(ColorPicker.ColorS, 0, VisualColorY, 0) },
			})
			ColorPicker:UpdateColorPicker()
		end

		ColorPicker["75"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if SelectingColor then
					SelectingColor:Disconnect()
				end

				Library.Sliding = true
				SelectingColor = RunService.RenderStepped:Connect(function()
					local ColorX = (
						math.clamp(Mouse.X - ColorPicker["75"].AbsolutePosition.X, 0, ColorPicker["75"].AbsoluteSize.X)
						/ ColorPicker["75"].AbsoluteSize.X
					)
					local ColorY = (
						math.clamp(Mouse.Y - ColorPicker["75"].AbsolutePosition.Y, 0, ColorPicker["75"].AbsoluteSize.Y)
						/ ColorPicker["75"].AbsoluteSize.Y
					)
					ColorPicker["77"].Position = UDim2.new(ColorX, 0, ColorY, 0)
					ColorPicker.ColorS = ColorX
					ColorPicker.ColorV = 1 - ColorY
					ColorPicker:UpdateColorPicker()
				end)
			end
		end)

		ColorPicker["75"].InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if SelectingColor then
					SelectingColor:Disconnect()
				end
				Library.Sliding = false
			end
		end)

		local SelectingHue

		ColorPicker["78"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if SelectingHue then
					SelectingHue:Disconnect()
				end

				Library.Sliding = true
				SelectingHue = RunService.RenderStepped:Connect(function()
					local HueY = (
						1
						- math.clamp(
								Mouse.Y - ColorPicker["78"].AbsolutePosition.Y,
								0,
								ColorPicker["78"].AbsoluteSize.Y
							)
							/ ColorPicker["78"].AbsoluteSize.Y
					)
					local VisualHueY = (
						math.clamp(Mouse.Y - ColorPicker["78"].AbsolutePosition.Y, 0, ColorPicker["78"].AbsoluteSize.Y)
						/ ColorPicker["78"].AbsoluteSize.Y
					)

					ColorPicker["7b"].Position = UDim2.new(0.5, 0, VisualHueY, 0)
					ColorPicker.ColorH = 1 - HueY

					ColorPicker:UpdateColorPicker()
				end)
			end
		end)

		ColorPicker["78"].InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if SelectingHue then
					SelectingHue:Disconnect()
				end
				Library.Sliding = false
			end
		end)

		local function checkHex(hex)
			local success, result = pcall(function()
				return Color3.fromHex(hex)
			end)

			return success
		end

		local function checkValidHSV(hsv)
			if hsv >= 0 and hsv <= 1 then
				return true
			else
				return false
			end
		end

		ColorPicker["7d"].FocusLost:Connect(function()
			local HexCode = ColorPicker["7d"].Text
			local isHex = checkHex(HexCode)
			if isHex then
				ColorPicker:SetColor(Color3.fromHex(HexCode))
			else
				ColorPicker:updateTextboxVal()
			end
		end)

		ColorPicker["80"].FocusLost:Connect(function()
			local numVal
			local success = pcall(function()
				local ColorCode = tonumber(ColorPicker["80"].Text)
				ColorCode = ColorCode / 256
				local valid = checkValidHSV(ColorCode)

				if valid then
					ColorPicker:SetColor(Color3.fromHSV(ColorCode, ColorPicker.ColorS, ColorPicker.ColorV))
				else
					ColorPicker:updateTextboxVal()
				end
			end)

			if not success then
				ColorPicker:updateTextboxVal()
			end
		end)

		ColorPicker["83"].FocusLost:Connect(function()
			local numVal
			local success = pcall(function()
				local ColorCode = tonumber(ColorPicker["83"].Text)
				ColorCode = ColorCode / 256
				local valid = checkValidHSV(ColorCode)

				if valid then
					ColorPicker:SetColor(Color3.fromHSV(ColorPicker.ColorH, ColorCode, ColorPicker.ColorV))
				else
					ColorPicker:updateTextboxVal()
				end
			end)

			if not success then
				ColorPicker:updateTextboxVal()
			end
		end)

		ColorPicker["86"].FocusLost:Connect(function()
			local numVal
			local success = pcall(function()
				local ColorCode = tonumber(ColorPicker["86"].Text)
				ColorCode = ColorCode / 256
				local valid = checkValidHSV(ColorCode)

				if valid then
					ColorPicker:SetColor(Color3.fromHSV(ColorPicker.ColorH, ColorPicker.ColorS, ColorCode))
				else
					ColorPicker:updateTextboxVal()
				end
			end)

			if not success then
				ColorPicker:updateTextboxVal()
			end
		end)

		ColorPicker:SetColor(DefaultColor)
	end

	ColorPicker["92"].MouseButton1Click:Connect(function()
		ColorPicker["72"]:Destroy()
		Library.ExistingColorPicker = nil
	end)

	ColorPicker["72"].MouseEnter:Connect(function()
		ColorPicker.Hover = true
	end)

	ColorPicker["72"].MouseLeave:Connect(function()
		ColorPicker.Hover = false
	end)

	UserInputService.InputBegan:Connect(function(input)
		if ColorPicker.Hover then
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not Library.Sliding then
				local ObjectPosition = Vector2.new(
					Mouse.X - ColorPicker["72"].AbsolutePosition.X,
					Mouse.Y - ColorPicker["72"].AbsolutePosition.Y
				)
				while
					RunService.RenderStepped:wait()
					and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
				do
					if not Library.Sliding then
						if Library.LockDragging then
							local FrameX, FrameY =
								math.clamp(
									Mouse.X - ObjectPosition.X,
									0,
									LibraryFrame.MainScreenGui.AbsoluteSize.X - ColorPicker["72"].AbsoluteSize.X
								),
								math.clamp(
									Mouse.Y - ObjectPosition.Y,
									0,
									LibraryFrame.MainScreenGui.AbsoluteSize.Y - ColorPicker["72"].AbsoluteSize.Y
								)

							Library:Tween(ColorPicker["72"], {
								Goal = {
									Position = UDim2.fromOffset(
										FrameX + (ColorPicker["72"].Size.X.Offset * ColorPicker["72"].AnchorPoint.X),
										FrameY + (ColorPicker["72"].Size.Y.Offset * ColorPicker["72"].AnchorPoint.Y)
									),
								},
								Style = Enum.EasingStyle.Linear,
								Direction = Enum.EasingDirection.InOut,
								Length = Library.DragSpeed,
							})
						else
							Library:Tween(ColorPicker["72"], {
								Goal = {
									Position = UDim2.fromOffset(
										Mouse.X
											- ObjectPosition.X
											+ (ColorPicker["72"].Size.X.Offset * ColorPicker["72"].AnchorPoint.X),
										Mouse.Y
											- ObjectPosition.Y
											+ (ColorPicker["72"].Size.Y.Offset * ColorPicker["72"].AnchorPoint.Y)
									),
								},
								Style = Enum.EasingStyle.Linear,
								Direction = Enum.EasingDirection.InOut,
								Length = Library.DragSpeed,
							})
						end
					end
				end
			end
		end
	end)
end

function Library:CalGradient(BaseColor)
	local h, s, v = BaseColor:ToHSV()

	local p0 = Color3.fromHSV(h, s, v)
	local p1

	if (v - 0.05) < 0 then
		p1 = Color3.fromHSV(h, s, 0)
	else
		p1 = Color3.fromHSV(h, s, v - 0.05)
	end

	return ColorSequence.new({ ColorSequenceKeypoint.new(0.000, p0), ColorSequenceKeypoint.new(1.000, p1) })
end

function Library:CalControlsGradient(BaseColor)
	local h, s, v = BaseColor:ToHSV()

	local p0 = Color3.fromHSV(h, s, v)
	local p1

	if (v - 0.02) < 0 then
		p1 = Color3.fromHSV(h, s, 0)
	else
		p1 = Color3.fromHSV(h, s, v - 0.02)
	end

	return ColorSequence.new({ ColorSequenceKeypoint.new(0.000, p0), ColorSequenceKeypoint.new(1.000, p1) })
end

function Library:Destroy()
	LibraryFrame.MainScreenGui:Destroy()
end

function Library:Create(options)
	options = Library:Place_Defaults({
		ToggleKey = Enum.KeyCode.Insert,
	}, options or {})

	local Gui = {
		TweeningToggle = false,
		ToggleKey = options.ToggleKey,
		Hidden = false,
		CurrentTab = nil,
		CurrentTabIndex = 0,
		CurrentTheme = {
			Main = Color3.fromRGB(36, 38, 43),
			Secondary = Color3.fromRGB(22, 23, 26),
			Tertiary = Color3.fromRGB(20, 23, 25),
			Text = Color3.fromRGB(255, 255, 255),
			Controls = Color3.fromRGB(37, 40, 45),
		},
	}

	function Gui:Notify(options)
		options = Library:Place_Defaults({
			Name = "Ring Ring",
			Text = "Notification!!",
			Duration = 5,
			Callback = function()
				return
			end,
		}, options or {})

		local Notification = {}

		do
			-- StarterGui.UiLib.NotifHolder.Notification
			Notification["98"] = Instance.new("Frame", LibraryFrame.NotificationHolder)
			Notification["98"]["BorderSizePixel"] = 0
			Notification["98"]["BackgroundColor3"] = ThemeColor.BaseMainColor
			Notification["98"]["BackgroundTransparency"] = 0.15000000596046448
			Notification["98"]["Size"] = UDim2.new(0, 229, 0, 0)
			Notification["98"]["Position"] = UDim2.new(0.8442176580429077, 0, 0.9055851101875305, 0)
			Notification["98"]["Name"] = [[Notification]]
			Notification["98"]["ClipsDescendants"] = true

			-- StarterGui.UiLib.NotifHolder.Notification.TopBar
			Notification["99"] = Instance.new("Frame", Notification["98"])
			Notification["99"]["BorderSizePixel"] = 0
			Notification["99"]["BackgroundColor3"] = ThemeColor.BaseMainColor
			Notification["99"]["Size"] = UDim2.new(0, 229, 0, 19)
			Notification["99"]["Name"] = [[TopBar]]

			-- StarterGui.UiLib.NotifHolder.Notification.ProgressBottom
			Notification["9a"] = Instance.new("Frame", Notification["98"])
			Notification["9a"]["BorderSizePixel"] = 0
			Notification["9a"]["BackgroundColor3"] = ThemeColor.BaseMainColor
			Notification["9a"]["BackgroundTransparency"] = 0.800000011920929
			Notification["9a"]["Size"] = UDim2.new(0, 211, 0, 3)
			Notification["9a"]["Position"] = UDim2.new(0.0393013097345829, 0, 0.8802816867828369, 0)
			Notification["9a"]["Name"] = [[ProgressBottom]]

			-- StarterGui.UiLib.NotifHolder.Notification.ProgressBottom.Frame
			Notification["9b"] = Instance.new("Frame", Notification["9a"])
			Notification["9b"]["BorderSizePixel"] = 0
			Notification["9b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
			Notification["9b"]["Size"] = UDim2.new(0, 0, 1, 0)

			-- StarterGui.UiLib.NotifHolder.Notification.TextLabel
			Notification["9c"] = Instance.new("TextLabel", Notification["98"])
			Notification["9c"]["TextWrapped"] = true
			Notification["9c"]["TextXAlignment"] = Enum.TextXAlignment.Left
			Notification["9c"]["TextYAlignment"] = Enum.TextYAlignment.Top
			Notification["9c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
			Notification["9c"]["TextSize"] = 11
			Notification["9c"]["TextColor3"] = ThemeColor.Text
			Notification["9c"]["Size"] = UDim2.new(0, 216, 0, 36)
			Notification["9c"]["Text"] = options.Text
			Notification["9c"]["Font"] = Enum.Font.Gotham
			Notification["9c"]["BackgroundTransparency"] = 1
			Notification["9c"]["Position"] = UDim2.new(0, 9, 0, 21)

			-- StarterGui.UiLib.NotifHolder.Notification.NameLabel
			Notification["9d"] = Instance.new("TextLabel", Notification["98"])
			Notification["9d"]["TextWrapped"] = true
			Notification["9d"]["TextXAlignment"] = Enum.TextXAlignment.Left
			Notification["9d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
			Notification["9d"]["TextSize"] = 9
			Notification["9d"]["TextColor3"] = ThemeColor.Text
			Notification["9d"]["Size"] = UDim2.new(0, 221, 0, 19)
			Notification["9d"]["Text"] = options.Name
			Notification["9d"]["Name"] = [[NameLabel]]
			Notification["9d"]["Font"] = Enum.Font.GothamBold
			Notification["9d"]["BackgroundTransparency"] = 1
			Notification["9d"]["Position"] = UDim2.new(0.034934498369693756, 0, 0, 0)
		end

		do
			local Completed = false

			Library:Tween(Notification["98"], {
				Length = 0.5,
				Goal = { Size = UDim2.new(0, 229, 0, 71) },
			})

			Library:Tween(Notification["9b"], {
				Length = options.Duration,
				Style = Enum.EasingStyle.Linear,
				Goal = { Size = UDim2.new(1, 0, 1, 0) },
			}, function()
				Completed = true
			end)

			repeat
				task.wait()
			until Completed

			local Completed = false

			Library:Tween(Notification["98"], {
				Length = 0.5,
				Goal = { Size = UDim2.new(0, 229, 0, 0) },
			}, function()
				Completed = true
			end)

			repeat
				task.wait()
			until Completed

			options.Callback()
			Notification["98"]:Destroy()
		end

		return Notification
	end

	do
		-- StarterGui.UiLib.Frame
		Gui["2"] = Instance.new("Frame", LibraryFrame.MainScreenGui)
		Gui["2"]["BorderSizePixel"] = 0
		Gui["2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["2"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
		Gui["2"]["BackgroundTransparency"] = 1
		Gui["2"]["Size"] = UDim2.new(0, 0, 0, 0)
		Gui["2"]["Position"] = UDim2.new(0.5, 0, 0.5, 0)
		Gui["2"]["ClipsDescendants"] = true

		-- StarterGui.UiLib.Frame.MainFrame
		Gui["3"] = Instance.new("Frame", Gui["2"])
		Gui["3"]["BorderSizePixel"] = 0
		Gui["3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["3"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
		Gui["3"]["Size"] = UDim2.new(0, 596, 0, 433)
		Gui["3"]["Position"] = UDim2.new(0, 347, 0, 216)
		Gui["3"]["Name"] = [[MainFrame]]

		-- StarterGui.UiLib.Frame.MainFrame.UICorner
		Gui["4"] = Instance.new("UICorner", Gui["3"])
		Gui["4"]["CornerRadius"] = UDim.new(0, 6)

		-- StarterGui.UiLib.Frame.MainFrame.Seperator
		Gui["5"] = Instance.new("Frame", Gui["3"])
		Gui["5"]["BorderSizePixel"] = 0
		Gui["5"]["BackgroundColor3"] = ThemeColor.Text
		Gui["5"]["BackgroundTransparency"] = 0.8999999761581421
		Gui["5"]["Size"] = UDim2.new(0, 596, 0, 1)
		Gui["5"]["Position"] = UDim2.new(0, 0, 0, 53)
		Gui["5"]["Name"] = [[Seperator]]

		ThemeInstances["Seperators"][#ThemeInstances["Seperators"] + 1] = Gui["5"]

		-- StarterGui.UiLib.Frame.MainFrame.TabName
		Gui["48"] = Instance.new("TextLabel", Gui["3"])
		Gui["48"]["TextWrapped"] = true
		Gui["48"]["TextXAlignment"] = Enum.TextXAlignment.Left
		Gui["48"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["48"]["TextSize"] = 16
		Gui["48"]["TextColor3"] = ThemeColor.Text
		Gui["48"]["Size"] = UDim2.new(0, 220, 0, 22)
		Gui["48"]["Text"] = [[Insane Tab]]
		Gui["48"]["Name"] = [[TabName]]
		Gui["48"]["Font"] = Enum.Font.GothamMedium
		Gui["48"]["BackgroundTransparency"] = 1
		Gui["48"]["Position"] = UDim2.new(0, 62, 0, 11)

		-- StarterGui.UiLib.Frame.MainFrame.TabDesc
		Gui["49"] = Instance.new("TextLabel", Gui["3"])
		Gui["49"]["TextWrapped"] = true
		Gui["49"]["TextXAlignment"] = Enum.TextXAlignment.Left
		Gui["49"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["49"]["TextSize"] = 11
		Gui["49"]["TextColor3"] = ThemeColor.Text
		Gui["49"]["TextTransparency"] = 0.7
		Gui["49"]["Size"] = UDim2.new(0, 220, 0, 22)
		Gui["49"]["Text"] = [[<i>Insane Description</i>]]
		Gui["49"]["Name"] = [[TabDesc]]
		Gui["49"]["Font"] = Enum.Font.Gotham
		Gui["49"]["BackgroundTransparency"] = 1
		Gui["49"]["Position"] = UDim2.new(0, 62, 0, 27)
		Gui["49"]["RichText"] = true

		-- StarterGui.UiLib.Frame.MainFrame.Logo
		Gui["4a"] = Instance.new("ImageLabel", Gui["3"])
		Gui["4a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["4a"]["Image"] = [[rbxassetid://12507272383]]
		Gui["4a"]["Size"] = UDim2.new(0, 62, 0, 46)
		Gui["4a"]["Name"] = [[Logo]]
		Gui["4a"]["BackgroundTransparency"] = 1
		Gui["4a"]["Position"] = UDim2.new(0, 0, 0, 7)

		-- StarterGui.UiLib.Frame.MainFrame.UIGradient
		Gui["47"] = Instance.new("UIGradient", Gui["3"])
		Gui["47"]["Rotation"] = 90
		Gui["47"]["Color"] = ThemeColor.Main

		ThemeInstances["MainFrame"] = Gui["47"]
	end

	-- Starting sequence
	local StartSeq = {}
	do
		-- StarterGui.UiLib.StartAnim
		StartSeq["5c"] = Instance.new("Frame", LibraryFrame.MainScreenGui)
		StartSeq["5c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		StartSeq["5c"]["AnchorPoint"] = Vector2.new(0.5, 0.5)
		StartSeq["5c"]["BackgroundTransparency"] = 1
		StartSeq["5c"]["Size"] = UDim2.new(0, 100, 0, 100)
		StartSeq["5c"]["Position"] = UDim2.new(0.5, 0, 0.5, 0)
		StartSeq["5c"]["Visible"] = true
		StartSeq["5c"]["Name"] = [[StartAnim]]

		-- StarterGui.UiLib.StartAnim.ImageLabel
		StartSeq["5d"] = Instance.new("ImageLabel", StartSeq["5c"])
		StartSeq["5d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		StartSeq["5d"]["Image"] = [[rbxassetid://12507272383]]
		StartSeq["5d"]["Size"] = UDim2.new(0, 136, 0, 100)
		StartSeq["5d"]["BackgroundTransparency"] = 1
		StartSeq["5d"]["Position"] = UDim2.new(-0.17999999225139618, 0, 0, 0)
		StartSeq["5d"]["ImageTransparency"] = 1

		local CompleteTweening = false

		Library:Tween(StartSeq["5d"], {
			Length = 0.75,
			Goal = { ImageTransparency = 0 },
		}, function()
			CompleteTweening = true
		end)

		repeat
			task.wait()
		until CompleteTweening

		task.wait(2.35)

		CompleteTweening = false

		Library:Tween(StartSeq["5d"], {
			Length = 0.75,
			Goal = { ImageTransparency = 1 },
		}, function()
			CompleteTweening = true
		end)

		repeat
			task.wait()
		until CompleteTweening

		Library:Tween(Gui["2"], {
			Length = 2,
			Goal = { Size = UDim2.new(0, 645, 0, 433) },
		})

		StartSeq["5c"]:Destroy()
	end

	-- Nav
	do
		-- StarterGui.UiLib.Frame.NavBar
		Gui["4b"] = Instance.new("Frame", Gui["2"])
		Gui["4b"]["ZIndex"] = 0
		Gui["4b"]["BorderSizePixel"] = 0
		Gui["4b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["4b"]["Size"] = UDim2.new(0, 47, 0, 432)
		Gui["4b"]["Visible"] = true
		Gui["4b"]["Name"] = [[NavBar]]
		Gui["4b"]["Position"] = UDim2.new(0, 48, 0, 0)

		-- StarterGui.UiLib.Frame.NavBar.UICorner
		Gui["4c"] = Instance.new("UICorner", Gui["4b"])
		Gui["4c"]["CornerRadius"] = UDim.new(0, 6)

		-- StarterGui.UiLib.Frame.NavBar.UIGradient
		Gui["4d"] = Instance.new("UIGradient", Gui["4b"])
		Gui["4d"]["Rotation"] = 90
		Gui["4d"]["Color"] = ThemeColor.Secondary

		ThemeInstances["NavFrame"] = Gui["4d"]

		-- StarterGui.UiLib.Frame.NavBar.SettingButton
		Gui["4e"] = Instance.new("ImageButton", Gui["4b"])
		Gui["4e"]["ImageTransparency"] = 0.699999988079071
		Gui["4e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["4e"]["Image"] = [[rbxassetid://12518807035]]
		Gui["4e"]["Size"] = UDim2.new(0, 22, 0, 22)
		Gui["4e"]["Name"] = [[SettingButton]]
		Gui["4e"]["Position"] = UDim2.new(0, 12, 0, 401)
		Gui["4e"]["BackgroundTransparency"] = 1

		-- StarterGui.UiLib.Frame.NavBar.ScrollingFrame
		Gui["4f"] = Instance.new("ScrollingFrame", Gui["4b"])
		Gui["4f"]["Active"] = true
		Gui["4f"]["ScrollBarImageTransparency"] = 1
		Gui["4f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["4f"]["BackgroundTransparency"] = 1
		Gui["4f"]["Size"] = UDim2.new(0, 47, 0, 432)
		Gui["4f"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0)
		Gui["4f"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
		Gui["4f"]["ScrollBarThickness"] = 0
		Gui["4f"]["Position"] = UDim2.new(0, 0, 0, 0)

		-- StarterGui.UiLib.Frame.NavBar.ScrollingFrame.UIListLayout
		Gui["54"] = Instance.new("UIListLayout", Gui["4f"])
		Gui["54"]["Padding"] = UDim.new(0, 6)
		Gui["54"]["SortOrder"] = Enum.SortOrder.LayoutOrder
		Gui["54"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center

		-- StarterGui.UiLib.Frame.NavBar.ScrollingFrame.UIPadding
		Gui["59"] = Instance.new("UIPadding", Gui["4f"])
		Gui["59"]["PaddingTop"] = UDim.new(0, 12)

		-- StarterGui.UiLib.Frame.NavToggleDetector
		Gui["5a"] = Instance.new("Frame", Gui["2"])
		Gui["5a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["5a"]["BackgroundTransparency"] = 1
		Gui["5a"]["Size"] = UDim2.new(0, 48, 0, 432)
		Gui["5a"]["Position"] = UDim2.new(0, 0, 0, 0)
		Gui["5a"]["Name"] = [[NavTleDetector]]
		Gui["5a"]["ZIndex"] = 100

		-- StarterGui.UiLib.Frame.MainFrame.TabsContainer
		Gui["6"] = Instance.new("Frame", Gui["3"])
		Gui["6"]["Active"] = true
		Gui["6"]["BorderSizePixel"] = 0
		Gui["6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
		Gui["6"]["BackgroundTransparency"] = 1
		Gui["6"]["Size"] = UDim2.new(0, 596, 0, 372)
		Gui["6"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
		Gui["6"]["Position"] = UDim2.new(0, 0, 0, 54)
		Gui["6"]["Name"] = [[TabsContainer]]
		Gui["6"]["Visible"] = true
		Gui["6"]["ClipsDescendants"] = true
	end

	function Gui:Tab(options)
		options = Library:Place_Defaults({
			Name = "Tab",
			Description = "Tab description",
			Icon = "rbxassetid://11254763826",
			Color = Color3.new(0.811765, 0.313725, 0.247059),
			Hidden = false,
		}, options or {})

		local Tab = {
			Hover = false,
			Active = false,
			Hidden = options.Hidden,
			Index = TabIndex,
		}

		if Tab.Hidden then
			Tab.Index = TabIndex + 10000
		end

		TabIndex += 1

		-- Colour sequence cal, Tab Button
		do
			if not Tab.Hidden then
				local Color = options.Color
				local h, s, v = Color:ToHSV()

				local p0 = Color3.fromHSV(h, s, v)
				local p1 = Color3.fromHSV(h, s, v - 0.75)

				-- StarterGui.UiLib.Frame.NavBar.ScrollingFrame.TabButton
				Tab["50"] = Instance.new("TextButton", Gui["4f"])
				Tab["50"]["BorderSizePixel"] = 0
				Tab["50"]["TextSize"] = 14
				Tab["50"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Tab["50"]["TextColor3"] = ThemeColor.Text
				Tab["50"]["Size"] = UDim2.new(0, 30, 0, 30)
				Tab["50"]["Name"] = [[TabButton]]
				Tab["50"]["Text"] = [[]]
				Tab["50"]["Font"] = Enum.Font.SourceSans

				-- StarterTab.UiLib.Frame.NavBar.ScrollingFrame.TabButton.TabIcon
				Tab["51"] = Instance.new("ImageLabel", Tab["50"])
				Tab["51"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Tab["51"]["Image"] = options.Icon
				Tab["51"]["Size"] = UDim2.new(0, 24, 0, 24)
				Tab["51"]["Name"] = [[TabIcon]]
				Tab["51"]["BackgroundTransparency"] = 1
				Tab["51"]["Position"] = UDim2.new(0, 3, 0, 3)

				-- StarterTab.UiLib.Frame.NavBar.ScrollingFrame.TabButton.UICorner
				Tab["52"] = Instance.new("UICorner", Tab["50"])
				Tab["52"]["CornerRadius"] = UDim.new(0, 5)

				-- StarterTab.UiLib.Frame.NavBar.ScrollingFrame.TabButton.UIGradient
				Tab["53"] = Instance.new("UIGradient", Tab["50"])
				Tab["53"]["Rotation"] = 45
				Tab["53"]["Color"] =
					ColorSequence.new({ ColorSequenceKeypoint.new(0.000, p0), ColorSequenceKeypoint.new(1.000, p1) })

				do
					local ToolTip
					local Hover = false

					Tab["50"].MouseEnter:Connect(function()
						if NavHover then
							ToolTip = Library:ToolTip(options.Name)
						end

						Hover = true

						local tweeninfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						local tween = TweenService:Create(Tab["53"], tweeninfo, { Rotation = 180 })
						tween:Play()

						tween.Completed:Wait()

						repeat
							local rot = Tab["53"].Rotation + 45

							if rot == 405 then
								rot = 45
							end

							local tweeninfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
							local tween = TweenService:Create(Tab["53"], tweeninfo, { Rotation = rot })
							tween:Play()

							tween.Completed:Wait()

							if Tab["53"].Rotation == 360 then
								Tab["53"].Rotation = 0
							end
						until Hover == false
					end)

					Tab["50"].MouseLeave:Connect(function()
						Hover = false

						Library:Tween(Tab["53"], {
							Length = 0.3,
							Goal = { Rotation = 45 },
						})

						pcall(function()
							ToolTip:Destroy()
						end)
					end)
				end
			end
		end

		-- Tab Container
		do
			-- StarterGui.UiLib.Frame.MainFrame.Container
			Tab["6"] = Instance.new("ScrollingFrame", Gui["6"])
			Tab["6"]["Active"] = true
			Tab["6"]["BorderSizePixel"] = 0
			Tab["6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
			Tab["6"]["BackgroundTransparency"] = 1
			Tab["6"]["Size"] = UDim2.new(0, 596, 0, 372)
			Tab["6"]["ScrollBarImageColor3"] = Color3.fromRGB(90, 90, 90)
			Tab["6"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
			Tab["6"]["ScrollBarThickness"] = 4
			Tab["6"]["Position"] = UDim2.new(0, 0, 0, 0)
			Tab["6"]["Name"] = [[Container]]
			Tab["6"]["Visible"] = false

			-- StarterGui.UiLib.Frame.MainFrame.Container.UIListLayout
			Tab["7"] = Instance.new("UIListLayout", Tab["6"])
			Tab["7"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center
			Tab["7"]["Padding"] = UDim.new(0, 8)
			Tab["7"]["SortOrder"] = Enum.SortOrder.LayoutOrder

			-- StarterGui.UiLib.Frame.MainFrame.Container.UIPadding
			Tab["8"] = Instance.new("UIPadding", Tab["6"])
			Tab["8"]["PaddingTop"] = UDim.new(0, 15)
			Tab["8"]["PaddingLeft"] = UDim.new(0, 1)
		end

		Tab["6"].ChildAdded:Connect(function(Child)
			if Child:IsA("Frame") then
				Library:ResizeCanvas(Tab["6"])

				Child:GetPropertyChangedSignal("Size"):Connect(function()
					Library:ResizeCanvas(Tab["6"])
				end)
			end
		end)

		do
			function Tab:Activate()
				if not Tab.Active then
					Gui["48"].Text = tostring(options.Name)
					Gui["49"].Text = [[<i>]] .. tostring(options.Description) .. [[</i>]]

					if Gui.CurrentTabIndex < Tab.Index then
						task.spawn(function()
							task.wait(0.15)

							Tab["6"].Position = UDim2.new(0, 0, 0, 433)

							Library:Tween(Tab["6"], {
								Length = 0.3,
								Goal = { Position = UDim2.new(0, 0, 0, 0) },
							})
						end)
					else
						task.spawn(function()
							task.wait(0.15)

							Tab["6"].Position = UDim2.new(0, 0, 0, -372)

							Library:Tween(Tab["6"], {
								Length = 0.3,
								Goal = { Position = UDim2.new(0, 0, 0, 0) },
							})
						end)
					end

					Gui.CurrentTabIndex = Tab.Index

					if Gui.CurrentTab ~= nil then
						Gui.CurrentTab:Deactivate()
					end

					Tab.Active = true
					Tab["6"].Visible = true

					Gui.CurrentTab = Tab
				end
			end

			function Tab:Deactivate()
				if Tab.Active then
					Tab.Active = false
					Tab.Hover = false

					if Gui.CurrentTabIndex < Tab.Index then
						Library:Tween(Tab["6"], {
							Length = 0.3,
							Goal = { Position = UDim2.new(0, 0, 0, 433) },
						})
					else
						Library:Tween(Tab["6"], {
							Length = 0.3,
							Goal = { Position = UDim2.new(0, 0, 0, -372) },
						})
					end

					task.wait(0.3)
					Tab["6"].Visible = false
				end
			end

			if Gui.CurrentTab == nil then
				if not options.Hidden then
					Tab:Activate()
				end
			end

			if not Tab.Hidden then
				Tab["50"].MouseButton1Click:Connect(function()
					if not Tab.Active then
						Tab:Activate()
					end
				end)
			end
		end

		function Tab:Section(options)
			options = Library:Place_Defaults({
				Name = "Section",
			}, options or {})

			local Section = {}

			do
				-- StarterGui.UiLib.Frame.MainFrame.Container.Section
				Section["21"] = Instance.new("Frame", Tab["6"])
				Section["21"]["BorderSizePixel"] = 0
				Section["21"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 49)
				Section["21"]["BackgroundTransparency"] = 1
				Section["21"]["Size"] = UDim2.new(0, 505, 0, 13)
				Section["21"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
				Section["21"]["Position"] = UDim2.new(0, 0, 0.5322129130363464, 0)
				Section["21"]["Name"] = [[Section]]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Section.NameLabel
				Section["22"] = Instance.new("TextLabel", Section["21"])
				Section["22"]["TextWrapped"] = true
				Section["22"]["TextXAlignment"] = Enum.TextXAlignment.Left
				Section["22"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Section["22"]["TextSize"] = 12
				Section["22"]["TextColor3"] = ThemeColor.Text
				Section["22"]["Size"] = UDim2.new(0, 496, 0, 20)
				Section["22"]["Text"] = options.Name
				Section["22"]["Name"] = [[NameLabel]]
				Section["22"]["Font"] = Enum.Font.Gotham
				Section["22"]["BackgroundTransparency"] = 1
				Section["22"]["Position"] = UDim2.new(0.0178217813372612, 0, 0, 0)
			end

			return Section
		end

		function Tab:Toggle(options)
			options = Library:Place_Defaults({
				Name = "Toggle",
				Default = false,
				Callback = function()
					return
				end,
			}, options or {})

			local Toggle = {
				Bool = options.Default,
			}

			do
				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle
				Toggle["f"] = Instance.new("Frame", Tab["6"])
				Toggle["f"]["BorderSizePixel"] = 0
				Toggle["f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Toggle["f"]["Size"] = UDim2.new(0, 505, 0, 41)
				Toggle["f"]["Position"] = UDim2.new(0.2527272701263428, 0, 0, 0)
				Toggle["f"]["Name"] = [[Toggle]]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle.UICorner
				Toggle["10"] = Instance.new("UICorner", Toggle["f"])
				Toggle["10"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle.UIGradient
				Toggle["11"] = Instance.new("UIGradient", Toggle["f"])
				Toggle["11"]["Rotation"] = 90
				Toggle["11"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = Toggle["11"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle.Detector
				Toggle["12"] = Instance.new("TextButton", Toggle["f"])
				Toggle["12"]["BorderSizePixel"] = 0
				Toggle["12"]["AutoButtonColor"] = false
				Toggle["12"]["TextSize"] = 14
				Toggle["12"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Toggle["12"]["TextColor3"] = ThemeColor.Text
				Toggle["12"]["Size"] = UDim2.new(0, 505, 0, 41)
				Toggle["12"]["Name"] = [[Detector]]
				Toggle["12"]["Text"] = [[]]
				Toggle["12"]["Font"] = Enum.Font.SourceSans

				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle.Detector.UIGradient
				Toggle["13"] = Instance.new("UIGradient", Toggle["12"])
				Toggle["13"]["Rotation"] = 90
				Toggle["13"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = Toggle["13"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle.Detector.UICorner
				Toggle["14"] = Instance.new("UICorner", Toggle["12"])
				Toggle["14"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle.NameLabel
				Toggle["15"] = Instance.new("TextLabel", Toggle["f"])
				Toggle["15"]["TextWrapped"] = true
				Toggle["15"]["TextXAlignment"] = Enum.TextXAlignment.Left
				Toggle["15"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Toggle["15"]["TextSize"] = 12
				Toggle["15"]["TextColor3"] = ThemeColor.Text
				Toggle["15"]["Size"] = UDim2.new(0, 188, 0, 41)
				Toggle["15"]["Text"] = options.Name
				Toggle["15"]["Name"] = [[NameLabel]]
				Toggle["15"]["Font"] = Enum.Font.Gotham
				Toggle["15"]["BackgroundTransparency"] = 1
				Toggle["15"]["Position"] = UDim2.new(0.03366336598992348, 0, 0, 0)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle.Indicator
				Toggle["16"] = Instance.new("TextLabel", Toggle["f"])
				Toggle["16"]["BorderSizePixel"] = 0
				Toggle["16"]["BackgroundColor3"] = ThemeColor.Indicator
				Toggle["16"]["TextSize"] = 14
				Toggle["16"]["TextColor3"] = ThemeColor.Text
				Toggle["16"]["Size"] = UDim2.new(0, 22, 0, 22)
				Toggle["16"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
				Toggle["16"]["Text"] = [[]]
				Toggle["16"]["Name"] = [[Indicator]]
				Toggle["16"]["Font"] = Enum.Font.SourceSans
				Toggle["16"]["Position"] = UDim2.new(0.9247524738311768, 0, 0.2195121943950653, 0)

				ThemeInstances["Indicators"][#ThemeInstances["Indicators"] + 1] = Toggle["16"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle.Indicator.UICorner
				Toggle["17"] = Instance.new("UICorner", Toggle["16"])
				Toggle["17"]["CornerRadius"] = UDim.new(0, 6)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Toggle.Outline
				Toggle["18"] = Instance.new("UIStroke", Toggle["f"])
				Toggle["18"]["Color"] = ThemeColor.Outline
				Toggle["18"]["Name"] = [[Outline]]

				ThemeInstances["Outline"][#ThemeInstances["Outline"] + 1] = Toggle["18"]
			end

			-- Methods
			do
				function Toggle:Toggle(toggle)
					if toggle then
						Toggle.Bool = true

						Library:Tween(Toggle["16"], {
							Length = 0.5,
							Goal = { BackgroundColor3 = Color3.fromRGB(255, 255, 255) },
						})
					else
						Toggle.Bool = false

						Library:Tween(Toggle["16"], {
							Length = 0.5,
							Goal = { BackgroundColor3 = ThemeColor.Indicator },
						})
					end

					task.spawn(function()
						options.Callback(Toggle.Bool)
					end)
				end

				function Toggle:Set(bool)
					if type(bool) == "boolean" then
						Toggle:Toggle(bool)
					else
						if Toggle.Bool then
							Toggle:Toggle(false)
						else
							Toggle:Toggle(true)
						end
					end
				end
			end

			-- Handler
			do
				Toggle["f"].MouseEnter:Connect(function()
					local h, s, v = ThemeColor.Outline:ToHSV()
					local NewColour

					if (v - 0.07) < 0 then
						NewColour = Color3.fromHSV(h, s, 0)
					else
						NewColour = Color3.fromHSV(h, s, v - 0.07)
					end

					Library:Tween(Toggle["18"], {
						Length = 0.5,
						Goal = { Color = NewColour },
					})
				end)

				Toggle["f"].MouseLeave:Connect(function()
					Library:Tween(Toggle["18"], {
						Length = 0.5,
						Goal = { Color = ThemeColor.Outline },
					})
				end)

				Toggle["12"].MouseButton1Click:Connect(function()
					Toggle:Set()
				end)
			end

			Toggle:Set(options.Default)

			return Toggle
		end

		function Tab:Button(options)
			options = Library:Place_Defaults({
				Name = "Button",
				Callback = function()
					return
				end,
			}, options or {})

			local Button = {}

			do
				-- StarterGui.UiLib.Frame.MainFrame.Container.Button
				Button["19"] = Instance.new("Frame", Tab["6"])
				Button["19"]["BorderSizePixel"] = 0
				Button["19"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Button["19"]["Size"] = UDim2.new(0, 505, 0, 41)
				Button["19"]["Position"] = UDim2.new(0.2527272701263428, 0, 0, 0)
				Button["19"]["Name"] = [[Button]]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Button.UICorner
				Button["1a"] = Instance.new("UICorner", Button["19"])
				Button["1a"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Button.UIGradient
				Button["1b"] = Instance.new("UIGradient", Button["19"])
				Button["1b"]["Rotation"] = 90
				Button["1b"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = Button["1b"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Button.Detector
				Button["1c"] = Instance.new("TextButton", Button["19"])
				Button["1c"]["BorderSizePixel"] = 0
				Button["1c"]["AutoButtonColor"] = false
				Button["1c"]["TextSize"] = 14
				Button["1c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Button["1c"]["TextColor3"] = ThemeColor.Text
				Button["1c"]["Size"] = UDim2.new(0, 505, 0, 41)
				Button["1c"]["Name"] = [[Detector]]
				Button["1c"]["Text"] = [[]]
				Button["1c"]["Font"] = Enum.Font.SourceSans

				-- StarterGui.UiLib.Frame.MainFrame.Container.Button.Detector.UIGradient
				Button["1d"] = Instance.new("UIGradient", Button["1c"])
				Button["1d"]["Rotation"] = 90
				Button["1d"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = Button["1d"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Button.Detector.UICorner
				Button["1e"] = Instance.new("UICorner", Button["1c"])
				Button["1e"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Button.NameLabel
				Button["1f"] = Instance.new("TextLabel", Button["19"])
				Button["1f"]["TextWrapped"] = true
				Button["1f"]["TextXAlignment"] = Enum.TextXAlignment.Left
				Button["1f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Button["1f"]["TextSize"] = 12
				Button["1f"]["TextColor3"] = ThemeColor.Text
				Button["1f"]["Size"] = UDim2.new(0, 188, 0, 41)
				Button["1f"]["Text"] = options.Name
				Button["1f"]["Name"] = [[NameLabel]]
				Button["1f"]["Font"] = Enum.Font.Gotham
				Button["1f"]["BackgroundTransparency"] = 1
				Button["1f"]["Position"] = UDim2.new(0.03366336598992348, 0, 0, 0)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Button.Outline
				Button["20"] = Instance.new("UIStroke", Button["19"])
				Button["20"]["Color"] = ThemeColor.Outline
				Button["20"]["Name"] = [[Outline]]

				ThemeInstances["Outline"][#ThemeInstances["Outline"] + 1] = Button["20"]
			end

			-- Handler
			do
				Button["19"].MouseEnter:Connect(function()
					local h, s, v = ThemeColor.Outline:ToHSV()
					local NewColour

					if (v - 0.07) < 0 then
						NewColour = Color3.fromHSV(h, s, 0)
					else
						NewColour = Color3.fromHSV(h, s, v - 0.07)
					end

					Library:Tween(Button["20"], {
						Length = 0.5,
						Goal = { Color = NewColour },
					})
				end)

				Button["19"].MouseLeave:Connect(function()
					Library:Tween(Button["20"], {
						Length = 0.5,
						Goal = { Color = ThemeColor.Outline },
					})
				end)

				Button["1c"].MouseButton1Click:Connect(function()
					task.spawn(function()
						options.Callback()
					end)
				end)
			end

			return Button
		end

		function Tab:Slider(options)
			options = Library:Place_Defaults({
				Name = "Slider",
				Min = 0,
				Max = 100,
				Default = 1,
				Callback = function() end,
			}, options or {})

			local Slider = {
				OldVal = options.Default,
			}

			do
				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider
				Slider["23"] = Instance.new("Frame", Tab["6"])
				Slider["23"]["BorderSizePixel"] = 0
				Slider["23"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Slider["23"]["Size"] = UDim2.new(0, 505, 0, 41)
				Slider["23"]["Position"] = UDim2.new(0.2527272701263428, 0, 0, 0)
				Slider["23"]["Name"] = [[Slider]]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.UICorner
				Slider["24"] = Instance.new("UICorner", Slider["23"])
				Slider["24"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.UIGradient
				Slider["25"] = Instance.new("UIGradient", Slider["23"])
				Slider["25"]["Rotation"] = 90
				Slider["25"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = Slider["25"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.Detector
				Slider["26"] = Instance.new("TextButton", Slider["23"])
				Slider["26"]["BorderSizePixel"] = 0
				Slider["26"]["AutoButtonColor"] = false
				Slider["26"]["TextSize"] = 14
				Slider["26"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Slider["26"]["TextColor3"] = ThemeColor.Text
				Slider["26"]["Size"] = UDim2.new(0, 505, 0, 41)
				Slider["26"]["Name"] = [[Detector]]
				Slider["26"]["Text"] = [[]]
				Slider["26"]["Font"] = Enum.Font.SourceSans

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.Detector.UIGradient
				Slider["27"] = Instance.new("UIGradient", Slider["26"])
				Slider["27"]["Rotation"] = 90
				Slider["27"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = Slider["27"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.Detector.UICorner
				Slider["28"] = Instance.new("UICorner", Slider["26"])
				Slider["28"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.NameLabel
				Slider["29"] = Instance.new("TextLabel", Slider["23"])
				Slider["29"]["TextWrapped"] = true
				Slider["29"]["TextXAlignment"] = Enum.TextXAlignment.Left
				Slider["29"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Slider["29"]["TextSize"] = 12
				Slider["29"]["TextColor3"] = ThemeColor.Text
				Slider["29"]["Size"] = UDim2.new(0, 188, 0, 41)
				Slider["29"]["Text"] = options.Name
				Slider["29"]["Name"] = [[NameLabel]]
				Slider["29"]["Font"] = Enum.Font.Gotham
				Slider["29"]["BackgroundTransparency"] = 1
				Slider["29"]["Position"] = UDim2.new(0.03366336598992348, 0, 0, 0)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.Indicator
				Slider["2a"] = Instance.new("TextLabel", Slider["23"])
				Slider["2a"]["TextWrapped"] = true
				Slider["2a"]["BorderSizePixel"] = 0
				Slider["2a"]["TextScaled"] = true
				Slider["2a"]["BackgroundColor3"] = ThemeColor.Indicator
				Slider["2a"]["TextSize"] = 14
				Slider["2a"]["TextColor3"] = ThemeColor.Text
				Slider["2a"]["Size"] = UDim2.new(0, 217, 0, 4)
				Slider["2a"]["Text"] = [[]]
				Slider["2a"]["Name"] = [[Indicator]]
				Slider["2a"]["Font"] = Enum.Font.SourceSans
				Slider["2a"]["Position"] = UDim2.new(0, 263, 0, 18)

				ThemeInstances["Indicators"][#ThemeInstances["Indicators"] + 1] = Slider["2a"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.Indicator.UICorner
				Slider["2b"] = Instance.new("UICorner", Slider["2a"])
				Slider["2b"]["CornerRadius"] = UDim.new(0, 6)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.Indicator.Back
				Slider["2c"] = Instance.new("Frame", Slider["2a"])
				Slider["2c"]["BorderSizePixel"] = 0
				Slider["2c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Slider["2c"]["Size"] = UDim2.new(0.4, 0, 0, 6)
				Slider["2c"]["Position"] = UDim2.new(0, 0, 0, -1)
				Slider["2c"]["Name"] = [[Back]]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.Indicator.Back.UICorner
				Slider["2d"] = Instance.new("UICorner", Slider["2c"])
				Slider["2d"]["CornerRadius"] = UDim.new(1, 0)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Slider.Outline
				Slider["2e"] = Instance.new("UIStroke", Slider["23"])
				Slider["2e"]["Color"] = ThemeColor.Outline
				Slider["2e"]["Name"] = [[Outline]]

				ThemeInstances["Outline"][#ThemeInstances["Outline"] + 1] = Slider["2e"]
			end

			-- Methods
			function Slider:SetValue(Value)
				Value = math.floor(Value)

				Library:Tween(Slider["2c"], {
					Length = 1,
					Goal = { Size = UDim2.fromScale(((Value - options.Min) / (options.Max - options.Min)), 1.5) },
				})

				Slider["29"]["Text"] = options.Name .. " - " .. Value

				options.Callback(Value)
			end

			-- Handler
			do
				Slider["23"].MouseEnter:Connect(function()
					local h, s, v = ThemeColor.Outline:ToHSV()
					local NewColour

					if (v - 0.07) < 0 then
						NewColour = Color3.fromHSV(h, s, 0)
					else
						NewColour = Color3.fromHSV(h, s, v - 0.07)
					end

					Library:Tween(Slider["2e"], {
						Length = 0.5,
						Goal = { Color = NewColour },
					})
				end)

				Slider["23"].MouseLeave:Connect(function()
					Library:Tween(Slider["2e"], {
						Length = 0.5,
						Goal = { Color = ThemeColor.Outline },
					})
				end)

				local MouseDown

				Slider["26"].MouseButton1Down:Connect(function()
					Library.Sliding = true
					MouseDown = true

					Library:Tween(Slider["2c"], {
						Length = 0.5,
						Goal = { BackgroundColor3 = Color3.fromRGB(218, 218, 218) },
					})

					while RunService.RenderStepped:wait() and MouseDown do
						local percentage =
							math.clamp((Mouse.X - Slider["2a"].AbsolutePosition.X) / Slider["2a"].AbsoluteSize.X, 0, 1)
						local value = ((options.Max - options.Min) * percentage) + options.Min
						value = math.floor(value)

						if value ~= Slider.OldVal then
							task.spawn(function()
								options.Callback(value)
							end)
						end

						Slider.OldVal = value

						Library:Tween(Slider["2c"], {
							Length = 0.1,
							Goal = {
								Size = UDim2.fromScale(((value - options.Min) / (options.Max - options.Min)), 1.5),
							},
						})

						Slider["29"]["Text"] = options.Name .. " - " .. value
					end

					Library.Sliding = false

					Library:Tween(Slider["2c"], {
						Length = 0.5,
						Goal = { BackgroundColor3 = Color3.fromRGB(255, 255, 255) },
					})
				end)

				UserInputService.InputEnded:Connect(function(key)
					if key.UserInputType == Enum.UserInputType.MouseButton1 then
						MouseDown = false
					end
				end)
			end

			Slider:SetValue(options.Default)

			return Slider
		end

		function Tab:Label(options)
			options = Library:Place_Defaults({
				Text = "Label",
			}, options or {})

			local Label = {}

			do
				-- StarterGui.UiLib.Frame.MainFrame.Container.Label
				Label["b"] = Instance.new("Frame", Tab["6"])
				Label["b"]["BorderSizePixel"] = 0
				Label["b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Label["b"]["Size"] = UDim2.new(0, 505, 0, 35)
				Label["b"]["Position"] = UDim2.new(0.2527272701263428, 0, 0, 0)
				Label["b"]["Name"] = [[Label]]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Label.UICorner
				Label["c"] = Instance.new("UICorner", Label["b"])
				Label["c"]["CornerRadius"] = UDim.new(0, 4)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Label.UIGradient
				Label["d"] = Instance.new("UIGradient", Label["b"])
				Label["d"]["Rotation"] = 90
				Label["d"]["Color"] = ThemeColor.Label

				ThemeInstances["Label"][#ThemeInstances["Label"] + 1] = Label["d"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Label.NameLabel
				Label["e"] = Instance.new("TextLabel", Label["b"])
				Label["e"]["TextWrapped"] = true
				Label["e"]["TextXAlignment"] = Enum.TextXAlignment.Left
				Label["e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Label["e"]["TextSize"] = 12
				Label["e"]["TextColor3"] = ThemeColor.Text
				Label["e"]["Size"] = UDim2.new(0, 488, 0, 35)
				Label["e"]["Name"] = [[NameLabel]]
				Label["e"]["Font"] = Enum.Font.Gotham
				Label["e"]["BackgroundTransparency"] = 1
				Label["e"]["Position"] = UDim2.new(0.03366336598992348, 0, 0, 0)
			end

			-- Methods
			do
				function Label:SetText(name)
					Label["e"]["Text"] = name

					local Val
					repeat
						Val = Label["e"].TextBounds.Y

						Label["b"]["Size"] = UDim2.new(0, 505, 0, Label["e"].TextBounds.Y + 21)
						Label["e"]["Size"] = UDim2.new(0, 488, 0, Label["e"].TextBounds.Y + 21)
					until Val == Label["e"].TextBounds.Y
				end
			end

			Label:SetText(options.Text)

			return Label
		end

		function Tab:Textbox(options)
			options = Library:Place_Defaults({
				Name = "Small Textbox",
				Default = "Text",
				Callback = function()
					return
				end,
			}, options or {})

			local Textbox = {}

			do
				-- StarterGui.UiLib.Frame.MainFrame.Container.Textbox
				Textbox["40"] = Instance.new("Frame", Tab["6"])
				Textbox["40"]["BorderSizePixel"] = 0
				Textbox["40"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Textbox["40"]["Size"] = UDim2.new(0, 505, 0, 41)
				Textbox["40"]["Position"] = UDim2.new(0.2527272701263428, 0, 0, 0)
				Textbox["40"]["Name"] = [[Textbox]]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Textbox.UICorner
				Textbox["41"] = Instance.new("UICorner", Textbox["40"])
				Textbox["41"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Textbox.UIGradient
				Textbox["42"] = Instance.new("UIGradient", Textbox["40"])
				Textbox["42"]["Rotation"] = 90
				Textbox["42"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = Textbox["42"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Textbox.NameLabel
				Textbox["43"] = Instance.new("TextLabel", Textbox["40"])
				Textbox["43"]["TextWrapped"] = true
				Textbox["43"]["TextXAlignment"] = Enum.TextXAlignment.Left
				Textbox["43"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Textbox["43"]["TextSize"] = 12
				Textbox["43"]["TextColor3"] = ThemeColor.Text
				Textbox["43"]["Size"] = UDim2.new(0, 188, 0, 41)
				Textbox["43"]["Text"] = options.Name
				Textbox["43"]["Name"] = [[NameLabel]]
				Textbox["43"]["Font"] = Enum.Font.Gotham
				Textbox["43"]["BackgroundTransparency"] = 1
				Textbox["43"]["Position"] = UDim2.new(0.03366336598992348, 0, 0, 0)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Textbox.Outline
				Textbox["44"] = Instance.new("UIStroke", Textbox["40"])
				Textbox["44"]["Color"] = ThemeColor.Outline
				Textbox["44"]["Name"] = [[Outline]]

				ThemeInstances["Outline"][#ThemeInstances["Outline"] + 1] = Textbox["44"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Textbox.Frame
				Textbox["46"] = Instance.new("Frame", Textbox["40"])
				Textbox["46"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Textbox["46"]["BackgroundTransparency"] = 1
				Textbox["46"]["Size"] = UDim2.new(0, 100, 0, 41)
				Textbox["46"]["Position"] = UDim2.new(0.7841584086418152, 0, 0, 0)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Textbox.Frame.TextBox
				Textbox["4e"] = Instance.new("TextBox", Textbox["46"])
				Textbox["4e"]["BorderSizePixel"] = 0
				Textbox["4e"]["TextColor3"] = Color3.new(1, 1, 1)
				Textbox["4e"]["TextSize"] = 12
				Textbox["4e"]["BackgroundColor3"] = ThemeColor.Indicator
				Textbox["4e"]["PlaceholderText"] = [[...]]
				Textbox["4e"]["Size"] = UDim2.new(0, 29, 0, 22)
				Textbox["4e"]["Text"] = [[]]
				Textbox["4e"]["Position"] = UDim2.new(0.9247524738311768, 0, 0.2195121943950653, 0)
				Textbox["4e"]["Font"] = Enum.Font.Gotham
				Textbox["4e"]["ClipsDescendants"] = true

				ThemeInstances["Indicators"][#ThemeInstances["Indicators"] + 1] = Textbox["4e"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Textbox.Frame.TextBox.UICorner
				Textbox["47"] = Instance.new("UICorner", Textbox["4e"])
				Textbox["47"]["CornerRadius"] = UDim.new(0, 6)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Textbox.Frame.UIListLayout
				Textbox["48"] = Instance.new("UIListLayout", Textbox["46"])
				Textbox["48"]["VerticalAlignment"] = Enum.VerticalAlignment.Center
				Textbox["48"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Right
				Textbox["48"]["SortOrder"] = Enum.SortOrder.LayoutOrder
			end

			-- Handler
			do
				Textbox["40"].MouseEnter:Connect(function()
					local h, s, v = ThemeColor.Outline:ToHSV()
					local NewColour

					if (v - 0.07) < 0 then
						NewColour = Color3.fromHSV(h, s, 0)
					else
						NewColour = Color3.fromHSV(h, s, v - 0.07)
					end

					Library:Tween(Textbox["44"], {
						Length = 0.5,
						Goal = { Color = NewColour },
					})
				end)

				Textbox["40"].MouseLeave:Connect(function()
					Library:Tween(Textbox["44"], {
						Length = 0.5,
						Goal = { Color = ThemeColor.Outline },
					})
				end)

				Textbox["4e"]:GetPropertyChangedSignal("Text"):Connect(function()
					if Textbox["4e"].Text == "" then
						Library:Tween(Textbox["4e"], {
							Length = 0.2,
							Goal = { Size = UDim2.new(0, 29, 0, 22) },
						})
					else
						local Bound = TextService:GetTextSize(
							Textbox["4e"].Text,
							Textbox["4e"].TextSize,
							Textbox["4e"].Font,
							Vector2.new(Textbox["4e"].AbsoluteSize.X, Textbox["4e"].AbsoluteSize.Y)
						)

						if (Bound.X + 18) > 330 then
							Library:Tween(Textbox["4e"], {
								Length = 0.2,
								Goal = { Size = UDim2.new(0, 330, 0, 22) },
							})
						else
							Library:Tween(Textbox["4e"], {
								Length = 0.2,
								Goal = { Size = UDim2.new(0, (Bound.X + 18), 0, 22) },
							})
						end
					end

					task.spawn(function()
						options.Callback(Textbox["4e"].Text)
					end)
				end)
			end

			-- Methods
			do
				function Textbox:SetText(Text)
					Textbox["4e"].Text = Text
				end
			end

			Textbox:SetText(options.Default)

			return Textbox
		end

		function Tab:Dropdown(options)
			options = Library:Place_Defaults({
				Name = "Dropdown",
				Items = {},
				Callback = function(item)
					return
				end,
			}, options or {})

			local Dropdown = {
				Items = options.Items,
				SelectedItem = nil,
				ContainerOpened = false,
				NameText = options.Name,
				Hover = false,
			}

			do
				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown
				Dropdown["2f"] = Instance.new("Frame", Tab["6"])
				Dropdown["2f"]["BorderSizePixel"] = 0
				Dropdown["2f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Dropdown["2f"]["Size"] = UDim2.new(0, 505, 0, 41)
				Dropdown["2f"]["ClipsDescendants"] = true
				Dropdown["2f"]["Position"] = UDim2.new(0.07563025504350662, 0, 0.22969187796115875, 0)
				Dropdown["2f"]["Name"] = [[Dropdown]]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.UICorner
				Dropdown["30"] = Instance.new("UICorner", Dropdown["2f"])
				Dropdown["30"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.UIGradient
				Dropdown["31"] = Instance.new("UIGradient", Dropdown["2f"])
				Dropdown["31"]["Rotation"] = 90
				Dropdown["31"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = Dropdown["31"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Detector
				Dropdown["32"] = Instance.new("TextButton", Dropdown["2f"])
				Dropdown["32"]["BorderSizePixel"] = 0
				Dropdown["32"]["AutoButtonColor"] = false
				Dropdown["32"]["TextSize"] = 14
				Dropdown["32"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Dropdown["32"]["TextColor3"] = ThemeColor.Text
				Dropdown["32"]["Size"] = UDim2.new(0, 505, 0, 41)
				Dropdown["32"]["Name"] = [[Detector]]
				Dropdown["32"]["Text"] = [[]]
				Dropdown["32"]["Font"] = Enum.Font.SourceSans
				Dropdown["32"]["BackgroundTransparency"] = 1

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Detector.UIGradient
				Dropdown["33"] = Instance.new("UIGradient", Dropdown["32"])
				Dropdown["33"]["Rotation"] = 90
				Dropdown["33"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = Dropdown["33"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Detector.UICorner
				Dropdown["34"] = Instance.new("UICorner", Dropdown["32"])
				Dropdown["34"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.NameLabel
				Dropdown["35"] = Instance.new("TextLabel", Dropdown["2f"])
				Dropdown["35"]["TextWrapped"] = true
				Dropdown["35"]["TextXAlignment"] = Enum.TextXAlignment.Left
				Dropdown["35"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Dropdown["35"]["TextSize"] = 12
				Dropdown["35"]["TextColor3"] = ThemeColor.Text
				Dropdown["35"]["Size"] = UDim2.new(0, 188, 0, 41)
				Dropdown["35"]["Text"] = options.Name
				Dropdown["35"]["Name"] = [[NameLabel]]
				Dropdown["35"]["Font"] = Enum.Font.Gotham
				Dropdown["35"]["BackgroundTransparency"] = 1
				Dropdown["35"]["Position"] = UDim2.new(0, 16, 0, 0)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Outline
				Dropdown["36"] = Instance.new("UIStroke", Dropdown["2f"])
				Dropdown["36"]["Color"] = ThemeColor.Outline
				Dropdown["36"]["Name"] = [[Outline]]

				ThemeInstances["Outline"][#ThemeInstances["Outline"] + 1] = Dropdown["36"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Indicator
				Dropdown["37"] = Instance.new("TextLabel", Dropdown["2f"])
				Dropdown["37"]["TextWrapped"] = true
				Dropdown["37"]["TextXAlignment"] = Enum.TextXAlignment.Left
				Dropdown["37"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Dropdown["37"]["TextSize"] = 14
				Dropdown["37"]["TextColor3"] = Color3.new(1, 1, 1)
				Dropdown["37"]["Size"] = UDim2.new(0, 13, 0, 41)
				Dropdown["37"]["Text"] = [[˅]]
				Dropdown["37"]["Name"] = [[Indicator]]
				Dropdown["37"]["Font"] = Enum.Font.Gotham
				Dropdown["37"]["BackgroundTransparency"] = 1
				Dropdown["37"]["Position"] = UDim2.new(0, 489, 0, 0)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Frame
				Dropdown["38"] = Instance.new("Frame", Dropdown["2f"])
				Dropdown["38"]["BorderSizePixel"] = 0
				Dropdown["38"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Dropdown["38"]["BackgroundTransparency"] = 1
				Dropdown["38"]["Size"] = UDim2.new(0, 505, 0, 28)
				Dropdown["38"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
				Dropdown["38"]["Position"] = UDim2.new(0, 0, 0, 43)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Frame.UIListLayout
				Dropdown["3b"] = Instance.new("UIListLayout", Dropdown["38"])
				Dropdown["3b"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center
				Dropdown["3b"]["Padding"] = UDim.new(0, 5)
				Dropdown["3b"]["SortOrder"] = Enum.SortOrder.LayoutOrder

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Frame.UIPadding
				Dropdown["3c"] = Instance.new("UIPadding", Dropdown["38"])
				Dropdown["3c"]["PaddingTop"] = UDim.new(0, 5)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Seperator
				Dropdown["3f"] = Instance.new("Frame", Dropdown["2f"])
				Dropdown["3f"]["BorderSizePixel"] = 0
				Dropdown["3f"]["BackgroundColor3"] = ThemeColor.Text
				Dropdown["3f"]["BackgroundTransparency"] = 0.699999988079071
				Dropdown["3f"]["Size"] = UDim2.new(0, 415, 0, 1)
				Dropdown["3f"]["Position"] = UDim2.new(0, 44, 0, 42)
				Dropdown["3f"]["Name"] = [[Seperator]]

				ThemeInstances["Seperators"][#ThemeInstances["Seperators"] + 1] = Dropdown["3f"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.ValLabelHolder
				Dropdown["40"] = Instance.new("Frame", Dropdown["2f"])
				Dropdown["40"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				Dropdown["40"]["BackgroundTransparency"] = 1
				Dropdown["40"]["Size"] = UDim2.new(0, 474, 0, 41)
				Dropdown["40"]["Name"] = [[ValLabelHolder]]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.ValLabelHolder.ValLabel
				Dropdown["41"] = Instance.new("TextLabel", Dropdown["40"])
				Dropdown["41"]["BorderSizePixel"] = 0
				Dropdown["41"]["BackgroundColor3"] = ThemeColor.Indicator
				Dropdown["41"]["TextSize"] = 10
				Dropdown["41"]["TextColor3"] = Color3.new(1, 1, 1)
				Dropdown["41"]["Size"] = UDim2.new(0, 66, 0, 22)
				Dropdown["41"]["Name"] = [[ValLabel]]
				Dropdown["41"]["Font"] = Enum.Font.Gotham
				Dropdown["41"]["Position"] = UDim2.new(0.8336427211761475, 0, 0.20788872241973877, 0)

				ThemeInstances["Indicators"][#ThemeInstances["Indicators"] + 1] = Dropdown["41"]

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.ValLabelHolder.ValLabel.UICorner
				Dropdown["42"] = Instance.new("UICorner", Dropdown["41"])
				Dropdown["42"]["CornerRadius"] = UDim.new(0, 4)

				-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.ValLabelHolder.UIListLayout
				Dropdown["43"] = Instance.new("UIListLayout", Dropdown["40"])
				Dropdown["43"]["VerticalAlignment"] = Enum.VerticalAlignment.Center
				Dropdown["43"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Right
				Dropdown["43"]["SortOrder"] = Enum.SortOrder.LayoutOrder
			end

			-- Handler
			do
				local function ResizeFrame()
					local NumChild = 0

					for i, v in pairs(Dropdown["38"]:GetChildren()) do
						if v:IsA("TextButton") then
							NumChild += 1
						end
					end

					local FrameYOffset = 29 * NumChild + 5 * NumChild + 20

					if NumChild == 0 then
						FrameYOffset = 47
					end

					Library:Tween(Dropdown["2f"], {
						Length = 0.5,
						Goal = { Size = UDim2.fromOffset(505, FrameYOffset) },
					})
				end

				Dropdown["2f"].MouseEnter:Connect(function()
					local h, s, v = ThemeColor.Outline:ToHSV()
					local NewColour

					if (v - 0.07) < 0 then
						NewColour = Color3.fromHSV(h, s, 0)
					else
						NewColour = Color3.fromHSV(h, s, v - 0.07)
					end

					Library:Tween(Dropdown["36"], {
						Length = 0.5,
						Goal = { Color = NewColour },
					})
				end)

				Dropdown["2f"].MouseLeave:Connect(function()
					Library:Tween(Dropdown["36"], {
						Length = 0.5,
						Goal = { Color = ThemeColor.Outline },
					})
				end)

				Dropdown["32"].MouseButton1Click:Connect(function()
					if Dropdown.ContainerOpened then
						Dropdown.ContainerOpened = false

						Library:Tween(Dropdown["2f"], {
							Length = 0.5,
							Goal = { Size = UDim2.fromOffset(505, 41) },
						})
					else
						Dropdown.ContainerOpened = true

						ResizeFrame()
					end
				end)

				Dropdown["38"].ChildAdded:Connect(function()
					if Dropdown.ContainerOpened then
						ResizeFrame()
					end
				end)

				Dropdown["38"].ChildRemoved:Connect(function()
					if Dropdown.ContainerOpened then
						ResizeFrame()
					end
				end)
			end

			-- Methods
			do
				function Dropdown:AddItem(value)
					local DropdownOption = {
						Hover = false,
						CallbackVal = value,
					}

					do
						-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Frame.Option
						DropdownOption["3d"] = Instance.new("TextButton", Dropdown["38"])
						DropdownOption["3d"]["TextSize"] = 12
						DropdownOption["3d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
						DropdownOption["3d"]["TextColor3"] = ThemeColor.Text
						DropdownOption["3d"]["Size"] = UDim2.new(0, 297, 0, 29)
						DropdownOption["3d"]["Name"] = [[Option]]
						DropdownOption["3d"]["Text"] = tostring(DropdownOption.CallbackVal)
						DropdownOption["3d"]["Font"] = Enum.Font.Gotham
						DropdownOption["3d"]["Position"] = UDim2.new(0.24455446004867554, 0, 0, 0)
						DropdownOption["3d"]["BackgroundTransparency"] = 1

						-- StarterGui.UiLib.Frame.MainFrame.Container.Dropdown.Frame.Option.Seperator
						DropdownOption["3e"] = Instance.new("Frame", DropdownOption["3d"])
						DropdownOption["3e"]["BorderSizePixel"] = 0
						DropdownOption["3e"]["BackgroundColor3"] = ThemeColor.Text
						DropdownOption["3e"]["BackgroundTransparency"] = 0.8999999761581421
						DropdownOption["3e"]["Size"] = UDim2.new(0, 253, 0, 1)
						DropdownOption["3e"]["Position"] = UDim2.new(0, 22, 0, 29)
						DropdownOption["3e"]["Name"] = [[Seperator]]

						ThemeInstances["Seperators"][#ThemeInstances["Seperators"] + 1] = DropdownOption["3e"]
					end

					DropdownOption["3d"].MouseButton1Click:Connect(function()
						task.spawn(function()
							options.Callback(DropdownOption.CallbackVal)
						end)

						Dropdown.SelectedItem = DropdownOption.CallbackVal
						Dropdown["41"].Text = tostring(Dropdown.SelectedItem)

						local Bound = TextService:GetTextSize(
							Dropdown["41"].Text,
							Dropdown["41"].TextSize,
							Dropdown["41"].Font,
							Vector2.new(Dropdown["41"].AbsoluteSize.X, Dropdown["41"].AbsoluteSize.Y)
						)

						Library:Tween(Dropdown["41"], {
							Length = 0.2,
							Goal = { Size = UDim2.new(0, (Bound.X + 14), 0, 22) },
						})
					end)

					if Dropdown.SelectedItem == nil then
						Dropdown.SelectedItem = DropdownOption.CallbackVal
						Dropdown["41"].Text = tostring(Dropdown.SelectedItem)

						local Bound = TextService:GetTextSize(
							Dropdown["41"].Text,
							Dropdown["41"].TextSize,
							Dropdown["41"].Font,
							Vector2.new(Dropdown["41"].AbsoluteSize.X, Dropdown["41"].AbsoluteSize.Y)
						)

						Library:Tween(Dropdown["41"], {
							Length = 0.2,
							Goal = { Size = UDim2.new(0, (Bound.X + 14), 0, 22) },
						})
					end
				end

				function Dropdown:Clear()
					for i, v in pairs(Dropdown["38"]:GetChildren()) do
						if v:IsA("TextButton") then
							v:Destroy()
						end
					end

					local FrameYOffset = 34 + 4
				end

				function Dropdown:UpdateList(options)
					options = Library:Place_Defaults({
						Items = {},
						Replace = true,
					}, options or {})

					if options.Replace then
						for i, v in pairs(Dropdown["38"]:GetChildren()) do
							if v:IsA("TextButton") then
								v:Destroy()
							end
						end
					end

					for i, v in pairs(options.Items) do
						Dropdown:AddItem(v)
					end
				end
			end

			do
				task.spawn(function()
					for i, v in pairs(options.Items) do
						Dropdown:AddItem(v)
					end
				end)
			end

			return Dropdown
		end

		function Tab:ThemeColorPicker(options)
			options = Library:Place_Defaults({
				ThemeColors = {},
				Callback = function()
					return
				end,
			}, options or {})

			local ThemeColorPicker = {
				ThemeColor = options.ThemeColors,
			}

			do
				-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPicker
				ThemeColorPicker["54"] = Instance.new("Frame", Tab["6"])
				ThemeColorPicker["54"]["ZIndex"] = 0
				ThemeColorPicker["54"]["BorderSizePixel"] = 0
				ThemeColorPicker["54"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
				ThemeColorPicker["54"]["Size"] = UDim2.new(0, 505, 0, 34)
				ThemeColorPicker["54"]["Position"] = UDim2.new(0.07563025504350662, 0, 0, 0)
				ThemeColorPicker["54"]["Name"] = [[ThemeColorPicker]]

				-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPicker.UICorner
				ThemeColorPicker["55"] = Instance.new("UICorner", ThemeColorPicker["54"])
				ThemeColorPicker["55"]["CornerRadius"] = UDim.new(0, 2)

				-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPicker.UIGradient
				ThemeColorPicker["56"] = Instance.new("UIGradient", ThemeColorPicker["54"])
				ThemeColorPicker["56"]["Rotation"] = 90
				ThemeColorPicker["56"]["Color"] = ThemeColor.Controls

				ThemeInstances["Controls"][#ThemeInstances["Controls"] + 1] = ThemeColorPicker["56"]

				-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPicker.Outline
				ThemeColorPicker["57"] = Instance.new("UIStroke", ThemeColorPicker["54"])
				ThemeColorPicker["57"]["Color"] = ThemeColor.Outline
				ThemeColorPicker["57"]["Name"] = [[Outline]]

				ThemeInstances["Outline"][#ThemeInstances["Outline"] + 1] = ThemeColorPicker["57"]

				-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPicker.UIListLayout
				ThemeColorPicker["58"] = Instance.new("UIListLayout", ThemeColorPicker["54"])
				ThemeColorPicker["58"]["SortOrder"] = Enum.SortOrder.LayoutOrder

				-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPicker.UIPadding
				ThemeColorPicker["5e"] = Instance.new("UIPadding", ThemeColorPicker["54"])
				ThemeColorPicker["5e"]["PaddingTop"] = UDim.new(0, 5)
			end

			ThemeColorPicker["54"].ChildAdded:Connect(function()
				local NumChild = 0

				for i, v in pairs(ThemeColorPicker["54"]:GetChildren()) do
					if v:IsA("Frame") then
						NumChild += 1
					end
				end

				local NewSize = NumChild * 24 + 10

				Library:Tween(ThemeColorPicker["54"], {
					Length = 0.5,
					Goal = { Size = UDim2.new(0, 505, 0, NewSize) },
				})
			end)

			-- Handler
			do
				local function makePickerObject(v, Color)
					local ColorName = tostring(v)

					local CurrentColor = Color

					local ThemeColorPickerObj = {}

					task.spawn(function()
						while task.wait() do
							if Gui.CurrentTheme[v] ~= CurrentColor then
								ThemeColorPickerObj["5b"]["BackgroundColor3"] = Gui.CurrentTheme[v]
								CurrentColor = Gui.CurrentTheme[v]
							end
						end
					end)

					-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPicker.ThemeColor
					ThemeColorPickerObj["59"] = Instance.new("Frame", ThemeColorPicker["54"])
					ThemeColorPickerObj["59"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
					ThemeColorPickerObj["59"]["BackgroundTransparency"] = 1
					ThemeColorPickerObj["59"]["Size"] = UDim2.new(0, 505, 0, 24)
					ThemeColorPickerObj["59"]["BorderColor3"] = Color3.fromRGB(28, 43, 54)
					ThemeColorPickerObj["59"]["Name"] = [[ThemeColor]]

					-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPicker.ThemeColor.NameLabel
					ThemeColorPickerObj["5a"] = Instance.new("TextLabel", ThemeColorPickerObj["59"])
					ThemeColorPickerObj["5a"]["TextWrapped"] = true
					ThemeColorPickerObj["5a"]["TextXAlignment"] = Enum.TextXAlignment.Left
					ThemeColorPickerObj["5a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
					ThemeColorPickerObj["5a"]["TextTransparency"] = 0.20000000298023224
					ThemeColorPickerObj["5a"]["TextSize"] = 11
					ThemeColorPickerObj["5a"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
					ThemeColorPickerObj["5a"]["Size"] = UDim2.new(0, 188, 0, 24)
					ThemeColorPickerObj["5a"]["Text"] = tostring(v) .. " Color"
					ThemeColorPickerObj["5a"]["Name"] = [[NameLabel]]
					ThemeColorPickerObj["5a"]["Font"] = Enum.Font.Gotham
					ThemeColorPickerObj["5a"]["BackgroundTransparency"] = 1
					ThemeColorPickerObj["5a"]["Position"] = UDim2.new(0.03366336598992348, 0, 0, 0)

					-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPickerObj.ThemeColor.Detector
					ThemeColorPickerObj["5b"] = Instance.new("TextButton", ThemeColorPickerObj["59"])
					ThemeColorPickerObj["5b"]["BorderSizePixel"] = 0
					ThemeColorPickerObj["5b"]["TextSize"] = 14
					ThemeColorPickerObj["5b"]["BackgroundColor3"] = Color
					ThemeColorPickerObj["5b"]["TextColor3"] = Color3.fromRGB(0, 0, 0)
					ThemeColorPickerObj["5b"]["Size"] = UDim2.new(0, 38, 0, 15)
					ThemeColorPickerObj["5b"]["Name"] = [[Detector]]
					ThemeColorPickerObj["5b"]["Text"] = [[]]
					ThemeColorPickerObj["5b"]["Font"] = Enum.Font.SourceSans
					ThemeColorPickerObj["5b"]["Position"] = UDim2.new(0.9007624387741089, 0, 0.16633352637290955, 0)

					-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPickerObj.ThemeColor.Detector.UICorner
					ThemeColorPickerObj["5c"] = Instance.new("UICorner", ThemeColorPickerObj["5b"])
					ThemeColorPickerObj["5c"]["CornerRadius"] = UDim.new(0, 4)

					-- StarterGui.UiLib.Frame.MainFrame.Settings.ThemeColorPickerObj.ThemeColor.HexLabel
					ThemeColorPickerObj["5d"] = Instance.new("TextLabel", ThemeColorPickerObj["59"])
					ThemeColorPickerObj["5d"]["TextWrapped"] = true
					ThemeColorPickerObj["5d"]["TextXAlignment"] = Enum.TextXAlignment.Left
					ThemeColorPickerObj["5d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255)
					ThemeColorPickerObj["5d"]["TextSize"] = 9
					ThemeColorPickerObj["5d"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
					ThemeColorPickerObj["5d"]["Size"] = UDim2.new(0, 102, 0, 24)
					ThemeColorPickerObj["5d"]["Text"] = [[#ef2424]]
					ThemeColorPickerObj["5d"]["Name"] = [[HexLabel]]
					ThemeColorPickerObj["5d"]["Font"] = Enum.Font.GothamMedium
					ThemeColorPickerObj["5d"]["BackgroundTransparency"] = 1
					ThemeColorPickerObj["5d"]["Position"] = UDim2.new(0.7980198264122009, 0, 0, 0)

					-- StarterGui.UiLib.ColorPicker.Textboxes.HEX.UIStroke
					ThemeColorPickerObj["7f"] = Instance.new("UIStroke", ThemeColorPickerObj["5b"])
					ThemeColorPickerObj["7f"]["Color"] = ThemeColor.Text
					ThemeColorPickerObj["7f"]["Transparency"] = 0.7
					ThemeColorPickerObj["7f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border

					ThemeInstances["Seperators"][#ThemeInstances["Seperators"] + 1] = ThemeColorPickerObj["7f"]
					ThemeColorPickerObj["5d"]["Text"] = "#"
						.. tostring(ThemeColorPickerObj["5b"]["BackgroundColor3"]:ToHex())

					ThemeColorPickerObj["5b"].MouseButton1Click:Connect(function()
						Library:ColorPicker(function(Color)
							ThemeColorPickerObj["5b"]["BackgroundColor3"] = Color
							CurrentColor = Color

							options.Callback(ColorName, ThemeColorPickerObj["5b"]["BackgroundColor3"])
							ThemeColorPickerObj["5d"]["Text"] = "#"
								.. tostring(ThemeColorPickerObj["5b"]["BackgroundColor3"]:ToHex())
						end, CurrentColor)
					end)

					return ThemeColorPickerObj
				end

				local function MakeObjects()
					for i, v in pairs(ThemeColorPicker.ThemeColor) do
						makePickerObject(i, v)
					end
				end

				MakeObjects()
			end

			-- Methods
			do
			end

			return ThemeColorPicker
		end

		--[[
			function Tab:Template(options)
				options = Library:Place_Defaults({
					Name = "Template",
					Callback = function() return end
				}, options or {})

				local Template = {
					Hover = false
				}

				do
				end

				-- Handler
				do
				end

				-- Methods
				do
					
				end

				return Template
			end
			]]
		--

		return Tab
	end

	-- Nav handle
	do
		Gui["5a"].MouseEnter:Connect(function()
			NavHover = true

			Library:Tween(Gui["4b"], {
				Length = 0.5,
				Goal = { Position = UDim2.new(0, 0, 0, 0) },
			})
		end)

		Gui["5a"].MouseLeave:Connect(function()
			NavHover = false
			local CompleteTweening = false

			Library:Tween(Gui["4b"], {
				Length = 0.5,
				Goal = { Position = UDim2.new(0, 50, 0, 0) },
			}, function()
				CompleteTweening = true
			end)

			repeat
				task.wait()
			until CompleteTweening
		end)

		Gui["2"].MouseEnter:Connect(function()
			Library.MainFrameHover = true
		end)

		Gui["2"].MouseLeave:Connect(function()
			Library.MainFrameHover = false
		end)

		function Gui:Toggled(bool)
			Gui.TweeningToggle = true
			if bool == nil then
				if Gui["2"].Visible then
					Library:Tween(Gui["2"], {
						Length = 1,
						Goal = { Size = UDim2.new(0, 645, 0, 0) },
					})

					task.wait(1)
					Gui["2"].Visible = false
				else
					Gui["2"].Visible = true
					Library:Tween(Gui["2"], {
						Length = 1,
						Goal = { Size = UDim2.new(0, 645, 0, 433) },
					})

					task.wait(1)
				end
			elseif bool then
				Gui["2"].Visible = true
				Library:Tween(Gui["2"], {
					Length = 1,
					Goal = { Size = UDim2.new(0, 645, 0, 433) },
				})

				task.wait(1)
			elseif not bool then
				Library:Tween(Gui["2"], {
					Length = 1,
					Goal = { Size = UDim2.new(0, 645, 0, 0) },
				})

				task.wait(1)
				Gui["2"].Visible = false
			end

			Gui.TweeningToggle = false
		end

		UserInputService.InputBegan:Connect(function(input)
			if Library.MainFrameHover then
				if input.UserInputType == Enum.UserInputType.MouseButton1 and not Library.Sliding then
					local ObjectPosition =
						Vector2.new(Mouse.X - Gui["2"].AbsolutePosition.X, Mouse.Y - Gui["2"].AbsolutePosition.Y)
					while
						RunService.RenderStepped:wait()
						and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
					do
						if not Library.Sliding then
							if Library.LockDragging then
								local FrameX, FrameY =
									math.clamp(
										Mouse.X - ObjectPosition.X,
										0,
										LibraryFrame.MainScreenGui.AbsoluteSize.X - Gui["2"].AbsoluteSize.X
									),
									math.clamp(
										Mouse.Y - ObjectPosition.Y,
										0,
										LibraryFrame.MainScreenGui.AbsoluteSize.Y - Gui["2"].AbsoluteSize.Y
									)

								Library:Tween(Gui["2"], {
									Goal = {
										Position = UDim2.fromOffset(
											FrameX + (Gui["2"].Size.X.Offset * Gui["2"].AnchorPoint.X),
											FrameY + (Gui["2"].Size.Y.Offset * Gui["2"].AnchorPoint.Y)
										),
									},
									Style = Enum.EasingStyle.Linear,
									Direction = Enum.EasingDirection.InOut,
									Length = Library.DragSpeed,
								})
							else
								Library:Tween(Gui["2"], {
									Goal = {
										Position = UDim2.fromOffset(
											Mouse.X
												- ObjectPosition.X
												+ (Gui["2"].Size.X.Offset * Gui["2"].AnchorPoint.X),
											Mouse.Y
												- ObjectPosition.Y
												+ (Gui["2"].Size.Y.Offset * Gui["2"].AnchorPoint.Y)
										),
									},
									Style = Enum.EasingStyle.Linear,
									Direction = Enum.EasingDirection.InOut,
									Length = Library.DragSpeed,
								})
							end
						end
					end
				end
			end
		end)

		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Gui.ToggleKey then
				if not Gui.TweeningToggle then
					Gui:Toggled()
				end
			end
		end)
	end

	function Gui:SetTheme(Theme)
		Theme = Library:Place_Defaults({
			Main = Color3.fromRGB(36, 38, 43),
			Secondary = Color3.fromRGB(22, 23, 26),
			Tertiary = Color3.fromRGB(20, 23, 25),
			Text = Color3.fromRGB(255, 255, 255),
			Controls = Color3.fromRGB(37, 40, 45),
		}, Theme or {})

		Gui.CurrentTheme = Theme

		local function calLabelGradient(BaseColor)
			local h, s, v = BaseColor:ToHSV()

			local p0
			local p1

			if (v + 0.02) > 1 then
				p0 = Color3.fromHSV(h, s, 1)
			else
				p0 = Color3.fromHSV(h, s, v + 0.02)
			end

			if (v + 0.01) > 1 then
				p1 = Color3.fromHSV(h, s, 1)
			else
				p1 = Color3.fromHSV(h, s, v + 0.01)
			end

			return ColorSequence.new({ ColorSequenceKeypoint.new(0.000, p0), ColorSequenceKeypoint.new(1.000, p1) })
		end

		local Gradients = {
			Main = Library:CalGradient(Theme.Main),
			Secondary = Library:CalGradient(Theme.Secondary),
			Controls = Library:CalControlsGradient(Theme.Controls),
			Label = calLabelGradient(Theme.Secondary),
		}

		local OutlineC

		do
			local h, s, v = Theme.Controls:ToHSV()

			if (v - 0.02) < 0 then
				OutlineC = Color3.fromHSV(h, s, 0)
			else
				OutlineC = Color3.fromHSV(h, s, v - 0.02)
			end
		end

		ThemeColor.Main = Gradients.Main
		ThemeColor.Secondary = Gradients.Secondary
		ThemeColor.Text = Theme.Text
		ThemeColor.Controls = Gradients.Controls
		ThemeColor.Outline = OutlineC
		ThemeColor.Label = Gradients.Label
		ThemeColor.Indicator = Theme.Tertiary
		ThemeColor.BaseMainColor = Theme.Main

		for i, v in next, ThemeInstances.Seperators do
			pcall(function()
				v.BackgroundColor3 = ThemeColor.Text
			end)
			pcall(function()
				v.Color = ThemeColor.Text
			end)
		end

		for i, v in next, ThemeInstances.Controls do
			v.Color = ThemeColor.Controls
		end

		for i, v in next, ThemeInstances.Outline do
			v.Color = ThemeColor.Outline
		end

		for i, v in next, ThemeInstances.Label do
			v.Color = ThemeColor.Label
		end

		for i, v in next, ThemeInstances.Indicators do
			v.BackgroundColor3 = ThemeColor.Indicator
		end

		ThemeInstances.MainFrame.Color = ThemeColor.Main
		ThemeInstances.NavFrame.Color = ThemeColor.Secondary

		for i, v in next, LibraryFrame.MainScreenGui:GetDescendants() do
			pcall(function()
				if not (v.Name == "Indicator") then
					if not (v.Name == "TextBox") then
						if not (v.Name == "ValLabel") then
							v.TextColor3 = ThemeColor.Text
						end
					end
				end
			end)
		end
	end

	-- SettingsTab
	do
		Gui.SettingsTab = Gui:Tab({
			Name = "Settings",
			Description = "Customize it to your favor!",
			Icon = "rbxassetid://11254763826",
			Color = Color3.new(0.364706, 0.811765, 0.262745),
			Hidden = true,
		})

		Gui.SettingsTab:Section({
			Name = "Library",
		})

		Gui.SettingsTab:Button({
			Name = "Destroy library",
			Callback = function()
				Library:Destroy()
			end,
		})

		Gui.SettingsTab:Section({
			Name = "Dragging customization",
		})

		Gui.SettingsTab:Toggle({
			Name = "Dragging Boundary",
			Default = true,
			Callback = function(bool)
				Library.LockDragging = bool
			end,
		})

		Gui.SettingsTab:Slider({
			Name = "Dragging Speed",
			Min = 0,
			Max = 100,
			Default = 93,
			Callback = function(val)
				Library.DragSpeed = 1 - (val / 100)
			end,
		})

		Gui.SettingsTab:Section({
			Name = "Gui Theme",
		})

		Gui.SettingsTab:ThemeColorPicker({
			ThemeColors = {
				Main = Color3.fromRGB(36, 38, 43),
				Secondary = Color3.fromRGB(22, 23, 26),
				Tertiary = Color3.fromRGB(20, 23, 25),
				Text = Color3.fromRGB(255, 255, 255),
				Controls = Color3.fromRGB(37, 40, 45),
			},
			Callback = function(Name, Color)
				Gui.CurrentTheme[Name] = Color

				Gui:SetTheme(Gui.CurrentTheme)
			end,
		})

		Gui.SettingsTab:Button({
			Name = "Export Theme as JSON",
			Callback = function()
				local TostringTheme = {}

				for i, v in next, Gui.CurrentTheme do
					TostringTheme[i] = tostring(v)
				end

				local EncodedTheme = game:GetService("HttpService"):JSONEncode(TostringTheme)
				if setclipboard then
					setclipboard(EncodedTheme)
					Gui:Notify({
						Name = "Theme System",
						Text = "Theme Copied to clipboard!",
						Duration = 5,
						Callback = function()
							return
						end,
					})
				else
					Gui:Notify({
						Name = "Theme System",
						Text = "Your executor does not support setclipboard!",
						Duration = 5,
						Callback = function()
							return
						end,
					})
				end
			end,
		})

		Gui.SettingsTab:Textbox({
			Name = "Import Theme JSON",
			Default = "",
			Callback = function(txt)
				--- Decodes a string into a Color3 structure.
				--- @param Color3String string The string to try and decode.
				--- @return Color3 decodedColor The decoded color as an object.
				local function decodeColor3(Color3String)
					local splitString = string.split(Color3String, ",")
					local newColor3 = Color3.new(splitString[1], splitString[2], splitString[3])
					return newColor3
				end

				local success, result = pcall(function()
					game:GetService("HttpService"):JSONDecode(txt)
				end)

				if success then
					local NewTheme = game:GetService("HttpService"):JSONDecode(txt)
					for i, v in next, NewTheme do
						NewTheme[i] = decodeColor3(v)
					end

					Gui:SetTheme(NewTheme)
					Gui:Notify({
						Name = "Theme System",
						Text = "Imported Theme!",
						Duration = 5,
						Callback = function()
							return
						end,
					})
				else
					Gui:Notify({
						Name = "Theme System",
						Text = "Invalid theme JSON!",
						Duration = 5,
						Callback = function()
							return
						end,
					})
				end
			end,
		})

		Gui["4e"].MouseButton1Click:Connect(function()
			Gui.SettingsTab:Activate()
		end)
	end

	Gui:SetTheme()

	return Gui
end

return Library
