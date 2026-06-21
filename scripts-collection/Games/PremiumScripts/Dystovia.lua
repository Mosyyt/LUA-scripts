if not LRM_IsUserPremium then
	game:GetService("Players").LocalPlayer:Kick("[Loader] This script is Premium Only. Get it on our Discord server!")
	task.wait(1)
	if LPH_OBFUSCATED then
		LPH_CRASH()
	end
	return
end

local Players = game.Players
local rs = game:GetService("RunService")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayerCharacter = lp.Character or lp.CharacterAdded:Wait()
lp.CharacterAdded:Connect(function(character)
	LocalPlayerCharacter = character
end)
local Library = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/Scripts/master/YouWontDoAnythingWithThat.lua")
)()

local Window = Library:Create({
	ToggleKey = Enum.KeyCode.Insert,
})

--- Util function.
function grabWeapon()
	for _, v in pairs(LocalPlayerCharacter:GetChildren()) do
		local damagePart = v:FindFirstChildWhichIsA("BasePart")
		if damagePart and string.find(damagePart.Name, "Damage") then
			return v, damagePart
		end
	end
end

local CODEX_SHARED_STATE = {
	EnableNoFall = true,
}

function initialiseHooks()
	local oldNoFall
	oldNoFall = hookmetamethod(game, "__namecall", function(...)
		if not CODEX_SHARED_STATE.EnableNoFall then
			return oldNoFall(...) -- Return immediately.
		end

		local self = select(1, ...)

		if not checkcaller() and getnamecallmethod() == "FireServer" and self and self.Name == "FallDamage" then
			local args = { ... }
			if #args < 2 then
				return oldNoFall(...) -- Not target
			elseif typeof(args[2]) == "number" then
				args[2] = -1 -- Modify 2, 1 is self.
				return oldNoFall(unpack(args))
			end
		end
		return oldNoFall(...)
	end)
end

function initialiseMain(window)
	local Tab = window:Tab({
		Name = "~~ Dystovia ~~ Main ~~",
		Description = "~~ Codexus Hub [Premium Only] ~~",
		Icon = "rbxassetid://11254763826", -- Tab Icon
		Color = Color3.new(0.811765, 0.313725, 0.247059), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	-- STRICT DEPENDENCIES ON THIS CODE! THANKS BEBO, DAMN YOU!

	local weapon, damagePart = grabWeapon()
	local MobsNameFolder = game:GetService("ReplicatedStorage").MobDrops
	local MobsFolder = workspace.MobFolder
	local mobs = {}

	for i, v in pairs(MobsNameFolder:GetChildren()) do
		table.insert(mobs, v.Name) -- Mob names, somehow.
	end
	table.insert(mobs, #mobs)
	--- @type string | nil
	local selectedMob = nil
	--- @type Instance | nil
	local currentMob = nil
	
	Tab:Dropdown({
		Name = "Select A Mob",
		Items = mobs, -- Table
		Callback = function(Dotikk)
			selectedMob = Dotikk
		end,
	})

	--- @type nil | RBXScriptConnection
	local farmSelectionConnection = nil
	Tab:Toggle({
		Name = "Farm selected mob",
		Default = false,
		Callback = function(enableFarming)
			if enableFarming then
				local function FindNextValidMob()
					local mobs = MobsFolder:GetChildren()
					for i = 1, #mobs do
						local v = mobs[i]
						local humanoid = v:FindFirstChildOfClass("Humanoid")
						if
							v.Name == selectedMob
							and humanoid
							and humanoid.Health > 0
							and v:FindFirstChild("HumanoidRootPart")
						then
							return v
						end
					end
				end
				local function MoveToNextMob()
					if currentMob ~= nil and MobsFolder and MobsFolder:FindFirstChild(selectedMob) then
						currentMob = currentMob or FindNextValidMob()

						if currentMob then
							local humanoid = currentMob:FindFirstChildOfClass("Humanoid")
							if humanoid and humanoid.Health > 0 then
								repeat
									task.wait()

									LocalPlayerCharacter.HumanoidRootPart.CFrame = currentMob:GetPivot()
											* CFrame.Angles(math.rad(-90), 0, 0)
										+ Vector3.new(0, 6, 0)
								until not currentMob or not farmSelectionConnection or humanoid.Health == 0
							end
							currentMob = FindNextValidMob()
						end
					end
				end

				farmSelectionConnection = rs.Heartbeat:Connect(function()
					MoveToNextMob()
				end)
			else
				if farmSelectionConnection then
					farmSelectionConnection:Disconnect()
					farmSelectionConnection = nil
				end
			end
		end,
	})

	--- @type nil | RBXScriptConnection
	local mobInstaKillConnection = nil

	Tab:Toggle({
		Name = "Mob Instant Kill",
		Callback = function(enableInstantKill)
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			if enableInstantKill then
				mobInstaKillConnection = rs.Heartbeat:Connect(function()
					local Mobs = MobsFolder:GetChildren()
					for i = 1, #Mobs do
						local v = Mobs[i]
						local MobDistanceTOPlayer = (
							LocalPlayerCharacter.HumanoidRootPart.Position - v:GetPivot().Position
						).Magnitude
						if
							MobDistanceTOPlayer < 12
							and v:FindFirstChild("MobArea")
							and v:FindFirstChildOfClass("Humanoid").Health ~= 0
						then
							for _ = 1, 6, 1 do
								ReplicatedStorage.Events.DamageEvents.DamageDetect:FireServer(
									true,
									"Attack",
									v.MobArea,
									damagePart
								)
							end -- Call 6 times.
						end
					end
				end)
			else
				if mobInstaKillConnection then
					mobInstaKillConnection:Disconnect()
					mobInstaKillConnection = nil
				end
			end
		end,
	})

	Tab:Section({ Name = "~~ Reach ~~" })

	local reachDistance = 16
	Tab:Slider({
		Name = "Reach Distance",
		Min = 1,
		Max = 80,
		Default = 16,
		Callback = function(selectedVal)
			reachDistance = selectedVal
		end,
	})

	--- @type nil | RBXScriptConnection
	local connectionReachWeapon = nil

	Tab:Toggle({
		Name = "Weapon Reach",
		Callback = function(enableWeaponReach)
			if connectionReachWeapon and connectionReachWeapon.Connected then
				connectionReachWeapon:Disconnect()
			end

			if enableWeaponReach then
				connectionReachWeapon = rs.Heartbeat:Connect(function()
					for _, v in pairs(MobsFolder:GetChildren()) do
						local mobArea = v:FindFirstChild("MobArea")
						if mobArea then
							local distance = (mobArea.Position - LocalPlayerCharacter.HumanoidRootPart.Position).Magnitude
							if distance <= reachDistance then
								if damagePart then
									firetouchinterest(damagePart, mobArea, 0)
									firetouchinterest(damagePart, mobArea, 1)
								end
							end
						end
					end
				end)
			end
		end,
	})
end

function initialiseTeleports(window)
	local Tab = window:Tab({
		Name = "~~ Dystovia ~~ Teleports ~~",
		Description = "~~ Codexus Hub [Premium Only] ~~",
		Icon = "rbxassetid://3926305904", -- Tab Icon
		Color = Color3.new(0.909803, 1, 0.317647), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	local ruins = {}

	for _, ruinInstance in ipairs(workspace.Ruins:GetChildren()) do
		table.insert(ruins, ruinInstance.Name)
	end
	table.insert(ruins, #ruins)

	Tab:Dropdown({
		Name = "Ruin Teleport",
		Items = ruins, -- Tabel
		Callback = function(ruinName)
			LocalPlayerCharacter:PivotTo(workspace.Ruins[ruinName]:GetPivot())
		end,
	})
end

function initialiseMisc(window)
	local PlayerService = game:GetService("Players")

	local Tab = window:Tab({
		Name = "~~ Dystovia ~~ Miscellaneous ~~",
		Description = "~~ Codexus Hub [Premium Only] ~~",
		Icon = "rbxassetid://3926305904", -- Tab Icon
		Color = Color3.new(0.384313, 0.631372, 1), -- Tab Colour
		Hidden = false, -- IGNORE THIS
	})

	local ChestsTable = {}
	local selectedChest
	local function UpdateChests()
		ChestsTable = {}
		for _, v in pairs(workspace.Chests:GetChildren()) do
			local chestName = v.Name
			if not table.find(ChestsTable, chestName) then
				table.insert(ChestsTable, v.Name)
			end
		end
	end
	UpdateChests()

	Tab:Section({ Name = "~~ Chests ~~" })
	local ChestsDropdown = Tab:Dropdown({
		Name = "Select Chest",
		Items = ChestsTable, -- Tabel
		Callback = function(itemName)
			selectedChest = itemName
		end,
	})
	Tab:Button({
		Name = "TP To Chest",
		Callback = function()
			LocalPlayerCharacter:PivotTo(workspace.Chests[selectedChest]:GetPivot())
		end
	})
	workspace.Chests.ChildAdded:Connect(function()
		UpdateChests()
		ChestsDropdown:UpdateList({
			Items = ChestsTable,
			Replace = true,
		})
	end)

	workspace.Chests.ChildRemoved:Connect(function()
		UpdateChests()
		ChestsDropdown:UpdateList({
			Items = ChestsTable,
			Replace = true,
		})
	end)

	Tab:Label({ Text = "Go near a chest and toggle to Dupe" })

	--- @type nil | thread
	local dupeThread = nil
	Tab:Toggle({
		Name = "Dupe Chest Items",
		Default = false,
		Callback = function(akiw12)
			if dupeThread then
				task.cancel(dupeThread)
			end

			if akiw12 then
				local function ChestDupe()
					for _, v in pairs(workspace.Chests:GetChildren()) do
						local itemsInsideItem = v:FindFirstChild("Item")
						local distance = (v:GetPivot().Position - LocalPlayerCharacter.HumanoidRootPart.Position).Magnitude
						if itemsInsideItem and distance <= 50 then
							for _, item in pairs(itemsInsideItem:GetChildren()) do
								game.ReplicatedStorage.Events.ItemEvents.ItemPickup:FireServer(v, item.Name, "Chest")
								task.wait(0.2)
							end
						end
					end
				end
				dupeThread = task.spawn(function()
					while task.wait(1) do
						ChestDupe()
					end
				end)
			end
		end,
	})


	Tab:Section({
		Name = "~~ Others ~~",
	})
	local moneyamout
	Tab:Textbox({
		Name = "Store Money Ammount",
		Default = "Money Ammount Here", -- Default Text in the box
		Callback = function(txt)
			moneyamout = txt
		end
	})
	Tab:Button({
		Name = "Store Money",
		Callback = function()
			game:GetService("ReplicatedStorage").Events.Saving.GoldStoring:FireServer(tonumber(moneyamout))
		end
	})
	
	local selectedScroll
	local ScrollsTable = {}

	local function UpdateScrolls()
		ScrollsTable = {}  -- Clear the existing table
		for _, v in pairs(ReplicatedStorage.Items[lp.Name.."Items"]:GetChildren()) do
			if string.find(v.Name, "Scroll") then
				local scrollName = v.Name
				if not table.find(ScrollsTable, scrollName) then
					table.insert(ScrollsTable, scrollName)
				end
			end
		end
	end
	
	UpdateScrolls()

	local ScrollNamesDropdown = Tab:Dropdown({
		Name = "Select Scroll",
		Items = ScrollsTable, -- Tabel
		Callback = function(ScrollNa90)
			selectedScroll = ScrollNa90
		end,
	})

	ReplicatedStorage.Items[lp.Name.."Items"].ChildAdded:Connect(function(ScrollName)
		if string.find(ScrollName.Name, "Scroll") then
			UpdateScrolls()
			ScrollNamesDropdown:UpdateList({
				Items = ScrollsTable,
				Replace = true,
			})
		end
	end)

	ReplicatedStorage.Items[lp.Name.."Items"].ChildRemoved:Connect(function(ScrollName2)
		if string.find(ScrollName2.Name, "Scroll") then
			UpdateScrolls()
			ScrollNamesDropdown:UpdateList({
				Items = ScrollsTable,
				Replace = true,
			})
		end
	end)

	--- @type nil | thread
	local AutoSelectedScroll = nil
	Tab:Toggle({
		Name = "Use Selected Scroll",
		Default = false,
		Callback = function(Statenier)
			if AutoSelectedScroll then
				task.cancel(AutoSelectedScroll)
			end

			if Statenier then
				local function UseScroll()
					game:GetService("ReplicatedStorage").Events.ItemEvents.UseScroll:FireServer(selectedScroll)
				end
				AutoSelectedScroll = task.spawn(function()
					while task.wait(1) do
						UseScroll()
					end
				end)
			end
		end,
	})

	--- @type nil|RBXScriptConnection
	local propChangedSigInfStamina = nil

	Tab:Toggle({
		Name = "Infinite Stamina",
		Default = false,
		Callback = function(state)
			if propChangedSigInfStamina and propChangedSigInfStamina.Connected then
				propChangedSigInfStamina:Disconnect()
			end

			if state then
				local leadStats = PlayerService.LocalPlayer.LeadStats
				propChangedSigInfStamina = leadStats.Stamina:GetPropertyChangedSignal("Value"):Connect(function()
					game:GetService("Players").LocalPlayer.LeadStats.Stamina.Value = leadStats.MaxStamina.Value
				end)
			end
		end,
	})

	--- @type nil|RBXScriptConnection
	local propChangedSigDodgeCooldown = nil

	Tab:Toggle({
		Name = "No Dodge Cooldown",
		Default = false,
		Callback = function(state)
			if propChangedSigDodgeCooldown and propChangedSigDodgeCooldown.Connected then
				propChangedSigDodgeCooldown:Disconnect()
			end

			if state then
				propChangedSigDodgeCooldown = LocalPlayerCharacter.Dodging
					:GetPropertyChangedSignal("Value")
					:Connect(function()
						LocalPlayerCharacter.Dodging.Value = false
					end)
			end
		end,
	})

	--- @type nil|RBXScriptConnection
	local propChangedSigNoKnockback = nil
	Tab:Toggle({
		Name = "Anti Knockback",
		Default = false,
		Callback = function(state)
			if propChangedSigNoKnockback and propChangedSigNoKnockback.Connected then
				propChangedSigNoKnockback:Disconnect()
			end

			if state then
				propChangedSigNoKnockback = LocalPlayerCharacter.Knockbacked
					:GetPropertyChangedSignal("Value")
					:Connect(function()
						LocalPlayerCharacter.Knockbacked.Value = false
					end)
			end
		end,
	})

	--- @type nil | thread
	local pickupThread = nil
	Tab:Toggle({
		Name = "Auto Loot Pick Up",
		Default = false,
		Callback = function(state)
			if pickupThread then
				task.cancel(pickupThread)
			end

			if state then
				local function pickupLootAuto()
					for _, v in pairs(game.workspace.LootFolder:GetChildren()) do
						local itemsInsideItem = v:FindFirstChild("Item")
						if itemsInsideItem then
							for _, item in pairs(itemsInsideItem:GetChildren()) do
								ReplicatedStorage.Events.ItemEvents.ItemPickup:FireServer(v, item.Name)
								break
							end
						end
					end
				end
				pickupThread = task.spawn(function()
					while task.wait(1) do
						pickupLootAuto()
					end
				end)
			end
		end,
	})

	--- @type nil | thread
	local herbFarm = nil
	Tab:Toggle({
		Name = "Auto Farm Herbs",
		Default = false,
		Callback = function(herbAutoF)
			if herbFarm then
				task.cancel(herbFarm)
			end

			if herbAutoF then
				local function pickupHerbs()
					for _, v in pairs(workspace.Herbs:GetChildren()) do
						for _, Herb in pairs(v:GetChildren()) do
							if Herb:IsA("Model") and Herb:FindFirstChild("BasePart") then
								lp.Character:PivotTo(Herb:GetPivot())
								local distance = (Herb:GetPivot().Position - lp.Character.HumanoidRootPart.Position).Magnitude
								if distance <= 20 then
									task.wait(0.1)
									game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
								end
								task.wait(0.1)
							end
						end
					end
				end
				herbFarm = task.spawn(function()
					while task.wait(0.1) do
						pickupHerbs()
					end
				end)
			end
		end,
	})
end

initialiseHooks()
initialiseMain(Window)
initialiseTeleports(Window)
initialiseMisc(Window)
