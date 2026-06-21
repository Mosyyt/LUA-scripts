local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local LocalPlayerCharacter = PlayerService.LocalPlayer.Character or PlayerService.LocalPlayer.CharacterAdded:Wait()
PlayerService.LocalPlayer.CharacterAdded:Connect(function(character)
	LocalPlayerCharacter = character
end)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()

local Window = Fluent:CreateWindow({
	Title = "Residence Masacre",
	SubTitle = "by Codexus Hub",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.Insert, -- Used when theres no MinimizeKeybind
})

local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "code-2" }),
	Visuals = Window:AddTab({ Title = "Visuals", Icon = "view" }),
	Credits = Window:AddTab({ Title = "Credits", Icon = "thumbs-up" }),
	Misc = Window:AddTab({ Title = "Miscellaneous", Icon = "book-mark" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

Fluent:Notify({
	Title = "GUI Loaded!",
	Content = "The GUI has been loaded! Thanks for using it, " .. LocalPlayer.DisplayName .. "!",
	Duration = 5, -- Set to nil to make the notification not disappear
})

function initialiseMain(tabs)
	--- @type thread | nil
	local autoWireFixerThread = nil
	local autoWireFixerToggle = tabs.Main:AddToggle(
		"auto_wire",
		{ Title = "Enable Auto Wire", Description = "Automatically completes the wire mini-game", Default = false }
	)

	autoWireFixerToggle:OnChanged(function()
		if autoWireFixerThread then
			task.cancel(autoWireFixerThread)
		end
		if Options.auto_wire.Value then
			autoWireFixerThread = task.spawn(function()
				while task.wait(0.5) do
					local wireRemote = game:GetService("ReplicatedStorage").Remotes.ClickWire
					for i, v in pairs(game:GetService("Workspace").FuseBox.Wires:GetChildren()) do
						for i, p in pairs(v:GetChildren()) do
							if p:IsA("ParticleEmitter") then
								if p.Enabled then
									wireRemote:FireServer(p.Parent)
								end
							end
						end
					end
				end
			end)
		end
	end)

	--- @type RBXScriptConnection | nil
	local infiniteStaminaConnection = nil
	local infiniteStaminaToggle = tabs.Main:AddToggle(
		"inf_stamina",
		{ Title = "Enable Infinite Stamina", Description = "Bypasses the Stamina limit", Default = false }
	)

	infiniteStaminaToggle:OnChanged(function()
		if infiniteStaminaConnection and infiniteStaminaConnection.Connected then
			infiniteStaminaConnection:Disconnect()
		end

		if Options.inf_stamina.Value then
			infiniteStaminaConnection = LocalPlayer.Character
				:WaitForChild("Sprint")
				:WaitForChild("Stam")
				:GetPropertyChangedSignal("Value")
				:Connect(function()
					local stamina = LocalPlayer.Character.Sprint.Stam

					if stamina.Value < 4.5 then
						stamina.Value = 4.5
					end
				end)
		end
	end)

	--- @type RBXScriptConnection | nil
	local infiniteStaminaConnection = nil
	local infiniteStaminaToggle = tabs.Main:AddToggle(
		"inf_oxy",
		{ Title = "Enable Infinite Oxygen", Description = "Bypasses the Oxygen limit", Default = false }
	)

	infiniteStaminaToggle:OnChanged(function()
		if infiniteStaminaConnection and infiniteStaminaConnection.Connected then
			infiniteStaminaConnection:Disconnect()
		end

		if Options.inf_oxy.Value then
			infiniteStaminaConnection = LocalPlayer.Character
				:WaitForChild("Breath")
				:GetPropertyChangedSignal("Value")
				:Connect(function()
					local breath = LocalPlayer.Character.Breath

					if breath.Value < 19 then
						breath.Value = 19
					end
				end)
		end
	end)

	--- @type RBXScriptConnection | nil
	local autoPowerConnection = nil
	local autoPowerToggle = tabs.Main:AddToggle(
		"auto_pow",
		{ Title = "Automatic Power", Description = "Automatically refuels the power for Oxygen", Default = false }
	)

	autoPowerToggle:OnChanged(function()
		if autoPowerConnection and autoPowerConnection.Connected then
			autoPowerConnection:Disconnect()
		end

		local fuel = workspace.Shack.Generator.Fuel

		if fuel.Value < 80 then
			task.wait()
			local clickDetector = workspace.Shack.JerryCan:FindFirstChildOfClass("ClickDetector")
			fireclickdetector(clickDetector)
			task.wait(0.01)
			clickDetector = workspace.Shack.Generator:FindFirstChildOfClass("ClickDetector")
			fireclickdetector(clickDetector)
		end

		if Options.auto_pow.Value then
			autoPowerConnection = workspace.Shack.Generator.Fuel:GetPropertyChangedSignal("Value"):Connect(function()
				if fuel.Value < 80 then
					task.wait()
					local clickDetector = workspace.Shack.JerryCan:FindFirstChildOfClass("ClickDetector")
					fireclickdetector(clickDetector)
					task.wait(0.01)
					clickDetector = workspace.Shack.Generator:FindFirstChildOfClass("ClickDetector")
					fireclickdetector(clickDetector)
				end
			end)
		end
	end)

	--- @type thread | nil
	local windowNotifierThread = nil
	local windowNotifierToggle = tabs.Main:AddToggle("window_notifier", {
		Title = "Enable Window Notifier",
		Description = "Notifies you when the Mutant is on the Window",
		Default = false,
	})

	windowNotifierToggle:OnChanged(function()
		if windowNotifierThread then
			task.cancel(windowNotifierThread)
		end

		if Options.window_notifier.Value then
			windowNotifierThread = task.spawn(function()
				local mutant = workspace:FindFirstChild("Mutant")
				local windows = workspace:FindFirstChild("Windows"):GetChildren()
				while task.wait() do
					for _, window in pairs(windows) do
						local windowPivot = window:GetPivot()
						local winPos = windowPivot.Position
						local monsterPivot = mutant:GetPivot()
						local monsterPos = monsterPivot.Position

						if (winPos - monsterPos).Magnitude <= 5 then
							Fluent:Notify({
								Title = "The Mutant is on the Window!",
								Content = "The mutant appears to be on the Window that gives to the room '"
									.. window.RoomName.Value
									.. "' of the house, go scare it! ASAP!",
								Duration = 5, -- Set to nil to make the notification not disappear
							})
							task.wait(5)
						end
					end
				end
			end)
		end
	end)

	--- @type thread | nil
	local autoPlayThread = nil
	local autoPlayToggle = tabs.Main:AddToggle("auto_play", {
		Title = "Enable Auto Play",
		Description = "Plays the game for you, detects when the Mutant is on a Window, and turns on the light for the room, Automatically!",
		Default = false,
	})

	autoPlayToggle:OnChanged(function()
		if autoPlayThread then
			task.cancel(autoPlayThread)
		end

		if Options.auto_play.Value then
			autoPlayThread = task.spawn(function()
				local mutant = workspace:FindFirstChild("Mutant")
				local windows = workspace:FindFirstChild("Windows"):GetChildren()
				local lights = workspace:FindFirstChild("Lights"):GetChildren()
				while task.wait() do
					for _, window in pairs(windows) do
						local windowPivot = window:GetPivot()
						local winPos = windowPivot.Position
						local monsterPivot = mutant:GetPivot()
						local monsterPos = monsterPivot.Position

						local windowRoomName = window.RoomName.Value
						if (winPos - monsterPos).Magnitude <= 5 then
							Fluent:Notify({
								Title = "The Mutant is on the Window!",
								Content = "The mutant appears to be on the Window that gives to the room '"
									.. windowRoomName
									.. "' of the house, turning light on automatically!",
								Duration = 5, -- Set to nil to make the notification not disappear
							})

							local targetClickDetector = nil

							for _, light in pairs(lights) do
								local lightCfg = light:FindFirstChildOfClass("Configuration")

								if lightCfg.RoomName.Value == windowRoomName then
									targetClickDetector = light.Switch.Detector:FindFirstChildOfClass("ClickDetector")
									break
								end
							end

							fireclickdetector(targetClickDetector)
							task.wait(1)
							fireclickdetector(targetClickDetector)
							task.wait(1)
							task.wait(3)
						end
					end
				end
			end)
		end
	end)

	Tabs.Main:AddButton({
		Title = "Auto Camera",
		Description = "Claims all the cameras for the games' camera system",
		Callback = function()
			local claimedCameras = 0
			for index, value in pairs(game:GetService("Workspace").TempCameras:GetChildren()) do
				local detector = value:FindFirstChildOfClass("ClickDetector")
				if not detector then
					Fluent:Notify({
						Title = "Huh, this is weird...",
						Content = "We did not expect this, but a camera is missing something for us to claim it!",
						Duration = 5, -- Set to nil to make the notification not disappear
					})
				else
					detector.MaxActivationDistance = 69420
					task.wait(0.1)
					fireclickdetector(detector)
					claimedCameras = claimedCameras + 1
				end
			end

			if claimedCameras > 0 then
				Fluent:Notify({
					Title = "All " .. claimedCameras .. " have been claimed!",
					Content = "All the available cameras have been claimed and can now be accessed on the in-game camera system!",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			else
				Fluent:Notify({
					Title = "All cameras were already claimed before!",
					Content = "All the available cameras were already claimed, there was no need to use this!",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			end
		end,
	})

	tabs.Main:AddButton({
		Title = "Get all items",
		Description = "Gets all the items in the game. If you get none, first use the Radio to do things work",
		Callback = function()
			for _, child in pairs(workspace.Doors:GetChildren()) do
				if child.Name == "Door" then
					for _, descendant in pairs(child:GetDescendants()) do
						if descendant and descendant:IsA("ClickDetector") then
							fireclickdetector(descendant)
						end
					end
				end
			end

			-- The player hasn't grabbed a flashlight.
			if not LocalPlayerCharacter:FindFirstChild("Flashlight") then
				if
					workspace:FindFirstChild("Flashlight")
					and workspace.Flashlight.Handle:FindFirstChildOfClass("ClickDetector")
				then
					fireclickdetector(workspace.Flashlight.Handle:FindFirstChildOfClass("ClickDetector"))
				end

				task.wait(1)
			end

			for _, descendant in pairs(workspace.ItemSpots:GetDescendants()) do
				if descendant and descendant:IsA("ClickDetector") then
					fireclickdetector(descendant)
				end
			end
		end,
	})

	tabs.Main:AddButton({
		Title = "Toggle All Doors",
		Description = "This will Open or Close all the doors in the game",
		Callback = function()
			for _, child in pairs(workspace.Doors:GetChildren()) do
				if child.Name == "Door" then
					for _, descendant in pairs(child:GetDescendants()) do
						if descendant and descendant:IsA("ClickDetector") then
							fireclickdetector(descendant)
						end
					end
				end
			end
		end,
	})

	tabs.Main:AddButton({
		Title = "Toggle All Closets",
		Description = "This will Open or Close all the closets in the game [Trolling time]",
		Callback = function()
			for _, child in pairs(workspace.Doors:GetChildren()) do
				if child.Name == "Closet" then
					for _, descendant in pairs(child:GetDescendants()) do
						if descendant and descendant:IsA("ClickDetector") then
							fireclickdetector(descendant)
						end
					end
				end
			end
		end,
	})

	tabs.Main:AddButton({
		Title = "Infinite Flashlight Battery",
		Description = "Makes your Flashlight battery infinite (Requires Flashlight)",
		Callback = function()
			local flashlight = LocalPlayerCharacter:FindFirstChild("Flashlight")

			if not flashlight then
				Fluent:Notify({
					Title = "No Flashlight Found!",
					Content = "The script has not found a flashlight on you, did you grab it?",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
				return
			end
			local batteryNumValue = flashlight:FindFirstChild("Battery")
			local flashlightCharges = flashlight:FindFirstChild("Charges")
			local isUpgradedFlashlight = flashlight:FindFirstChild("Upgraded")

			if batteryNumValue then
				batteryNumValue.Value = math.huge
			end
			if flashlightCharges then
				flashlightCharges.Value = math.huge
			end
			if isUpgradedFlashlight then
				isUpgradedFlashlight.Value = true
			end
		end,
	})

	local enableFBright = false
	Tabs.Main:AddButton({
		Title = "Full Bright",
		Description = "Enables Full Bright",
		Callback = function()
			task.wait(0.1)
			local lightService = game:GetService("Lighting")
			if lightService:FindFirstChild("Atmosphere") then
				lightService.Atmosphere.Density = 0
				lightService.Atmosphere.Haze = 1
				lightService.Ambient = Color3.fromRGB(128, 128, 128)
			end

			if lightService:FindFirstChild("BloodSky") then
				lightService.BloodSky:Destroy()
				Fluent:Notify({
					Title = "Full Bright",
					Content = "The blood sky has been removed as part of the Full Bright",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			end

			enableFBright = true
		end,
	})

	local oldHook
	oldHook = hookmetamethod(
		game,
		"__index",
		newcclosure(function(...)
			if not enableFBright or checkcaller() then
				return oldHook(...)
			end

			local table = select(1, ...)
			local index = select(2, ...)

			if not table or not index then
				return oldHook(...)
			end

			if tostring(table) == "Atmosphere" and index == "Density" then
				return 0
			end

			if tostring(table) == "Atmosphere" and index == "Haze" then
				return 1
			end

			if tostring(table) == "Lighting" and index == "Ambient" then
				return Color3.fromRGB(140, 140, 140)
			end

			return oldHook(...)
		end)
	)

	local oldNewIndexHook
	oldNewIndexHook = hookmetamethod(
		game,
		"__newindex",
		newcclosure(function(...)
			if not enableFBright or checkcaller() then
				return oldNewIndexHook(...)
			end

			local table = select(1, ...)
			local index = select(2, ...)
			local value = select(3, ...)

			if not table or not index or not value then
				return oldNewIndexHook(...)
			end

			if tostring(table) == "Atmosphere" and index == "Density" then
				return value
			end

			if tostring(table) == "Atmosphere" and index == "Haze" then
				return value
			end

			if tostring(table) == "Lighting" and index == "ClockTime" then
				return value
			end

			if tostring(table) == "Lighting" and index == "Ambient" then
				return value
			end

			return oldNewIndexHook(...)
		end)
	)
end

function initialiseVisuals(tabs)
	local monsterEspToggle = tabs.Visuals:AddToggle(
		"monster_esp",
		{ Title = "Monster ESP", Description = "ESP for the Mutant, the Main enemy of the game", Default = false }
	)

	monsterEspToggle:OnChanged(function()
		local function CreateContainer()
			local folder = Instance.new("Folder", gethui())
			folder.Name = "Container"
			return folder
		end

		if Options.monster_esp.Value then
			local monster = game:GetService("ReplicatedStorage"):FindFirstChild("Mutant")

			if not monster then
				monster = workspace:FindFirstChild("Mutant")
			end

			local target = monster:IsA("ObjectValue") and monster.Value or monster

			if not target then
				error("Failed to find monster for ESP!")
			end

			local container = gethui():FindFirstChild("Container") or CreateContainer()

			local highlight = Instance.new("Highlight", container) -- Create highlight, parent to gethui() to avoid possible detections!
			highlight.Adornee = target
			highlight.FillColor = Color3.fromRGB(41, 21, 0)
			highlight.FillTransparency = 0.5
			highlight.OutlineColor = Color3.fromRGB(206, 54, 54)

			local bill = Instance.new("BillboardGui", container)
			bill.AlwaysOnTop = true
			bill.Enabled = true
			bill.Adornee = target
			bill.LightInfluence = 1
			bill.Size = UDim2.new(0, 20, 0, 20)

			local frame = Instance.new("Frame", bill)

			local text = Instance.new("TextLabel", frame)
			text.Name = "lmap!"
			text.TextSize = 24
			text.Size = UDim2.new(0, 30, 0, 30)
			text.BackgroundTransparency = 1
			text.Font = Enum.Font.SourceSansBold
			text.TextScaled = true
			text.TextWrapped = true
			text.Text = "Silly Goose"
			text.TextColor3 = Color3.new(1, 1, 1)
		else
			if gethui():FindFirstChild("Container") then
				gethui().Container:Destroy()
			end
		end
	end)

	local playerEspToggle = tabs.Visuals:AddToggle(
		"player_esp",
		{ Title = "Players ESP", Description = "ESP for the players, your allies... hopefully (LOL)", Default = false }
	)

	playerEspToggle:OnChanged(function()
		local function CreateContainer()
			local folder = Instance.new("Folder", gethui())
			folder.Name = "Players_Container"
			return folder
		end

		local function GetPlayerCharacters()
			local chars = {}
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				if player ~= LocalPlayer then
					table.insert(chars, player.Character)
				end
			end
			return chars
		end

		if Options.player_esp.Value then
			local playerCharacters = GetPlayerCharacters()

			local container = gethui():FindFirstChild("Players_Container") or CreateContainer()

			for _, target in pairs(playerCharacters) do
				local folder = Instance.new("Folder", container)
				local highlight = Instance.new("Highlight", folder) -- Create highlight, parent to gethui() to avoid possible detections!
				highlight.Adornee = target
				highlight.FillColor = Color3.fromRGB(128, 167, 104)
				highlight.FillTransparency = 0.5
				highlight.OutlineColor = Color3.fromRGB(54, 62, 206)

				local bill = Instance.new("BillboardGui", folder)
				bill.AlwaysOnTop = true
				bill.Enabled = true
				bill.Adornee = target
				bill.LightInfluence = 1
				bill.Size = UDim2.new(0, 20, 0, 20)

				local frame = Instance.new("Frame", bill)

				local text = Instance.new("TextLabel", frame)
				text.Name = "plrname"
				text.TextSize = 24
				text.Size = UDim2.new(0, 30, 0, 30)
				text.BackgroundTransparency = 1
				text.Font = Enum.Font.SourceSansBold
				text.TextScaled = true
				text.TextWrapped = true
				text.Text = target.Name
				text.TextColor3 = Color3.new(1, 1, 1)
				target.Destroying:Connect(function()
					folder:Destroy()
				end)
			end
		else
			if gethui():FindFirstChild("Players_Container") then
				gethui().Players_Container:Destroy()
			end
		end
	end)
end

function initialiseCredits(tabs)
	tabs.Credits:AddParagraph({
		Title = "Hello! Thanks for using Codexus Hub!",
	})
end

function initialiseMisc(tabs)
	tabs.Misc:AddButton({
		Title = "Anti AFK",
		Description = "Prevents the game from kicking you due to inactivity",
		Callback = function()
			for _, f in pairs(getconnections(LocalPlayer.Idled)) do
				f:Disable()
			end
			Fluent:Notify({
				Title = "Anti AFK Loaded!",
				Content = "The game will no longer kick you due to inactivity!",
				Duration = 5, -- Set to nil to make the notification not disappear
			})
		end,
	})

	tabs.Misc:AddButton({
		Title = "Bypass BTools and Fly Anti Cheat",
		Description = "Bypasses the Anti-Fly and Anti-BTools",
		Callback = function()
			local foundTargets = false
			for _, closure in pairs(getgc(false)) do
				if typeof(closure) == "function" and islclosure(closure) and not isexecutorclosure(closure) then
					local constants = debug.getconstants(closure)

					for _, v in pairs(constants) do
						if typeof(v) == "string" then
							if v:find("Possible exploit") or v:find("Fly script") or v:find("Btools") then
								hookfunction(closure, function()
									print("hi dev, your ac sucks :heart:")
								end)
								foundTargets = true
							end
						end
					end
				end
			end

			if foundTargets then
				Fluent:Notify({
					Title = "Bypass Loaded!",
					Content = "The game will no longer try to kick you if you try to fly or use BTools!",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			else
				Fluent:Notify({
					Title = "Bypass Failed to Load!",
					Content = "The bypass has failed to load, perhaps the game was updated and the bypass, patched!",
					Duration = 5, -- Set to nil to make the notification not disappear
				})
			end
		end,
	})

	tabs.Misc:AddButton({
		Title = "Server Hop",
		Description = "Hops game servers",
		Callback = function()
			game:GetService("TeleportService"):Teleport(game.PlaceId)
		end,
	})
end

function initialiseEverything()
	initialiseMain(Tabs)
	initialiseVisuals(Tabs)
	initialiseCredits(Tabs)
	initialiseMisc(Tabs)

	SaveManager:SetLibrary(Fluent)
	InterfaceManager:SetLibrary(Fluent)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({})
	InterfaceManager:SetFolder("CodexusHubFree")
	SaveManager:SetFolder("CodexusHubFree/ResidenceMassacre")
	InterfaceManager:BuildInterfaceSection(Tabs.Settings)
	SaveManager:BuildConfigSection(Tabs.Settings)
	Window:SelectTab(1)
	SaveManager:LoadAutoloadConfig()
end

initialiseEverything()
