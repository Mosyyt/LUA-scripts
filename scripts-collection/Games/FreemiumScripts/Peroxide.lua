--! THIS SCRIPT IS NO LONGER MAINTAINED BY CODEXUS HUB! ALL DEVELOPMENT FOR THIS SCRIPT HAS BEEN CEASED.

function IsKeySystemLink()
	if LRM_UserNote then
		return LRM_UserNote == "not_premium"
	else
		error("Luarmor variables missing. This may not be a Luarmor environment.")
	end
	--[[
        -- Example for Key System checking.
        if IsKeySystemLink() then
            game:GetService("Players").LocalPlayer:Kick("[Loader] Unauthorized. This script is Premium Only | Get it on our Discord!")
        end
    ]]
end

function LPH_NO_VIRTUALIZE(...)
	return ...
end
function LPH_NO_UPVALUES(...)
	return ...
end

task.wait(3)

--- #region Shared Variables

--- #region Services
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local LocalPlayerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalPlayerHumanoid = LocalPlayerCharacter:WaitForChild("Humanoid")
local Player_CharacterRootPart = LocalPlayerCharacter:WaitForChild("HumanoidRootPart")

local SimplePath = loadstring(game:HttpGet("https://pastebin.com/raw/gJbzZ2Yr"))()
local UILibrary = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua")
)()

--- #endregion Shared Variables

--- Initialises base connections and initial functions for the script to perform as expected.
function initialise_connections_and_initialise_functions()
	LocalPlayer.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		LocalPlayerCharacter = character
		LocalPlayerHumanoid = character:WaitForChild("Humanoid")
		Player_CharacterRootPart = character:WaitForChild("HumanoidRootPart")
	end)

	local function UpdateNames()
		for _, child in pairs(workspace.Live:GetChildren()) do
			if child:FindFirstChild("Stats") then
				local underscoreIndex = string.find(child.Name, "_")
				if underscoreIndex then
					local newName = string.sub(child.Name, 1, underscoreIndex - 1)
					child.Name = newName
				end
			end
		end
	end
	workspace.Live.ChildAdded:Connect(UpdateNames)

	UpdateNames()

	--[[
		-- This anticheat bypass has been patched.
		task.spawn(function()
				local function disable()
				local ctxErrorConnections = getconnections(game:GetService("ScriptContext").Error)

				for _, c in ctxErrorConnections do
					hookfunction(c.Function, function() end)
				end
			end
			
			disable()

			while task.wait(1) do
				disable()
			end
		end)
	]]
end

local CODEXUS_SHARED_STATE = {
	--- The key per-server.
	--- Used for remote firing.
	RemotesKey = nil,
}

--- Initialises function hooks and metamethod hook.
function initialiseHooks()
	local anticheat
	anticheat = hookmetamethod(
		game,
		"__index",
		newcclosure(LPH_NO_VIRTUALIZE(function(...)
			local self, k = select(1, ...), select(2, ...)
			if not checkcaller() and k == "WalkSpeed" and self.Name == "Humanoid" and self:IsA("Humanoid") then
				return game.Players.LocalPlayer.Character.Humanoid.WalkSpeed
			elseif not checkcaller() and k == "JumpPower" and self.Name == "Humanoid" and self:IsA("Humanoid") then
				return game.Players.LocalPlayer.Character.Humanoid.JumpPower
			elseif not checkcaller() and k == "Jumping" and self.Name == "Humanoid" and self:IsA("Humanoid") then
				return false
			end
			return anticheat(...)
		end))
	)

	--- Hook used to obtain the remote key programatically.
	local keyHook
	keyHook = hookmetamethod(
		game,
		"__namecall",
		newcclosure(LPH_NO_VIRTUALIZE(function(...)
			if CODEXUS_SHARED_STATE.RemotesKey or checkcaller() then
				return keyHook(...) -- No reason to add indirection, we already have the remote's key
			end

			local self = select(1, ...)
			local argTable = select(2, ...)

			if
				(self and argTable and typeof(argTable) == "table")
				and getnamecallmethod() == "FireServer"
				and self.Name == "Input" -- Input remote, target.
				and rawget(argTable, "Key")
			then
				rawset(CODEXUS_SHARED_STATE, "RemotesKey", argTable.Key)
			end

			return keyHook(...)
		end))
	)
end

--- Tweens to a position safely abusing the PathFinding service.
local function TweenToTargetPosition(character, target)
	print("pathfinding")
	local path = PathfindingService:CreatePath({
		AgentRadius = 5,
		AgentHeight = 15,
		AgentCanJump = true,
		AgentCanClimb = true,
		-- The less, the more detailed the path will be, and the more natural it will feel... or will it?
		WaypointSpacing = 50,
	})

	local pathfindingActor = SimplePath.new(character)
	pathfindingActor.Visualze = true

	pathfindingActor.Blocked:Connect(function()
		pathfindingActor:Run(character)
	end)

	pathfindingActor.WaypointReached:Connect(function()
		pathfindingActor:Run(character)
	end)

	pathfindingActor.Error:Connect(function(erType)
		print(erType)
		pathfindingActor:Run(character)
	end)

	if true then
		return pathfindingActor:Run(character)
	end

	local worked, msg = pcall(function()
		path:ComputeAsync(character.HumanoidRootPart.CFrame.Position, target)
	end)

	if not worked then
		print(msg)
		print("failed to do path of " .. (character.HumanoidRootPart.CFrame.Position - target).Magnitude)
		return path.Status
	end

	if path.Status ~= Enum.PathStatus.Success then
		return path.Status
	end

	local waypoints = path:GetWaypoints()
	local oldWs = character:FindFirstChildOfClass("Humanoid").WalkSpeed

	print(tostring(path.Status))
	print("traversing " .. #waypoints)
	for _, waypoint in ipairs(waypoints) do
		local targetPosition = waypoint.Position
		if false then --! Maybe we can paywall the Tweening, and use normal walking if not premium.
			local tweenInfo = TweenInfo.new(
				(targetPosition - character.HumanoidRootPart.Position).Magnitude / 50, -- Move at 50 studs/s
				Enum.EasingStyle.Linear
			)
			local tween = TweenService:Create(
				character.HumanoidRootPart,
				tweenInfo,
				{ CFrame = CFrame.new(waypoint.Position + Vector3.new(0, 10, 0)) }
			)
			tween:Play()
			tween.Completed:Wait()
		else
			--! Possible implementation for free users (If we ever use it!);
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			humanoid.WalkSpeed = 50
			humanoid:MoveTo(targetPosition)

			local completed = false
			humanoid.MoveToFinished:Once(function()
				completed = true
			end)

			local waited = 0
			while waited < 2 and not completed do
				waited = waited + task.wait(0.05)
			end

			if not completed then
				-- Pathfinding failure, handle somehow.
				print("path fail")
			else
				print("path success")
			end
		end
	end
	if oldWs then
		character:FindFirstChildOfClass("Humanoid").WalkSpeed = oldWs
	end

	return path.Status
end

function initialiseMain(window)
	-- Tab
	local MainTab = window:Tab({
		Name = "Main",
		Description = "~~ Peroxide ~~ | ~~ Codexus Hub ~~",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	-- Section
	local Section = MainTab:Section({ Name = "Main Functionality" })

	--- #region Mob Farming

	local MobTable = {}
	local selectedMob
	local function UpdateMobTable()
		MobTable = {}
		for _, v in pairs(workspace.Live:GetChildren()) do
			local chestName = v.Name
			if not table.find(MobTable, chestName) and v:IsA("Model") then
				if LocalPlayer:DistanceFromCharacter(v:GetPivot().Position) > 2000 then
					print(
						"skipped mob due to being "
							.. LocalPlayer:DistanceFromCharacter(v:GetPivot().Position)
							.. " studs away from the player."
					)
				else
					table.insert(MobTable, v.Name)
				end
			end
		end
	end
	UpdateMobTable()

	local mobsDropdown = MainTab:Dropdown({
		Name = "Select Mob",
		Items = MobTable, -- Tabel
		Callback = function(mobName)
			selectedMob = mobName
		end,
	})

	workspace.Live.ChildAdded:Connect(function()
		UpdateMobTable()
		mobsDropdown:UpdateList({
			Items = MobTable,
			Replace = true,
		})
	end)

	workspace.Live.ChildRemoved:Connect(function()
		UpdateMobTable()
		mobsDropdown:UpdateList({
			Items = MobTable,
			Replace = true,
		})
	end)

	local mobFarmThread = nil
	MainTab:Toggle({
		Name = "Farm Mob",
		Default = false,
		Callback = function(enableFarm)
			if enableFarm then
				mobFarmThread = task.spawn(function()
					local function get_nearest_mob()
						local nearest = math.huge
						local mob = nil
						local Mobs = workspace.Live:GetChildren()
						for i = 1, #Mobs do
							local v = Mobs[i]
							if v.Name == selectedMob and v:FindFirstChildOfClass("Humanoid").Health ~= 0 then
								if nearest > LocalPlayer:DistanceFromCharacter(v:GetPivot().Position) then
									nearest = LocalPlayer:DistanceFromCharacter(v:GetPivot().Position)
									mob = v
								end
							end
						end
						return mob
					end
					while task.wait() do
						local mob = nil
						repeat
							mob = get_nearest_mob()
							if not mob then
								task.wait(5)
							end
						until mob

						local ret = TweenToTargetPosition(LocalPlayerCharacter, mob:GetPivot().Position)

						if ret == Enum.PathStatus.NoPath then
							window:Notify({
								Name = "Failed to traverse to mob",
								Text = "Perhaps you are too far away from it or there is no path to it!",
								Duration = 5,
							})
						else
							local maxPeriodHits = 32
							local hum = mob:FindFirstChild("Humanoid")
							local Cps = 12
							local split = 1 / Cps
							local hitsThisPeriod = 0
							while
								task.wait()
								and hum
								and hum.Health > 0
								and maxPeriodHits > hitsThisPeriod
								and (
										LocalPlayerCharacter.HumanoidRootPart.CFrame.Position
										- mob:GetPivot().Position
									).Magnitude
									< 5
							do
								local tU = {
									Key = CODEXUS_SHARED_STATE.RemotesKey,
									InputState = "LeftClick",
									Pressing = false,
								}

								local selectedAttack = math.random(0, 2)

								if selectedAttack == 1 then
									tU.Pressing = true
									ReplicatedStorage.Remotes.Input:FireServer(tU)
									task.wait() -- Wait a heartbeat between the two to avoid spam ratelimit.
									tU.Pressing = false
									ReplicatedStorage.Remotes.Input:FireServer(tU)
								elseif selectedAttack == 2 then
									local old = tU.InputState
									tU.InputState = "Heavy"
									tU.Pressing = true
									ReplicatedStorage.Remotes.Input:FireServer(tU)
									task.wait() -- Wait a heartbeat between the two to avoid spam ratelimit.
									tU.Pressing = false
									ReplicatedStorage.Remotes.Input:FireServer(tU)
									tU.InputState = old
								end

								task.wait(split)
								local lookAt = CFrame.lookAt(
									LocalPlayerCharacter.HumanoidRootPart.CFrame.Position,
									mob:GetPivot().Position
								) -- Looks at mob

								LocalPlayerCharacter:PivotTo(lookAt)
								hitsThisPeriod = hitsThisPeriod + 1
							end
						end
					end
				end)
			else
				if mobFarmThread then
					task.cancel(mobFarmThread)
					mobFarmThread = nil
				end
			end
		end,
	})

	--- #endregion Mob Farming

	local NpcsTable = {}
	local selectedNPC = nil
	local function UpdateNpcsTable()
		NpcsTable = {}
		for _, v in pairs(workspace.NPCs:GetChildren()) do
			local NPCSSS = v.Name
			if not table.find(NpcsTable, NPCSSS) and v:IsA("Model") then
				if LocalPlayer:DistanceFromCharacter(v:GetPivot().Position) > 2000 then
					print(
						"skipped npc due to being "
							.. LocalPlayer:DistanceFromCharacter(v:GetPivot().Position)
							.. " studs away from the player."
					)
				else
					table.insert(NpcsTable, v.Name)
				end
			end
		end
	end
	UpdateNpcsTable()

	local npcDrop = MainTab:Dropdown({
		Name = "Select NPC",
		Items = NpcsTable, -- Tabel
		Callback = function(npcName)
			selectedNPC = npcName
		end,
	})

	workspace.NPCs.ChildAdded:Connect(function()
		UpdateNpcsTable()
		npcDrop:UpdateList({
			Items = NpcsTable,
			Replace = true,
		})
	end)

	workspace.NPCs.ChildRemoved:Connect(function()
		UpdateNpcsTable()
		npcDrop:UpdateList({
			Items = NpcsTable,
			Replace = true,
		})
	end)

	MainTab:Button({
		Name = "Go to Npc",
		Callback = function()
			for _, v in pairs(workspace.NPCs:GetChildren()) do
				if v.Name == selectedNPC and v:IsA("Model") then
					print("Callback invoked")
					local ret = TweenToTargetPosition(LocalPlayerCharacter, v:GetPivot().Position)

					if ret == Enum.PathStatus.NoPath then
						window:Notify({
							Name = "Failed to traverse to mob",
							Text = "Perhaps you are too far away from it or there is no path to it!",
							Duration = 5,
						})
					end
					break
				end
			end
		end,
	})
end

function initialiseAuto(window)
	-- Tab
	local AutosTab = window:Tab({
		Name = "Autos",
		Description = "~~ Peroxide ~~ | ~~ Codexus Hub ~~",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	local clicksPerSecond = 6
	AutosTab:Slider({
		Name = "M1 per second",
		Min = 5,
		Max = 14,
		Default = 6,
		Callback = function(newCps)
			clicksPerSecond = newCps
		end,
	})

	--- @type thread | nil
	local autoM1Thread = nil
	AutosTab:Toggle({
		Name = "Auto M1",
		Default = false,
		Callback = function(enableAutoM1)
			if autoM1Thread then
				task.cancel(autoM1Thread)
				autoM1Thread = nil
			end

			if not CODEXUS_SHARED_STATE.RemotesKey then
				window:Notify({
					Name = "Please execute any input at LEAST once!",
					Text = "Do an M1, or any kind of movement before enabling this feature.",
					Duration = 5,
				})
			end

			if enableAutoM1 then
				autoM1Thread = task.spawn(function()
					local tU = {
						Key = CODEXUS_SHARED_STATE.RemotesKey,
						InputState = "LeftClick",
						Pressing = false,
					}

					while task.wait() do
						local splitSecond = 1 / clicksPerSecond
						for i = 0, clicksPerSecond do
							tU.Pressing = true
							ReplicatedStorage.Remotes.Input:FireServer(tU)
							task.wait() -- Wait a heartbeat between the two to avoid spam ratelimit.
							tU.Pressing = false
							ReplicatedStorage.Remotes.Input:FireServer(tU)

							task.wait(splitSecond)
						end
					end
				end)
			end
		end,
	})

	--- @type thread | nil
	local autoHeavyThread = nil
	AutosTab:Toggle({
		Name = "Automatic Heavy Attacks",
		Default = false,
		Callback = function(enableAutoHeavy)
			if autoHeavyThread then
				task.cancel(autoHeavyThread)
				autoHeavyThread = nil
			end

			if not CODEXUS_SHARED_STATE.RemotesKey then
				window:Notify({
					Name = "Please execute any input at LEAST once!",
					Text = "Do an M1, or any kind of movement before enabling this feature.",
					Duration = 5,
				})
			end

			if enableAutoHeavy then
				autoHeavyThread = task.spawn(function()
					local tU = {
						Key = CODEXUS_SHARED_STATE.RemotesKey,
						InputState = "Heavy",
						Pressing = false,
					}
					local clicksPerSecond = 4 -- Redefine.

					while task.wait() do
						local splitSecond = 1 / clicksPerSecond
						for i = 0, clicksPerSecond do
							tU.Pressing = true
							ReplicatedStorage.Remotes.Input:FireServer(tU)
							task.wait() -- Wait a heartbeat between the two to avoid spam ratelimit.
							tU.Pressing = false
							ReplicatedStorage.Remotes.Input:FireServer(tU)

							task.wait(splitSecond)
						end
					end
				end)
			end
		end,
	})

	--- @type thread | nil
	local autoGripThread = nil
	AutosTab:Toggle({
		Name = "Automatic Grip [Auto Hollow Eat]",
		Default = false,
		Callback = function(enableAutoGrip)
			if autoGripThread then
				task.cancel(autoGripThread)
				autoGripThread = nil
			end

			if not CODEXUS_SHARED_STATE.RemotesKey then
				window:Notify({
					Name = "Please execute any input at LEAST once!",
					Text = "Do an M1, or any kind of movement before enabling this feature.",
					Duration = 5,
				})
			end

			if enableAutoGrip then
				autoGripThread = task.spawn(function()
					local tU = {
						Key = CODEXUS_SHARED_STATE.RemotesKey,
						InputState = "Grip",
						Pressing = false,
					}
					local clicksPerSecond = 3 -- Redefine.

					while task.wait() do
						local splitSecond = 1 / clicksPerSecond
						for i = 0, clicksPerSecond do
							tU.Pressing = true
							ReplicatedStorage.Remotes.Input:FireServer(tU)
							task.wait(5) -- Wait a heartbeat between the two to avoid spam ratelimit.
							tU.Pressing = false
							ReplicatedStorage.Remotes.Input:FireServer(tU)

							task.wait(splitSecond)
						end
					end
				end)
			end
		end,
	})
end

function initialiseVisuals(window)
	local VisualsTab = window:Tab({
		Name = "Visuals",
		Description = "~~ Peroxide ~~ | ~~ Codexus Hub ~~",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	--- #region Mob ESP

	local camera = workspace.CurrentCamera
	local entitiesFolder = game:GetService("Workspace").Live
	local runService = game:GetService("RunService")
	local espEnabled = true

	local function esp(entity)
		local humanoid = entity:FindFirstChild("Humanoid")
		local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart")

		if not humanoid or not humanoidRootPart then
			return
		end

		local textLabel = Drawing.new("Text")
		textLabel.Visible = false
		textLabel.Center = true
		textLabel.Outline = true
		textLabel.Font = 2
		textLabel.Color = Color3.fromRGB(0, 255, 0)
		textLabel.Size = 13

		local ancestryChangedConnection
		local healthChangedConnection
		local renderSteppedConnection

		local function disconnectConnections()
			textLabel.Visible = false
			textLabel:Remove()
			if ancestryChangedConnection then
				ancestryChangedConnection:Disconnect()
				ancestryChangedConnection = nil
			end
			if healthChangedConnection then
				healthChangedConnection:Disconnect()
				healthChangedConnection = nil
			end
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end

		ancestryChangedConnection = entity.AncestryChanged:Connect(function(_, parent)
			if not parent then
				disconnectConnections()
			end
		end)

		healthChangedConnection = humanoid.HealthChanged:Connect(function(health)
			if health <= 0 then
				disconnectConnections()
			end
		end)

		renderSteppedConnection = runService.RenderStepped:Connect(function()
			local hrpPosition, hrpOnScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
			if hrpOnScreen then
				local distance = (camera.CFrame.Position - humanoidRootPart.Position).Magnitude
				if distance <= 1000 then -- Adjust the distance threshold as needed
					textLabel.Position = Vector2.new(hrpPosition.X, hrpPosition.Y)
					textLabel.Text = string.format(
						"%s\nDistance: %.2f\nHealth: %.1f",
						humanoid.DisplayName,
						distance,
						humanoid.Health
					)
					textLabel.Visible = espEnabled
				else
					textLabel.Visible = false
				end
			else
				textLabel.Visible = false
			end
		end)
	end

	local function entityAdded(entity)
		if entity:IsA("Model") and not entity:FindFirstChild("Health") then
			esp(entity)
		end
		entity.ChildAdded:Connect(function(child)
			if child:IsA("Model") and not child:FindFirstChild("Health") then
				esp(child)
			end
		end)
	end

	local function toggleESP()
		espEnabled = not espEnabled
		for _, entity in ipairs(entitiesFolder:GetChildren()) do
			if not entity:FindFirstChild("Health") then
				entityAdded(entity)
			end
		end
	end
	for _, entity in ipairs(entitiesFolder:GetChildren()) do
		if not entity:FindFirstChild("Health") then
			entityAdded(entity)
		end
	end

	entitiesFolder.ChildAdded:Connect(entityAdded)

	VisualsTab:Toggle({
		Name = "Mob ESP",
		Default = false,
		Callback = function()
			toggleESP()
		end,
	})

	--- #endregion Mob ESP
end

-- Hooks MUST be initialised before the UI, as it locks the thread on UI init.
initialise_connections_and_initialise_functions()
initialiseHooks()

repeat
	task.wait() -- Wait for game to load fully.
until game:IsLoaded()

-- Window Initialisation
local Window = UILibrary:Create({ ToggleKey = Enum.KeyCode.Insert })

initialiseMain(Window)
initialiseAuto(Window)
initialiseVisuals(Window)
