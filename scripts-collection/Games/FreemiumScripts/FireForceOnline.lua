local PlayerService = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = PlayerService.LocalPlayer
local LocalPlayerCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

LocalPlayer.CharacterAdded:Connect(function(character)
	LocalPlayerCharacter = character
end)

local Characters = workspace.Alive

local function Noclip()
	for i, v in pairs(LocalPlayerCharacter:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide == true then
			v.CanCollide = false
			LocalPlayerCharacter.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
		end
	end
end

local function FreezeLocalPlayerCharacter()
	local nofall = LocalPlayerCharacter.HumanoidRootPart:FindFirstChild("FREEZED_CHAR")
	if nofall then
		return nofall
	end
	nofall = Instance.new("BodyVelocity", LocalPlayerCharacter.HumanoidRootPart)
	nofall.Name = "FREEZED_CHAR"
	nofall.Velocity = Vector3.new(0, 0, 0)
	return nofall
end

local function UnfreezeLocalPlayerCharacter()
	local nofallObj = LocalPlayerCharacter:FindFirstChild("HumanoidRootPart"):FindFirstChild("FREEZED_CHAR")
	if not nofallObj then
		return false
	end
	nofallObj:Destroy()
	return true
end

local function TweenToObject(object, speed, rotation, offset)
	if not offset then
		offset = Vector3.new(0, -3, 0)
	end
	local info = TweenInfo.new(
		(LocalPlayerCharacter.HumanoidRootPart.Position - object.CFrame.Position).Magnitude / speed,
		Enum.EasingStyle.Linear
	)
	local tween = TweenService:Create(
		LocalPlayerCharacter.HumanoidRootPart,
		info,
		{ CFrame = (object.CFrame + offset) * CFrame.Angles(math.rad(-rotation), 0, 0) }
	)
	local noclipConnection

	if UnfreezeLocalPlayerCharacter() then
		FreezeLocalPlayerCharacter()
	end
	noclipConnection = RunService.Heartbeat:Connect(Noclip)
	tween:Play()

	tween.Completed:Connect(function()
		UnfreezeLocalPlayerCharacter()
		noclipConnection:Disconnect()
	end)
	return tween
end

local function TweenToPostion(cframe, speed, rotation, offset)
	if not offset then
		offset = Vector3.new(0, 3, 0)
	end

	local info = TweenInfo.new(
		(LocalPlayerCharacter.HumanoidRootPart.Position - cframe.Position).Magnitude / speed,
		Enum.EasingStyle.Linear
	)
	local tween = TweenService:Create(
		LocalPlayerCharacter.HumanoidRootPart,
		info,
		{ CFrame = (cframe + offset) * CFrame.Angles(math.rad(-rotation), 0, 0) }
	)
	local nofall
	local noclipConnection

	if UnfreezeLocalPlayerCharacter() then
		nofall = FreezeLocalPlayerCharacter()
	end

	noclipConnection = RunService.Heartbeat:Connect(Noclip)
	tween:Play()

	tween.Completed:Connect(function()
		UnfreezeLocalPlayerCharacter()
		noclipConnection:Disconnect()
	end)
	return tween
end
local VirtualInputManager = game:GetService("VirtualInputManager")

local Library = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua")
)()
local mobNames = {
	"AdultCivilianNPC",
	"Amaterasu",
	"Backpacker",
	"BerserkerInfernal",
	"Brandon",
	"CarThief",
	"ChildCivilianNPC",
	"ChildNPC",
	"CrawlerInfernal",
	"Curt",
	"ExplodingInfernal",
	"FireForceScientist",
	"Girl",
	"Inca",
	"Infernal",
	"Infernal Demon",
	"Infernal Oni",
	"Infernal2",
	"LightningNPC",
	"OldLady",
	"OldMan",
	"Parry Block",
	"Parry No Block",
	"Pedro",
	"PurseNPC",
	"PurseNPC",
	"RealExaminer",
	"Shadow",
	"ShoNPC",
	"ShoTest",
	"SummoningInfernal",
	"Thug1",
	"ThugNPC",
	"UnknownExaminer",
	"WhiteCladDefender1",
	"WhiteCladScout",
	"WhiteCladTraitor1",
	"WhiteCladTraitor2",
}
local function KillAuraF(KADistance)
	for _, v in pairs(workspace.Alive:GetChildren()) do
		local knockedValue = v:FindFirstChild("Knocked")
		local carriedValue = v:FindFirstChild("Carried")

		if LocalPlayer.Character and v.Name ~= LocalPlayer.Name and not carriedValue then
			local targetPosition = nil
			if v:FindFirstChild("Head") then
				targetPosition = v.Head.Position
			elseif v:FindFirstChild("HumanoidRootPart") then
				targetPosition = v.HumanoidRootPart.Position
			end

			if
				targetPosition
				and LocalPlayer:DistanceFromCharacter(targetPosition) <= KADistance
				and not knockedValue
			then
				game:GetService("ReplicatedStorage").Events.CombatEvent
					:FireServer(math.random(1, 3), LocalPlayer.Character.FistCombat, v:GetPivot(), true)
				game:GetService("ReplicatedStorage").Events.M2Event
					:FireServer(LocalPlayer.Character.FistCombat, 0, true)
			end
		end
	end
end

local function clickUiButton(button, state)
	local buttonPosX = button.AbsolutePosition.X + button.AbsoluteSize.X / 2
	local buttonPosY = button.AbsolutePosition.Y + 66
	VirtualInputManager:SendMouseButtonEvent(buttonPosX, buttonPosY, 0, state, game, 1)
end
local Window = Library:Create({
	ToggleKey = Enum.KeyCode.Insert,
})

--- Settings for the game's hooks, metamethods and functions.
local HookSettings = {
	EnableAntiRagdollHook = false,
}

function InitializeHooks()
	local oldAntiRagdoll
	oldAntiRagdoll = hookmetamethod(
		game,
		"__namecall",
		newcclosure(function(...)
			local method = getnamecallmethod()
			local self = select(1, ...)

			if
				self
				and HookSettings.EnableAntiRagdollHook
				and method == "FireServer"
				and (self.Name == "AttackOnBack" or self.Name == "Ragdoll")
			then
				return nil -- Suppress this remotes from firing.
			end
			return oldAntiRagdoll(...)
		end)
	)
end

function InitializeMainTab(window)
	-- Tab
	local Tab = window:Tab({
		Name = "Fire Force",
		Description = "~~ Codexus Hub ~~ Press Insert! ~~",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	-- This feature could use optimisation by using ChildAdded instead
	-- But we are about to release to optimise this, too bad!

	local knockbackConnection = nil
	Tab:Toggle({
		Name = "Anti Knockback/Stun/Ragdoll",
		Default = false,
		Callback = function(enableAKnock)
			if knockbackConnection then
				knockbackConnection:Disconnect()
				knockbackConnection = nil
			end

			HookSettings.EnableAntiRagdollHook = enableAKnock
			if enableAKnock then
				knockbackConnection = RunService.Stepped:Connect(function()
					for i, v in pairs(LocalPlayer.Character:GetChildren()) do
						if
							v.Name == "AttackStun"
							or v.Name == "HitCD"
							or v.Name == "Stun"
							or v.Name == "Knocked"
							or v.Name == "DEAD"
							or v.Name == "TempKnocked"
						then
							v:Destroy()
						end
					end
					for i, v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
						if
							v.Name == "BodyVelocity"
							or v:IsA("BallSocketConstraint")
							or v:IsA("NoCollisionConstraint")
						then
							v:Destroy()
						end
					end
				end)
			end
		end,
	})

	local KillAura

	Tab:Toggle({
		Name = "Kill Aura",
		Default = false,
		Callback = function(KillAura2)
			if KillAura2 then
				KillAura = RunService.Heartbeat:Connect(function()
					KillAuraF(13)
				end)
			else
				if KillAura then
					KillAura:Disconnect()
				end
			end
		end,
	})

	--- @type thread | nil
	local autoParryThread
	Tab:Toggle({
		Name = "Auto Parry",
		Default = false,
		Callback = function(enableAutoParry)
			if autoParryThread then
				task.cancel(autoParryThread)
				autoParryThread = nil
			end

			if enableAutoParry then
				autoParryThread = task.spawn(function()
					local function isPlayer(workspacePath)
						return workspacePath:FindFirstChild("ClientEffects") ~= nil
					end
					local mobList = {}

					for _, child in ipairs(workspace.Alive:GetChildren()) do
						if not isPlayer(child) then
							local dbgId = child.GetDebugId()
							mobList[dbgId] = child -- Dbg ids are probably unique, just perfect!
						end
					end

					--- The mob to check for its movements and attacks bs.
					local watchedMob = nil
					local function setTargetOfClosestRegisteredMob()
						for _, mob in mobList do
							local mobPart = mob:FindFirstChildOfClass("BasePart")

							if not mobPart then
								mobPart = mob:FindFirstChildOfClass("Part")
							end

							if not mobPart then
								mobPart = mob:FindFirstChildOfClass("Meshpart")
							end

							if not mobPart then
								print("[Auto Parry] -> Whoops, something occured that shouldn't have had!")
							else
								if LocalPlayer:DistanceFromCharacter() < 5 then
									watchedMob = mob
									break
								end
							end
						end
					end

					workspace.Alive.ChildAdded:Connect(
						--- @param child Instance
						function(child)
							task.wait(1)
							if not isPlayer(child) then
								local dbgId = child.GetDebugId()
								mobList[dbgId] = child -- Dbg ids are probably unique, just perfect!
							end
						end
					)
					workspace.Alive.ChildRemoved:Connect(function(child)
						if not isPlayer(child) then
							local dbgId = child.GetDebugId()
							mobList[dbgId] = nil
						end
					end)

					local watcherThread = task.create(function()
						while task.wait(1) do
							setTargetOfClosestRegisteredMob()
						end
					end)

					while task.wait() do
						if watchedMob then
							if watchedMob:FindFirstChild("Punched") then
								game:GetService("ReplicatedStorage").Events.ParryEvent:FireServer()
								task.wait(0.6)
							end
						end
					end
				end)
			end
		end,
	})

	local Markers = {}

	for _, marker in ipairs(workspace.AllMissionMarkers:GetChildren()) do
		table.insert(Markers, marker.Name)
	end

	table.insert(Markers, #Markers)

	local selectedMarker
	local Dropdown
	Dropdown = Tab:Dropdown({
		Name = "Select Marker",
		Items = Markers,
		Callback = function(sMarker)
			selectedMarker = sMarker

			table.clear(Markers)
			for _, marker in ipairs(workspace.AllMissionMarkers:GetChildren()) do
				table.insert(Markers, marker.Name)
			end

			table.insert(Markers, #Markers)

			if Dropdown then
				Dropdown:Clear()

				Dropdown:UpdateList({
					Items = Markers,
					Replace = true,
				})
			end
		end,
	})

	Tab:Button({
		Name = "Go To Marker",
		Callback = function()
			game.Players.LocalPlayer.Character:PivotTo(workspace.AllMissionMarkers[selectedMarker].Adornee:GetPivot())
		end,
	})
end

function InitializeTrainingTab(window)
	local Tab = window:Tab({
		Name = "Training",
		Description = "Codexus Hub",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	local DTraining = false
	Tab:Toggle({
		Name = "Defense Training",
		Default = false,
		Callback = function(bool312)
			DTraining = bool312
		end,
	})

	task.spawn(function()
		while true do
			if DTraining then
				for _, v in ipairs(LocalPlayer.PlayerGui.TrainingGui.KeyOrder:GetChildren()) do
					if v:IsA("Frame") then
						local keyText = v.Key and v.Key.Text
						if keyText then
							game:GetService("ReplicatedStorage").Events.TrainingEvent:FireServer("Defense", keyText)
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)

	local StrengthTraining

	Tab:Toggle({
		Name = "Strength Training",
		Default = false,
		Callback = function(StrengthTraining2)
			if StrengthTraining2 then
				StrengthTraining = RunService.Heartbeat:Connect(function()
					local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
					if playerGui then
						local trainingGui = playerGui.TrainingGui
						local clickButton = trainingGui
							and trainingGui.KeyArea
							and trainingGui.KeyArea:FindFirstChild("ClickButton")
						if clickButton then
							clickUiButton(clickButton, true)
							clickUiButton(clickButton, false)
						end
					end
				end)
			else
				if StrengthTraining then
					StrengthTraining:Disconnect()
				end
			end
		end,
	})
end

function InitializeFarmingTab(window)
	local Tab = window:Tab({
		Name = "Farming",
		Description = "Codexus Hub",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	local SelectedMob
	local Distance
	Tab:Section({ Name = "Mob Farm" })

	Tab:Dropdown({
		Name = "Select Mob",
		Items = mobNames, -- Table
		Callback = function(Mob)
			SelectedMob = Mob
		end,
	})
	Tab:Slider({
		Name = "Mob Distance",
		Min = 1, -- Min Val
		Max = 10, -- Max Val
		Default = 6, -- Default Val
		Callback = function(DSSA)
			Distance = DSSA
		end,
	})

	local CurrentMob
	local FarmSelected
	Tab:Toggle({
		Name = "Farm Mob",
		Default = false,
		Callback = function(state1)
			if state1 then
				FarmSelected = task.spawn(function()
					while task.wait() do
						if
							not CurrentMob
							or not CurrentMob:FindFirstChildOfClass("Humanoid")
							or (CurrentMob:FindFirstChildOfClass("Humanoid") and CurrentMob:FindFirstChildOfClass(
								"Humanoid"
							).Health == 0)
							or not CurrentMob:FindFirstChild("HumanoidRootPart")
						then
							CurrentMob = nil
							local Mobs = Characters:GetChildren()
							for i = 1, #Mobs do
								local v = Mobs[i]
								if
									not SelectedMob
									or v.Name == SelectedMob.Name
										and (v:FindFirstChildOfClass("Humanoid") and v:FindFirstChildOfClass("Humanoid").Health > 0)
										and v:FindFirstChild("HumanoidRootPart")
										and LocalPlayer.Character
								then
									local head = v:FindFirstChild("Head")
									local missionMarker = head and head:FindFirstChild("MissionMarker")
									if
										not missionMarker
										or not (
											missionMarker:FindFirstChild("ImageLabel")
											and missionMarker.ImageLabel.Visible
										)
									then
										CurrentMob = v
										break
									end
								end
							end
						end

						if CurrentMob and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
							local knockedValue = CurrentMob:FindFirstChild("Knocked")
							if not knockedValue then
								print("Tweening")
								TweenToPostion(CurrentMob.Head.CFrame, 90, 150, Vector3.new(0, Distance, 0)).Completed:Wait()
								print("Tween completed")
							else
								game:GetService("ReplicatedStorage").Events.GripEvent:FireServer(false, CurrentMob)
							end
						end
					end
				end)
			else
				if FarmSelected then
					task.cancel(FarmSelected)
					FarmSelected = nil
				end
			end
		end,
	})

	Tab:Section({ Name = "Player Farm" })

	local selectedPlayer
	local PlayersTable = {}

	local function UpdatePlayers()
		table.clear(PlayersTable)
		for i, v in ipairs(game.Players:GetPlayers()) do
			if LocalPlayer.Name ~= v.Name then
				table.insert(PlayersTable, v.Name)
			end
		end
	end

	UpdatePlayers()

	local Dropdown4 = Tab:Dropdown({
		Name = "Select Player",
		Items = PlayersTable,
		Callback = function(Player91)
			selectedPlayer = Player91
		end,
	})

	local PlayerFarmTP

	Tab:Toggle({
		Name = "Farm Player",
		Default = false,
		Callback = function(PlayerFarmTP2)
			if PlayerFarmTP2 then
				PlayerFarmTP = RunService.Heartbeat:Connect(function()
					for _, v in pairs(workspace.Alive:GetChildren()) do
						if
							LocalPlayer.Character
							and v.Name ~= LocalPlayer.Name
							and v.Name == selectedPlayer
							and not v:FindFirstChild("Knocked")
						then
							print("Tweening")
							TweenToPostion(v.HumanoidRootPart.CFrame, 90, 150, Vector3.zero).Completed:Wait()
							print("Tween Completed!")
							KillAuraF(10)
						end
					end
				end)
			else
				if PlayerFarmTP then
					PlayerFarmTP:Disconnect()
				end
			end
		end,
	})

	-- Update PlayersTable and Dropdown when players join or leave the game
	game.Players.PlayerAdded:Connect(function(player)
		UpdatePlayers()
		Dropdown4:UpdateList({
			Items = PlayersTable,
			Replace = true,
		})
	end)

	game.Players.PlayerRemoving:Connect(function(player)
		UpdatePlayers()
		Dropdown4:UpdateList({
			Items = PlayersTable,
			Replace = true,
		})
	end)
end

InitializeMainTab(Window)
InitializeTrainingTab(Window)
InitializeFarmingTab(Window)
